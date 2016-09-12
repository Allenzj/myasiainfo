package com.asiainfo.dacp.dp.agent;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import com.asiainfo.dacp.dp.message.DpSender;
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "/conf/*.xml" })
public class DpAgentSenderTest {
	@Autowired
	private DpSender sender;
	@Test
	public void test() {
		boolean isSend = sender.sendMessage("queue1","message of queue1");
		System.out.println(isSend);
	}

}
