package com.asiainfo.dacp.dp.server.scheduler.bean;

/**
 * 输出表依赖配置信息
 * 
 * @author wybhlm
 *
 */
public class TargetObj {
	/** 程序或者数据 */
	private String source;
	/** 程序周期 */
	private String sourcefreq;
	/** 目标 */
	private String target;
	/** 目标类型 */
	private String targettype;
	/** 目标周期 */
	private String targetfreq;
	/** 质量检测 */
	private Integer needDqCheck;
	/*** 流程号 */
	private String flowcode;
	/*** 触发类型 */
	private String triggerType;
	/*** 指定具体依赖时间批次 */
	private String sourceAppoint;

	public String getSourceAppoint() {
		return sourceAppoint;
	}

	public void setSourceAppoint(String sourceAppoint) {
		this.sourceAppoint = sourceAppoint;
	}

	public String getSourcefreq() {
		return sourcefreq;
	}

	public void setSourcefreq(String sourcefreq) {
		this.sourcefreq = sourcefreq;
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

	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
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

	public Integer getNeedDqCheck() {
		return needDqCheck;
	}

	public void setNeedDqCheck(Integer needDqCheck) {
		this.needDqCheck = needDqCheck;
	}

	public TargetObj() {
		needDqCheck = 0;
	}

	public String getTriggerType() {
		return triggerType;
	}

	public void setTriggerType(String triggerType) {
		this.triggerType = triggerType;
	}

}
