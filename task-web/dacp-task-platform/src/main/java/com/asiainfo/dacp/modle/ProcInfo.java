package com.asiainfo.dacp.modle;

import java.util.List;

public class ProcInfo {
	
	String xmlid;
	Proc proc;
	ProcScheduleInfo procScheuleInfo;
	List<ProcScheduleRunpara> procScheduleRunpara;
	
	public String getXmlid() {
		return xmlid;
	}
	public void setXmlid(String xmlid) {
		this.xmlid = xmlid;
	}
	public Proc getProc() {
		return proc;
	}
	public void setProc(Proc proc) {
		this.proc = proc;
	}
	public ProcScheduleInfo getProcScheuleInfo() {
		return procScheuleInfo;
	}
	public void setProcScheuleInfo(ProcScheduleInfo procScheuleInfo) {
		this.procScheuleInfo = procScheuleInfo;
	}
	public List<ProcScheduleRunpara> getProcScheduleRunpara() {
		return procScheduleRunpara;
	}
	public void setProcScheduleRunpara(List<ProcScheduleRunpara> procScheduleRunpara) {
		this.procScheduleRunpara = procScheduleRunpara;
	}
	
	
	
}
