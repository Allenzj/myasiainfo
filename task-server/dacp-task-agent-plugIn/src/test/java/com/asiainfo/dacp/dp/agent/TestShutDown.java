package com.asiainfo.dacp.dp.agent;

public class TestShutDown {
	public static void main(String[] args){
			Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
				public void run() {
					 System.out.println("shut ok");
				}
			}));
			for(int i=0;i<10;i++){
			    System.out.println("i="+i);
			    if(i==4){
				System.exit(0);
			    }
			    try {
				Thread.sleep(1000);
			    } catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			    }
			}
	}
}
