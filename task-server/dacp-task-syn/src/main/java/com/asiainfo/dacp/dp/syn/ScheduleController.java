package com.asiainfo.dacp.dp.syn;

import java.io.Writer;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;

import com.asiainfo.dacp.jdbc.JdbcTemplate;
import com.google.gson.Gson;

@Controller
@RequestMapping("/shd")
public class ScheduleController {

	@RequestMapping(value = "/saveKpiShdInfo")
	public void SaveKpiScheduleInfo(HttpServletRequest request,
			HttpServletResponse response) throws Exception {
		String id = request.getParameter("id");
		JdbcTemplate jdbc = new JdbcTemplate("METADB");
		Writer out = response.getWriter();
		Gson gson = new Gson();
		Map<String, String> returnRes = new HashMap<String, String>();

		try {
			String sql = "select kpi_scope_id,kpi_scope_code,kpi_scope_name,proc_depend,kpi_depend,cycle from kpi_scope_def where kpi_scope_id='"
					+ id + "'";
			List<Map<String, Object>> list = jdbc.queryForList(sql);
			String name = list.get(0).get("KPI_SCOPE_CODE").toString();
			String proc_depends = list.get(0).get("PROC_DEPEND").toString();
			String kpi_depends = list.get(0).get("KPI_DEPEND").toString();
			String cycle = list.get(0).get("CYCLE").toString();
			String freq = cycle.substring(0,1).toUpperCase() + "-0";
			String[] procs = proc_depends.split(",");
			String[] kpis = kpi_depends.split(",");
			// 删除原有依赖
			String delete_sql = " DELETE FROM transdatamap_design WHERE transname='" + name + "' ";
			jdbc.execute(delete_sql);
			// 保存依赖信息
			String _sql = " insert into transdatamap_design (xmlid,flowcode,transname,source,sourcetype,sourcefreq,target,targettype,targetfreq,need_dq_check) values ";
			StringBuilder values = new StringBuilder();
			if (proc_depends.trim().length() > 0 && procs.length > 0) {
				for (int i = 0; i < procs.length; i++) {
					String uuid = UUID.randomUUID().toString().replace("-", "");
					values.append("('" + uuid + "',");
					values.append("'DEFAULT_FLOW',");
					values.append("'" + name + "',");
					values.append("'" + procs[i] + "',");
					values.append("'PROC',");
					values.append("'" + freq + "',");
					values.append("'" + name + "',");
					values.append("'SCOPE',");
					values.append("'" + freq + "',");
					values.append("NULL)");
					if (i < procs.length - 1) {
						values.append(",");
					}
				}
			}
			if (kpi_depends.trim().length() > 0 && kpis.length > 0) {
				values.append(",");
				for (int i = 0; i < kpis.length; i++) {
					String uuid = UUID.randomUUID().toString().replace("-", "");
					values.append("('" + uuid + "',");
					values.append("'DEFAULT_FLOW',");
					values.append("'" + name + "',");
					values.append("'" + kpis[i] + "',");
					values.append("'KPI',");
					values.append("'" + freq + "',");
					values.append("'" + name + "',");
					values.append("'SCOPE',");
					values.append("'" + freq + "',");
					values.append("NULL)");
					if (i < kpis.length - 1) {
						values.append(",");
					}
				}
			}
			jdbc.execute(_sql + values.toString());

			String __sql="select count(1) from proc_schedule_info where proc_name = '" + name + "'";
			int count = jdbc.queryForObject(__sql, Integer.class);
			// 保存初始调度信息
			if (count>0) {
				String updataSql = "UPDATE proc_schedule_info a SET a.pri_level=(SELECT priority FROM kpi_scope_def WHERE kpi_scope_code = a.proc_name),a.run_freq=(SELECT CYCLE FROM kpi_scope_def WHERE kpi_scope_code = a.proc_name) WHERE a.proc_name = '"
						+ name + "'";
				jdbc.execute(updataSql);
			} else {
				String insertSql = "INSERT INTO proc_schedule_info (proc_name,run_freq,pri_level) SELECT kpi_scope_code,cycle,priority FROM kpi_scope_def WHERE kpi_scope_code = '"
						+ name + "'";
				jdbc.execute(insertSql);
			}
			returnRes.put("response", "保存成功！");
			returnRes.put("flag", "true");
		} catch (Exception e) {
			returnRes.put("response", e.toString());
			returnRes.put("flag", "false");
		} finally {
			out.write(gson.toJson(returnRes));
		}
	}

	@RequestMapping(value = "/saveKpiSourceInfo")
	public void SaveKpiSourceInfo(HttpServletRequest request,
			HttpServletResponse response) throws Exception {
		String target = request.getParameter("target");
		String targetType = request.getParameter("targetType").toUpperCase();//全部转换为大写
		String sourceCycle = request.getParameter("sourceCycle");
		String source = request.getParameter("source");
		String sourceType = request.getParameter("sourceType").toUpperCase();
		String targetCycle = request.getParameter("targetCycle");
		String targetFreq = StringUtils.isEmpty(targetCycle)?null:targetCycle.substring(0,1).toUpperCase() + "-0";

		JdbcTemplate jdbc = new JdbcTemplate("METADB");
		Writer out = response.getWriter();
		Gson gson = new Gson();
		Map<String, String> returnRes = new HashMap<String, String>();

		try {
			// 删除原有依赖
			String delete_sql = " DELETE FROM transdatamap_design WHERE target ='"
					+ target + "' ";
			jdbc.execute(delete_sql);
			// 保存依赖关系
			String _sql = " insert into transdatamap_design (xmlid,flowcode,transname,source,sourcetype,sourcefreq,target,targettype,targetfreq) values ";
			StringBuilder values = new StringBuilder();
			String transname = target;
			if (sourceType.toUpperCase() .equals("SCOPE")) {
				transname = source;
			}

			String[] sources = source.split(",");
			String[] sourcecycles=sourceCycle.split(",");
			for (int i = 0; i < sources.length; i++) {
				String uuid = UUID.randomUUID().toString().replace("-", "");values.append("('" + uuid + "',");
				values.append("'DEFAULT_FLOW',");
				values.append("'" + transname.toUpperCase() + "',");
				values.append("'" + sources[i] + "',");
				values.append("'" + sourceType + "',");
				String sourceFreq= sourcecycles[i].equals("null")?null:sourcecycles[i].substring(0,1).toUpperCase()+"-0";
				if(sourceFreq==null){
					values.append("NULL,");
				}else{
					values.append("'" + sourceFreq + "',");
				}
				values.append("'" + target + "',");
				values.append("'" + targetType.toUpperCase() + "',");
				values.append("'" + targetFreq + "')");
				if (i < sources.length - 1) {
					values.append(",");
				}
			}
			_sql+=values.toString();
			jdbc.execute(_sql);
			
			//指标组初始化/修改调度信息
			if (targetType.toUpperCase().equals("SCOPE")) {
				String infoSql = "";
				String __sql="select count(1) from proc_schedule_info where proc_name = '" + target + "'";
				int count = jdbc.queryForObject(__sql, Integer.class);
				if (count>0) {
					infoSql = "UPDATE proc_schedule_info a SET a.pri_level=(SELECT priority FROM kpi_scope_def WHERE kpi_scope_code = a.proc_name) WHERE a.proc_name = '"
							+ target + "'";
				} else {
					infoSql = "INSERT INTO proc_schedule_info (proc_name,run_freq,pri_level) SELECT kpi_scope_code,cycle,priority FROM kpi_scope_def WHERE kpi_scope_code = '"
							+ target + "'";
				}
				jdbc.execute(infoSql);
			}
			returnRes.put("response", "数据更新成功！");
			returnRes.put("flag", "true");
		} catch (Exception e) {
			returnRes.put("response", e.getMessage().toString());
			returnRes.put("flag", "false");
		} finally {
			out.write(gson.toJson(returnRes));
		}

	}
	
	public String getSourceFreq(String source,String sourceType,JdbcTemplate jdbc){
		String sql="";
		if(sourceType.toLowerCase()=="proc"){
			sql="SELECT cycletype FROM proc ";
		}
		if(sql.length()==0){
			return null;
		}else{
			Map<String,Object> obj = jdbc.queryForMap(sql);
			String cycle = obj.get(1).toString();
			String freq = (cycle==null||cycle.length()==0)?null:cycle.substring(0,1).toUpperCase()+"-0";
			return freq;
		}
	}
	
	@RequestMapping(value = "/test")
	public void test(HttpServletRequest request,
			HttpServletResponse response) throws Exception {
		JdbcTemplate jdbc = new JdbcTemplate("METADB");
		String sql="select count(1) from kpi_schedule_info where kpi_scope_code = 'AcctIttemD_Org'";
		int a = jdbc.queryForObject(sql, Integer.class);;
		System.out.println(a);
	}
}
