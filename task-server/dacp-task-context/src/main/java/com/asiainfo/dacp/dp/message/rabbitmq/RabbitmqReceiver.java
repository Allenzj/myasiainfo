package com.asiainfo.dacp.dp.message.rabbitmq;

import org.springframework.amqp.core.Queue;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitAdmin;
import org.springframework.amqp.rabbit.listener.SimpleMessageListenerContainer;
import org.springframework.beans.factory.annotation.Autowired;

import com.asiainfo.dacp.dp.message.DpReceiver;

public class RabbitmqReceiver implements DpReceiver {
	@Autowired
	private ConnectionFactory ConnectionFactory;
	@Autowired
	private SimpleMessageListenerContainer container;
	@Override
	public void start() {
		RabbitAdmin admin = new RabbitAdmin(ConnectionFactory);
		if(container!=null){
			if(!container.isAutoStartup()){
				String[] queueNames = container.getQueueNames();
				for (String queueName : queueNames) {
					Queue queue = new Queue(queueName,true,false,false);
					admin.declareQueue(queue);
				}
				//container.setQueues(queues);
				//container.setAutoStartup(true);
				container.start();
			}
		}
	}
	@Override
	public void stop() {
		if(container!=null){
			container.stop();
		}
	}
	@Override
	public void restart(){
		stop();
		start();
	}
}
