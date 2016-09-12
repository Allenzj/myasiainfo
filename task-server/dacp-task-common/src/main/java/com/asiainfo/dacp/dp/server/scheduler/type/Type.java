package com.asiainfo.dacp.dp.server.scheduler.type;

public class Type {
	interface BASE {
		int val();
	}
	/*** 资源级别 */
	public enum SRC_LV {
		/*** 默认--0 */
		DEEAULT,
		/*** 低 --1 */
		LOW,
		/*** 中 --2*/
		MID,
		/*** 高 --3*/
		HIGH;
		public static SRC_LV valueOf(int lv) {
			return SRC_LV.values()[lv];
		}
	}
	public enum MESSAG_TYPE {
		/*** 默认 */
		DEFAULT,
		/*** 执行 */
		EXECUTE,
		/*** 停止 */
		STOP,
		/*** 检测心跳 */
		CHECK_HEARTBEAT,
		/*** ACK */
		ACK,
		/*** 状态 */
		STATUS;
		
		public static MESSAG_TYPE valueOf(int _val) {
			return MESSAG_TYPE.values()[_val];
		}
	}
	/*** 发布状态 */
	public enum PUB_TYPE {
		/*** 未发布 */
		UN_PUB,
		/*** 已经发布 */
		PUB;
		public static PUB_TYPE valueOf(int _val) {
			return PUB_TYPE.values()[_val];
		}
	}
	public enum RUN_TYPE{
		/***顺序执行[0]*/
		EXECUTE_SERIAL,
		/***多重启动[1]*/
		EXECUTE_MORE, 
		/***单一启动[2]*/
		EXECUTE_ONECE, 
		/***周期内顺序启动[3]*/
		EXECUTE_SERIAL_IN_CYCLE,
		/***常驻进程[4]*/
		EXECUTE_FOREVER;
	}
	/*** drive type */
	public enum DRIVE_TYPE {
		/*** 时间驱动 */
		TIME_TRIGGER,
		/*** 事件驱动 */
		EVENT_TRIGGER;
	}
}
