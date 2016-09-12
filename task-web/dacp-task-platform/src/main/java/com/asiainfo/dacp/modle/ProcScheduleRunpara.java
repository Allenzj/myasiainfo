package com.asiainfo.dacp.modle;

import java.io.Serializable;

import com.asiainfo.dacp.jdbc.persistence.Column;
import com.asiainfo.dacp.jdbc.persistence.Persistence;
import com.asiainfo.dacp.jdbc.persistence.Table;


@Table(name="proc_schedule_runpara")
public class ProcScheduleRunpara extends Persistence implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 2568464840547780883L;

	@Column(name="xmlid", isPrimaryKey=true)
	String    xmlid;
	
	@Column(name="orderid", isPrimaryKey=true)
	int       orderid;
	
	@Column(name="run_para")
	String    run_para;
	
	@Column(name="run_para_value")
	String    run_para_value;
	
	
	public String getXmlid() {
		return xmlid;
	}
	public void setXmlid(String xmlid) {
		this.xmlid = xmlid;
	}
	public int getOrderid() {
		return orderid;
	}
	public void setOrderid(int orderid) {
		this.orderid = orderid;
	}
	public String getRun_para() {
		return run_para;
	}
	public void setRun_para(String run_para) {
		this.run_para = run_para;
	}
	public String getRun_para_value() {
		return run_para_value;
	}
	public void setRun_para_value(String run_para_value) {
		this.run_para_value = run_para_value;
	}
	
	

}
