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
	

}
