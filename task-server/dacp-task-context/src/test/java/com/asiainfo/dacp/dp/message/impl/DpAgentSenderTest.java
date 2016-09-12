package com.asiainfo.dacp.dp.message.impl;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.FileSystemXmlApplicationContext;

import com.asiainfo.dacp.dp.message.DpSender;
import com.asiainfo.dacp.dp.message.rabbitmq.RabbitmqSender;
public class DpAgentSenderTest {
	public  void test() {
		ApplicationContext context = new FileSystemXmlApplicationContext(
				"classpath*:conf/applicationContext-send.xml");
		DpSender dpSender= context.getBean(RabbitmqSender.class);
		while(true){
			System.out.println("send:"+dpSender.sendMessage("requsetAndResponse", "aaabbbb"));
		}
	}
	public static void main(String[] args) throws InterruptedException{
		ApplicationContext context = new FileSystemXmlApplicationContext(
				"classpath*:conf/applicationContext-send.xml");
		final DpSender dpSender= context.getBean(RabbitmqSender.class);
		new Thread(new Runnable() {
			@Override
			public void run() {
				while(true){
					System.out.println("recieve:"+dpSender.sendAndRecieve("requsetAndResponse", "response_msg", 0));
			        try {
						Thread.sleep(1000*1);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
			}
		}).start();
		
	}
}
