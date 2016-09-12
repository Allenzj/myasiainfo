package com.asiainfo.dacp.dp.mq;

import org.springframework.beans.factory.config.AutowireCapableBeanFactory;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.FileSystemXmlApplicationContext;

import com.asiainfo.dacp.dp.message.DpReceiver;
import com.asiainfo.dacp.dp.message.DpSender;
import com.asiainfo.dacp.dp.message.rabbitmq.RabbitmqReceiver;
import com.asiainfo.dacp.dp.message.rabbitmq.RabbitmqSender;

public class Sender {

	public static void main(String[] args) {
		ApplicationContext context = new FileSystemXmlApplicationContext(
				"classpath:conf/applicationContext-send.xml");
		AutowireCapableBeanFactory factory = context
				.getAutowireCapableBeanFactory();
		final DpSender dpSender = factory.createBean(RabbitmqSender.class);
		new Thread(new Runnable() {
			@Override
			public void run() {
				for (int i = 0; i < 200; i++) {
				
					if (dpSender.sendMessage("cluster_test1", "hello-send1:"+i)) {
						System.out.println("[send]hello-send1:"+i);
					}
					/*
					if (dpSender.sendMessage("cluster_test2", "hello-send2:"+i)) {
						System.out.println("[send]hello-send2:"+i);
					}*/
					//System.out.println("recieve1:"+dpSender.sendAndRecieve("cluster_test1_REQUEST_QUEUE", "send-reply-msg1", 0));
					//System.out.println("recieve2:"+dpSender.sendAndRecieve("cluster_test2_REQUEST_QUEUE", "send-reply-msg2", 0));
					try {
						Thread.sleep(10*1);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
			}
		}).start();

	}
}
