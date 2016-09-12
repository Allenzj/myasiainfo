package com.asiainfo.dacp.dp.agent;

import java.util.Queue;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.asiainfo.dacp.dp.agent.task.CacheUtils;
import com.asiainfo.dacp.dp.message.DpMessage;

/**
 * 消息发送线程
 * 
 * @author wybhlm
 */
@Component
public class DpAgentMsgSendThread implements Runnable {
	@Autowired
	private DpAgentContext context;
	private boolean isStop = false;
	private Logger logger = LoggerFactory.getLogger(DpAgentMsgSendThread.class);
	public void run() {
		Queue<DpMessage> sendQueue = context.getMsgSendQueue();
		DpMessage obtainMsg = null;
		while (!isStop) {
			synchronized (sendQueue) {
				if (sendQueue.isEmpty()) {
					try {
						sendQueue.wait();
					} catch (InterruptedException e) {
						logger.error("", e);
					}
				}
				while (!sendQueue.isEmpty()) {
					obtainMsg = sendQueue.peek();
					if (context.getDpSender().sendMessage(
							obtainMsg.getSourceQueue(), obtainMsg)) {
						sendQueue.poll();
						 CacheUtils.queueTask(context.getAgentCode(),obtainMsg.getMsgId());
					}
				}
			}
			try {
				Thread.sleep(3000L);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}

}
