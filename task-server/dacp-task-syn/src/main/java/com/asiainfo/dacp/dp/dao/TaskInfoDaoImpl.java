package com.asiainfo.dacp.dp.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Repository;
import org.springframework.util.StringUtils;

import com.asiainfo.dacp.dp.constant.Constant.DBNAME;
import com.asiainfo.dacp.dp.model.TaskInfoDtoForBJCT;
import com.asiainfo.dacp.jdbc.JdbcTemplate;

@Repository
public class TaskInfoDaoImpl implements TaskInfoDao{
	private static Logger LOG = LoggerFactory.getLogger(TaskInfoDaoImpl.class);
	@Override
	public int checkExist(String tableName, String[] fieldNames, Object[] values,String metaDb) {
		 JdbcTemplate   JdbcTemplate= new  JdbcTemplate(DBNAME.METADB);
		if(!StringUtils.isEmpty(metaDb)){
			JdbcTemplate= new JdbcTemplate(metaDb);
		}
		String sql = "select 1 from " + tableName + " where ";
		for (int i = 0; i < fieldNames.length; i++) {
			if (i != fieldNames.length - 1) {
				sql += fieldNames[i] + "=? and ";
			} else {
				sql += fieldNames[i] + "=? " ;
			}
		}
		try {
			LOG.debug("exec-sql:{}", sql.toString());
			JdbcTemplate.queryForObject(sql, values, String.class);
			return 1;
		} catch (EmptyResultDataAccessException ex) {
			return 0;
		}
	}
	@Override
	public boolean saveInfo(String tableName, Map<String, Object> insertMap, String metadb) {
		try{
			 JdbcTemplate   JdbcTemplate= new  JdbcTemplate(DBNAME.METADB);
			if(!StringUtils.isEmpty(metadb)){
				JdbcTemplate= new JdbcTemplate(metadb);
			}
			Map <String,List<String>>  dataMap= getKeysAndValues(insertMap);
			Object [] values=dataMap.get("values").toArray(new Object[dataMap.get("values").size()]);
			Object [] keys= dataMap.get("keys").toArray(new Object[dataMap.get("keys").size()]);
			String sql = "insert into "+tableName+"({columns}) values({values})";
			String columns="";
			String value="";
			for (int i=0;i<keys.length;i++){
				if(i!=values.length-1){
					columns+=keys[i]+",";
					value+="?,";
				}else{
					columns+=keys[i];
					value+="?";
				}
			}
			sql= sql.replace("{columns}", columns).replace("{values}",value);
			JdbcTemplate.update(sql,values);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	private static Map<String,List<String>>  getKeysAndValues(Map<String,Object> map){
		if(map.isEmpty())return null;
			Map<String,List<String>> mapList= new HashMap<String, List<String>>();
			List<String> keys=new ArrayList<String>();
			List<String> values = new ArrayList<String>();
			for (String key:map.keySet()){
				keys.add(key);
				values.add(map.get(key).toString());
			}
			mapList.put("keys", keys);
			mapList.put("values", values);
		return mapList;
	}
	@Override
	public Map<String, Object> find(String tableName,String [] findNames ,String[] fieldNames, String[] values, String metadb) {
		String sql ="select ";
		 JdbcTemplate   JdbcTemplate= new  JdbcTemplate(DBNAME.METADB);
		for(int i=0;i<findNames.length;i++){
			if(i!=findNames.length-1){
				sql+=findNames[i]+",";
			}else{
				sql+=findNames[i]+" ";
			}
		}
		sql+=" from "+tableName+" where 1=1";
		for(int i=0;i<fieldNames.length;i++){
				sql+=" and  "+fieldNames[i]+"=?";
		}
		LOG.debug("exec-sql:{}", sql.toString());
		List<Map<String, Object>>  findList= JdbcTemplate.queryForList(sql, values);
		return findList.get(0);
	}
	@Override
	public String deleteProc(String procId) {
		 JdbcTemplate   JdbcTemplate= new  JdbcTemplate(DBNAME.METADB);
		String querrySql="select count(*) count from proc where xmlid='"+procId+"' and state='INVALID'";
		if(JdbcTemplate.queryForList(querrySql).get(0).get("count").toString().equals("1")){//
		try{
		String deleteSql="delete from proc where xmlid='"+procId+"'";
		JdbcTemplate.update(deleteSql);
		String deleteInfoSql="delete from proc_schedule_info where xmlid='"+procId+"'";
		JdbcTemplate.update(deleteInfoSql);
			return "1";	
		}catch(Exception e){
			return "0";	
		}
		}else{
			LOG.info("proc[{}] is valid or proc is not exist ,can not be deleted!please invalid proc first.",procId);
			return "0";
		}
	}
	@Override
	public String updateProc(TaskInfoDtoForBJCT taskdto) {
		 JdbcTemplate   JdbcTemplate= new  JdbcTemplate(DBNAME.METADB);
		String updateSql="update proc set proc_name='"+taskdto.getProcName()+"',path='"+taskdto.getPath()+"',state='UNPUBLISH' where xmlid='"+taskdto.getProcId()+"'";
		
		String updateSqlInfo="update proc_schedule_info set proc_name='"+taskdto.getProcName()+"',exec_path='"+taskdto.getPath()+"' where xmlid='"+taskdto.getProcId()+"'";
		try{
		JdbcTemplate.update(updateSql);
		JdbcTemplate.update(updateSqlInfo);
		return "1";
		}catch(Exception e){
		return "0";	
		}
	}
	  public List<Map<String, Object>> querry(String sql){
		  JdbcTemplate   JdbcTemplate= new  JdbcTemplate(DBNAME.METADB);
		  return JdbcTemplate.queryForList(sql);
	}
	  public  List<Map<String, Object>> queryForList(String sql,Object args){
		  try{
			  JdbcTemplate   JdbcTemplate= new  JdbcTemplate(DBNAME.METADB);
			return JdbcTemplate.queryForList(sql, args);
		  }catch(EmptyResultDataAccessException e){
			  return null;
		  }
	}
}
