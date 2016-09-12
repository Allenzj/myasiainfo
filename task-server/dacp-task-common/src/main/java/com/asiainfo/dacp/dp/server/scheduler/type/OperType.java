package com.asiainfo.dacp.dp.server.scheduler.type;

public enum OperType {
	/***停止agent*/
	STOP_AGENT,
	/***更新程序配置*/
	UPDATE_PROC_CONFIG,
	/***重做当前任务*/
	REDO_TASK,
	/***重做当前及后续任务*/
	REDO_CUR_AFTER_TASK,
	/***重做接口或者数据的后续任务*/
	REDO_AFTER_DATA_TASK,
	/***强制通过*/
	FORCE_PASS,
	/***停止任务*/
	STOP_TASK;
}
