/**
 * 
 */
package com.asiainfo.dacp.dp.message;


/**
 * 异步消息接收类
 * 
 * @author MeiKefu
 * @date 2014-7-22
 */
public interface DpReceiver {
	/**
	 * 启动服务
	 * @throws Exception
	 */
	void start() ;
	/**
	 * 停止服务
	 * @throws Exception
	 */
	void stop() ;
	/**
	 * 重启服务
	 * @throws Exception
	 */
	void restart() ;
}
