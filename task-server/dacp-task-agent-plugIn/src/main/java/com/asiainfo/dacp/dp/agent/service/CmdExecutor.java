package com.asiainfo.dacp.dp.agent.service;

import java.io.File;
import java.io.IOException;
import java.util.Map;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.LogOutputStream;
import org.apache.commons.exec.PumpStreamHandler;

public class CmdExecutor extends DefaultExecutor {
	private Process process;
	private final  StringBuilder lineBuff = new StringBuilder();
	@Override
	protected Process launch(CommandLine command, Map<String, String> env,
			File dir) throws IOException {
		process =  super.launch(command, env, dir);
		return process;
	}
	public Process getProcess(){
		return process;
	}
	public String getLines(){
		if (lineBuff.length() == 0) {
			return "无日志";
		} else {
			return lineBuff.toString();
		}
	}
	private LogOutputStream logOutputStream  = new  LogOutputStream() {
		@Override
		protected void processLine(String line, int logLevel) {
			lineBuff.append(line).append("\r\n");
		}
	};
	public int execCmd(String cmd,int exitValue){
		this.setStreamHandler(new PumpStreamHandler(logOutputStream));
		int exitV = -1;
		try{
			this.setExitValue(exitValue);
			exitV =  this.execute(CommandLine.parse(cmd));
		}catch(Exception ex){
			
		}
		return exitV;
	}
	public int execCmd(String cmd) {
		this.setStreamHandler(new PumpStreamHandler(logOutputStream));
		int exitV = -1;
		try {
			exitV = this.execute(CommandLine.parse(cmd));
		} catch (Exception ex) {
			lineBuff.append(getExceptionDetail(ex));
		}
		return exitV;
	}
	private LogOutputStream withNoLogStream = new LogOutputStream() {
		@Override
		protected void processLine(String line, int logLevel) {
		
		}
		
	};
	public int execCmdNoLog(String cmd){
		this.setStreamHandler(new PumpStreamHandler(withNoLogStream));
		int exitV = -1;
		try {
			exitV = this.execute(CommandLine.parse(cmd));
		} catch (Exception ex) {
			lineBuff.append(getExceptionDetail(ex));
		}
		return exitV;
	}
	private String getExceptionDetail(Exception e) {
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
}
