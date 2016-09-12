package com.asiainfo.dacp.dp.syn;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.asiainfo.dacp.dp.model.Constant;
import com.asiainfo.dacp.dp.model.Constant.DBNAME;
import com.asiainfo.dacp.dp.model.Constant.TABLENAME;
import com.asiainfo.dacp.jdbc.JdbcTemplate;


@Service
public class SmsController {
	private static Logger LOG = LoggerFactory.getLogger(SmsController.class);
	@PostConstruct
	public static void findProcIsError() throws Exception {
		new Thread(){
			public void run(){
				try {
					while (true){
						JdbcTemplate jdbcTemplate= new JdbcTemplate(DBNAME.TASKDBNAME);
						//查找错误告警数据
						String findSmsDataSql = "SELECT a.interval_time,a.max_send_cnt,c.interval_time AS sendCnt,last_send_time,seqno,a.xmlid,a.proc_name,c.date_args,a.sms_group_id,warning_type,d.phone,alarm_type,c.alarm_context FROM sms_message_group_task a,sms_message_group_member b,proc_schedule_alarm_log c ,metauser d WHERE a.sms_group_id = b.sms_group_id and c.xmlid=a.xmlid  and a.is_send=0  and ( c.send_flag=0 or c.send_flag is null ) and d.username=b.member_name and b.status=0 ";
						List<Map<String,Object>>   smsErrorData=jdbcTemplate.queryForList(findSmsDataSql);
						LOG.info("查询要发送告警程序条数为：{}",smsErrorData==null?0:smsErrorData.size());
						int nextCnt = 0;
						for(Map<String,Object> map :smsErrorData){
							//根据|查分 错误类型
							String[]  warningTypes = map.get("warning_type").toString().split(",");
							boolean  isSend =false;
							String sendCount=StringUtils.isEmpty(map.get("sendcnt"))?"0":map.get("sendcnt").toString();
							SimpleDateFormat  sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
							//检测是否符合发送告警
							if(check(map)){
								//增加发送次数
								nextCnt=Integer.valueOf(sendCount)+1;
								for(String warningType:warningTypes){
									String alarm_type = StringUtils.isEmpty(map.get("alarm_type").toString())?"0":map.get("alarm_type").toString();
									if(warningType.equals(alarm_type)){
										Map<String,Object>  insertMap= new HashMap<String, Object>();
//										Integer  smsId = getSmsId();
//										insertMap.put(Constant.OPTIME,new Date());
										insertMap.put(Constant.MSG, map.get("alarm_context").toString()+"["+sdf.format(new Date())+"]");//map.get("sms_group_id").toString()+map.get("proc_name").toString()+getAlarmTypeName(alarm_type));
										insertMap.put(Constant.PHONENUM, map.get("phone").toString());
										LOG.info("符合条件数据入短信告警表，发送号码为{},消息内容为:{}",insertMap.get(Constant.PHONENUM), insertMap.get(Constant.MSG));
										isSend= insertErrorSms(TABLENAME.SENDTABLENAME,insertMap);
									}
								}
							}
							if(isSend){
								//更新错误次数与最后发送时间
								 jdbcTemplate.update("update proc_schedule_alarm_log set interval_time='" + nextCnt + "',last_send_time='" + sdf.format(new Date()) + "' where xmlid = '" + map.get("xmlid").toString() + "' and  date_args = '" + map.get("date_args").toString() + "' and alarm_type = '" + map.get("alarm_type").toString() + "'");
							}
						}
						Thread.sleep(5*60*1000);
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
				
			}
		}.start();
	}
	//贵州告警 获取主键ID
	private static Integer getSmsId() {
		JdbcTemplate jdbcTemplate= new JdbcTemplate(DBNAME.SMSDBNAME);
		String sql = "select fun_sms_message_seq.nextval as nextid from  dual";
		List<Map<String,Object>>   nexidList=jdbcTemplate.queryForList(sql);
		return Integer.valueOf(nexidList.get(0).get(nexidList).toString());
	}


	private static String getAlarmTypeName(String alarm_type) {
		//查找要发送的错误信息
		JdbcTemplate jdbcTemplate= new JdbcTemplate(DBNAME.TASKDBNAME);
		 String findSql = "select type_name from warning_type where type_code='"+alarm_type+"'";
			List<Map<String,Object>>   smsErrorData=jdbcTemplate.queryForList(findSql);
		return smsErrorData.get(0).get("type_name").toString();
	}

	//检测发送次数与发送周期
	private static boolean check(Map<String, Object> map) throws ParseException {
		JdbcTemplate jdbcTemplate= new JdbcTemplate(DBNAME.TASKDBNAME);
		String maxSendCnt=  StringUtils.isEmpty(map.get("max_send_cnt"))?"0":map.get("max_send_cnt").toString();
		String intervalTime=StringUtils.isEmpty(map.get("interval_time"))?"0":map.get("interval_time").toString();
		String lastSendTime=StringUtils.isEmpty(map.get("last_send_time"))?"1989-01-01 00:00:00":map.get("last_send_time").toString();
		String sendCnt= StringUtils.isEmpty(map.get("sendcnt"))?"0":map.get("sendcnt").toString();
		long  newDate=System.currentTimeMillis();
		SimpleDateFormat  sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		long lastSendLong = sdf.parse(lastSendTime).getTime();
		if(Integer.valueOf(maxSendCnt)<=Integer.valueOf(sendCnt)){
			//如果发送次数小于等于已发送次数  设置为发送成功
			jdbcTemplate.update("update proc_schedule_alarm_log set send_flag='1' where  seqno = '"+map.get("seqno").toString()+"'");
			return false;
		}
		if(((newDate-lastSendLong)/(60*1000))>=Integer.valueOf(intervalTime)&&Integer.valueOf(maxSendCnt)>Integer.valueOf(sendCnt)){
			return true;
		}else {
			return false;
		}
		
	}

	//错误信息保存到短信告警表
	private static boolean insertErrorSms( String tabName, Map<String, Object> insertMap) {
		try {
			JdbcTemplate jdbcTemplate= new JdbcTemplate(DBNAME.SMSDBNAME);
			Map <String,List<String>>  dataMap= getKeysAndValues(insertMap);
			Object [] values=dataMap.get("values").toArray(new Object[dataMap.get("values").size()]);
			Object [] keys= dataMap.get("keys").toArray(new Object[dataMap.get("keys").size()]);
			String sql = "insert into "+tabName+"({columns}) values({values})";
			String columns="";
			String value="";
			for (int i=0;i<keys.length;i++){
				if(i!=values.length-1){
					columns+=keys[i]+",";
					value+="?,";
				}else{
					columns+=keys[i];
					value+="?";
				}
			}
			sql= sql.replace("{columns}", columns).replace("{values}",value);
			jdbcTemplate.update(sql,values);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	
	private static Map<String,List<String>>  getKeysAndValues(Map<String,Object> map){
		if(map.isEmpty())return null;
			Map<String,List<String>> mapList= new HashMap<String, List<String>>();
			List<String> keys=new ArrayList<String>();
			List<String> values = new ArrayList<String>();
			for (String key:map.keySet()){
				keys.add(key);
				values.add(map.get(key).toString());
			}
			mapList.put("keys", keys);
			mapList.put("values", values);
		return mapList;
	}
}
