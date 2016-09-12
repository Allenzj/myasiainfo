package com.asiainfo.dacp.dp.agent.task;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.Reader;
import java.util.Date;

import com.google.gson.Gson;

public class CacheUtils {
	public static class FinishStatus {
		public final static String RUN_SUCCESS = "RUN_SUCCESS";
		public final static String RUN_INTERRUPTION = "RUN_INTERRUPTION";
		public final static String RUN_ERROR = "RUN_ERROR";
		public final static String RUN_RUNING = "RUN_RUNING";
		public final static String SEND = "SEND";
		public final static String UNSEND = "UNSEND";
	}

	private static Gson json = new Gson();

	private static String parsePath(String agentCode, String seqno) {
		StringBuilder sb = new StringBuilder().append(".cache/")
				.append(agentCode).append("/").append(seqno);
		System.out.println(sb.toString()+"路径");
		return sb.toString();
	}

	public static Task initTask(String agentCode, String seqno, String cmdLine) {
		Task task = new Task();
		task.setAgentCode(agentCode);
		task.setCmdLine(cmdLine);
		task.setSeqno(seqno);
		task.setPid(null);
		task.setStartTime("" + new Date().getTime());
		task.setSendFlag(FinishStatus.UNSEND);
		task.setRunMsg(FinishStatus.RUN_RUNING);
		task.setExitValue("-1");
		task.setEndTime(null);
		return task;
	}

	public static boolean saveTask(Task task) {
		BufferedWriter writer = null;
		try {
			File file = new File(".cache/" + task.getAgentCode());
			file.mkdirs();
			file = new File(parsePath(task.getAgentCode(), task.getSeqno()));
			writer = new BufferedWriter(new FileWriter(file));
			writer.write((json.toJson(task)));
			writer.close();
			return true;
		} catch (Exception e) {
			return false;
		} finally {
			try {
				writer.close();
			} catch (Exception e) {
			}
		}
	}

	public static Task paseTask(String agentCode, String seqno) {
		Task task = null;
		Reader reader = null;
		try {
			File file = new File(parsePath(agentCode, seqno));
			reader = new FileReader(file);
			task = new Gson().fromJson(reader, Task.class);
		} catch (Exception e) {

		} finally {
			try {
				reader.close();
			} catch (Exception e1) {
				// ignore
			}
		}
		return task;
	}

	public static boolean queueTask(Task task) {
		task.setSendFlag(CacheUtils.FinishStatus.SEND);
		saveTask(task);
		File file = new File(parsePath(task.getAgentCode(), task.getSeqno()));
		return file.delete();
	}
	public static boolean queueTask(String agentCode,String seqno) {
		File file = new File(parsePath(agentCode, seqno));
		return file.delete();
	}
}
