package com.asiainfo.dacp.dp.model;

import java.util.List;
import java.util.Map;

public class TaskInfoDtoForBJCT {
	private String procName;//程序名称
	private String path;//程序路径
	private String user;
	private String procId;
	private String type;
	public String getProcName() {
		return procName;
	}
	public void setProcName(String procName) {
		this.procName = procName;
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
	public String getPath() {
		return path;
	}
	public void setPath(String path) {
		this.path = path;
	}
	public String getUser() {
		return user;
	}
	public void setUser(String user) {
		this.user = user;
	}
	
}
