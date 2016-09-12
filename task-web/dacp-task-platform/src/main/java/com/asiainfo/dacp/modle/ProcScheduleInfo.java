package com.asiainfo.dacp.modle;



import java.io.Serializable;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import com.asiainfo.dacp.jdbc.persistence.Column;
import com.asiainfo.dacp.jdbc.persistence.Persistence;
import com.asiainfo.dacp.jdbc.persistence.Table;



/**
 * The persistent class for the proc_schedule_info database table.
 * 
 */
@Table(name="proc_schedule_info")
public class ProcScheduleInfo extends Persistence implements Serializable {
	private static final long serialVersionUID = 1L;

	//@Column(name="AGENT_CODE")
	//private String agent_code;

	@Column(name="xmlid", isPrimaryKey=true)
	String	xmlid;

	@Column(name="proc_name")
	String	proc_name;
	@Column(name="agent_code")
	String	agent_code;
	@Column(name="trigger_type")
	int	trigger_type=1;
	@Column(name="run_freq")
	String	run_freq;
	@Column(name="st_day")
	String	st_day;
	@Column(name="st_time")
	String	st_time;
	
	@Column(name="cron_exp")
	String	cron_exp;
	
	@Column(name="proc_group")
	String	proc_group;
	
	@Column(name="pri_level")
	int	pri_level=10;
	
	@Column(name="platform")
	String	platform;
	
	@Column(name="resouce_level")
	int	resouce_level=10;
	
	@Column(name="redo_num")
	int	redo_num=3;
	
	@Column(name="alarm_class")
	String	alarm_class;
	
	@Column(name="exec_class")
	String	exec_class;
	
	@Column(name="date_args")
	String	date_args="1";
	
	@Column(name="muti_run_flag")
	int	muti_run_flag=0;
	
	@Column(name="dura_max")
	int	dura_max;
	
	@Column(name="eff_time")
	String	eff_time=formatDate();
	
	@Column(name="exp_time")
	String	exp_time="2050-12-31";
	
	@Column(name="on_focus")
	int	on_focus=0;
	
	@Column(name="redo_interval")
	int	redo_interval=5;
	
	@Column(name="allow_exec_time")
	String	allow_exec_time;
	
	@Column(name="time_win")
	String	time_win;
	
	@Column(name="flowcode")
	String	flowcode;
	
	@Column(name="max_run_hours")
	int max_run_hours=24;
	
	@Column(name="proc_type")
	String proc_type;
	
	@Column(name="exec_proc")
	String exec_proc;
	
	@Column(name="exec_path")
	String exec_path;
	
	//展示用
	String exec_proc_name;
	
	
	public String getExec_proc_name() {
		return exec_proc_name;
	}
	public void setExec_proc_name(String exec_proc_name) {
		this.exec_proc_name = exec_proc_name;
	}
	public String getExec_path() {
		return exec_path;
	}
	public void setExec_path(String exec_path) {
		this.exec_path = exec_path;
	}
	public String getProc_type() {
		return proc_type;
	}
	public void setProc_type(String proc_type) {
		this.proc_type = proc_type;
	}
	public String getExec_proc() {
		return exec_proc;
	}
	public void setExec_proc(String exec_proc) {
		this.exec_proc = exec_proc;
	}
	List<ProcScheduleRunpara> procParams;
	
	public String getXmlid() {
		return xmlid;
	}
	public void setXmlid(String xmlid) {
		this.xmlid = xmlid;
	}
	public String getProc_name() {
		return proc_name;
	}
	public void setProc_name(String proc_name) {
		this.proc_name = proc_name;
	}
	public String getAgent_code() {
		return agent_code;
	}
	public void setAgent_code(String agent_code) {
		this.agent_code = agent_code;
	}
	public int getTrigger_type() {
		return trigger_type;
	}
	public void setTrigger_type(int trigger_type) {
		this.trigger_type = trigger_type;
	}
	public String getRun_freq() {
		return run_freq;
	}
	public void setRun_freq(String run_freq) {
		this.run_freq = run_freq;
	}
	public String getSt_day() {
		return st_day;
	}
	public void setSt_day(String st_day) {
		this.st_day = st_day;
	}
	public String getSt_time() {
		return st_time;
	}
	public void setSt_time(String st_time) {
		this.st_time = st_time;
	}
	public String getCron_exp() {
		return cron_exp;
	}
	public void setCron_exp(String cron_exp) {
		this.cron_exp = cron_exp;
	}
	public String getProc_group() {
		return proc_group;
	}
	public void setProc_group(String proc_group) {
		this.proc_group = proc_group;
	}
	public int getPri_level() {
		return pri_level;
	}
	public void setPri_level(int pri_level) {
		this.pri_level = pri_level;
	}
	public String getPlatform() {
		return platform;
	}
	public void setPlatform(String platform) {
		this.platform = platform;
	}
	public int getResouce_level() {
		return resouce_level;
	}
	public void setResouce_level(int resouce_level) {
		this.resouce_level = resouce_level;
	}
	public int getRedo_num() {
		return redo_num;
	}
	public void setRedo_num(int redo_num) {
		this.redo_num = redo_num;
	}
	public String getAlarm_class() {
		return alarm_class;
	}
	public void setAlarm_class(String alarm_class) {
		this.alarm_class = alarm_class;
	}
	public String getExec_class() {
		return exec_class;
	}
	public void setExec_class(String exec_class) {
		this.exec_class = exec_class;
	}
	public String getDate_args() {
		return date_args;
	}
	public void setDate_args(String date_args) {
		this.date_args = date_args;
	}
	public int getMuti_run_flag() {
		return muti_run_flag;
	}
	public void setMuti_run_flag(int muti_run_flag) {
		this.muti_run_flag = muti_run_flag;
	}
	public int getDura_max() {
		return dura_max;
	}
	public void setDura_max(int dura_max) {
		this.dura_max = dura_max;
	}
	public String getEff_time() {
		return eff_time;
	}
	public void setEff_time(String eff_time) {
		this.eff_time = eff_time;
	}
	public String getExp_time() {
		return exp_time;
	}
	public void setExp_time(String exp_time) {
		this.exp_time = exp_time;
	}
	public int getOn_focus() {
		return on_focus;
	}
	public void setOn_focus(int on_focus) {
		this.on_focus = on_focus;
	}
	public int getRedo_interval() {
		return redo_interval;
	}
	public void setRedo_interval(int redo_interval) {
		this.redo_interval = redo_interval;
	}
	public String getAllow_exec_time() {
		return allow_exec_time;
	}
	public void setAllow_exec_time(String allow_exec_time) {
		this.allow_exec_time = allow_exec_time;
	}
	public String getTime_win() {
		return time_win;
	}
	public void setTime_win(String time_win) {
		this.time_win = time_win;
	}
	public String getFlowcode() {
		return flowcode;
	}
	public void setFlowcode(String flowcode) {
		this.flowcode = flowcode;
	}
	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	public List<ProcScheduleRunpara> getProcParams() {
		return procParams;
	}
	public void setProcParams(List<ProcScheduleRunpara> procParams) {
		this.procParams = procParams;
	}
	
	
	
	public int getMax_run_hours() {
		return max_run_hours;
	}
	public void setMax_run_hours(int max_run_hours) {
		this.max_run_hours = max_run_hours;
	}
	public static String formatDate(){
		Date date=new Date();
		DateFormat format=new SimpleDateFormat("yyyy-MM-dd");
		return format.format(date);
	}
	

}
