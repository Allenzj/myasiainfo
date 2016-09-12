package com.asiainfo.dacp.dp.agent;

import java.lang.reflect.Method;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.FileSystemXmlApplicationContext;

import com.asiainfo.dacp.dp.annotation.DpService;

/**
 * 
 * @author MeiKefu
 * @date 2014-7-22
 */
public class DpAgentBoot {
	private static Logger LOG = LoggerFactory.getLogger(DpAgentBoot.class);

	public static void main(String[] args) {
		try {
			String[] url = new String[] { "classpath*:conf/part/*.xml",
					"file:conf/*.xml" };
			if (args.length == 1) {
				url = new String[] { url[0], args[0] };
			}
			ApplicationContext context = new FileSystemXmlApplicationContext(
					url);
			DpAgentContext agentContext = context.getBean(DpAgentContext.class);
			agentContext.setAppContext(context);
			LOG.info("启动代理服务器:{}", agentContext.getAgentCode());
			LOG.info("启动消息侦听服务");
			agentContext.getDpReceiver().start();
			LOG.info("启动消息发送服务");
			Executors.newSingleThreadExecutor().execute(
					context.getBean(DpAgentMsgSendThread.class));
			DpHeartbeatThread heartbeatThead = context
					.getBean(DpHeartbeatThread.class);
			//LOG.info("发送重启命令");
			//heartbeatThead.sendRestartFlag();
			LOG.info("启动心跳检测服务");
			ScheduledExecutorService executor = Executors.newScheduledThreadPool(2);
			executor.scheduleAtFixedRate(heartbeatThead, 0,
					agentContext.getHeartbeatInterval(), TimeUnit.MINUTES);
			LOG.info("启动日志清理服务");
//			DpLogCleanThread logCleanThread = context
//					.getBean(DpLogCleanThread.class).build(new String[]{"./sbin/rmlog.sh",agentContext.getLogPath()});
//			executor.scheduleAtFixedRate(logCleanThread, 0, 1, TimeUnit.DAYS);
			LOG.info("启动其它服务");
			Map<String, Object> objsMap = context
					.getBeansWithAnnotation(DpService.class);
			for (Object clz : objsMap.values()) {
				Class<?> clas = clz.getClass();
				Method method = clas.getMethod("start", String.class);
				method.invoke(clz, url[1]);
			}

		} catch (Throwable ex) {
			ex.printStackTrace();
			System.exit(-1);
		}
	}
}
