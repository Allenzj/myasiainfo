package com.asiainfo.dacp.dp.agent;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.asiainfo.dacp.dp.common.MapKeys;
import com.asiainfo.dacp.dp.message.DpMessage;
import com.asiainfo.dacp.dp.type.MsgType;


/**
 * 
 * @author MeiKefu
 * @date 2014-12-18
 */
@Component
public class DpHeartbeatThread implements Runnable{
	@Autowired
	private DpAgentContext agentContext;
	@Override
	public void run() {
		DpMessage hearBeatMessage = new DpMessage();
		hearBeatMessage.setMsgType(MsgType.taskTypeHeart.name());
		Map<String,String> bodyMap = new HashMap<String,String>();
		bodyMap.put(MapKeys.AGENT_CODE, agentContext.getAgentCode());
		hearBeatMessage.addBody(bodyMap);
		agentContext.getDpSender().sendMessage(agentContext.getHeartBeatQueue(), hearBeatMessage);
	}
	public void sendRestartFlag(){
		/*
		DpMessage hearBeatMessage = new DpMessage();
		hearBeatMessage.setMsgType(MsgType.RESAER_FLAG.name());
		Map<String,String> bodyMap = new HashMap<String,String>();
		bodyMap.put(MapKeys.AGENT_CODE, agentContext.getAgentCode());
		hearBeatMessage.addBody(bodyMap);
		agentContext.getDpSender().sendMessage(agentContext.getHeartBeatQueue(), hearBeatMessage);
		*/
	}
}
