package com.asiainfo.dacp.dp.server.scheduler.utils;

import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;

import com.asiainfo.dacp.dp.server.scheduler.bean.MetaLog;
import com.asiainfo.dacp.dp.server.scheduler.bean.SourceLog;
import com.asiainfo.dacp.dp.server.scheduler.bean.SourceObj;
import com.asiainfo.dacp.dp.server.scheduler.bean.TargetObj;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.type.DataFreq;
import com.asiainfo.dacp.dp.server.scheduler.type.ObjType;

public class ConvertUtils {
	public static List<SourceLog> convertToSrouceLog(String seqno,
			String dateArgs, List<SourceObj> lst) {
		List<SourceLog> list = new LinkedList<SourceLog>();
		if (lst == null) {
			return list;
		}
		SourceLog srcLog = null;
		String sourceFreq = null;
		String sourceAppoint = null;
		for (SourceObj obj : lst) {
			sourceFreq = obj.getSourcefreq();
			sourceAppoint = obj.getSourceAppoint();
			srcLog = new SourceLog();
			srcLog.setSeqno(seqno);
			srcLog.setProcName(obj.getTarget());
			srcLog.setSource(obj.getSource());
			srcLog.setSourceType(obj.getSourcetype());
			srcLog.setCheckFlg(0);
			srcLog.setFlowcode(obj.getFlowcode());
			srcLog.setDateArgs(dateArgs);
			if (StringUtils.equals(obj.getSourcetype(), ObjType.PROC.name())) {
				if (StringUtils.equals(sourceFreq, DataFreq.N.name())) {
					srcLog.setCheckFlg(1);
					srcLog.setDataTime("N");
				} else {
					srcLog.setDataTime(TimeUtils.getDependDateArgs(sourceFreq,dateArgs));
				}
			} else {
				srcLog.setDataTime(TimeUtils.convertToDataTime(dateArgs,
						sourceFreq,sourceAppoint));
				if (StringUtils.equals(srcLog.getDataTime(), DataFreq.N.name())) {
					srcLog.setCheckFlg(1);
				}
			}
			list.add(srcLog);
		}
		return list;
	}

	public static List<MetaLog> convertToMetaLog(TaskLog runInfo,
			List<TargetObj> lst) {
		List<MetaLog> list = new ArrayList<MetaLog>();
		if (lst == null) {
			return list;
		}
		String seqno = runInfo.getSeqno();
		String xmlid = runInfo.getXmlid();
		String procName = runInfo.getProcName();
		String procDate = runInfo.getProcDate();
		String dateArgs = runInfo.getDateArgs();
		MetaLog targetLog = null;
		String runFreq = null;
		String dataTime = null;
		for (TargetObj obj : lst) {
			runFreq = obj.getTargetfreq();
			dataTime = TimeUtils.convertToDataTime(dateArgs, runFreq);
			targetLog = new MetaLog();
			targetLog.setFlowcode(obj.getFlowcode());
			targetLog.setSeqno(seqno);
			targetLog.setProcName(xmlid);
			targetLog.setTarget(obj.getTarget());
			targetLog.setProcDate(procDate);
			targetLog.setDataTime(dataTime);
			targetLog.setDateArgs(dateArgs);
			targetLog.setGenerateTime(TimeUtils.dateToString(new Date()));
			if (StringUtils.equals(dataTime, DataFreq.N.name())
					&& (int) runInfo.getTriggerFlag() == 1) {
				targetLog.setTriggerFlag(1);
				targetLog.setDataTime(dateArgs.replaceAll("-", "")
						.replaceAll(" ", "").replaceAll(":", ""));
			} else {
				targetLog.setTriggerFlag(0);
			}
			if (obj.getNeedDqCheck() == null) {
				targetLog.setNeedDqCheck(0);
				targetLog.setDqCheckRes(1);
			} else if ((int) obj.getNeedDqCheck() == 0) {
				targetLog.setNeedDqCheck(0);
				targetLog.setDqCheckRes(1);
			} else {
				targetLog.setNeedDqCheck(1);
				targetLog.setDqCheckRes(0);
			}
			list.add(targetLog);
		}
		return list;
	}

	/*** 转换messsageBody */
	public static MetaLog convertToMetaLog(Map<String, String> dataMap) {
		if (dataMap == null) {
			return null;
		}
		MetaLog targetLog = new MetaLog();
		targetLog.setSeqno(UUIDUtils.getUUID());
		String target = dataMap.get("target");
		String procDate = dataMap.get("procDate");
		String dataTime = dataMap.get("dataTime");
		String interNo = dataMap.get("interNo");
		if (StringUtils.isNotEmpty(target) && StringUtils.isNotEmpty(dataTime)) {
			targetLog.setTarget(target);
			targetLog.setProcDate(procDate);
			targetLog.setProcName(interNo);
			targetLog.setDataTime(dataTime);
			targetLog.setNeedDqCheck(0);
			targetLog.setDqCheckRes(1);
			targetLog.setDateArgs(TimeUtils.dataTimeToDateArgs(dataTime));
			targetLog.setGenerateTime(TimeUtils.dateToString(new Date()));
			if (StringUtils.equals(dataTime, DataFreq.N.name())) {
				targetLog.setTriggerFlag(1);
			} else {
				targetLog.setTriggerFlag(0);
			}
		}
		return targetLog;
	}
}
