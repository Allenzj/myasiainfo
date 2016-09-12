package com.asiainfo.dacp.dp.agent;

import java.lang.reflect.Method;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

import com.asiainfo.dacp.dp.common.MapKeys;
import com.asiainfo.dacp.dp.common.RunStatus;
import com.asiainfo.dacp.dp.message.DpMessage;
import com.asiainfo.dacp.dp.type.MsgType;


/**
 * 
 * @author MeiKefu
 * @date 2014-12-18
 */
@Component
@Scope("prototype")
public class DpExecutorThread implements Runnable {
	private Logger logger = LoggerFactory.getLogger(DpExecutorThread.class);
	private Object message;
	@Autowired
	private DpAgentContext context;

	public DpExecutorThread build(Object message) {
		this.message = message;
		return this;
	}

	@Override
	public void run() {
		String execText = "";
		DpMessage msg=(DpMessage) message;
		DpMessage returnMsg = msg.clone();
		returnMsg.getFirstMap().clear();
		String classURL=msg.getClassUrl();
		String classMethod=msg.getClassMethod();
		try{
		Class<?> clazz = Class.forName(classURL);
		Method m = clazz.getDeclaredMethod(classMethod,DpMessage.class,DpAgentContext.class);
	    m.invoke(clazz.newInstance(), message,context);//运行脚本执行类
		}catch(Exception e){
		logger.info("agent run process fail");
		e.printStackTrace();
		execText += String.format("[%s,%s]执行错误：%s\r\n", msg.getMsgId(), msg.getFirstMap().get(MapKeys.CMD_LINE),
				DpAgentUtils.getExceptionDetail(e));
		returnMsg.getFirstMap().put(MapKeys.PROC_STATUS,
				""+RunStatus.PROC_RUN_FAIL);
		returnMsg.getFirstMap().put(MapKeys.PROC_LOG, execText);
		context.offerSendQueue(returnMsg);
		}
		
	}
}
