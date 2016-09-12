package com.asiainfo.dacp.dp.agent;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.asiainfo.dacp.dp.process.DpProcess;

@Component
public class DpLogCleanThread implements Runnable {
	@Autowired
	private DpProcess process;
	private String[] args;
	public DpLogCleanThread build(String[] args){
		this.args = args;
		return this;
	}
	@Override
	public void run() {
		try {
			Process proc= process.createProcess(args);
			proc.waitFor();
		} catch (Exception e) {
			//
		}
	}

}
