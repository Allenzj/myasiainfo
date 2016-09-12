package com.asiainfo.dacp.dp.server;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.asiainfo.dacp.dp.message.DpReceiver;
import com.asiainfo.dacp.dp.message.DpSender;
import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;
import com.asiainfo.dacp.dp.server.scheduler.exchange.DpExchange;
import com.asiainfo.dacp.dp.server.scheduler.exchange.DpSupplement;
import com.asiainfo.dacp.dp.server.scheduler.exchange.ServerConfig;
import com.asiainfo.dacp.dp.server.scheduler.quartz.DpQuartz;
import com.asiainfo.dacp.dp.server.scheduler.service.TaskService;
import com.asiainfo.dacp.dp.server.scheduler.type.Type;

/**
 * 
 * @author MeiKefu
 * @date 2014-12-22
 */
@Component
public class DpServerContext {
	@Autowired
	private DpSender dpSender;
	@Autowired
	private DpReceiver dpReceiver;
	@Autowired
	private DatabaseDao dbDao;
	@Autowired
	private TaskService taskService;
	@Value("${resource.level.high}")
	private int high;
	@Value("${resource.level.mid}")
	private int mid;
	@Value("${resource.level.low}")
	private int low;
	@Value("${dq.status}")
	private int dqStatus;
	@Value("${request.queue.name}")
	private  String request_queue_name ;
	@Value("${receiveQueue}")
	private  String response_queue_name ;
	@Value("${heartbeat.valid.interval}")
	private int valid_interval;
	@Value("${heartbeat.check.interval}")
	private int check_interval;
	@Value("${manual.proc.function}")
	private String manualProcFunction;
	@Autowired
	private ServerConfig serverConfig;
	@Autowired
	private DpExchange dpExchange;
	@Autowired 
	private DpQuartz dpQuartz;
	@Autowired
	private DpSupplement dpSupplement;
	@Autowired 
	private DpQuartz alarmQuartz;
	
	public DpSupplement getDpSupplement() {
		return dpSupplement;
	}
	public DpExchange getDpExchange() {
		return dpExchange;
	}
	public ServerConfig getServerConfig() {
		return serverConfig;
	}
	public String getManualProcFunction() {
		return manualProcFunction;
	}
	public DpSender getDpSender() {
		return dpSender;
	}

	public int getHigh() {
		return high;
	}
	public int getValid_interval() {
		return valid_interval;
	}

	public void setValid_interval(int valid_interval) {
		this.valid_interval = valid_interval;
	}

	public int getCheck_interval() {
		return check_interval;
	}

	public void setCheck_interval(int check_interval) {
		this.check_interval = check_interval;
	}

	public void setHigh(int high) {
		this.high = high;
	}
	public int getMid() {
		return mid;
	}
	public void setMid(int mid) {
		this.mid = mid;
	}
	public int getLow() {
		return low;
	}
	public void setLow(int low) {
		this.low = low;
	}
	public int getDqStatus() {
		return dqStatus;
	}
	public void setDqStatus(int dqStatus) {
		this.dqStatus = dqStatus;
	}
	public String getRequest_queue_name() {
		return request_queue_name;
	}
	public void setRequest_queue_name(String request_queue_name) {
		this.request_queue_name = request_queue_name;
	}
	public String getResponse_queue_name() {
		return response_queue_name;
	}
	public void setResponse_queue_name(String response_queue_name) {
		this.response_queue_name = response_queue_name;
	}
	public DatabaseDao getDbDao() {
		return dbDao;
	}
	public TaskService getTaskService() {
		return taskService;
	}
	public DpReceiver getDpReceiver() {
		return dpReceiver;
	}
	
	public DpQuartz getDpQuartz() {
		return dpQuartz;
	}
	public int getResourceIps(int resourceLevel) {
		switch (Type.SRC_LV.valueOf(resourceLevel)) {
		case HIGH:
			return this.getHigh();
		case MID:
			return this.getMid();
		case LOW:
			return this.getLow();
		default:
			return 1;
		}
	}
	
	public DpQuartz getAlarmQuartz() {
		return alarmQuartz;
	}
}
