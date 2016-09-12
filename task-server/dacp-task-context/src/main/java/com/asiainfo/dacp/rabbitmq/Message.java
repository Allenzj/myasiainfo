package com.asiainfo.dacp.rabbitmq;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.asiainfo.dacp.dp.message.DpMessage;

/**
 * 为了解决老调度的消息兼容，这里做了继承处理，以兼容DpMessage 跟Message的差异
 */
public class Message extends DpMessage implements Serializable{
	private static final long serialVersionUID = 1L;
	private String msgId;
	private String msgType;
	private String classUrl;
	private String classMethod;
	private String sourceQueue;
	private List<Map<String, String>> body = new ArrayList<Map<String,String>>();
	public String getSourceQueue() {
		return sourceQueue;
	}
	public void setSourceQueue(String sourceQueue) {
		this.sourceQueue = sourceQueue;
	}
	public Message() {
	}
	public Message(String msgId, String msgType, String classUrl,
			String classMethod,String sourceQueue) {
		super();
		this.msgId = msgId;
		this.msgType = msgType;
		this.classUrl = classUrl;
		this.classMethod = classMethod;
		this.sourceQueue=sourceQueue;
	}
	public List<Map<String, String>> getBody() {
		return body;
	}
	public Map<String, String> getBodyMap() {
		return body.get(0);
	}
	public void setBody(List<Map<String, String>> body) {
		this.body = body;
	}
	public String getMsgId() {
		return msgId;
	}
	public void setMsgId(String msgId) {
		this.msgId = msgId;
	}
	public String getMsgType() {
		return msgType;
	}
	public void setMsgType(String msgType) {
		this.msgType = msgType;
	}
	public String getClassUrl() {
		return classUrl;
	}
	public void setClassUrl(String classUrl) {
		this.classUrl = classUrl;
	}
	public String getClassMethod() {
		return classMethod;
	}
	public void setClassMethod(String classMethod) {
		this.classMethod = classMethod;
	}
	public void addBody(Map<String,String> map){
		
		this.body.add(map);
	}
	public Map<String,String> getFirstMap(){
		if(this.body.size()>0)
		   return this.body.get(0);
		else
		   return null; 
	}
	
	public void test(){
		Map<String,String> map1 = new HashMap<String, String>();
		map1.put("aaa1", "bbb");
		map1.put("aaa2", "bbb");
		map1.put("aaa3", "bbb");
		map1.put("aaa4", "bbb");
		
		Map<String,String> map2 = new HashMap<String, String>();
		map2.put("aaa1", "bbb");
		map2.put("aaa2", "bbb");
		map2.put("aaa3", "bbb");
		map2.put("aaa4", "bbb");
		//List<Map<String,String>> mapList = new ArrayList<Map<String,String>>();
		//mapList.add(map1);
		//mapList.add(map2);
		Message msg = new Message("P1_201405091223","procTcl","com.dmp.schedule.agent.Tcl","execute","aaa");
		msg.addBody(map1);
		msg.addBody(map2);
		Message msg2 = (Message) msg;
		System.out.println(msg2.getFirstMap());
	}
	
}