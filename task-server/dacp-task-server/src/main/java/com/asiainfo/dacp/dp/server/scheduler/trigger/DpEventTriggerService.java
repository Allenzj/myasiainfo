package com.asiainfo.dacp.dp.server.scheduler.trigger;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.asiainfo.dacp.dp.common.RunStatus;
import com.asiainfo.dacp.dp.common.RunStatus.ONOFF;
import com.asiainfo.dacp.dp.server.scheduler.bean.MetaLog;
import com.asiainfo.dacp.dp.server.scheduler.bean.TargetObj;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskConfig;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;
import com.asiainfo.dacp.dp.server.scheduler.service.ShipbuilderService;
import com.asiainfo.dacp.dp.server.scheduler.service.TaskService;
import com.asiainfo.dacp.dp.server.scheduler.type.DataFreq;
import com.asiainfo.dacp.dp.server.scheduler.type.RunFreq;
import com.asiainfo.dacp.dp.server.scheduler.utils.ConvertUtils;
import com.asiainfo.dacp.dp.server.scheduler.utils.TaskUtils;
import com.asiainfo.dacp.dp.server.scheduler.utils.TimeUtils;

@Service
public class DpEventTriggerService implements DpEventTrigger {
	@Autowired
	private DatabaseDao dbDao;
	@Autowired
	private TaskService taskService;
	@Value("${scanEventType}")
	private String scanEventType;
	@Value("${isDataTransTask}")
	private String isDataTransTask ;
	@Autowired
	private ShipbuilderService kinship;
	private static Logger LOG = LoggerFactory.getLogger(DpEventTriggerService.class);

	public void scanEvent(List<MetaLog> metaLogList) {
		if(metaLogList==null||metaLogList.isEmpty())return ;
		int cnt = 1000;
		List<MetaLog> insertList = new ArrayList<MetaLog>();
		String finalSql = "SELECT 1 FROM proc_schedule_meta_log WHERE 1=1 ";
		String realSql = "";
		String target = "";
		String data_time = "";
		try {
			for (MetaLog metaLog : metaLogList) {
				target = metaLog.getTarget();
				data_time = metaLog.getDataTime();
				realSql = finalSql + " and target='" + target + "' ";
				if (data_time.length() == 10) {// 小时
					cnt = 24;
					data_time = data_time.substring(0, 8) + "__";
					realSql += " AND data_time LIKE '" + data_time+"'"
							       + " HAVING COUNT(target)=" + cnt;
					if (dbDao.checkExist(realSql) == 1) {
						MetaLog mLog = metaLog.clone();
						if (mLog != null) {
							mLog.setDataTime(data_time.replaceAll("_", ""));
							mLog.setTriggerFlag(0);
							insertList.add(mLog);
							LOG.info("task[{},{}]扫描到事件源[{},{}]",mLog.getSeqno(),mLog.getProcName(),mLog.getTarget(),data_time.replaceAll("_", ""));
						}
					}
				} else if (data_time.length() == 8) {// 月末判断
					if(TimeUtils.isMonthLast(data_time)){
						MetaLog mLog = metaLog.clone();
						if (mLog != null) {
							mLog.setDataTime(data_time.substring(0, 6));
							mLog.setTriggerFlag(0);
							insertList.add(mLog);
							LOG.info("task[{},{}]扫描到事件源[{},{}]",mLog.getSeqno(),mLog.getProcName(),mLog.getTarget(),data_time.replaceAll("_", ""));
						}
					}
				} else {
					continue;
				}
			}
			if (!insertList.isEmpty()) {
				dbDao.saveTargertLog(insertList, "proc_schedule_target_log");
			}
		} catch (Exception e) {
			// ignore//e.printStackTrace();
		}
	}
	//处理外部触发
	public void triggerByData() {
		try {
			List<MetaLog> metaList = dbDao.queryTargetLogList();
			List<TaskLog> nextTasks = null;
			List<TaskConfig> nextProcs = null;
			String source = null, optTime = null;
			String[] targetFileds = new String[] { "target", "data_time" };
			Object[] values = null;
			int ckRes = -1;
			int state = -7;
			String pks = "target,data_time,generate_time";
			Map<String, Object> map = new HashMap<String, Object>();
			List<MetaLog> triggeredList = new ArrayList<MetaLog>();
			TaskLog newTask = null;
			boolean isTriggered = true;
			for (MetaLog interData : metaList) {
				try{
					isTriggered = true;
					map.clear();
					triggeredList.clear();
					state = -7;
					source = interData.getTarget();
					optTime = interData.getDataTime();
					values = new Object[] { source, optTime };
					ckRes = dbDao.checkExist("proc_schedule_meta_log",
							targetFileds, values);
					if (ckRes == 1) {// 如果是从新加载的接口
						nextTasks = kinship.getAfterTask(source, optTime);
						LOG.info("data[{}] have {} task",interData.getDataId(),nextTasks.size());
						for (TaskLog runInfo : nextTasks) {
							state = runInfo.getTaskState();
							if (state ==5||state ==4) {
								isTriggered = false;
								LOG.info("the last inter["+interData.getDataId()+"] was redid ");
								taskService.killProcee(runInfo);//终止正在运行的任务
							}
						}
						if (!isTriggered) {
							continue;
						}
						for (TaskLog runInfo : nextTasks) {
							
							switch (runInfo.getTaskState()) {
							case RunStatus.PROC_RUN_SUCCESS:
							case RunStatus.PROC_RUN_FAIL://有执行结果的记录保留日志，失效任务
								taskService.invalidTask(runInfo);	//失效任务
								//创建新任务并重做该任务所有后续任务
								TaskLog taskLog=taskService.createTaskRunInfo(MemCache.PROC_MAP.get(runInfo.getXmlid()),TimeUtils.dateArgsToOptTime(runInfo.getDateArgs()), runInfo,null);
								taskLog.setTaskState(-7);
								taskService.updateState(taskLog, 0);
						}
						}
					} else {// 接口第一次加载
						nextProcs = kinship.getAfterProc(source, optTime);
						LOG.info("data[{}] have {} process", interData.getDataId(),nextProcs.size());
						for (TaskConfig config : nextProcs) {
							if (TaskUtils.isNotCreated(config.getXmlid(),
								TimeUtils.getDateArgs(config.getRunFreq(),optTime))) {
								newTask = taskService.createTaskRunInfo(config,
										optTime, null,null);
								if (newTask != null) {
									LOG.info("data[{}] triggered task:[{}]",interData.getDataId(), newTask.getTaskId());
								}
							}
						}
					}
					map.put("target", source);
					map.put("data_time", optTime);
					map.put("trigger_flag", 1);
					map.put("generate_time", interData.getGenerateTime());
					dbDao.update("proc_schedule_target_log", pks, map);
					interData.setTriggerFlag(1);
					dbDao.deleteLogHis("proc_schedule_meta_log", source, optTime);
					triggeredList.add(interData);
					dbDao.saveTargertLog(triggeredList, "proc_schedule_meta_log");
				}catch(Exception e){
					LOG.info("data[{}] triggered task fail,please check data config",interData.getDataId());
				}
			}
			afterTableFinish(metaList);
		} catch (Exception e) {
			LOG.error("", e);
		}
	}
	//处理内部程序或表触发
	@Override
	public void tiggerByProc(TaskLog runInfo) {
		boolean isTriggered = false;
		try {
			// 同一程序在同一周期内，只能被触发一次
			List<TargetObj> targetList = MemCache.TARGET_MAP.get(runInfo
					.getXmlid());
			List<MetaLog> metaList = ConvertUtils.convertToMetaLog(runInfo,
					targetList);
			
			if (!metaList.isEmpty()) {
				// 删除目标表历史记录
				taskService.deleteRunResult(runInfo);
				// 保存数据
				if (!dbDao.saveTargertLog(metaList, "proc_schedule_meta_log")) {
					LOG.error("task[{}]:保存输出表数据失败!",runInfo.getTaskId());
					return;
				}else{
					//afterTableFinish(metaList);
					if(("1").equals(isDataTransTask)){
						taskService.pushMessage(metaList);
					}
				}
			
			}
			if ((int) runInfo.getTriggerFlag() == 0) {
//				//扫描事件
//				scanEvent(metaList);
				if(StringUtils.equals(ONOFF.SCANEVENTTYPE,scanEventType)){
					scanEvent(metaList);
				}
				// 触发
				Set<TaskConfig> set = new HashSet<TaskConfig>();
				List<TaskConfig> nextProcList  = MemCache.INTERIM_PROC_NEXR_PROC_MAP.get(runInfo.getXmlid());
				if(CollectionUtils.isEmpty(nextProcList)){
					 nextProcList = MemCache.PROC_NEXT_PROC_MAP.get(runInfo.getXmlid());
					// 数据触发
					if (targetList != null) {
						List<TaskConfig> confList = null;
						String refKey = null;
						for (TargetObj _obj : targetList) {
							if (StringUtils.equals(_obj.getTargetfreq(),
									DataFreq.N.name())) {
								continue;
							}
							List<TargetObj> sourceKeyList = dbDao.getSourceKey(_obj.getTarget());
							for(TargetObj obj : sourceKeyList){
								String key = obj.getSource() + "/" + _obj.getTargetfreq();
								if(StringUtils.isNotEmpty(obj.getSourceAppoint()) && runInfo.getDateArgs().endsWith(obj.getSourceAppoint())){
									key += "/" + obj.getSourceAppoint();
								}
								confList = MemCache.DATA_NEXT_PROC_MAP.get(key);
								if (CollectionUtils.isNotEmpty(confList)) {
									set.addAll(confList);
								}
							}
							
							//追加处理 月末触发月
							if (_obj.getTargetfreq().indexOf(DataFreq.D.name()) == 0 && TimeUtils.isMonthLast(TimeUtils .convertToDataTime(runInfo.getDateArgs(),_obj.getTargetfreq()))) {
								refKey = _obj.getTarget() + "/" + DataFreq.ML.name() + "-0";
								confList = MemCache.DATA_NEXT_PROC_MAP.get(refKey);
								if (CollectionUtils.isNotEmpty(confList)) {
									set.addAll(confList);
								}
							}
						}
					}
				}
				
				// 程序触发	
				if (CollectionUtils.isNotEmpty(nextProcList)) {
					for (TaskConfig config : nextProcList) {
						if (StringUtils.equals(runInfo.getRunFreq(),config.getRunFreq())) {
							set.add(config);
						}
					}
				}
				// 创建后续任务
				if (CollectionUtils.isNotEmpty(set)) {
					TaskLog newTask = null;
					List<TaskConfig> configList = new ArrayList<TaskConfig>(set);
					LOG.info("task[{}] have {} next tasks:",runInfo.getTaskId(),configList.size());
					String dateArgs = null;
					String optTime = null;
					for (TaskConfig _config : configList) {
						dateArgs = runInfo.getDateArgs();
						if (StringUtils.equals(_config.getRunFreq(),
								RunFreq.month.name())) {
							dateArgs = TimeUtils.formatMonthDateArgs(runInfo
									.getDateArgs());
						}
						if (TaskUtils.isNotCreated(_config.getXmlid(),
								dateArgs)) {
							optTime = TimeUtils.dateArgsToOptTime(dateArgs);
							newTask = taskService.createTaskRunInfo(_config,
									optTime, runInfo,null);
							if (newTask != null) {
								LOG.info("task[{}] create next task:[{}]",runInfo.getTaskId(),newTask.getTaskId());
							}
						}
					}
				}
			}
			isTriggered = true;
		} catch (Exception ex) {
			LOG.error("", ex);
		}
		if (isTriggered) {
			taskService.updateProcTriggerFlag(runInfo.getSeqno());
		}
	}
	private void afterTableFinish(List<MetaLog> metaList){
		//推送消息至分发服务端
		taskService.insertDistributeTable(metaList);
	}
}
