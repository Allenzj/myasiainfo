package com.asiainfo.dacp.dp.server.scheduler.command;

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;

import com.asiainfo.dacp.dp.common.MapKeys;
import com.asiainfo.dacp.dp.server.DpServerContext;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.utils.DpExecutorUtils;

public class ScheduleCmdLineBuilder{
	@Autowired
	private DpServerContext dpcontext;
	public HashMap buildCmdLine(TaskLog runInfo) {
		HashMap<String, String> map = new HashMap<String, String>();
		String  cmdLine = null;
		String dateArgs = this.formatDateArgs(runInfo);
		String runpara   = dpcontext.getDbDao().queryRunpara(runInfo,dateArgs);
		Map<String, String> template = new HashMap<String, String>();
		template.put("taskid", dateArgs);
		cmdLine =DpExecutorUtils.variableSubstitution(runpara, template);
		if(StringUtils.equals(cmdLine, ""))//如果参数列表为空，则默认追加日期批次
			cmdLine=dateArgs;
		map.put(MapKeys.CMD_LINE, cmdLine);//完整命令通过个性化命令拼接类执行，直接拼接，agent只需要获取该命令执行即可
		map.put(MapKeys.PROC_NAME, MemCache.PROC_MAP.get(runInfo.getXmlid())==null?runInfo.getProcName():MemCache.PROC_MAP.get(runInfo.getXmlid()).getExecProc());//传递真正的程序名
		map.put(MapKeys.PATH,runInfo.getPath());//传递运行程序的路径，即使是手工任务也可以运行
		return map; //默认拼接日期参数
	}
	protected  String formatDateArgs(TaskLog runInfo){
		String dateArgs = runInfo.getDateArgs();
		dateArgs = dateArgs.replaceAll("-", "");
		dateArgs = dateArgs.replaceAll(" ", "");
		dateArgs = dateArgs.replaceAll(":", "");
		return dateArgs;
	}
}
