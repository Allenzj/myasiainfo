package com.asiainfo.dacp.repositoris;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.asiainfo.dacp.jdbc.JdbcTemplate;
import com.asiainfo.dacp.jdbc.persistence.Column;
import com.asiainfo.dacp.modle.Proc;
import com.asiainfo.dacp.modle.ProcScheduleInfo;
import com.asiainfo.dacp.modle.ProcScheduleRunpara;





@Repository
public class ProcRepository {
	private static Logger LOG = LoggerFactory.getLogger(ProcRepository.class);
	
	
	public ProcScheduleInfo querySchedInfo(String xmlid) {
		JdbcTemplate jdbcTemplate = new JdbcTemplate();
		try{
			@SuppressWarnings("unchecked")
			ProcScheduleInfo result = (ProcScheduleInfo)jdbcTemplate.queryForObject
			("select * from proc_schedule_info  where xmlid=?",new Object[]{xmlid},new RowMapper(){
				public Object mapRow(ResultSet rs, int rowNum) throws SQLException {
					ProcScheduleInfo context = new ProcScheduleInfo();
					context.setXmlid(rs.getString("xmlid"));
					context.setProc_name(rs.getString("proc_name"));
					context.setAgent_code(rs.getString("agent_code"));
					context.setTrigger_type(rs.getInt("trigger_type"));
					context.setRun_freq(rs.getString("run_freq"));
					context.setSt_day(rs.getString("st_day"));
					context.setSt_time(rs.getString("st_time"));
					context.setCron_exp(rs.getString("cron_exp"));				
					context.setExec_path(rs.getString("exec_path"));
				 	context.setExec_proc(rs.getString("exec_proc"));
				 	context.setProc_type(rs.getString("proc_type"));
					context.setPri_level(rs.getInt("pri_level"));
					context.setPlatform(rs.getString("platform"));
					context.setResouce_level(rs.getInt("resouce_level"));
					context.setRedo_num(rs.getInt("redo_num"));
					context.setAlarm_class(rs.getString("alarm_class"));
					context.setExec_class(rs.getString("exec_class"));
					context.setDate_args(rs.getString("date_args"));
					context.setMuti_run_flag(rs.getInt("muti_run_flag"));
					context.setDura_max(rs.getInt("dura_max"));
					context.setEff_time(rs.getString("eff_time"));
					context.setExp_time(rs.getString("exp_time"));
					context.setOn_focus(rs.getInt("on_focus"));
					context.setRedo_interval(rs.getInt("redo_interval"));
					context.setAllow_exec_time(rs.getString("allow_exec_time"));
					context.setTime_win(rs.getString("time_win"));
					context.setFlowcode(rs.getString("flowcode"));
					//context.setLevels(rs.getString("levels"));
					//context.setTopicname(rs.getString("topicname"));
					//context.setCreate_user(rs.getString("create_user"));
					//context.setCreate_time(rs.getString("create_time"));
					//context.setUpdate_user(rs.getString("update_user"));
					//context.setUpdate_time(rs.getString("update_time"));
					//context.setTeam_code(rs.getString("team_code"));
					//context.setState(rs.getString("state"));
					return context;
				}
			});
			return result;
		}catch(Exception e){
			LOG.error("查询proc_schedule_info表xmlid="+xmlid+"数据失败");
		}
		return null;
	}
	
	
	public Proc queryProcByid(String xmlid) {
		JdbcTemplate jdbcTemplate = new JdbcTemplate();
		try{
			@SuppressWarnings("unchecked")
			Proc result = (Proc)jdbcTemplate.queryForObject
			("select * from Proc where xmlid=?",new Object[]{xmlid},new RowMapper(){
				public Object mapRow(ResultSet rs, int rowNum) throws SQLException {
					Proc context = new Proc();
					context.setXmlid(rs.getString("xmlid"));
					context.setProc_name(rs.getString("proc_name"));
					context.setProccnname(rs.getString("proccnname"));
					context.setIntercode(rs.getString("intercode"));
					context.setTopicname(rs.getString("topicname"));
					context.setInorfull(rs.getString("inorfull"));
					context.setProctype(rs.getString("proctype"));
					context.setCycletype(rs.getString("cycletype"));
					context.setStartdate(rs.getString("startdate"));
					context.setStarttime(rs.getString("starttime"));
					context.setEndtime(rs.getString("endtime"));
					context.setParentproc(rs.getString("parentproc"));
					context.setRemark(rs.getString("remark"));
					context.setTeam_code(rs.getString("team_code"));
					context.setCurdutyer(rs.getString("curdutyer"));
					context.setLevel_val(rs.getString("level_val"));
					context.setRunmode(rs.getString("runmode"));
					context.setDbname(rs.getString("dbname"));
					context.setDbuser(rs.getString("dbuser"));
					context.setPath(rs.getString("path"));
					context.setCreater(rs.getString("creater"));
					context.setDeveloper(rs.getString("developer"));
					context.setState(rs.getString("state"));
					context.setState_date(rs.getString("state_date"));
					context.setEff_date(rs.getString("eff_date"));
					context.setEff_date(rs.getString("eff_date"));
					context.setXml(rs.getString("xml"));
					context.setVerseq(rs.getInt("verseq"));
					context.setAreacode(rs.getString("areacode"));
					context.setAuditer(rs.getString("auditer"));
					context.setDesigner(rs.getString("designer"));
					context.setParentproc(rs.getString("parentproc"));
					context.setTopiccode(rs.getString("topiccode"));
					return context;
				}
			});
			return result;
		}catch(Exception e){
			LOG.error("查询proc表xmlid="+xmlid+"数据失败");
		}
		return null;
	}
	
	private JdbcTemplate getJdbcTemplate(){
		return new JdbcTemplate();
	}
	
	@SuppressWarnings("rawtypes")
	public List<ProcScheduleRunpara> queryRunpara(String xmlid) {
		JdbcTemplate jdbcTemplate = getJdbcTemplate();
		@SuppressWarnings("unchecked")
		List<ProcScheduleRunpara> result = jdbcTemplate.query("select * from proc_schedule_runpara where xmlid=? order by orderid",new Object[]{xmlid},new RowMapper(){
			public Object mapRow(ResultSet rs, int rowNum) throws SQLException {
				ProcScheduleRunpara runPara = new ProcScheduleRunpara();				
				runPara.setXmlid(rs.getString("xmlid"));
				runPara.setOrderid(rs.getInt("orderid"));
				runPara.setRun_para(rs.getString("run_para"));
				runPara.setRun_para_value(rs.getString("run_para_value"));
				return runPara;
			}
		});
		return result;
	}
}
