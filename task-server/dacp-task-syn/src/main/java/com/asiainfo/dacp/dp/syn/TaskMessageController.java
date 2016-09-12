package com.asiainfo.dacp.dp.syn;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;

import com.asiainfo.dacp.core.Configuration;
import com.asiainfo.dacp.dp.constant.Constant.DBNAME;
import com.asiainfo.dacp.dp.model.TaskInfoDtoForBJCT;
import com.asiainfo.dacp.dp.model.TaskRunStatusDTO;
import com.asiainfo.dacp.dp.service.TaskInfoService;
import com.asiainfo.dacp.jdbc.JdbcTemplate;
import com.google.gson.Gson;
/**
 * 调度外部接口服务，供外部系统调用
 * @author Silence
 *
 */
@Controller
@RequestMapping("/taskWebservice")
public class TaskMessageController {
	private static Logger LOG = LoggerFactory.getLogger(TaskMessageController.class);
	@Autowired
	private TaskInfoService taskService;
	/**
	 * 提供北京电信天狮接口，同步天狮开发程序至调度系统
	 * @param request
	 * @param response
	 * @param requestBody
	 * @return
	 */
	@RequestMapping(value="/saveTaskInfo",method=RequestMethod.POST,produces =MediaType.APPLICATION_JSON_UTF8_VALUE)
	@ResponseBody
	public String saveTaskMessage(HttpServletRequest request,HttpServletResponse response,@RequestBody String requestBody){
		LOG.info("获取到参数为：{}",requestBody);
		Gson  gson = new Gson();
		Map map=new HashMap();
		String result=""; 
		try {
			TaskInfoDtoForBJCT   taskDto = gson.fromJson(requestBody,TaskInfoDtoForBJCT.class);
			if(org.apache.commons.codec.binary.StringUtils.equals("0", taskDto.getType())){
			result= taskService.saveTaskInfo(taskDto);
			}else{
			result=	taskService.deleteProc(taskDto.getProcId());
			}
			map.put("result", result);
			return gson.toJson(map) ; 
		} catch (Exception e) {
			map.put("result", 0);
			e.printStackTrace();
			LOG.error("保存信息错误,错误原因{}",e.getMessage());
			return gson.toJson(map);
		}
		
	}
/**
 * 提供给北京电信天狮接口，同步agent信息	
 * @param request
 * @param requestBody
 * @return
 */
	@RequestMapping(value="/opAgent",method=RequestMethod.GET,produces = "text/html;charset=UTF-8")
	@ResponseBody
	public String opAgent(HttpServletRequest request,@RequestBody String requestBody){
		RestTemplate rest=new RestTemplate(); 
	    HttpHeaders headers = new HttpHeaders();
	    MediaType type = MediaType.parseMediaType("application/json; charset=UTF-8");
	    headers.setContentType(type);
	    headers.add("Accept", MediaType.APPLICATION_JSON_UTF8_VALUE);
	    HttpEntity<String> formEntity = new HttpEntity<String>(requestBody, headers);
		LOG.info("传递请求参数为:{}",requestBody);
		String url = Configuration.getInstance().getProperty("com.asiainfo.dacp.task.webService");
		LOG.info("传递请求地址为:{}",url);
		String resp=rest.postForObject(url, formEntity, String.class);
		LOG.info("接收到返回值：{}",resp);
		return resp;
	}
/**
 * 提供给华为外部接口，查询程序运行成功与否，查询表是否生成	
 * @param request
 * @param response
 * @param requestBody
 * @return
 */
	@RequestMapping(value="/getTaskStatus",method=RequestMethod.POST ,produces =MediaType.APPLICATION_JSON_UTF8_VALUE)
	@ResponseBody
	public String getTaskStatus(HttpServletRequest request,HttpServletResponse response,@RequestBody String requestBody){
		JdbcTemplate  jdbcTemplate= new  JdbcTemplate(DBNAME.METADBS);
		LOG.info("获取到参数为：{}",requestBody);
		Gson  gson = new Gson();
		Map map=new HashMap();
		TaskRunStatusDTO   taskDto=new TaskRunStatusDTO();
		try{
	     taskDto = gson.fromJson(requestBody,TaskRunStatusDTO.class);
		}catch(Exception e){
			map.put("isSuccess","0");
			map.put("returnMsg","参数【"+requestBody+"】错误，请核查参数！");
			map.put("successTime","");
			return gson.toJson(map);
		}
		String querryXmlid="";
		String querryStatus="";
		String xmlid="";
		String dateArgs="";
		if(StringUtils.equals(taskDto.getType(), "0")){//查询类型是程序
			if(taskDto.getDateArgs().length()==7){
				dateArgs=taskDto.getDateArgs()+"-01";
			}
			querryXmlid="select xmlid from proc where proc_name='"+taskDto.getObjName()+"'";
			querryStatus="select end_time end_time from proc_schedule_log where date_args='"+taskDto.getDateArgs()+"' and xmlid=? and valid_flag=0 and task_state=6 order by end_time desc";
		}else{//查询类型是表
			querryXmlid="select xmlid from tablefile where dataname='"+taskDto.getObjName()+"' and dbname='"+taskDto.getDbName()+"'";
			querryStatus="select  generate_time end_time from proc_schedule_meta_log where data_time='"+taskDto.getDateArgs().replace("-", "").replace(" ", "").replace(":", "")+"' and target=? order by generate_time desc";
		}
		List<Map<String, Object>> list= jdbcTemplate.queryForList(querryXmlid);
		if(list==null||list.size()==0){//如果没查到该目标记录 ，则返回失败
			map.put("isSuccess","0");
			map.put("returnMsg","无该程序/表{"+taskDto.getObjName()+"}记录，请核查。");
			map.put("successTime","");
			return gson.toJson(map);
		}else{
		 xmlid= (String) list.get(0).get("XMLID");
		 List<Map<String, Object>> listResult=jdbcTemplate.queryForList(querryStatus,xmlid);
		if(listResult==null||listResult.size()==0){//无记录代表未完成
				map.put("isSuccess","0");
				map.put("returnMsg","该目标{"+taskDto.getObjName()+"}还未完成，请核查。");
				map.put("successTime","");
		}else{
				map.put("isSuccess","1");
				map.put("returnMsg","该目标{"+taskDto.getObjName()+"}已运行成功。");//完成目标
				map.put("successTime",listResult.get(0).get("end_time"));//完成时间
		}		
		return  gson.toJson(map);
		}
	}
//	public static void main(String[] args) {
//		RestTemplate rest=new RestTemplate(); 
//		String json="{procId:111122223fg3gfhfg,procName:test-updatet12hgfhgf21333,type:0,path:\"/home/bjct11111\",user:olala}";
//		LOG.info("传递请求参数为:{}",json);
//		 	HttpHeaders headers = new HttpHeaders();
//		    MediaType type = MediaType.parseMediaType("application/json; charset=UTF-8");
//		    headers.setContentType(type);
//		    headers.add("Accept", MediaType.APPLICATION_JSON.toString());
//		    HttpEntity<String> formEntity = new HttpEntity<String>(json, headers);
//		    String resp=rest.postForObject("http://127.0.0.1:8080/dacp/taskWebservice/saveTaskInfo", formEntity, String.class);
//		LOG.info("接收到返回值：{}",resp);
//	}
	
}
