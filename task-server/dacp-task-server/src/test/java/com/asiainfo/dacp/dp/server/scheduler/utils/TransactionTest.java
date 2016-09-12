package com.asiainfo.dacp.dp.server.scheduler.utils;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.asiainfo.dacp.dp.server.scheduler.dao.DatabaseDao;
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = "classpath:conf/*.xml")
//@ContextConfiguration(locations = "file:conf/*.xml")
public class TransactionTest {
	@Autowired
	private DatabaseDao dbDao;
	@Test
	public void transactionTest() {
		dbDao.insertDistributeTable("ODS_USR_INFO_YYYYMMDD", "20150609");
		/*try {
			int i= dbDao.update("delete from proc_schedule_script_log");
			System.out.println(i);
		} catch (Exception e) {
			e.printStackTrace();
		}*/
	}
}