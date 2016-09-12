package com.asiainfo.dacp.dp.model;

public class TaskRunStatusDTO {
private String type;
private String objName;
private String dbName;
private String dateArgs;
public String getType() {
	return type;
}
public void setType(String type) {
	this.type = type;
}
public String getObjName() {
	return objName;
}
public void setObjName(String objName) {
	this.objName = objName;
}
public String getDbName() {
	return dbName;
}
public void setDbName(String dbName) {
	this.dbName = dbName;
}
public String getDateArgs() {
	return dateArgs;
}
public void setDateArgs(String dateArgs) {
	this.dateArgs = dateArgs;
}

}
