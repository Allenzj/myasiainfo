package com.asiainfo.dacp.dp.server.scheduler.command;

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang.StringUtils;

import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.type.MsgType;
import com.asiainfo.dacp.dp.server.scheduler.utils.DpExecutorUtils;

public class NJCmdLineBuilder extends DpCmdLineBuilder{

	@Override
	public String buildCmdLine(TaskLog runInfo) {
		String cmdLine = "";
		String procDate = runInfo.getProcDate();
		String runpara   = this.formatRunpara(runInfo);
		String dateArgs = this.formatDateArgs(runInfo);
		// 如果是dp程序
		if (StringUtils.equals(runInfo.getProctype(),
				MsgType.taskTypeProc.name())) {
			cmdLine = new StringBuilder()
					.append("go.bat").append(" ").append(dateArgs)
					.append(" ").append(runpara).toString();
		} else {//如果是脚本
			Map<String, String> template = new HashMap<String, String>();
			template.put("yyyy-MM-dd HH:mm", procDate);
			template.put("yyyy-MM-dd HH", procDate);
			template.put("yyyy-MM-dd", procDate);
			template.put("yyyy-MM", procDate);
			template.put("yyyyMMddHHmm", procDate);
			template.put("yyyyMMddHH", procDate);
			template.put("yyyyMMdd", procDate);
			template.put("yyyyMM", procDate);
			cmdLine = DpExecutorUtils.variableSubstitution(runpara, template);
			template.clear();
			template.put("taskid", dateArgs);
			template.put("TASKID", dateArgs);
			template.put("date_args", dateArgs);
			template.put("dateArgs", dateArgs);
			template.put("DATEARGS", dateArgs);
			template.put("DATE_ARGS", dateArgs);
			template.put("jobBatchNo",dateArgs);
			template.put("JOBBATCHNO",dateArgs);
			template.put("batchno",dateArgs);
			template.put("BATCHNO",dateArgs);
			template.put("BATCH_NO",dateArgs);
			cmdLine = DpExecutorUtils.variableSubstitution(cmdLine, template);
		}
		return cmdLine;
	}

}
