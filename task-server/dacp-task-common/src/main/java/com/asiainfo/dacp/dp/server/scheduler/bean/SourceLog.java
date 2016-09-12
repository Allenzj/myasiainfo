package com.asiainfo.dacp.dp.server.scheduler.bean;
/**
 * proc_schedule_source_log表
 * @author wybhlm
 *
 */
public class SourceLog {
	private String seqno;
	private String procName;
	private String source;
	private String sourceType;
	private String dataTime;
	private Integer checkFlg;
	/***流程号*/
	private String flowcode;
	private String dateArgs;
	public String getFlowcode() {
		return flowcode;
	}
	public void setFlowcode(String flowCode) {
		this.flowcode = flowCode;
	}
	public String getDateArgs() {
		return dateArgs;
	}
	public void setDateArgs(String dateArgs) {
		this.dateArgs = dateArgs;
	}
	public SourceLog() {
		checkFlg = 0;
	}
	public String getSeqno() {
		return seqno;
	}
	public void setSeqno(String seqno) {
		this.seqno = seqno;
	}
	
	public String getSourceType() {
		return sourceType;
	}
	
	public String getProcName() {
		return procName;
	}
	public void setProcName(String procName) {
		this.procName = procName;
	}
	public void setCheckFlg(Integer checkFlg) {
		this.checkFlg = checkFlg;
	}
	public void setSourceType(String sourceType) {
		this.sourceType = sourceType;
	}
	public String getSource() {
		return source;
	}
	public void setSource(String source) {
		this.source = source;
	}
	public String getDataTime() {
		return dataTime;
	}
	public void setDataTime(String dataTime) {
		this.dataTime = dataTime;
	}
	public int getCheckFlg() {
		return checkFlg==null?1:(int)checkFlg;
	}
	public void setCheckFlg(int checkFlg) {
		this.checkFlg = checkFlg;
	}
	
}