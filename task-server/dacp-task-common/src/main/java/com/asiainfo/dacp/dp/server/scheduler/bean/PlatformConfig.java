package com.asiainfo.dacp.dp.server.scheduler.bean;
/**
 * roc_schedule_paltform
 * agent组配置信息
 * @author wybhlm
 *
 */
public class PlatformConfig {
	private String platform;
	private Integer ips;
	private Integer curips;
	public PlatformConfig(){
		this.ips=1000;
		this.curips=0;
	}
	public String getPlatform() {
		return platform;
	}
	public void setPlatform(String platform) {
		this.platform = platform;
	}
	public Integer getIps() {
		return ips==null?1000:ips;
	}
	public void setIps(Integer ips) {
		this.ips = ips;
	}
	public Integer getCurips() {
		return curips==null?0:ips;
	}
	public void setCurips(Integer curips) {
		this.curips = curips;
	}
	
	
}
