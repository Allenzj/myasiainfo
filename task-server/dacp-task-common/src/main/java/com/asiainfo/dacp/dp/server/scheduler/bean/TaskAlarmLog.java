package com.asiainfo.dacp.dp.server.scheduler.bean;

/**
 * 任务告警信息
 * proc_schedule_alarm_info
 * @author wybhlm
 *
 */
public class TaskAlarmLog {

	private String xmlid;
	/*** 程序id */
	private String procXmlid;
	/*** 程序名[英文] */
	private String procName;
	/*** 程序日期批次] */
	private String procDateArgs;
	/** 告警类型 */
	private String alarmType;
	/** 告警内容 */
	private String alarmContent;
	/** 告警时间 */
	private String alarmTime;
	
	
	public String getXmlid() {
		return xmlid;
	}
	public void setXmlid(String xmlid) {
		this.xmlid = xmlid;
	}
	public String getProcXmlid() {
		return procXmlid;
	}
	public void setProcXmlid(String procXmlid) {
		this.procXmlid = procXmlid;
	}
	public String getProcName() {
		return procName;
	}
	public void setProcName(String procName) {
		this.procName = procName;
	}
	public String getProcDateArgs() {
		return procDateArgs;
	}
	public void setProcDateArgs(String procDateArgs) {
		this.procDateArgs = procDateArgs;
	}
	public String getAlarmType() {
		return alarmType;
	}
	public void setAlarmType(String alarmType) {
		this.alarmType = alarmType;
	}
	public String getAlarmContent() {
		return alarmContent;
	}
	public void setAlarmContent(String alarmContent) {
		this.alarmContent = alarmContent;
	}
	public String getAlarmTime() {
		return alarmTime;
	}
	public void setAlarmTime(String alarmTime) {
		this.alarmTime = alarmTime;
	}
}
