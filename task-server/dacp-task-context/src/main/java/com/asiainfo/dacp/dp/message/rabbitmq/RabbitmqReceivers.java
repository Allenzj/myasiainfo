package com.asiainfo.dacp.dp.message.rabbitmq;

import java.util.ArrayList;
import java.util.Map;

import org.springframework.amqp.core.Queue;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitAdmin;
import org.springframework.amqp.rabbit.listener.SimpleMessageListenerContainer;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.util.StringUtils;

import com.asiainfo.dacp.dp.message.DpReceiver;

public class RabbitmqReceivers implements DpReceiver, ApplicationContextAware {
	@Autowired
	private ConnectionFactory ConnectionFactory;
	private ApplicationContext context;
	private Map<String, SimpleMessageListenerContainer> containerMap;
	public void start() {
		RabbitAdmin admin = new RabbitAdmin(ConnectionFactory);
		containerMap = context.getBeansOfType(SimpleMessageListenerContainer.class);
		for (SimpleMessageListenerContainer container : containerMap.values()) {
			if (!container.isAutoStartup()) {
				String[] queueNames = container.getQueueNames();
				for (String queueName : queueNames) {
					Queue queue = new Queue(queueName,true,false,false);
					admin.declareQueue(queue);
				}
				container.start();
			}
		}
	}
	@Override
	public void stop() {
		for (SimpleMessageListenerContainer container : containerMap.values()) {
			container.stop();
		}
	}

	@Override
	public void restart() {
		stop();
		start();
	}

	@Override
	public void setApplicationContext(ApplicationContext arg0)
			throws BeansException {
		this.context = arg0;
	}
}
