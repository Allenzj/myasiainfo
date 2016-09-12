package com.asiainfo.dacp.dp.server.scheduler.utils;


import org.apache.commons.lang3.StringUtils;

import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;

public class TaskUtils {
	/** 判断任务是否被创建 */
	public static boolean isNotCreated(String xmlid, String dataArgs) {
		for(TaskLog taskLog :MemCache.TASK_MAP.values()){
			if (StringUtils.equals(taskLog.getXmlid(), xmlid)
					&& StringUtils.equals(taskLog.getDateArgs(), dataArgs)&&StringUtils.equals(taskLog.getValidFlag().toString(),"0")) {
//				taskStatus = taskLog.getTaskState();
//				if (taskStatus == RunStatus.REDO
//				  || taskStatus == RunStatus.CREATE_TASK
//				  || taskStatus == 0-RunStatus.CREATE_TASK) {
//					return false;
//				}
					return false;
			}
		}
		return true;
	}
	/**
	 * 根据程序名，出队标志查询未出队列的任务
	 */
	public static boolean isEnqueue(String procName) {
		for (TaskLog taskLog : MemCache.TASK_MAP.values()) {
			if (StringUtils.equals(taskLog.getProcName(), procName)) {
				return true;
			}
		}
		return false;
	}

}
