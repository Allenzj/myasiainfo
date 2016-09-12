package com.asiainfo.dacp.dp.server.scheduler.type;
public enum ScriptType {
	jar,
	shell,
	hive,
	tcl,
	dp,
	python,
	mapReduce,
	sql;
	public static ScriptType getScriptType(String scriptType){
		return valueOf(scriptType.toLowerCase());
	}
}
