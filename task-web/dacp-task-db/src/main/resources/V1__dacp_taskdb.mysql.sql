CREATE TABLE `transflow_manual` (
  `FLOWCODE` VARCHAR(500) NOT NULL,
  `FLOWNAME` VARCHAR(500) NOT NULL,
  `CYCLETYPE` VARCHAR(32) DEFAULT NULL,
  `CREATER` VARCHAR(32) DEFAULT NULL,
  `CREATE_DATE` VARCHAR(32) DEFAULT NULL,
  `STATE` VARCHAR(32) DEFAULT NULL,
  `STATE_DATE` DATE DEFAULT NULL,
  `TEAM_CODE` VARCHAR(32) DEFAULT NULL,
  `XML` MEDIUMBLOB,
  `REMARK` VARCHAR(3000) DEFAULT NULL
) ENGINE=INNODB DEFAULT CHARSET=utf8;

CREATE TABLE `transdatamap_design_manual` (
  `FLOWCODE` VARCHAR(40) DEFAULT 'DEFAULT_FLOW',
  `TRANSNAME` VARCHAR(200) DEFAULT NULL,
  `SOURCE` VARCHAR(120) DEFAULT NULL,
  `SOURCETYPE` VARCHAR(10) DEFAULT NULL,
  `SOURCEFREQ` VARCHAR(20) DEFAULT NULL,
  `SOURCE_APPOINT` VARCHAR(20) DEFAULT NULL,
  `TARGET` VARCHAR(120) DEFAULT NULL,
  `TARGETTYPE` VARCHAR(10) DEFAULT NULL,
  `TARGETFREQ` VARCHAR(20) DEFAULT NULL,
  `NEED_DQ_CHECK` SMALLINT(1) DEFAULT NULL,
  KEY `proc_flowCode_index` (`FLOWCODE`)
);
CREATE TABLE `schedule_task_premisstion` (
  `run_freq` VARCHAR(12) DEFAULT NULL,
  `date_args` VARCHAR(24) DEFAULT NULL,
  `task_num` INT(10) UNSIGNED DEFAULT '0',
  `succ_num` INT(10) UNSIGNED DEFAULT '0',
  `fail_num` INT(10) UNSIGNED DEFAULT '0',
  `running_num` INT(11) DEFAULT '0',
  `other_num` INT(11) DEFAULT '0',
  `run_flag` INT(11) DEFAULT '1',
  `stat_time` VARCHAR(24) DEFAULT NULL,
  `oper_time` VARCHAR(24) DEFAULT NULL,
  `user_name` VARCHAR(30) DEFAULT NULL
);
CREATE TABLE PROC_SCHEDULE_EXE_CLASS
(
   XMLID                VARCHAR(32) NOT NULL,
   PROCTYPE             VARCHAR(32),
   PROCTYPE_NAME        VARCHAR(64),
   EXE_CLASS            VARCHAR(512),
   EXE_FUNC             VARCHAR(512),
   PRIMARY KEY (XMLID)
);


INSERT INTO `proc_schedule_exe_class` (`XMLID`, `PROCTYPE`, `PROCTYPE_NAME`, `EXE_CLASS`, `EXE_FUNC`) VALUES('1e5368429e1f11e5a1ec28d244996b89','shell','SHELL','com.asiainfo.dacp.execClass.ScheduleExe4Shell','run');
INSERT INTO `proc_schedule_exe_class` (`XMLID`, `PROCTYPE`, `PROCTYPE_NAME`, `EXE_CLASS`, `EXE_FUNC`) VALUES('36f9c37a9e1f11e5a1ec28d244996b80','tcl','TCL','com.asiainfo.dacp.execClass.ScheduleExe4TCL','run');
INSERT INTO `proc_schedule_exe_class` (`XMLID`, `PROCTYPE`, `PROCTYPE_NAME`, `EXE_CLASS`, `EXE_FUNC`) VALUES('36f9c37a9e1f11e5a1ec28d244996b81','dp','DP程序','com.asiainfo.dacp.execClass.ScheduleExe4DP','run');
INSERT INTO `proc_schedule_exe_class` (`XMLID`, `PROCTYPE`, `PROCTYPE_NAME`, `EXE_CLASS`, `EXE_FUNC`) VALUES('36f9c37a9e1f11e5a1ec28d244996b89','hive','HiveSQL','com.asiainfo.dacp.execClass.ScheduleExe4HQL','run');
INSERT INTO `proc_schedule_exe_class` (`XMLID`, `PROCTYPE`, `PROCTYPE_NAME`, `EXE_CLASS`, `EXE_FUNC`) VALUES('36f9c37a9e1f11e5a1ec28d244996c01','jar','java程序','com.asiainfo.dacp.execClass.ScheduleExe4JAVA','run');
INSERT INTO `proc_schedule_exe_class` (`XMLID`, `PROCTYPE`, `PROCTYPE_NAME`, `EXE_CLASS`, `EXE_FUNC`) VALUES('36f9c37a9e1f11e5a1ec28d244996c02','mapReduce','hadoop程序','com.asiainfo.dacp.execClass.ScheduleExe4Hadoop','run');
INSERT INTO `proc_schedule_exe_class` (`XMLID`, `PROCTYPE`, `PROCTYPE_NAME`, `EXE_CLASS`, `EXE_FUNC`) VALUES('36f9c37a9e1f11e5a1ec28d244996c03','python','python程序','com.asiainfo.dacp.execClass.ScheduleExe4Python','run');
INSERT INTO `proc_schedule_exe_class` (`XMLID`, `PROCTYPE`, `PROCTYPE_NAME`, `EXE_CLASS`, `EXE_FUNC`) VALUES('36f9c37a9e1f11e5a1ec28d244996c04','sql','sql脚本','com.asiainfo.dacp.execClass.ScheduleExe4SQL','run');

ALTER TABLE PROC_SCHEDULE_EXE_CLASS COMMENT '调度不同的程序类型执行类';

CREATE TABLE `dp_host_config` (
  `host_name` VARCHAR(64) NOT NULL,
  `hostcnname` VARCHAR(32) DEFAULT NULL,
  `login_type` VARCHAR(32) DEFAULT NULL,
  `ipaddr` VARCHAR(32) DEFAULT NULL,
  `port` VARCHAR(16) DEFAULT NULL,
  `chartset` VARCHAR(16) DEFAULT NULL,
  `workdir` VARCHAR(64) DEFAULT NULL,
  `user_name` VARCHAR(32) DEFAULT NULL,
  `password` VARCHAR(128) DEFAULT NULL,
  `op_user` VARCHAR(64) DEFAULT NULL,
  `op_time` VARCHAR(64) DEFAULT NULL
) ENGINE=INNODB DEFAULT CHARSET=utf8;

CREATE TABLE `proc_schedule_dim_group` (
  `XMLID` VARCHAR(32) NOT NULL,
  `GROUP_CODE` VARCHAR(64) DEFAULT NULL,
  `GROUP_VALUE` VARCHAR(128) DEFAULT NULL,
  `GROUP_SEQ` INT(6) DEFAULT NULL,
  `REMARK` VARCHAR(200) DEFAULT NULL,
  PRIMARY KEY (`XMLID`)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

CREATE TABLE `proc_schedule_dim` (
  `XMLID` VARCHAR(32) NOT NULL,
  `DIM_GROUP_ID` VARCHAR(64) DEFAULT NULL COMMENT '关联proc_schedule_dim_group表XMLID',
  `DIM_CODE` VARCHAR(64) DEFAULT NULL,
  `DIM_VALUE` VARCHAR(128) DEFAULT NULL,
  `DIM_SEQ` INT(6) DEFAULT NULL,
  `REMARK` VARCHAR(200) DEFAULT NULL,
  PRIMARY KEY (`XMLID`)
);

ALTER TABLE PROC_SCHEDULE_DIM COMMENT '调度系统维表';

CREATE TABLE proc_schedule_runpara (
  xmlid VARCHAR(100) DEFAULT NULL,
  orderid INT(11) DEFAULT NULL,
  run_para VARCHAR(100) DEFAULT NULL,
  run_para_value VARCHAR(100) DEFAULT NULL
) ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE PROC_SCHEDULE_RUNPARA COMMENT '调度运行参数表，存放调度任务需要的运行程序参数。';

CREATE TABLE aietl_agentnode (
  AGENT_ID SMALLINT(6) DEFAULT '-1',
  AGENT_NAME VARCHAR(50) DEFAULT NULL,
  TASK_TYPE VARCHAR(10) DEFAULT NULL,
  NODE_IP VARCHAR(50) DEFAULT NULL,
  NODE_TCP_PORT INT(11) DEFAULT NULL,
  NODE_UDP_PORT INT(11) DEFAULT NULL,
  NODE_STATUS INT(11) DEFAULT NULL,
  STATUS_CHGTIME VARCHAR(20) DEFAULT NULL,
  HOST_NAME VARCHAR(100) DEFAULT NULL,
  IPS SMALLINT(100) DEFAULT NULL,
  CURIPS SMALLINT(6) DEFAULT '0',
  SCRIPT_PATH VARCHAR(128) DEFAULT NULL,
  PLATFORM VARCHAR(32) DEFAULT NULL
) ENGINE=INNODB DEFAULT CHARSET=utf8;

/*Table structure for table proc */
/*
CREATE TABLE proc (
  XMLID VARCHAR(32) NOT NULL,
  PROC_NAME VARCHAR(200) NOT NULL DEFAULT '',
  INTERCODE VARCHAR(20) DEFAULT NULL,
  PROCCNNAME VARCHAR(120) DEFAULT NULL,
  INORFULL VARCHAR(4) DEFAULT NULL,
  CYCLETYPE VARCHAR(60) DEFAULT NULL,
  TOPICNAME VARCHAR(60) DEFAULT NULL,
  STARTDATE VARCHAR(16) DEFAULT NULL,
  STARTTIME TIME DEFAULT NULL,
  ENDTIME TIME DEFAULT NULL,
  PARENTPROC VARCHAR(32) DEFAULT NULL,
  REMARK VARCHAR(255) DEFAULT NULL,
  EFF_DATE TIMESTAMP ,
  CREATER VARCHAR(32) DEFAULT NULL,
  `STATE` VARCHAR(32) DEFAULT NULL,
  `STATE_DATE` TIMESTAMP NULL DEFAULT NULL,
  PROCTYPE VARCHAR(32) DEFAULT NULL,
  PATH VARCHAR(200) DEFAULT NULL,
  RUNMODE VARCHAR(32) DEFAULT NULL,
  DBNAME VARCHAR(32) DEFAULT NULL,
  DBUSER VARCHAR(32) DEFAULT NULL,
  CURTASKCODE VARCHAR(32) DEFAULT NULL,
  DESIGNER VARCHAR(32) DEFAULT NULL,
  EXTEND_CFG VARCHAR(2048) DEFAULT NULL,
  AUDITER VARCHAR(32) DEFAULT NULL,
  DEPLOYER VARCHAR(32) DEFAULT NULL,
  RUNPARA VARCHAR(300) DEFAULT NULL,
  RUNDURA VARCHAR(32) DEFAULT NULL,
  TEAM_CODE VARCHAR(32) DEFAULT NULL,
  DEVELOPER VARCHAR(32) DEFAULT NULL,
  CURDUTYER VARCHAR(32) DEFAULT NULL,
  VERSEQ INT(11) DEFAULT NULL,
  LEVEL_VAL VARCHAR(32) DEFAULT NULL,
  AREACODE VARCHAR(16) DEFAULT NULL,
  TOPICCODE VARCHAR(32) DEFAULT NULL,
  XML LONGTEXT,
  PRIMARY KEY (XMLID,PROC_NAME)
) ENGINE=INNODB DEFAULT CHARSET=utf8;
*/

/*Table structure for table proc_schedule_info */


CREATE TABLE `proc_schedule_info` (
  `XMLID` VARCHAR(100) NOT NULL,
  `PROC_NAME` VARCHAR(200) DEFAULT NULL COMMENT '程序名',
  `AGENT_CODE` VARCHAR(32) DEFAULT NULL,
  `TRIGGER_TYPE` INT(11) DEFAULT NULL COMMENT '0: 时间触发（3~7行字段）\n            1：事件触发\n            如果是事件触发，则不配置st_day,st_time,\n            cron_exp字段\n            ',
  `RUN_FREQ` VARCHAR(32) DEFAULT NULL COMMENT '天（day）/月(month)/\n            小时(hour)/分钟(minute)/ 手工(manul)\n            ',
  `ST_DAY` VARCHAR(20) DEFAULT NULL,
  `ST_TIME` VARCHAR(20) DEFAULT NULL,
  `CRON_EXP` VARCHAR(32) DEFAULT NULL,
  `PROC_GROUP` VARCHAR(32) DEFAULT NULL,
  `PRI_LEVEL` INT(11) DEFAULT NULL COMMENT '程序优先级：1~20',
  `PLATFORM` VARCHAR(32) DEFAULT NULL COMMENT 'Agent组/接入平台',
  `RESOUCE_LEVEL` INT(11) DEFAULT NULL COMMENT '资源级别：高(3)，中(2)，低(1)',
  `REDO_NUM` INT(11) DEFAULT NULL COMMENT '大于或等于0',
  `ALARM_CLASS` VARCHAR(32) DEFAULT NULL COMMENT '0/1【短信/电话】',
  `EXEC_CLASS` VARCHAR(32) DEFAULT NULL COMMENT '重庆再用/关联proc_func_def_java的FUN_ID字段',
  `DATE_ARGS` VARCHAR(32) DEFAULT NULL COMMENT '0：顺序启动;1:多重启动;2:唯一启动:3 顺序启动但是不依赖月末最后一天',
  `MUTI_RUN_FLAG` INT(11) DEFAULT NULL,
  `DURA_MAX` INT(11) DEFAULT NULL COMMENT '不为0的整数【重庆在用】\n            单位为分钟/根据运行平均时长加上浮比',
  `EFF_TIME` VARCHAR(20) DEFAULT NULL COMMENT '（YYYY-MM-DD)',
  `EXP_TIME` VARCHAR(20) DEFAULT NULL COMMENT '（YYYY-MM-DD)',
  `ON_FOCUS` INT(11) DEFAULT NULL COMMENT '1/0',
  `REDO_INTERVAL` INT(11) DEFAULT NULL,
  `ALLOW_EXEC_TIME` VARCHAR(20) DEFAULT NULL,
  `TIME_WIN` VARCHAR(8) DEFAULT NULL COMMENT '杭州：最迟完时间\n            重庆：到点执行时间\n            ',
  `FLOWCODE` VARCHAR(32) DEFAULT 'DEFAULT_FLOW',
  `MAX_RUN_HOURS` INT(6) DEFAULT NULL COMMENT '任务最长运行时间',
  `EXEC_PROC` VARCHAR(200) DEFAULT NULL COMMENT '运行程序',
  `PROC_TYPE` VARCHAR(32) DEFAULT NULL COMMENT '任务类型',
  `EXEC_PATH` VARCHAR(200) DEFAULT NULL COMMENT '执行路径',
   PRIMARY KEY (`XMLID`)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE PROC_SCHEDULE_INFO COMMENT '程序调度信息表';

/*Table structure for table proc_schedule_log */
CREATE TABLE proc_schedule_log (
  seqno VARCHAR(50) DEFAULT NULL,
  xmlid VARCHAR(32) DEFAULT NULL,
  agent_code VARCHAR(32) DEFAULT NULL,
  run_freq VARCHAR(10) DEFAULT NULL,
  proc_name VARCHAR(200) DEFAULT NULL,
  flowcode VARCHAR(500) DEFAULT NULL,
  platform VARCHAR(20) DEFAULT NULL,
  task_state SMALLINT(6) DEFAULT NULL,
  status_time VARCHAR(20) DEFAULT NULL,
  start_time VARCHAR(20) DEFAULT NULL,
  exec_time VARCHAR(20) DEFAULT NULL,
  end_time VARCHAR(20) DEFAULT NULL,
  use_time VARCHAR(20) DEFAULT NULL,
  retrynum SMALLINT(6) DEFAULT NULL,
  errcode SMALLINT(6) DEFAULT NULL,
  proc_date VARCHAR(20) DEFAULT NULL,
  alarm_flag INT(6) DEFAULT '0',
  date_args VARCHAR(20) DEFAULT NULL,
  queue_flag SMALLINT(6) DEFAULT '0',
  trigger_flag SMALLINT(6) DEFAULT '0',
  pri_level SMALLINT(6) DEFAULT '1',
  pid VARCHAR(10) DEFAULT NULL,
  team_code VARCHAR(32) DEFAULT NULL,
  time_win VARCHAR(20) DEFAULT NULL,
  path VARCHAR(300) DEFAULT NULL,
  runpara VARCHAR(300) DEFAULT NULL,
  proctype VARCHAR(32) DEFAULT NULL,
  VALID_FLAG INT(11) DEFAULT NULL COMMENT '0 有效 1失效',
  RETURN_CODE INT(11) DEFAULT NULL COMMENT 'dp任务步骤返回号',
  KEY idx_seqno (seqno),
  KEY idx_proc_name_date_args (proc_name,date_args)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

/*Table structure for table proc_schedule_meta_log */

CREATE TABLE proc_schedule_meta_log (
  seqno VARCHAR(50) DEFAULT NULL,
  proc_name VARCHAR(200) DEFAULT NULL,
  date_args VARCHAR(20) DEFAULT NULL,
  flowcode VARCHAR(500) DEFAULT NULL,
  proc_date VARCHAR(20) DEFAULT NULL,
  target VARCHAR(50) DEFAULT NULL,
  data_time VARCHAR(20) DEFAULT NULL,
  trigger_flag SMALLINT(6) DEFAULT '0',
  generate_time VARCHAR(20) DEFAULT NULL,
  need_dq_check SMALLINT(1) DEFAULT '0',
  dq_check_res SMALLINT(1) DEFAULT '1',
  KEY idx_target_datatime (target,data_time)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

/*Table structure for table proc_schedule_platform */

CREATE TABLE proc_schedule_platform (
  platform VARCHAR(32) DEFAULT NULL,
  platform_cnname VARCHAR(32) DEFAULT NULL,
  ips SMALLINT(6) DEFAULT NULL,
  curips SMALLINT(6) DEFAULT NULL,
  team_code VARCHAR(1000) DEFAULT NULL
) ENGINE=INNODB DEFAULT CHARSET=utf8;

/*Table structure for table proc_schedule_script_log */


CREATE TABLE proc_schedule_script_log (
  seqno VARCHAR(50) DEFAULT NULL,
  proc_name VARCHAR(200) DEFAULT NULL,
  flowcode VARCHAR(500) DEFAULT NULL,
  app_log LONGTEXT,
  KEY idx_seqno (seqno)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

/*Table structure for table proc_schedule_source_log */

CREATE TABLE proc_schedule_source_log (
  seqno VARCHAR(50) DEFAULT NULL,
  proc_name VARCHAR(200) DEFAULT NULL,
  date_args VARCHAR(20) DEFAULT NULL,
  flowcode VARCHAR(500) DEFAULT NULL,
  source VARCHAR(50) DEFAULT NULL,
  source_type VARCHAR(10) DEFAULT NULL,
  data_time VARCHAR(20) DEFAULT NULL,
  check_flag SMALLINT(6) DEFAULT '0',
  KEY idx_seqno (seqno),
  KEY idx_source (source)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

/*Table structure for table proc_schedule_target_log */

CREATE TABLE proc_schedule_target_log (
  seqno VARCHAR(50) DEFAULT NULL,
  proc_name VARCHAR(200) DEFAULT NULL,
  date_args VARCHAR(20) DEFAULT NULL,
  flowcode VARCHAR(500) DEFAULT NULL,
  proc_date VARCHAR(20) DEFAULT NULL,
  target VARCHAR(50) DEFAULT NULL,
  data_time VARCHAR(20) DEFAULT NULL,
  trigger_flag SMALLINT(6) DEFAULT '0',
  generate_time VARCHAR(20) DEFAULT NULL,
  need_dq_check SMALLINT(1) DEFAULT '0',
  dq_check_res SMALLINT(1) DEFAULT '1'
) ENGINE=INNODB DEFAULT CHARSET=utf8;

/*Table structure for table transdatamap_design */

CREATE TABLE transdatamap_design (
  XMLID VARCHAR(64) NOT NULL,
  FLOWCODE VARCHAR(500) DEFAULT 'DEFAULT_FLOW',
  transname VARCHAR(200) DEFAULT NULL,
  SOURCE VARCHAR(120) DEFAULT NULL,
  SOURCETYPE VARCHAR(10) DEFAULT NULL,
  SOURCEFREQ VARCHAR(20) DEFAULT NULL,
  SOURCE_APPOINT VARCHAR(100) DEFAULT NULL,
  TARGET VARCHAR(120) DEFAULT NULL,
  TARGETTYPE VARCHAR(10) DEFAULT NULL,
  TARGETFREQ VARCHAR(20) DEFAULT NULL,
  NEED_DQ_CHECK SMALLINT(1) DEFAULT NULL,
  PRIMARY KEY (XMLID)
) ENGINE=MYISAM DEFAULT CHARSET=utf8;


CREATE TABLE `proc_schedule_alarm_info` (
  `xmlid` varchar(100) NOT NULL DEFAULT '' COMMENT '主键xmlid',
  `proc_xmlid` varchar(200) DEFAULT NULL COMMENT '程序xmlid',
  `sms_group_id` varchar(64) DEFAULT NULL COMMENT '短信用户组',
  `alarm_type` varchar(20) DEFAULT NULL COMMENT '告警类型',
  `due_time_cron` varchar(20) DEFAULT NULL COMMENT '告警时间cron表达式',
  `offset` varchar(2) DEFAULT NULL COMMENT '告警批次偏移量',
  `max_send_count` varchar(2) DEFAULT NULL COMMENT '最大发送次数',
  `interval_time` varchar(5) DEFAULT NULL COMMENT '发送时间间隔',
  `is_valid` varchar(1) DEFAULT NULL COMMENT '告警信息是否生效',
  `flag` varchar(1) DEFAULT NULL COMMENT '通知server处理：0，未处理｜1，已处理'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `proc_schedule_alarm_log` (
  `xmlid` varchar(100) DEFAULT NULL COMMENT '主键xmlid',
  `proc_xmlid` varchar(200) DEFAULT NULL COMMENT '程序xmlid',
  `proc_name` varchar(200) NOT NULL DEFAULT '' COMMENT '程序名称',
  `proc_date_args` varchar(20) NOT NULL DEFAULT '' COMMENT '告警批次',
  `alarm_type` varchar(20) DEFAULT NULL COMMENT '告警类型',
  `alarm_content` text COMMENT '告警内容',
  `alarm_time` varchar(20) DEFAULT NULL COMMENT '告警时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `proc_schedule_alarm_send_log` (
  `xmlid` varchar(100) DEFAULT NULL,
  `proc_xmlid` varchar(200) DEFAULT NULL COMMENT '程序xmid',
  `proc_name` varchar(200) DEFAULT NULL COMMENT '程序名',
  `proc_date_args` varchar(20) DEFAULT NULL COMMENT '告警批次',
  `send_phone` varchar(20) DEFAULT NULL COMMENT '发送告警号码',
  `send_content` text COMMENT '发送告警内容',
  `send_time` varchar(20) DEFAULT NULL COMMENT '发送告警时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sms_log` (
  `phonenumber` varchar(20) DEFAULT NULL COMMENT '模拟发送告警短信的号码',
  `smscontent` varchar(1000) DEFAULT NULL COMMENT '模拟发送告警短信的内容'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*Table structure for table sms_message_group */

CREATE TABLE sms_message_group (
  SMS_GROUP_ID VARCHAR(100) DEFAULT NULL COMMENT '用户组',
  SMS_GROUP_NAME VARCHAR(200) DEFAULT NULL COMMENT '用户组名称'
) ENGINE=INNODB DEFAULT CHARSET=utf8;

/*Data for the table sms_message_group */

INSERT  INTO sms_message_group(SMS_GROUP_ID,SMS_GROUP_NAME) VALUES ('G0001','经分团队'),('G0002','一经模块'),('G0003','二经模块'),('G0004','MIS模块');

/*Table structure for table sms_message_group_member */

CREATE TABLE sms_message_group_member (
  SMS_GROUP_ID VARCHAR(100) DEFAULT NULL COMMENT '用户组',
  MEMBER_NAME VARCHAR(20) DEFAULT NULL COMMENT '成员',
  PHONENUM VARCHAR(15) DEFAULT NULL COMMENT '发送号码',
  `STATUS` VARCHAR(1) DEFAULT NULL COMMENT '是否发送 0 发送 1不发送'
) ENGINE=INNODB DEFAULT CHARSET=utf8;

/*Data for the table sms_message_group_member */

INSERT  INTO sms_message_group_member(SMS_GROUP_ID,MEMBER_NAME,PHONENUM,`STATUS`) VALUES ('G0001','heziming','138000000001','0'),('G0002','sufan','138000000002','0'),('G0002','niuzhenjia','138000000003','1'),('G0003','wuliang','138000000004','0');

/*Table structure for table sms_message_group_task */

CREATE TABLE `sms_message_group_task` (
  `XMLID` VARCHAR(32) NOT NULL,
  `PROC_NAME` VARCHAR(200) DEFAULT NULL COMMENT '程序名',
  `SMS_GROUP_ID` VARCHAR(64) DEFAULT NULL COMMENT '短信用户组',
  `WARNING_TYPE` VARCHAR(20) DEFAULT NULL COMMENT '告警类型',
  `DUE_TIME_CRON` VARCHAR(20) DEFAULT NULL COMMENT '告告警检查时间',
  `OFFSET` VARCHAR(2) DEFAULT NULL COMMENT '告警便宜批次',
  `MAX_SEND_CNT` VARCHAR(2) DEFAULT NULL COMMENT '最大发送次数',
  `INTERVAL_TIME` VARCHAR(5) DEFAULT NULL COMMENT '发送时间间隔',
  `IS_SEND` VARCHAR(1) DEFAULT NULL COMMENT '该程序是否发送短信 0 发送 1不发送',
  PRIMARY KEY (`XMLID`)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

/*Data for the table sms_message_group_task */


/*Table structure for table warning_type */



CREATE TABLE warning_type (
  TYPE_CODE VARCHAR(5) DEFAULT NULL COMMENT '告警类型',
  TYPE_NAME VARCHAR(64) DEFAULT NULL COMMENT '告警名称'
) ENGINE=INNODB DEFAULT CHARSET=utf8;

/*Data for the table warning_type */

INSERT  INTO warning_type(TYPE_CODE,TYPE_NAME) VALUES ('1','到点未跑完'),('2','程序运行错误');

/*
CREATE TABLE `tablefile` (
  `XMLID` VARCHAR(64) NOT NULL COMMENT '对象ID',
  `DATANAME` VARCHAR(120) NOT NULL COMMENT '表名',
  `DATACNNAME` VARCHAR(120) NOT NULL COMMENT '中文名',
  `TEAM_CODE` VARCHAR(32) DEFAULT NULL COMMENT '团队代码',
  `SCHEMA_NAME` VARCHAR(120) DEFAULT NULL COMMENT '模式名',
  `DATATYPE` VARCHAR(20) DEFAULT NULL COMMENT '数据类型（V:视图、T:表）',
  `DBNAME` VARCHAR(32) DEFAULT NULL COMMENT '存储数据库(metadbcfg.dbname)',
  `TABSPACE` VARCHAR(120) DEFAULT NULL COMMENT '表空间.如果是hive存放路径',
  `INDEX_TABSPACE` VARCHAR(120) DEFAULT NULL COMMENT '索引空间',
  `LEVEL_VAL` VARCHAR(32) NOT NULL COMMENT '层次（ODS、DWD、DW、DM、ST）',
  `RIGHTLEVEL` VARCHAR(32) DEFAULT NULL COMMENT '敏感级别',
  `DELIMITER` CHAR(10) DEFAULT NULL COMMENT '分割符(hadoop平台文件分割。也可作为接口平台入库文件依据)',
  `SPLITTYPE` VARCHAR(8) DEFAULT NULL,
  `TOPICNAME` VARCHAR(32) DEFAULT NULL COMMENT '主题（客户域\n            用户域\n            服务域\n            行为域\n            资源域\n            事件域\n            账务域\n            资源域\n            财务域\n            维表域\n            集团用户\n            专题分析\n            KPI分析\n            多维成本\n            重点应用\n            ）',
  `CYCLETYPE` VARCHAR(32) DEFAULT NULL COMMENT '周期类型(日、周、月、年、多日、多月、多年）',
  `COMPRESSION` VARCHAR(1) DEFAULT NULL COMMENT '是否压缩(Y/N)',
  `FIELDNUM` INT(11) DEFAULT '0' COMMENT '字段个数',
  `TABSIZES` DECIMAL(15,0) DEFAULT '0' COMMENT '表大小',
  `ROWNUM_VAL` DECIMAL(10,0) DEFAULT '0' COMMENT '记录条数',
  `REFCOUNT` INT(11) DEFAULT '0' COMMENT '引用次数',
  `EFF_DATE` DATE NOT NULL COMMENT '创建时间',
  `CREATER` VARCHAR(32) NOT NULL COMMENT '创建者',
  `STATE` VARCHAR(32) NOT NULL DEFAULT 'NEW' COMMENT '当前状态（新建、审核、发布、未上线、开放()）',
  `STATE_DATE` DATE DEFAULT NULL COMMENT '状态时间',
  `DEVELOPER` VARCHAR(32) DEFAULT NULL COMMENT '开发者',
  `CURDUTYER` VARCHAR(32) DEFAULT NULL COMMENT '负责人（如果是新建，与CREATER一样。根据状态修改人员而变化）',
  `VERSEQ` INT(11) DEFAULT NULL COMMENT '版本号',
  `DESIGNER` VARCHAR(32) DEFAULT NULL COMMENT '设计人员',
  `AUDITER` VARCHAR(32) DEFAULT NULL COMMENT '审核人员',
  `DATEFIELD` VARCHAR(32) DEFAULT NULL COMMENT '生命周期',
  `DATEFMT` VARCHAR(16) DEFAULT NULL COMMENT '生命周期单位（日、月、永久)',
  `DATETYPE` VARCHAR(16) DEFAULT NULL,
  `EXTEND_CFG` VARCHAR(1024) DEFAULT NULL COMMENT '{location:"文件路径",sprate:''分隔符}',
  `REMARK` VARCHAR(512) DEFAULT NULL COMMENT '备注',
  `OPEN_STATE` VARCHAR(32) DEFAULT NULL COMMENT '开放状态',
  PRIMARY KEY (`XMLID`,`DATANAME`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COMMENT='数据表.存储RDB、hive元模型';
*/

CREATE TABLE `schedule_op_log` (
  `OP_OBJ` VARCHAR(50) NOT NULL DEFAULT '',
  `OP_USER` VARCHAR(50) DEFAULT NULL,
  `OP_USER_IP` VARCHAR(50) DEFAULT NULL,
  `OP_TYPE` VARCHAR(20) DEFAULT NULL,
  `OP_SQL` VARCHAR(1000) DEFAULT NULL,
  `OP_STATE` VARCHAR(10) DEFAULT NULL,
  `OP_TIME` DATETIME DEFAULT NULL
) ENGINE=INNODB DEFAULT CHARSET=utf8 COMMENT='调度人工干预日志表';

CREATE TABLE `aietl_servernode` (
  `server_id` VARCHAR(36) DEFAULT NULL,
  `host_name` VARCHAR(100) DEFAULT NULL COMMENT '关联dp_host_config表host_name',
  `deploy_path` VARCHAR(128) DEFAULT NULL,
  `server_status` INT(11) DEFAULT NULL,
  `status_time` VARCHAR(20) DEFAULT NULL
) ENGINE=INNODB DEFAULT CHARSET=utf8 COMMENT='server状态监控日志表';

CREATE TABLE `schedule_task_supplement` (
  `xmlid` VARCHAR(200) NOT NULL,
  `proc_name` VARCHAR(200) DEFAULT NULL,
  `next_time` BIGINT(20) DEFAULT NULL,
  `run_freq` VARCHAR(6) DEFAULT NULL,
  PRIMARY KEY (`xmlid`)
) ENGINE=INNODB DEFAULT CHARSET=utf8;


insert  into `proc_schedule_dim`(`XMLID`,`DIM_GROUP_ID`,`DIM_CODE`,`DIM_VALUE`,`DIM_SEQ`,`REMARK`) values ('05497f74972eac7b34f02ebbcf846e94','caa2bcc8b69964f1f271dd3c595ae838','year','年',1,NULL);
insert  into `proc_schedule_dim`(`XMLID`,`DIM_GROUP_ID`,`DIM_CODE`,`DIM_VALUE`,`DIM_SEQ`,`REMARK`) values ('2a69c91094042071e1fab08d41112c04','34c795581b15b1333a1b39843e1de6a9','KPI层','KPI层',NULL,NULL);
insert  into `proc_schedule_dim`(`XMLID`,`DIM_GROUP_ID`,`DIM_CODE`,`DIM_VALUE`,`DIM_SEQ`,`REMARK`) values ('556e76f869dbcfdf63794efb6d26e3da','caa2bcc8b69964f1f271dd3c595ae838','minute','分钟',5,NULL);
insert  into `proc_schedule_dim`(`XMLID`,`DIM_GROUP_ID`,`DIM_CODE`,`DIM_VALUE`,`DIM_SEQ`,`REMARK`) values ('6291d9d652eeb078f5fc6868533b9f6c','4cf958a1f37e961fa73e9293c757761e','O域','O域',NULL,NULL);
insert  into `proc_schedule_dim`(`XMLID`,`DIM_GROUP_ID`,`DIM_CODE`,`DIM_VALUE`,`DIM_SEQ`,`REMARK`) values ('79964f58b4dacf412c23b0ef68ee7fd2','caa2bcc8b69964f1f271dd3c595ae838','hour','小时',4,NULL);
insert  into `proc_schedule_dim`(`XMLID`,`DIM_GROUP_ID`,`DIM_CODE`,`DIM_VALUE`,`DIM_SEQ`,`REMARK`) values ('926863e9b34fa61402346d0338614b31','4cf958a1f37e961fa73e9293c757761e','B域','B域',NULL,NULL);
insert  into `proc_schedule_dim`(`XMLID`,`DIM_GROUP_ID`,`DIM_CODE`,`DIM_VALUE`,`DIM_SEQ`,`REMARK`) values ('cb116776012439922e8f41b546d47371','caa2bcc8b69964f1f271dd3c595ae838','month','月',2,NULL);
insert  into `proc_schedule_dim`(`XMLID`,`DIM_GROUP_ID`,`DIM_CODE`,`DIM_VALUE`,`DIM_SEQ`,`REMARK`) values ('e64abf37d4a29b9322c17645fb8cdd39','caa2bcc8b69964f1f271dd3c595ae838','day','日',3,NULL);
insert  into `proc_schedule_dim`(`XMLID`,`DIM_GROUP_ID`,`DIM_CODE`,`DIM_VALUE`,`DIM_SEQ`,`REMARK`) values ('f29645ccfc0f28c6f609516c794752e0','34c795581b15b1333a1b39843e1de6a9','DW层','DW层',NULL,NULL);

insert into `proc_schedule_dim_group` (`XMLID`, `GROUP_CODE`, `GROUP_VALUE`, `GROUP_SEQ`, `REMARK`) values('34c795581b15b1333a1b39843e1de6a9','LEVEL_TYPE','层次',NULL,'层次');
insert into `proc_schedule_dim_group` (`XMLID`, `GROUP_CODE`, `GROUP_VALUE`, `GROUP_SEQ`, `REMARK`) values('4cf958a1f37e961fa73e9293c757761e','TOPIC_TYPE','主题',NULL,'主题');
insert into `proc_schedule_dim_group` (`XMLID`, `GROUP_CODE`, `GROUP_VALUE`, `GROUP_SEQ`, `REMARK`) values('caa2bcc8b69964f1f271dd3c595ae838','CYCLE_TYPE','周期类型',NULL,'周期类型');


insert into `metamodel` (`MODELCODE`, `PARENTCODE`, `MODELNAME`, `MODELTYPE`, `CRETIME`, `REMARK`, `CLASSTYPE`, `SEQ`, `IMAGEINDEX`, `URL`, `FRAME`, `COUNTSQL`, `IMAGES`, `STATE`) values('task_cfg',NULL,'调度配置',NULL,NULL,NULL,NULL,'2',NULL,'','desktop',NULL,NULL,'on');
insert into `metamodel` (`MODELCODE`, `PARENTCODE`, `MODELNAME`, `MODELTYPE`, `CRETIME`, `REMARK`, `CLASSTYPE`, `SEQ`, `IMAGEINDEX`, `URL`, `FRAME`, `COUNTSQL`, `IMAGES`, `STATE`) values('task_cfg_02','task_cfg','任务配置',NULL,NULL,NULL,NULL,'2',NULL,'ftl/task/miniProcList?team_code={team_code}',NULL,NULL,'fa fa-user text-info','on');
insert into `metamodel` (`MODELCODE`, `PARENTCODE`, `MODELNAME`, `MODELTYPE`, `CRETIME`, `REMARK`, `CLASSTYPE`, `SEQ`, `IMAGEINDEX`, `URL`, `FRAME`, `COUNTSQL`, `IMAGES`, `STATE`) values('task_cfg_03','task_cfg','数据模型',NULL,NULL,NULL,NULL,'3',NULL,'task/model_table',NULL,NULL,'fa fa-users text-success','on');
insert into `metamodel` (`MODELCODE`, `PARENTCODE`, `MODELNAME`, `MODELTYPE`, `CRETIME`, `REMARK`, `CLASSTYPE`, `SEQ`, `IMAGEINDEX`, `URL`, `FRAME`, `COUNTSQL`, `IMAGES`, `STATE`) values('task_cfg_04','task_cfg','数据字典',NULL,NULL,NULL,NULL,'4',NULL,'ftl/task/model_dictionary',NULL,NULL,'fa fa-users text-success','on');
insert into `metamodel` (`MODELCODE`, `PARENTCODE`, `MODELNAME`, `MODELTYPE`, `CRETIME`, `REMARK`, `CLASSTYPE`, `SEQ`, `IMAGEINDEX`, `URL`, `FRAME`, `COUNTSQL`, `IMAGES`, `STATE`) values('task_cfg_05','task_cfg','Agent配置',NULL,NULL,NULL,NULL,'5',NULL,'ftl/task/agentList',NULL,NULL,'fa fa-eye text-warning-dk','on');
insert into `metamodel` (`MODELCODE`, `PARENTCODE`, `MODELNAME`, `MODELTYPE`, `CRETIME`, `REMARK`, `CLASSTYPE`, `SEQ`, `IMAGEINDEX`, `URL`, `FRAME`, `COUNTSQL`, `IMAGES`, `STATE`) values('task_monitor',NULL,'调度监控',NULL,NULL,NULL,NULL,'1',NULL,'','desktop',NULL,NULL,'on');
insert into `metamodel` (`MODELCODE`, `PARENTCODE`, `MODELNAME`, `MODELTYPE`, `CRETIME`, `REMARK`, `CLASSTYPE`, `SEQ`, `IMAGEINDEX`, `URL`, `FRAME`, `COUNTSQL`, `IMAGES`, `STATE`) values('task_monitor_01','task_monitor','任务监控',NULL,NULL,NULL,NULL,'1',NULL,'task/taskMonitor',NULL,NULL,'fa fa-puzzle-piece text-success','on');
insert into `metamodel` (`MODELCODE`, `PARENTCODE`, `MODELNAME`, `MODELTYPE`, `CRETIME`, `REMARK`, `CLASSTYPE`, `SEQ`, `IMAGEINDEX`, `URL`, `FRAME`, `COUNTSQL`, `IMAGES`, `STATE`) values('task_monitor_02','task_monitor','Agent监控',NULL,NULL,NULL,NULL,'2',NULL,'ftl/task/agentMonitor',NULL,NULL,'fa fa-user text-info','on');
insert into `metamodel` (`MODELCODE`, `PARENTCODE`, `MODELNAME`, `MODELTYPE`, `CRETIME`, `REMARK`, `CLASSTYPE`, `SEQ`, `IMAGEINDEX`, `URL`, `FRAME`, `COUNTSQL`, `IMAGES`, `STATE`) values('task_monitor_03','task_monitor','手工任务',NULL,NULL,NULL,NULL,'3',NULL,'ftl/task/scheduleManual',NULL,NULL,'fa fa-user text-info','on');
insert into `metamodel` (`MODELCODE`, `PARENTCODE`, `MODELNAME`, `MODELTYPE`, `CRETIME`, `REMARK`, `CLASSTYPE`, `SEQ`, `IMAGEINDEX`, `URL`, `FRAME`, `COUNTSQL`, `IMAGES`, `STATE`) values('task_monitor_11','task_monitor','数据监控',NULL,NULL,NULL,NULL,'3',NULL,'ftl/task/dataMonitor',NULL,NULL,'fa fa-user text-info','on');
insert into `metamodel` (`MODELCODE`, `PARENTCODE`, `MODELNAME`, `MODELTYPE`, `CRETIME`, `REMARK`, `CLASSTYPE`, `SEQ`, `IMAGEINDEX`, `URL`, `FRAME`, `COUNTSQL`, `IMAGES`, `STATE`) values('sysmgr_host_list','sysmgr','主机配置',NULL,NULL,NULL,'TFMoniteShow','6','1','ftl/task/miniHostList','content',NULL,'fa fa-list-alt','on');
