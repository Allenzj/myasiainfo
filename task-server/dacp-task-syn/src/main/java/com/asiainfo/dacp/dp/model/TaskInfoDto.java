package com.asiainfo.dacp.dp.model;

import java.util.List;
import java.util.Map;

public class TaskInfoDto {
	private String procName;//程序名称
	private String procCnName;//程序中文名
	private String topicName;//主题
	private String levelVal;//层次
	private String procType;//程序类型
	private String runFreq;//运行周期
	private String path;//程序路径
	private String platform;//接入平台
//	private String agentCode;//执行主机
	private List<Map<String,Object>> params;//执行参数
	private String userName;
	private String procId;
	private String type;
	public String getProcName() {
		return procName;
	}
	public void setProcName(String procName) {
		this.procName = procName;
	}
	public String getProcCnName() {
		return procCnName;
	}
	public void setProcCnName(String procCnName) {
		this.procCnName = procCnName;
	}
	
//	public List<ParamsDto> getParams() {
//		return params;
//	}
//	public void setParams(List<ParamsDto> params) {
//		this.params = params;
//	}
	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}
	public String getProcId() {
		return procId;
	}
	public void setProcId(String procId) {
		this.procId = procId;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getTopicName() {
		return topicName;
	}
	public void setTopicName(String topicName) {
		this.topicName = topicName;
	}
	public String getLevelVal() {
		return levelVal;
	}
	public void setLevelVal(String levelVal) {
		this.levelVal = levelVal;
	}
	public String getProcType() {
		return procType;
	}
	public void setProcType(String procType) {
		this.procType = procType;
	}
	public String getRunFreq() {
		return runFreq;
	}
	public void setRunFreq(String runFreq) {
		this.runFreq = runFreq;
	}
	public String getPath() {
		return path;
	}
	public void setPath(String path) {
		this.path = path;
	}
	public String getPlatform() {
		return platform;
	}
	public void setPlatform(String platform) {
		this.platform = platform;
	}
	
//	public String getAgentCode() {
//		return agentCode;
//	}
//	public void setAgentCode(String agentCode) {
//		this.agentCode = agentCode;
//	}
	
}
