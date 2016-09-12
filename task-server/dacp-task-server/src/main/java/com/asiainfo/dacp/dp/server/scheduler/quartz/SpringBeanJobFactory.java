package com.asiainfo.dacp.dp.server.scheduler.quartz;

import org.quartz.spi.TriggerFiredBundle;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.AutowireCapableBeanFactory;
/***
 * 重写spring的scheduleFactory
 * @author wybhlm
 *
 */
public class SpringBeanJobFactory  extends org.springframework.scheduling.quartz.SpringBeanJobFactory {
	@Autowired
    private AutowireCapableBeanFactory beanFactory;
	/**
     * 这里我们覆盖了super的createJobInstance方法，对其创建出来的类再进行autowire。
     */
    @Override
    protected Object createJobInstance(TriggerFiredBundle bundle) throws Exception {
        Object jobInstance = super.createJobInstance(bundle);
        beanFactory.autowireBean(jobInstance);
        return jobInstance;
    }
}
