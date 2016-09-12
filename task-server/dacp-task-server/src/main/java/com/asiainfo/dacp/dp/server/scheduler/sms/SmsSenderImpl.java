package com.asiainfo.dacp.dp.server.scheduler.sms;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;


public class SmsSenderImpl implements ISmsSender {

	@Value("${sms.tablename}")
	private String TABLENAME;
	@Value("${sms.tablename.phone.field}")
	private String PHONENUM;
	@Value("${sms.tablename.content.field}")
	private String msg;
	@Autowired
	private DatabaseDao dbDao;
	
	private Logger LOG = LoggerFactory.getLogger(SmsSenderImpl.class);

	@Override
	public boolean sendSms(String phone,Map<String, Object> map) {
		try {
			SimpleDateFormat  sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			
			Map<String,Object>  insertMap= new HashMap<String, Object>();
			insertMap.put(PHONENUM, phone);
			insertMap.put(msg, map.get("alarm_content")+"["+sdf.format(new Date())+"]");
			dbDao.insert(TABLENAME, insertMap);
			LOG.info("符合条件数据入短信告警表，发送号码为{},消息内容为:{}",phone, map.get("alarm_content"));
			return true;
		} catch (Exception e) {
			LOG.error("任务[%s,%s,%s]告警短信发送失败",map.get("proc_xmlid"),map.get("proc_name"),map.get("proc_date_args"));
			return false;
		}
	}

}
