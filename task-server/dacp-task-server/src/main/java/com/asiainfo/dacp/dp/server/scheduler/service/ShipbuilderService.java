package com.asiainfo.dacp.dp.server.scheduler.service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.Stack;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.asiainfo.dacp.dp.server.scheduler.bean.TargetObj;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskConfig;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;
import com.asiainfo.dacp.dp.server.scheduler.type.DataFreq;
import com.asiainfo.dacp.dp.server.scheduler.type.ObjType;
import com.asiainfo.dacp.dp.server.scheduler.type.RunFreq;
import com.asiainfo.dacp.dp.server.scheduler.utils.TimeUtils;

@Service
public class ShipbuilderService {
	private static Logger LOG = LoggerFactory.getLogger(ShipbuilderService.class);
	@Autowired
	private DatabaseDao dbDao;

	private boolean isContain(List<TaskConfig> cfgList, String xmlid) {
		for (TaskConfig config : cfgList) {
			if (StringUtils.equals(xmlid, config.getXmlid())) {
				return true;
			}
		}
		return false;
	}

	public List<TaskLog> getAfterTask(TaskLog curTask) {
		Set<TaskLog> return_set = new HashSet<TaskLog>();
		try {
			String dateArgs = curTask.getDateArgs();
			List<TaskLog> runInfoList = dbDao.queryTaskRunLogList(-6, 100,
					dateArgs,curTask.getRunFreq());//查找出所有有效日志记录
			if (StringUtils.equals(curTask.getRunFreq(), RunFreq.day.name())
					&& TimeUtils.isMonthLast(curTask.getDateArgs())) {
				dateArgs = TimeUtils.formatMonthDateArgs(dateArgs);
				List<TaskLog> logList = dbDao.queryTaskRunLogList(-6, 100,
						dateArgs,RunFreq.month.name());
				if (CollectionUtils.isNotEmpty(logList)) {
					runInfoList.addAll(logList);
				}
			}
			TaskLog _curTask = null;
			List<TargetObj> tarList = null;
			List<TaskConfig> confList = null;
			List<TaskConfig> _confList = null;
			List<TaskConfig> nextProcList = null;
			String curSeqno = null;
			Stack<TaskLog> stack = new Stack<TaskLog>();
			stack.push(curTask);
			Set<TaskConfig> nextProcSet = new HashSet<TaskConfig>();
			while (!stack.isEmpty()) {
				nextProcSet.clear();
				_curTask = stack.pop();
				curSeqno = _curTask.getSeqno();
				LOG.info(_curTask.getXmlid());
				if(!StringUtils.isEmpty(_curTask.getFlowcode())){//如果该任务带有流程编号，则走临时调度
					 List<TargetObj> targetList= dbDao.getTargetMap(_curTask.getFlowcode(),null,_curTask.getProcName());
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
				nextProcList=  MemCache.INTERIM_PROC_NEXR_PROC_MAP.get(_curTask.getXmlid());
				if(nextProcList==null||nextProcList.size()<=0){
					tarList = MemCache.TARGET_MAP.get(_curTask.getXmlid());
					// 输出表后续程序
					if (tarList != null) {
						for (TargetObj _obj : tarList) {
							List<TargetObj> sourceKeyList = dbDao.getSourceKey(_obj.getTarget());
							for(TargetObj obj : sourceKeyList){
								String key = obj.getSource() + "/" + _obj.getTargetfreq();
								if(StringUtils.isNotEmpty(obj.getSourceAppoint()) && _curTask.getDateArgs().endsWith(obj.getSourceAppoint())){
									key += "/" + obj.getSourceAppoint();
								}
								confList = MemCache.DATA_NEXT_ALL_PROC_MAP.get(key);
								if (CollectionUtils.isNotEmpty(confList)) {
									nextProcSet.addAll(confList);
								}
							}
							
							//追加月末触发月
							if (_obj.getTargetfreq().indexOf(DataFreq.D.name()) == 0) {
								if (TimeUtils.isMonthLast(TimeUtils
										.convertToDataTime(_curTask.getDateArgs(), _obj.getTargetfreq()))) {
									confList = MemCache.DATA_NEXT_ALL_PROC_MAP.get(_obj.getTarget()//输出表后置程序时，查询所有后置任务，不区分时间跟事件触发
											+ "/"
											+ DataFreq.ML.name()
											+ "-0");
									if (CollectionUtils.isNotEmpty(confList)) {
										nextProcSet.addAll(confList);
									}
								}
							}
						}
					}
					//程序 后续程序
					nextProcList = MemCache.PROC_NEXT_ALL_PROC_MAP.get(_curTask
							.getXmlid());
				}
				if (nextProcList != null) {
					for (TaskConfig config : nextProcList) {
							nextProcSet.add(config);
					}
				}
				if (nextProcSet.isEmpty()) {
					continue;
				}
				_confList = new ArrayList<TaskConfig>(nextProcSet);
				for (TaskLog task : runInfoList) {//循环当前批次所有有效处理日志
					// 如果任务名和当前任务名相同
					if (StringUtils.equals(task.getSeqno(), curSeqno)) {
						continue;
					}
					// 如果任务已经在堆里
					if (stack.contains(task)) {
						continue;
					}
					
					if (isContain(_confList, task.getXmlid())) {//如果从关系表里查出来的任务配置存在于处理日志里，说明当前任务有后置任务运行了
						if(return_set.contains(task)) {//如果set里已经有该程序，说明后续任务又指向前置任务，进入死循环，终止遍历
//							LOG.info("Failed to search for after task :{}", curTask.getProcName());
//							LOG.info("find one or more sub task :{},please check proc_schedule_log and transdatamap_design!", task.getProcName());
//							List<TaskLog> afterTaskList = new ArrayList<TaskLog>(return_set);
//							map.put("success", false);//成功返回后续任务
//							map.put("list", afterTaskList);//返回后续任务list
//							return map;
							continue;
						}
						stack.push(task);
						return_set.add(task);//加入后续任务
					}
				}
			}

		} catch (Exception e) {
			LOG.error("", e);
		}
		LOG.info("final_return_set_size:{}", return_set.size());
		List<TaskLog> afterTaskList = new ArrayList<TaskLog>(return_set);
		return afterTaskList;
	}

	public List<TaskConfig> getAfterProc(String source, String optTime) {
		int ln = optTime.length();
		String refKey = null;
		List<TaskConfig> configList = new ArrayList<TaskConfig>();
		if (ln == 6) {
			refKey = source + "/" + DataFreq.M.name()+"-0";
		} else if (ln == 8) {
			if (TimeUtils.isMonthLast(optTime)) {
				String _refKey = source + "/" + DataFreq.ML.name()+"-0";
				List<TaskConfig> _configList = MemCache.DATA_NEXT_PROC_MAP
						.get(_refKey);
				if (CollectionUtils.isNotEmpty(_configList)) {//如果存在ML依赖先加入ML依赖
					configList.addAll(_configList);
				}
			}
			refKey = source + "/" + DataFreq.D.name()+"-0";
		} else if (ln == 10) {
			refKey = source + "/" + DataFreq.H.name()+"-0";
		} else if (ln == 12) {
			refKey = source + "/" + DataFreq.MI.name()+"-0";
		} else {
			return configList;
		}
		List<TaskConfig> _configList = MemCache.DATA_NEXT_PROC_MAP.get(refKey);//如果存在普通日依赖，添加普通依赖
		if (CollectionUtils.isNotEmpty(_configList)) {
			configList.addAll(_configList);
		}
//		if (CollectionUtils.isNotEmpty(configList)) {
//			configList.addAll(configList);
//		} else {
//			configList = MemCache.DATA_NEXT_PROC_MAP.get(refKey);
//			if(configList==null){
//				configList = new ArrayList<TaskConfig>();
//			}
//		}
		return configList;
	}

	public List<TaskLog> getAfterTask(String source, String optTime) {
		List<TaskLog> res = new ArrayList<TaskLog>();
		String dateArgs = TimeUtils.dataTimeToDateArgs(optTime);
		try {
			List<TaskConfig> configList = getAfterProc(source, optTime);
			if (CollectionUtils.isEmpty(configList)) {
				return res;
			}
			int ln = optTime.length();
			String runFreq = RunFreq.day.name();
			runFreq = ln==  6?RunFreq.month.name():runFreq;
			runFreq = ln==  8?RunFreq.day.name():runFreq;
			runFreq = ln==10?RunFreq.hour.name():runFreq;
			List<TaskLog> runInfoList = dbDao.queryTaskRunLogList(-6, 100,dateArgs,runFreq);
			if (optTime.length() == 8 && TimeUtils.isMonthLast(optTime)) {
				dateArgs = TimeUtils.formatMonthDateArgs(dateArgs);
				List<TaskLog> logList = dbDao.queryTaskRunLogList(-6, 100,dateArgs,RunFreq.month.name());
				if (CollectionUtils.isNotEmpty(logList)) {
					runInfoList.addAll(logList);
				}
			}
			Set<TaskLog> return_set = new HashSet<TaskLog>();
			for (TaskConfig cfg : configList) {
				for (TaskLog runInfo : runInfoList) {
					if (StringUtils.equals(runInfo.getXmlid(),
							cfg.getXmlid())) {
						return_set.add(runInfo);
					}
				}
			}
			if (CollectionUtils.isNotEmpty(return_set)) {
				res = new ArrayList<TaskLog>(return_set);
			}
		} catch (Exception e) {
			LOG.error("", e);
		}
		return res;
	}


	private static Set<TaskConfig> taskInfoListSet = new HashSet<TaskConfig>();
	public List<TaskConfig> getNextTaskInfo(String xmlid) {
		List<TargetObj> nextAllItemList = dbDao.queryNextAllList(xmlid);
		for (TargetObj targetObj : nextAllItemList) {
			String targetCycle = targetObj.getTargetfreq().split("-")[0];
			String sourceCycle = targetObj.getSourcefreq().split("-")[0];
			//检验是否同周期
			if(sourceCycle.equals(targetCycle)){
				if(targetObj.getTargettype().equals(ObjType.DATA.name()) ){
					//如果是表，直接跳过，递归查询后续任务
					getNextTaskInfo(targetObj.getTarget());
				}else{
					TaskConfig nextTask = MemCache.PROC_MAP.get(targetObj.getTarget());
					if(nextTask!=null){
						//任务信息加入到集合重中
						taskInfoListSet.add(nextTask);
					}
					//继续递归后续任务
					getNextTaskInfo(nextTask.getXmlid());
				}
			}
		}
		List<TaskConfig> afterTaskList = new ArrayList<TaskConfig>(taskInfoListSet);
		return afterTaskList;
	}
}
