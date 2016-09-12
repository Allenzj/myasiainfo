package com.asiainfo.dacp.dp.server.scheduler.service;

import java.util.Date;

import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.asiainfo.dacp.dp.common.RunStatus;
import com.asiainfo.dacp.dp.server.DpServerContext;
import com.asiainfo.dacp.dp.server.scheduler.bean.AgentIps;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.utils.TimeUtils;

@Service
public class CheckResourceService {
	private Logger LOG = LoggerFactory.getLogger(CheckDependService.class);
	@Autowired
	private TaskService taskService;
	@Autowired
	private DpServerContext context;
	@Autowired
	private CheckRunModeService CheckRunModeService;
	public void check(TaskLog runInfo) {
		try {
			//执行模式检测不通过
			if(!CheckRunModeService.check(runInfo)){
				return ;
			}
			// 检测agent并发量
			String agentCode = runInfo.getAgentCode();
			String platform = MemCache.PROC_MAP.get(runInfo.getXmlid()).getPlatform();
			if(StringUtils.isEmpty(agentCode)&&StringUtils.isEmpty(platform)){
				String errorInfo = String.format("task[%s] check agent-ips error[configure error] : both the configure of the agent and platform is null", runInfo.getTaskId());
				LOG.error(errorInfo);
				taskService.setTaskError(runInfo, errorInfo);
				return ;
			}
			//筛选agent
			String  selectAgent = agentCode;
			boolean hasPlatform = false;
			if (StringUtils.isEmpty(agentCode)) {
				int ipsOffset = 0, maxOffset = 0;
				for (AgentIps agent : MemCache.AGENT_IPS_MAP.values()) {
					if (agent.getAgentStatus()==1&&StringUtils.equalsIgnoreCase(agent.getPlatform(),runInfo.getPlatform())) {
						hasPlatform=true;
						ipsOffset = agent.getIps() - agent.getCurips();
						if (ipsOffset > maxOffset) {
							maxOffset = ipsOffset;
							selectAgent = agent.getAgentCode();
						}
					}
				}
			}
			if(StringUtils.isEmpty(selectAgent)){
				int status = -1;
				if(hasPlatform){
					status = RunStatus.AGENT.FULL; 
				}else{
					status = RunStatus.AGENT.NEED;
				}
				context.getTaskService().updateCheckStatus(runInfo, status);
				return ;
			}
			AgentIps _agent = MemCache.AGENT_IPS_MAP.get(selectAgent);
			if (_agent == null) {
				String errorInfo = String.format("task[%s] check agent-ips error:no agent[%s] ", runInfo.getTaskId(),selectAgent);
				taskService.setTaskError(runInfo, errorInfo);
				return ;
			}
			if (_agent.getAgentStatus() == 0) {
				context.getTaskService().updateCheckStatus(runInfo, RunStatus.AGENT.DOWN);
				return ;
			}
			boolean isPass = true;
			//分钟任务忽略并发检测
			//并发检测
			if ( _agent.getIps() - _agent.getCurips() > 0) {
				isPass = true;
			}else{
				isPass = false;
			}
			if(!isPass){
				context.getTaskService().updateCheckStatus(runInfo, RunStatus.AGENT.FULL);
				return ;
			}
			runInfo.setAgentCode(selectAgent);
			
		/*	String stTime=MemCache.PROC_MAP.get(runInfo.getXmlid()).getStTime();
			String stDay=MemCache.PROC_MAP.get(runInfo.getXmlid()).getStDay();*/
			
			// 发送至agent
			if (!taskService.sendProcToAgent(runInfo)) {
				context.getTaskService().updateCheckStatus(runInfo, RunStatus.AGENT.FAIL);
				return;
			}
			AgentIps agent = MemCache.AGENT_IPS_MAP.get(runInfo.getAgentCode());
			if (agent != null) {
				agent.addIps(1);
			}
			runInfo.setExecTime(TimeUtils.dateToString2(new Date()));
			taskService.updateState(runInfo, RunStatus.SEND_TO_MQ);
			MemCache.IPS_TASK_MAP.remove(runInfo.getSeqno());
		} catch (Exception ex) {
			context.getTaskService().updateCheckStatus(runInfo, RunStatus.AGENT.EXCEPTION);
			LOG.error("", ex);
		}
	}
}
