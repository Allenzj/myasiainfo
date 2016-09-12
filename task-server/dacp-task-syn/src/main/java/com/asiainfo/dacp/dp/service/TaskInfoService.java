package com.asiainfo.dacp.dp.service;

import java.util.List;
import java.util.Map;

import com.asiainfo.dacp.dp.model.TaskInfoDtoForBJCT;

public interface TaskInfoService {

	 public String saveTaskInfo(TaskInfoDtoForBJCT taskDto) throws Exception;
	 public String deleteProc(String procId);

}
