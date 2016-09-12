package com.asiainfo.dacp.dp.server;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.FileSystemXmlApplicationContext;

import com.asiainfo.dacp.dp.server.scheduler.service.TaskManager;
import com.asiainfo.dacp.dps.utils.zookpeer.ZookeeperClientFactory;
import com.asiainfo.dacp.dps.zookpeer.util.ZkConnect;
import com.asiainfo.dacp.dps.zookpeer.util.ZkOperator;

/**
 * @author MeiKefu
 * @date 2014-12-22
 */
public class DpServerBoot {
	private static ApplicationContext context;
	private static Logger LOG = LoggerFactory.getLogger(DpServerBoot.class);
	
	public static void main(String[] args) {
		try {
			context = new FileSystemXmlApplicationContext(new String[]{"conf/*.xml"});
			
			TaskManager taskManager = context.getBean(TaskManager.class);
			System.out.println(taskManager.getZookeeperEnable());
			if(StringUtils.isNotEmpty(taskManager.getZookeeperEnable()) && StringUtils.equals(taskManager.getZookeeperEnable(), "true")){
				LOG.info("启动zookeeper高可用");
				context.getBean(ZookeeperClientFactory.class).zklocks(context, "startup", taskManager.getServerId());
			}else{
				LOG.info("不启动zookeeper高可用");
				taskManager.startup();
			}
		} catch (Throwable ex) {
			ex.printStackTrace();
			System.exit(-1);
		}
	}
}
