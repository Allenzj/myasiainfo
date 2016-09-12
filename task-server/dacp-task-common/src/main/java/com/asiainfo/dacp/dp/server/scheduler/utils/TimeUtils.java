package com.asiainfo.dacp.dp.server.scheduler.utils;

import java.sql.Time;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.asiainfo.dacp.dp.server.scheduler.bean.TaskConfig;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.type.DataFreq;
import com.asiainfo.dacp.dp.server.scheduler.type.RunFreq;

public class TimeUtils {
	public final static String YYYY_MM_DD_HHmm = "yyyy-MM-dd HH:mm";
	public final static String YYYY_MM_DD_HHmmss = "yyyy-MM-dd HH:mm:ss";
	public final static String yyyyMMdd = "yyyyMMdd";
	public final static String yyyyMMddHH = "yyyyMMddHH";
	public final static String yyyyMMddHHmm = "yyyyMMddHHmm";
	public final static String yyyyMMddHHmmssSSS = "yyyyMMddHHmmssSSS";
	private static Logger LOG = LoggerFactory.getLogger(TimeUtils.class);

	/**
	 * yyyy-MM-dd HH:mm convert to date
	 * 
	 * @param source
	 * @return
	 */
	public static Date convertToTime(String source) {
		if (StringUtils.isEmpty(source))
			return null;
		Date date = null;
		try {
			date = new SimpleDateFormat(YYYY_MM_DD_HHmm).parse(source);
		} catch (ParseException e) {
			LOG.error("convert {} to date,error:{}", source, e);
		}
		return date;
	}
	
	/**
	 * yyyy-MM-dd HH:mm:ss convert to date
	 * 
	 * @param source
	 * @return
	 */
	public static Date convertToTime2(String source) {
		if (StringUtils.isEmpty(source))
			return null;
		Date date = null;
		try {
			date = new SimpleDateFormat(YYYY_MM_DD_HHmmss).parse(source);
		} catch (ParseException e) {
			LOG.error("convert {} to date,error:{}", source, e);
		}
		return date;
	}

	/**
	 * yyyyMMdd convert to date
	 * 
	 * @param source
	 * @return
	 */
	public static Date convertToTime2Day(String source) {
		if (StringUtils.isEmpty(source))
			return null;
		Date date = null;
		try {
			date = new SimpleDateFormat(yyyyMMdd).parse(source);
		} catch (ParseException e) {
			LOG.error("convert {} to date,error:{}", source, e);
		}
		return date;
	}

	/**
	 * yyyyMMddhh convert to date
	 * 
	 * @param source
	 * @return
	 */
	public static Date convertToTime2Hour(String source) {
		if (StringUtils.isEmpty(source))
			return null;
		Date date = null;
		try {
			date = new SimpleDateFormat(yyyyMMddHH).parse(source);
		} catch (ParseException e) {
			LOG.error("convert {} to date,error:{}", source, e);
		}
		return date;
	}

	/**
	 * yyyyMMddhhmm convert to date
	 * 
	 * @param source
	 * @return
	 */
	public static Date convertToTime2Second(String source) {
		if (StringUtils.isEmpty(source))
			return null;
		Date date = null;
		try {
			date = new SimpleDateFormat(yyyyMMddHHmm).parse(source);
		} catch (ParseException e) {
			LOG.error("convert {} to date,error:{}", source, e);
		}
		return date;
	}

	/***
	 * 
	 * yyyyMMddHHmm
	 * 
	 */
	public static String dateToString2Second(Date date) {
		return new SimpleDateFormat("yyyyMMddHHmmss").format(date);
	}

	/***
	 * yyyyMMddHHmm
	 * 
	 */
	public static String dateToString2Minute(Date date) {
		return new SimpleDateFormat(yyyyMMddHHmm).format(date);
	}

	public static String dateToString2Hour(Date date) {
		return new SimpleDateFormat(yyyyMMddHH).format(date);
	}

	/***
	 * 
	 * yyyyMMdd
	 * 
	 */
	public static String dateToString2Day(Date date) {
		return new SimpleDateFormat(yyyyMMdd).format(date);
	}

	/***
	 * 
	 * yyyy-MM-dd HH:mm
	 * 
	 */
	public static String dateToString(Date date) {
		return new SimpleDateFormat(YYYY_MM_DD_HHmm).format(date);
	}
	
	/***
	 * 
	 * yyyy-MM-dd HH:mm:ss
	 * 
	 */
	public static String dateToString2(Date date) {
		return new SimpleDateFormat(YYYY_MM_DD_HHmmss).format(date);
	}

	public static String convertToDataTime(String dateArgs, String runFreq) {
		String res = "N";
		if (StringUtils.isEmpty(runFreq)||runFreq.indexOf(DataFreq.N.name()) == 0) {
			return res;
		}
		String[] a = runFreq.split("-");
		String freq = a[0];
		if (a.length == 1) {
			return res;
		}
		Calendar ca = Calendar.getInstance();
		// 日期参数补0
		String newDateArgs = dateArgs;
		if (dateArgs.length() == 10) {
			newDateArgs += " 00:00";
		} else {
			newDateArgs += ":00";
		}
		Date base = TimeUtils.convertToTime(newDateArgs);
		String offset = a[1];
		int _offset = 0;
		try {
			_offset = Integer.parseInt(offset);
		} catch (Exception ex) {
			_offset = 0;
		}
		DataFreq _freq = DataFreq.valueOf(freq);
		switch (_freq) {
		case D:
			ca.setTime(base);
			ca.add(Calendar.DATE, 0 - _offset);
			res = TimeUtils.dateToString2Day(ca.getTime());
			break;
		case M:
			ca.setTime(base);
			ca.add(Calendar.MONTH, 0 - _offset);
			ca.set(Calendar.DAY_OF_MONTH, 1);
			res = TimeUtils.dateToString2Day(ca.getTime()).substring(0, 6);
			break;
		case ML:
			ca.setTime(base);
			ca.add(Calendar.MONTH, 1 - _offset);
			ca.set(Calendar.DAY_OF_MONTH, 0);
			res = TimeUtils.dateToString2Day(ca.getTime());
			break;
		case H:
			ca.setTime(base);
			ca.add(Calendar.HOUR, 0 - _offset);
			res = TimeUtils.dateToString2Hour(ca.getTime());
			break;
		case MI:
			ca.setTime(base);
			ca.add(Calendar.MINUTE, 0 - _offset);
			res = TimeUtils.dateToString2Minute(ca.getTime());
			break;
		case DL:
			ca.setTime(base);
			ca.add(Calendar.DAY_OF_MONTH, 0 - _offset);
			ca.set(Calendar.HOUR_OF_DAY, 23);
			res = TimeUtils.dateToString2Hour(ca.getTime());
		default:
			break;
		}
		return res;
	}

	public static String convertToDataTime(String dateArgs, String runFreq,String sourceAppoint){
		if(StringUtils.isNotEmpty(sourceAppoint)){
			if(sourceAppoint.length()==1&& sourceAppoint.matches("[1-9]")){
				sourceAppoint ="0" + sourceAppoint;
			}
			dateArgs = dateArgs.substring(0,dateArgs.length()-2)+ sourceAppoint;
		}
		return convertToDataTime(dateArgs,runFreq);
	}
	
	// 计算依赖程序的日期参数
	public static String getDependDateArgs(String runFreq, String dateArgs) {
		if (StringUtils.equals(runFreq, DataFreq.N.name())) {
			return "N";
		}
		Calendar ca = Calendar.getInstance();
		ca.setTime(new Date());
		ca.add(Calendar.DATE, -1);
		String res = TimeUtils.dateToString(new Date()).substring(0, 10);
		if (StringUtils.isEmpty(runFreq)) {
			return res;
		}
		if (dateArgs.length() == 10) {
			dateArgs += " 00:00";
		} else if (dateArgs.length() == 4) {
			
		} else {
			dateArgs += ":00";
		}
		Date base = TimeUtils.convertToTime(dateArgs);
		String[] a = runFreq.split("-");
		if (a.length != 2) {
			return res;
		}
		String freq = a[0];
		String offset = StringUtils.isEmpty(a[1]) ? "0" : a[1];
		DataFreq _cycleType = DataFreq.valueOf(freq);
		switch (_cycleType) {
		case D:
			ca.setTime(base);
			ca.add(Calendar.DATE, 0 - Integer.parseInt(offset));
			res = TimeUtils.dateToString(ca.getTime()).substring(0, 10);
			return res;
		case M:
			ca.setTime(base);
			ca.add(Calendar.MONTH, 0 - Integer.parseInt(offset));
			res = formatMonthDateArgs(TimeUtils.dateToString(ca.getTime()));
			return res;
		case Y:
			ca.setTime(base);
			ca.add(Calendar.YEAR, 0 - Integer.parseInt(offset));
			res = formatYearDateArgs(TimeUtils.dateToString(ca.getTime()));
			return res;
		case ML:
			ca.setTime(base);
			ca.add(Calendar.MONTH, 1 - Integer.parseInt(offset));
			ca.set(Calendar.DAY_OF_MONTH, 0);
			res = TimeUtils.dateToString(ca.getTime()).substring(0, 10);
			return res;
		case H:
			ca.setTime(base);
			ca.add(Calendar.HOUR, 0 - Integer.parseInt(offset));
			res = TimeUtils.dateToString(ca.getTime()).substring(0, 13);
			return res;
		case MI:
			ca.setTime(base);
			ca.add(Calendar.MINUTE, 0 - Integer.parseInt(offset));
			res = TimeUtils.dateToString(ca.getTime()).substring(0, 16);
			return res;
		default:
			return res;
		}
	}

	/***
	 * 触发任务日期参数
	 */
	public static String getDateArgs(String runFreq, String optTime) {
		Date _date = null;
		String res = null;
		optTime = optTime.replaceAll("-", "");
		switch (RunFreq.valueOf(runFreq)) {
		case year:
			if (optTime.length() == 4) {
				optTime += "0101";
			}
			_date = TimeUtils.convertToTime2Day(optTime);
			res = formatYearDateArgs(TimeUtils.dateToString(_date));
			break;
		case minute:
			_date = TimeUtils.convertToTime2Second(optTime);
			res = TimeUtils.dateToString(_date);
			break;
		case hour:
			_date = TimeUtils.convertToTime2Hour(optTime);
			res = TimeUtils.dateToString(_date).substring(0, 13);
			break;
		case day:
			_date = TimeUtils.convertToTime2Day(optTime);
			res = TimeUtils.dateToString(_date).substring(0, 10);
			break;
		case month:
			if (optTime.length() == 6) {
				optTime += "01";
			}
			_date = TimeUtils.convertToTime2Day(optTime);
			res = formatMonthDateArgs(TimeUtils.dateToString(_date));
			break;
		default:
			break;
		}
		return res;
	}

	/***
	 * 定时任务日期参数
	 * 
	 * @param runFreq
	 * @param procDate
	 * @param dateArgs
	 * @return
	 */
	public static String getDateArgs(String runFreq, Date procDate,
			String offset) {
		Calendar ca = Calendar.getInstance();
		ca.setTime(new Date());
		ca.add(Calendar.DATE, -1);
		String res = TimeUtils.dateToString(new Date()).substring(0, 10);
		if (StringUtils.isEmpty(offset)) {
			return res;
		}
		Date base = procDate;
		RunFreq _cycleType = RunFreq.valueOf(runFreq);
		switch (_cycleType) {
		case year:
			ca.setTime(base);
			ca.add(Calendar.YEAR, 0 - Integer.parseInt(offset));
			res = formatYearDateArgs(TimeUtils.dateToString(ca.getTime()));
			return res;
		case day:
			ca.setTime(base);
			ca.add(Calendar.DATE, 0 - Integer.parseInt(offset));
			res = TimeUtils.dateToString(ca.getTime()).substring(0, 10);
			return res;
		case month:
			ca.setTime(base);
			ca.add(Calendar.MONTH, 0 - Integer.parseInt(offset));
			res = formatMonthDateArgs(TimeUtils.dateToString(ca.getTime()));
			return res;
		case hour:
			ca.setTime(base);
			ca.add(Calendar.HOUR, 0 - Integer.parseInt(offset));
			res = TimeUtils.dateToString(ca.getTime()).substring(0, 13);
			return res;
		case minute:
			ca.setTime(base);
			ca.add(Calendar.MINUTE, 0 - Integer.parseInt(offset));
			res = TimeUtils.dateToString(ca.getTime());
		default:
			return res;
		}
	}

	public static String beforeNMonth(int n) {
		Date now = new Date();
		Calendar ca = Calendar.getInstance();
		ca.setTime(now);
		ca.add(Calendar.MONTH, 0 - n);
		return TimeUtils.dateToString2Day(ca.getTime()).substring(0, 6);
	}

	public static String beforeNDay(int n) {
		Date now = new Date();
		Calendar ca = Calendar.getInstance();
		ca.setTime(now);
		ca.add(Calendar.DATE, 0 - n);
		return TimeUtils.dateToString2Day(ca.getTime());
	}

	/***
	 * 月末判断
	 */
	public static boolean isMonthLast(String _date) {
		try {
			Calendar ca = Calendar.getInstance();
			_date = _date.replaceAll("-", "");
			ca.setTime(TimeUtils.convertToTime2Day(_date));
			if (ca.get(Calendar.DATE) == ca
					.getActualMaximum(Calendar.DAY_OF_MONTH)) {
				return true;
			} else {
				return false;
			}
		} catch (Exception ex) {
		}
		return false;
	}

	public static boolean isMonthLast(Date _date) {
		try {
			Calendar ca = Calendar.getInstance();
			ca.setTime(_date);
			if (ca.get(Calendar.DATE) == ca
					.getActualMaximum(Calendar.DAY_OF_MONTH)) {
				return true;
			} else {
				return false;
			}
		} catch (Exception ex) {
		}
		return false;
	}

	public static String formatMonthDateArgs(String dateArgs) {
		String _dateArgs = dateArgs.substring(0, 7) + "-01";
		return _dateArgs;
	}

	public static String formatYearDateArgs(String dateArgs) {
		String _dateArgs = dateArgs.substring(0, 4) + "-01-01";
		return _dateArgs;
	}

	/**
	 * 数据日期转日期参数
	 * 
	 * @param _time
	 * @return
	 */
	public static String dataTimeToDateArgs(String _time) {
		String result = null;
		StringBuilder sb = new StringBuilder();
		// 20141212125036--->2014-12-12 12:50:36
		for (int i = 1; i <= _time.length(); i++) {
			sb.append(_time.charAt(i - 1));
			if (i == 4) {
				sb.append("-");
			} else if (i == 6) {
				sb.append("-");
			} else if (i == 8) {
				sb.append(" ");
			} else if (i == 10) {
				sb.append(":");
			} else if (i == 12) {
				sb.append(":");
			}
		}
		char lastChar = sb.charAt(sb.length() - 1);
		if ('-' == lastChar || ' ' == lastChar || ':' == lastChar) {
			sb.deleteCharAt(sb.length() - 1);
		}
		result = sb.toString();
		if (_time.length() == 6) {
			result = formatMonthDateArgs(result);
		}
		return result;
	}

	/**
	 * 日期参数转数据日期
	 * 
	 * @param _time
	 * @return
	 */
	public static String dateArgsToOptTime(String _time) {
		String res = _time;
		res = res.replaceAll("-", "");
		res = res.replaceAll(" ", "");
		res = res.replaceAll(":", "");
		return res;
	}

	public static String getPlanTime(String optTime) {
		int ln = optTime.length();
		Date base = new Date();
		Calendar ca = Calendar.getInstance();
		if (ln == 8) {
			optTime += "0000";
			base = TimeUtils.convertToTime2Second(optTime);
			ca.setTime(base);
			ca.add(Calendar.DAY_OF_MONTH, 1);
		} else if (ln == 10) {
			optTime += "00";
			base = TimeUtils.convertToTime2Second(optTime);
			ca.setTime(base);
			ca.add(Calendar.HOUR_OF_DAY, 1);
		}
		return TimeUtils.dateToString2Minute(ca.getTime());
	}

	/**
	 * @param waitTime
	 *            休眠时间间隔（单位：妙）
	 */
	public static void sleep(int waitTime) {
		try {
			Thread.sleep((long) waitTime * 1000L);
		} catch (InterruptedException e) {
			// ignore
		}
	}

	public static String converToTimeWin(TaskLog runInfo, TaskConfig config) {
		if (config.getOnFocus() == null || config.getOnFocus() == 0) {
			return null;
		}
		String runFreq = config.getRunFreq();
		String planTime = TimeUtils.dataTimeToDateArgs(runInfo.getProcDate());
		String timeWin = config.getTimeWin();
		switch (RunFreq.valueOf(runFreq)) {
		case hour:
			return null;
		case month:
			if (StringUtils.isEmpty(timeWin)) {
				return null;
			} else {
				return planTime.substring(0, 8) + timeWin;
			}
		case day:
			if (StringUtils.isEmpty(timeWin)) {
				return null;
			} else {
				String _timeWin = planTime.substring(0, 10);
				_timeWin += " " + timeWin;
				return _timeWin;
			}
			
		default:
			return null;
		}
	}

	public static String getPreDateArgs(String runFreq, String curDateArgs) {
		String preDateArgs = null;
		String time = curDateArgs;
		if (curDateArgs.length() == 7) {
			time += "-01 00:00";
		} else if (curDateArgs.length() == 10) {
			time += " 00:00";
		} else if (curDateArgs.length() == 4) {
			time += "-01-01 00:00";
		} else {
			time += ":00";
		}
		Date base = TimeUtils.convertToTime(time);
		Calendar ca = Calendar.getInstance();
		ca.setTime(base);
		switch (RunFreq.valueOf(runFreq)) {
		case hour:
			ca.add(Calendar.HOUR, -1);
			preDateArgs = TimeUtils.dateToString(ca.getTime()).substring(0, 13);
			break;
		case day:
			ca.add(Calendar.DAY_OF_MONTH, -1);
			preDateArgs = TimeUtils.dateToString(ca.getTime()).substring(0, 10);
			break;
		case month:
			ca.add(Calendar.MONTH, -1);
			preDateArgs = TimeUtils.dateToString(ca.getTime()).substring(0, 10);
			break;
		case minute:
			ca.add(Calendar.MINUTE, -1);
			preDateArgs = TimeUtils.dateToString(ca.getTime()).substring(0, 16);
			break;
		default:
			preDateArgs = null;
			break;
		}

		return preDateArgs;
	}
	
	//判断当前时间是否在最早可执行时间之后，如果是，则返回true
		public static boolean compareToTime(String time){
			try{
			Calendar cal=Calendar.getInstance();
			Date date=new Date();
			cal.setTime(date);
			SimpleDateFormat sTime=new SimpleDateFormat("HH:mm:ss");
			String now=sTime.format(date);
			Time nowTime=Time.valueOf(now);
			Time xTime=Time.valueOf(time);
			SimpleDateFormat sTime1=new SimpleDateFormat("HHmmss");
			String a=sTime1.format(xTime);
			return !nowTime.before(xTime);
			}catch(Exception e){
				e.printStackTrace();	
				return false;	
			}		
		}
		//判断当前程序是否到了可执行的时间
		public static boolean isAllowExec(String time,String day,TaskLog runinfo){
			Date date=new Date();//定义现在时间
			Date scheduleDate;//定义调度时间
			String procMonth=runinfo.getProcDate().substring(0, 6);//获取批次触发日期月
			String procDay=runinfo.getProcDate().substring(0, 8);//获取批次触发日期日
			String dealDate="";
			if(runinfo.getRunFreq().equals(RunFreq.month)){//拼接调度日
				if(day!=null&&day.length()>0&&time!=null&&time.length()>0){
				dealDate=procMonth+day+time.replace(":", "");
				}else{
					return true;
				}
			}else if(runinfo.getRunFreq().equals(RunFreq.day.name())){//拼接调度时间
				if(time!=null&&time.length()>0){
				dealDate=procDay+time.replace(":", "");
				}else{
					return true;
				}
			}else{
				return true;//如果周期既不是月也不是日则直接执行
			}try{
			SimpleDateFormat s=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		    scheduleDate=s.parse(dataTimeToDateArgs(dealDate));
			}catch(Exception e){
				LOG.info("判断调度时间跟当前时间比较，转换调度时间错误，请检查cron表达式及程序周期");
				e.printStackTrace();
				return true;
			}
			if(!date.before(scheduleDate)){
				return true;
			}else{
				return false;
			}
		}
		
		/**
		 * 计算时间差
		 * @param start 开始时间
		 * @param end 结束时间
		 * @return 时间差：d天h时mi分s秒
		 */
		public static String timeDiff(long start,long end){
			long l = end-start;

		   long day=l/(24*60*60*1000);

		   long hour=(l/(60*60*1000)-day*24);

		   long min=((l/(60*1000))-day*24*60-hour*60);

		   long secord=(l/1000-day*24*60*60-hour*60*60-min*60);

		   return day+"天"+hour+"小时"+min+"分"+secord+"秒";
		}
		
		/**
		 * 计算时间差
		 * @param start 开始时间
		 * @param end 结束时间
		 * @return 时间差：d天h时mi分s秒
		 */
		public static String timeDiff(Date start,Date end){
		   return timeDiff(start.getTime(),end.getTime());
		}
		
		/**
		 * 计算时间差
		 * @param start 开始时间
		 * @param end 结束时间
		 * @return 时间差：d天h时mi分s秒
		 * @throws ParseException 
		 */
		public static String timeDiff(String startTime,String endTime) throws ParseException{
			SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			long start = sdf.parse(startTime).getTime();
			long end = sdf.parse(endTime).getTime();
			
			long l = end-start;

		    long hour=(l/(60*60*1000));
		    long min=((l/(60*1000))-hour*60);
		    long secord=(l/1000-hour*60*60-min*60);

		    return (hour<10?"0"+hour:hour)+":"+(min<10?"0"+min:min)+":"+(secord<10?"0"+secord:secord);
		}
}
