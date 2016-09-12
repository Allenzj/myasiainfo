package com.asiainfo.dacp.dp.server.scheduler.exchange;

import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;
import com.asiainfo.dacp.dp.server.scheduler.service.TaskService;
@Service
public class SupplementThread implements Runnable {
	@Autowired
	private DatabaseDao dbDao;
	@Autowired
	private TaskService taskService;
	private final static Logger LOG = LoggerFactory.getLogger(SupplementThread.class);
	private static boolean flag=true;
	@Override
	public void run() {
		while (flag){
			try{
				//查询表procName
				List<Map<String,Object>> isNextTaskList= dbDao.queryForMapList("select  xmlid  from schedule_task_supplement");
				for(int i=isNextTaskList.size()-1;i>=0;i--){
					//创建出当前procName的所有程序 (server停止到启动期间的任务)
					taskService.createNextTask(isNextTaskList.get(i).get("xmlid").toString());
					//删除list中当前任务
					isNextTaskList.remove(i);
					if(i==0){
						//所有任务创建完毕，退出线程
						flag=false;
						LOG.info("补任务完毕");
					}
					
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	public boolean  getIsRun(){
		return flag;
	}
}
