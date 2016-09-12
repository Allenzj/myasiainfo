package com.asiainfo.dacp.dp.message.impl;

import org.junit.Test;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.FileSystemXmlApplicationContext;

public class DacpMessageReciverTest {
	@Test
	public void test() {
		System.out.println("reciever----start");
		ApplicationContext context = new FileSystemXmlApplicationContext(
				"classpath*:conf/applicationContext-recieve.xml");
	}
	public static void main(String[] args){
		System.out.println("reciever----start");
		ApplicationContext context = new FileSystemXmlApplicationContext(
				"classpath*:conf/applicationContext-recieve.xml");
	}
}
