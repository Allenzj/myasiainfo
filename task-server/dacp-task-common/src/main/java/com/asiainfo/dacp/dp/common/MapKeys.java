package com.asiainfo.dacp.dp.common;

public class MapKeys {
	/***************************** 所有执行任务接收和发送字典 *****************************/

	/********************************* 接收任务字典 *********************************/
	/** 任务编号 */
	public final static String MSG_ID = "msgId";
	/** 任务类型 */
	public final static String MSG_TYPE = "msgType";// taskTypeProc,taskTypeFunc,taskTypeHeart
	/** 执行脚本类型 */
	public final static String SCRIPT_NAME = "ScriptName";
	/** 日期参数 */
	public final static String PROC_DATE_VAR = "procDateVar";
	/** 执行状态 */
	public final static String PROC_STATUS = "procStatus";
	/** 执行状态描述 */
	public final static String PROC_LOG = "procLog";
	/** 平台程序 */
	public final static String TASK_TYPE_PROC = "taskTypeProc";
	/** 平台函数 */
	public final static String TASK_TYPE_FUNC = "taskTypeFunc";
	/** 心跳检测 */
	public final static String TASK_TYPE_HEART = "taskTypeHeart";
	/** agent名 */
	public final static String AGENT_CODE = "agentCode";
	/** 心跳检测 */
	public final static String IS_ALIVE = "isAlive";
	/** 进程pid */
	public final static String PROC_PID = "procPid";
    /**执行命令*/
	public final static String CMD_LINE = "commandLine";
	/**dp程序出现错误步骤号*/
	public final static String PROC_RETURN_CODE="procReturnCode";
	/**程序名*/
	public final static String PROC_NAME="procName";
	/**程序路径*/
	public final static String PATH="path";
}
