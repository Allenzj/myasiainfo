package com.asiainfo.dacp.dp.server.scheduler.service;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;

import org.apache.commons.lang.StringUtils;
import org.quartz.CronExpression;
import org.quartz.TriggerUtils;
import org.quartz.impl.triggers.CronTriggerImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.asiainfo.dacp.dp.common.MapKeys;
import com.asiainfo.dacp.dp.common.RunStatus;
import com.asiainfo.dacp.dp.common.RunStatus.AlarmType;
import com.asiainfo.dacp.dp.message.DpMessage;
import com.asiainfo.dacp.dp.message.DpSender;
import com.asiainfo.dacp.dp.server.DpServerContext;
import com.asiainfo.dacp.dp.server.scheduler.bean.AgentIps;
import com.asiainfo.dacp.dp.server.scheduler.bean.ClassInfo;
import com.asiainfo.dacp.dp.server.scheduler.bean.MetaLog;
import com.asiainfo.dacp.dp.server.scheduler.bean.Relationship;
import com.asiainfo.dacp.dp.server.scheduler.bean.SourceLog;
import com.asiainfo.dacp.dp.server.scheduler.bean.SourceObj;
import com.asiainfo.dacp.dp.server.scheduler.bean.TargetObj;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskAlarmInfo;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskAlarmLog;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskConfig;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.command.ScheduleCmdLineBuilder;
import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;
import com.asiainfo.dacp.dp.server.scheduler.exchange.SupplementThread;
import com.asiainfo.dacp.dp.server.scheduler.quartz.QuartzJob;
import com.asiainfo.dacp.dp.server.scheduler.quartz.QuartzPlanJob;
import com.asiainfo.dacp.dp.server.scheduler.quartz.QuartzSqlJob;
import com.asiainfo.dacp.dp.server.scheduler.quartz.StateCheckJob;
import com.asiainfo.dacp.dp.server.scheduler.quartz.TaskAlarmJob;
import com.asiainfo.dacp.dp.server.scheduler.sms.ISmsSender;
import com.asiainfo.dacp.dp.server.scheduler.type.DBType;
import com.asiainfo.dacp.dp.server.scheduler.type.DataFreq;
import com.asiainfo.dacp.dp.server.scheduler.type.MsgType;
import com.asiainfo.dacp.dp.server.scheduler.type.ObjType;
import com.asiainfo.dacp.dp.server.scheduler.type.ProcStatus;
import com.asiainfo.dacp.dp.server.scheduler.type.RunFreq;
import com.asiainfo.dacp.dp.server.scheduler.type.Type;
import com.asiainfo.dacp.dp.server.scheduler.type.Type.DRIVE_TYPE;
import com.asiainfo.dacp.dp.server.scheduler.utils.ConvertUtils;
import com.asiainfo.dacp.dp.server.scheduler.utils.TimeUtils;
import com.asiainfo.dacp.dp.server.scheduler.utils.UUIDUtils;
import com.asiainfo.dacp.rabbitmq.Message;
import com.mchange.v2.c3p0.ComboPooledDataSource;

@Service
public class TaskService {
	@Autowired
	private DatabaseDao dbDao;
	@Autowired
	private ComboPooledDataSource dataSource;
	@Autowired
	private DpSender dpSender;
	@Autowired
	private DpServerContext dpContext;
	@Autowired
	private HeartbeatService heartbeatService;
	@Autowired
	private ScheduleCmdLineBuilder cmdLineBuilder;
	@Autowired
	private SupplementThread supplementThread;
	@Autowired
	private ISmsSender smsSender;
	
	private static Logger LOG = LoggerFactory.getLogger(TaskManager.class);
	private static boolean flag=true;
	public void taskRunFailAlarm(TaskLog runInfo){
		TaskConfig config = MemCache.PROC_MAP.get(runInfo.getXmlid());
		//任务已下线
		if(config==null)return;

		int taskState = runInfo.getTaskState();
		//运行失败任务
		if (taskState >= RunStatus.PROC_RUN_FAIL){
			//自动重做已经结束
			if(runInfo.getRetryNum() >= config.getRedoNum()){
				try {
					//查看该任务告警信息
					TaskAlarmInfo errorAlarmInfo = dbDao.queryTaskAlarmInfoByProcXmid(config.getXmlid(),AlarmType.PROC_ERROR);
					//该任务配置了错误告警信息
					if(errorAlarmInfo!=null){
						//List<TaskAlarmLog> taskAlarmLogList = dbDao.getTaskAlarmLogList(config.getXmlid(),config.getDateArgs(),AlarmType.PROC_ERROR);
						//int maxAlarmCount = Integer.parseInt(errorAlarmInfo.getMaxSendCount());
						//int intervalTime = Integer.parseInt(errorAlarmInfo.getIntervalTime());
						SimpleDateFormat  sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
						
						//if(taskAlarmLogList.size() < maxAlarmCount){
							//long  nowTime=System.currentTimeMillis();
							//没有告警记录或者上次告警间隔时间大于配置告警间隔
							//if(taskAlarmLogList.size()==0 || (taskAlarmLogList.size()>0 && (nowTime-sdf.parse(taskAlarmLogList.get(0).getAlarmTime()).getTime())/(60*1000)>= intervalTime)){
								Map<String,Object> alarmData= new HashMap<String, Object>();
								alarmData.put("xmlid", UUIDUtils.getUUID());
								alarmData.put("proc_xmlid", runInfo.getXmlid());
								alarmData.put("proc_name", runInfo.getProcName());
								alarmData.put("proc_date_args", runInfo.getDateArgs());
								int alarmType = AlarmType.PROC_ERROR;
								alarmData.put("alarm_type",alarmType);
								alarmData.put("alarm_content",String.format("[调度告警]:任务[%s,%s,%s] 执行报错",runInfo.getSeqno(),runInfo.getProcName(),runInfo.getDateArgs()));
								alarmData.put("alarm_time", sdf.format(new Date()));
								//记录告警信息
								if(dbDao.insert("proc_schedule_alarm_log",alarmData)){
									//发送告警短信
									SendSmsService(alarmData);
								}
							//}
						//}
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}	
	}
	
	public void distinguishDB() {
		String driverClass = dataSource.getDriverClass();
		if ("com.mysql.jdbc.Driver".equals(driverClass)) {
			MemCache.DBTYPE = DBType.MYSQL;
		} else if ("oracle.jdbc.driver.OracleDriver".equals(driverClass)) {
			MemCache.DBTYPE = DBType.ORACLE;
		}
	}

	/***
	 * 初始化程序运行日志
	 * 
	 * @param xmlid
	 */
	public List<TaskLog> initTaskRunLogCache() throws Exception {
		synchronized (MemCache.TASK_MAP) {
			List<TaskLog> taskRunInfoList = dbDao.queryTaskRunLogList(
					-4, 100, 0);//等待终止任务会被失效，不能作为有效任务查询处理
			// 初始化任务队列表缓存
			// LOG.info("task list-size:{}", taskRunInfoList.size());
			TaskConfig config = null;
			int state = -100;
			Map<String, TaskLog> newMap = new ConcurrentHashMap<String, TaskLog>();
			// 临时保存map
			List<TaskConfig> nextProcList = null;
			Map<String, TaskLog> tmpMap = MemCache.TASK_MAP;
			for (TaskLog runInfo : taskRunInfoList) {
				if (StringUtils.equals(runInfo.getRunFreq(),
						RunFreq.manual.name())
						|| StringUtils.isEmpty(runInfo.getXmlid())) {
					config = null;
				} else {
					config = MemCache.PROC_MAP.get(runInfo.getXmlid());
				}
				if (config != null) {
					state = runInfo.getTaskState();
					if (state <= RunStatus.CHECK_IPS_SUCCESS
							&& state >= 0 - RunStatus.CHECK_IPS_SUCCESS) {
						runInfo.setPath(config.getPath());
						runInfo.setProctype(config.getProcType());
						runInfo.setAgentCode(config.getAgentCode());
						runInfo.setRunFreq(config.getRunFreq());
						runInfo.setRunpara(config.getRunpara());
						runInfo.setPlatform(config.getPlatform());
					}
				}
				newMap.put(runInfo.getSeqno(), runInfo);
				if(!StringUtils.isEmpty(runInfo.getFlowcode())){//获取临时调度的后续程序
					 List<TargetObj> targetList= dbDao.getTargetMap(TargetObj.class,runInfo.getFlowcode(),null,null,null);
					 for(int i=0;i<targetList.size();i++){
						 TaskConfig  taskConfig = dbDao.queryTaskConfig(targetList.get(i).getTarget());
						 if(MemCache.INTERIM_PROC_NEXR_PROC_MAP.containsKey(targetList.get(i).getSource())){
						 	 nextProcList = MemCache.INTERIM_PROC_NEXR_PROC_MAP.get(targetList.get(i).getSource());
							 nextProcList.add(taskConfig);
							 MemCache.INTERIM_PROC_NEXR_PROC_MAP.put(targetList.get(i).getSource(), nextProcList);
							 
						 }else{
							 nextProcList= new ArrayList<TaskConfig>();
							 nextProcList.add(taskConfig);
							 MemCache.INTERIM_PROC_NEXR_PROC_MAP.put(targetList.get(i).getSource(), nextProcList);
						 
						 }
					 }
				}
			}
			// 替换map
			MemCache.TASK_MAP = newMap;
			// 清除旧map
			tmpMap.clear();
			return taskRunInfoList;
		}
	}
	
	public void reInitProcConfig(TaskConfig config) {
		try {
			String xmlid = config.getXmlid();
			MemCache.PROC_MAP.put(xmlid, config);
			List<SourceObj> sourceList = dbDao.querySourceList(xmlid);
			List<TargetObj> targetList = dbDao.queryNextDataList(xmlid);
			if (sourceList.isEmpty()) {
				MemCache.SOURCE_MAP.remove(xmlid);
			} else {
				MemCache.SOURCE_MAP.put(xmlid, sourceList);
			}
			if (targetList.isEmpty()) {
				MemCache.TARGET_MAP.remove(xmlid);
			} else {
				MemCache.TARGET_MAP.put(xmlid, targetList);
			}
			// 更新依赖信息
			int state = 1;
			String seqno = null;
			List<SourceLog> srcLogList = new ArrayList<SourceLog>();
			
			TaskLog task = MemCache.TASK_MAP.get(config.getXmlid());
			if (task!=null){
				seqno = task.getSeqno();
				state = task.getTaskState();
				if (state == RunStatus.CREATE_TASK && dbDao.deleteLog("proc_schedule_source_log", seqno)){
					srcLogList = ConvertUtils.convertToSrouceLog(seqno,task.getDateArgs(),
							MemCache.SOURCE_MAP.get(task.getXmlid()));
					dbDao.saveSourceLog(srcLogList);
					MemCache.SRC_LOG_MAP.put(seqno, srcLogList);
				}
			}
		} catch (Exception e) {
			LOG.error("", e);
		}
	}

	// 日数据触发日任务，月数据触发月任务，小时数据触发小时任务
	private boolean isSameFreq(String runfreq, String sourceFreq) {
		if (StringUtils.equals(runfreq, RunFreq.day.name())
				&& sourceFreq.indexOf(DataFreq.D.name()) == 0) {
			return true;
		}
		if (StringUtils.equals(runfreq, RunFreq.month.name())
				&& sourceFreq.indexOf(DataFreq.M.name()) == 0) {
			return true;
		}
		if (StringUtils.equals(runfreq, RunFreq.hour.name())
				&& sourceFreq.indexOf(DataFreq.H.name()) == 0) {
			return true;
		}
		if (StringUtils.equals(runfreq, RunFreq.minute.name())
				&& sourceFreq.indexOf(DataFreq.MI.name()) == 0) {
			return true;
		}
		if (StringUtils.equals(runfreq, RunFreq.year.name())
				&& sourceFreq.indexOf(DataFreq.Y.name()) == 0) {
			return true;
		}
		return false;
	}

	/** 更新数据后续任务 */
	public void updateNextTaskCfg() {
		MemCache.DATA_NEXT_PROC_MAP.clear();
		MemCache.PROC_NEXT_PROC_MAP.clear();
		MemCache.DATA_NEXT_ALL_PROC_MAP.clear();
		MemCache.PROC_NEXT_ALL_PROC_MAP.clear();
		TaskConfig config = null;
		List<TaskConfig> nextTaskList = null;
		String refKey = null;
		// 建立数据触发程序索引
		List<Relationship> shipList = dbDao.queryRelList();
		for (Relationship ship : shipList) {
			refKey = ship.getSource() + "/" + ship.getSourcefreq();
			if(StringUtils.isNotEmpty(ship.getSourceAppoint())){
				refKey += "/" + ship.getSourceAppoint();
			}
			config = MemCache.PROC_MAP.get(ship.getTarget());
			if (config != null){
					//&& isSameFreq(config.getRunFreq(), ship.getSourcefreq())) {
				nextTaskList = MemCache.DATA_NEXT_PROC_MAP.get(refKey);
				if (nextTaskList == null) {
					nextTaskList = new ArrayList<TaskConfig>();
				}
				nextTaskList.add(config);
				if(StringUtils.equals(ship.getTriggerType(),String.valueOf(DRIVE_TYPE.EVENT_TRIGGER.ordinal()))){//如果是事件触发，存入事件触发缓存，供触发用
					MemCache.DATA_NEXT_PROC_MAP.put(refKey, nextTaskList);
				}
				MemCache.DATA_NEXT_ALL_PROC_MAP.put(refKey, nextTaskList);//所有目标都存入全量后续程序中，供重做后续使用
			}
		}
		// 建立程序触发程序索引
		List<TargetObj> nextProcList = dbDao.queryNextProcList(null);
		nextTaskList = null;
		for (TargetObj tarObj : nextProcList) {
			refKey = tarObj.getSource();
			config = MemCache.PROC_MAP.get(tarObj.getTarget());
			if (config != null
					&& isSameFreq(config.getRunFreq(), tarObj.getSourcefreq())) {
				nextTaskList = MemCache.PROC_NEXT_PROC_MAP.get(refKey);
				if (nextTaskList == null) {
					nextTaskList = new ArrayList<TaskConfig>();
				}
				nextTaskList.add(config);
				if(StringUtils.equals(tarObj.getTriggerType(),String.valueOf(DRIVE_TYPE.EVENT_TRIGGER.ordinal()))){//如果是事件触发，存入事件触发缓存，供触发用
				MemCache.PROC_NEXT_PROC_MAP.put(refKey, nextTaskList);
				}
				MemCache.PROC_NEXT_ALL_PROC_MAP.put(refKey, nextTaskList);
			}
		}
	}

	/**
	 * 更新程序依赖信息
	 */
	public void updateSourceLog() {
		MemCache.SRC_LOG_MAP.clear();
		// 初始化未执行完成的程序源
		try {
			List<SourceLog> srcLogList = dbDao.querySourceLogList();
			List<SourceLog> itemList = null;
			for (SourceLog srcLog : srcLogList) {
				itemList = MemCache.SRC_LOG_MAP.get(srcLog.getSeqno());
				if (itemList == null) {
					itemList = new LinkedList<SourceLog>();
				}
				itemList.add(srcLog);
				MemCache.SRC_LOG_MAP.put(srcLog.getSeqno(), itemList);
			}
		} catch (Exception e) {
			LOG.error("", e);
		}

	}

	/***
	 * 加载配置
	 */
	public void initConfig() {
		try {
			LOG.info("初始化任务配置信息");
			List<TaskConfig> procList = dbDao.queryTaskConfigList();
			List<SourceObj> srcList = dbDao.querySourceList(null);
			List<TargetObj> nextDataList = dbDao.queryNextDataList(null);
			List<SourceObj> srcItemList = null;
			List<TargetObj> nextDataItemList = null;
			String xmlid = null;
			for (TaskConfig config : procList) {
				xmlid = config.getXmlid();
				MemCache.PROC_MAP.put(xmlid, config);
				// 初始化输入表及依赖程序
				srcItemList = new ArrayList<SourceObj>();
				for (SourceObj srcObj : srcList) {
					if (StringUtils.equals(srcObj.getTarget(), xmlid)) {
						srcItemList.add(srcObj);
					}
				}
				if (!srcItemList.isEmpty()) {
					MemCache.SOURCE_MAP.put(xmlid, srcItemList);
				}
				// 初始化输出表
				nextDataItemList = new ArrayList<TargetObj>();
				for (TargetObj tarObj : nextDataList) {
					if (StringUtils.equals(tarObj.getSource(), xmlid)) {
						nextDataItemList.add(tarObj);
					}
				}
				if (!nextDataItemList.isEmpty()) {
					MemCache.TARGET_MAP.put(xmlid, nextDataItemList);
				}
			}
		} catch (Exception e) {
			LOG.info("数据加载失败！");
			LOG.error("", e);
		}
	}

	/***
	 * 更新任务状态信息
	 * 
	 * @param log
	 */
	public synchronized boolean updateState(TaskLog runInfo, int taskState) {
		synchronized (runInfo) {
			int updateState = taskState;
			int oldState = runInfo.getTaskState();
			if (oldState <= taskState) {
				updateState = taskState;
			} else {
				updateState = oldState;
			}
			runInfo.setTaskState(updateState);
			runInfo.setStatusTime(TimeUtils.dateToString(new Date()));
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("seqno", runInfo.getSeqno());
			map.put("task_state", runInfo.getTaskState());
			map.put("status_time", runInfo.getStatusTime());
			map.put("start_time", runInfo.getStartTime());
			map.put("exec_time", runInfo.getExecTime());
			map.put("end_time", runInfo.getEndTime());
			map.put("retrynum", runInfo.getRetryNum());
			map.put("queue_flag", runInfo.getQueueFlag());
			map.put("trigger_flag", runInfo.getTriggerFlag());
			map.put("agent_code", runInfo.getAgentCode());
			map.put("path", runInfo.getPath());
			map.put("runpara", runInfo.getRunpara());
			map.put("pid", runInfo.getPid());
			map.put("valid_flag", runInfo.getValidFlag());
			map.put("return_code",runInfo.getReturnCode()==null?0:runInfo.getReturnCode());
			
			//如果是成功或失败状态,更新任务运行时长
			if(taskState == 6||taskState>=50){
				String startTime = runInfo.getExecTime();
				String endTime = runInfo.getEndTime();
				if(StringUtils.isNotEmpty(startTime) && StringUtils.isNotEmpty(endTime)){
					try {
						map.put("use_time", TimeUtils.timeDiff(startTime, endTime));
					} catch (ParseException e) {
						// TODO Auto-generated catch block
						LOG.error("task[{}]:开始时间[{}]和结束时间[{}]格式有误!", runInfo.getTaskId(),startTime,endTime);
					}
				}else{
					map.put("use_time", "");
				}
				
			}
			if (dbDao.update("proc_schedule_log", "seqno", map)) {
				LOG.info("task[{}]:update status set status={}",
						runInfo.getTaskId(), runInfo.getTaskState());
				if (runInfo.getQueueFlag() == 1) {// 如果任务出队
					MemCache.TASK_MAP.remove(runInfo.getSeqno());
				}
				return true;
			} else {
				LOG.info("task[{}]:update status fail!", runInfo.getTaskId());
				return false;
			}
		}
	}

	public boolean updateSourceLog(final SourceLog srcLog) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("seqno", srcLog.getSeqno());
		map.put("source", srcLog.getSource());
		map.put("check_flag", srcLog.getCheckFlg());
		if (!dbDao.update("proc_schedule_source_log", "seqno,source", map)) {
			return false;
		}
		return true;
	}

	public boolean insertSourceLog(final SourceLog srcLog) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("seqno", srcLog.getSeqno());
		map.put("poc_name", srcLog.getProcName());
		map.put("source", srcLog.getSource());
		map.put("source_type", srcLog.getSourceType());
		map.put("data_time", srcLog.getDataTime());
		map.put("check_flag", srcLog.getCheckFlg());
		map.put("date_args", srcLog.getDateArgs());
		if (!dbDao.insert("proc_schedule_source_log", map)) {
			return false;
		}
		return true;
	}

	public boolean insertTaskLog(final TaskConfig config, final TaskLog runInfo) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("seqno", runInfo.getSeqno());
		map.put("xmlid", runInfo.getXmlid());
		map.put("proc_name", runInfo.getProcName());
		map.put("task_state", runInfo.getTaskState());
		map.put("start_time", runInfo.getStartTime());
		map.put("status_time", runInfo.getStatusTime());
		map.put("retrynum", runInfo.getRetryNum());
		map.put("date_args", runInfo.getDateArgs());
		map.put("proc_date", runInfo.getProcDate());
		map.put("queue_flag", runInfo.getQueueFlag());
		map.put("trigger_flag", runInfo.getTriggerFlag());
		map.put("agent_code", runInfo.getAgentCode());
		map.put("pri_level", runInfo.getPriLevel());
		map.put("platform", config.getPlatform());
		map.put("run_freq", config.getRunFreq());
		map.put("team_code", config.getTeamCode());
		map.put("time_win", TimeUtils.converToTimeWin(runInfo, config));
		map.put("flowcode", config.getFlowcode());
		map.put("runpara", config.getRunpara());
		map.put("proctype", config.getProcType());
		map.put("path", config.getPath());
		map.put("valid_flag", runInfo.getValidFlag());
		if (dbDao.insert("proc_schedule_log", map)) {
			LOG.info("task[{}] create taskLog success", runInfo.getTaskId());
			return true;
		} else {
			LOG.info("task[{}] create taskLog fail",runInfo.getTaskId());
			return false;
		}
	}

	/**
	 * @param config
	 *            程序配置
	 * @param optTime
	 *            数据日期
	 * @param baseDate
	 *            计划时间
	 * @return
	 */
	public synchronized TaskLog createTaskRunInfo(TaskConfig config, String optTime,
			TaskLog preTask,Date baseDate) {
		int triggerType = config.getTriggerType();
		Date now = null;
		TaskLog runInfo = new TaskLog();
		if(baseDate == null ){
			now = new Date();
		}else{
			now = baseDate;
		}
		String seqno = UUIDUtils.getUUID();
		/**** 数据日期 */
		runInfo.setPriLevel(config.getPriLevel());
		runInfo.setSeqno(seqno);
		runInfo.setXmlid(config.getXmlid());
		runInfo.setRunFreq(config.getRunFreq());
		runInfo.setProcName(config.getProcName());
		runInfo.setAgentCode(config.getAgentCode());
		runInfo.setTaskState(RunStatus.CREATE_TASK);
		runInfo.setStartTime(TimeUtils.dateToString2(now));
		runInfo.setTimeWin(config.getTimeWin());
		// 入队
		runInfo.setQueueFlag(0);
		runInfo.setTriggerFlag(0);
		runInfo.setValidFlag(0);
		// 流程号
		runInfo.setFlowcode(config.getFlowcode());
		runInfo.setRunpara(config.getRunpara());
		runInfo.setPath(config.getPath());
		runInfo.setProctype(config.getProcType());
		
		//未传递时间参数按日期偏移量计算日期批次 
		if (StringUtils.equals(optTime, null) ) {
			runInfo.setProcDate(TimeUtils.dateToString2Minute(now));
			runInfo.setDateArgs(TimeUtils.getDateArgs(config.getRunFreq(), now,
					config.getDateArgs()));
		} else {//传递日期批次
			String procDate = preTask == null ? TimeUtils.getPlanTime(optTime)
					: preTask.getProcDate();
			runInfo.setProcDate(procDate);
			runInfo.setDateArgs(TimeUtils.getDateArgs(config.getRunFreq(),
					optTime));
		}
		try {
			// 查询source
			List<SourceObj> srcObjList = MemCache.SOURCE_MAP.get(config
					.getXmlid());
			// 初始化不为null
			srcObjList = srcObjList == null ? new ArrayList<SourceObj>()
					: srcObjList;
			// 插入运行日志，源日志
			if (insertTaskLog(config, runInfo)) {
				// 删除计划任务
				List<TaskLog> runInfoList=dbDao.queryPlanTask(runInfo);
				for (int i = 0; i < runInfoList.size(); i++) {
					TaskLog taskLog = runInfoList.get(i);
					dbDao.deleteLog("proc_schedule_source_log", taskLog.getSeqno());
				}
				deletePlanTask(runInfo);
				//检查是否还有同批次未失效任务
//				List<TaskLog> sameTask = dbDao.checkExistSameInvalidTask(runInfo);
//				if(CollectionUtils.isNotEmpty(sameTask)){
//					for(TaskLog log : sameTask){
//						invalidTask(log);
//					}
//				}
				List<SourceLog> srcLogList = ConvertUtils.convertToSrouceLog(
						seqno, runInfo.getDateArgs(), srcObjList);
				if (dbDao.saveSourceLog(srcLogList)) {
					LOG.info("task[{}] create source log  success",runInfo.getTaskId());
					MemCache.SRC_LOG_MAP.put(runInfo.getSeqno(), srcLogList);
					MemCache.TASK_MAP.put(runInfo.getSeqno(), runInfo);
					MemCache.DEPEND_TASK_MAP.put(runInfo.getSeqno(), runInfo);
					return runInfo;
				} else {
					dbDao.deleteLog("proc_schedule_log", seqno);
					LOG.error("task[{}] create source log fail", runInfo.getTaskId());
				}
			} else {
				LOG.error("task[{}] create log fail", runInfo.getTaskId());
			}

		} catch (Exception e) {
			LOG.error("", e);
			LOG.info("task[{}]任务编号为：{}的job[{} {}]发生异常", seqno, config.getProcName(),
					runInfo.getDateArgs(), e.getMessage());
		}
		return null;
	}
	/**重做后续定时任务时，创建定时任务模板为定时任务本身
	 * @param config
	 *            程序配置
	 * @param optTime
	 *            数据日期
	 * @param baseDate
	 *            计划时间
	 * @return
	 */
	public TaskLog reDoTimeTriggerTask(TaskConfig config,TaskLog taskLog) {
		Date now = new Date();
		TaskLog runInfo = new TaskLog();
		String seqno = UUIDUtils.getUUID();
		/**** 数据日期 */
		runInfo.setPriLevel(config.getPriLevel());
		runInfo.setXmlid(config.getXmlid());
		runInfo.setSeqno(seqno);
		runInfo.setRunFreq(config.getRunFreq());
		runInfo.setProcName(config.getProcName());
		runInfo.setAgentCode(config.getAgentCode());
		runInfo.setTaskState(RunStatus.CREATE_TASK);
		runInfo.setStartTime(TimeUtils.dateToString2(now));
		// 入队
		runInfo.setQueueFlag(0);
		runInfo.setTriggerFlag(0);
		runInfo.setValidFlag(0);
		// 流程号
		runInfo.setFlowcode(config.getFlowcode());
		runInfo.setRunpara(config.getRunpara());
		runInfo.setPath(config.getPath());
		runInfo.setProctype(config.getProcType());
		// 时间触发
			runInfo.setProcDate(taskLog.getProcDate());
			runInfo.setDateArgs(taskLog.getDateArgs());
		try {
			// 查询source
			List<SourceObj> srcObjList = MemCache.SOURCE_MAP.get(config
					.getXmlid());
			// 初始化不为null
			srcObjList = srcObjList == null ? new ArrayList<SourceObj>()
					: srcObjList;
			// 插入运行日志，源日志
			if (insertTaskLog(config, runInfo)) {
				// 删除计划任务
				deletePlanTask(runInfo);
				List<SourceLog> srcLogList = ConvertUtils.convertToSrouceLog(
						seqno, runInfo.getDateArgs(), srcObjList);
				if (dbDao.saveSourceLog(srcLogList)) {
					LOG.info("task[{}] create source log  success",runInfo.getTaskId());
					MemCache.SRC_LOG_MAP.put(runInfo.getSeqno(), srcLogList);
					MemCache.TASK_MAP.put(runInfo.getSeqno(), runInfo);
					MemCache.DEPEND_TASK_MAP.put(runInfo.getSeqno(), runInfo);
					return runInfo;
				} else {
					dbDao.deleteLog("proc_schedule_log", seqno);
					LOG.error("task[{}] create source log fail", runInfo.getTaskId());
				}
			} else {
				LOG.error("task[{}] create log fail", runInfo.getTaskId());
			}

		} catch (Exception e) {
			LOG.error("", e);
			LOG.info("task[{}]任务编号为：{}的job[{} {}]发生异常", seqno, config.getProcName(),
					runInfo.getDateArgs(), e.getMessage());
		}
		return null;
	}
	public void updateProcTriggerFlag(String seqno) {
		Map<String, Object> porcTriggerMap = new HashMap<String, Object>();
		porcTriggerMap.put("seqno", seqno);
		porcTriggerMap.put("trigger_flag", 1);
		porcTriggerMap.put("queue_flag", 1);
		if(dbDao.update("proc_schedule_log", "seqno", porcTriggerMap)){
		    MemCache.TASK_MAP.remove(seqno);
		}
	}

	public synchronized void insertAppLog(TaskLog runInfo, String procLog) {
		// 替换字符"'
		// procLog = procLog.replaceAll("\'", " ");
		Map<String, Object> logMap = new HashMap<String, Object>();
		// 清除以前的日志
		dbDao.delete("delete from proc_schedule_script_log where seqno='"
				+ runInfo.getSeqno() + "'");
		logMap.put("seqno", runInfo.getSeqno());
		logMap.put("proc_name", runInfo.getProcName());
		logMap.put("app_log", procLog);
		if (dbDao.insert("proc_schedule_script_log", logMap)) {
			LOG.info("task[{}] insert run info log success",
					runInfo.getTaskId());
		} else {
			LOG.info("task[{}] insert task log fail", runInfo.getTaskId());
		}
	}

	public void invalidTask(TaskLog runInfo) {
		runInfo.setTriggerFlag(1);
		runInfo.setQueueFlag(1);
		runInfo.setValidFlag(1);
		runInfo.setStatusTime(TimeUtils.dateToString(new Date()));
		String sql="update proc_schedule_script_log set app_log=CONCAT(app_log,'\\n \\n【前置任务重做，此任务失效】') where seqno='"+runInfo.getSeqno()+"'";
		dbDao.update(sql);//追加日志为该日志失效
		updateState(runInfo, runInfo.getTaskState());
		String deleteSql="delete from proc_schedule_meta_log where seqno='"+runInfo.getSeqno()+"'";
		dbDao.update(deleteSql);//删除执行结果
	}

	public void waitToFinish(TaskLog runInfo) {
		int oldFlag = runInfo.getTriggerFlag();
		int oldState = runInfo.getTaskState();
		runInfo.setTriggerFlag(1);
		runInfo.setTaskState(RunStatus.WAIT_FINISH);
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("seqno", runInfo.getSeqno());
		map.put("trigger_flag", runInfo.getTriggerFlag());
		map.put("task_state", RunStatus.WAIT_FINISH);
		if (dbDao.update("proc_schedule_log", "seqno", map)) {
			LOG.info("task[{}]:update trigger_flag set trigger_falg={}",runInfo.getTaskId(),runInfo.getTriggerFlag());
		} else {
			runInfo.setTriggerFlag(oldFlag);
			runInfo.setTaskState(oldState);
			LOG.info("task[{}]:update trigger_flag fail!",runInfo.getTaskId());
		}
	}

	private boolean deletePlanTask(TaskLog runInfo) {
		String sql = " delete from proc_schedule_log where xmlid='"
				+ runInfo.getXmlid() + "' and date_args='"
				+ runInfo.getDateArgs() + "'   and task_state="
				+ RunStatus.PLAN_TASK;
		return dbDao.delete(sql);
	}
	/**
	 * 初始化任务依赖
	 * @param runInfo
	 * @return
	 */
	public boolean initSourceLog(TaskLog runInfo){
		String sourceSql = " delete from proc_schedule_source_log where proc_name='"
				+ runInfo.getProcName()+"' and date_args='" + runInfo.getDateArgs() + "'";
		if(dbDao.delete(sourceSql)){
			MemCache.SRC_LOG_MAP.remove(runInfo.getSeqno());
			List<SourceObj> srcObjList = MemCache.SOURCE_MAP.get(runInfo
					.getXmlid());
			List<SourceLog> srcLogList = ConvertUtils.convertToSrouceLog(
					runInfo.getSeqno(), runInfo.getDateArgs(), srcObjList);
			if(dbDao.saveSourceLog(srcLogList)){
				MemCache.SRC_LOG_MAP.put(runInfo.getSeqno(), srcLogList);
				MemCache.TASK_MAP.put(runInfo.getSeqno(), runInfo);
			//	MemCache.DEPEND_TASK_MAP.put(runInfo.getSeqno(), runInfo); //不需要放进依赖检测队列，状态变了会自动放入队列
				return true;
			}else{
				return false;
			}
		}
		return false;
	}
	//删除meta_log记录
	public void deleteRunResult(TaskLog runInfo) {
		try {
			String sql = " delete from proc_schedule_meta_log where proc_name='" + runInfo.getXmlid() + "' and date_args='" + runInfo.getDateArgs()+ "'";
			dbDao.delete(sql);
		} catch (Exception ex) {
			LOG.error("", ex);
		}
	}

	/**
	 * 推送消息至分发服务器
	 * 
	 * @param metaList
	 */
	public void pushMessage(List<MetaLog> metaList) {
		if (metaList.isEmpty()) {
			return;
		}
		Message msgContent = new Message();
		msgContent.setClassMethod("updateDBStatus");
		msgContent.setClassUrl("com.asiainfo.proc.DataTransTask");
		msgContent.setMsgType("TRANS");
		msgContent.setSourceQueue("transServer");
		Map<String, String> map;
		for (MetaLog log : metaList) {
			map = new HashMap<String, String>();
			map.put("XMLID", log.getTarget());
			map.put("op_time", log.getDataTime());
			msgContent.addBody(map);
		}
		if (dpContext.getDpSender().pushMessage("dacp-trans-exchange",
				msgContent)) {
			LOG.info("push {}  message to trans-server success[{}]");
		} else {
			LOG.info("push {}  message to trans-server fail", metaList.size());
		}
	}
	
	public void insertDistributeTable(List<MetaLog> metaList) {
		if (metaList.isEmpty()) {
			return;
		}
		for (MetaLog log : metaList) {
			dbDao.insertDistributeTable(log.getTarget(),log.getDataTime());
		}
	}
	
	public void resetDataTime(Map<String, String> dataMap) {
		String freq = null;
		String[] a = null;
		String tmp = null;
		String target = dataMap.get("target");
		String dataTime = dataMap.get("dataTime");
		String interNo = dataMap.get("interNo");
		if (StringUtils.isNotEmpty(target) && StringUtils.isNotEmpty(dataTime)
				&& StringUtils.isEmpty(interNo)) {
			freq = dbDao.queryFreq(target);
			if (freq != null) {
				a = freq.split("-");
				tmp = dataTime.substring(6, 8);
				if (a.length >= 1 && DataFreq.M.name().equals(a[0])
						&& tmp.equals("01")) {
					dataTime = dataTime.substring(0, 6);
					dataMap.put("dataTime", dataTime);
				}
			}

		}
	}

	/**
	 * 删除任务
	 */
	public boolean deleteTask(TaskLog runInfo) {
		try {
			final String deleteStr = "delete  from ? where seqno='"
					+ runInfo.getSeqno() + "'";
			String _deleteStr = deleteStr
					.replaceAll("[?]", "proc_schedule_log");
			dbDao.delete(_deleteStr);
			_deleteStr = deleteStr
					.replaceAll("[?]", "proc_schedule_source_log");
			dbDao.delete(_deleteStr);
			_deleteStr = deleteStr
					.replaceAll("[?]", "proc_schedule_script_log");
			dbDao.delete(_deleteStr);
			_deleteStr = deleteStr.replaceAll("[?]", "proc_schedule_meta_log");
			// dbDao.delete(_deleteStr);
			// _deleteStr = deleteStr.replaceAll("[?]",
			// "proc_schedule_target_log");
			dbDao.delete(_deleteStr);
			MemCache.clearRunInfoCache(runInfo.getSeqno());
			return true;
		} catch (Exception e) {
			LOG.error("", e);
			return false;
		}
	}

	/***
	 * 上线下线检测
	 */
	public void checkStateService() {
		try {
			List<TaskConfig> taskList = dbDao
					.queryNeedUpdateTaskConfigList(" and ( STATE='INVALID' OR STATE='VALID')");
			String effTime = "";
			String expTime = "";
			Map<String, Object> handlerMap = new HashMap<String, Object>();
			String stateDate = TimeUtils.dateToString(new Date());
			String nowStr = stateDate.substring(0, 10);
			for (TaskConfig _new : taskList) {
				effTime = _new.getEffTime();
				expTime = _new.getExpTime();
				handlerMap.clear();
				handlerMap.put("xmlid", _new.getXmlid());
				switch (ProcStatus.valueOf(_new.getState())) {
				case VALID:
					if (!(nowStr.compareTo(effTime) >= 0 && nowStr
							.compareTo(expTime) <= 0)) {// 处于失效期
						handlerMap.put("STATE", ProcStatus.INVALID.name());
						handlerMap.put("STATE_DATE", stateDate);
						dpContext.getDpQuartz().deleteCronSchdJob(_new.getXmlid(),_new.getXmlid());
						MemCache.clearProcCache(_new.getXmlid());
						dbDao.update("PROC", "xmlid", handlerMap);
					}
					break;
				case INVALID:
					if (nowStr.compareTo(effTime) >= 0
							&& nowStr.compareTo(expTime) <= 0) {// 处于有效期
						reInitProcConfig(_new);
						handlerMap.put("STATE", ProcStatus.VALID.name());
						handlerMap.put("STATE_DATE", stateDate);
						if (_new.getTriggerType() == Type.DRIVE_TYPE.TIME_TRIGGER
								.ordinal()) {
							if (dpContext.getDpQuartz().createCronSchdJob(_new.getXmlid(),_new.getXmlid(),_new.getCronExp(),QuartzJob.class,_new.getXmlid())) {
								LOG.info("update config of proc[{}] success!",
										_new.getProcName());
							} else {
								LOG.info("update config of proc[{}] fail!",
										_new.getProcName());
							}
						}
						dbDao.update("PROC", "xmlid", handlerMap);
						if (_new.getRunFreq().equals(RunFreq.day.name())
								|| _new.getRunFreq().equals(RunFreq.month.name())) {
							String dateArgs = TimeUtils.getDateArgs(
									_new.getRunFreq(), new Date(), "" + 1);
							createPlanTask(_new,dateArgs);
						}
					} else {
						dpContext.getDpQuartz().deleteCronSchdJob(_new.getXmlid(),_new.getXmlid());
						MemCache.clearProcCache(_new.getXmlid());
					}
				default:
					break;
				}
			}
		} catch (Exception ex) {
			LOG.info("update config of proc fail!");
			LOG.error("", ex);
		}
	}

	/***
	 * 刷新缓存
	 * 上线下线控制
	 */
	public void refreshTaskConfig() {
		try {
			List<TaskConfig> taskList = dbDao
					.queryNeedUpdateTaskConfigList(" and STATE='PUBLISHED' ");
			String effTime = "";
			String expTime = "";
			TaskConfig _old = null;
			Map<String, Object> handlerMap = new HashMap<String, Object>();
			String nowStr = TimeUtils.dateToString(new Date()).substring(0, 10);
			String stateDate = TimeUtils.dateToString(new Date());
			for (TaskConfig _new : taskList) {
				try {
				effTime = _new.getEffTime();
				expTime = _new.getExpTime();
				_old = MemCache.PROC_MAP.get(_new.getXmlid());
				handlerMap.clear();
				if(StringUtils.isEmpty(_new.getProcType())){
					LOG.info("{} procType is null ",_new.getProcName());
				}
				if(!StringUtils.equals(_new.getProcType(),"SCOPE"))
				handlerMap.put("XMLID", _new.getXmlid());
				else
				handlerMap.put("KPI_SCOPE_CODE", _new.getXmlid());	
				if (nowStr.compareTo(effTime) >= 0
						&& nowStr.compareTo(expTime) <= 0) {// 处于有效期
					reInitProcConfig(_new);
					//创建计划任务
					if (_new.getRunFreq().equals(RunFreq.day.name())
							|| _new.getRunFreq().equals(RunFreq.month.name())) {
						String dateArgs = TimeUtils.getDateArgs(
								_new.getRunFreq(), new Date(), "" + 1);
						createPlanTask(_new,dateArgs);
					}
					if (_new.getTriggerType() == Type.DRIVE_TYPE.TIME_TRIGGER
							.ordinal()) {
						if (_old == null) {
							if (dpContext.getDpQuartz().createCronSchdJob(_new.getXmlid(),_new.getXmlid(),_new.getCronExp(),QuartzJob.class,_new.getXmlid())) {
								LOG.info("update config of proc[{}] success!",
										_new.getProcName());
							} else {
								LOG.info("update config of proc[{}] fail!",
										_new.getProcName());
							}
						} else {
							if (dpContext.getDpQuartz().modifyCronSchdJob(_new.getXmlid(),_new.getXmlid(),_new.getCronExp(),QuartzJob.class,_new.getXmlid())) {
								LOG.info("update config of proc[{}] success!",
										_new.getProcName());
							} else {
								LOG.info("update config of proc[{}] fail!",
										_new.getProcName());
							}
						}
					} else {
						dpContext.getDpQuartz().deleteCronSchdJob(_new.getXmlid(),_new.getXmlid());
						LOG.info("update config of proc[{}] success!",
								_new.getProcName());
					}
					handlerMap.put("STATE", ProcStatus.VALID.name());
					if(!StringUtils.equals(_new.getProcType(),"SCOPE"))
					handlerMap.put("STATE_DATE", stateDate);
				} else {
					if(dpContext.getDpQuartz().deleteCronSchdJob(_new.getXmlid(),_new.getXmlid())){
						LOG.info("offline proc[{}] success!",_new.getProcName());
					}
					/** 清除缓存 */
					MemCache.clearProcCache(_new.getXmlid());
					handlerMap.put("STATE", ProcStatus.INVALID.name());
					if(!StringUtils.equals("SCOPE", _new.getProcType()))
					handlerMap.put("STATE_DATE", stateDate);
				}
				if(!StringUtils.equals("SCOPE", _new.getProcType()))
				dbDao.update("PROC", "XMLID", handlerMap);
				else
				dbDao.update("kpi_scope_def", "KPI_SCOPE_CODE", handlerMap);
				} catch (Exception ex) {
					LOG.info("update config of proc fail!");
					LOG.error("", ex);
				}
			}
		}catch (Exception ex) {
			LOG.error("", ex);
		}
	}

	public void createTaskPlanService(String exp) {
		String name = QuartzPlanJob.class.getName();
		if(dpContext.getDpQuartz().deleteCronSchdJob(name, name)){
			dpContext.getDpQuartz().createCronSchdJob(name,name, exp, QuartzPlanJob.class, null);
		}
	}

	public void createCheckStateService(String exp) {
		String name = StateCheckJob.class.getName();
		if(dpContext.getDpQuartz().deleteCronSchdJob(name, name)){
			dpContext.getDpQuartz().createCronSchdJob(name,name, exp, StateCheckJob.class, null);
		}
	}
	
	public void createTaskAlarmService() {
		List<TaskAlarmInfo> taskAlarmInfoList = dbDao.queryFinishLateAlarmTaskInfoList();
		if(taskAlarmInfoList.size()>0) createTaskAlarmJobs(taskAlarmInfoList);

		//开启一个线程扫描监控告警信息变更
		new Thread(new Runnable() {	
			@Override
			public void run() {
				while(true){
					try {
						List<TaskAlarmInfo> taskAlarmInfoList = dbDao.queryFlagAlarmTaskInfoList();
						if(taskAlarmInfoList.size()>0) {
							createTaskAlarmJobs(taskAlarmInfoList);
						}
						//扫描间隔5秒钟
						TimeUtils.sleep(5);
					} catch (Exception e) {
						e.getStackTrace();
					}
				}
			}
		}).start();
	}
	/**
	 * 创建告警定时服务
	 * @param taskAlarmInfoList 任务列表
	 */
	public synchronized void createTaskAlarmJobs(List<TaskAlarmInfo> taskAlarmInfoList){
		String name = null;
		String cron = null;
		for (TaskAlarmInfo item : taskAlarmInfoList) {
			name = item.getXmlid();
			cron = item.getDueTimeCron();
			//是否生效
			if(item.getIsValid().equals("0")){
				dpContext.getAlarmQuartz().createCronSchdJob(name,name,cron,TaskAlarmJob.class,item);
			}else{
				dpContext.getAlarmQuartz().deleteCronSchdJob(name,name);
			}
			//修改处理标记flag
			dbDao.update("update proc_schedule_alarm_info set flag = 1 where xmlid='"+item.getXmlid()+"' and flag <>1");
		}
	}
	
	
	

	/***
	 * 时间触发
	 */
	public void timeTrigger() {
		String runFreq = null;
		String name = null;
		String cron = null;
		for (TaskConfig config : MemCache.PROC_MAP.values()) {
			if (config.getTriggerType().intValue() == Type.DRIVE_TYPE.TIME_TRIGGER
					.ordinal()) {
				runFreq = config.getRunFreq();
				if (StringUtils.equals(runFreq, RunFreq.manual.name())) {
					continue;
				}
				name = config.getXmlid();
				cron = config.getCronExp();
				dpContext.getDpQuartz().createCronSchdJob(name,name,cron,QuartzJob.class,name);
			}
		}
	}

	/**
	 * 创建每天夜间执行的sql任务：每晚0点左右根据proc_schedule_info表中的内容
	 * 更新proc_schedule_log表中的dura_max字段的值
	 * 
	 */
	public void createSqlTask(String cronExp) {
		int days = 30; // 最近天数
		String[] sqlTextArr = new String[1];
		switch (MemCache.DBTYPE) {
		case MYSQL:
			sqlTextArr[0] = "UPDATE proc_schedule_info" // 求任务在days天数内的平均执行时间
					+ " INNER JOIN("
					+ " SELECT xmlid,"
					+ " TRUNCATE(SUM(TIME_TO_SEC(TIMEDIFF(exec_time, start_time)))/COUNT(xmlid)/60,0) evra_time"
					+ " FROM proc_schedule_log"
					+ " WHERE LENGTH(exec_time) > 0 AND LENGTH(start_time) > 0 AND DATEDIFF(CURDATE(), start_time) < "
					+ days
					+ " and valid_flag='0'"
					+ " GROUP BY xmlid HAVING evra_time >=0) T"
					+ " ON proc_schedule_info.xmlid = T.xmlid"
					+ " SET proc_schedule_info.dura_max = IF(T.evra_time = 0, 1, T.evra_time);";
			break;
		case ORACLE:
			sqlTextArr[0] = "update proc_schedule_info aa set aa.dura_max ="
					+ "("
					+ " SELECT round(sum((to_date(l.exec_time, 'yyyy-mm-dd hh24:mi') -"
					+ " to_date(l.start_time, 'yyyy-mm-dd hh24:mi')) * 24 * 60) /"
					+ " count(1),0) a"
					+ " FROM proc_schedule_log l"
					+ " where LENGTH(exec_time) > 0"
					+ " AND LENGTH(start_time) > 0"
					+ " AND to_date(l.exec_time, 'yyyy-mm-dd hh24:mi') > to_date(l.start_time, 'yyyy-mm-dd hh24:mi')"
					+ " and to_date(substr(l.start_time, 1, 10), 'yyyy-mm-dd') >="
					+ " to_date(sysdate - " + days + ", 'yyyy-mm-dd')"
					+ " and valid_flag='0'"
					+ " and l.proc_name = aa.proc_name)";
			sqlTextArr[0] = "";
			break;
		default:
			sqlTextArr[0] = "";

		}
		if (!"".equals(sqlTextArr[0])) {
			String name = QuartzSqlJob.class.getName();
			if (dpContext.getDpQuartz().deleteCronSchdJob(name, name)) {
				dpContext.getDpQuartz().createCronSchdJob(name, name, cronExp,
						QuartzSqlJob.class, sqlTextArr);
			}
		}
	}

	/** 同步agent并发信息 */
	public void refreshAgentIps() {
//		MemCache.AGENT_IPS_MAP.clear();
		List<AgentIps> ipsList = dbDao.queryAgentIps();
		for (AgentIps ips : ipsList) {
			MemCache.AGENT_IPS_MAP.put(ips.getAgentCode(), ips);
		}
	}

	/**
	 * 检测agent心跳信息
	 */
	public void checkAgentService() {
		Executors.newSingleThreadExecutor().execute(heartbeatService);
	}
	/***
	 * 发送信息至agent
	 * 
	 * @param runInfo
	 * @return
	 */
	public boolean sendProcToAgent(TaskLog runInfo) {
		String procName = runInfo.getProcName();
		String queueName = runInfo.getAgentCode();
		if(StringUtils.isNotEmpty(dpContext.getRequest_queue_name())){
			queueName = queueName.concat("_"+dpContext.getRequest_queue_name());
		}
		DpMessage msgObj = new DpMessage();
		msgObj.setMsgId(runInfo.getSeqno());
		if (StringUtils.isEmpty(runInfo.getProctype())) {//如果没有配置程序类型，返回不执行
			LOG.info("task[{}] send mq fail.because: the proctype is null",runInfo.getSeqno());
			return false;
		}else{
			msgObj.setMsgType(MsgType.taskTypeFunc.name());//所有类型都当做执行脚本执行
		}
		ClassInfo clz = dbDao.queryClassInfo(runInfo.getProctype());
		if (clz == null) {
			LOG.info("task[{}] send mq fail.because: the exec class is null",
					runInfo.getSeqno());
			return false;
		}
		msgObj.setClassUrl(clz.getExeClass());
		msgObj.setClassMethod(clz.getExeFunc());
		Map<String, String> map = cmdLineBuilder.buildCmdLine(runInfo);
		msgObj.setSourceQueue(dpContext.getResponse_queue_name());
		msgObj.addBody(map);
		if (dpContext.getDpSender().sendMessage(queueName, msgObj)) {
			LOG.info("task[{}] send mq[{}] success ,message:{}",
					runInfo.getTaskId(), queueName, map.get(MapKeys.CMD_LINE));
			return true;
		} else {
			LOG.info("task[{}] send mq[{}] fail,message:{}", procName,
					runInfo.getTaskId(), queueName, map.get(MapKeys.CMD_LINE));
			return false;
		}

	}
	/**
	 * 设置任务失败
	 */
	public void setTaskError(TaskLog task,String error){
		int oldTaskState = task.getTaskState();
		int oldTriggerFlag = task.getTriggerFlag();
		int oldQueueFlag = task.getQueueFlag();
		task.setEndTime(TimeUtils.dateToString(new Date()));
		task.setQueueFlag(1);
		task.setTriggerFlag(1);
		if (updateState(task, RunStatus.PROC_RUN_FAIL)) {
			LOG.error(error);
			insertAppLog(task, error);
		} else {//回滚
			task.setTaskState(oldTaskState);
			task.setQueueFlag(oldQueueFlag);
			task.setTriggerFlag(oldTriggerFlag);
			task.setEndTime(null);
		}
	}
	/***
	 * 变更执行模式/agent ips 检测状态
	 */
	public void updateCheckStatus(TaskLog task,int status){
		Integer errorCode = task.getErrcode();
		if(errorCode!=null&&errorCode == status){
			return ;
		}
		Map<String,Object> updateMap = new HashMap<String, Object>();
		updateMap.put("SEQNO",task.getSeqno());
		updateMap.put("ERRCODE",status);
		if(dbDao.update("proc_schedule_log", "seqno", updateMap)){
			task.setErrcode(status);
		}
	}
	public synchronized void updateAgentStatus(Map<String,String> resMap){
		Map<String, Object> valuePair = new HashMap<String, Object>();
		if (resMap == null) {
			return;
		}
		String agentName = resMap.get(MapKeys.AGENT_CODE);
		LOG.info("recive agent【{}】, heart beat! ",agentName);
		if (null == MemCache.AGENT_IPS_MAP.get(agentName)) {
			//LOG.info("数据错误：无法获取agent[{}]信息", agentName);
			return;
		}
		String chgTime = TimeUtils.dateToString(new Date());
		valuePair.put("agent_name", agentName);
		valuePair.put("task_type", "TASK");
		valuePair.put("STATUS_CHGTIME", chgTime);
		valuePair.put("NODE_STATUS", 1);
		dbDao.update("aietl_agentnode", "agent_name,task_type",valuePair);
	}
	/***
	 * 生成计划任务
	 */
	public void createPlanTask(TaskConfig config, String dateArgs) {
		try {
			int i = dbDao.checkExist("proc_schedule_log",new String[]{"xmlid","date_args","valid_flag"},new Object[]{config.getXmlid(),dateArgs,0});
			if(i==0){
				TaskLog runInfo = new TaskLog();
				Date now = new Date();
				Calendar ca = Calendar.getInstance();
				ca.setTime(now);
				//创建任务默认当前时间
//				ca.set(Calendar.HOUR_OF_DAY, 0);
//				ca.set(Calendar.MINUTE, 0);
				String initTime = TimeUtils.dateToString2(ca.getTime());
				String seqno = UUIDUtils.getUUID();
				/**** 数据日期 */
				runInfo.setPriLevel(config.getPriLevel());
				runInfo.setSeqno(seqno);
				runInfo.setXmlid(config.getXmlid());
				runInfo.setProcName(config.getProcName());
				runInfo.setDateArgs(dateArgs);
				runInfo.setProcDate(TimeUtils.dateToString2Minute(ca.getTime()));
				runInfo.setAgentCode(config.getAgentCode());
				runInfo.setTaskState(RunStatus.PLAN_TASK);
				runInfo.setStartTime(initTime);
				// 入队
				runInfo.setQueueFlag(1);
				runInfo.setTriggerFlag(1);
				runInfo.setFlowcode(config.getFlowcode());
				runInfo.setValidFlag(0);
				dpContext.getTaskService().insertTaskLog(config, runInfo);
				// 查询source
				List<SourceObj> srcObjList = MemCache.SOURCE_MAP.get(config
						.getXmlid());
				// 初始化不为null
				srcObjList = srcObjList == null ? new ArrayList<SourceObj>()
						: srcObjList;
						List<SourceLog> srcLogList = ConvertUtils.convertToSrouceLog(
							seqno, runInfo.getDateArgs(), srcObjList);
					if (dbDao.saveSourceLog(srcLogList)) {
						LOG.info("task[{}] create source log  success",runInfo.getTaskId());
					}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * 为任务递归后续任务创建计划任务
	 * @param config
	 * @param dateArgs
	 */
	public void createAfterPlanTask(String xmlid,String cycle, String dateArgs) {
		// TODO Auto-generated method stub
		//获取transdatamap_design中该节点下所有下一级节点
		List<TargetObj> nextAllItemList = dbDao.queryNextAllList(xmlid);
		for (TargetObj targetObj : nextAllItemList) {
			String targetCycle = targetObj.getTargetfreq().split("-")[0];
			String sourceCycle = getSingleCycle(cycle);
			//检验是否同周期
			if(sourceCycle.equals(targetCycle)){
				if(targetObj.getTargettype().equals(ObjType.DATA.name()) ){
					//如果是表，直接跳过，递归查询后续任务
					createAfterPlanTask(targetObj.getTarget(),cycle,dateArgs);
				}else{
					TaskConfig nextTask = MemCache.PROC_MAP.get(targetObj.getTarget());
					if(nextTask!=null){
						createPlanTask(nextTask,dateArgs);
						//继续递归后续任务
						createAfterPlanTask(nextTask.getXmlid(),cycle,dateArgs);
					}
				}
			}
		}
	}
	
	private String getSingleCycle(String cycle){
		if(cycle==null)return null;
		switch (cycle.toLowerCase()) {
			case "year":
				return "Y";
			case "month":
				return "M";
			case "day":
				return "D";
			case "hour":
				return "H";
			case "minute":
				return "MI";
			default:
				return null;
		}
	}
	

	/***
	 * 获取指定任务的下线时间
	 */
	public String getExptime(String procName){
		return dbDao.getExptimeByProcName(procName);
	} 
	/**
	 * 杀掉后台任务进程
	 * @param run
	 */
	public void killProcess(TaskLog task) {
		try {
			DpMessage message = new DpMessage();
			Map<String, String> map = new HashMap<String, String>();
			map.put("SEQNO", task.getSeqno());
			map.put("AGENT_CODE", task.getAgentCode());
			message.setMsgType("KILL_PROC");
			message.setMsgId(task.getSeqno());
			message.setClassUrl("default-url");
			message.setClassMethod("default-method");
			message.setSourceQueue("taskServer");
			message.addBody(map);
			Object delRes = dpSender.sendAndRecieve(task.getAgentCode() + "_REQUEST_QUEUE",
					message, 1000 * 100);
			if (delRes != null&&delRes.equals("true")) {
				LOG.info("","kill process success!");
			}else{
				LOG.info("","kill process failed!");
			}
			
		} catch (Exception ex) {
			LOG.error("",ex);
		}
	}
	
	//创建任务
	public synchronized void createNextTask(String xmlId) throws Exception{
		//查询当前procName下次执行时间
		LOG.info("正常补{}任务",xmlId);
			List<Map<String, Object>>  taskMapList = dbDao.queryForMapList("select next_time from schedule_task_supplement where xmlid='"+xmlId+"'");
			if(taskMapList!=null&&taskMapList.size()>0){
				Map<String,Object>  taskMap=taskMapList.get(0);
				long nextTime =(Long) taskMap.get("next_time");
				long time = System.currentTimeMillis();
				//如果当前时间大于下次执行时间则创建任务
				if(time>nextTime){
					TaskConfig  config = dbDao.queryTaskConfig(xmlId);
					//如果 config信息不为null 并且当前任务处于已发布状态
					if(config!=null&&StringUtils.equals(config.getState(),ProcStatus.VALID.name())){
						createTaskRunInfo(config,null,null,new Date(nextTime));
						//修改当前任务的下次执行时间
						updateTaskNextTime(config,nextTime,0);
						//递归创建当前任务
						createNextTask(xmlId);
					}
				}
			}
	}
	//修改任务下次执行时间
	public synchronized void updateTaskNextTime(TaskConfig config, long nextTime,int type) throws Exception {
		
		if(config!=null){
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			//判断当前任务是否是时间驱动
			if(config.getTriggerType()!=Type.DRIVE_TYPE.TIME_TRIGGER
					.ordinal()){
				return ;
			}
			//根据cron表达式获取下次执行时间
			 long taskNextTime= getTimeByCron(config,nextTime);
			 //LOG.info("当前任务下次执行时间为：{}",sdf.format(new Date(taskNextTime)));
			 if(taskNextTime==0){
				 return;
			 }
			 //检查当前任务是否已经存在  不存在添加当前数据 ， 如果存在 修改当前任务的下次执行时间
			int checkValue = dpContext.getDbDao().checkExist("schedule_task_supplement",new String[]{"xmlid"},new String[]{config.getXmlid()});
			if(checkValue!=1){
				if(StringUtils.equalsIgnoreCase(config.getRunFreq(),RunFreq.day.name())
						||StringUtils.equalsIgnoreCase(config.getRunFreq(),RunFreq.hour.name())
						||StringUtils.equalsIgnoreCase(config.getRunFreq(),RunFreq.minute.name())){
					Map<String, Object> map= new HashMap<String, Object>();
					map.put("xmlid", config.getXmlid());
					map.put("proc_name", config.getProcName());
					map.put("next_time", taskNextTime);
					map.put("run_freq", config.getRunFreq());
					dpContext.getDbDao().insert("schedule_task_supplement",map);
				}
			}else {
				flag=supplementThread.getIsRun();
				if(flag&&System.currentTimeMillis()>=nextTime){
					dpContext.getDbDao().update("update schedule_task_supplement set next_time="+taskNextTime+" where xmlid='"+config.getXmlid()+"'");
				}else if (!flag&&type ==1 ){
					dpContext.getDbDao().update("update schedule_task_supplement set next_time="+nextTime+" where xmlid='"+config.getXmlid()+"'");
				}
			}
		}
	}
	//根据时间与cron表达式获取任务下次执行时间
	private synchronized long getTimeByCron(TaskConfig config,long nextTime) throws ParseException {
		CronTriggerImpl cronTriggerImpl = new CronTriggerImpl();
		if(CronExpression.isValidExpression(config.getCronExp())){
		   cronTriggerImpl.setCronExpression(config.getCronExp());//这里写要准备猜测的cron表达式  
	        Calendar calendar = Calendar.getInstance();  
	        calendar.setTime(new Date(nextTime));
	        Date now = calendar.getTime();  
	        calendar.add(Calendar.MONTH, 1);
	        List<Date> dates = TriggerUtils.computeFireTimesBetween(cronTriggerImpl, null, now, calendar.getTime());
	        if(StringUtils.equalsIgnoreCase(RunFreq.day.name(), config.getRunFreq())){
	        	 return dates.get(1).getTime();
	        }else{
	        	return dates.get(1).getTime();
	        }
		}
     return 0;
	}
	//根据时间与周期 获取 dateArgs
	private String getDateArgs(String runFreq,long nextTime) {
		SimpleDateFormat sdf =  null ;
		if (StringUtils.equals(RunFreq.day.name(),runFreq)){
			sdf = new SimpleDateFormat("yyyy-MM-dd");
		}else if (StringUtils.equals(RunFreq.hour.name(),runFreq)){
			sdf = new SimpleDateFormat("yyyy-MM-dd HH");
		}else if (StringUtils.equals(RunFreq.minute.name(),runFreq)){
			sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
		}else if (StringUtils.equals(RunFreq.month.name(),runFreq)){
			sdf = new SimpleDateFormat("yyyy-MM");
		}else if (StringUtils.equals(RunFreq.year.name(),runFreq)){
			sdf = new SimpleDateFormat("yyyy");
		}
		return sdf.format(new Date(nextTime));
	}
	//杀任务进程接口
	public boolean killProcee(TaskLog runInfo){
		String seqno =runInfo.getSeqno();
		String agentCode = runInfo.getAgentCode();
		DpMessage message = new DpMessage();
		Map<String, String> map = new HashMap<String, String>();
		map.put("SEQNO", seqno);
		map.put("AGENT_CODE", agentCode);
		message.setMsgType("KILL_PROC");
		message.setMsgId(seqno);
		message.setClassUrl("default-url");
		message.setClassMethod("default-method");
		message.setSourceQueue("taskServer");
		message.addBody(map);
		Object delRes = dpSender.sendAndRecieve(agentCode + "_REQUEST_QUEUE",
				message, 1000 * 100);
		if (delRes != null&&delRes.equals("true")) {
			LOG.info("the task ["+runInfo.getProcName()+","+runInfo.getDateArgs()+"] was killed,because the last task was redid!");
			return true;
		} else {
			return false;
		}
	}
	
	public boolean checkExistProc(String xmlid,String dateArgs,int state){
		try {
			int result = dbDao.checkExist("proc_schedule_log",new String[]{"xmlid","date_args","task_state","valid_flag"},new Object[]{xmlid,dateArgs,state,"0"});
			if(result==1){
				return true;
			}else{
				return false;
			}
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public void SendSmsService(Map<String, Object> taskLogMap) throws Exception{
		SimpleDateFormat  sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		List<Map<String,Object>> memberList = dbDao.queryAlarmMemeberPhoneNumList(taskLogMap.get("proc_xmlid").toString());
		for (Map<String, Object> map : memberList) {
			if(map.get("phone")!=null && StringUtils.isNotEmpty(map.get("phone").toString())){
				String phoneNum = map.get("phone").toString();
				//发送短信
				if(smsSender.sendSms(phoneNum,taskLogMap)){
					//记录告警短信发送记录
					Map<String, Object> sendLogMap = new HashMap<String, Object>();
					sendLogMap.put("xmlid", UUIDUtils.getUUID());
					sendLogMap.put("proc_xmlid", taskLogMap.get("proc_xmlid"));
					sendLogMap.put("proc_name", taskLogMap.get("proc_name"));
					sendLogMap.put("proc_date_args", taskLogMap.get("proc_date_args"));
					sendLogMap.put("send_phone", phoneNum);
					sendLogMap.put("send_time", sdf.format(new Date()));
					sendLogMap.put("send_content", taskLogMap.get("alarm_content"));
					dbDao.insert("proc_schedule_alarm_send_log",sendLogMap);
				}
			}else{
				LOG.error("任务[%s,%s]配置地告警人员的电话号码异常",taskLogMap.get("proc_xmlid"),taskLogMap.get("proc_name"));
			}
		}
	}
}
