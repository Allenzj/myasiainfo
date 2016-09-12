package com.asiainfo.dacp.dp.mq;

import org.junit.Test;
import org.springframework.core.task.AsyncTaskExecutor;
import org.springframework.core.task.SimpleAsyncTaskExecutor;

/**
 * Spring异步任务处理
 *
 * @author <a href="mailto:hongyuan.czq@taobao.com">Gerald Chen</a>
 * @version $Id: AsyncTaskExecutorTest.java,v 1.1 2011/05/30 08:58:07 gerald.chen Exp $
 */
public class AsyncTaskExecutorTest {

    @Test
    public void test() throws InterruptedException {
        AsyncTaskExecutor executor = new SimpleAsyncTaskExecutor("sys.out");
        executor.execute(new OutThread(), 50000L);
        System.out.println("Hello, World!");
        Thread.sleep(10000 * 1000L);
    }
    
    static class OutThread implements Runnable {

        public void run() {
            for (int i = 0; i < 100; i++) {
                System.out.println(i + " start ...");
                try {
                    Thread.sleep(2 * 1000L);
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
        }
        
    }
}