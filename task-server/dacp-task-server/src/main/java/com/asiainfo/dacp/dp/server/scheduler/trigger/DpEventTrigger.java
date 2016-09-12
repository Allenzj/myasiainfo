package com.asiainfo.dacp.dp.server.scheduler.trigger;

import java.util.List;

import com.asiainfo.dacp.dp.server.scheduler.bean.MetaLog;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;

public interface DpEventTrigger {
	/**内部程序触发*/
	public void tiggerByProc(TaskLog runInfo);
	/**外部数据流触发*/
	public void triggerByData();
	/**扫描事件*/
	public void scanEvent(List<MetaLog> metaLogList);
}
