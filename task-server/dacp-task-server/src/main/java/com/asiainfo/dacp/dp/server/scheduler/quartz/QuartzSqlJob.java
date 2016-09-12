package com.asiainfo.dacp.dp.server.scheduler.quartz;

import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import com.asiainfo.dacp.dp.server.DpServerContext;
import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;
/**
 * 执行sql定时任务的操作类
 * @author mantis
 *
 */
public class QuartzSqlJob implements Job{
	@Autowired
	private DpServerContext dpContext;
	@Autowired
	private DatabaseDao dbDao;
	private Logger Log = LoggerFactory.getLogger(QuartzSqlJob.class);
	@Override
	public void execute(JobExecutionContext context)
			throws JobExecutionException {
		String[] sqlTextArr = (String[])context.getMergedJobDataMap().get(DpQuartz.DATA_KEY);
		int count = 0;
		for(String sqlText:sqlTextArr){
			if (!sqlText.isEmpty()){
				dbDao.executeSql(sqlText);
			}
			else {
				Log.error("sql task[{}]'s sql param[{}] is null!", context.getJobDetail().getKey().getName(), count);		
			}
			count++;
		}
		
	}

}
