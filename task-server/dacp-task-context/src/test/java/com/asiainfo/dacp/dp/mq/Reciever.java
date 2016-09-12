package com.asiainfo.dacp.dp.mq;

import org.springframework.beans.factory.config.AutowireCapableBeanFactory;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.FileSystemXmlApplicationContext;

import com.asiainfo.dacp.dp.message.DpReceiver;
import com.asiainfo.dacp.dp.message.rabbitmq.RabbitmqReceiver;
import com.asiainfo.dacp.dp.message.rabbitmq.RabbitmqReceivers;
public class Reciever {

	public static void main(String[] args) {
		System.out.println("reciever----start");
		ApplicationContext context = new FileSystemXmlApplicationContext(
				"classpath:conf/applicationContext-recieve.xml");
		AutowireCapableBeanFactory factory = context.getAutowireCapableBeanFactory();
		DpReceiver receiver = factory.createBean(RabbitmqReceivers.class);
		try{
			receiver.start();
		}catch(Exception ex){
			ex.printStackTrace();
		}
	}

}
