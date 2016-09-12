package com.asiainfo.dacp.dp.server.scheduler.cache;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import com.asiainfo.dacp.dp.server.scheduler.bean.AgentIps;
import com.asiainfo.dacp.dp.server.scheduler.bean.SourceLog;
import com.asiainfo.dacp.dp.server.scheduler.bean.SourceObj;
import com.asiainfo.dacp.dp.server.scheduler.bean.TargetObj;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskConfig;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.type.DBType;

public class MemCache {
	public static DBType DBTYPE;
	/** 程序基本配置 */
	public final static Map<String, TaskConfig> PROC_MAP = new ConcurrentHashMap<String, TaskConfig>();
	/** 程序目标配置信息 */
	public final static Map<String, List<TargetObj>> TARGET_MAP = new ConcurrentHashMap<String, List<TargetObj>>();
	/** 程序源信息配置信息 */
	public final static Map<String, List<SourceObj>> SOURCE_MAP = new ConcurrentHashMap<String, List<SourceObj>>();
	/** 运行信息缓存 */
	public static Map<String, TaskLog> TASK_MAP = new ConcurrentHashMap<String, TaskLog>();
	/** 依赖检测信息 */
	public final static Map<String, List<SourceLog>> SRC_LOG_MAP = new ConcurrentHashMap<String, List<SourceLog>>();
	/** 数据的后续任务 */
	public final static Map<String, List<TaskConfig>> DATA_NEXT_PROC_MAP = new ConcurrentHashMap<String, List<TaskConfig>>();
	/** 数据的后续所有任务包括时间触发 */
	public final static Map<String, List<TaskConfig>> DATA_NEXT_ALL_PROC_MAP = new ConcurrentHashMap<String, List<TaskConfig>>();
	/** 程序的后续任务 */
	public final static Map<String, List<TaskConfig>> PROC_NEXT_PROC_MAP = new ConcurrentHashMap<String, List<TaskConfig>>();
	/** 程序的后续所有任务包括时间触发 */
	public final static Map<String, List<TaskConfig>> PROC_NEXT_ALL_PROC_MAP = new ConcurrentHashMap<String, List<TaskConfig>>();
	/** 重做队列缓存 **/
	public final static Map<String, TaskLog> REDO_TASK_MAP = new ConcurrentHashMap<String, TaskLog>();
	/** 依赖检测队列缓存 **/
	public final static Map<String, TaskLog> DEPEND_TASK_MAP = new ConcurrentHashMap<String, TaskLog>();
	/**临时调度的后续任务*/
	public final static Map<String,List<TaskConfig>> INTERIM_PROC_NEXR_PROC_MAP= new ConcurrentHashMap<String, List<TaskConfig>>();
	/** 执行模式检测队列缓存 **/
	public final static Map<String, TaskLog> RUNMODE_TASK_MAP = new ConcurrentHashMap<String, TaskLog>();
	/** 并发检测队列缓存 */
	public final static Map<String, TaskLog> IPS_TASK_MAP = new ConcurrentHashMap<String, TaskLog>();
	/** 触发队列缓存 */
	public final static Map<String, TaskLog> TRIGGER_TASK_MAP = new ConcurrentHashMap<String, TaskLog>();
	/** agent并发情况缓存 */
	public final static Map<String,AgentIps> AGENT_IPS_MAP = new ConcurrentHashMap<String, AgentIps>();
	public final static Map<String,TaskLog> SEND_TASK_MAP = new ConcurrentHashMap<String, TaskLog>();
	
	
	

	public static synchronized Map<String, TaskConfig> getProcMap(String key) {
		
		
		return PROC_MAP;
	}
	
	public static synchronized Map<String, TaskConfig> addProcMap(String key) {
		
		
		return PROC_MAP;
	}
	
	/**
	 * @author FengL
	 * @category 更新插入 TARGET_MAP
	 * @param key
	 * @return the List<TargetObj>
	 */
//	public static void addTargetMapByKey(String key,List<TargetObj> targetObjList) {
//		if(TARGET_MAP.get(key)!=null)
//			TARGET_MAP.putIfAbsent(key, targetObjList);
//		else
//			TARGET_MAP.replace(key, targetObjList);
//			//TARGET_MAP.put(key, targetObjList);
//	}	
	/**
	 * @author FengL
	 * @category 通过job xmlid值返回后续触发
	 * @param key
	 * @return the List<TargetObj>
	 */
	public static synchronized void delTargetMapByKey(String key) {
		if(TARGET_MAP.get(key)!=null)
		 TARGET_MAP.remove(key);
	}	

	/**
	 * @author FengL
	 * @category 通过job xmlid值返回后续触发
	 * @param key
	 * @return the List<TargetObj>
	 */
	public static synchronized List<TargetObj> getTargetMapByKey(String key) {
		return TARGET_MAP.get(key);
	}

	public static void clearAllCache() {
		MemCache.PROC_MAP.clear();
		MemCache.TARGET_MAP.clear();
		MemCache.SOURCE_MAP.clear();
		MemCache.PROC_NEXT_PROC_MAP.clear();
		MemCache.PROC_NEXT_ALL_PROC_MAP.clear();
		MemCache.INTERIM_PROC_NEXR_PROC_MAP.clear();
		MemCache.TASK_MAP.clear();
		MemCache.SRC_LOG_MAP.clear();
		MemCache.DATA_NEXT_PROC_MAP.clear();
		MemCache.DATA_NEXT_ALL_PROC_MAP.clear();
		MemCache.REDO_TASK_MAP.clear();
		MemCache.DEPEND_TASK_MAP.clear();
		MemCache.RUNMODE_TASK_MAP.clear();
		MemCache.TRIGGER_TASK_MAP.clear();
		MemCache.IPS_TASK_MAP.clear();
		MemCache.AGENT_IPS_MAP.clear();
		MemCache.SEND_TASK_MAP.clear();
	}

	public static void clearTmpCache() {
		MemCache.INTERIM_PROC_NEXR_PROC_MAP.clear();
		MemCache.REDO_TASK_MAP.clear();
		MemCache.DEPEND_TASK_MAP.clear();
		MemCache.RUNMODE_TASK_MAP.clear();
		MemCache.TRIGGER_TASK_MAP.clear();
		MemCache.IPS_TASK_MAP.clear();
		MemCache.SEND_TASK_MAP.clear();
	}

	public static void clearRunInfoCache(String seqno) {
		MemCache.SRC_LOG_MAP.remove(seqno);
		MemCache.TASK_MAP.remove(seqno);
		MemCache.REDO_TASK_MAP.remove(seqno);
		MemCache.DEPEND_TASK_MAP.remove(seqno);
		MemCache.RUNMODE_TASK_MAP.remove(seqno);
		MemCache.TRIGGER_TASK_MAP.remove(seqno);
		MemCache.IPS_TASK_MAP.remove(seqno);
		MemCache.SEND_TASK_MAP.clear();
	}
	/**
	 * 删除程序缓存
	 * @param procName
	 */
	public static void clearProcCache(String xmlid){
		PROC_MAP.remove(xmlid);
		PROC_NEXT_PROC_MAP.remove(xmlid);
		SOURCE_MAP.remove(xmlid);
		TARGET_MAP.remove(xmlid);
	}
}
