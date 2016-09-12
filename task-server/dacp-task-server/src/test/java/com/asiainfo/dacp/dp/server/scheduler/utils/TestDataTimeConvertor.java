package com.asiainfo.dacp.dp.server.scheduler.utils;

import java.util.Date;


public class TestDataTimeConvertor {

	public static void main(String[] args) {
		//System.out.println(TimeUtils.convertToDataTime("2015-01-08 14", "H-1"));
		//System.out.println(TimeUtils.getPreDateArgs("day", "2015-01-08"));
		//System.out.println(TimeUtils.getPreDateArgs("month", "2015-01-01"));
		//System.out.println(TimeUtils.getPreDateArgs("hour", "2015-01-07 01"));
		System.out.println(TimeUtils.getDependDateArgs("M-0", "2015-03-01"));
		System.out.println(TimeUtils.getDateArgs("month", new Date(), "1"));
	}

}
