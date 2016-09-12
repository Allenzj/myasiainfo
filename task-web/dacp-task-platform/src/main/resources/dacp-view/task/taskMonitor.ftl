<!DOCTYPE html> 
<html lang="zh" class="app"> 
<head>      
	<meta charset="utf-8" />         
	<title>大数据开放平台</title>     
	<meta http-equiv="X-UA-Compatible" content="chrome=1,ie=edge"/>
	<link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-lib/datepicker/datepicker.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-lib/datepicker/jquery.simpledate.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-lib/datepicker/jquery.pst-area-control.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-view/ve/css/dacp-ve-js-1.0.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-res/task/css/implWidgets.css" type="text/css" rel="stylesheet"  />
	<link href="${mvcPath}/dacp-view/aijs/css/ai.css" type="text/css" rel="stylesheet"  />
	
	<script src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js" type="text/javascript"></script>
	<script type="text/javascript" src="${mvcPath}/dacp-lib/jquery/jquery-ui-1.10.2.min.js"></script>
	<script src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>
	<script src="${mvcPath}/dacp-lib/underscore/underscore.js" type="text/javascript"></script>
	<script src="${mvcPath}/dacp-lib/backbone/backbone-min.js" type="text/javascript"></script>
	<script src="${mvcPath}/dacp-lib/highcharts/highcharts.js" type="text/javascript" ></script>
	<script src="${mvcPath}/dacp-lib/datepicker/bootstrap-datepicker.js" type="text/javascript" ></script>
	<script src="${mvcPath}/dacp-lib/datepicker/jquery.simpledate.js" type="text/javascript"></script>
	<script src="${mvcPath}/dacp-lib/datepicker/jquery.pst-area-control.js" type="text/javascript"></script>
	<script src="${mvcPath}/dacp-view/ve/js/dacp-ve-js-1.0.js" type="text/javascript" charset="utf-8"></script>
	<script src="${mvcPath}/ve/ve-context-path.js" type="text/javascript" charset="utf-8"></script>

    <script src="${mvcPath}/dacp-lib/jquery-plugins/bootstrap-treeview.min.js"> </script>
    <script src="${mvcPath}/dacp-lib/jquery-plugins/jquery.layout-latest.js" type="text/javascript"> </script>
    <script src="${mvcPath}/dacp-view/aijs/js/ai.treeview.js"></script>
    
    
    <!-- 使用ai.core.js需要将下面两个加到页面 -->
	<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
	<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>
	
	<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>
    
    
  	<script src="${mvcPath}/dacp-view/task/taskType.js"></script>
  	<script src="${mvcPath}/dacp-view/task/js/scheduleOpLog.js"></script>
  	
<style type="text/css">
	body {
		margin: 0;
		font-family: Roboto, arial, sans-serif;
		font-size: 13px;
		line-height: 20px;
		color: #444444;
		background-color: #f1f1f1;
	}
	
	a{
		cursor:pointer;
	}
	
	.navbar-btn.btn-sm {
		margin-top: 5px;
		margin-bottom: 10px;
	}
	
	tr.active.table-text-visited {
		color: #4CB6CB;
		background-color: #000000;
		font-weight: bold;
	}
	
	.ui-layout-north {
		z-index: 10000 !important;
	}
	
	.ui-layout-center {
		overflow: auto;
	}
	
	.ui-layout-toggler-west .btnCenter {
		background: #00C;
	}
	
	.ui-layout-toggler-west .btnWest {
		background: #090;
	}
	
	.ui-layout-toggler-west .btnBoth {
		background: #C00;
	}
	
	.ui-layout-resizer-west {
		border-width: 0 1px;
	}
	
	.ui-layout-toggler-west {
		border-width: 0;
	}
	
	.ui-layout-toggler-west div {
		width: 4px;
		height: 35px; /* 3x 35 = 105 total height */
	}
	
	.ui-layout-toggler-west .btnCenter {
		background: #00C;
	}
	
	.ui-layout-toggler-west .btnWest {
		background: #090;
	}
	
	.ui-layout-toggler-west .btnBoth {
		background: #C00;
	}
	
	.dropdown-menu{
		position: absolute;
		top: 100%;
		left: 0;
		z-index: 99999;
		display: none;
		float: left;
		min-width: 60px;
		padding: 5px 0;
		margin: 2px 0 0;
		font-size: 14px;
		list-style: none;
		background-color: #fff;
		background-clip: padding-box;
		border: 1px solid #ccc;
		border: 1px solid rgba(0,0,0,.15);
		border-radius: 4px;
		-webkit-box-shadow: 0 6px 12px rgba(0,0,0,.175);
		box-shadow: 0 6px 12px rgba(0,0,0,.175);
		max-height:300px;
		overflow:visible;
	}
	#myModal{
		z-index: 99999;
	}
</style>

<script>
var _status=['0','1',' and task_state>=-7 ','3',' and (task_state between -4 and 4) ',' and task_state= 5 ',' and task_state=6 ',' and task_state>=50 ',' and task_state=-7'];
var _CLASS=['btn-default','btn-info','btn-info','btn-primary','btn-warning','btn-success','btn-danger','btn-warning','btn-default','btn-danger','btn-info','btn-warning','btn-danger'];
var _VALUE=['创建成功','排队等待','并发检测成功','发送至agent','正在运行','运行成功','运行失败','暂停任务','重做后续','等待中断','失效','未触发','等待重做'];

var click_state="";//点击状态
var choose_state="detail_dv_2";//点击div的id 默认显示任务状态
var searchType="m-simple";//全量m-all和去重m-simple
var _sql = "SELECT seqno,a.xmlid,a.proc_name,b.proccnname,b.topicname,b.level_val,b.curdutyer,a.PRI_LEVEL,a.PLATFORM,a.AGENT_CODE,a.RUN_FREQ,TASK_STATE,STATUS_TIME,START_TIME,EXEC_TIME,END_TIME,USE_TIME,RETRYNUM,a.proctype,a.DATE_ARGS,CREATER,a.TIME_WIN,a.return_code,c.ON_FOCUS,queue_flag,ERRCODE,PROC_DATE "+
				"  from proc_schedule_log a left join proc b on a.xmlid = b.xmlid left join proc_schedule_info c on a.xmlid = c.xmlid " +
				"  where 1=1 and a.run_freq <> 'manual' {condi} ";
var _treeSql ="SELECT TOPICNAME,LEVEL_VAL,COUNT(1) NUM FROM (" + _sql + ") t GROUP BY TOPICNAME,LEVEL_VAL ORDER BY NUM DESC";
var _totalSql = " select count(*) as total, sum(case when task_state=6 then 1 else 0 end ) as finish, sum(case when task_state=5 then 1 else 0 end ) as running,sum(case when task_state in (-1,1) then 1 else 0 end ) as created , sum(case when task_state<=4 and task_state>-4 then 1 else 0 end ) as queue, sum(case when task_state=-7 then 1 else 0 end) as unqueue,sum(case when task_state>6 then 1 else 0 end ) as fail " +
		   	    "  from (" + _sql + ") t ";
var team_code = paramMap["team_code"]||"";
_treeSql="SELECT dbname,topicname,rule_code,parentcode,ruletype,rulename,ruletext FROM meta_team_permission WHERE 1=1 {team_code}  AND ruletype IN('database','topic') ORDER BY rule_code";
_treeSql=_treeSql.replace("{team_code}",team_code==""?"":" and team_code = '" + team_code + "'");

var getQueryCondi = function(){
	var _condi="";
	_condi = searchType == "m-simple"? " and valid_flag=0 ":"";
	
	var taskName = $("#task_name input").val().trim();
	if(taskName.length >0 ){
		_condi +=" AND (b.proc_name like '%" + taskName + "%' ) " ;
	}
	
	var curdutyer = $("#curdutyer input").val().trim();
	if(curdutyer.length >0 ){
		_condi +=" AND (b.curdutyer like '%" + curdutyer + "%' ) " ;
	}
	
	var date_args = $("#date_args input").val();
	if(date_args && date_args.length > 0){
		_condi += " and a.date_args = '" + formatDateArgs(date_args) + "'";
	}

	var start_time = $("#start_time").val().trim();
	if(start_time && start_time.length > 0){
		//to_date(end_time,'yyyy-mm-dd hh24:mi:ss')
		_condi += " and start_time >= '" + start_time + " 00:00'";
	} 

	var end_time = $("#end_time").val().trim();
	if(end_time && end_time.length > 0){
		_condi += " and start_time <= '" + end_time + " 23:59'";
	}
	
	var run_freq = $("#run_freq_select select").val();
	if(run_freq.length>0){
		_condi += " and a.run_freq='" + run_freq + "' ";
	}
	
	var agent_code = $("#agent_code_select select").val();
	if(agent_code.length>0){
		_condi += " and a.agent_code='" + agent_code + "' ";
	}
	
	_condi+= getTeamCondi();
	
	return _condi;
}

function validInput(){
	var date_args = $("#date_args input").val().trim();
	if(date_args && date_args.length > 0){
		 if(!/^((\d{4})|(\d{4}-\d{2})|(\d{4}-\d{2}-\d{2})|(\d{4}-\d{2}-\d{2} \d{2})|(\d{4}-\d{2}-\d{2} \d{2} \d{2})|(\d{4}-\d{2}-\d{2} \d{2} \d{2} \d{2}))$/.test(date_args)){
		 	alert("数据日期格式有误");
		 	return false;
		 }
	}
	return true;
}

function getTeamCondi(){
	//var team_code=$("#treetitle span",window.parent.document).eq(0).attr("curteam");//"${team_code!}";
	var team_codes=team_code;
	var curTeamCodeCondi="";
//	for(var i=0;i<_UserInfo.userGroups.length;i++){
//		team_codes += "'"+_UserInfo.userGroups[i].groupCode+"',"
//	}
	if(typeof(team_codes)!="undefined" && team_codes.length>0){
		//team_codes = team_codes.substring(0,team_codes.length-1);
		curTeamCodeCondi ="  and b.team_code in ('" + team_codes + "')";
	}
	/* else{
		curTeamCodeCondi = " and 1=2";
	} */
	return curTeamCodeCondi;
}

var switchContent = function(condi){
	if(!condi||typeof(condi)=="undefined"){
		condi="";
	}
	
	var tree = _treeSql.replace("{condi}",condi);
	var content = _sql.replace("{condi}",condi);
	var total = _totalSql.replace("{condi}",condi);
	
	_contentStore.config.sql = content;
	_contentStore.fetch();
	_totalStore.config.sql = total;
	choose_state = "detail_dv_2";
	_totalStore.fetch();
};

var kill = function(seqno,agentCode){
	$.ajax({ 
		url:'/'+contextPath+'/syn/kill?SEQNO='+seqno+'&AGENT_CODE='+agentCode+'&SYN_TYPE=KILL_PROC',
		error:function(){     
		       alert('网络错误！');     
	    },
		success:function(msg){
			var msg = $.parseJSON(msg);
			if(msg.flag==true||msg.flag=="true"){
			     alert('终止任务成功');
				 _contentStore.fetch();
			}else{
				alert('终止任务失败');     
			}
		}
  });
}

//刷新统计面板不更新数据
var refreshTotal = function(condi){
	if(!condi||typeof(condi)=="undefined"){
		condi="";
	}

	var tree = _treeSql.replace("{condi}",condi);
	var content = _sql.replace("{condi}",condi);
	
	_contentStore.config.sql = content;
	_contentStore.fetch();
	_totalStore.fetch();
};

function showDetail(seqno,op){
	window.open("/" + contextPath + "/ftl/task/monitorDialog?seqno="+seqno+"&op="+op);
}
function showTransDataMapManual(seqno,procName,dateArgs){
	window.open("/" + contextPath + "/ftl/task/monitorRedoManual?seqno="+seqno+"&procName="+procName+"&dateArgs="+dateArgs);
}

//统计面板
var _totalPanel = new ve.HtmlWidget({
	config:{
		"className": "html",
		"id": "view_total_up_total_id",
		"template":
			'<div class="total_line row">'+
		   		'<div class="total_run col-sm-2">'+
		   			'<div class="total_1 ">任务运行概况</div>'+
		   			'<div id="total_2" class="total_2 "><%=curDate%></div>'+
	   			'</div>'+
	       		'<div class="total_detail col-sm-10">'+
			        '<div id="detail_dv_1" class="detail_1" ><label class="total_label_1"><%=finishRate%>%</label><div><label class="sm-detail">运行成功率</label></div></div>'+
			        '<div id="detail_dv_2" class="detail_dv detail_2" ><label class="total_label_2 detail_label" id="2"><%=total%></label><div><label class="sm-detail">总程序数</label></div></div>'+
			        '<div id="detail_dv_3" class="detail_dv detail_3" ><label class="total_label_3 detail_label" id="6"><%=finish%></label><div><label class="sm-detail">执行成功</label></div></div>'+
			        '<div id="detail_dv_4" class="detail_dv detail_4" ><label class="total_label_4 detail_label" id="7"><%=fail%></label><div><label class="sm-detail">执行失败</label></div></div>'+
			        '<div id="detail_dv_5" class="detail_dv detail_5" ><label class="total_label_5 detail_label" id="5"><%=running%></label><div><label class="sm-detail">正在执行</label></div></div>'+
			        '<div id="detail_dv_6" class="detail_dv detail_6" ><label class="total_label_6 detail_label" id="4"><%=queue%></label><div><label class="sm-detail">排队等待</label></div></div>'+
			        '<div id="detail_dv_7" class="detail_dv detail_7" ><label class="total_label_7 detail_label" id="8"><%=unqueue%></label><div><label class="sm-detail">未触发</label></div></div>'+
       			'</div>'+
	       '</div>',
		"events":{
			afterRender:function(){
				var _view = this;
				var curDate = $("#date_args input").val();
			
		  		var finish = _totalStore.models.length>0?_totalStore.models[0].get("FINISH"):0;
		  		var fail =    _totalStore.models.length>0?_totalStore.models[0].get("FAIL"):0;
		  		var running = _totalStore.models.length>0?_totalStore.models[0].get("RUNNING"):0;
		  		var unqueue= _totalStore.models.length>0?_totalStore.models[0].get("UNQUEUE"):0;
		  		var queue = _totalStore.models.length>0?_totalStore.models[0].get("QUEUE"):0;
		  		var total = _totalStore.models.length>0?_totalStore.models[0].get("TOTAL"):0;
		  		
		  		finish = finish==undefined||finish==null?0:finish;
		  		fail = fail==undefined||fail==null?0:fail;
		  		running = running==undefined||running==null?0:running;
		  		queue = queue==undefined||queue==null?0:queue;
		  		unqueue = unqueue==undefined||unqueue==null?0:unqueue;
		  		
		  		var finishRate = (finish*100/(total==0?1:total)).toFixed(2);
		  		_view.$el.addClass('info-general').empty().append(_.template(_view.config.template,{
		  			'curDate':curDate,
		  			'finishRate':finishRate,
		  			'total':total,
		  			'finish':finish,
		  			'fail':fail,
		  			'running':running,
		  			'queue':queue,
		  			'unqueue':unqueue
	  			}));
		  		_view.$el.find(".detail_dv").css("cursor","pointer");
				_view.$el.find(".detail_dv").on('click',function(e){
					if(!validInput())return false;
		  			var _id = $(e.currentTarget).find(".detail_label").attr("id");
		  			choose_state = $(e.currentTarget).attr("id");
		  			click_state = _status[_id];
		  			refreshTotal(getQueryCondi() + click_state);
		  		});
				//active
				if(choose_state) $("#"+choose_state).css("border","2px solid blue");
			}
		}
	}
});

//查询面板
var _queryPanel = new ve.FormWidget({
	config:{
		"class":"form",
		"formClass":"form-inline",
		"id": "view_total_up_total_tab_nav",
		"noJustfiyFilter":"on",
		"items": [/*
			{
				"type":"combox",
				"id":"task_state_select",
				"fieldLabel":"状态",
				"select":[{'key':'2','value':'全部状态'},{'key':'4','value':'排队等待'},{'key':'5','value':'正在运行'},{'key':'6','value':'执行成功'},{'key':'7','value':'执行失败'},{'key':'8','value':'未触发'}],
			    "style": "min-width:60px;width:95px;"
			},*/
			{
				"type":"combox",
				"fieldLabel":"任务周期",
				"id":"run_freq_select",
				"select":${cycleList!"[]"},
				"style": "min-width:80px;width:100px;"
			},
			{
				"type":"combox",
				"fieldLabel":"执行Agent",
				"id":"agent_code_select",
				"select":${agentList!"[]"},
				"style": "min-width:80px;width:100px;"
			},
			{
				"type": "text",
				"id":"curdutyer",
				"fieldLabel":"",
				"placeholder":"当前责任人",
				"style": "min-width:80px;width:120px;"
			},
			{
				"type": "text",
				"id":"task_name",
				"fieldLabel":"",
				"placeholder":"任务名称",
				"style": "min-width:80px;width:155px;"
			},
			{
				"type": "timebetween",
				"id":"timebetween",
				"startTimeId":"start_time",
				"endTimeId":"end_time",
				"fieldLabel":"时间范围",
				"placeholder":"时间范围",
				"format" : "yyyy-mm-dd",
				"style": "min-width:80px;width:100px;"
			},
			{
				"type": "text",
				"id":"date_args",
				"fieldLabel":"数据日期",
				"placeholder":"格式yyyy-MM-dd hh mm ss",
				"format" : "yyyy-mm-dd",
				"style": "min-width:80px;width:120px;"
			},
			{
				"id":"search",
				"value":"查询",
				"type":"button",
				"className":"search_btn btn-sm btn-primary",
			},
			{
				"id":"switch-mode",
				"value":"",
				"type":"button",
				"className":"search_btn btn-sm btn-primary",
			},
			{
				"id":"batch_redo_self",
				"value":"批量重做当前",
				"type":"hidden",
				"className":"search_btn btn-sm btn-warning",
			},
			{
				"id":"batch_redo_after",
				"value":"批量重做后续",
				"type":"hidden",
				"className":"search_btn btn-sm btn-danger",
			},
			{
				"id":"batch_option",
				"value":"多批次操作",
				"type":"button",
				"className":"search_btn btn-sm btn-warning",
				"style": "margin-left:5px;"
			},
			{
				"id":"export-to-excel",
				"value":"导出数据",
				"type":"button",
				"className":"search_btn btn-sm btn-primary",
			}
		],
		'events': {
			afterRender:function(){
				var _view = this;
				_view.$el.find('form').addClass('form_personal');
				_view.$el.css("padding","2px 2px 2px 20px");
				_view.$el.find("#task_name").after("<br />");
				_view.$el.find("#timebetween").attr("style","margin-right:4px");
				_view.$el.find("#search").attr("style","margin-left:10px")
				_view.$el.find("#refresh-btn button").append('<span class="glyphicon glyphicon-refresh"></span>');
				
				_view.$el.find("#switch-mode").empty().append(
					'<div class="btn-group" data-toggle="buttons" style="margin-right: 5px;">'+
						'<label id="m-simple" class="btn btn-sm btn-info active">'+
							'<input type="radio" name="options">'+
							'<i class="fa fa-check text-active" ></i>去重'+
						'</label>'+
						'<label id="m-all" class="btn btn-sm btn-success">'+
							'<input type="radio" name="options">'+
							'<i class="fa fa-check text-active"></i>全量'+
						'</label>'+
					'</div>'
				);

				var _refresh = function(flag){
					if(flag){
						REFRESHTIMER = setTimeout(function(){
							_contentStore.fetch();
							_totalStore.fetch();
							_refresh(true);
						},10000);
					}else{
						clearTimeout(REFRESHTIMER);
					}
				};
				_view.$el.find("#m-simple,#m-all").on("click",function(e){
					if(!validInput())return false;
					searchType = $(e.currentTarget).attr("id");
					if(searchType=="m-simple"){
						$("#batch_redo_self").show();
						$("#batch_redo_after").show();
					}else{
						$("#batch_redo_self").hide();
						$("#batch_redo_after").hide();
					}
					switchContent(getQueryCondi());
			   });
			},
			'change #agent_code_select select':function(e){
				if(!validInput())return false;
				switchContent(getQueryCondi());
			},
			'change #run_freq_select select':function(e){
				if(!validInput())return false;
			    switchContent(getQueryCondi());
			},/*
			'change #task_state_select select':function(e){
				switchContent(getQueryCondi());
			},*/
			'click #search':function(){
				if(!validInput())return false;
				switchContent(getQueryCondi());
			},
			'click #batch_option':function(){
				var selected = _grid.getCheckedRows();
				if(selected.length!=1){
					alert("只能选择一项");					
				}else{
					var seqno=selected[0].SEQNO;
					var xmlid = selected[0].XMLID;
					var procName = selected[0].PROC_NAME;
					var dateArgs = selected[0].DATE_ARGS;
					batchOptionDialog(seqno,xmlid,procName,dateArgs);
				}
			},
			'click #refresh-btn':function(){
				if(!validInput())return false;
				switchContent(getQueryCondi());
			},//批量重做当前
			'click #batch_redo_self':function(){
				var selected = _grid.getCheckedRows();
				if(selected.length==0){
					alert("至少选中一个可重做项");					
				}else{
					if(confirm("确定所选项都要重做当前吗？")){
						redoProc("cur",selected);
						//刷新版面
						switchContent(getQueryCondi());
					}
				}
			},//批量重做后续
			'click #batch_redo_after':function(){
				var selected = _grid.getCheckedRows();
				if(selected.length==0){
					alert("至少选中一个可重做项");					
				}else{
					if(confirm("确定所选项都要重做后续吗？")){
						redoProc("after",selected);
						//刷新版面
						switchContent(getQueryCondi());
					}
				}
			},//导出查询的数据为EXCEl的格式
			'click #export-to-excel':function(){
				var header = [{"label":'程序名称',"dataIndex":"PROC_NAME"},{"label":'周期',"dataIndex":"RUN_FREQ"},{"label":'Agent',"dataIndex":"AGENT_CODE"},{"label":'状态',"dataIndex":"TASK_STATE"},{"label":'当前责任人',"dataIndex":"CURDUTYER"},{"label":'创建时间',"dataIndex":"START_TIME"},{"label":'开始执行时间',"dataIndex":"EXEC_TIME"},{"label":'执行结束时间',"dataIndex":"END_TIME"},{"label":'运行时长',"dataIndex":"USE_TIME"},{"label":'批次号',"dataIndex":"DATE_ARGS"}];
				var contextPath = location.pathname.split('/')[1]||'';
		        contextPath = '/'+contextPath+'/ve/download';
				var exportSql=_contentStore.config.sql;
		        //exportSql = exportSql.replace("order by START_TIME desc"," ");
		        var sql="select proc_name,run_freq,agent_code,task_state,creater,start_time,exec_time,end_time,use_time,date_args,time_win from( "
			        	  + " select proc_name,agent_code,creater,start_time,exec_time,end_time,date_args,time_win, "
			        	  + " case run_freq  "
			        	  + " when 'year' then '年' "
			        	  + " when 'month' then '月' "
			        	  + " when 'day' then '日' "
			        	  + " when 'hour' then '时' "
			        	  + " when 'minute' then '分' "
			        	  + " when 'manual' then '手工任务' "
			        	  + " when 'week' then '周' "
			        	  + " else '--' end as run_freq, "
			        	  + " case "
			        	  + " when task_state = -7 then '未触发' "
			        	  + " when task_state = -6 then '失效' "
			        	  + " when task_state = -5 then '等待中断' "
			        	  + " when task_state in (-3, -2, -1) then '暂停任务' "
			        	  + " when task_state = 0 then '重做后续' "
			        	  + " when task_state = 1 then '创建成功' "
			        	  + " when task_state in (2,3) then '排队等待' "
			        	  + " when task_state = 4 then '发送至agent' "
			        	  + " when task_state = 5 then '正在运行' "
			        	  + " when task_state = 6 then '运行成功' "
			        	  + " else '运行失败' end as task_state, "
			        	  //+ " CASE WHEN end_time IS NULL THEN '--' WHEN exec_time IS NULL THEN '--' ELSE TIME_FORMAT(TIMEDIFF(end_time, exec_time),'%H:%i:%s') END AS time_ss "
			        	  + " case when use_time is null then '--' else use_time  end as use_time "
		        	  + " from ( " + exportSql + " ) tt "
		        	+" ) t ";
		        var downloadStore = new AI.JsonStore({
					sql: sql,
					dataSource:"METADBS"
				});
		        if (downloadStore && downloadStore.count>0){
					ve.DownloadHelper.download({
					    sql:sql,
					    dataSource:"METADBS",
					    header:JSON.stringify(header),
					    url:contextPath,
					    fileName : "任务监控的查询结果",
					    fileType:'excel'
			        });
		        }else{
		        	alert("没有数据！");
		        }
				
			}
		}
	}

});

function getTopicCodes(node){
	var codes = [];
	
	function getChildTopicCodes(node){
		if(node.nodes && node.nodes.length>0){
			$.each(node.nodes,function(i,item){
				if(item.nodes && item.nodes.length>0){
					getChildTopicCodes(item);
				}else{
					//codes.push(item.id);
					codes.push(item.id.substr(item.id.lastIndexOf("-")+1));
				}
			});
		}else{
			codes.push(node.id.substr(node.id.lastIndexOf("-")+1));
		}
	}
	
	getChildTopicCodes(node,codes);
	return codes;
}


//左边树
var buildTreeView = function(sql){
	/*
	$('#treeview6').treeview({
		color: "#428bca",
		expandIcon: "glyphicon glyphicon-chevron-right",
		collapseIcon: "glyphicon glyphicon-chevron-down",
		nodeIcon: "glyphicon glyphicon-user",
		showTags: true,
		levels: 4,
		onNodeSelected:function(event,node){
			var topicCodes = getTopicCodes(node);
			var codes = "";
			if(topicCodes && topicCodes.length>0){
				for(var i=0; i< topicCodes.length; i++){
					codes += "'"+topicCodes[i]+"',"
				}
				codes = codes.substr(0,codes.length-1);
			}
			
			var topicCondi = "and b.topiccode in (" + codes + ")";
			switchContent(topicCondi + getQueryCondi() + click_state);
		},
		// groupfield:"DBNAME,LEVEL_VAL,CYCLETYPE",//SCHEMA_NAME,TABSPACE,
		pkeyfield:"PARENTCODE",
		keyfield:"RULE_CODE",
		titlefield:"RULENAME",
		rootval: "R01",
		iconfield:"",
		sql:sql,
		dataSource:"METADB",
		// subtype: 'grouptree' 
		subtype: 'simpletree' 
	});*/
};

var procNameRender = function(value,data,index){
	var res='<a href="#" style="text-decoration:underline;color:blue;" title="查看调度信息" onclick="showProcScheduleInfo(\'' + data.XMLID.trim() + '\')">'+ value +'</a>';
	return res;
};

function showProcScheduleInfo(xmlid){
	$("#upsertForm").empty();
	var sql="SELECT b.proc_name,b.creater,a.platform,a.agent_code,a.trigger_type,a.eff_time,a.exp_time,a.cron_exp,a.muti_run_flag,a.date_args,a.pri_level FROM proc_schedule_info a RIGHT JOIN proc b on a.proc_name = b.proc_name where b.xmlid ='" + xmlid + "'";
	ds_mydata=new AI.JsonStore({
		sql : sql,
		filter : 'proctype =1',
		selfield : '',
		key : "XMLID",
		pageSize : 15,
		table : "PROC",
		dataSource:"METADBS"
	});
	var formcfg = ({
		id : 'form',
		store : ds_mydata,
		containerId : 'upsertForm',
		items : [ 
			{type : 'text',label : '程序名称',fieldName : 'PROC_NAME',isReadOnly:"y"},
			{type : 'date',label : '上线时间',fieldName : 'EFF_TIME',value:new Date().format('yyyy-mm-dd'),isReadOnly:"y"}, 
			{type : 'date',label : '下线时间',fieldName : 'EXP_TIME',isReadOnly:"y"},
			{type : 'text',label : '资源组',fieldName : 'PLATFORM',isReadOnly:"y"},
		    {type : 'text',label : 'AGENT',fieldName : 'AGENT_CODE',isReadOnly:"y"},
			{type : 'text',label : '优先级',fieldName : "PRI_LEVEL",isReadOnly:"y"}, 
			{type : 'radio-custom',label : '运行模式',fieldName : 'MUTI_RUN_FLAG',storesql:'0,顺序启动|1,多重启动|2,唯一启动|3,月内顺序启动',isReadOnly:"y"},
			{type:  "radio-custom", label: "触发类型", fieldName: "TRIGGER_TYPE",storesql:'0,时间触发|1,事件触发',isReadOnly:"y"},
			{type : 'text',label : 'cron表达式',fieldName : 'CRON_EXP',isReadOnly:"y"}, 
			{type : 'text',label : '日期偏移量',fieldName : 'DATE_ARGS',isReadOnly:"y"}
		],
		
	});

	var from = new AI.Form(formcfg);
	var x = document.getElementsByName('TRIGGER_TYPE');
       for (var j = 0; j < x.length; j++) {
           if (x[j].checked) {
           	if(j == '0'){
           		$("#CRON_EXP").parent().parent().show();
        		$("#DATE_ARGS").parent().parent().show();
           	}else{
           		$("#CRON_EXP").parent().parent().hide();
        		$("#DATE_ARGS").parent().parent().hide();
           	}
           }
       }
	$("#dialog-ok").hide();
	$(".modal-title").html("查看调度信息");
	$('#myModal').css("z-index",99999)
	
	$(".close-modal").click(function(){
		$('#myModal').modal('hide');
	});
	
    $('#myModal').modal({
		show : true,
		backdrop:false
	});
}

var runFreqRender = function(value,data,index){
	var res="未知";
	switch(value){
		case "year":
			res="年"
			break;
		case "week":
			res="周"
			break;
		case "month":
			res="月"
			break;
		case "day":
			res="日"
			break;
		case "hour":
			res="小时"
			break;
		case "minute":
			res="分钟"
			break;
		default:
			break;
	}
	return res;
};

var _argsRender = function (value,data,index){
	var args = data.DATE_ARGS;
	var argsType = data.RUN_FREQ;
	switch(argsType){
		case "month":
			args = args.substr(0,7);
			break;
		case "year":
			args = args.substr(0,4);
			break;
		default:
			break;
	}
	return args;
};

var _stateIcon = function(value,data,index){
	//操作下拉菜单
	var li_condi = '<li><a id="li_condi" seq="<%=seqno%>" name="<%=procName%>" err="<%=errorCode%>" status="<%=task_status%>">查看执行条件</a></li>';
	var li_log = '<li><a id="li_log" seq="<%=seqno%>">查看日志</a></li>';
	var li_running_log = '<li><a id="li_running_log" seq="<%=seqno%>" agent="<%=agent%>">查看运行日志</a></li>';
	var li_force_pass = '<li><a id="li_force_pass" seq="<%=seqno%>">强制通过</a></li>';
	var li_force_exec = '<li><a id="li_force_exec" seq="<%=seqno%>" >强制执行</a></li>';
	var li_stop = '<li><a id="li_stop" seq="<%=seqno%>" agent="<%=agent%>">停止</a></li>';
	var li_pause = '<li><a id="li_pause" seq="<%=seqno%>" task_status="<%=task_status%>">暂停执行</a></li>';
	var li_recover = '<li><a id="li_recover" seq="<%=seqno%>" task_status="<%=task_status%>">恢复任务</a></li>';
	/* var li_redo_after = '<li><a id="li_redo_after" seq="<%=seqno%>">重做后续</a></li>'; */
	var li_redo_after ='<li class="dropdown-submenu">'+
				'<a tabindex="-1" href="javascript:;">重做后续</a>'+
				'<ul class="dropdown-menu" >'+
					'<li class=""> <a id="li_redo_after_0" name="li_redo_after_0" seq="<%=seqno%>" href="javascript:;">'+'<span class="glyphicon "></span>'+'重做后续</a></li>'+
					'<li class="" > <a id="li_redo_after_2" name="li_redo_after_2" dateArgs="<%=dateArgs%>"  procName="<%=procName%>" seq="<%=seqno%>"  returncode="<%=returnCode%>"  href="javascript:;">'+'<span class="glyphicon "></span>'+'临时重做</a></li>'+
				'</ul></li>';
	var li_redo_self = '<li><a id="li_redo_self" seq="<%=seqno%>">重做当前</a></li>';
	var li_use_time = '<li><a id="li_use_time"   seq="<%=seqno%>">时长分析</a></li>';
	//taskType.js设置dp_redo_type
	if((dp_redo_type=='1' || dp_redo_type==1) && value>=50 && data.PROCTYPE == "dp" ){ 
		li_redo_after =
			'<li class="dropdown-submenu">'+
				'<a tabindex="-1" href="javascript:void(0);">重做后续</a>'+
				'<ul class="dropdown-menu" >'+
					'<li> <a id="li_redo_after_0" name="li_redo_after_0" seq="<%=seqno%>" href="javascript:void(0);"><span class="glyphicon "></span>从开始步骤启动</a></li>'+
					'<li> <a id="li_redo_after_1" name="li_redo_after_1" seq="<%=seqno%>" returncode="<%=returnCode%>" href="javascript:void(0);"><span class="glyphicon "></span>从错误步骤启动</a></li>'+
					'<li class="" > <a id="li_redo_after_2" name="li_redo_after_2" dateArgs="<%=dateArgs%>"  procName="<%=procName%>" seq="<%=seqno%>"  returncode="<%=returnCode%>"  href="javascript:;">'+'<span class="glyphicon "></span>'+'临时重做</a></li>'+
				'</ul>'+
			'</li>';
		li_redo_self =
			'<li class="dropdown-submenu">'+
				'<a tabindex="-1" href="javascript:void(0);">重做当前</a>'+
				'<ul class="dropdown-menu" >'+
					'<li> <a id="li_redo_self_0" name="li_redo_self_0" seq="<%=seqno%>" href="javascript:void(0);"><span class="glyphicon "></span>从开始步骤启动</a></li>'+
					'<li> <a id="li_redo_self_1" name="li_redo_self_1" seq="<%=seqno%>"  returncode="<%=returnCode%>"  href="javascript:void(0);">'+'<span class="glyphicon "></span>从错误步骤启动</a></li>'+
				'</ul>'+
			'</li>';
	}
	
	var li_set_priv='<li class="dropdown-submenu">'+
				    	'<a tabindex="-1" href="javascript:void(0);">设置优先级</a>'+
					    '<ul class="dropdown-menu" >'+
					        '<li class="<%=(priLevel==20?"active":"")%>"><a id="li_set_priv" name="20" seq="<%=seqno%>" href="javascript:;"><span class="glyphicon glyphicon-ok <%=priLevel==20?"":"hide"%>"></span> 高（20）</a></li>'+
					        '<li class="<%=(priLevel>14&&priLevel<20?"active":"")%>"><a id="li_set_priv" name="15" seq="<%=seqno%>" href="javascript:;"><span class="glyphicon glyphicon-ok <%=priLevel>14&&priLevel<20?"":"hide"%>"></span> 高于正常（15）</a></li>'+
					        '<li class="<%=(priLevel>9&&priLevel<15?"active":"")%>"><a id="li_set_priv" name="10" seq="<%=seqno%>" href="javascript:;"><span class="glyphicon glyphicon-ok <%=priLevel>9&&priLevel<15?"":"hide"%>"></span> 正常（10）</a></li>'+
					        '<li class="<%=(priLevel>5&&priLevel<10?"active":"")%>"><a id="li_set_priv" name="5" seq="<%=seqno%>" href="javascript:;"><span class="glyphicon glyphicon-ok <%=priLevel>5&&priLevel<10?"":"hide"%>"></span> 低于正常（5）</a></li>'+
					        '<li class="<%=priLevel<5?"active":""%>"><a id="li_set_priv" name="1" seq="<%=seqno%>" href="javascript:;"><span class="glyphicon glyphicon-ok <%=priLevel<5?"":"hide"%>"></span> 低（1）</a></li>'+
					    '</ul>'+
			        '</li>';
			  
	var lis ="";
	var flag = value;
	switch(value){
		case -7:
			flag = 12;
			lis = li_force_pass + li_force_exec;
			break;
		case -1:
		case -2:
		case -3:
			flag = 8;
			lis = li_recover;
			break;
		case 0:
			flag = 9;
			//break;
		case 1:
			lis = li_condi + li_force_pass + li_force_exec + li_pause + li_set_priv;
			break;
		case 2:
			//break;
		case 3:
			lis = li_condi + li_force_pass + li_pause + li_set_priv;
			break;
		case 4:
			lis = li_condi;
			break;
		case -5:
			flag = 10;
		case 5:
			lis = li_condi + li_running_log + li_stop;
			break;
		case -6:
			flag = 11;
		case 6:
			lis = li_condi + li_log + li_redo_after + li_redo_self + li_use_time;
			break;
		case 7:
			break;
		default:
			if(value>=50){
				lis = li_condi + li_log + li_redo_after + li_redo_self + li_force_pass + li_use_time;
				flag = data.QUEUE_FLAG==0? 13: 7;
			}
			break;
	}	
	var _tmpl = 
		'<div class="btn-group '+(index>6?"dropup":"")+'">'+
			'<button type="button" class="btn btn-xs <%=cla%> dropdown-toggle" data-toggle="dropdown">'+
				'<%=name%><span class="caret"></span>'+
			'</button>'+
			'<ul class="dropdown-menu" role="menu">'+
				lis +
			'</ul>'+
		'</div>';
	return _.template(_tmpl,{"cla":_CLASS[flag-1],"name":_VALUE[flag-1],"value":value,"seqno":data.SEQNO,"priLevel":data.PRI_LEVEL,"procName":data.PROC_NAME,"task_status":data.TASK_STATE,"agent":data.AGENT_CODE,"errorCode":data.ERRCODE,"returnCode":data.RETURN_CODE,"dateArgs":data.DATE_ARGS});
};

var _timeDiffRender = function(value,data,index){
	var res = '--';
	var end= data.END_TIME;
	var start =data.EXEC_TIME;
	if(start&&start.length>0&&end&&end.length>0){
		start = start.replace(/-/g,"/");
		end  = end.replace(/-/g,"/");
		var _start = new Date(start);
		var _end = new Date(end);
		var diff = _end.getTime()-_start.getTime();
		//计算出相差天数
		var days=Math.floor(diff/(24*3600*1000))
		//计算出小时数
		var leave1=diff%(24*3600*1000)    
		//计算天数后剩余的毫秒数
		var hours=Math.floor(leave1/(3600*1000))
		//计算相差分钟数
		var leave2=leave1%(3600*1000)      
		//计算小时数后剩余的毫秒数
		var minutes=Math.floor(leave2/(60*1000))
		//计算分钟后剩余毫秒数
		var leave3=leave2%(60*1000)
		var secords=Math.floor(leave3/(1000))
		if(days>0){
			hours += days*24;
		}

		var _hours = hours<=9?"0"+hours:""+hours;
		var _minutes=minutes<=9?"0"+minutes:""+minutes;
		var secords=secords<=9?"0"+secords:""+secords;
		if(_minutes.length>0 && _hours.length>0){
			res = _hours+":"+_minutes+":"+secords;
		}else{
			res =  "--";
		}
	}else{
		res= "--";
	}
	return res;
};

//列表
var _grid = new ve.GridWidget({
	config:{
		"className":"grid",
		'id':'evaluateView_tab_evaluate_middle_down_grid',
		'showcheck': true,
		'pageSize':30,
		"header":[
			{"label":"程序名称","dataIndex":"PROC_NAME","className":"ai-grid-body-td-left",renderer: procNameRender},
			{"label":"周期","dataIndex":"RUN_FREQ","className":"ai-grid-body-td-left",renderer: runFreqRender},
			{"label":"Agent","dataIndex":"AGENT_CODE"},
			{"label":"状态","dataIndex":"TASK_STATE","className":"ai-grid-body-td-left",renderer: _stateIcon},
			{"label":"当前责任人","dataIndex":"CURDUTYER"},
			{"label":"创建时间","dataIndex":"START_TIME"},
			{"label":"开始执行时间","dataIndex":"EXEC_TIME"},
			{"label":"执行结束时间","dataIndex":"END_TIME"},
			{"label":"运行时长","dataIndex":"USE_TIME"},//renderer: _timeDiffRender},
			{"label":"批次号","dataIndex":"DATE_ARGS","className":"ai-grid-body-td-left",renderer: _argsRender}
		],
		"events":{
			afterRender:function(){
				var _view = this;
				_view.$el.find(".table-outer").css("overflow","visible");
			},
			rowClick:function(index,data){
				//alert(index)
			},
			rowDblClick:function(index,data,_view){
				var seqno = data.SEQNO;
				showDetail(seqno,"flow");
			},
			
			afterTabelBodyRender:function(){
				var _view = this;
				_view.$el.find(".table-area").css("overflow","visible");

           	 	_view.$el.find("a#li_log,a#li_use_time,a#li_condi,a#li_running_log").on("click",function(e){
					var _seqno = $(e.currentTarget).attr("seq");
					showDetail(_seqno,this.id);
				});
	            
				_view.$el.find("a#li_force_pass,a#li_force_exec,a#li_pause,a#li_recover,a#li_redo_self,a#li_redo_after,a#conti,a#li_set_priv,a#li_stop,a#li_redo_self_0,a#li_redo_self_1,a#li_redo_after_0,a#li_redo_after_1,a#li_redo_after_2").on("click",function(e){
					var _seqno = $(e.currentTarget).attr("seq");
					var _workType = $(e.currentTarget).attr("id");
				    var task_status= $(e.currentTarget).attr("task_status");
				    var agent=$(e.currentTarget).attr("agent");
					//var _newLog = proc_log.getNewRecord();
					var finalSql="update proc_schedule_log  ";
					var execSql="";
					var res="";
					if(_workType=='li_pause'||_workType=='li_recover'){
						var alterStr = _workType=='pause'?"确定暂停程序?":"确定恢复程序?";
						if(confirm(alterStr)){
							execSql=finalSql + "set TASK_STATE='"+(0-task_status)+"' where seqno='"+_seqno+"' and  task_state='"+task_status+"'";
							res=ai.executeSQL(execSql,false,"METADBS");
							
							//记录人工操作日志
							taskOpLog("'"+_seqno+"'",_workType=='pause'?"暂停程序":"恢复程序",execSql,res.success);
						}
					}else if(_workType=='li_set_priv'){
						if(confirm("确定调整优先级?")){
						var _level = $(e.currentTarget).attr("name")
						execSql=finalSql +"set PRI_LEVEL='"+_level+"' where seqno='"+_seqno+"'  ";
						res=ai.executeSQL(execSql,false,"METADBS");
						
						//记录人工操作日志
						taskOpLog("'"+_seqno+"'","调整优先级",execSql,res.success);
						}
					}else if(_workType=='li_force_pass'){
						showForcePassDialog(_seqno);					
					}else if(_workType=='li_force_exec'){
						//_log.set("TASK_STATE",2);
						if(confirm("确定强制执行?")){
							execSql=finalSql+" set TASK_STATE=2,trigger_flag=0,queue_flag=0 where seqno='"+_seqno+"' and (task_state=1 or task_state=-7)";
							res=ai.executeSQL(execSql,false,"METADBS");

							//记录人工操作日志
							taskOpLog("'"+_seqno+"'","强制执行",execSql,res.success);
						}
					}else if(_workType=='li_stop_trigger'){
						//_log.set("TASK_STATE",2);
						if(confirm("停止触发?")){
							execSql=finalSql+" set trigger_flag=1 where seqno='"+_seqno+"' and trigger_flag=1";
							res=ai.executeSQL(execSql,false,"METADBS");
							
							//记录人工操作日志
							taskOpLog("'"+_seqno+"'","停止触发",execSql,res.success);
						}
					}else if(_workType=='li_stop'){
						//_log.set("TASK_STATE",2);
						if(confirm("停止任务?")){
							kill(_seqno,agent);

							//记录人工操作日志
							taskOpLog("'"+_seqno+"'","停止任务",'','');
						}
					}else if(_workType=='li_redo_after_2'){
						var procName=$(e.currentTarget).attr("procname");
						var dateArgs=$(e.currentTarget).attr("dateArgs");
						showTransDataMapManual(_seqno,procName,dateArgs);
					}else if (_workType=='li_redo_self_1'||_workType=='li_redo_after_1'){
						var return_code = $(e.currentTarget).attr("returncode")?$(e.currentTarget).attr("returncode"):0;
						if(confirm("确定从第" + return_code + "步开始重做？")){
							var logStore = getValidStore(_seqno);
							if(!logStore) {
								alert("当前记录已失效，不能被重做！");
								return;
							}
							
							var date = new Date();
							_dateStr = date.format("yyyy-mm-dd hh:mm:ss");
							var sql1=" update proc_schedule_log set valid_flag=1,status_time='"+_dateStr+"' where seqno='"+_seqno+"' and ( task_state=6 or task_state>=50 ) ";
							var sql2=" update proc_schedule_script_log set app_log=CONCAT(app_log,'\\n \\n【前置任务重做，此任务失效】') where seqno='"+_seqno+"' ";
							res=ai.executeSQL(sql1,false,"METADBS");
							ai.executeSQL(sql2,false,"METADBS");

							//录入一条重做记录
							var newlog = logStore.getAt(0);
							newlog.set("SEQNO",getSeqNo());
							newlog.set("TASK_STATE",0);
							newlog.set("START_TIME",_dateStr)
							newlog.set("EXEC_TIME",null)
							newlog.set("END_TIME",null)
							newlog.set("STATUS_TIME",_dateStr);
							newlog.set("QUEUE_FLAG",0);
							newlog.set("TRIGGER_FLAG",_workType=="li_redo_self_1"?1:0);
							newlog.set("VALID_FLAG",0);
							newlog.set("AGENT_CODE",newlog.data.AGENT_CODE);
							newlog.set("FLOWCODE",ai.guid());
							logStore.add(newlog);
							logStore.commit(false);

							//记录人工操作日志
							taskOpLog("'"+_seqno+"'","从第" + return_code + "步开始重做",sql1,res.success);
						}
					}else if (_workType=='li_redo_self'||_workType=='li_redo_after'||_workType=='li_redo_self_0'||_workType=='li_redo_after_0'){
						if(confirm("确定重做?")){
							var logStore = getValidStore(_seqno);
							if(!logStore) {
								alert("当前记录已失效，不能被重做！");
								return;
							}

							//失效当前任务
							var date = new Date();
							_dateStr = date.format("yyyy-mm-dd hh:mm:ss");
							var sql1=" update proc_schedule_log set valid_flag=1,status_time='"+_dateStr+"' where seqno='"+_seqno+"' and ( task_state=6 or task_state>=50 ) ";
							var sql2=" update proc_schedule_script_log set app_log=CONCAT(app_log,'\\n \\n【前置任务重做，此任务失效】') where seqno='"+_seqno+"' ";
							res = ai.executeSQL(sql1,false,"METADBS");
							ai.executeSQL(sql2,false,"METADBS");
							//录入一条重做记录
							var newlog = logStore.getAt(0);
							newlog.set("SEQNO",getSeqNo());
							newlog.set("TASK_STATE",0);
							newlog.set("START_TIME",_dateStr)
							newlog.set("EXEC_TIME",null)
							newlog.set("END_TIME",null)
							newlog.set("STATUS_TIME",_dateStr);
							newlog.set("QUEUE_FLAG",0);
							newlog.set("TRIGGER_FLAG",_workType=="li_redo_self"||_workType=="li_redo_self_0"?1:0);
							newlog.set("VALID_FLAG",0);
							newlog.set("RETURN_CODE",0);
							newlog.set("AGENT_CODE",newlog.data.AGENT_CODE);
							newlog.set("FLOWCODE",ai.guid());
							logStore.add(newlog);
							logStore.commit(false);
							
							//记录人工操作日志
							taskOpLog("'"+_seqno+"'",_workType.indexOf("redo_self")>-1?"重做当前":"重做后续",sql1,res.success);
					  	}
					}
					_contentStore.fetch();
				});
			}
	    }
  }
});


$(document).ready(function() {
	var toggleButtons = '<div class="btnCenter"></div>'
			+ '<div class="btnBoth"></div>'
			+ '<div class="btnWest"></div>';
	$('body').layout({
    	sizable:						false,
    	animatePaneSizing:				true,
    	fxSpeed:						'slow',
    	spacing_open:					0,
    	spacing_closed:					0,
    	west__spacing_closed:			8,
    	west__spacing_open:				8,
    	west__togglerLength_closed:		105,
    	west__togglerLength_open:		105,
    	west__togglerContent_closed:	toggleButtons,
    	west__togglerContent_open:		toggleButtons,
    	west__size:						0,
    	north__size: 					135
	});
	_totalPanel.$el=$("#totalPanel");
	_queryPanel.$el=$("#queryPanel");
	_queryPanel.render();
	_grid.$el=$("#tabpanel1");
	
	var today = new Date();
	var timestamp = today.getTime();
	var defaultEndTime = today.format("yyyy-mm-dd");
	today.setDate(today.getDate()-1);
	var defaultStartTime=today.format("yyyy-mm-dd");
	//var defaultDateArgs = today.format("yyyy-mm-dd");
	$("#start_time").val(defaultStartTime);
	$("#end_time").val(defaultEndTime);

	var _condi = getQueryCondi();
	
	//默认加载失败任务纪录
	//_condi += " and task_state>=50 ";
	
    buildTreeView(_treeSql);
    
	_totalStore = new ve.SqlStore({
		sql:_totalSql.replace("{condi}",_condi),
		dataSource:"METADBS"
	});
	_totalStore.on("reset",function(){
		_totalPanel.store=_totalStore;
		_totalPanel.store.fetched=true;
		_totalPanel.render();
	});
	_totalStore.fetch();
	
	_contentStore=new ve.SqlStore({
		sql: _sql.replace("{condi}",_condi),
		dataSource:"METADBS"
	});
	_contentStore.on("reset",function(){
		_grid.store=_contentStore;
		_grid.store.fetched=true;
		_grid.render();
		
		$(".btnCenter").hide();
		$(".btnBoth").hide();
		$(".btnWest").hide();
		if(_contentStore.length >0){
			$(".btnCenter").show();
			$(".btnBoth").show();
			$(".btnWest").show();
		}		
	});
	_contentStore.fetch();
});
	
function showForcePassDialog(seqno){	
	$("#dialog-ok").show();
	$(".modal-title").html("强制通过原因");
	$("#myModal").modal({
		show:true,
		backdrop:false
	});

	$("#upsertForm").empty();
	$("#dialog-ok").unbind("click");
	var _editPanel = new AI.Form({
		id: 'baseInfoForm',
		//store: tableStore,
		containerId: 'upsertForm',
		fieldChange: function(fieldName, newVal){},
		items: [
			{type : 'text', label : '通过原因', notNull: 'N', fieldName : 'PASS_REASON', width : 420 }
		]
	});
	
	//确定
	$("#dialog-ok").on('click', function(){
		if($("#PASS_REASON").val().trim()==""){
			alert("通过原因不能为空！")
			return false;
		}
		
		var sql= "update proc_schedule_log set TASK_STATE=6,QUEUE_FLAG=0,TRIGGER_FLAG=0 where seqno='"+seqno+"' and task_state<>6 ";
		ai.executeSQL(sql,false,"METADBS");
		
		var sql1 ="select seqno from proc_schedule_script_log where seqno='"+seqno+"' ";
		var store1=ai.getStore(sql1,'METADBS');
		var sql2="";
		if(store1&&store1.count>0){
			sql2=" update proc_schedule_script_log set app_log= CONCAT(app_log,'\\n\\n','【"+getNowTime()+"强制通过】,原因："+$("#PASS_REASON").val()+"') where seqno='"+seqno+"' ";
		}else{
			sql2=" insert into proc_schedule_script_log values('"+seqno+"',(select proc_name from proc_schedule_log where seqno='"+seqno+"'),'DEFAULT_FLOW','【"+getNowTime()+"强制通过】,原因："+$("#PASS_REASON").val()+"')"
		}			
		ai.executeSQL(sql2,false,"METADBS");
		_contentStore.fetch();
        $('#myModal').modal('hide');
	});
	
	$(".close-modal").click(function(){
		$('#myModal').modal('hide');
	});
	
	$("#myModal").modal({
		show:true,
		backdrop:false
	});
}

//多批次操作
function batchOptionDialog(seqno,xmlid,procName,dateArgs){	
	$("#dialog-ok").show();
	$("#dialog-ok").html("确定");
	$(".modal-title").html("多批次操作");
	$("#myModal").modal({
		show:true,
		backdrop:false
	});

	$("#upsertForm").empty();
	$("#dialog-ok").unbind("click");
	var _editPanel = new AI.Form({
		id: 'baseInfoForm',
		//store: tableStore,
		containerId: 'upsertForm',
		fieldChange: function(fieldName, newVal){},
		items: [
			{type : 'text', label : '程序名',isReadOnly:'y', fieldName : 'OPTION_PROC_NAME',value: procName },
			{type : 'text', label : '批次区间', notNull: 'N', fieldName : 'batch_range'},
			{type: 'radio',label : '操作类型', notNull: 'N',fieldName : 'OPTION_TYPE',storesql:'redo_cur,重做当前|redo_after,重做后续'}
	
		]
	});
	
	//修改批次区间显示
	var batch_range = '<input id="start_batch" type="text" class="form-control" style="width:100px; float:left" value="' + dateArgs + '">' +
					  '<span style="float:left"> - </span> ' +
					  '<input id="end_batch" type="text" class="form-control" style="width:100px; float:left" value="' + dateArgs + '">';
	$("#upsertForm").find("#batch_range").parent().html(batch_range);
	
	
	//确定
	$("#dialog-ok").on('click', function(){
		var startBatch = $("#start_batch").val().trim();
		var endBatch = $("#end_batch").val().trim();
		var optionType = getRadioValue("OPTION_TYPE");
		if(start_batch =="" || end_batch==""){
			alert("请填写批次区间！")
			return false;
		}
		if(optionType==""){
			alert("请选择操作类型！")
			return false;
		}
		var triggerFlag=0;
		var sql="";
		switch(optionType){
			case "redo_after":
				triggerFlag=0;
				break;
			case "redo_cur":
				triggerFlag=1;
				break;
			default:
				
				break;
		}
		var now = new Date().format("yyyy-mm-dd hh:mm:ss");
		sql= "update proc_schedule_log set task_state=0,status_time='"+now+"',trigger_flag="+triggerFlag+",queue_flag=0,return_code=0,exec_time=NULL,end_time=NULL where xmlid='"+xmlid+"' and date_args between '"+startBatch+"' and '"+endBatch+"' and valid_flag=0";
		var res = ai.executeSQL(sql,false,"METADBS");
		
		//记录操作日志
		taskOpLog("'"+seqno+"'","多批次"+ (optionType=="redo_cur"?"重做当前":"重做后续"),sql,res.success);
		_contentStore.fetch();
        $('#myModal').modal('hide');
	});
	
	$(".close-modal").click(function(){
		$('#myModal').modal('hide');
	});
	
	$("#myModal").modal({
		show:true,
		backdrop:false
	});
}

function getRadioValue(name){
	var radios = document.getElementsByName(name);
	var val="";
	$.each(radios,function(index,item){
		if(item.checked){
			val = item.value;
			return;
		}
	});
	return val;
}

//批量重做
function redoProc(type,data){
	var sql="";
	var _dateStr = new Date().format("yyyy-mm-dd hh:mm:ss");
	if(type=="cur"){
		sql="update proc_schedule_log set task_state=0,status_time='" + _dateStr + "',trigger_flag=1,queue_flag=0,return_code=0,exec_time=NULL,end_time=NULL where seqno in ({seqnos})  and ( task_state >=50 or task_state=6 )";
	}else{
		sql="update proc_schedule_log set task_state=0,status_time='" + _dateStr + "',trigger_flag=0,return_code=0,queue_flag=0,exec_time=NULL,end_time=NULL where seqno in ({seqnos}) and ( task_state >=50 or task_state=6 )";
	}
	
	var seqnos="";
	for(var i=0;i<data.length;i++){
		if(data[i].TASK_STATE >=6){
			//运行成功和运行失败方可重做
			seqnos +="'"+ data[i].SEQNO +"',"
		}
	}
	//没有可重做返回 -1
	if(seqnos.length==0){
		return -1;
	}else{
		seqnos = seqnos.substring(0,seqnos.length-1);
		sql = sql.replace('{seqnos}',seqnos);
		var res = ai.executeSQL(sql,false,"METADBS");
		//记录人工操作日志
		taskOpLog(seqnos,"批量重做"+type,sql,res.success);
		return 0;
	}
}

function getValidStore(seqno){
	var store = new AI.JsonStore({
		sql :"select * from proc_schedule_log where seqno='"+seqno+"' and valid_flag=0",
		table:'proc_schedule_log',
		key:"SEQNO",
		dataSource:"METADBS"
	});
	if(store.count>0)return store;
	return null;
}	

//获取当前时间
function getNowTime(){
	var d = new Date();
	var vYear = d.getFullYear();
	var vMon = d.getMonth() + 1;
	var vDay = d.getDate();
	var h = d.getHours();
	var m = d.getMinutes();
	var se = d.getSeconds();
	return vYear +"-"+(vMon<10 ? "0" + vMon : vMon)+"-"+(vDay<10 ? "0"+ vDay : vDay)+" "+(h<10 ? "0"+ h : h)+":"+(m<10 ? "0" + m : m)+":"+(se<10 ? "0" +se : se);
}

function getSeqNo(){
	var now = new Date();
	now = now.format("yyyyMMddhhmmss") +"0"+ now.getMilliseconds();
	return now;
}

//日期格式化 yyyyMMddhhmmss--->yyyy-MM-dd hh:mm
var formatDateArgs=function(dateArgs){
	var tmp = dateArgs.toString().trim();
	tmp =  tmp.replace(/-/g,"");
	tmp =  tmp.replace(":" ,"");
	tmp =  tmp.replace(" " ,"");
	var newStr = "";
	for(var i=0;i<tmp.length;i++){
		 if(i==3){
		 	newStr=newStr+tmp.charAt(i)+"-";
		 }else if(i==5){
		 	newStr=newStr+tmp.charAt(i)+"-";
		 }else if(i==7){
		 	newStr=newStr+tmp.charAt(i)+" ";
		 }else if(i==9){
		 	newStr=newStr+tmp.charAt(i)+":";
		 }else{
		 	newStr=newStr+tmp.charAt(i);
		 }
	}
	var finalChar = newStr.charAt(newStr.length-1);
	if(finalChar==" "||finalChar==":"||finalChar=="-"){
	   newStr=newStr.substring(0,newStr.length-1);
	}
	return newStr;
}

</script>
</head>
<body class="">
	<div id="myModal" class="modal fade"> 
	   <div class="modal-dialog"> 
		   <div class="modal-content" > 
			   <div class="modal-header"> 
				   <button type="button" class="close close-modal" > <span aria-hidden="true">&times;</span><span class="sr-only">Close</span> </button> 
				   <h4 class="modal-title">强制通过原因</h4>
			   </div> 
			   <div class="modal-body" id="upsertForm"></div>
			   <div class="modal-footer">
				   <button id="dialog-cancel" type="button" class="btn btn-default close-modal" >取消</button>
				   <button id="dialog-ok" type="button" class="btn btn-primary">通过</button>
			   </div>
		  </div>
	   </div>
	</div>
	
	<div class="ui-layout-north">
	   <div class="row breadcrumb" id="totalPanel" style="margin:5px 1px 1px 1px;padding:6px 0px;"></div>
	   <div  id="queryPanel"></div>
	</div>
	<div class="ui-layout-west">
		<div id="treeview6" class="test" style="overflow:auto;"></div>
	</div>
	<div class="ui-layout-center">
		<div id="tabpanel1"></div>
	</div>
</body>
</html>
