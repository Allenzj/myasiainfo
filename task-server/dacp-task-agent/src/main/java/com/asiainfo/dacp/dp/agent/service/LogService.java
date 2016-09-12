package com.asiainfo.dacp.dp.agent.service;

import java.io.File;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import com.asiainfo.dacp.dp.agent.DpAgentContext;
import com.asiainfo.dacp.dp.common.MapKeys;
import com.asiainfo.dacp.dp.message.DpMessage;
@Service
public class LogService {
	public String service(DpMessage msg,DpAgentContext context){
		String distFile =context.getLogPath()+ File.separator + msg.getMsgId() + ".log";
		Map<String, String> firstMap = msg.getFirstMap();
		String cmd = firstMap.get(MapKeys.CMD_LINE);
		if(StringUtils.hasText(cmd)){
			CmdExecutor exeCutor = new CmdExecutor();
			exeCutor.execCmd(cmd+" "+distFile, 0);
			return exeCutor.getLines();
		}else{
			return "无日志";
		}
	}
}
