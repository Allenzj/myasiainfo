package com.asiainfo.dacp.dp.dao;

import java.util.List;
import java.util.Map;

import com.asiainfo.dacp.dp.model.TaskInfoDtoForBJCT;

public interface TaskInfoDao {

	int checkExist(String tableName, String[] fieldNames, Object[] values,String metaDb);

	boolean saveInfo(String tableName, Map<String, Object> insertMap, String metadb);

	Map<String, Object> find(String tableName,String [] findNames, String[] fieldNames, String[] values,String metadb);
    
	String deleteProc(String procId);
	
	String updateProc(TaskInfoDtoForBJCT taskdto);

	List<Map<String, Object>> querry(String sql);
	
	List<Map<String, Object>> queryForList(String sql,Object args);
}
