package com.asiainfo.dacp.dp.server.scheduler.quartz;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import com.asiainfo.dacp.dp.common.RunStatus;
import com.asiainfo.dacp.dp.common.RunStatus.AlarmType;
import com.asiainfo.dacp.dp.server.DpServerContext;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskAlarmInfo;
import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;
import com.asiainfo.dacp.dp.server.scheduler.service.TaskService;
import com.asiainfo.dacp.dp.server.scheduler.utils.TimeUtils;
import com.asiainfo.dacp.dp.server.scheduler.utils.UUIDUtils;

public class TaskAlarmJob implements Job{
	private String smsContentTemp="[调度告警]:任务[{0},{1},{2}]截止告警时间{3}未完成";
	@Autowired
	private TaskService taskService;
	@Autowired
	private DatabaseDao dbDao;

	private Logger LOG = LoggerFactory.getLogger(TaskAlarmJob.class);

	public void execute(JobExecutionContext context) throws JobExecutionException {
		SimpleDateFormat  sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Date baseDate = context.getScheduledFireTime();
		TaskAlarmInfo alarmInfo = null;
		try {
			alarmInfo = (TaskAlarmInfo)context.getMergedJobDataMap().get(DpQuartz.ALARM_KEY);
			if (alarmInfo == null) {
				LOG.error("The taskAlarmInfo is not found");
				return;
			}
			
			String dateArgs = TimeUtils.getDateArgs(alarmInfo.getRunFreq(),baseDate,alarmInfo.getOffSet());
			int curAlarmCount = 0;//当前告警次数
			int maxAlarmCount = 0;//最大告警次数
			int intervalTime = 0;//告警间隔
			try {
				maxAlarmCount = Integer.parseInt(alarmInfo.getMaxSendCount());
			} catch (Exception e) {
				LOG.error("[%s,%s]告警信息配置最大告警次数有误",alarmInfo.getProcXmlid(),alarmInfo.getProcName());
			}
			try {
				intervalTime = Integer.parseInt(alarmInfo.getIntervalTime());
			} catch (Exception e) {
				LOG.error("[%s,%s]告警信息配置发送间隔有误",alarmInfo.getProcXmlid(),alarmInfo.getProcName());
			}
			
			while(true){
				//是否有任务成功记录
				boolean flag = taskService.checkExistProc(alarmInfo.getProcXmlid(),dateArgs,RunStatus.PROC_RUN_SUCCESS);
				if(flag){
					break;
				}else{
					curAlarmCount++;
					//告警达到最大次数退出进程
					if(curAlarmCount > maxAlarmCount){
						break;
					}
					//告警间隔配置错误退出进程
					if(intervalTime==0){
						break;
					}
					//记录告警日志，发送告警短信
					Map<String, Object> newmap = new HashMap<String, Object>();
					newmap.put("xmlid", UUIDUtils.getUUID());
					newmap.put("proc_xmlid", alarmInfo.getProcXmlid());
					newmap.put("proc_name", alarmInfo.getProcName());
					newmap.put("proc_date_args", dateArgs);
					newmap.put("alarm_type", AlarmType.PROC_LATE);
					smsContentTemp=smsContentTemp.replace("{0}", alarmInfo.getXmlid()).replace("{1}", alarmInfo.getProcName()).replace("{2}", dateArgs).replace("{3}", sdf.format(baseDate));
					newmap.put("alarm_content", smsContentTemp);
					newmap.put("alarm_time", sdf.format(new Date()));
					
					if(dbDao.insert("proc_schedule_alarm_log", newmap)){
						taskService.SendSmsService(newmap);
					}else{
						LOG.error("记录告警信息失败");
					}
				}
				//告警间隔
				TimeUtils.sleep( intervalTime * 60 );
			}
			
		} catch (Exception ex) {
			LOG.error("记录告警信息出错:"+ex.getMessage());
		}
		
	}
}
