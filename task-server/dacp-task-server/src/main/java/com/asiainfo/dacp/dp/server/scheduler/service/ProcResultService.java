package com.asiainfo.dacp.dp.server.scheduler.service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import com.asiainfo.dacp.dp.common.MapKeys;
import com.asiainfo.dacp.dp.common.RunStatus;
import com.asiainfo.dacp.dp.message.DpHandler;
import com.asiainfo.dacp.dp.message.DpMessage;
import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;
import com.asiainfo.dacp.dp.server.scheduler.bean.MetaLog;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.type.MsgType;
import com.asiainfo.dacp.dp.server.scheduler.type.RunFreq;
import com.asiainfo.dacp.dp.server.scheduler.utils.ConvertUtils;
import com.asiainfo.dacp.dp.server.scheduler.utils.TimeUtils;
/**
 * 接收消息服务
 * @author Silence
 *
 */
public class ProcResultService implements DpHandler {
	/*** 输出表操作 */
	@Autowired
	private DatabaseDao dbDao;
	@Autowired
	private TaskService taskService;
	private static Logger LOG = LoggerFactory
			.getLogger(ProcResultService.class);
	/*** 缓存线程池 **/
	private ExecutorService pool = Executors.newCachedThreadPool();
	/*** 任务处理 */
	public Object onMessage(final  Object _msgObj) {
		pool.execute(new Runnable() {
			public void run() {
				try {
					if (_msgObj == null) {
						return;
					}
						DpMessage msgObj=(DpMessage) _msgObj;
					Map<String, String> reMap = msgObj.getFirstMap();
					if (reMap == null) {
						return;
					}
					String msgType = msgObj.getMsgType();
					MsgType _msgType = MsgType.valueOf(msgType);
					switch (_msgType) {
					case taskTypeHeart:
						// 变更心跳检测信息
						taskService.updateAgentStatus(msgObj.getFirstMap());
						break;
					case taskTypeFunc:// 平台函数
					case taskTypeProc:// 平台程序
					case SCOPE://指标组任务
						String seqno = msgObj.getMsgId();
						String _status = reMap.get(MapKeys.PROC_STATUS);
						if (_status == null) {
							LOG.info("the status of task[{}] was null ", seqno);
							return;
						}
						int status = Integer.parseInt(_status);
						TaskLog runInfo = MemCache.TASK_MAP.get(seqno);
						if (runInfo == null) {
							LOG.info("task[{}] was deleted or ignore", seqno);
							return;
						}
						if ((int) runInfo.getQueueFlag() == 1) { 
							LOG.info("task[{}] was dequeued, the result is invalid",runInfo.getTaskId());
							return;
						}
						runInfo.setStatusTime(TimeUtils
								.dateToString2(new Date()));
						if (status == RunStatus.PROC_RUNNING) {
							LOG.info("task[{}] is running! ",runInfo.getTaskId());
							if ((int) runInfo.getTaskState() == RunStatus.WAIT_FINISH) {
								return;
							}
							runInfo.setExecTime(TimeUtils
									.dateToString2(new Date()));
							runInfo.setPid(reMap.get(MapKeys.PROC_PID));
							taskService.updateState(runInfo, status);
						} else if (status == RunStatus.PROC_RUN_SUCCESS) {
							// 保存执行结果,保存程序信息
							runInfo.setEndTime(TimeUtils
									.dateToString2(new Date()));
							if (StringUtils.equals(runInfo.getRunFreq(),
									RunFreq.manual.name())) {
								runInfo.setQueueFlag(1);
								runInfo.setTriggerFlag(1);
							} 
							LOG.info("task[{},{}] run success! ",
									runInfo.getSeqno(), runInfo.getProcName());
							// 插入脚本日志
							String procLog = reMap.get(MapKeys.PROC_LOG);
							taskService.insertAppLog(runInfo, procLog);
							// 入库
							if (runInfo.getTaskState() == RunStatus.WAIT_FINISH) {//如果是等待终止，更新并失效
								taskService.updateState(runInfo,
										RunStatus.PROC_RUN_SUCCESS);
								//taskService.deleteTask(runInfo);//并不删除日志
								taskService.invalidTask(runInfo);//失效该任务
							}else{
								/**任务成功，修改错误步骤号为0*/
								runInfo.setReturnCode(0);
								taskService.updateState(runInfo,
										RunStatus.PROC_RUN_SUCCESS);
							}
						} else {
							// 加入数据库日志
							String procLog = reMap.get(MapKeys.PROC_LOG);
							// 插入脚本日志
							taskService.insertAppLog(runInfo, procLog);
							LOG.info("task[{}] run fail!",runInfo.getTaskId());
							// 持久化到数据库
							runInfo.setEndTime(TimeUtils.dateToString2(new Date()));
							if (StringUtils.equals(runInfo.getRunFreq(),
									RunFreq.manual.name())) {
								runInfo.setQueueFlag(1);
								runInfo.setTriggerFlag(1);
							} 
							runInfo.setReturnCode(StringUtils.isEmpty(reMap.get(MapKeys.PROC_RETURN_CODE))?0:Integer.valueOf(reMap.get(MapKeys.PROC_RETURN_CODE)));
							if (runInfo.getTaskState() == RunStatus.WAIT_FINISH) {//如果是等待终止，更新并失效
								taskService.updateState(runInfo, status);
								//taskService.deleteTask(runInfo);//并不删除日志
								taskService.invalidTask(runInfo);//失效该任务
							}else{//如果是正常的，则直接更新状态
								taskService.updateState(runInfo, status);
							}
						}
						break;
					case KILL_PROC:
						String kill_seqno = msgObj.getMsgId();
						LOG.info("task[{}] was kill", kill_seqno);
						TaskLog kill_runInfo = MemCache.TASK_MAP.get(kill_seqno);
						if (kill_runInfo == null) {
							LOG.info("task[{}] was deleted or ignore", kill_seqno);
							return;
						}
						kill_runInfo.setQueueFlag(1);
						kill_runInfo.setRetryNum(100);
						taskService.updateState(kill_runInfo, 51);
						break;
					case INTER:// 割接数据或者接口数据
						Map<String, String> dataMap = msgObj.getFirstMap();
						taskService.resetDataTime(dataMap);
						if (!dataMap.isEmpty()) {
							MetaLog targetLog = ConvertUtils
									.convertToMetaLog(dataMap);

							List<MetaLog> targetLogList = new ArrayList<MetaLog>();
							targetLogList.add(targetLog);
							if (StringUtils.isEmpty(targetLog.getProcName())) {
								/* 删除历史数据 */
								dbDao.deleteLogHis("proc_schedule_meta_log",
										targetLog.getTarget(),
										targetLog.getDataTime());
								dbDao.saveTargertLog(targetLogList,
										"proc_schedule_meta_log");
							} else {
								dbDao.saveTargertLog(targetLogList,
										"proc_schedule_target_log");
							}
							/* 分发数据 */
							taskService.pushMessage(targetLogList);//重庆版本需要分发
						}
						break;
					/*
					case RESAER_FLAG:
						Map<String, String> returnMap = msgObj.getFirstMap();
						if (returnMap == null) {
							return;
						}
						String restartAgentName = returnMap.get(MapKeys.AGENT_CODE);
						//将在agent上执行的任务置为失败
						for(TaskLog task:MemCache.TASK_MAP.values()){
							int oldTaskState = task.getTaskState();
							String agentCode = task.getAgentCode();
							String  error=String.format("task[%s]在agent[%s]上执行失败:agent被重启", task.getTaskId(),agentCode);
							if(StringUtils.equals(restartAgentName, agentCode)&&oldTaskState==RunStatus.PROC_RUNNING){
								taskService.setTaskError(task, error);
							}
						}
						break;
					*/
					default:
						break;
					}
				} catch (Exception e) {
					LOG.error("", e);
				}
			}
		});
		return null;
	}
}
