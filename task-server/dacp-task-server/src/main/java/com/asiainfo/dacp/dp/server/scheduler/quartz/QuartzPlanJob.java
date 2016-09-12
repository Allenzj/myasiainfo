package com.asiainfo.dacp.dp.server.scheduler.quartz;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.quartz.TriggerUtils;
import org.quartz.impl.triggers.CronTriggerImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import com.asiainfo.dacp.dp.server.DpServerContext;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskConfig;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.type.RunFreq;
import com.asiainfo.dacp.dp.server.scheduler.type.Type.DRIVE_TYPE;
import com.asiainfo.dacp.dp.server.scheduler.utils.TimeUtils;
public class QuartzPlanJob implements Job{
	@Autowired
	private DpServerContext dpContext;
	private Logger LOG = LoggerFactory.getLogger(QuartzPlanJob.class);
	@Override
	public void execute(JobExecutionContext context)
			throws JobExecutionException {
		Date base = new Date();
		Calendar ca = Calendar.getInstance();
		ca.add(Calendar.DATE, 1);
		String dateStr = TimeUtils.dateToString2Day(ca.getTime());
		LOG.info("生成{}的计划任务＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊开始＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊",dateStr);
		String dateArgs = null;
		ca.setTime(base);
		ca.add(Calendar.DATE, 0);
		dateArgs = TimeUtils.dateToString(ca.getTime()).substring(0, 10);
		for (TaskConfig config : MemCache.PROC_MAP.values()) {
			try{
			switch (RunFreq.valueOf(config.getRunFreq())) {
			case day:// 日任务
				ca.setTime(base);
				ca.add(Calendar.DATE, 0);
				dateArgs = TimeUtils.dateToString(ca.getTime()).substring(0, 10);
				dpContext.getTaskService().createPlanTask(config, dateArgs);
				break;
			case month:// 月任务
				ca.setTime(base);
				if (TimeUtils.isMonthLast(base)) {
					dateArgs = TimeUtils.dateToString(base).substring(0, 8)+ "01";
					dpContext.getTaskService().createPlanTask(config, dateArgs);
				}
				break;
			/*
			case hour:// 小时任务
				ca.setTime(base);
				ca.add(Calendar.DATE, 1);
				for (int i = 0; i < 24; i++) {
					dateArgs = TimeUtils.dateToString(ca.getTime()).substring(0, 10);
					if (i <= 9) {
						dateArgs += " 0" + i;
					} else {
						dateArgs += " " + i;
					}
					dpContext.getTaskService().createPlanTask(config, dateArgs);
				}
				break;*/
			case hour:// 小时任务
				ca.setTime(base);
				ca.add(Calendar.DATE, 1);
				//时间触发小时任务，可以根据cron表达式计算出第二天需要执行的任务批次
				if(config.getTriggerType() == DRIVE_TYPE.TIME_TRIGGER.ordinal()){
					CronTriggerImpl cronTriggerImpl = new CronTriggerImpl();  
			        try {
						cronTriggerImpl.setCronExpression(config.getCronExp());
					} catch (ParseException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}//这里写要准备猜测的cron表达式
				       
			        List<Date> dates = TriggerUtils.computeFireTimesBetween(cronTriggerImpl, null, base, ca.getTime());
				    
					for (Date date : dates) {
						SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH");
						dateArgs = sdf.format(date);
						dateArgs = TimeUtils.getDateArgs(config.getRunFreq(), date, config.getDateArgs() );
						dpContext.getTaskService().createPlanTask(config, dateArgs);
						// 时间触发任务的后续任务
						dpContext.getTaskService().createAfterPlanTask(config.getXmlid(), config.getRunFreq(),
								dateArgs);
					}
				}
				break;
			default:
				break;
			}
			}catch(Exception e){
				LOG.info("生成{}的{}定时任务失败",dateStr,config.getProcName());
				e.printStackTrace();
			}
		}
		LOG.info("生成{}的计划任务＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊结束＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊",dateStr);
	}
}
