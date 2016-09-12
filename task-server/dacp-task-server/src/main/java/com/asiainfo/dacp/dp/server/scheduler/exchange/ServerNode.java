package com.asiainfo.dacp.dp.server.scheduler.exchange;

public class ServerNode {
	private String serverId;
	private String hostName;
	private String deployPath;
	private Integer serverStatus;
	private String statusTime;
	private String serverName;
	public String getServerId() {
		return serverId;
	}
	public void setServerId(String serverId) {
		this.serverId = serverId;
	}
	public String getHostName() {
		return hostName;
	}
	public void setHostName(String hostName) {
		this.hostName = hostName;
	}
	public String getDeployPath() {
		return deployPath;
	}
	public void setDeployPath(String deployPath) {
		this.deployPath = deployPath;
	}
	public Integer getServerStatus() {
		return serverStatus;
	}
	public void setServerStatus(Integer serverStatus) {
		this.serverStatus = serverStatus;
	}
	public String getServerName() {
		return serverName;
	}
	public void setServerName(String serverName) {
		this.serverName = serverName;
	}
	public String getStatusTime() {
		return statusTime;
	}
	public void setStatusTime(String statusTime) {
		this.statusTime = statusTime;
	}
	
}
