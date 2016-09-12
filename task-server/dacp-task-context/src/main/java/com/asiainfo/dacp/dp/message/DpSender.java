/**
 * 
 */
package com.asiainfo.dacp.dp.message;


/**
 * @author MeiKefu
 * @date 2014-7-22
 */
public interface DpSender {
	/**
	 * @param destination 队列名
	 * @param message 消息内容
	 * @return 
	 */
	public boolean sendMessage(String destination,Object message);
	/**
	 * @param destination 队列名
	 * @param message 消息内容
	 * @return 
	 */
	public boolean pushMessage(String destination,Object message);
	/**
	 * 
	 * @param destination 队列名
	 * @param message 消息内容
	 * @param timeout 超时时间
	 * @return response message
	 */
	public Object sendAndRecieve(String destination,Object message,long timeout);
}
