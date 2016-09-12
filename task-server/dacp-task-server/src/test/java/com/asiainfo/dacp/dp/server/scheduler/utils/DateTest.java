package com.asiainfo.dacp.dp.server.scheduler.utils;

import java.util.Calendar;
import java.util.Date;

public class DateTest {

	public static void main(String[] args) {
		Date date = TimeUtils.convertToTime2Day("20150402");
		Calendar ca = Calendar.getInstance();
		ca.setTime(date);
		System.out.println(ca.getActualMaximum(Calendar.DAY_OF_MONTH));
		System.out.println(ca.getActualMaximum(Calendar.DATE));
		String[] sts = new String[]{"ss","123","1234"};
		System.out.println(sts);
		
	}

}
