package com.asiainfo.dacp.dp.server.scheduler.utils;

import java.util.Comparator;

import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;

/***
 * 排序类
 * 
 * @author wangyuanbin
 *
 */
public class ComparatorUtils {
	/**** 程序优先级 */
	public static Comparator<TaskLog> priLevelCmpare = new Comparator<TaskLog>() {
		public int compare(TaskLog t1, TaskLog t2) {
			String st1 = t1.getDateArgs();
			String st2 = t1.getDateArgs();
			if (st1.equals(st2)) {
				int pri1 = t1.getPriLevel();
				int pri2 = t2.getPriLevel();
				int res = pri1 - pri2;
				return res >0 ?-1:1;
			} else {
				return 0;
			}
		}
	};
	/**** 按时间排序 */
	public static Comparator<TaskLog> timeCmpare = new Comparator<TaskLog>() {
		public int compare(TaskLog t1, TaskLog t2) {
			String st1 = t1.getDateArgs();
			String st2 = t1.getDateArgs();
			if (st1.length() == st2.length()) {
				return  st2.compareTo(st1)>=1?-1:1;
			} else {
				return 0;
			}
		}
	};
}
