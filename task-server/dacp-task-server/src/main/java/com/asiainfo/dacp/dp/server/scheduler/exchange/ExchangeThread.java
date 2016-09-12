package com.asiainfo.dacp.dp.server.scheduler.exchange;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;

@Service
public class ExchangeThread implements Runnable {
	public void run() {}
//	@Autowired
//	private ServerConfig config;
//	@Autowired
//	private DatabaseDao databaseDao;
//	private boolean needExchange;
//	private final String querySql="select server_id,host_name,server_status,server_name,status_time from aietl_servernode ";
//	private final static Logger LOG = LoggerFactory.getLogger(ExchangeThread.class);
//	public void run() {
//		try {
//			needExchange = false;
//			if (StringUtils.isEmpty(config.getServerName())) {
//				LOG.error("灾备服务错误：服务器名为空");
//				return;
//			}
//			if (config == null) {
//				LOG.error("灾备服务错误：无数据，未定义服务器组");
//				return;
//			}
//			while(true){
//				ServerNode runServer= null;
//				//查询数据库是否存在当前server数据
//				String  queryAllSql=querySql+"where server_name !='"+config.getServerName()+"'";
//				List<ServerNode> isexist = databaseDao.queryForList(querySql+" where server_name='"+config.getServerName()+"'", ServerNode.class);
//				if(isexist==null||isexist.size()<=0){
//					Map<String,Object> insertMap = new HashMap<String, Object>();
//					insertMap.put("server_id", System.currentTimeMillis());
//					insertMap.put("server_status", 0);
//					insertMap.put("status_time", System.currentTimeMillis());
//					insertMap.put("server_name", config.getServerName());
//					databaseDao.insert("aietl_servernode", insertMap);
//				}
//				//查询除去本身以外 是否有server正在运行
//				List<ServerNode> serverNodeList=databaseDao.queryForList(queryAllSql, ServerNode.class);
//				//判断除去本身以外是否有数据
//				if(serverNodeList==null||serverNodeList.size()<=0){
//					databaseDao.update("update aietl_servernode set server_status=0,status_time='"+System.currentTimeMillis()+"' where server_name !='"+config.getServerName()+"'");
//					databaseDao.update("update aietl_servernode set server_status=1,status_time='"+System.currentTimeMillis()+"' where server_name='"+config.getServerName()+"'");
//					needExchange=true;
//				}else{
//					//循环遍历是否有正在运行的数据
//					for(ServerNode serverNode :serverNodeList){
//						if(serverNode.getServerStatus()==1){
//							runServer = serverNode;
//						}
//					}
//					if(runServer==null){
//						databaseDao.update("update aietl_servernode set server_status=0,status_time='"+System.currentTimeMillis()+"' where server_name !='"+config.getServerName()+"'");
//						databaseDao.update("update aietl_servernode set server_status=1,status_time='"+System.currentTimeMillis()+"' where server_name='"+config.getServerName()+"'");
//						needExchange=true;
//					}else{
//						if(System.currentTimeMillis() - Long.valueOf(runServer.getStatusTime())>(2*60*1000)){
//							//修改除本身以外的数据为关闭，并把本身设置为启动
//							databaseDao.update("update aietl_servernode set server_status=0,status_time='"+System.currentTimeMillis()+"' where server_name !='"+config.getServerName()+"'");
//							databaseDao.update("update aietl_servernode set server_status=1,status_time='"+System.currentTimeMillis()+"' where server_name='"+config.getServerName()+"'");
//							needExchange=true;
//						}
//					}
//				}
//				databaseDao.update("update aietl_servernode set status_time='"+System.currentTimeMillis()+"' where server_name='"+config.getServerName()+"'");
//				Thread.sleep((long) 60 * 1000L);
//			}
//		} catch (Exception ex) {
//			LOG.error("灾备服务错误:", ex);
//			needExchange=false;
//		}
//
//	}
//	public boolean needExchange(){
//		return needExchange;
//	}
}
