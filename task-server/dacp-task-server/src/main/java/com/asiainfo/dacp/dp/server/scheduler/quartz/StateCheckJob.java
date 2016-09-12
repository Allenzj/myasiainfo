package com.asiainfo.dacp.dp.server.scheduler.quartz;

import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.asiainfo.dacp.dp.server.DpServerContext;
@Component
public class StateCheckJob implements Job{
	@Autowired
	private DpServerContext dpContext ;
	private Logger LOG = LoggerFactory.getLogger(StateCheckJob.class);
	public void execute(JobExecutionContext context)
			throws JobExecutionException {
		LOG.info("online check start");
		dpContext.getTaskService().checkStateService();
		LOG.info("online check end");
		
	}
}
