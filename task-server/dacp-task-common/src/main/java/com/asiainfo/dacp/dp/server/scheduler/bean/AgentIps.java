package com.asiainfo.dacp.dp.server.scheduler.bean;

import com.asiainfo.dacp.dp.common.RunStatus;

/**
 * agent并发信息
 * @author wybhlm
 *
 */
public class AgentIps {
	private String agentCode;
	private Integer ips;
	private Integer curips;
	private Integer agentStatus;
	private String scriptPath;
	private String statusChgtime;
	private String platform;
	public AgentIps(){
		curips = 0;
		ips = 100;
	}
	public String getScriptPath() {
		return scriptPath;
	}
	public void setScriptPath(String scriptPath) {
		this.scriptPath = scriptPath;
	}
	public String getAgentCode() {
		return agentCode;
	}
	public void setAgentCode(String agentCode) {
		this.agentCode = agentCode;
	}
	public Integer getIps() {
		return ips==null?0:ips;
	}
	public synchronized void setIps(Integer ips) {
		this.ips = ips;
	}
	public synchronized Integer getCurips() {
		return curips==null?0:curips;
	}
	public synchronized void addIps(int offset) {
		this.curips = this.curips==null?0:this.curips;
		this.curips = curips+offset;
	}
	public synchronized Integer getAgentStatus() {
		return agentStatus==null?0:agentStatus;
	}
	public synchronized void setAgentStatus(Integer agentStatus) {
		this.agentStatus = agentStatus;
	}
	public void setCurips(Integer curips) {
		this.curips = curips==null?0:curips;
	}
	public String getStatusChgtime() {
		return statusChgtime==null?"1999-01-17 17:00":statusChgtime;
	}
	public void setStatusChgtime(String statusChgtime) {
		this.statusChgtime = statusChgtime;
	}
	public String getPlatform() {
		return platform;
	}
	public void setPlatform(String platform) {
		this.platform = platform;
	}
}
