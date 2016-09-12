package com.asiainfo.dacp.dp.common;

public class RunStatus {
	/*** 重做 */
	public final static int REDO = 0;
	/*** 创建作业 */
	public final static int CREATE_TASK = 1;
	/*** 检查依赖成功 */
	public final static int CHECK_DEPEND_SUCCESS = 2;
	/*** 检查并发量成功 */
	public final static int CHECK_IPS_SUCCESS = 3;
	/*** 发送Agent成功 */
	public final static int SEND_TO_MQ = 4;
	/***等待中断*/
	public final static int WAIT_FINISH=-5;
	/*** 开始执行*/
	public final static int PROC_RUNNING = 5;
	/*** 执行成功 */
	public final static int PROC_RUN_SUCCESS = 6;
	/***失效*/
	public final static int INVALID=-6;
	/***计划任务*/
	public final static int PLAN_TASK= -7;
	/*** 执行失败 */
	public final static int PROC_RUN_FAIL = 51;
	/*** 执行模式状态*/
	public final static class RUNMODE{
		/**同任务名的相同批次的任务在执行*/
		public final static int SAME = 201;
		/**同任务名的程序在执行*/
		public final static int MUT = 202;
		/**上一批次任务未执行*/
		public final static int PRE = 203;	
		/**未知异常*/
		public final static int EXCEPTION = 204;
		/**是否允许执行*/
		public final static int ISALLOW=205;
		/**是否关闭*/
		public final static int ONOFF=206;
	}
	public final static class AGENT{
		/**agent 挂了*/
		public final static int DOWN = 301;
		/**agent 满了*/
		public final static int FULL = 302;
		/**找不到agent信息*/
		public final static int NEED = 303;
		/**未知异常*/
		public final static int EXCEPTION = 304;
		/**发送失败*/
		public final static int FAIL = 305;
		/**立即执行*/
		public final static int READY =306;
		/**最早执行时间未到*/
		public final static int STAY =307;
	}
//是否有效
	public final static class IsValid{
		public final static int VALID=0;
		/**状态是否有效*/
		public final static int VALID_FLAG=0;
		/**批次任务是否允许执行*/
		public final static int IS_ALLOW=0;
	}
	public final static class ONOFF{
		//是否根据小周期生成大周期数据，1为开启
		public final static String SCANEVENTTYPE="1";
	}
/**
 * 系统运行错误代码
 * @author Silence
 *
 */
	public final static class ERRCODE{
		/**配置错误*/
		public final static int CONFIGERR = 1001;
		/**定时调度*/
		public final static int TIMETRIGGER = 1002;
		/**更新数据异常*/
		public final static int UPDATEEXCEPTION = 1003;
		/**连接消息服务器异常*/
		public final static int LINKEXCEPTION = 1004;
		
	}
	
	public final static class AlarmType{
		/**到点未完成*/
		public final static int PROC_LATE = 1;
		/**程序错误*/
		public final static int PROC_ERROR = 2;
	}
}