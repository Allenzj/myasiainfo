package com.asiainfo.dacp.dp.server.scheduler.service;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CountDownLatch;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.asiainfo.dacp.dp.common.RunStatus;
import com.asiainfo.dacp.dp.common.RunStatus.IsValid;
import com.asiainfo.dacp.dp.server.DpServerContext;
import com.asiainfo.dacp.dp.server.scheduler.bean.SourceLog;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;
import com.asiainfo.dacp.dp.server.scheduler.type.ObjType;
public class CheckDependService implements Runnable {
	private Logger LOG = LoggerFactory.getLogger(CheckDependService.class);
	private CountDownLatch latch;
	private TaskLog runInfo;
	private DatabaseDao databaseDao;
	private TaskService taskService;
	public CheckDependService(DpServerContext context,TaskLog runInfo,CountDownLatch latch) {
		this.runInfo = runInfo;
		this.databaseDao=context.getDbDao();
		this.taskService = context.getTaskService();
		this.latch = latch;
	}
	//
	@Override
	public void run() {
		try {
			Object[] values = null;
			int ckRes = 0;
			Map<String, Object> dataMap = new HashMap<String, Object>();
			String[] targetFileds = new String[] { "target", "data_time"};
			String[] procFileds = new String[] { "xmlid", "date_args",
					"task_state","valid_flag" };
			List<SourceLog> srcLst = MemCache.SRC_LOG_MAP.get(runInfo
					.getSeqno());
			if(srcLst == null){
				srcLst = new LinkedList<SourceLog>();
				LOG.debug("任务[" + runInfo.getTaskId() + "]未找到前置依赖信息");
			}
			Iterator<SourceLog> iter = srcLst.iterator();
			SourceLog srcLog = null;
			while (iter.hasNext()) {
				srcLog = iter.next();
				ckRes = 0;
				if (srcLog.getCheckFlg() == 1) {
					iter.remove();
					continue;
				}
				switch (ObjType.valueOf(srcLog.getSourceType())) {
				case DATA:
					values = new Object[] { srcLog.getSource(),
							srcLog.getDataTime() };
					ckRes = databaseDao.checkExist("proc_schedule_meta_log",
							targetFileds, values);
					break;
				case INTER:
					values = new Object[] { srcLog.getSource(),
							srcLog.getDataTime() };
					ckRes = databaseDao.checkExist("proc_schedule_meta_log",
							targetFileds, values);
					break;
				case EVENT:
					values = new Object[] { srcLog.getSource(),
							srcLog.getDataTime() };
					ckRes = databaseDao.checkExist("proc_schedule_meta_log",
							targetFileds, values);
					break;
				case PROC:
					values = new Object[] { srcLog.getSource(),
							srcLog.getDataTime(), RunStatus.PROC_RUN_SUCCESS,IsValid.VALID};
					ckRes = databaseDao.checkExist("proc_schedule_log", procFileds,
							values);
					break;
				default:
					ckRes = 0;
					break;
				}
				if (ckRes == 1) {
					srcLog.setCheckFlg(1);
					dataMap.clear();
					dataMap.put("seqno", runInfo.getSeqno());
					dataMap.put("source", srcLog.getSource());
					dataMap.put("check_flag", 1);
					databaseDao.update("proc_schedule_source_log", "seqno,source",
							dataMap);
					iter.remove();
				}
			}
			// 检查所有状态是否满足
			if (srcLst.isEmpty()) {
				if (taskService.updateState(runInfo,
						RunStatus.CHECK_DEPEND_SUCCESS)) {
					LOG.info("task[{},{}] check depend success",
							runInfo.getSeqno(), runInfo.getProcName());
					MemCache.SRC_LOG_MAP.remove(runInfo.getSeqno());
					//MemCache.RUNMODE_TASK_MAP.put(runInfo.getSeqno(), runInfo);
				}
			}
		} catch (Exception e) {
			LOG.info("the database occur an error!");
			LOG.error("", e);
		}
		latch.countDown();
	}

}
