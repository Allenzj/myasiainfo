package com.asiainfo.dacp.dp.server.scheduler.bean;

/**
 * transdatamap_design 根据输出表建立后续任务索引
 * 
 * @author wybhlm
 *
 */
public class Relationship {
	private String source;
	private String sourcetype;
	private String sourcefreq;
	private String target;
	private String targettype;
	private String targetfreq;
	private String triggerType;
	private String sourceAppoint;//指定依赖具体时间批次

	public String getSourceAppoint() {
		return sourceAppoint;
	}

	public void setSourceAppoint(String sourceAppoint) {
		this.sourceAppoint = sourceAppoint;
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

	public String getTarget() {
		return target;
	}

	public void setTarget(String target) {
		this.target = target;
	}

	public String getTargettype() {
		return targettype;
	}

	public void setTargettype(String targettype) {
		this.targettype = targettype;
	}

	public String getTargetfreq() {
		return targetfreq;
	}

	public void setTargetfreq(String targetfreq) {
		this.targetfreq = targetfreq;
	}

	public String getTriggerType() {
		return triggerType;
	}

	public void setTriggerType(String triggerType) {
		this.triggerType = triggerType;
	}

}
