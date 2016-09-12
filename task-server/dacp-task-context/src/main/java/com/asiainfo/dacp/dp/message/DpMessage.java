package com.asiainfo.dacp.dp.message;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class DpMessage implements Serializable{
	private static final long serialVersionUID = 1L;
	/**消息ID---sqno*/
	private String msgId;
	/**消息类型---taskTypeProc/taskTypeFunc/taskTypeHeart/KILL_PROC/GET_LOG*/
	private String msgType;
	/**执行类*/
	private String classUrl;
	/**执行类方法*/
	private String classMethod;
	/**消息返回队列---taskServer*/
	private String sourceQueue;
	/**消息体*/
	private List<Map<String, String>> body = new ArrayList<Map<String, String>>();

	public String getSourceQueue() {
		return sourceQueue;
	}

	public void setSourceQueue(String sourceQueue) {
		this.sourceQueue = sourceQueue;
	}

	public DpMessage() {
	}

	public DpMessage(String msgId, String msgType, String classUrl,
			String classMethod, String sourceQueue) {
		super();
		this.msgId = msgId;
		this.msgType = msgType;
		this.classUrl = classUrl;
		this.classMethod = classMethod;
		this.sourceQueue = sourceQueue;
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

	public void addBody(Map<String, String> map) {

		this.body.add(map);
	}

	public Map<String, String> getFirstMap() {
		if (this.body.size() > 0)
			return this.body.get(0);
		else
			return null;
	}
	public DpMessage clone() {
		DpMessage dpMessage = null;
		ObjectOutputStream oo = null;
		ObjectInputStream oi = null;
		try {
			ByteArrayOutputStream bo = new ByteArrayOutputStream();
			oo = new ObjectOutputStream(bo);
			oo.writeObject(this);
			ByteArrayInputStream bi = new ByteArrayInputStream(bo.toByteArray());
			oi = new ObjectInputStream(bi);
			dpMessage =  (DpMessage)oi.readObject();
		} catch (Exception ex) {
		}finally{
			try {
				if(oo!=null)oo.close();
				if(oi!=null)oi.close();
			} catch (IOException e) {
			}
		}
		return dpMessage;
	}
}
