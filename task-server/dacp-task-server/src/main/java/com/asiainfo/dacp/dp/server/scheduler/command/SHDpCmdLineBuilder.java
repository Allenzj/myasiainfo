package com.asiainfo.dacp.dp.server.scheduler.command;

import org.apache.commons.lang.StringUtils;

import com.asiainfo.dacp.dp.server.scheduler.bean.AgentIps;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.type.MsgType;
import com.asiainfo.dacp.dp.server.scheduler.type.RunFreq;

public class SHDpCmdLineBuilder extends DpCmdLineBuilder {
	
	@Override
	protected String formatDateArgs(TaskLog runInfo) {
		String dateArgs = super.formatDateArgs(runInfo);
//		if(StringUtils.equals(runInfo.getRunFreq(),RunFreq.month.name())){
//			dateArgs = dateArgs+"01";
//		}
		return dateArgs;
	}

	@Override
	public String buildCmdLine(TaskLog runInfo) {
		String cmdLine = "";
		String agentCode = runInfo.getAgentCode();
		AgentIps agent = MemCache.AGENT_IPS_MAP.get(agentCode);
		if (agent == null) {
			return cmdLine;
		}
		String agentPath = agent.getScriptPath().trim();
//		path = path != null ? path.trim() : path;
//		path += runInfo.getPath();
		String procPath = runInfo.getPath().trim();
		String progName = runInfo.getProcName();
		String runpara   =  this.formatRunpara(runInfo);
		String dateArgs =  this.formatDateArgs(runInfo);
		// 格式化参数
		StringBuilder args = new StringBuilder("");
		
		if ( StringUtils.equals(runInfo.getProctype(), MsgType.taskTypeProc.name())) {// 如果是dp程序
			if(agentPath.endsWith("/")) {
				cmdLine = args.append("sh ")
						.append(agentPath).append("proc/run.sh ").append(progName).append(" ").append(dateArgs)
						.append(" ").append(runpara).toString();
			} else {
				cmdLine = args.append("sh ")
						.append(agentPath).append("/proc/run.sh ").append(progName).append(" ").append(dateArgs)
						.append(" ").append(runpara).toString();
			}
			
		} else {// 如果是脚本, 验证脚本类型
			String[] prefix_a = procPath.split("[.]");
			int length = prefix_a.length;
			if (length < 2 || StringUtils.isEmpty(prefix_a[length - 1])) {
				return cmdLine;
			}
			String prefix = prefix_a[length - 1].toLowerCase();
			if(StringUtils.equals("jar", prefix)){
				args.append("java -jar ");
			}else if(StringUtils.equals("tcl", prefix)){
				args.append("tclsh ");
			}else if(StringUtils.equals("py", prefix)){
				args.append("python ");
			}else if(StringUtils.equals("pl", prefix)){
				args.append("perl ");
			}else if(StringUtils.equals("bat", prefix)){
				args.append("");
			}else if(StringUtils.equals("sh", prefix)){
				args.append("sh ");
			}
			
			//增加执行SS脚本的参数匹配, 格式为: SS_pre_table_judge.sh -p SHDW.BASS1_USER_SRVC_YYYYMM -t YYYYMM  
//			if(progName.contains("YYYYMMDD")) {
//				progName = "-p " + progName.substring(0, progName.length() - 8) + dateArgs.substring(0, 8);
//				dateArgs = "-t " + dateArgs.substring(0, 8);
//			} else if(progName.contains("YYYYMM")) {
//				progName = "-p " + progName.substring(0, progName.length() - 6) + dateArgs.substring(0, 6);
//				dateArgs = "-t " + dateArgs.substring(0, 6);
//			} else if(progName.contains("YYYY")) {
//				progName = "-p " + progName.substring(0, progName.length() - 4) + dateArgs.substring(0, 4);
//				dateArgs = "-t " + dateArgs.substring(0, 4);
//			}
			
			args.append(procPath).append(" ").append(dateArgs).append(" ").append(runpara);
			cmdLine = args.toString();
			
		}
		System.out.println("执行命令: " + cmdLine);
		return cmdLine;
		
	}
	
	public static void main(String[] args) {
		String agentPath = "/data1/";
		
		String cmd_Line = "";
		StringBuilder args_str = new StringBuilder("");
		
		System.out.println("cmdLine: " + cmd_Line);
		
		if(agentPath.endsWith("/")) {
			cmd_Line = args_str.append("sh ").append(agentPath).append("proc/run.sh ").toString();
		} else {
			cmd_Line = args_str.append("sh ").append(agentPath).append("/proc/run.sh ").toString();
		}
		
		System.out.println("cmdLine: " + cmd_Line);
	}
	
}
