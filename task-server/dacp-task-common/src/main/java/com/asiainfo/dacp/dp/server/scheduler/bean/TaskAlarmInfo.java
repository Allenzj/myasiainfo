package com.asiainfo.dacp.dp.server.scheduler.bean;

/**
 * 任务告警信息
 * proc_schedule_alarm_info
 * @author wybhlm
 *
 */
public class TaskAlarmInfo {

	private String xmlid;
	/*** 程序id */
	private String procXmlid;
	/*** 程序名[英文] */
	private String procName;
	/*** 程序运行周期 */
	private String runFreq;
	/** 告警类型 */
	private String alarmType;
	/** 告警截时间cron表达式 */
	private String dueTimeCron;
	/** 告警批次偏移量 */
	private String offSet;
	/** 最大发送次数 */
	private String maxSendCount;
	/** 发送间隔时间 */
	private String intervalTime;
	/** 是否生效 */
	private String isValid;
	/** 是否处理 */
	private String flag;
	
	
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
	public String getRunFreq() {
		return runFreq;
	}
	public void setRunFreq(String runFreq) {
		this.runFreq = runFreq;
	}
	public String getAlarmType() {
		return alarmType;
	}
	public void setAlarmType(String alarmType) {
		this.alarmType = alarmType;
	}
	public String getDueTimeCron() {
		return dueTimeCron;
	}
	public void setDueTimeCron(String dueTimeCron) {
		this.dueTimeCron = dueTimeCron;
	}
	public String getOffSet() {
		return offSet;
	}
	public void setOffSet(String offSet) {
		this.offSet = offSet;
	}
	public String getMaxSendCount() {
		return maxSendCount;
	}
	public void setMaxSendCount(String maxSendCount) {
		this.maxSendCount = maxSendCount;
	}
	public String getIntervalTime() {
		return intervalTime;
	}
	public void setIntervalTime(String intervalTime) {
		this.intervalTime = intervalTime;
	}
	public String getIsValid() {
		return isValid;
	}
	public void setIsValid(String isValid) {
		this.isValid = isValid;
	}
	public String getFlag() {
		return flag;
	}
	public void setFlag(String flag) {
		this.flag = flag;
	}
}
