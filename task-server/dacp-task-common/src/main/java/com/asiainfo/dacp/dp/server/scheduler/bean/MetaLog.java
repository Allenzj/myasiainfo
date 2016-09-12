package com.asiainfo.dacp.dp.server.scheduler.bean;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

/***
 * 元数据日志表/输出表的日志表
 * proc_schedule_target_log
 * proc_schedule_meta_log
 * @author wangyuanbin
 *
 */
@SuppressWarnings("serial")
public class MetaLog implements Serializable{
	private String seqno;
	private String xmlid;
	private String procName;
	private String procDate;
	private String target;
	private String dataTime;
	private Integer triggerFlag;
	private Integer needDqCheck;
	private Integer dqCheckRes;
	private String generateTime;
	private String dateArgs;
	/***流程号*/
	private String flowcode;

	public String getXmlid() {
		return xmlid;
	}
	public void setXmlid(String xmlid) {
		this.xmlid = xmlid;
	}
	
	public String getDateArgs() {
		return dateArgs;
	}
	public void setDateArgs(String dateArgs) {
		this.dateArgs = dateArgs;
	}
	public String getFlowcode() {
		return flowcode;
	}
	public void setFlowcode(String flowCode) {
		this.flowcode = flowCode;
	}	
	
	public String getSeqno() {
		return seqno;
	}
	public void setSeqno(String seqno) {
		this.seqno = seqno;
	}
	public String getProcName() {
		return procName;
	}
	public void setProcName(String procName) {
		this.procName = procName;
	}
	public String getProcDate() {
		return procDate;
	}
	public void setProcDate(String procDate) {
		this.procDate = procDate;
	}
	public String getTarget() {
		return target;
	}

	public void setTarget(String target) {
		this.target = target;
	}
	public String getDataTime() {
		return dataTime;
	}

	public void setDataTime(String dataTime) {
		this.dataTime = dataTime;
	}

	public Integer getTriggerFlag() {
		return triggerFlag;
	}

	public void setTriggerFlag(Integer triggerFlag) {
		this.triggerFlag = triggerFlag;
	}

	public Integer getNeedDqCheck() {
		return needDqCheck;
	}
	public void setNeedDqCheck(Integer needDqCheck) {
		this.needDqCheck = needDqCheck;
	}
	public Integer getDqCheckRes() {
		return dqCheckRes;
	}
	public void setDqCheckRes(Integer dqCheckRes) {
		this.dqCheckRes = dqCheckRes;
	}
	public String getGenerateTime() {
		return generateTime;
	}
	public void setGenerateTime(String generateTime) {
		this.generateTime = generateTime;
	}
	public MetaLog() {
		triggerFlag=1;
		needDqCheck=0;
		dqCheckRes=1;
	}
	public MetaLog clone() {
		MetaLog metaLog = null;
		ObjectOutputStream oo = null;
		ObjectInputStream oi = null;
		try {
			ByteArrayOutputStream bo = new ByteArrayOutputStream();
			oo = new ObjectOutputStream(bo);
			oo.writeObject(this);
			ByteArrayInputStream bi = new ByteArrayInputStream(bo.toByteArray());
			oi = new ObjectInputStream(bi);
			metaLog =  (MetaLog)oi.readObject();
		} catch (Exception ex) {
		}finally{
			try {
				if(oo!=null)oo.close();
				if(oi!=null)oi.close();
			} catch (IOException e) {
			}
		}
		return metaLog;
	}
	public String getDataId(){
		StringBuilder dataId = new StringBuilder()
		.append(procName).append(",").append(target).append(",").append(dataTime);
	    return dataId.toString();
	}
}
