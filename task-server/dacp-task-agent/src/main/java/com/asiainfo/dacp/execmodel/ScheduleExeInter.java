package com.asiainfo.dacp.execmodel;

import java.io.File;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.asiainfo.dacp.dp.agent.DpAgentContext;
import com.asiainfo.dacp.dp.agent.DpAgentUtils;
import com.asiainfo.dacp.dp.agent.DpExecutorThread;
import com.asiainfo.dacp.dp.common.MapKeys;
import com.asiainfo.dacp.dp.common.RunStatus;
import com.asiainfo.dacp.dp.message.DpMessage;
@Service
public abstract class ScheduleExeInter {
	private Logger logger = LoggerFactory.getLogger(DpExecutorThread.class);
	private Object message;
	/**
	 * 非脚本程序需要自己实现
	 * @param message
	 * @return
	 */
	public abstract void run(com.asiainfo.dacp.dp.message.DpMessage message,DpAgentContext context);//执行命令
	
	/**
	 * 常规脚本程序匹配通用执行方法
	 * @param message
	 * @param cmdLine
	 */
	public void runcmd(com.asiainfo.dacp.dp.message.DpMessage message,String cmdLine,DpAgentContext context){
		String execText = "";
		DpMessage msg = (DpMessage) message;
		DpMessage returnMsg = msg.clone();
		returnMsg.getFirstMap().clear();
		String msgId = msg.getMsgId();
		execText += String.format("[%s]的执行参数:[%s]\r\n", msgId, cmdLine);
		logger.info(execText);
		// 格式化命令行
		String[] command = cmdLine.split(" ");
		StringBuilder args = new StringBuilder();
		for (String item : command) {
			if (StringUtils.isNotEmpty(item)) {
				args.append(item).append(" ");
			}
		}
		String finalCmdLine = StringUtils.trim(args.toString());
		command = finalCmdLine.split(" ");
		// 获取日志文件路径
		String logPath = context.getLogPath() + File.separator + msgId + ".log";
		// 执行命令
		try {
			Process process = context.getDpProcess()
					.createProcess(logPath, command);
			int pid =  context.getDpProcess().getPid(process);
			if (process != null) {
				context.getProcessMap().put(msgId, process);
			}
			execText += String
					.format("[%s,%s]正在执行，PID:%s\r\n", msgId, cmdLine, pid);
			returnMsg.getFirstMap().put(MapKeys.PROC_STATUS,
					"" + RunStatus.PROC_RUNNING);
			returnMsg.getFirstMap().put(MapKeys.PROC_PID, "" + pid);
			returnMsg.getFirstMap().put(MapKeys.PROC_LOG, "" + execText);
			context.offerSendQueue(returnMsg);
			process.waitFor();
			Thread.sleep(5*1000);//等待日志文件流处理完毕
			execText += context.getDpProcess().getLog(logPath);
		
			// 重新复制一份message;
			returnMsg = msg.clone();
			returnMsg.getFirstMap().clear();
			 /**添加错误步骤号*/
		    returnMsg.getFirstMap().put(MapKeys.PROC_RETURN_CODE, String.valueOf(process.exitValue()));
			if (process.exitValue() == 0) {
				returnMsg.getFirstMap().put(MapKeys.PROC_STATUS,
						"" + RunStatus.PROC_RUN_SUCCESS);
			} else {
				returnMsg.getFirstMap().put(MapKeys.PROC_STATUS,
						"" + RunStatus.PROC_RUN_FAIL);
			}
			returnMsg.getFirstMap().put(MapKeys.PROC_LOG, execText);
			context.offerSendQueue(returnMsg);
			context.getProcessMap().remove(msgId);
		} catch (Exception ex) {
			logger.error("", ex);
			execText += String.format("[%s,%s]执行错误：%s\r\n", msgId, cmdLine,
					DpAgentUtils.getExceptionDetail(ex));
			returnMsg.getFirstMap().put(MapKeys.PROC_STATUS,
					""+RunStatus.PROC_RUN_FAIL);
			returnMsg.getFirstMap().put(MapKeys.PROC_LOG, execText);
			context.offerSendQueue(returnMsg);
		}finally{
			context.getProcessMap().remove(msgId);
		}
	}

}
