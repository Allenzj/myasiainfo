package com.asiainfo.dacp.dp.agent;

import org.apache.commons.exec.OS;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import com.asiainfo.dacp.dp.agent.service.CmdExecutor;
import com.asiainfo.dacp.dp.agent.service.LogService;
import com.asiainfo.dacp.dp.agent.task.CacheUtils;
import com.asiainfo.dacp.dp.agent.task.Task;
import com.asiainfo.dacp.dp.common.MapKeys;
import com.asiainfo.dacp.dp.common.RunStatus;
import com.asiainfo.dacp.dp.message.DpHandler;
import com.asiainfo.dacp.dp.message.DpMessage;
import com.asiainfo.dacp.dp.type.MsgType;
import com.asiainfo.dacp.util.JsonHelper;

/**
 * 
 * @author MeiKefu
 * @date 2014-12-18
 */
public class DpAgentReceiver implements DpHandler {
	@Autowired
	private DpAgentContext context;
	@Autowired 
	private LogService logService;
	private Logger logger = LoggerFactory.getLogger(DpExecutorThread.class);

	public Object onMessage(Object object) {
		try {
			DpMessage msg = (DpMessage) object;
			String msgStr = JsonHelper.getInstance().write(msg);
			logger.info("收到消息:{}", msgStr);
			DpMessage returnMsg = msg.clone();
			returnMsg.getFirstMap().clear();
			String msgId = msg.getMsgId();
			String msgType = StringUtils.trim(msg.getMsgType());
			String execText = "";
			// 参数校验
			if (StringUtils.isEmpty(msgId)) {
				execText = String.format("[%s]的消息不完整：编号为空", msgId);
			} else if (StringUtils.isEmpty(msgType)) {
				execText = String.format("[%s]的消息不完整：类型为空", msgId);
			} else {
				execText = "";
			}
			if (StringUtils.isNotEmpty(execText)) {
				returnMsg.getFirstMap().put(MapKeys.PROC_STATUS,
						""+RunStatus.PROC_RUN_FAIL);
				returnMsg.getFirstMap().put(MapKeys.PROC_LOG, execText);
				context.offerSendQueue(returnMsg);
				return null;
			}
			switch (MsgType.valueOf(msgType)) {
			case taskTypeFunc:// 执行脚本
				DpExecutorThread dpExecutorThread = context.getAppContext()
						.getBean(DpExecutorThread.class).build(msg);
				context.getThreadPool().execute(dpExecutorThread);
				return null;
			case KILL_PROC:// 杀进程
				int exitValue = -1;
				Task curTask = CacheUtils.paseTask(context.getAgentCode(), msg.getMsgId());
				logger.info("1111111");
				System.out.println("11111");
				if(curTask == null){
					logger.info("1111111");
					System.out.println("11111");
					exitValue = 0;
				}else{
					logger.info(curTask.getRunMsg()+" run_Runing");
					if(curTask.getRunMsg().equals(CacheUtils.FinishStatus.RUN_RUNING)){
						String killShell = context.getShellPath();
						logger.info("killShell 路径为 ："+killShell+" ");
						CmdExecutor executor = new CmdExecutor();
						if(OS.isFamilyMac()){
							exitValue = -1;
						}else if(OS.isFamilyWindows()){
							exitValue = executor.execCmd(killShell+" "+curTask.getPid());
						}else if(OS.isFamilyUnix()){
							logger.info("执行命令为 : "+"sh "+killShell+" "+curTask.getPid());
							exitValue = executor.execCmd("sh "+killShell+" "+curTask.getPid());
							logger.info("执行结果为 : "+exitValue);
						}else{
							exitValue = -1;
						}
						  CacheUtils.queueTask(context.getAgentCode(),msg.getMsgId());
					}
				}
				return  exitValue==0?"true":"false";
			case GET_LOG:
				return logService.service(msg, context);
			default:
				return null;
			}
		} catch (Exception ex) {
			logger.error("",ex);
			return null;
		}
	}
	
}
