package com.asiainfo.dacp.dp.message.rabbitmq;

import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.DirectExchange;
import org.springframework.amqp.core.FanoutExchange;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitAdmin;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.rabbit.listener.SimpleMessageListenerContainer;
import org.springframework.beans.factory.annotation.Autowired;

import com.asiainfo.dacp.dp.message.DpSender;
/**
 * rabbitmq发送消息
 * @author Silence
 *
 */
public class RabbitmqSender implements DpSender {
	@Autowired
	private ConnectionFactory connectionFactory;
	public static Logger LOG = LoggerFactory.getLogger(RabbitmqSender.class);

	@Override
	public boolean sendMessage(String destination, Object message) {
		try {
			RabbitTemplate rabbitTemplate = new RabbitTemplate(
					connectionFactory);
			RabbitAdmin rabbitAdmin = new RabbitAdmin(connectionFactory);
			String row_key = destination.concat("_key");
			DirectExchange dexchange = new DirectExchange(destination,true,false);
			Queue queue = new Queue(destination, true, false, false);
			rabbitAdmin.declareQueue(queue);
			rabbitAdmin.declareExchange(dexchange);
			rabbitAdmin.declareBinding(BindingBuilder.bind(queue).to(dexchange)
					.with(row_key));
			rabbitTemplate.convertAndSend(destination, row_key, message);
			return true;
		} catch (Exception ex) {
			LOG.error("", ex);
			return false;
		}
	}
	/**
	 * publish,推送消息给多个queue
	 */
	@Override
	public boolean pushMessage(String destination, Object message) {
		try {
			RabbitTemplate rabbitTemplate = new RabbitTemplate(
					connectionFactory);
			RabbitAdmin rabbitAdmin = new RabbitAdmin(connectionFactory);
			FanoutExchange fanExchange = new FanoutExchange(destination, true, false);
			rabbitAdmin.declareExchange(fanExchange);
			rabbitAdmin.declareBinding(BindingBuilder.bind(fanExchange).to(fanExchange));
			rabbitTemplate.convertAndSend(destination, "", message);
			return true;
		} catch (Exception ex) {
			LOG.error("", ex);
			return false;
		}
	}
	/**
	 * rabbitmq resquest/response
	 */
	@Override
	public Object sendAndRecieve(String destination, Object message,
			long timeout) {
		try {
			Queue replyQueue =  new Queue(destination+".reply");
			RabbitAdmin admin = new RabbitAdmin(connectionFactory);
			admin.declareQueue(replyQueue);
			RabbitTemplate template = new RabbitTemplate(connectionFactory);
			template.setExchange(new DirectExchange(UUID.randomUUID().toString(), false, true).getName());
			template.setRoutingKey(destination);
			template.setReplyQueue(replyQueue);
			SimpleMessageListenerContainer container = new SimpleMessageListenerContainer();
			container.setConnectionFactory(connectionFactory);
			container.setQueues(replyQueue);
			container.setAutoStartup(false);
			container.setMessageListener(template);
			container.start();
			RabbitTemplate _template = new RabbitTemplate(connectionFactory);
			if (timeout > 0) {
				_template.setReplyTimeout(timeout);
			}
			Object replyObj = _template.convertSendAndReceive(destination,message);
			return replyObj;
		} catch (Exception ex) {
			LOG.error("", ex);
		}
		return null;
	}

}
