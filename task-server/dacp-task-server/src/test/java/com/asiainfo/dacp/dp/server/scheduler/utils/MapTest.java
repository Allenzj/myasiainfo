package com.asiainfo.dacp.dp.server.scheduler.utils;

import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

public class MapTest {
	private static int size = 1000000;
	public static Map<String, Integer> map = new ConcurrentHashMap<String, Integer>();
	
	public static void main(String[] args) {
		for (int i = 1; i <= size-1; i++) {
			String key = "" + i;
			map.put(key, i);
		};
		new Thread(new Runnable() {
			public void run() {
				Random random = new Random();
				while (true) {
					Map<String, Integer> tmpMap = new ConcurrentHashMap<String, Integer>();
					for (int i = 1; i <= size-1; i++) {
						String key = "" + i;
						tmpMap.put(key, random.nextInt(size-1)+1);
					}
					Map<String, Integer> tmp = MapTest.map ;
					MapTest.map = tmpMap;
					tmp.clear();
					try {
						Thread.sleep(10);
					} catch (InterruptedException e) {

					}
				}

			}

		}).start();
		for(int i = 0 ; i<10 ;i++){
			new Thread(new Test()).start();
		}
	}
	public static class Test implements Runnable {
		public void run() {
			Random random = new Random();
			while (true) {
				String key = "" + (random.nextInt(size-1) + 1);
				Integer inter = MapTest.map.get(key);
				String val = "" + inter;
				System.out.println("key:" + key + ",value:" + val);
				if (null == inter) {
					System.out.println("break-key:" + key + ",value:" + val);
					System.exit(-1);
					break;
				}
				try {
					Thread.sleep(1);
				} catch (InterruptedException e) {
				}
			}
		}
		
	}

}
