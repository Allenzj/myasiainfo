package com.asiainfo.dacp.dp.mq;

import com.asiainfo.dacp.dp.message.DpHandler;

public class DpMessageHandler implements DpHandler{
	
	@Override
	public Object onMessage(Object message) {
		System.out.println("ID:"+Thread.currentThread().getId()+";name:"+Thread.currentThread().getName());
		String str =message.toString();
		System.out.println(str);
		String result = str.toUpperCase();
		try {
			Thread.sleep(1000*10L);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
		//return result;
	}
}
