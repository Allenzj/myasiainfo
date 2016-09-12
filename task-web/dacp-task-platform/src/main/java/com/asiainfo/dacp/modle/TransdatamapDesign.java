package com.asiainfo.dacp.modle;

import java.io.Serializable;

import com.asiainfo.dacp.jdbc.persistence.Column;
import com.asiainfo.dacp.jdbc.persistence.Persistence;
import com.asiainfo.dacp.jdbc.persistence.Table;

@SuppressWarnings("serial")
@Table(name="transdatamap_design")
public class TransdatamapDesign  extends Persistence implements Serializable{

	 //@Column(name="xmlid", isPrimaryKey=true)
	@Column(name="xmlid")  
	String xmlid;
	 
	 @Column(name="flowcode")
	  String flowcode;
	 
	 @Column(name="transname")
	 String transname;
	 
	 @Column(name="source")
	  String source;
	 
	 @Column(name="sourcetype")
	  String sourcetype;
	 
	 @Column(name="sourcefreq")
	  String sourcefreq;
	 
	 @Column(name="target")
	  String target;
	 
	 @Column(name="targettype")
	  String targettype;
	 
	 @Column(name="targetfreq")
	  String targetfreq;
	 
	 @Column(name="need_dq_check")
	  int need_dq_check;

	public String getXmlid() {
		return xmlid;
	}

	public void setXmlid(String xmlid) {
		this.xmlid = xmlid;
	}

	public String getFlowcode() {
		return flowcode;
	}

	public void setFlowcode(String flowcode) {
		this.flowcode = flowcode;
	}

	public String getTransname() {
		return transname;
	}

	public void setTransname(String transname) {
		this.transname = transname;
	}

	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String getSourcetype() {
		return sourcetype;
	}

	public void setSourcetype(String sourcetype) {
		this.sourcetype = sourcetype;
	}

	public String getSourcefreq() {
		return sourcefreq;
	}

	public void setSourcefreq(String sourcefreq) {
		this.sourcefreq = sourcefreq;
	}

	public String getTarget() {
		return target;
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

	public int getNeed_dq_check() {
		return need_dq_check;
	}

	public void setNeed_dq_check(int need_dq_check) {
		this.need_dq_check = need_dq_check;
	}

	  
}
