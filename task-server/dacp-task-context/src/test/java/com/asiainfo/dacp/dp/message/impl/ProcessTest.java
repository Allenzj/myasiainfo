package com.asiainfo.dacp.dp.message.impl;

import org.junit.Test;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.FileSystemXmlApplicationContext;

import com.asiainfo.dacp.dp.process.DpProcess;
import com.asiainfo.dacp.dp.process.DpProcessBuilder;

public class ProcessTest {
	@Test
	public void test(){
		String ss="";
		if(true){
		System.out.println(ss.length());
		return;
		}
		ApplicationContext context = new FileSystemXmlApplicationContext(
				"classpath*:conf/applicationContext-send.xml");
		DpProcess process = context.getBean(DpProcessBuilder.class);
		Process poc = process.createProcess("D:\\Mkdirs\\20150121\\123.log",new String[]{"tclsh","D:\\TEST_IDE\\dacp-agent\\bin\\P1.tcl"});
		System.out.println(process.getPid(poc));
		System.out.println(process.getLog("D:\\Mkdirs\\20150121\\123.log"));
		try {
			poc.waitFor();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	public static void main(String[] args){
		final DpProcess process = new DpProcessBuilder();
		final Process poc = process.createProcess("D:\\Mkdirs\\20150121\\123.log",new String[]{"tclsh","D:\\TEST_IDE\\dacp-agent\\bin\\P1.tcl"});
		new Thread(new Runnable() {
			public void run() {
				try {
					Thread.sleep(1000*60L);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
				System.out.println(process.kill(poc,""));
				System.out.println(poc);
			}
		}).start();
		System.out.println(process.getPid(poc));
		System.out.println(process.getLog("D:\\Mkdirs\\20150121\\123.log"));
		try {
			poc.waitFor();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
	}
}
