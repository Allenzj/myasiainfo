package com.asiainfo.dacp.dp.server.scheduler.quartz;

import org.quartz.Job;

public interface DpQuartz {
	public final static String DATA_KEY = "DATA_KEY";
	public final static String ALARM_KEY = "ALARM_KEY";
	public boolean createCronSchdJob(String name, String group, String cronExp,
			Class<? extends Job> jobClass, Object jobData);
	public boolean modifyCronSchdJob(String key, String group, String cronExp,
			Class<? extends Job> jobClass,Object jobData);
	public boolean shutdown();

	public boolean deleteCronSchdJob(String name, String group);

}
