package com.asiainfo.dacp.dp.syn;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;

import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.asiainfo.dacp.dp.model.Constant.DBNAME;
import com.asiainfo.dacp.dps.zookpeer.util.ZkOperator;
import com.asiainfo.dacp.jdbc.JdbcTemplate;

import net.sf.json.JSONObject;

@Service
public class ServerListener {
	private JdbcTemplate jdbcTemplate = new JdbcTemplate(DBNAME.TASKDBNAME);
	@Autowired
	private ZkOperator zkOperator;
	@Value("${com.asiainfo.dacp.dps.registry.service.AppClientRegistryService.groupCode}")
	private String groupNode;
	
	@Value("${StartServerStatusMonitor.enabled}")
	private String isStartServerStatusMonitor;
	
	@Value("${StartServerStatusMonitor.checkInterval}")
	private String checkInterval;

	@PostConstruct
	public void gitServiceStatus() {
		if(StringUtils.isNotEmpty(isStartServerStatusMonitor)&&StringUtils.equalsIgnoreCase(isStartServerStatusMonitor, "true")){
			serviceStatusMap();
		}
	}

	private void serviceStatusMap() {
		new Thread() {
			public void run() {
				while (true) {
					try {
						//获取所有节点
						JSONObject json = JSONObject.fromObject(zkOperator.getStringData(groupNode));
						@SuppressWarnings("unchecked")
						Iterator<String> iterator = json.keys();

						SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
						Calendar ca = Calendar.getInstance();
						String now = sdf.format(ca.getTime());

						//获取活着的节点
						List<String> childrenNodes = zkOperator.getChildrenNodes(groupNode);
						
						while (iterator.hasNext()) {
							String key = iterator.next();
							String value = json.getString(key);
							String[] values =value.split("/");
							value = values[values.length-1];
							if (!childrenNodes.contains(value)) {
								String sql = " update aietl_servernode set server_status=-1,status_time='"
										+ now + "' where server_id='" + key + "'";
								jdbcTemplate.update(sql);
								System.out.println("更新["+key+"]节点状态为:-1");
							} else {
								String sql = "select 1 from aietl_servernode where server_id='" + key + "'";
								List<Map<String, Object>> serverList = jdbcTemplate.queryForList(sql);
								if (serverList.size() == 1) {
									int status = 0;
									//排序活着的子节点，第一位的为正在运行的server
									Collections.sort(childrenNodes);
									int index = childrenNodes.indexOf(value);
									if(index==0){
										status = 1;
									}else{
										status = 0;
									}
									String updateSql = "update aietl_servernode set server_status="+status+",status_time='"
											+ now + "' where server_id='" + key + "'";
									
									jdbcTemplate.update(updateSql);
									System.out.println("更新["+key+"]节点状态为:" + status);
								}else{
									System.out.println("请检查["+key+"]配置");
								}	
							}
						}
						
						try {
							long interval = Long.parseLong(checkInterval);
							Thread.sleep(interval);
						} catch (Exception e) {
							System.out.println("无效的StartServerStatusMonitor.checkInterval配置：" + checkInterval);
						}
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			}
		}.start();
	}
}
