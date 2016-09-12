package com.asiainfo.dacp.dp.server.scheduler.dao;

import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.asiainfo.dacp.dp.common.RunStatus;
import com.asiainfo.dacp.dp.server.scheduler.bean.AgentIps;
import com.asiainfo.dacp.dp.server.scheduler.bean.ClassInfo;
import com.asiainfo.dacp.dp.server.scheduler.bean.MetaLog;
import com.asiainfo.dacp.dp.server.scheduler.bean.PlatformConfig;
import com.asiainfo.dacp.dp.server.scheduler.bean.Relationship;
import com.asiainfo.dacp.dp.server.scheduler.bean.RunPara;
import com.asiainfo.dacp.dp.server.scheduler.bean.SourceLog;
import com.asiainfo.dacp.dp.server.scheduler.bean.SourceObj;
import com.asiainfo.dacp.dp.server.scheduler.bean.TargetObj;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskAlarmInfo;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskAlarmLog;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskConfig;
import com.asiainfo.dacp.dp.server.scheduler.bean.TaskLog;
import com.asiainfo.dacp.dp.server.scheduler.cache.MemCache;
import com.asiainfo.dacp.dp.server.scheduler.type.ScriptType;
import com.asiainfo.dacp.dp.server.scheduler.utils.TimeUtils;

@Repository
public class DatabaseDao {
	@Autowired
	private JdbcTemplate jdbcTemplate;
	private static Logger LOG = LoggerFactory.getLogger(DatabaseDao.class);
	@Value("${server.isSupportKpiSchedule}")
	private boolean isSupportKpiSchedule;
	@Value("${dp_redo_type}")
	private String  dpRedoType; 
	public int checkExist(String tableName, String fieldName, Object value)
			throws Exception {
		String sql = "select 1 from " + tableName + " where " + fieldName
				+ "=? " + getLimitStr();
		try {
			LOG.debug("exec-sql:{}", sql.toString());
			jdbcTemplate.queryForObject(sql, Integer.class, value);
			return 1;
		} catch (EmptyResultDataAccessException ex) {
			return 0;
		}
	}
	public int checkExist(String sql) throws Exception {
		try {
			LOG.debug("exec-sql:{}", sql.toString());
			jdbcTemplate.queryForObject(sql, Integer.class);
			return 1;
		} catch (EmptyResultDataAccessException ex) {
			return 0;
		}
	}

	public int checkExist(String tableName, String[] fieldNames, Object[] values)
			throws Exception {
		String sql = "select 1 num from " + tableName + " where ";
		for (int i = 0; i < fieldNames.length; i++) {
			if (i != fieldNames.length - 1) {
				sql += fieldNames[i] + "=? and ";
			} else {
				sql += fieldNames[i] + "=? " + getLimitStr();
			}
		}
		try {
			LOG.debug("exec-sql:{}", sql.toString());
			jdbcTemplate.queryForObject(sql, Integer.class, values);
			return 1;
		} catch (EmptyResultDataAccessException ex) {
			return 0;
		}
	}
	
	public TaskLog getTaskLog(String xmlid,String dateArgs){
		String sql="select * FROM proc_schedule_log where xmlid='"+xmlid+"' and date_args='"+dateArgs+"' and valid_flag=0";
	
		LOG.debug("exec-sql:{}", sql.toString());
		List<TaskLog> _lst = this.jdbcTemplate.query(sql, new BeanPropertyRowMapper<TaskLog>(TaskLog.class));
		if (CollectionUtils.isEmpty(_lst)) {
			return null;
		} else {
			return _lst.get(0);
		}
		
	}

	public boolean delete(String sql) {
		try{
			return this.jdbcTemplate.update(sql) >= 0;
		}catch(Exception ex){
			LOG.error("",ex);
			LOG.error("exec-sql:{}", sql.toString());
			return false;
		}
	
	}

	/***
	 * 删除历史消息
	 * 
	 * @param tableName
	 * @param target
	 * @param procDate
	 * @return
	 */
	public boolean deleteLogHis(String tableName, String target, String dataTime) {
		String sql = "delete from " + tableName + " where target='" + target
				+ "' and data_time='" + dataTime + "'";
		LOG.debug("exec-sql:{}", sql.toString());
		return this.delete(sql);
	}

	public boolean deleteProcLog(String xmlid, String date_args) {
		String sql = "delete from proc_schedule_log where xmlid='"
				+ xmlid + "' and date_args='" + date_args + "'";
		LOG.debug("exec-sql:{}", sql.toString());
		return this.delete(sql);
	}
	
	public boolean insertErrorLog(String errCode,String proc_name, String errorMsg) {
		StringBuilder sql = new StringBuilder();
		try{
			sql.append("INSERT INTO PROC_SCHEDUAL_ERROR")
			.append("(SEQ_NO,")
			.append("ERR_CODE,")
			.append("PROC_NAME,ERR_TIME,ERR_CONTENT,USER_NAME")
			.append(")") 
			.append(" VALUES")
			.append("(?,?,?,?,?,'sys')") ;
			this.jdbcTemplate.update(sql.toString(),TimeUtils.dateToString2Second(new Date()), errCode,proc_name,TimeUtils.dateToString2Second(new Date())
					,errorMsg);
			return true;
		}catch(Exception ex){
			LOG.debug("exec-sql:{}", sql.toString());
			LOG.debug("", ex);
			return false;
		}
	}
	

	public boolean deleteLog(String tableName, String seqno) {
		String sql = "delete from " + tableName + " where seqno='" + seqno
				+ "'";
		LOG.debug("exec-sql:{}", sql.toString());
		return this.delete(sql);
	}
	public synchronized boolean update(String tableName, String pks, Map<String, Object> map) {
		if (StringUtils.isEmpty(pks)) {
			return false;
		}
		String[] _pks = pks.split(",");
		String key = null;
		Object value = null;
		StringBuilder sql = new StringBuilder("update " + tableName + " set ");
		StringBuilder whereCase = new StringBuilder(" where 1=1 ");
		List<Object> valueList = new ArrayList<Object>();
		List<Object> whereCaseList = new ArrayList<Object>();
		boolean isWhereCase = false;
		for (Map.Entry<String, Object> entry : map.entrySet()) {
			isWhereCase = false;
			key = entry.getKey();
			value = entry.getValue();
			if (value == null) {
				continue;
			}
			for (String pk : _pks) {
				if (StringUtils.equalsIgnoreCase(pk, key)) {
					whereCase.append(" and "+key + "=? ");
					whereCaseList.add(value);
					isWhereCase = true;
				}
			}
			if (!isWhereCase) {
				sql.append(key + "=?,");
				valueList.add(value);
			}
		}
		sql.deleteCharAt(sql.length() - 1);
		sql.append(whereCase);
		//加入whereCase条件值
		valueList.addAll(whereCaseList);
		try {
			int res = this.jdbcTemplate.update(sql.toString(),valueList.toArray());
			return res>0;
		} catch (Exception ex) {
			LOG.error("update-exec-sql:{}", sql.toString());
			LOG.error("update-exec-sql:error{}", ex);
			return false;
		}
	}
	//插入分發表
	public boolean insertDistributeTable(String xmlid,String data_time){
		StringBuilder sql = new StringBuilder();
		try{
			sql.append("INSERT INTO distribute_source_info")
			.append("(schedule_id,")
			.append("source_xmlid,") 
			.append("data_time")
			.append(")") 
			.append("VALUES")
			.append("(REPLACE(UUID(),'-',''),") 
			.append("?,?)") 
			.append(" ON DUPLICATE KEY UPDATE source_status=2 ,") 
			.append("come_num=come_num+1");
			this.jdbcTemplate.update(sql.toString(), xmlid,data_time);
			return true;
		}catch(Exception ex){
			LOG.debug("exec-sql:{}", sql.toString());
			LOG.debug("", ex);
			return false;
		}
	}
	public boolean insert(String tableName, Map<String, Object> map) {
		if (map.isEmpty()) {
			return false;
		}
		StringBuilder sql = new StringBuilder("insert into " + tableName);
		StringBuilder fields = new StringBuilder("(");
		StringBuilder values = new StringBuilder(" values(");
		String key = null;
		Object value = null;
		List<Object> valueList = new ArrayList<Object>();
		for (Map.Entry<String, Object> entry : map.entrySet()) {
			key = entry.getKey();
			value = entry.getValue();
			if (value == null) {
				continue;
			}
			fields.append(key);
			fields.append(",");
			valueList.add(value);
			values.append("?");
			values.append(",");
		}
		fields.deleteCharAt(fields.length() - 1);
		fields.append(") ");
		values.deleteCharAt(values.length() - 1);
		values.append(") ");
		sql.append(fields);
		sql.append(values);
		try {
			this.jdbcTemplate.update(sql.toString(),valueList.toArray());
			return true;
		} catch (Exception ex) {
			LOG.error("exec-sql:{}", sql.toString());
			LOG.error("", ex);
			return false;
		}
	}

	public List<MetaLog> queryMetaLogList(String seqno) throws Exception {
		StringBuilder sql = new StringBuilder();
		sql.append("select  ").append("seqno,").append("proc_name,")
				.append("proc_date,").append("target,").append("data_time,")
				.append("need_dq_check,").append("dq_check_res,")
				.append("generate_time,").append("trigger_flag ")
				.append("from proc_schedule_meta_log")
				.append(" where trigger_flag=0 and seqno='" + seqno + "'");
		LOG.debug("exec-sql:{}", sql.toString());
		return this.jdbcTemplate.query(sql.toString(),
				new BeanPropertyRowMapper<MetaLog>(MetaLog.class));
	}

	public List<MetaLog> queryTargetLogList() throws Exception {
		StringBuilder sql = new StringBuilder();
		sql.append("select  ").append("seqno,").append("proc_name,")
				.append("proc_date,").append("target,").append("data_time,")
				.append("need_dq_check,").append("dq_check_res,")
				.append("trigger_flag,").append("generate_time ")
				.append("from proc_schedule_target_log")
				.append(" where trigger_flag=0 ");
		LOG.debug("exec-sql:{}", sql.toString());
		return this.jdbcTemplate.query(sql.toString(),
				new BeanPropertyRowMapper<MetaLog>(MetaLog.class));
	}

	/***
	 * @param st_state
	 *            状态范围
	 * @param ed_state
	 *            状态时间
	 * @param queueFlag
	 *            出对标志
	 * @return
	 * @throws Exception
	 */
	public List<TaskLog> queryTaskRunLogList(int st_state, int ed_state,
			int queueFlag) {
		List<TaskLog> lst = new ArrayList<TaskLog>();
		try{
			String sql = "select seqno,a.xmlid,a.proc_name,a.pri_level,task_state,start_time,exec_time,end_time,a.run_freq,a.agent_code,a.platform,a.flowcode,runpara,path,proctype,status_time,retrynum,a.date_args,proc_date,queue_flag,trigger_flag,a.time_win,errcode,valid_flag,return_code,b.max_run_hours "
						+"	from proc_schedule_log a "
						+"  left join proc_schedule_info b on a.xmlid = b.xmlid ";
			sql += " where queue_flag =" + queueFlag + " and   task_state between "
					+ st_state + " and " + ed_state +" and valid_flag='0' "
					+ " ORDER BY date_args ASC,pri_level DESC";
			LOG.debug("exec-sql:{}", sql.toString());
			lst =  this.jdbcTemplate.query(sql, new BeanPropertyRowMapper<TaskLog>(
					TaskLog.class));
		}catch(Exception ex){
			LOG.error("",ex);
		}
		return lst;
	}
	
	/**
	 * 有效到点未完成告警信息列表
	 * @return
	 */
	public List<TaskAlarmInfo> queryFinishLateAlarmTaskInfoList() {
		List<TaskAlarmInfo> list = new ArrayList<TaskAlarmInfo>();
		try{
			String sql = "select a.*,b.proc_name,b.run_freq from proc_schedule_alarm_info a left join proc_schedule_info b on a.proc_xmlid = b.xmlid where is_valid = 0 and due_time_cron is not null and due_time_cron<>'' and (alarm_type = 1 or alarm_type like '1,%' or alarm_type like '%,1' or alarm_type like '%,1,%')";
			LOG.debug("exec-sql:{}", sql.toString());
			list =  this.jdbcTemplate.query(sql, new BeanPropertyRowMapper<TaskAlarmInfo>(TaskAlarmInfo.class));
		}catch(Exception ex){
			LOG.error("",ex);
		}
		return list;
	}
	
	/**
	 * 重新标记的告警配置的到点未完成告警任务信息列表
	 * @return
	 */
	public List<TaskAlarmInfo> queryFlagAlarmTaskInfoList() {
		List<TaskAlarmInfo> list = new ArrayList<TaskAlarmInfo>();
		try{
			String sql = "select a.*,b.proc_name,b.run_freq from proc_schedule_alarm_info a left join proc_schedule_info b on a.proc_xmlid = b.xmlid where flag=0 and due_time_cron is not null and due_time_cron<>'' and (alarm_type = 1 or alarm_type like '1,%' or alarm_type like '%,1' or alarm_type like '%,1,%')";
			LOG.debug("exec-sql:{}", sql.toString());
			list =  this.jdbcTemplate.query(sql, new BeanPropertyRowMapper<TaskAlarmInfo>(TaskAlarmInfo.class));
		}catch(Exception ex){
			LOG.error("",ex);
		}
		return list;
	}
	
	/**
	 * 有效错误告警信息列表
	 * @return
	 */
	public List<TaskAlarmInfo> queryRunErrorAlarmTaskInfoList() {
		List<TaskAlarmInfo> list = new ArrayList<TaskAlarmInfo>();
		try{
			String sql = "select a.*,b.proc_name,b.run_freq from proc_schedule_alarm_info a left join proc_schedule_info b on a.proc_xmlid = b.xmlid where is_valid = 0 and due_time_cron is not null and due_time_cron<>'' and (alarm_type = 1 or alarm_type like '1,%' or alarm_type like '%,1' or alarm_type like '%,1,%')";
			LOG.debug("exec-sql:{}", sql.toString());
			list =  this.jdbcTemplate.query(sql, new BeanPropertyRowMapper<TaskAlarmInfo>(TaskAlarmInfo.class));
		}catch(Exception ex){
			LOG.error("",ex);
		}
		return list;
	}
	
	/**
	 * 当天创建的任务记录
	 * @return
	 */
	public List<TaskLog> queryTodayValidTaskInfoList() {
		List<TaskLog> list = new ArrayList<TaskLog>();
		try{
			String sql = "select * from proc_schedule_log where (time_win is not null or time_win <> '') and start_time like concat(left(now(),10) ,'%') and valid_flag=0 ";
			LOG.debug("exec-sql:{}", sql.toString());
			list =  this.jdbcTemplate.query(sql, new BeanPropertyRowMapper<TaskLog>(TaskLog.class));
		}catch(Exception ex){
			LOG.error("",ex);
		}
		return list;
	}
	
	/**
	 * 需要告警的任务列表
	 * @return
	 */
	public List<TaskAlarmInfo> queryAlarmTaskList() {
		List<TaskAlarmInfo> list = new ArrayList<TaskAlarmInfo>();
		try{
			String sql = "select a.xmlid,a.proc_name,a.run_freq,b.team_code,a.on_focus,c.warning_type,c.due_time,c.offset from proc_schedule_info a inner join proc b on a.xmlid = b.xmlid and b.state='VALID' inner join sms_message_group_task c on a.xmlid = c.xmlid ";
			LOG.debug("exec-sql:{}", sql.toString());
			list =  this.jdbcTemplate.query(sql, new BeanPropertyRowMapper<TaskAlarmInfo>(TaskAlarmInfo.class));
		}catch(Exception ex){
			LOG.error("",ex);
		}
		return list;
	}

	public List<TaskLog> queryTaskRunLogList(String whereCase) throws Exception {
		String sql = getTaskLogSql("proc_schedule_log");
		if (StringUtils.isNotEmpty(whereCase)) {
			sql += " where 1=1 and valid_flag='0' " + whereCase;
		}
		LOG.debug("exec-sql:{}", sql.toString());
		return this.jdbcTemplate.query(sql, new BeanPropertyRowMapper<TaskLog>(
				TaskLog.class));
	}

	public List<TaskLog> queryTaskRunLogList(int st_state, int ed_state,
			String date_args, String runFreq) throws Exception {
		String sql = getTaskLogSql("proc_schedule_log");
		sql += " where  date_args = '" + date_args
				+ "'  and task_state between " + st_state + " and " + ed_state;
		if(StringUtils.isNotEmpty(runFreq)){
			sql	+= " and run_freq='" + runFreq ;
		}
		sql+="' and valid_flag='0' ORDER BY seqno";
		LOG.debug("exec-sql:{}", sql.toString());
		return this.jdbcTemplate.query(sql, new BeanPropertyRowMapper<TaskLog>(
				TaskLog.class));
	}

	public List<AgentIps> queryAgentIps() {
		String sql = "SELECT a.agent_name agent_code,node_status agent_status,status_chgtime,ips,script_path,b.curips curips,platform  FROM aietl_agentnode a LEFT JOIN (SELECT agent_code,COUNT(agent_code) curips FROM proc_schedule_log WHERE (task_state=-5 OR task_state=5 OR task_state=4) and valid_flag='0' GROUP BY agent_code) b ON a.agent_name = b.agent_code WHERE a.task_type = 'TASK'";
		return this.jdbcTemplate.query(sql,
				new BeanPropertyRowMapper<AgentIps>(AgentIps.class));
	}

	public TaskConfig queryTaskConfig(String procName) throws Exception {
		String nowStr = TimeUtils.dateToString(new Date()).substring(0, 10);
		String sql = getTaskConfigSql().toString();
		sql += (" and STATE='VALID' and eff_time<='" + nowStr
				+ "' and exp_time>='" + nowStr + "'");
		sql += " and c.xmlid='" + procName + "'";
		LOG.debug("exec:{}", sql);
		List<TaskConfig> list = this.jdbcTemplate.query(sql,
				new BeanPropertyRowMapper<TaskConfig>(TaskConfig.class));
		if (list.isEmpty()) {
			return null;
		} else {
			return list.get(0);
		}
	}

	public List<TaskConfig> queryNeedUpdateTaskConfigList(String whereCase)
			throws Exception {
		String sql = getTaskConfigSql().toString();
		sql += whereCase;
		// " and (STATE='PUBLISHED' OR  STATE='INVALID' OR STATE='VALID')";
		LOG.debug("exec:{}", sql);
		return this.jdbcTemplate.query(sql,
				new BeanPropertyRowMapper<TaskConfig>(TaskConfig.class));
	}

	public List<TaskConfig> queryTaskConfigList() throws Exception {
		String nowStr = TimeUtils.dateToString(new Date()).substring(0, 10);
		String sql = getTaskConfigSql().toString();
		sql += " and STATE='VALID' and eff_time<='" + nowStr
				+ "' and exp_time>='" + nowStr + "'";
		LOG.debug("exec:{}", sql);
		return this.jdbcTemplate.query(sql,
				new BeanPropertyRowMapper<TaskConfig>(TaskConfig.class));
	}

	/***
	 * 在transdatamap_design中查询数据
	 * 
	 * @param procName
	 * @return
	 */
	public List<SourceObj> querySourceList(String xmlid) {
		String sql = getSourceSql();
		if (StringUtils.isNotEmpty(xmlid)) {
			sql += " and target='" + xmlid + "'";
		}
		LOG.debug("exec:{}", sql);
		return this.jdbcTemplate.query(sql,
				new BeanPropertyRowMapper<SourceObj>(SourceObj.class));
	}

	public List<TargetObj> queryNextDataList(String xmlid) {
		String sql = getTargetSql();
		if (StringUtils.isNotEmpty(xmlid)) {
			sql += " and source='" + xmlid + "'";
		}
		LOG.debug("exec:{}", sql);
		return this.jdbcTemplate.query(sql,
				new BeanPropertyRowMapper<TargetObj>(TargetObj.class));
	}
	
	public List<TargetObj> queryNextAllList(String xmlid) {
		String sql = "SELECT source,sourcetype,sourcefreq,source_appoint ,flowcode,target,targettype ,targetfreq ,need_dq_check FROM transdatamap_design WHERE source='"+xmlid+"'";
		LOG.debug("exec:{}", sql);
		return this.jdbcTemplate.query(sql,
				new BeanPropertyRowMapper<TargetObj>(TargetObj.class));
	}

	public List<TargetObj> queryNextProcList(String procName) {
		String sql = "select * from ( SELECT source,sourcefreq,target,targetfreq ,trigger_type FROM transdatamap_design,proc a,proc_schedule_info b WHERE target=a.xmlid AND a.xmlid=b.xmlid AND transname=target AND  sourcetype='PROC' AND targettype<>'DATA' AND sourcefreq<>'N' AND state='VALID'  ";
		if(isSupportKpiSchedule)
		sql+="UNION ALL SELECT source,sourcefreq,target,targetfreq ,trigger_type FROM transdatamap_design,kpi_scope_def a,proc_schedule_info b WHERE target=a.kpi_scope_code AND a.kpi_scope_code=b.proc_name AND transname=target AND  sourcetype='PROC' AND targettype<>'DATA'  AND sourcefreq<>'N' AND a.state='VALID' ) c where 1=1 ";	
		else sql+=(") c where 1=1");
		if (StringUtils.isNotEmpty(procName)) {
			sql += " and source='" + procName + "'";
		}
		LOG.debug("exec:{}", sql);
		return this.jdbcTemplate.query(sql,
				new BeanPropertyRowMapper<TargetObj>(TargetObj.class));
	}

	public <T> List<T> queryForList(String sql, Class<T> clz) {
		return this.jdbcTemplate.query(sql, new BeanPropertyRowMapper<T>(clz));
	}

	public List<SourceLog> querySourceLogList(String seqno) throws Exception {
		String sql = " select seqno,source,source_type,data_time from proc_schedule_source_log  ";
		sql += " where check_flag = 0";
		LOG.debug("exec:{}", sql);
		return this.jdbcTemplate.query(sql,
				new BeanPropertyRowMapper<SourceLog>(SourceLog.class));
	}

	public List<SourceLog> querySourceLogList() throws Exception {
		String sql = "SELECT a.seqno seqno,source,source_type,data_time FROM proc_schedule_source_log a ,proc_schedule_log  b WHERE a.seqno=b.seqno  AND  check_flag = 0 AND (task_state=1 OR task_state=-1) AND b.VALID_FLAG='0'";
		LOG.debug("exec:{}", sql);
		return this.jdbcTemplate.query(sql,
				new BeanPropertyRowMapper<SourceLog>(SourceLog.class));
	}

	public PlatformConfig queryPlatformConfig(String platform) throws Exception {
		String sql = " select platform,ips,curips"
				+ " from proc_schedule_platform where platform ='" + platform
				+ "'";
		LOG.debug("exec-sql:{}", sql.toString());
		List<PlatformConfig> _lst = this.jdbcTemplate
				.query(sql, new BeanPropertyRowMapper<PlatformConfig>(
						PlatformConfig.class));
		if (CollectionUtils.isEmpty(_lst)) {
			return null;
		} else {
			return _lst.get(0);
		}
	}

	public List<PlatformConfig> queryPlatformConfigList() throws Exception {
		String sql = " select platform,ips,curips"
				+ " from proc_schedule_platform ";
		LOG.debug("exec-sql:{}", sql.toString());
		return this.jdbcTemplate
				.query(sql, new BeanPropertyRowMapper<PlatformConfig>(
						PlatformConfig.class));
	}

	private String getTaskConfigSql() {
		StringBuilder sql = new StringBuilder();
		sql.append("SELECT * FROM  (");
		sql.append("select ").append("a.xmlid ,a.proc_name,")//
				.append("b.exec_path path,")
				.append("time_win,").append("b.proc_type proctype,").append("runpara,")
				.append("curdutyer,").append("agent_code,").append("eff_time,")
				.append("exp_time,").append("trigger_type,")
				.append("run_freq,").append("st_day,").append("state,")
				.append("st_time,").append("cron_exp,").append("pri_level,")
				.append("platform,").append("resouce_level,")
				.append("redo_num,").append("redo_interval,")
				.append("alarm_class,").append("exec_class,")
				.append("date_args,")
				.append("muti_run_flag,").append("team_code,")
				.append("on_focus,")
				.append("topicname,").append("exec_proc,")
				.append("flowcode,").append("dura_max ")
				.append("from proc  a,").append("proc_schedule_info  b ")
				.append("where a.xmlid=b.xmlid  ");
		if(isSupportKpiSchedule)//如果是指标组调度，则拼接指标组查询结果
		sql.append("UNION ALL SELECT ")
				  .append("a.xmlid, a.kpi_scope_code proc_name,")
				  .append("'runKPI.sh' path,")
				  .append(" time_win,")
				  .append("'SCOPE' proctype,")
				  .append("a.kpi_scope_code runpara,")
				  .append("a.create_user curdutyer,")
				  .append("agent_code,")
				  .append("eff_time,")
				  .append("exp_time,")
				  .append("trigger_type,")
				  .append("run_freq,")
				  .append("st_day,")
				  .append("state,")
				  .append("st_time,")
				  .append("cron_exp,")
				  .append("pri_level,")
				  .append("platform,")
				  .append("resouce_level,")
				  .append("redo_num,")
				  .append("redo_interval,")
				  .append("alarm_class,")
				  .append("exec_class,")
				  .append("date_args,")
				  .append("muti_run_flag,")
				  .append("'' team_code,")
				  .append("on_focus,")
				  .append("'' topicname,").append("'runKPI.sh' exec_proc,")
				  .append("flowcode,")
				  .append("dura_max ")
				  .append("FROM kpi_scope_def a, ")
				  .append("proc_schedule_info b ")
				.append("WHERE a.kpi_scope_code = b.proc_name ) c where 1=1 ");
		else sql.append(") c where 1=1");
			
		return sql.toString();
	}

	private String getTaskLogSql(String tableName) {
		String sql = "select xmlid,seqno,proc_name,pri_level,"
				+ "task_state,start_time,exec_time,end_time,run_freq,agent_code,platform,flowcode,runpara,path,proctype,"
				+ "status_time,retrynum,date_args,proc_date,queue_flag,trigger_flag,time_win,errcode,valid_flag,return_code"
				+ " from " + tableName;
		return sql;
	}

	public boolean saveTargertLog(final List<MetaLog> metaList, String tableName) {
		StringBuilder sql = new StringBuilder();
		try {
			sql.append("insert into " + tableName)
					.append("(seqno,proc_name,proc_date,target,data_time,trigger_flag,generate_time, flowcode,date_args) ")
					.append("values(?,?,?,?,?,?,?,?,?)");

			BatchPreparedStatementSetter pss = new BatchPreparedStatementSetter() {
				public void setValues(PreparedStatement ps, int i)
						throws SQLException {
					MetaLog metaLog = metaList.get(i);
					String generateTime=StringUtils.isEmpty(metaLog.getGenerateTime())?TimeUtils.dateToString(new Date()):metaLog.getGenerateTime();
					ps.setString(1, metaLog.getSeqno());
					ps.setString(2, metaLog.getProcName());
					ps.setString(3, metaLog.getProcDate());
					ps.setString(4, metaLog.getTarget());
					ps.setString(5, metaLog.getDataTime());
					ps.setInt(6, metaLog.getTriggerFlag());
					ps.setString(7, generateTime);
					ps.setString(8, metaLog.getFlowcode());
					ps.setString(9, metaLog.getDateArgs());
				}

				public int getBatchSize() {
					return metaList.size();
				}
			};
			this.jdbcTemplate.batchUpdate(sql.toString(), pss);
			return true;
		} catch (Exception ex) {
			LOG.error("exec-sql:[size={}] {} ", metaList.size(), sql.toString());
			LOG.error("", ex);
			return false;
		}
	}

	public boolean saveSourceLog(final List<SourceLog> srcLogList) {
		StringBuilder sql = new StringBuilder();
		try {
			sql.append("insert into proc_schedule_source_log")
					.append("(seqno,proc_name,source,source_type,data_time,check_flag, flowcode,date_args) ")
					.append("values(?,?,?,?,?,?,?,?)");

			BatchPreparedStatementSetter pss = new BatchPreparedStatementSetter() {
				public void setValues(PreparedStatement ps, int i)
						throws SQLException {
					SourceLog sourceLog = srcLogList.get(i);
					ps.setString(1, sourceLog.getSeqno());
					ps.setString(2, sourceLog.getProcName());
					ps.setString(3, sourceLog.getSource());
					ps.setString(4, sourceLog.getSourceType());
					ps.setString(5, sourceLog.getDataTime());
					ps.setInt(6, sourceLog.getCheckFlg());
					ps.setString(7, sourceLog.getFlowcode());
					ps.setString(8, sourceLog.getDateArgs());
				}

				public int getBatchSize() {
					return srcLogList.size();
				}
			};
			this.jdbcTemplate.batchUpdate(sql.toString(), pss);
			return true;
		} catch (Exception ex) {
			LOG.error("exec-sql:[size={}] {} ", srcLogList.size(),
					sql.toString());
			LOG.error("", ex);
			return false;
		}
	}
	private String getSourceSql() {
		String sql = "SELECT target ,flowcode,source,sourcetype ,sourcefreq,source_appoint  FROM transdatamap_design WHERE (targettype='PROC' or targettype='SCOPE')  AND transname=target ";
		return sql;
	}

	private String getTargetSql() {
		String sql = "SELECT source ,flowcode,target,targettype ,targetfreq ,need_dq_check FROM transdatamap_design WHERE transname=source and targettype='DATA' AND (sourcetype='PROC' OR sourcetype='SCOPE')";
		return sql;
	}

	public List<Relationship> queryRelList() {
		
		String sql = "SELECT source,sourcetype,sourcefreq,source_appoint,target,targettype,targetfreq,trigger_type FROM transdatamap_design,proc a,proc_schedule_info b WHERE transname=a.xmlid AND a.xmlid=b.xmlid AND sourcetype<>'PROC' AND targettype='PROC' AND sourcefreq<>'N' AND state='VALID' "
				+ " ORDER BY source,sourcefreq";
		LOG.debug("exec-sql:{}", sql.toString());
		return this.jdbcTemplate.query(sql,
				new BeanPropertyRowMapper<Relationship>(Relationship.class));
	}

	public String queryFreq(String xmlid) {
		String sql = "SELECT sourcefreq FROM transdatamap_design WHERE transname=target AND sourcetype='DATA' AND sourcefreq<>'N' AND sourcefreq is not null and source=? "
				+ getLimitStr();
		try {
			return this.jdbcTemplate.queryForObject(sql, String.class, xmlid);
		} catch (EmptyResultDataAccessException ex) {
			//LOG.error("", ex);
			LOG.info("该接口无调度程序依赖！");
			return null;
		}
	}
	public void executeSql(String sqlText) {
		this.jdbcTemplate.execute(sqlText);
	}

	public int update(String sqlText) {
		try {
			return this.jdbcTemplate.update(sqlText);
		} catch (Exception ex) {
			LOG.error("",ex);
			LOG.error("exec-sql:{}", sqlText.toString());
			return -1;
		}
	}
	private String getLimitStr() {
		String res = "";
		switch (MemCache.DBTYPE) {
		case MYSQL:
			res += " limit 1";
			break;
		case ORACLE:
			res += " and rownum<2";
			break;
		default:
			break;
		}
		return res;
	}

	public String getExptimeByProcName(String procName){
		String sql="select exp_time from proc_schedule_info where proc_name = ? "+ getLimitStr();
		try {
			return this.jdbcTemplate.queryForObject(sql, String.class, procName);
		} catch (EmptyResultDataAccessException ex) {
			LOG.error("", ex);
			return null;
		}
	}
	/**
	 * 通过程序类型ID查询程序执行类
	 * @param procType
	 * @return
	 */
	public ClassInfo queryClassInfo(String procType) {
		String sql = "SELECT EXE_CLASS,EXE_FUNC FROM PROC_SCHEDULE_EXE_CLASS WHERE PROCTYPE='"
				+ procType + "'";
		try {
			List<ClassInfo> clzList = this.jdbcTemplate.query(sql,
					new BeanPropertyRowMapper<ClassInfo>(ClassInfo.class));
			if (clzList.isEmpty()) {
				return null;
			} else {
				return clzList.get(0);
			}
		} catch (Exception ex) {
			LOG.error("exec-sql:{}", sql.toString());
			LOG.error("", ex);
			return null;
		}
	}
	/**
	 * 通过proc_schedule_info 查询运行参数
	 * @param xmlid
	 * @return
	 */
	public String queryRunpara(TaskLog runInfo,String dateArgs){
		String sql="SELECT run_para,run_para_value FROM proc_schedule_runpara where xmlid='"+runInfo.getXmlid()+"' order by orderid asc";
		String runparas="";
		try{
			List<RunPara> list= this.jdbcTemplate.query(sql,
					new BeanPropertyRowMapper<RunPara>(RunPara.class));
			for(RunPara runpara:list){
				runparas=runparas+" "+runpara.getRunPara()+" "+runpara.getRunParaValue();
			}
			int rerurnCode=0;
			if(!StringUtils.isEmpty(dpRedoType)&&"1".equals(dpRedoType)){
				/*任务是否执行错误,从当前步骤号执行*/
				if(runInfo.getReturnCode()!=null&&Integer.valueOf(runInfo.getReturnCode())>1){
					rerurnCode=runInfo.getReturnCode();
				}
			}
			if(runInfo.getProctype().equals(ScriptType.dp.name())){
				return " -t "+dateArgs+" -f "+ MemCache.PROC_MAP.get(runInfo.getXmlid()).getExecProc()+" -i "+rerurnCode+" "+runparas;
			}else{
				return runparas;
			}
		}catch(Exception e){
			LOG.error("exec-sql:{}", sql.toString());
			LOG.error("", e);
			return null;
		}
		
	}
	
	
	/**
	 * 获取运行参数
	 * @param runInfo
	 * @param dateArgs
	 * @param execProc
	 * @return
	 */
	public String queryRunpara(TaskLog runInfo,String dateArgs,String execProc){
		String sql="SELECT run_para,run_para_value FROM proc_schedule_runpara where xmlid='"+runInfo.getXmlid()+"' order by orderid asc";
		String runparas="";
		try{
			List<RunPara> list= this.jdbcTemplate.query(sql,
					new BeanPropertyRowMapper<RunPara>(RunPara.class));
			for(RunPara runpara:list){
				runparas=runparas+" "+runpara.getRunPara()+" "+runpara.getRunParaValue();
			}
			if(runInfo.getProctype().equals(ScriptType.dp.name())){
				return " -t "+dateArgs+" -f "+ execProc+" "+runparas;
			}else{
				return runparas;
			}
		}catch(Exception e){
			LOG.error("exec-sql:{}", sql.toString());
			LOG.error("", e);
			return null;
		}
		
	}
	
	public List<TargetObj> getTargetMap(String flowcode,String transName,String source) {
		String sql = "select * from transdatamap_design_manual where flowcode='"+flowcode+"'";
		if(!StringUtils.isEmpty(transName)){
			sql +=" and transname='"+transName+"'";
		}
		if(!StringUtils.isEmpty(source)){
			sql+=" and source='"+source+"'";
		}
		return 	jdbcTemplate.query(sql,new BeanPropertyRowMapper<TargetObj>(TargetObj.class));
	}
	
	@SuppressWarnings("unchecked")
	public <T> List<T>  getTargetMap(Class<T> t,String flowcode,String transName,String source,String target) throws InstantiationException, IllegalAccessException {
		T obj=t.newInstance();
		String sql = "select * from transdatamap_design_manual where flowcode='"+flowcode+"'";
		if(!StringUtils.isEmpty(transName)){
			sql +=" and transname='"+transName+"'";
		}
		if(!StringUtils.isEmpty(source)){
			sql+=" and source='"+source+"'";
		}
		if(!StringUtils.isEmpty(target)){
			sql+=" and target='"+target+"'";
		}
		return 	jdbcTemplate.query(sql,new BeanPropertyRowMapper<T>((Class<T>) obj.getClass()));
	}
	
	public List<TargetObj> getSourceKey(String source){
		String sql="SELECT source,sourcefreq,source_appoint FROM transdatamap_design WHERE source ='"+source+"' GROUP BY source,sourcefreq,source_appoint";
		try{
			List<TargetObj> list= this.jdbcTemplate.query(sql,
					new BeanPropertyRowMapper<TargetObj>(TargetObj.class));
			return list;
		}catch(Exception e){
			LOG.error("exec-sql:{}", sql.toString());
			LOG.error("", e);
			return null;
		}
	}
	
	/**
	 * 检测是否有相同批次的记录,返回相同批次记录
	 * @param task
	 * @throws Exception
	 */
	public List<TaskLog> checkExistSameInvalidTask(String xmlid,String dateArgs)
			throws Exception {
		List<TaskLog> lst = new ArrayList<TaskLog>();
		try{
			String sql = "select seqno,a.xmlid,a.proc_name,a.pri_level,task_state,start_time,exec_time,end_time,a.run_freq,a.agent_code,a.platform,a.flowcode,runpara,path,proctype,status_time,retrynum,a.date_args,proc_date,queue_flag,trigger_flag,a.time_win,errcode,valid_flag,return_code,b.max_run_hours "
						+ "	from proc_schedule_log a "
						+ "  left join proc_schedule_info b on a.xmlid = b.xmlid ";
			sql += " where a.xmlid = '" + xmlid + "' and a.date_args = '" + dateArgs + "' and a.valid_flag = 0";
			LOG.debug("exec-sql:{}", sql.toString());
			lst =  this.jdbcTemplate.query(sql, new BeanPropertyRowMapper<TaskLog>(
					TaskLog.class));
		}catch(Exception ex){
			LOG.error("",ex);
		}
		return lst;
	}
	/**
	 * 根据程序名查询程序所属用户，主要是为了适配北京电信需求
	 * @param task
	 * @throws Exception
	 */
	public String getProcUser (String xmlid){
		List<Map<String,Object>> lst = new ArrayList<Map<String,Object>>();
		String user="";
		try{
			String sql = "select user from proc where xmlid='"+xmlid+"'";
			LOG.debug("exec-sql:{}", sql.toString());
			lst =  this.jdbcTemplate.queryForList(sql);
			if(lst.get(0).get("user")!=null){
		    user=lst.get(0).get("user").toString();
			}else{
			user ="";	
			}
		}catch(Exception ex){
			LOG.error("",ex);
		}
		return user;
	}
	public int  checkExistLike(String sql) {
		try {
			LOG.debug("exec-sql:{}", sql.toString());
			jdbcTemplate.queryForObject(sql,String.class);
			return 1;
		} catch (EmptyResultDataAccessException ex) {
			return 0;
		}
		
	}
	public List<Map<String, Object>> queryForMapList(String sql) {
		return jdbcTemplate.queryForList(sql);
	}
	public List<TaskLog> queryPlanTask(TaskLog runInfo) {
		String sql ="select seqno from proc_schedule_log where xmlid='"
				+ runInfo.getXmlid() + "' and date_args='"
				+ runInfo.getDateArgs() + "'   and task_state="
				+ RunStatus.PLAN_TASK;
		return jdbcTemplate.query(sql,new BeanPropertyRowMapper<TaskLog>(TaskLog.class));
	}
	
	/**
	 * 获取程序的告警配置信息
	 * @param xmlid 告警信息表主键xmlid
	 * @return
	 * @throws Exception
	 */
	public TaskAlarmInfo queryTaskAlarmInfoByKey(String xmlid) throws Exception {
		String sql = "select a.*,b.proc_name,b.run_freq from proc_schedule_alarm_info a left join proc_schedule_info b on a.proc_xmlid = b.xmlid where a.xmlid='" + xmlid + "'";
		LOG.debug("exec:{}", sql);
		List<TaskAlarmInfo> list = this.jdbcTemplate.query(sql,
				new BeanPropertyRowMapper<TaskAlarmInfo>(TaskAlarmInfo.class));
		if (list.isEmpty()) {
			return null;
		} else {
			return list.get(0);
		}
	}
	
	/**
	 * 获取程序的告警配置信息
	 * @param procXmlid 程序xmlid
	 * @param alarmType 告警类型
	 * @return
	 * @throws Exception
	 */
	public TaskAlarmInfo queryTaskAlarmInfoByProcXmid(String procXmlid,int alarmType) throws Exception {
		String sql = "select a.*,b.proc_name,b.run_freq from proc_schedule_alarm_info a left join proc_schedule_info b on a.proc_xmlid = b.xmlid where a.proc_xmlid='" + procXmlid + "' and a.is_valid =0 and (a.alarm_type ='"+alarmType+"' or a.alarm_type like '"+alarmType+",%' or a.alarm_type like '%,"+alarmType+",%' or a.alarm_type like '%,"+alarmType+"' )";
		LOG.debug("exec:{}", sql);
		List<TaskAlarmInfo> list = this.jdbcTemplate.query(sql,
				new BeanPropertyRowMapper<TaskAlarmInfo>(TaskAlarmInfo.class));
		if (list.isEmpty()) {
			return null;
		} else {
			return list.get(0);
		}
	}
	
	/**
	 * 获取任务告警日志
	 * @param procXmlid 程序xmlid
	 * @param dateArgs 告警批次
	 * @param alarmType 告警类型
	 * @return
	 * @throws Exception
	 */
	public List<TaskAlarmLog> getTaskAlarmLogList(String procXmlid,String dateArgs,int alarmType) throws Exception {
		String sql = "select * from proc_schedule_alarm_log where proc_xmlid='" + procXmlid + "' and proc_date_args ='"+dateArgs+"' and alarm_type ='"+alarmType+"'  order by alarm_time desc";
		LOG.debug("exec:{}", sql);
		List<TaskAlarmLog> list = this.jdbcTemplate.query(sql,
				new BeanPropertyRowMapper<TaskAlarmLog>(TaskAlarmLog.class));
		return list;
	}
	
	public List<Map<String,Object>> queryAlarmMemeberPhoneNumList(String xmlid) throws Exception {
		String sql = "	select distinct b.phonenum as phone from proc_schedule_alarm_info a left join sms_message_group_member b on a.sms_group_id = b.sms_group_id and b.status = 0 where a.proc_xmlid='" + xmlid + "'";
		LOG.debug("exec:{}", sql);
		List<Map<String,Object>> list = this.jdbcTemplate.queryForList(sql);
		return list;
	}
}
