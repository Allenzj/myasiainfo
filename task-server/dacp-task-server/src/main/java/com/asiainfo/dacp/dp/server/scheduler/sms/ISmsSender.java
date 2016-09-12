package com.asiainfo.dacp.dp.server.scheduler.sms;

import java.util.Map;

public interface ISmsSender {
	public boolean sendSms(String phone,Map<String, Object> map);
}
