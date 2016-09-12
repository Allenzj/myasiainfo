package com.asiainfo.dacp.modle;

import java.io.Serializable;
import java.util.Date;

import com.asiainfo.dacp.jdbc.persistence.Column;
import com.asiainfo.dacp.jdbc.persistence.Persistence;
import com.asiainfo.dacp.jdbc.persistence.Table;



@Table(name="proc")
public class Proc  extends Persistence implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1883119974985730632L;
	@Column(name="xmlid", isPrimaryKey=true)
	private String	xmlid;
	@Column(name="proc_name")
	private String	proc_name;
	
	@Column(name="intercode")
	private String	intercode;
	
	@Column(name="proccnname")
	private String	proccnname;
	@Column(name="inorfull")
	private String	inorfull;
	@Column(name="cycletype")
	private String	cycletype;
	@Column(name="topicname")
	private String	topicname;
	@Column(name="startdate")
	private String	startdate;
	@Column(name="starttime")
	private String	starttime;
	
	@Column(name="endtime")
	private String	endtime;
	@Column(name="parentproc")
	private String	parentproc;
	@Column(name="remark")
	private String	remark;
	
	@Column(name="eff_date")
	private String eff_date;
	@Column(name="creater")
	private String	creater;
	@Column(name="state")
	private String	state;
	@Column(name="state_date")
	private String state_date;
	
	@Column(name="proctype")
	private String	proctype;
	
	@Column(name="path")
	private String	path;
	@Column(name="runmode")
	private String	runmode;
	@Column(name="dbname")
	private String	dbname;
	@Column(name="dbuser")
	private String	dbuser;
	@Column(name="curtaskcode")
	private String	curtaskcode;
	@Column(name="designer")
	private String	designer;
	@Column(name="extend_cfg")
	private String	extend_cfg;
	@Column(name="auditer")
	private String	auditer;
	@Column(name="deployer")
	private String	deployer;
	@Column(name="runpara")
	private String	runpara;
	@Column(name="rundura")
	private String	rundura;
	@Column(name="team_code")
	private String	team_code;
	@Column(name="developer")
	private String	developer;
	@Column(name="curdutyer")
	private String	curdutyer;
	@Column(name="verseq")
	private int	verseq;
	@Column(name="level_val")
	private String	level_val;
	@Column(name="areacode")
	private String	areacode;
	@Column(name="xml")
	private String	xml;
	@Column(name="topiccode")
	private String	topiccode;

	public String getTopiccode() {
		return topiccode;
	}
	public void setTopiccode(String topiccode) {
		this.topiccode = topiccode;
	}
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
	public String getIntercode() {
		return intercode;
	}
	public void setIntercode(String intercode) {
		this.intercode = intercode;
	}
	public String getProccnname() {
		return proccnname;
	}
	public void setProccnname(String proccnname) {
		this.proccnname = proccnname;
	}
	public String getInorfull() {
		return inorfull;
	}
	public void setInorfull(String inorfull) {
		this.inorfull = inorfull;
	}
	public String getCycletype() {
		return cycletype;
	}
	public void setCycletype(String cycletype) {
		this.cycletype = cycletype;
	}
	public String getTopicname() {
		return topicname;
	}
	public void setTopicname(String topicname) {
		this.topicname = topicname;
	}
	public String getStartdate() {
		return startdate;
	}
	public void setStartdate(String startdate) {
		this.startdate = startdate;
	}
	public String getStarttime() {
		return starttime;
	}
	public void setStarttime(String starttime) {
		this.starttime = starttime;
	}
	public String getEndtime() {
		return endtime;
	}
	public void setEndtime(String endtime) {
		this.endtime = endtime;
	}
	public String getParentproc() {
		return parentproc;
	}
	public void setParentproc(String parentproc) {
		this.parentproc = parentproc;
	}
	public String getRemark() {
		return remark;
	}
	public void setRemark(String remark) {
		this.remark = remark;
	}
	public String getEff_date() {
		return eff_date;
	}
	public void setEff_date(String eff_date) {
		this.eff_date = eff_date;
	}
	public String getCreater() {
		return creater;
	}
	public void setCreater(String creater) {
		this.creater = creater;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}
	public String getState_date() {
		return state_date;
	}
	public void setState_date(String state_date) {
		this.state_date = state_date;
	}
	public String getProctype() {
		return proctype;
	}
	public void setProctype(String proctype) {
		this.proctype = proctype;
	}
	public String getPath() {
		return path;
	}
	public void setPath(String path) {
		this.path = path;
	}
	public String getRunmode() {
		return runmode;
	}
	public void setRunmode(String runmode) {
		this.runmode = runmode;
	}
	public String getDbname() {
		return dbname;
	}
	public void setDbname(String dbname) {
		this.dbname = dbname;
	}
	public String getDbuser() {
		return dbuser;
	}
	public void setDbuser(String dbuser) {
		this.dbuser = dbuser;
	}
	public String getCurtaskcode() {
		return curtaskcode;
	}
	public void setCurtaskcode(String curtaskcode) {
		this.curtaskcode = curtaskcode;
	}
	public String getDesigner() {
		return designer;
	}
	public void setDesigner(String designer) {
		this.designer = designer;
	}
	public String getExtend_cfg() {
		return extend_cfg;
	}
	public void setExtend_cfg(String extend_cfg) {
		this.extend_cfg = extend_cfg;
	}
	public String getAuditer() {
		return auditer;
	}
	public void setAuditer(String auditer) {
		this.auditer = auditer;
	}
	public String getDeployer() {
		return deployer;
	}
	public void setDeployer(String deployer) {
		this.deployer = deployer;
	}
	public String getRunpara() {
		return runpara;
	}
	public void setRunpara(String runpara) {
		this.runpara = runpara;
	}
	public String getRundura() {
		return rundura;
	}
	public void setRundura(String rundura) {
		this.rundura = rundura;
	}
	public String getTeam_code() {
		return team_code;
	}
	public void setTeam_code(String team_code) {
		this.team_code = team_code;
	}
	public String getDeveloper() {
		return developer;
	}
	public void setDeveloper(String developer) {
		this.developer = developer;
	}
	public String getCurdutyer() {
		return curdutyer;
	}
	public void setCurdutyer(String curdutyer) {
		this.curdutyer = curdutyer;
	}
	public int getVerseq() {
		return verseq;
	}
	public void setVerseq(int verseq) {
		this.verseq = verseq;
	}
	public String getLevel_val() {
		return level_val;
	}
	public void setLevel_val(String level_val) {
		this.level_val = level_val;
	}
	public String getAreacode() {
		return areacode;
	}
	public void setAreacode(String areacode) {
		this.areacode = areacode;
	}
	public String getXml() {
		return xml;
	}
	public void setXml(String xml) {
		this.xml = xml;
	}
	
	
	
}
