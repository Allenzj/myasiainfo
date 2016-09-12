package com.asiainfo.dacp.dp.service;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.asiainfo.dacp.dp.constant.Constant.TASK;
import com.asiainfo.dacp.dp.dao.TaskInfoDao;
import com.asiainfo.dacp.dp.model.TaskInfoDto;
import com.asiainfo.dacp.dp.model.TaskInfoDtoForBJCT;
import com.asiainfo.dacp.dp.util.UUIDUtils;

@Service
public class TaskInfoServiceImpl implements TaskInfoService {
	@Autowired
	private TaskInfoDao  taskInfoDao;
	@Override
	public String saveTaskInfo(TaskInfoDtoForBJCT taskDto) throws Exception {
		boolean  isOk=false;
			if(taskDto==null){
				return "0";
			}
			if(StringUtils.isEmpty(taskDto.getProcName())){
				return "0";
			}
			if(StringUtils.isEmpty(taskDto.getUser())){
				return "0";
			}
			if(StringUtils.isEmpty(taskDto.getPath())){
				return "0";
			}
//			if(StringUtils.isEmpty(taskDto.getAgentCode())){
//				returnMap.put("success", false);
//				returnMap.put("renturnText", "执行主机不能为空");
//				return returnMap;
//			}
			if(checkId(taskDto.getProcId())){
				return taskInfoDao.updateProc(taskDto);
			}
			isOk=saveTask(taskDto);
		if(isOk){
			return "1";
		}else{
			return "0";
		}
	}
	@Transactional
	private boolean saveTask(TaskInfoDtoForBJCT taskDto) throws Exception {
		try {
			Map<String, Object> procMap=new HashMap<String,Object>();
			String xmlid = UUIDUtils.getUUID();
			SimpleDateFormat s=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			String date=s.format(new Date());
			procMap.put("xmlid",taskDto.getProcId());
			procMap.put("proc_name", taskDto.getProcName());
			procMap.put("state", TASK.STATE);//初始化程序状态
			procMap.put("user", taskDto.getUser());//初始化程序所属系统执行用户
			procMap.put("EFF_DATE", date);//初始化创建时间
			procMap.put("STATE_DATE", date);//初始化更新时间
			procMap.put("TEAM_CODE", "AppUser");//初始化普通用户组
			Map<String, Object> procInfoMap=new HashMap<String,Object>();//proc_schedule_info初始化数据
			procInfoMap.put("proc_name", taskDto.getProcName());
			procInfoMap.put("xmlid",taskDto.getProcId());
			procInfoMap.put("exec_path", taskDto.getPath());//初始化程序执行路径
			procInfoMap.put("exec_proc", taskDto.getProcName());//初始化程序执行程序
			procInfoMap.put("trigger_type", 1);//初始化程序触发类型
			procInfoMap.put("resouce_level", 10);//初始化程序资源级别
			procInfoMap.put("redo_num", 3);//初始化程序重做次数
			procInfoMap.put("date_args", 1);//初始化程序日期偏移量
			procInfoMap.put("muti_run_flag", 0);//初始化程序执行模式
			procInfoMap.put("redo_interval", 5);//初始化程序重做次数
			procInfoMap.put("max_run_hours", 24);//初始化程序超时时间
			procInfoMap.put("exp_time", "2050-12-31");//初始化程序有效期
			procInfoMap.put("eff_time", formatDate());//初始化程序起始时间
			boolean  flag=false;
			if(taskInfoDao.saveInfo("proc_schedule_info", procInfoMap, null)){
				flag=taskInfoDao.saveInfo("proc",procMap,null);
			}
			return flag;
//			return taskInfoDao.saveInfo("proc",procMap,null);
		} catch (Exception e) {
			throw new Exception(e);
		}
		
	}

	private Object findPlatform(String agentCode) {
		Map<String, Object> platform=taskInfoDao.find("aietl_agentnode",new String[]{"platform"},new String[]{"agent_name"},new String[]{agentCode},null);
		return platform.get("platform");
	}
	private boolean checkId(String id) throws Exception {
		try{
			int exist = taskInfoDao.checkExist("proc",new String[]{"xmlid"},new String[]{id},null);
			return exist==1?true:false;
		}catch(Exception e){
			throw new Exception(e);
		}
	}
	public String deleteProc(String procId){
	  return taskInfoDao.deleteProc(procId);
	}
	public static String formatDate(){
		Date date=new Date();
		DateFormat format=new SimpleDateFormat("yyyy-MM-dd");
		return format.format(date);
	}
}
