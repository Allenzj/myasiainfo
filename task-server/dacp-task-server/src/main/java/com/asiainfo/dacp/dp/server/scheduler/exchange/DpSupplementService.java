package com.asiainfo.dacp.dp.server.scheduler.exchange;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class DpSupplementService implements DpSupplement{
	@Autowired
	private SupplementThread supplementThread;
	@Override
	public void start() {
		new Thread(supplementThread).start();
	}

}
