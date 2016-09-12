package com.asiainfo.dacp.dp.agent;

import java.io.File;
import java.util.HashMap;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.asiainfo.dacp.dp.agent.task.CacheUtils;
import com.asiainfo.dacp.dp.agent.task.Task;
import com.asiainfo.dacp.dp.common.MapKeys;
import com.asiainfo.dacp.dp.common.RunStatus;
import com.asiainfo.dacp.dp.message.DpMessage;
@Service
public class EngineService {
	private Queue<String> tasksQueue = new ConcurrentLinkedQueue<String>();
	@Autowired
	private DpAgentContext context;
	public String service() {
		final String agentCode = context.getAgentCode();
		final String folder = ".cache/" + agentCode;
		File file = null;
		File[] files = null;
		file = new File(folder);
		files = file.listFiles();
		if (files == null) {
			files = new File[] {};
		}
		// 初始化队列
		for (File subItem : files) {
			tasksQueue.add(subItem.getName());
		}
		String seqno = null;
		Task curTask = null;
		String runMsg = null;
		String exitValue=null;
		DpMessage msg = null;
		String log = null;
		String logPath = null;
		while (!tasksQueue.isEmpty()) {
			seqno = tasksQueue.poll();
			System.out.println(" seqno is "+seqno);
			curTask = CacheUtils.paseTask(context.getAgentCode(), seqno);
			if (curTask == null) {
				CacheUtils.queueTask(agentCode, seqno);
			} else if (StringUtils.equals(curTask.getSendFlag(),
					CacheUtils.FinishStatus.SEND)) {
				CacheUtils.queueTask(curTask);
			} else {
				runMsg = curTask.getRunMsg();
				exitValue=curTask.getExitValue();
				logPath = context.getLogPath() + File.separator + seqno
						+ ".log";
				msg = new DpMessage(seqno, MapKeys.TASK_TYPE_PROC, null, null,
						context.getTaskServerQueue());
				msg.addBody(new HashMap<String, String>());
				log = DpAgentUtils.getLog(logPath);
				if (StringUtils.equals(runMsg,
						CacheUtils.FinishStatus.RUN_INTERRUPTION)) {
					msg.getFirstMap().put(MapKeys.PROC_STATUS,
							"" + RunStatus.PROC_RUN_FAIL);
					msg.getFirstMap().put(MapKeys.PROC_LOG,
							log + "\n" + "程序异常退出！");
					context.offerSendQueue(msg);
				} else if (StringUtils.equals(runMsg,
						CacheUtils.FinishStatus.RUN_ERROR)) {
					msg.getFirstMap().put(MapKeys.PROC_STATUS,
							"" + RunStatus.PROC_RUN_FAIL);
					msg.getFirstMap().put(MapKeys.PROC_LOG,
							log + "\n" + "程序报错！");
					msg.getFirstMap().put(MapKeys.PROC_RETURN_CODE, String.valueOf(exitValue));
					context.offerSendQueue(msg);
				} else if (StringUtils.equals(runMsg,
						CacheUtils.FinishStatus.RUN_SUCCESS)) {
					msg.getFirstMap().put(MapKeys.PROC_STATUS,
							"" + RunStatus.PROC_RUN_SUCCESS);
					msg.getFirstMap().put(MapKeys.PROC_LOG, log);
					msg.getFirstMap().put(MapKeys.PROC_RETURN_CODE, String.valueOf(exitValue));
					context.offerSendQueue(msg);
				}else if (StringUtils.equals(runMsg,CacheUtils.FinishStatus.RUN_RUNING)){//如果还有程序正在运行 重新添加到队列中
					for (File subItem : files) {
						tasksQueue.add(subItem.getName());
					}
				}
			}
			try {
				Thread.sleep(10000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		return null;
	}
}
