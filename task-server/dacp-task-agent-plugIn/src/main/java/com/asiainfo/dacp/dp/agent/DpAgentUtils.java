package com.asiainfo.dacp.dp.agent;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

public class DpAgentUtils {

	/**
	 * 获取exception详情信息
	 * 
	 * @param e
	 *            Excetipn type
	 * @return String type
	 */
	public static  String getExceptionDetail(Exception e) {
		StringBuffer msg = new StringBuffer("null");
		if (e != null) {
			msg = new StringBuffer("");
			String message = e.toString();
			int length = e.getStackTrace().length;
			if (length > 0) {
				msg.append(message + "\n");
				for (int i = 0; i < length; i++) {
					msg.append("\t" + e.getStackTrace()[i] + "\n");
				}
			} else {
				msg.append(message);
			}
		}
		return msg.toString();
	}
	public static String getLog(String dstFile) {
		StringBuilder logText = new StringBuilder();
		BufferedReader reader = null;
		try {
			File file = new File(dstFile);
			reader = new BufferedReader(new FileReader(file));
			String tempString = null;
			while ((tempString = reader.readLine()) != null) {
				logText.append(tempString);
				logText.append(System.getProperty("line.separator"));
			}
		} catch (Exception e) {
			// ignore
		} finally {
			if (reader != null) {
				try {
					reader.close();
				} catch (IOException e1) {
					// ignore
				}
			}
		}
		return logText.toString();
	}
}
