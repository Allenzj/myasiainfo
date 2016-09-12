package com.asiainfo.dacp.task.controller;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.asiainfo.dacp.core.BeanFactory;
import com.asiainfo.dacp.jdbc.JdbcTemplate;
import com.asiainfo.dacp.jdbc.datastore.SqlQuery;
import com.asiainfo.dacp.jdbc.datastore.SqlQueryResultVo;
import com.asiainfo.dacp.modle.Proc;
import com.asiainfo.dacp.modle.ProcInfo;
import com.asiainfo.dacp.modle.ProcRelation;
import com.asiainfo.dacp.modle.ProcScheduleInfo;
import com.asiainfo.dacp.modle.ProcScheduleRunpara;
import com.asiainfo.dacp.modle.TransdatamapDesign;
import com.asiainfo.dacp.repositoris.ProcRepository;
import com.asiainfo.dacp.util.JsonHelper;
import com.asiainfo.dacp.web.models.User;
import com.asiainfo.dacp.web.SessionKeyConstants;












import org.springframework.web.bind.annotation.*;
/**
 * 重写ftl拦截，兼容dacp-web版本不匹配的问题
 */

@Controller
@RequestMapping("/taskftl/**")
public class taskviewcontrollerftl {
	//与@RequestMapping的需要一致
	String mappingValue = "/taskftl/";
	
	@RequestMapping(method=RequestMethod.GET)
	public String ftlRedirect(HttpServletRequest request) {
		String path=request.getRequestURI().replaceAll(request.getSession().getAttribute("mvcPath")+mappingValue, "");
		return path;
	}
	
}
