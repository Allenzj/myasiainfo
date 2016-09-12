package com.asiainfo.dacp.dp.server.scheduler.utils;


import static org.junit.Assert.*;

import java.util.HashMap;
import java.util.Map;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

import org.junit.Test;

public class DpExecutorUtilsTest {
	
	//@Test
	public void variableSubstitution() {
		
		Map data = new HashMap();
		data.put("date1", "20140513");
		assertEquals("wosab", DpExecutorUtils.variableSubstitution("wosab", data));
		assertEquals("", DpExecutorUtils.variableSubstitution("wosab${ab}", data));
		
	}
	
	//@Test
	public void variableSubstitution1() {

		Map data = new HashMap();
		data.put("date1", "20140513");
		
		//assertEquals("20130513", DpExecutorUtils.variableSubstitution("${date1?calDate(-1,'h')}", data));//-1小时
		assertEquals("20140512", DpExecutorUtils.variableSubstitution("${date1?calDate(-1)}", data));//-1天
		assertEquals("20140512", DpExecutorUtils.variableSubstitution("${date1?calDate(-1,'d')}", data));//-1天
		assertEquals("20140413", DpExecutorUtils.variableSubstitution("${date1?calDate(-1,'m')}", data));//-1月
		assertEquals("20130513", DpExecutorUtils.variableSubstitution("${date1?calDate(-1,'y')}", data));//-1月
		
		assertEquals("20140531", DpExecutorUtils.variableSubstitution("${date1?calDate(0,'L')}", data));//本月的最后一天
		assertEquals("20140430", DpExecutorUtils.variableSubstitution("${date1?calDate(-1,'L')}", data));//-1月的最后一天
		
		
		System.out.println();

	}
	@Test
	public void testHour(){
		String res="sh /home/ocdc/app/ocnosql/bulkload/bin/load_hbase_hb.sh ${taskid?substring(0,4)}-${taskid?substring(4,6)}-${taskid?substring(4,6)}";
		Map data = new HashMap();
		data.put("taskid", "2015031217");
		System.out.println(DpExecutorUtils.variableSubstitution(res, data));

	}
	//@Test
	public void aaaa(){
		ScriptEngineManager sem = new ScriptEngineManager();
		ScriptEngine engine = sem.getEngineByName("nashorn");
		System.out.println(engine);
	}
}
