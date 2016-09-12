package com.asiainfo.dacp.execClass;

import com.asiainfo.dacp.dp.agent.DpAgentContext;
import com.asiainfo.dacp.dp.common.MapKeys;
import com.asiainfo.dacp.dp.message.DpMessage;
import com.asiainfo.dacp.execmodel.ScheduleExeInter;

public class ScheduleExe4TCL extends ScheduleExeInter{

	@Override
	public void run(DpMessage message,DpAgentContext context) {
		// TODO Auto-generated method stub
		String path="";
		if(message.getFirstMap().get(MapKeys.PATH)!=null){
		path= message.getFirstMap().get(MapKeys.PATH).endsWith("/")?
		message.getFirstMap().get(MapKeys.PATH):message.getFirstMap().get(MapKeys.PATH)+"/";
		}
		String cmdLine="tclsh "+path+
			   message.getFirstMap().get(MapKeys.PROC_NAME)+
			   " "+message.getFirstMap().get(MapKeys.CMD_LINE);
		this.runcmd(message, cmdLine,context);
	}

}
