package com.asiainfo.dacp.dp.model;

public class Constant {
	public static final String SMS_ID = "SMS_ID";
	public static final String OPTIME="op_time";
	public static final String MSG="smscontent";
	public static final String PHONENUM="phonenumber";
	public static final Integer THREADOPEN=1;
	public static final Integer THREADCLOSE=2;
	
	public class DBNAME{
		public static final String SMSDBNAME = "ORACLE（BIDW）";
		public static final String TASKDBNAME = "METADBS";
	}
	public class TABLENAME{
		public static final String SENDTABLENAME = "AISYS.USYS_BASS_SMSSENDER";
	}
}
