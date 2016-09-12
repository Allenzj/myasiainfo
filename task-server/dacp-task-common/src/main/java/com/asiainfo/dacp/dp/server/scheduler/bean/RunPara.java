package com.asiainfo.dacp.dp.server.scheduler.bean;

public class RunPara {
private String xmlid;
private String orderid;
private String runPara;
private String runParaValue;
public String getOrderid() {
	return orderid;
}
public void setOrderid(String orderid) {
	this.orderid = orderid;
}
public String getXmlid() {
	return xmlid;
}
public void setXmlid(String xmlid) {
	this.xmlid = xmlid;
}
public String getRunPara() {
	return runPara==null?"":runPara;
}
public void setRunPara(String runPara) {
	this.runPara = runPara;
}
public String getRunParaValue() {
	return runParaValue==null?"":runParaValue;
}
public void setRunParaValue(String runParaValue) {
	this.runParaValue = runParaValue;
}

}
