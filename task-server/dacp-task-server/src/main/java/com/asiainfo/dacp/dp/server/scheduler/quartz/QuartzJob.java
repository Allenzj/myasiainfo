package com.asiainfo.dacp.dp.server.scheduler.quartz;

import java.util.Date;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

import com.asiainfo.dacp.dp.server.DpServerContext;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskConfig;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;
import com.asiainfo.dacp.dp.server.scheduler.service.TaskService;
import com.asiainfo.dacp.dp.server.scheduler.type.RunFreq;

/**
 * 生成计划任务
 * 
 * @author wangyuanbin
 */
public class QuartzJob implements Job {
	@Autowired
	private DpServerContext dpContext;
	@Value("${isDeleteTask.minute}")
	private String isDeleteMinuteTask;
	@Autowired
	private TaskService taskService;
	@Autowired
	private DatabaseDao dbDao;
	private Logger LOG = LoggerFactory.getLogger(QuartzJob.class);

	public void execute(JobExecutionContext context)
			throws JobExecutionException {
		Date baseDate = context.getScheduledFireTime(); 
		String procKey  = (String) context.getMergedJobDataMap().get(DpQuartz.DATA_KEY);
//		TaskConfig config= MemCache.PROC_MAP.get(procKey);
		TaskConfig config = null;
		try {
			config = dpContext.getDbDao().queryTaskConfig(procKey);
		} catch (Exception e1) {
			e1.printStackTrace();
		}
		if (config == null) {
			LOG.error("The task is null,con't genaration");
			return;
		}
		boolean needCreate = true;
		try {
			taskService.updateTaskNextTime(config,context.getNextFireTime().getTime(),1);
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		int mutiFlag =  config.getMutiRunFlag()==null?1:config.getMutiRunFlag();
		// 常驻进程
		if(StringUtils.equalsIgnoreCase(isDeleteMinuteTask, "true")){
			if (StringUtils.equals(config.getRunFreq(), RunFreq.minute.name())) {
				try {
					
					dbDao.delete(
							"delete from proc_schedule_script_log  where seqno  in ("
							+ " select seqno from ( "
							+ "select a.seqno  from proc_schedule_script_log a 	"
							+ "LEFT JOIN proc_schedule_log b ON a.seqno = b.seqno "
							+ "where task_state = 6  "
							+ "and b.proc_name='"+config.getProcName()+"')c )");
					int row = dbDao.update(
							"delete from proc_schedule_log where proc_name='"
									+ config.getProcName()
									+ "' and task_state=6  ");
					if (row > 0) {
						needCreate = true;
					} else {
						int exist = dpContext.getDbDao().checkExist(
								"proc_schedule_log", new String[]{"proc_name","task_state"},
								new String[]{config.getProcName(),"6"});
						if (exist == 1) {
							needCreate = false;
						} else {
							needCreate = true;
						}
					}
				} catch (Exception e) {
					LOG.error("", e);
				}
			}
		}
		
		if (needCreate) {
			synchronized (MemCache.TASK_MAP) {
				TaskLog newTask = dpContext.getTaskService().createTaskRunInfo(
						config, null, null,baseDate);
				if (newTask != null) {
					LOG.info("timer[{}] triggered task:[{}]",config.getCronExp(),newTask.getTaskId());
				}
			}
		}
	}
}
