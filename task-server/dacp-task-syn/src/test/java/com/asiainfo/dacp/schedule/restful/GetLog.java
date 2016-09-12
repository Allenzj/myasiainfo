package com.asiainfo.dacp.schedule.restful;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import com.asiainfo.dacp.dp.syn.DpSynController;

@RunWith(SpringJUnit4ClassRunner.class)
@WebAppConfiguration
@ContextConfiguration(locations = {"classpath*:conf/rabbitmq.xml"})
public class GetLog {
	@Autowired
	private WebApplicationContext wac;
	@Autowired
	private DpSynController synController;
	private MockMvc mockMvc;
	@Before
	public void setup() {
		mockMvc = MockMvcBuilders.standaloneSetup(synController).build();
	}
	@Test
	public void execute() throws Exception {
		ResultActions ra = this.mockMvc.perform(MockMvcRequestBuilders
				.post("/syn/getLog")
				.param("AGENT_CODE", "agent@test")
				.param("SEQNO","15070417050010037"));
		MvcResult mr = ra.andReturn();
		String result = mr.getResponse().getContentAsString();
		System.out.println(result);
	}

}
