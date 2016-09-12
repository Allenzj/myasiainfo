package com.asiainfo.dacp.dp.server.scheduler.command;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.StringUtils;

import com.asiainfo.dacp.dp.common.RunStatus;
import com.asiainfo.dacp.dp.server.scheduler.bean.AgentIps;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.type.MsgType;
import com.asiainfo.dacp.dp.server.scheduler.type.ScriptType;

public class CQCmdLineBuilder extends DpCmdLineBuilder{
	private String externalScriptPath;
	@Override
	public String buildCmdLine(TaskLog runInfo) {
		String cd="";
		String cmd = "";
		List<String> command = new ArrayList<String>();
		String path=StringUtils.isEmpty(runInfo.getPath())?runInfo.getProcName():runInfo.getPath();
		String dateArgs =  runInfo.getDateArgs().trim().replaceAll("-", "");
		String procVars=runInfo.getRunpara();
			AgentIps agentConfig= MemCache.AGENT_IPS_MAP.get(runInfo.getAgentCode());
			String agentPath=agentConfig.getScriptPath();
			String scriptPath=agentPath+path;
			//脚本路径校验
			if(null == scriptPath || "".equals(scriptPath))
				return "";
			scriptPath = scriptPath.trim();
			String scriptType=path.split("[.]")[path.split("[.]").length-1].toLowerCase().trim();
			if(!"jar".equals(scriptType)&&!"pl".equals(scriptType)&&!"py".equals(scriptType)&&!"tcl".equals(scriptType)&&!"sh".equals(scriptType))
				return "";
			switch (ScriptType.getScriptType(scriptType)) {
			case jar:
				cd = "jar";
				break;
			case python:
				cd = "python";
				break;
			case tcl:
				// cd = "tclsh";
				cd = agentPath+externalScriptPath;
				break;
			case shell:
				cd = "sh";
				break;
			default:
				return "";
			}
			if (ScriptType.jar.name().equals(cd)) {
				command.add("java");
				command.add("-jar");
				command.add(scriptPath);
				command.add("-t");
				command.add(dateArgs);
				if (!"".equals(dateArgs) && dateArgs != null) {
					int pos = dateArgs.indexOf(";");
					if (pos == -1) {
						dateArgs = dateArgs + ";";
					}
					String[] splitJobParams = dateArgs.trim().split(";");
					for (int i = 0; i < splitJobParams.length; i++) {
						String param = splitJobParams[i];
						if (param.length() > 0)
							command.add(param);
					}
				}
				for (int i = 0; i < command.size(); i++) {
					cmd += command.get(i) + " ";
				}
			} else {
				command.add(cd);
				command.add(scriptPath);
				if (!"".equals(dateArgs) && dateArgs != null)
					command.add(dateArgs);
				if (!"".equals(procVars) && procVars != null) {
					int pos = procVars.indexOf(";");
					if (pos == -1) {
						procVars = procVars + ";";
					}
					String[] splitJobParams = procVars.trim().split(";");
					for (int i = 0; i < splitJobParams.length; i++) {
						String param = splitJobParams[i];
						if (param.length() > 0)
							command.add(param);
					}
				}
				for (int i = 0; i < command.size(); i++) {
					cmd += command.get(i) + " ";
				}
			}			
			return cmd;
	}
	public String getExternalScriptPath() {
		return externalScriptPath;
	}
	public void setExternalScriptPath(String externalScriptPath) {
		this.externalScriptPath = externalScriptPath;
	}
	
}
