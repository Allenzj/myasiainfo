package com.asiainfo.dp.task.agentExectue;

import java.io.Serializable;

public class Task implements Serializable {
	private static final long serialVersionUID = 1L;
	private String seqno;
	private String runMsg;
	private String cmdLine;
	private String sendFlag;
	private String pid;
	private String startTime;
	private String endTime;
	private String agentCode;
	private String checkCount;
	private String exitValue;
	
	public String getRunMsg() {
		return runMsg;
	}

	public void setRunMsg(String runMsg) {
		this.runMsg = runMsg;
	}

	public int getCheckCount() {
		checkCount = checkCount==null||"".equals(checkCount)?"0":checkCount;
		return Integer.parseInt(checkCount);
	}

	public void setCheckCount(String checkCount) {
		this.checkCount = checkCount;
	}

	public void setAgentCode(String agentCode) {
		this.agentCode = agentCode;
	}

	public String getAgentCode() {
		return agentCode;
	}

	public String getSeqno() {
		return seqno;
	}

	public void setSeqno(String seqno) {
		this.seqno = seqno;
	}

	public String getPid() {
		return pid;
	}

	public void setPid(String pid) {
		this.pid = pid;
	}

	public String getCmdLine() {
		return cmdLine;
	}

	public void setCmdLine(String cmdLine) {
		this.cmdLine = cmdLine;
	}

	public String getExitValue() {
		return exitValue;
	}

	public void setExitValue(String exitValue) {
		this.exitValue = exitValue;
	}

	public String getStartTime() {
		return startTime;
	}

	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}

	public String getEndTime() {
		return endTime;
	}

	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}

	public String getSendFlag() {
		return sendFlag;
	}

	public void setSendFlag(String sendFlag) {
		this.sendFlag = sendFlag;
	}
}
