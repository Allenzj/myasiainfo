package com.asiainfo.dacp.dp.server.scheduler.service;

import java.util.Date;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.asiainfo.dacp.dp.common.RunStatus;
import com.asiainfo.dacp.dp.server.DpServerContext;
import com.asiainfo.dacp.dp.server.scheduler.bean.TargetObj;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskConfig;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;
import com.asiainfo.dacp.dp.server.scheduler.trigger.DpEventTrigger;
import com.asiainfo.dacp.dp.server.scheduler.type.RunFreq;
import com.asiainfo.dacp.dp.server.scheduler.utils.TimeUtils;
import com.asiainfo.dacp.dps.zookpeer.service.ZkService;

/**
 * @category 启动taskserver
 * @author wangyuanbin
 */
@Service
@ZkService
public class TaskManager {
	@Value("${supplementType}")
	private String supplementType;
	@Value("${zookeeper.enabled}")
	private String zookeeperEnable;
	@Value("${sms.alarm.enable}")
	private String smsAlarmEnable;
	@Value("${taskMaxRunTime}")
	private int taskMaxRunTime;
	
	public String getZookeeperEnable() {
		return zookeeperEnable;
	}
	
	@Value("${server.id}")
	private String serverId;
	public String getServerId() {
		return serverId;
	}
	
	@Autowired
	private DatabaseDao dbDao;
	@Autowired
	private TaskService taskService;
	@Autowired
	private ShipbuilderService kinship;
	@Autowired
	private DpServerContext dpContext;
	@Autowired
	private CheckResourceService checkResourceService;
	@Autowired
	private DpEventTrigger dpTrigger;
	private boolean isRuning = true;
	private static Logger LOG = LoggerFactory.getLogger(TaskManager.class);
	private ExecutorService threads = Executors.newFixedThreadPool(10);
	
	public void startup() {
		try {
			
			LOG.info("启动消息侦听服务");
			dpContext.getDpReceiver().start();
			LOG.info("持久化补数据");
			if(Integer.valueOf(StringUtils.isEmpty(supplementType)?"0":supplementType)==1){
				dpContext.getDpSupplement().start();
			}
			LOG.info("启动agent检测服务");
			taskService.checkAgentService();
			LOG.info("加载缓存数据");
			initCache();
			LOG.info("启动定时任务");
			taskService.timeTrigger();
			LOG.info("启动平均时长计划任务");
			taskService.createSqlTask("0 50 23 * * ? ");
			LOG.info("启动定时计划任务");
			taskService.createTaskPlanService("0 45 23 * * ? ");
			LOG.info("启动上线下线检测服务");
			taskService.createCheckStateService("0 0 0/3 * * ? ");
			if(("true").equals(smsAlarmEnable)){
				LOG.info("启动定时告警服务");
				taskService.createTaskAlarmService();
			}
			//T0筛选状态0重做后续的任务，处理重做后续并锁定后续所有线程，避免多线程操作数据库带来的风险
			//T1筛选创建成功的任务，并发依赖检测
			//T2筛选状态2的执行模式检测
			//T3执行模式检测通过的检测agent并发数筛选agent
			//T4agent筛选成功的存进待发送缓存队列
			//T5多线程并发获取待发送队列任务，发送至agent
			//T6多线程筛选执行成功的，触发后续，并移除队列
			//T7多线程筛选执行失败，判断是否自动重做或者移除队列
			//T8多线程检测状态4或者5的运行中的任务是否超时
			while (isRuning) {
				long t1 = System.currentTimeMillis();
				// 同步配置信息--上线下线控制
				taskService.refreshTaskConfig();
				long t2 = System.currentTimeMillis();
				showConsumeTime("同步上下线信息",t1, t2);
				
				// 更新后续任务
				taskService.updateNextTaskCfg();
				long t3 = System.currentTimeMillis();
				showConsumeTime("更新后续任务",t2, t3);
				
				// 更新依赖信息
				taskService.updateSourceLog();
				long t4 = System.currentTimeMillis();
				showConsumeTime("更新依赖信息",t3, t4);
				
				// 外部数据触发
				dpTrigger.triggerByData();
				long t5 = System.currentTimeMillis();
				showConsumeTime("外部数据触发",t4, t5);
				
				// 分发任务
				distributeTask();
				long t6 = System.currentTimeMillis();
				showConsumeTime("分发任务",t5, t6);
				
				/* 已经很慢了，就别睡了吧
				TimeUtils.sleep(5);
				*/
			}
			
		} catch (Exception e) {
			e.printStackTrace();
			LOG.error(e.getMessage());
		}
	}
	
	/**
	 * 打印消耗时间
	 * @param msg 提示信息
	 * @param start 开始时间
	 * @param end 结束时间
	 * @param interval 消耗时间超过此阀值，打印信息，单位秒
	 */
	private void showConsumeTime(String msg,long start,long end,int interval){
		long diff = (end - start) / 1000;
		if(diff > interval){
			LOG.info(msg+",耗时过长：{}",TimeUtils.timeDiff(start, end));
		}
	}
	
	/**
	 * 打印消耗时间，默认超过60秒打印
	 * @param msg 提示信息
	 * @param start 开始时间
	 * @param end 结束时间
	 */
	private void showConsumeTime(String msg,long start,long end){
		showConsumeTime( msg, start, end, 60);
	}

	/***
	 * 分发任务
	 */
	private void distributeTask() {
		try {
			// 清楚缓存信息
			MemCache.clearTmpCache();
			// 初始化缓存
			List<TaskLog> queueList = taskService.initTaskRunLogCache();
			int taskState = -7;
			String runFreq = null;
			for (TaskLog runInfo : queueList) {
				try{
				taskState = runInfo.getTaskState();
				runFreq = runInfo.getRunFreq();
				// 手工任务，直接发Agent执行
				if (runFreq.equals(RunFreq.manual.name())) {
					if (taskState == RunStatus.CHECK_IPS_SUCCESS) {
						taskService.sendProcToAgent(runInfo);
						runInfo.setExecTime(TimeUtils.dateToString(new Date()));
						taskService.updateState(runInfo, RunStatus.SEND_TO_MQ);
					}
					continue;
				}
				if (MemCache.PROC_MAP.get(runInfo.getXmlid()) == null) {
					runInfo.setQueueFlag(1);
					runInfo.setTriggerFlag(1);
					// 如果是强制通过的
					if (taskState == RunStatus.PROC_RUN_SUCCESS) {
						taskService.updateState(runInfo,RunStatus.PROC_RUN_SUCCESS);
					} else {
						taskService.setTaskError(runInfo, String.format("task[%s] the configure was invalid", runInfo.getTaskId()));
					}
					continue;
				}
				
				//此代码必须移除到队列处理
				if(("true").equals(smsAlarmEnable)){
					//错误告警
					taskService.taskRunFailAlarm(runInfo);
				}
				// 非手工任务
				// 按状态值分组
				if (taskState == RunStatus.REDO) {
					MemCache.REDO_TASK_MAP.put(runInfo.getSeqno(), runInfo);
				} else if (taskState == RunStatus.CREATE_TASK) {
					if(MemCache.INTERIM_PROC_NEXR_PROC_MAP.containsKey(runInfo.getXmlid())){//临时重做直接发送执行模式检测
						checkResourceService.check(runInfo);
					}else{
						 List<TargetObj> targetList= dbDao.getTargetMap(runInfo.getFlowcode(),runInfo.getXmlid(),null);
						if(targetList!=null&&targetList.size()>0){
							checkResourceService.check(runInfo);
						}else{
							MemCache.DEPEND_TASK_MAP.put(runInfo.getSeqno(), runInfo);
						}
					}
				} else if (taskState == RunStatus.CHECK_DEPEND_SUCCESS) {
					MemCache.RUNMODE_TASK_MAP.put(runInfo.getSeqno(), runInfo);
				} else if (taskState == RunStatus.CHECK_IPS_SUCCESS) {
					MemCache.RUNMODE_TASK_MAP.put(runInfo.getSeqno(), runInfo);
				} else if (taskState == RunStatus.SEND_TO_MQ) {
					checkTimeOut(runInfo);//检测发送超时
				} else if (taskState == RunStatus.PROC_RUNNING) {
					checkTimeOut(runInfo);//检测运行任务超时
				} else if (taskState == RunStatus.PROC_RUN_SUCCESS) {
					MemCache.TRIGGER_TASK_MAP.put(runInfo.getSeqno(), runInfo);
				} else if (taskState >= 50) {
					autoRedoTask(runInfo);// 失败重做
				}
				}catch(Exception e){
					LOG.error("", e);
				}
			}
			// 处理重做
			for (TaskLog task : MemCache.REDO_TASK_MAP.values()) {
				if (manualRedoTask(task)) {
					MemCache.DEPEND_TASK_MAP.put(task.getSeqno(), task);
				}
			}
			// 处理内部触发
			for (TaskLog triggerTask : MemCache.TRIGGER_TASK_MAP.values()) {
				dpTrigger.tiggerByProc(triggerTask);
			}
			// 处理依赖检测
			CountDownLatch latch = new CountDownLatch(
					MemCache.DEPEND_TASK_MAP.size());
			for (final TaskLog task : MemCache.DEPEND_TASK_MAP.values()) {
				threads.execute(new CheckDependService(dpContext, task, latch));
			}
			latch.await();
			//不用再次排序，SQL排完序之后，可直接筛选执行模式队列中任务顺序执行
			for (TaskLog runInfo : queueList) {
				if(MemCache.RUNMODE_TASK_MAP.containsKey(runInfo.getSeqno())){
					checkResourceService.check(runInfo);
				}
			}
			//立即执行
			
		} catch (Exception e) {
			LOG.error("", e);
		}
	}
	/** 加载缓存数据 */
	private void initCache() throws Exception {
		taskService.distinguishDB();
		taskService.initConfig();
		taskService.initTaskRunLogCache();
	}
	/**
	 * 程序运行超时处理默认12小时不处理，超时
	 * 
	 * @param runInfo
	 */
	private void checkTimeOut(TaskLog runInfo) {
		Date start = TimeUtils.convertToTime(runInfo.getExecTime());
		Integer  procMaxRunTime=runInfo.getMaxRunHours()==null?taskMaxRunTime:runInfo.getMaxRunHours();
		long dif = (new Date().getTime() - start.getTime()) / (1000L * 3600L);
		if (dif <= procMaxRunTime) {
			return;
		}
		String error = String.format(
				"任务[%s]发送至agent超时%s小时,请及检查agent[%s]状态或者消息服务器状态",
				runInfo.getTaskId(), dif,runInfo.getAgentCode());
		taskService.setTaskError(runInfo, error);
		taskService.killProcess(runInfo);
	}

	private boolean manualRedoTask(TaskLog _runInfo) {
		LOG.info("start redo task："+_runInfo.getProcName()+"["+_runInfo.getXmlid()+"]["+_runInfo.getSeqno()+"] ["+_runInfo.getDateArgs()+"]");
		taskService.deleteRunResult(_runInfo);
		taskService.initSourceLog(_runInfo);
		//重做后续
		if (_runInfo.getTriggerFlag() == 0) {
			//获取任务后续任务列表
			List<TaskLog> taskList=kinship.getAfterTask(_runInfo);
			//循环处理后续任务
			for (TaskLog runInfo : taskList) {
				//如果重做定时任务，那么直接调用创建定时任务
				if(MemCache.PROC_MAP.get(runInfo.getXmlid()).getTriggerType().toString().equals("0")){
					taskService.invalidTask(runInfo);	//失效任务
					taskService.reDoTimeTriggerTask(MemCache.PROC_MAP.get(runInfo.getXmlid()),runInfo);//直接创建定时任务
				//事件触发任务
				}else{
					switch (runInfo.getTaskState()) {
						case RunStatus.REDO:
						case RunStatus.CREATE_TASK:
						case 0 - RunStatus.CREATE_TASK:
						case RunStatus.CHECK_DEPEND_SUCCESS:
						case 0 - RunStatus.CHECK_DEPEND_SUCCESS:
						case RunStatus.CHECK_IPS_SUCCESS:
						case 0 - RunStatus.CHECK_IPS_SUCCESS:
							taskService.deleteTask(runInfo);//检测状态的结果无意义，直接删除	
							taskService.createTaskRunInfo(MemCache.PROC_MAP.get(runInfo.getXmlid()),TimeUtils.dateArgsToOptTime(runInfo.getDateArgs()), runInfo,null);//重做后续直接创建任务，检测依赖。
							break;
						case RunStatus.PROC_RUN_SUCCESS:
						case RunStatus.PROC_RUN_FAIL://有执行结果的记录保留日志，失效任务
							taskService.invalidTask(runInfo);	//失效任务
							taskService.createTaskRunInfo(MemCache.PROC_MAP.get(runInfo.getXmlid()),TimeUtils.dateArgsToOptTime(runInfo.getDateArgs()), runInfo,null);//重做后续直接创建任务，检测依赖。
							break;
						case RunStatus.SEND_TO_MQ:
						case RunStatus.PROC_RUNNING://正在运行的任务，直接停止任务
							taskService.killProcee(runInfo);//无论成功或失败，都失效当前任务，重建任务运行
							runInfo.setTaskState(RunStatus.PROC_RUN_FAIL);
							taskService.invalidTask(runInfo);	//失效任务
							taskService.createTaskRunInfo(MemCache.PROC_MAP.get(runInfo.getXmlid()),TimeUtils.dateArgsToOptTime(runInfo.getDateArgs()), runInfo,null);//重做后续直接创建任务，检测依赖。
							break;
						default: break;
					}
				}
			}
		}
		return taskService.updateState(_runInfo, RunStatus.CREATE_TASK);
	}
	/***
	 * 自动重做后续
	 * 
	 * @param runInfo
	 */
	private void autoRedoTask(TaskLog runInfo) {
		TaskConfig config = MemCache.PROC_MAP.get(runInfo.getXmlid());
		// 如果配置信息为空
		if (config == null) {
			runInfo.setQueueFlag(1);
			runInfo.setTriggerFlag(1);
			taskService.updateState(runInfo, runInfo.getTaskState());
			MemCache.TASK_MAP.remove(runInfo.getSeqno());
			return;
		}
		try {
			Integer redoNum = config.getRedoNum();
			Integer retryNum = runInfo.getRetryNum();
			if (redoNum - retryNum > 0) {
				runInfo.setReturnCode(0);
				Date begin = new Date();
				Date end = runInfo.getEndTime()==null?begin:TimeUtils.convertToTime(runInfo.getEndTime());
				long timeDiff = begin.getTime()-end.getTime();
				long waitMinute = timeDiff / (1000 * 60);
				if (waitMinute >= config.getRedoInterval()) {
					runInfo.setQueueFlag(0);
					runInfo.setTriggerFlag(0);
					runInfo.setTaskState(1);
					runInfo.setRetryNum(retryNum + 1);
					runInfo.setExecTime(null);
					runInfo.setEndTime(null);
					if (taskService.updateState(runInfo,
							RunStatus.CHECK_DEPEND_SUCCESS)) {
						MemCache.RUNMODE_TASK_MAP.put(runInfo.getSeqno(), runInfo);
					}
				}
			} else {
				runInfo.setQueueFlag(1);
				runInfo.setTriggerFlag(1);
				taskService.updateState(runInfo, runInfo.getTaskState());
				MemCache.TASK_MAP.remove(runInfo.getSeqno());
			}
		} catch (Exception ex) {
			LOG.error("", ex);
		}
	}
}
