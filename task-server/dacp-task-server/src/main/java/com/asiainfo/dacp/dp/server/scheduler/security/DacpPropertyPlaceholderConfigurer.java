/*
package com.asiainfo.dacp.dp.server.scheduler.security;

import java.util.Properties;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.BeanInitializationException;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.beans.factory.config.PropertyPlaceholderConfigurer;

import com.ai.appframe2.complex.util.e.K;

public class DacpPropertyPlaceholderConfigurer extends
		PropertyPlaceholderConfigurer {
	protected void processProperties(
			ConfigurableListableBeanFactory beanFactory, Properties props)
			throws BeansException {
		try {
			String dbPwd = props.getProperty("db.pwd");
			if (dbPwd != null) {
				String pwdStr = K.k_s(dbPwd);
				props.setProperty("db.pwd", pwdStr);
			}
			super.processProperties(beanFactory, props);
			System.out.println(props.getProperty("db.pwd"));
		} catch (Exception e) {
			e.printStackTrace();
			throw new BeanInitializationException(e.getMessage());
		}
	}
}*/
