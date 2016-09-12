package com.asiainfo.dacp.dp.server.scheduler.type;

public enum RunFreq {
	/*** 年 */
	year,
	/*** 天 */
	day,
	/*** 周 */
	week,
	/*** 月 */
	month,
	/*** 月末 */
	month_last,
	/*** 自定义 */
	custom,
	/*** 手工任务 */
	manual,
	/***小时*/
	hour,
	/***分钟*/
	minute;

}
