package com.asiainfo.dacp.dp.agent;

import java.util.Map;
import java.util.Queue;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import com.asiainfo.dacp.dp.message.DpReceiver;
import com.asiainfo.dacp.dp.message.DpSender;
import com.asiainfo.dacp.dp.message.DpMessage;
import com.asiainfo.dacp.dp.process.DpProcess;
import com.asiainfo.dacp.util.StringUtils;

/**
 * 
 * @author MeiKefu
 * @date 2014-12-18
 */
@Component
public class DpAgentContext {
	/**代理服务器名*/
	@Value("${agent-code}")
	private String agentCode;
	/**请求队列名后缀*/
	@Value("${request.queue.name}")
	private String agentQueueSuffix;
	/**代理服务器名*/
	@Value("${log-path}")
	private String logPath;
	/**心跳检测队列*/
	@Value("${heartbeat-queue}")
	private String heartBeatQueue;
	/**心跳时间间隔 [分钟]*/
	@Value("${heartbeat-interval}")
	private String heartbeatInterval = "10";
	/**task-server接收消息默认队列*/
	@Value("${task-server-queue}")
	private String taskServerQueue;
	/**要执行的shell脚本路径*/
	@Value("${kill-shell}")
	private String shellPath;
	
	public String getShellPath() {
		return shellPath;
	}
	/**消息处理线程池大小*/
	@Value("${executor-thead-count}")
	private String executorTheadCount = "10";
	/**消息处理发送器*/
	@Autowired
	private DpSender dpSender;
	/**进程管理工具*/
	@Autowired
	private DpProcess dpProcess;
	@Autowired
	private DpReceiver dpReceiver;
	private ApplicationContext appContext;
	/**进程队列*/
	private Map<String,Process> processMap = new ConcurrentHashMap<String, Process>();
	/**消息队列*/
	private Queue<DpMessage> msgSendQueue = new ConcurrentLinkedQueue<DpMessage>();
	private ExecutorService threadPool = Executors.newCachedThreadPool();
	
	public ExecutorService getThreadPool() {
		return threadPool;
	}
	public String getAgentCode() {
		return agentCode;
	}
	public DpProcess getDpProcess() {
		return dpProcess;
	}
	public String getHeartBeatQueue() {
		return heartBeatQueue;
	}

	public String getTaskServerQueue() {
		return taskServerQueue;
	}

	public int getExecutorTheadCount() {
		if (StringUtils.isNumberic(executorTheadCount)) {
			return Integer.parseInt(executorTheadCount);
		} else {
			return 10;
		}
	}
	
	public DpSender getDpSender() {
		return dpSender;
	}

	public int getHeartbeatInterval() {
		if (StringUtils.isNumberic(heartbeatInterval)) {
			return Integer.parseInt(heartbeatInterval);
		} else {
			return 10;
		}

	}
	/**
	 * 正在运行的业务线程数
	 */
	private int runningThreads;


	public int getRunningThreads() {
		return runningThreads;
	}

	public void setRunningThreads(int runningThreads) {
		this.runningThreads = runningThreads;
	}
	public String getLogPath() {
		return logPath;
	}
	public Map<String, Process> getProcessMap() {
		return processMap;
	}
	public Queue<DpMessage> getMsgSendQueue() {
		return msgSendQueue;
	}
	public void offerSendQueue(DpMessage msg){
		synchronized (msgSendQueue) {
			msgSendQueue.offer(msg);
			msgSendQueue.notify();
		}
	}
	public ApplicationContext getAppContext() {
		return appContext;
	}
	public void setAppContext(ApplicationContext appContext) {
		this.appContext = appContext;
	}
	public DpReceiver getDpReceiver() {
		return dpReceiver;
	}
	public void setAgentCode(String agentCode) {
		this.agentCode = agentCode;
	}
	public String getAgentQueueSuffix() {
		return agentQueueSuffix;
	}
	
}
