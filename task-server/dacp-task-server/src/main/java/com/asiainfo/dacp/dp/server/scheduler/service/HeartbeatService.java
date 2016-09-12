package com.asiainfo.dacp.dp.server.scheduler.service;

import java.util.Date;
import java.util.HashMap;

import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.asiainfo.dacp.dp.server.DpServerContext;
import com.asiainfo.dacp.dp.server.scheduler.bean.AgentIps;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;
import com.asiainfo.dacp.dp.server.scheduler.utils.TimeUtils;

@Service
public class HeartbeatService implements Runnable {
	private static Logger LOG = LoggerFactory.getLogger(HeartbeatService.class);
	@Autowired
	private DpServerContext context;
	@Autowired
	private DatabaseDao dbDao;
	@Autowired
	private TaskService taskService;
	public void run() {
		while (true) {
			try {
				taskService.refreshAgentIps();
				HashMap<String, Object> map = new HashMap<String, Object>();
				for (AgentIps cfg : MemCache.AGENT_IPS_MAP.values()) {
					String chgTime = cfg.getStatusChgtime();
					if (StringUtils.isEmpty(chgTime)) {
						return;
					}
					Date chgDate = TimeUtils.convertToTime(chgTime);
					Date now = new Date();
					// 检测mq的状态变更时间如果大于minute分钟
					if (now.getTime() - chgDate.getTime() > (long) context
							.getValid_interval() * 60L * 1000L) {
						map.put("agent_name", cfg.getAgentCode());
						map.put("TASK_TYPE", "TASK");
						map.put("node_status", 0);
						// LOG.error("hearbeat info: agent[{}] is down",cfg.getAgentCode());
					} else {
						map.put("agent_name", cfg.getAgentCode());
						map.put("TASK_TYPE", "TASK");
						map.put("node_status", 1);
					}
					dbDao.update("aietl_agentnode",
							"agent_name,task_type", map);
				}
			} catch (Exception e) {
				LOG.error("", e);
			}
			try {
				Thread.sleep(context.getCheck_interval()*1000L);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}

		}

	}
}
