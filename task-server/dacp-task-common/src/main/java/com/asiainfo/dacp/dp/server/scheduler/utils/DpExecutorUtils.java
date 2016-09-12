package com.asiainfo.dacp.dp.server.scheduler.utils;

import java.io.StringWriter;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import freemarker.core.Environment;
import freemarker.core.ExtBuildIn;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import freemarker.template.TemplateMethodModelEx;
import freemarker.template.TemplateModel;
import freemarker.template.TemplateModelException;

public class DpExecutorUtils {
	
	private static Logger LOG = LoggerFactory.getLogger(DpExecutorUtils.class);
	
	public static String variableSubstitution(String text, Object data){
		new ExtBuildIn(new CalDateBI());
		StringWriter sw = new StringWriter();
		try {
			Template template = new Template(null,text,null);
			template.process(data, sw);
			LOG.debug("原始文本:{}，替换后:{}",text,sw);
		} catch (Exception e) {
			LOG.warn("替换变量失败,{}",text);
			return text;
//			return null;
		}
		return sw.toString();
	}
	public static Map<String,Object> parseArgs(String param) {
		if (param.contains("\"")) {
			param = param.replaceAll("\"", "");
		}
		param = replaceMultiSpaceToOneSpace(param);
		LOG.info("外部参数：" + param);
		
		String[] paras = param.split(" ");
		Map<String,Object> result = new HashMap<String,Object>();
		for (int i = 0; i < paras.length; i = i + 2) {
			if("-t".equalsIgnoreCase(paras[i])){
				result.put("taskid", paras[i+1]);
				result.put("jobBatchNo", paras[i+1]);
			}
			result.put(paras[i].substring(1), paras[i+1]);
		}
		return result;
	}
	
	private static String replaceMultiSpaceToOneSpace(String s) {
		Pattern pattern = Pattern.compile(" {2,}");
		Matcher matcher = pattern.matcher(s);
		String result = matcher.replaceAll(" ");
		return result;
	}
	
	/**
	 * 计算日期的函数
	 * @author MeiKefu
	 */
	static class CalDateBI extends ExtBuildIn.ExtBuildInModel{
		public String getName(){
			return "calDate";
		}
		public TemplateModel calculateResult(final String s, final Environment env) throws TemplateException {
			return new TemplateMethodModelEx() {
				public Object exec(List args) throws TemplateModelException {
					int amount = -1;
					if(args.size()>0 && args.get(0)!=null){
						String arg1 = args.get(0).toString();
						if(StringUtils.isNumeric(arg1)){
							amount = Integer.valueOf(arg1);
						}
					}
					String cycle = "day";
					if(args.size()>1 && args.get(1)!=null){
						cycle = args.get(1).toString();
					}
					String format = "yyyyMMddHHmmss";
					format = format.substring(0,s.length());
					
					//fengwen 20150402支持参数格式化自定义传入
					if(args.size()>2 && args.get(2)!=null){
						format = args.get(2).toString();
					}
					
					int year = 2015;
					int month = 1;
					int day = 1;
					int hour = 0;
					int minute = 0;
					int second = 0;
					if(s.length()>3){
						year = Integer.valueOf(s.substring(0,4));
					}
					
					if(s.length()>5){
						month = Integer.valueOf(s.substring(4,6))-1;
					}
					
					if(s.length()>7){
						day = Integer.valueOf(s.substring(6,8));
					}
					
					if(s.length()>9){
						hour = Integer.valueOf(s.substring(8,10));
					}
					
					if(s.length()>11){
						minute = Integer.valueOf(s.substring(10,12));
					}
					
					if(s.length()>13){
						second = Integer.valueOf(s.substring(12,14));
					}
					GregorianCalendar calendar = new GregorianCalendar(year,month,day,hour,minute,second);
					
					int field = Calendar.DATE;
					
					if("month".equalsIgnoreCase(cycle)||"m".equalsIgnoreCase(cycle)){
						field = Calendar.MONTH;
					}else if ("year".equalsIgnoreCase(cycle)||"y".equalsIgnoreCase(cycle)){
						field = Calendar.YEAR;
					}else if ("hour".equalsIgnoreCase(cycle)||"h".equalsIgnoreCase(cycle)){
						field = Calendar.HOUR_OF_DAY;
						//format = "yyyyMMddHH";
					}else if ("minute".equalsIgnoreCase(cycle)||"mi".equalsIgnoreCase(cycle)){
						field = Calendar.MINUTE;
					}else if ("second".equalsIgnoreCase(cycle)||"s".equalsIgnoreCase(cycle)){
						field = Calendar.SECOND;
					}else if ("last".equalsIgnoreCase(cycle)||"l".equalsIgnoreCase(cycle)){//判断取每月最后一天
						field = Calendar.MONTH;
						amount = amount+1;
					}
					calendar.add(field, amount);
					if ("last".equalsIgnoreCase(cycle)||"l".equalsIgnoreCase(cycle)){
						calendar.set(Calendar.DAY_OF_MONTH, 0);
					}
					return new SimpleDateFormat(format).format(calendar.getTime());
				}
			};
		}
	}
}
