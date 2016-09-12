//package com.asiainfo.dacp.dp.server.scheduler.exchange;
//
//import org.apache.commons.lang.StringUtils;
//
//public class ExchangeConfig {
//	private String serverGroup;
//	private String majorServerName;
//	private  Integer majorServerStatus;
//	private String majorStatusChgTime;
//	private String minorServerName;
//	private Integer minorServerStatus;
//	private String minorStatusChgTime;
//	private String switchTimestamp;
//	private Integer checkInterval;
//	private Integer heartbeatInterval;
//	public Integer getHeartbeatInterval() {
//		return heartbeatInterval==null?5:heartbeatInterval;
//	}
//	public void setHeartbeatInterval(Integer heartbeatInterval) {
//		this.heartbeatInterval = heartbeatInterval;
//	}
//	public String getServerGroup() {
//		return serverGroup;
//	}
//	public void setServerGroup(String serverGroup) {
//		this.serverGroup = serverGroup;
//	}
//	public String getMajorServerName() {
//		return majorServerName;
//	}
//	public void setMajorServerName(String majorServerName) {
//		this.majorServerName = majorServerName;
//	}
//	public Integer getMajorServertatus() {
//	 	return majorServerStatus==null?1:majorServerStatus;
//	}
//	public void setMajorServertatus(Integer majorServerStatus) {
//		this.majorServerStatus = majorServerStatus;
//	}
//	public String getMajorStatusChgTime() {
//		return majorStatusChgTime==null?"201501010000":majorStatusChgTime;
//	}
//	public void setMajorStatusChgTime(String majorStatusChgTime) {
//		this.majorStatusChgTime = majorStatusChgTime==null?"2015-01-01 00:00":majorStatusChgTime;
//	}
//	public String getMinorServerName() {
//		return minorServerName;
//	}
//	public void setMinorServerName(String minorServerName) {
//		this.minorServerName = minorServerName;
//	}
//	public Integer getMajorServerStatus() {
//		return majorServerStatus==null?1:majorServerStatus;
//	}
//	public void setMajorServerStatus(Integer majorServerStatus) {
//		this.majorServerStatus = majorServerStatus;
//	}
//	public Integer getMinorServerStatus() {
//		return minorServerStatus==null?0:minorServerStatus;
//	}
//	public void setMinorServerStatus(Integer minorServerStatus) {
//		this.minorServerStatus = minorServerStatus;
//	}
//	public String getMinorStatusChgTime() {
//		return minorStatusChgTime==null?"2015-01-01 00:00":minorStatusChgTime;
//	}
//	public void setMinorStatusChgTime(String minorStatusChgTime) {
//		this.minorStatusChgTime = minorStatusChgTime;
//	}
//	public String getSwitchTimestamp() {
//		return switchTimestamp;
//	}
//	public void setSwitchTimestamp(String switchTimestamp) {
//		this.switchTimestamp = switchTimestamp;
//	}
//	public Integer getCheckInterval() {
//		return checkInterval;
//	}
//	public void setCheckInterval(Integer checkInterval) {
//		this.checkInterval = checkInterval;
//	}
//	public String getServerName(String fieldName){
//		if("major_server_name".equals(fieldName)){
//			return this.getMajorServerName();
//		}else{
//			return this.getMinorServerName();
//		}
//	}
//	public String  getServerStatusChgTime(String fieldName){
//		if("major_status_chg_time".equals(fieldName)){
//			return this.getMajorStatusChgTime();
//		}else if("minor_status_chg_time".equals(fieldName)){
//			return this.getMinorStatusChgTime();
//		}else{
//			return null;
//		}
//	}
//	public int getServerStatus(String fieldName){
//		if("major_server_status".equals(fieldName)){
//			return getMajorServerStatus();
//		}else if("minor_server_status".equals(fieldName)){
//			return getMinorServerStatus();
//		}else{
//			return -1;
//		}
//	}
//	public void setServerStatus(String fieldName,int value){
//		if("major_server_status".equals(fieldName)){
//			this.setMajorServertatus(value);
//		}else if("minor_server_status".equals(fieldName)){
//			this.setMinorServerStatus(value);
//		}else{
//		}
//	}
//	public String getStatusField(String serverName){
//		if (StringUtils.equalsIgnoreCase(serverName,
//				this.majorServerName)){
//			return "minor_server_status";
//		}else{
//			return "major_server_status";
//		}
//	}
//}
