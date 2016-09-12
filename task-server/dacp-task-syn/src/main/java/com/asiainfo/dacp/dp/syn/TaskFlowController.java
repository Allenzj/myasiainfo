package com.asiainfo.dacp.dp.syn;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.asiainfo.dacp.jdbc.JdbcTemplate;
import com.google.gson.Gson;
@Controller
@RequestMapping(value="/flow")
public class TaskFlowController {
	private int id=1;
	private int pId=0;
	private  String returnName="";
	private List<Map<String,Object>>   reMap=null;
	private  Map<String,String> allDataNode = null;
	@RequestMapping("/getZTreeNode/{seqno}")
	@ResponseBody
	public String  getZTreeNode(@PathVariable String seqno){
		reMap = new ArrayList<Map<String,Object>>();
		allDataNode=new HashMap<String, String>();
		id=1; 
		pId=0;
		String sql ="select xmlid,proc_name from proc_schedule_log where  seqno='"+seqno+"'";
		JdbcTemplate jdbcTemplate =new JdbcTemplate("METADB");
		List<Map<String,Object>>  procNameArr = jdbcTemplate.queryForList(sql);Map<String,Object>  map = new HashMap<String, Object>();
		map.put("id",id);
		map.put("pId",0);
		map.put("source", procNameArr.get(0).get("xmlid").toString());
		map.put("target", procNameArr.get(0).get("xmlid").toString());
		map.put("name",procNameArr.get(0).get("proc_name").toString());
		map.put("open",true); 
		reMap.add(map);
		pId++;
		id++;
		getbloodData(procNameArr.get(0).get("xmlid").toString(),null);
		Gson  gson=new Gson();
		return gson.toJson(reMap);
	}
	private void getSourceData(String name,String freq,String type){
		String  nextType = "source".equalsIgnoreCase(type)?"target":"source";
		JdbcTemplate jdbcTemplate =new JdbcTemplate("METADB");
		String sql = "select SOURCE,SOURCETYPE,SOURCEFREQ,TARGET,TARGETTYPE,TARGETFREQ,PROC_NAME from TRANSDATAMAP_DESIGN a,proc_schedule_info b where  "+nextType+"=b.xmlid";
		if(StringUtils.isEmpty(name)){
			return ;
		}else{ 
			sql+=" and "+type+"='"+name+"'";
		}
		if(!StringUtils.isEmpty(freq)){
			sql+=" and "+type+"freq='"+freq+"'";
		}
		List<Map<String,Object>> tranMapList=jdbcTemplate.queryForList(sql);
		buildTransData(tranMapList,type);
	}

	private void  getbloodData(String name,String freq){
		getSourceData(name,freq,"source");
	}
	private void buildTransData(List<Map<String,Object>> tranMapList,String type){
		String  nextType = "source".equalsIgnoreCase(type)?"target":"source";
		List<Map<String,String>>  isNextList = new ArrayList<Map<String,String>>();
		for(int i=0;i<tranMapList.size();i++){
			Map<String,Object>   dataMap = tranMapList.get(i);
			if("PROC".equals(dataMap.get(nextType+"type"))){
				Map<String,Object>  map = new HashMap<String, Object>();
				String  pIdName = dataMap.get(type+"type").equals("PROC")?dataMap.get(type).toString():getPId(dataMap.get(nextType).toString(),dataMap.get(type+"freq").toString(),nextType,dataMap.get(type).toString());
				String  idName= dataMap.get(nextType).toString();
				map.put("id",id);
				map.put("pId",pId);
				map.put("name",dataMap.get("proc_name"));
				map.put("target",idName);
				map.put("source",pIdName);
				map.put(type+"freq", dataMap.get(type+"freq"));
				map.put(nextType+"freq", dataMap.get(nextType+"freq"));
				map.put("open",id<3?true:false);
				reMap.add(map);
				allDataNode.put(dataMap.get(nextType).toString()+dataMap.get(type).toString(), id+"");
				id++;
			}
			Map<String,String>  map= new HashMap<String, String>();
			map.put("name",dataMap.get(nextType).toString());
			map.put("freq",dataMap.get(type+"freq").toString());
			map.put("typeName", dataMap.get(type).toString());
			map.put("type",type);
			map.put("pId", pId+"");
			isNextList.add(map);
		}
		if(isNextList!=null&&isNextList.size()>0){
			for(int i=0;i<isNextList.size();i++){
					String  pIdStr =allDataNode.get(isNextList.get(i).get("name")+isNextList.get(i).get("typeName"));
					pId=Integer.valueOf(StringUtils.isEmpty(pIdStr)?isNextList.get(i).get("pId"):pIdStr);
					getSourceData(isNextList.get(i).get("name"),isNextList.get(i).get("freq"),isNextList.get(i).get("type"));
			}
		}
	}
	private String  getPId(String name,String freq,String type,String valueName){
		JdbcTemplate jdbcTemplate =new JdbcTemplate("METADB");
		 returnName="";
		String  nextType = "source".equalsIgnoreCase(type)?"target":"source";
		String  sql = "select SOURCE,SOURCETYPE,SOURCEFREQ,TARGET,TARGETTYPE,TARGETFREQ  from transdatamap_design where  1=1";
		if(StringUtils.isEmpty(name)){
			return  null;
		}else{
			sql+=" and "+type+"='"+valueName+"'";
		} 
		if(!StringUtils.isEmpty(freq)){
			sql+=" and "+type+"freq='"+freq+"'";
		}
		List<Map<String,Object>> tranMapList=jdbcTemplate.queryForList(sql);
		for(Map<String,Object> map:tranMapList){
			if(map.get(type).equals(valueName)){
				 if ("PROC".equals(map.get(nextType+"type"))){
					returnName=map.get(nextType).toString();
				}
				if(StringUtils.isEmpty(returnName)){
						getPId(map.get(type).toString(),map.get(type+"freq").toString(),type,map.get(nextType).toString());
				}else{
					break;
				}
			}
		}
		return returnName;
	}
}
