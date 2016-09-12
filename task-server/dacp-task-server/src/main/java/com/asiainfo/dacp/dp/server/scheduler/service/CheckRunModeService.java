package com.asiainfo.dacp.dp.server.scheduler.service;

import java.util.Calendar;
import java.util.List;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.asiainfo.dacp.dp.common.RunStatus;
import com.asiainfo.dacp.dp.server.DpServerContext;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskConfig;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;
import com.asiainfo.dacp.dp.server.scheduler.type.RunFreq;
import com.asiainfo.dacp.dp.server.scheduler.type.Type;
import com.asiainfo.dacp.dp.server.scheduler.utils.TimeUtils;
@Service
public class CheckRunModeService {
	private Logger LOG = LoggerFactory.getLogger(CheckDependService.class);
	@Autowired
	private DpServerContext context;
	@Autowired
	private DatabaseDao dbDao;
	public boolean  check(TaskLog runInfo) {
		try {
			MemCache.SRC_LOG_MAP.remove(runInfo.getSeqno());
			if(isAllow(runInfo.getDateArgs(),runInfo.getRunFreq())){
				context.getTaskService().updateCheckStatus(runInfo, RunStatus.RUNMODE.ISALLOW);
				return false;
			}
			//检测同任务名，同批次号程序
			if(isRuning(runInfo.getXmlid(),runInfo.getDateArgs())){
				context.getTaskService().updateCheckStatus(runInfo, RunStatus.RUNMODE.SAME);
				return false;
			}
			// 检测执行模式[0/顺序启动 1/多重启动 2/单一启动 3/月内顺序启动]
			// 默认单一启动
			// 并发量检测
			TaskConfig config = MemCache.PROC_MAP.get(runInfo.getXmlid());
			int mutiRun = config.getMutiRunFlag()==null?0:(int)config.getMutiRunFlag();
			
			//顺序启动EXECUTE_SERIAL
			if (mutiRun == Type.RUN_TYPE.EXECUTE_SERIAL.ordinal()) {
				if (isRuning(runInfo.getXmlid())){
					context.getTaskService().updateCheckStatus(runInfo, RunStatus.RUNMODE.MUT);
					return false;
				}
				//如果上一批次未运行，当前批次不运行
				if(!isPreTaskRun(runInfo.getRunFreq(),runInfo.getXmlid(),runInfo.getDateArgs(),false)){
					context.getTaskService().updateCheckStatus(runInfo, RunStatus.RUNMODE.PRE);
					return false;
				}
			}else if(mutiRun == Type.RUN_TYPE.EXECUTE_ONECE.ordinal()){
				//串行执行判断
				if (isRuning(runInfo.getXmlid())){
					context.getTaskService().updateCheckStatus(runInfo, RunStatus.RUNMODE.MUT);
					return false;
				}
			}//周期内顺序启动EXECUTE_SERIAL_IN_CYCLE
			else if (mutiRun == Type.RUN_TYPE.EXECUTE_SERIAL_IN_CYCLE.ordinal()) {
				if (isRuning(runInfo.getXmlid())){
					context.getTaskService().updateCheckStatus(runInfo, RunStatus.RUNMODE.MUT);
					return false;
				}
				//如果上一批次未运行，当前批次不运行
				if(!isPreTaskRun(runInfo.getRunFreq(),runInfo.getXmlid(),runInfo.getDateArgs(), true)){
					context.getTaskService().updateCheckStatus(runInfo, RunStatus.RUNMODE.PRE);
					return false;
				}
			}
			return true;
		} catch (Exception ex) {
			context.getTaskService().updateCheckStatus(runInfo, RunStatus.RUNMODE.EXCEPTION);
			LOG.error("", ex);
			return false;
		} 
		
	}
	private boolean isAllow(String dateArgs,String runFreq){
		try {
			
			int checkValue= 0;
			if(StringUtils.equalsIgnoreCase(runFreq, RunFreq.minute.name())||StringUtils.equalsIgnoreCase(runFreq, RunFreq.hour.name())){
				dateArgs=dateArgs.substring(0,10);
			}
			checkValue=dbDao.checkExist("schedule_task_premisstion",new String[]{"date_args","run_flag","run_freq"},new Object[]{dateArgs,RunStatus.IsValid.IS_ALLOW,runFreq});
			return checkValue==1;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	/**
	 * 上一个批次任务是否在运行
	 * @param runFreq 周期
	 * @param xmlid 任务xmlid
	 * @param curDateArgs 当前日期批次
	 * @param flag 是否跨周期校验
	 * @return
	 */
	private boolean isPreTaskRun(String runFreq, String xmlid,
			String curDateArgs,boolean flag) {
		try {
			String preDateArgs = TimeUtils.getPreDateArgs(runFreq, curDateArgs);
			if (preDateArgs == null) {
				return true;
			}
			
			if(flag){
				boolean result = false;
				switch(runFreq){
					case "hour":
						if(!preDateArgs.substring(0,10).equals(curDateArgs.substring(0,10))){
							result = true;
						}
						break;
					case "day":
						if(!preDateArgs.substring(0,7).equals(curDateArgs.substring(0,7))){
							result = true;
						}
						break;
					case "month":

						if(!preDateArgs.substring(0,4).equals(curDateArgs.substring(0,4))){
							result = true;
						}
						break;
					case "minute":
						if(!preDateArgs.substring(0,13).equals(curDateArgs.substring(0,13))){
							result = true;
						}
						break;
					default:
						break;
					}
				
				if(result){
					return result;
				}
			}
			
			List<TaskLog> logList = dbDao.queryTaskRunLogList("and xmlid='"
					+ xmlid + "' and  date_args='" + preDateArgs
					+ "' order by task_state desc ");
			if (logList.isEmpty()) {
				return true;
			}
			int state = 0;
			for (TaskLog log : logList) {
				state = log.getTaskState();
				if (state == RunStatus.PROC_RUN_SUCCESS) {
					return true;
				}
			}
		} catch (Exception e) {
			LOG.error("", e);
		}
		return false;
	}
	/** 判断任务是否处于运行状态 */
	private   boolean isRuning(String xmlid) {
		int taskStatus = 0;
		for (TaskLog taskLog : MemCache.TASK_MAP.values()) {
				if (StringUtils.equals(taskLog.getXmlid(), xmlid)) {
					taskStatus = taskLog.getTaskState();
					if (taskStatus == RunStatus.SEND_TO_MQ
							|| taskStatus == RunStatus.PROC_RUNNING
							|| taskStatus == RunStatus.WAIT_FINISH) {
						return true;
					}
				}
		}
		return false;
	}
	/** 判断任务是否处于运行状态 */
	private  boolean isRuning(String xmlid,String dateArgs) {
		int taskStatus = 0;
		for (TaskLog taskLog : MemCache.TASK_MAP.values()) {
				if (StringUtils.equals(taskLog.getXmlid(), xmlid)
						&&StringUtils.equals(taskLog.getDateArgs(), dateArgs)) {
					taskStatus = taskLog.getTaskState();
					if (taskStatus == RunStatus.SEND_TO_MQ
							|| taskStatus == RunStatus.PROC_RUNNING
							|| taskStatus == RunStatus.WAIT_FINISH) {
						return true;
					}
				}
		}
		return false;
	}
}
