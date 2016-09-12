package com.asiainfo.dacp.dp.server.scheduler.command;

import org.apache.commons.lang.StringUtils;

import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.type.RunFreq;

public abstract class DpCmdLineBuilder {
	/**
	 * 获取程序执行命令行
	 * @param runInfo
	 * @return
	 */
	protected  String formatDateArgs(TaskLog runInfo){
		String dateArgs = runInfo.getDateArgs();
		dateArgs = dateArgs.replaceAll("-", "");
		dateArgs = dateArgs.replaceAll(" ", "");
		dateArgs = dateArgs.replaceAll(":", "");
		if(StringUtils.equals(runInfo.getRunFreq(),RunFreq.month.name())){
			dateArgs = dateArgs.substring(0,6);
		}
		return dateArgs;
	}
	protected String formatRunpara(TaskLog runInfo){
		String runpara = runInfo.getRunpara();
		if (StringUtils.isNotEmpty(runpara)) {
			runpara = runpara.trim();
			runpara = runpara.replaceAll("\r\n", " ");
			runpara = runpara.replaceAll("\n\r", " ");
			runpara = runpara.replaceAll("\r", " ");
			runpara = runpara.replaceAll("\n", " ");
		}else{
			runpara="";
		}
		return runpara;
	}
	public abstract String buildCmdLine(TaskLog runInfo);
}
