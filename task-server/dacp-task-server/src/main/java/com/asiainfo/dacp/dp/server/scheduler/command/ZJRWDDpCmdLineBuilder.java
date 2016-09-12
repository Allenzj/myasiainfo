package com.asiainfo.dacp.dp.server.scheduler.command;

import org.apache.commons.lang.StringUtils;

import com.asiainfo.dacp.dp.server.scheduler.bean.AgentIps;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.type.MsgType;

public class ZJRWDDpCmdLineBuilder extends DpCmdLineBuilder {
	@Override
	public String buildCmdLine(TaskLog runInfo) {
		String cmdLine = "";
		String agentCode = runInfo.getAgentCode();
		AgentIps agent = MemCache.AGENT_IPS_MAP.get(agentCode);
		if (agent == null) {
			return cmdLine;
		}
		String path = agent.getScriptPath();
		path = path != null ? path.trim() : path;
		/*
		if (!StringUtils.endsWith(path, File.separator)) {
			path += File.separator;
		}*/
		path += runInfo.getPath();
		String runpara   = this.formatRunpara(runInfo);
		String dateArgs = this.formatDateArgs(runInfo);
		// 格式化参数
		StringBuilder args = new StringBuilder("");
		// 如果是dp程序
		if ( StringUtils.equals(runInfo.getProctype(),
				MsgType.taskTypeProc.name())) {
			cmdLine = args.append("sh ")
					.append(runInfo.getPath()).append(" ").append(dateArgs)
					.append(" ").append(runpara).toString();
		} else {// 如果是脚本
			// 验证脚本类型
			String[] prefix_a = path.split("[.]");
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
			args.append(path).append(" ").append(dateArgs).append(" ").append(runInfo.getSeqno()).append(" ").append(runpara);
			//args.append(path).append(" ").append(dateArgs).append(" ").append(runpara);
			cmdLine = args.toString();
		}
		return cmdLine;
	}
}
