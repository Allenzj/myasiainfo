package com.asiainfo.dacp.dp.server.scheduler.bean;

/**
 * 依赖表或者程序配置信息
 * @author wybhlm
 *
 */
public class SourceObj {
	/**程序*/
	private String target;
	/**源*/
	private String source;
	/**源类型*/
	private String sourcetype;
	/**源周期*/
	private String sourcefreq;
	/***流程号*/
	private String flowcode;
	/***指定依赖时间批次*/
	private String sourceAppoint;
	
	public String getSourceAppoint() {
		return sourceAppoint;
	}
	public void setSourceAppoint(String sourceAppoint) {
		this.sourceAppoint = sourceAppoint;
	}
	public String getFlowcode() {
		return flowcode;
	}
	public void setFlowcode(String flowCode) {
		this.flowcode = flowCode;
	}	
	public String getTarget() {
		return target;
	}
	public void setTarget(String target) {
		this.target = target;
	}
	public String getSource() {
		return source;
	}
	public void setSource(String source) {
		this.source = source;
	}
	public String getSourcetype() {
		return sourcetype;
	}
	public void setSourcetype(String sourcetype) {
		this.sourcetype = sourcetype;
	}
	public String getSourcefreq() {
		return sourcefreq;
	}
	public void setSourcefreq(String sourcefreq) {
		this.sourcefreq = sourcefreq;
	}
	
}
