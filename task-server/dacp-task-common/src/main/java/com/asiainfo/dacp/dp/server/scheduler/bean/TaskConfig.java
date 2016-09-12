package com.asiainfo.dacp.dp.server.scheduler.bean;

/**
 * 任务配置信息
 * proc,proc_schedule_info
 * @author wybhlm
 *
 */
public class TaskConfig {
	private String xmlid;
	/*** 程序名[英文] */
	private String procName;
	
	/*** 触发类型*0--时间触发，1--事件触发 */
	private Integer triggerType;
	/*** 数据库名 */
	private String platform;
	/*** 程序运行周期：用于定义定时作业 */
	private String runFreq;
	/*** 开始日期 */
	private String stDay;
	/*** 开始时间 */
	private String stTime;
	/*** cron表达式 */
	private String cronExp;
	/*** 期望运行完成时间(分钟) */
	private Integer duraMax;
	/*** 程序优先级 */
	private Integer priLevel;
	/*** 资源级别 */
	private Integer resouceLevel;
	/*** 失败自动重做次数 */
	private Integer redoNum = 0;
	/*** 重做时间间隔 */
	private Integer redoInterval = 5;
	/*** 告警类型 */
	private Integer alarmClass = 0;
	/*** 维护人员 */
	private String curdutyer;
	/*** 有效无效 */
	private Integer validFlag = 0;
	/*** 执行模式 */
	private Integer mutiRunFlag = 0;
	// 作业信息
	/*** agent代码 */
	private String agentCode;
	/** 执行类url */
	private String execClass;
	/** 脚本路径 */
	private String path;
	/*** 运行参数 */
	private String runpara;
	/*** 程序类型 */
	private String procType;
	/*** 日期参数 */
	private String dateArgs;
	/*** 时间窗口 */
	private String timeWin;
	/***有效期*/
	private String effTime;
	/***失效期*/
	private String expTime;
	/***状态*/
	private String state;
	/***组编号*/
	private String teamCode;
	/***流程号*/
	private String flowcode;
	/**重点业务标志*/
	private Integer  onFocus;
	/**主题*/
	private String topicname;
	/**执行程序名*/
	private String execProc;
	public String getTopicname() {
		return topicname;
	}
	public void setTopicname(String topicname) {
		this.topicname = topicname;
	}
	public Integer getOnFocus() {
		return onFocus;
	}
	public void setOnFocus(Integer onFocus) {
		if(onFocus==null)
			onFocus=0;
		else
			this.onFocus = onFocus;
	}
	public TaskConfig() {
		redoInterval = 5;
		mutiRunFlag = 1;
		priLevel = 1;
		resouceLevel = 1;
		redoNum = 0;
		validFlag = 1;
	}
	public String getProcName() {
		return procName;
	}
	public Integer getTriggerType() {
		return triggerType;
	}
	public String getPlatform() {
		return platform;
	}
	public String getRunFreq() {
		return runFreq;
	}
	public String getStDay() {
		return stDay;
	}
	public String getStTime() {
		return stTime;
	}
	public String getCronExp() {
		return cronExp;
	}
	public Integer getDuraMax() {
		return duraMax;
	}
	public Integer getPriLevel() {
		return priLevel;
	}
	public Integer getResouceLevel() {
		return resouceLevel==null?0:resouceLevel;
	}
	public Integer getRedoNum() {
		return redoNum==null?0:redoNum;
	}
	public Integer getRedoInterval() {
		return redoInterval;
	}
	public Integer getAlarmClass() {
		return alarmClass;
	}
	public String getCurdutyer() {
		return curdutyer;
	}
	public Integer getValidFlag() {
		return validFlag;
	}
	public Integer getMutiRunFlag() {
		return mutiRunFlag;
	}
	public String getAgentCode() {
		return agentCode;
	}
	public String getExecClass() {
		return execClass;
	}
	public String getPath() {
		return path;
	}
	public String getRunpara() {
		return runpara;
	}
	public String getProcType() {
		return procType;
	}
	public String getDateArgs() {
		return dateArgs;
	}
	public String getTimeWin() {
		return timeWin;
	}
	public String getEffTime() {
		return effTime;
	}
	public String getExpTime() {
		return expTime;
	}
	public String getState() {
		return state;
	}
	public String getTeamCode() {
		return teamCode;
	}
	public String getFlowcode() {
		return flowcode;
	}
	public void setProcName(String procName) {
		this.procName = procName;
	}
	public void setTriggerType(Integer triggerType) {
		this.triggerType = triggerType;
	}
	public void setPlatform(String platform) {
		this.platform = platform;
	}
	public void setRunFreq(String runFreq) {
		this.runFreq = runFreq;
	}
	public void setStDay(String stDay) {
		this.stDay = stDay;
	}
	public void setStTime(String stTime) {
		this.stTime = stTime;
	}
	public void setCronExp(String cronExp) {
		this.cronExp = cronExp;
	}
	public void setDuraMax(Integer duraMax) {
		this.duraMax = duraMax;
	}
	public void setPriLevel(Integer priLevel) {
		this.priLevel = priLevel;
	}
	public void setResouceLevel(Integer resouceLevel) {
		this.resouceLevel = resouceLevel;
	}
	public void setRedoNum(Integer redoNum) {
		this.redoNum = redoNum;
	}
	public void setRedoInterval(Integer redoInterval) {
		this.redoInterval = redoInterval;
	}
	public void setAlarmClass(Integer alarmClass) {
		this.alarmClass = alarmClass;
	}
	public void setCurdutyer(String curdutyer) {
		this.curdutyer = curdutyer;
	}
	public void setValidFlag(Integer validFlag) {
		this.validFlag = validFlag;
	}
	public void setMutiRunFlag(Integer mutiRunFlag) {
		this.mutiRunFlag = mutiRunFlag;
	}
	public void setAgentCode(String agentCode) {
		this.agentCode = agentCode;
	}
	public void setExecClass(String execClass) {
		this.execClass = execClass;
	}
	public void setPath(String path) {
		this.path = path;
	}
	public void setRunpara(String runpara) {
		this.runpara = runpara;
	}
	public void setProcType(String procType) {
		this.procType = procType;
	}
	public void setDateArgs(String dateArgs) {
		this.dateArgs = dateArgs;
	}
	public void setTimeWin(String timeWin) {
		this.timeWin = timeWin;
	}
	public void setEffTime(String effTime) {
		this.effTime = effTime;
	}
	public void setExpTime(String expTime) {
		this.expTime = expTime;
	}
	public void setState(String state) {
		this.state = state;
	}
	public void setTeamCode(String teamCode) {
		this.teamCode = teamCode;
	}
	public void setFlowcode(String flowcode) {
		this.flowcode = flowcode;
	}
	public String getXmlid() {
		return xmlid;
	}
	public void setXmlid(String xmlid) {
		this.xmlid = xmlid;
	}
	public String getExecProc() {
		return execProc;
	}
	public void setExecProc(String execProc) {
		this.execProc = execProc;
	}
	
}
