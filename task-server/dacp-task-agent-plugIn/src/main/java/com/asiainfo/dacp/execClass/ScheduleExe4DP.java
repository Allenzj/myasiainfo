package com.asiainfo.dacp.execClass;

import com.asiainfo.dacp.dp.agent.DpAgentContext;
import com.asiainfo.dacp.dp.common.MapKeys;
import com.asiainfo.dacp.execmodel.ScheduleExeInter;
import com.asiainfo.dacp.dp.message.DpMessage;
/**
 * dp执行类
 * @author Silence
 *
 */
public class ScheduleExe4DP extends ScheduleExeInter {

	@Override
	public void run(DpMessage message,DpAgentContext context) {
		String path="";
		path=message.getFirstMap().get(MapKeys.PATH);
		String cmdLine="sh "+path+" "+message.getFirstMap().get(MapKeys.CMD_LINE);
		this.runcmd(message, cmdLine,context);
	}

}
