<!DOCTYPE html>
<html>
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
		
	<script src="${mvcPath}/dacp-view/task/analysis.js" type="text/javascript"></script>
	<script src="${mvcPath}/dacp-lib/gojs/go.js" type="text/javascript"></script>
  	<script src="${mvcPath}/dacp-view/task/dataFlow.js"></script>
  	 
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

</style>
<script>
var _CLASS=['btn-default','btn-info','btn-info','btn-primary','btn-warning','btn-success','btn-danger','btn-warning','btn-default','btn-danger','btn-info','btn-warning','btn-danger'];
var _VALUE=['创建成功','排队等待','并发检测成功','发送至agent','正在运行','运行成功','运行失败','暂停任务','重做后续','等待中断','失效','未触发','等待重做'];
var logStore="";
$(function(){
	var _op=paramMap["op"];
	var _seqno=paramMap["seqno"];
	//调度监控必须传递seqno
	if(_seqno){
		var findSql= " select a.seqno,a.xmlid,a.agent_code, b.proc_name,a.run_freq,a.date_args,a.errcode,a.task_state,b.proctype,'PROC' node_type from proc_schedule_log a "
			   + " left join proc b on a.xmlid = b.xmlid "
			   + " where 1=1 and a.seqno='" + _seqno + "'";
		logStore = new AI.JsonStore({
			sql: findSql,
			dataSource:"METADBS"
		});
	
		if(logStore.count > 0){
			data = logStore.root[0];
		}else{
			alert("该日志不存在");
			return;
		}
		
		switch(_op){
			case "li_condi":
				showCondition(_seqno);
				break;
			case "li_log":
				showLog(_seqno);
				break;
			case "li_running_log":
				showRunningLog(_seqno);
				break;
			case "li_use_time":
				showUseTime(_seqno);
				break;
			case "flow":
				showFlow(data);
				break;
			default:
				alert("未知的操作")
				break;
		}
	}else{
		var _xmlid = paramMap["xmlid"];
		var _dataname = paramMap["dataname"];
		
		if(_xmlid && _dataname){
			switch(_op){
			case "li_before":
				showTableBefore(_xmlid,_dataname);
				break;
			case "li_after":
				showTableAfter(_xmlid,_dataname);
				break;
			default:
				alert("未知的操作")
				break;
			}
		}else{
			alert("缺少参数");
		}
	}
	

	$(".op-bt-closeall").click(function(){
		window.close();
	})
});

function refrech(){
	window.location.href = window.location.href;
}

function showTableBefore(xmlid,dataname){
	var title = dataname+"的血缘分析";
	openTableInfo("ana-Before",title,xmlid,false);
}

function showTableAfter(xmlid,dataname){
	var title = dataname+"的影响分析";
	openTableInfo("ana-After",title,xmlid,false);
}

function showFlow(data){
	var title = data.PROC_NAME + " 流程图";
	$("#panel1 #tab_fullname").empty().append(title)
		.append('&nbsp;&nbsp;&nbsp;&nbsp;' 
			+ '<span id="overLoad" class="glyphicon glyphicon-refresh" onclick="refrech()" ></span>'); //标题
	$("#panel1").css("z-index", 10011).slideDown(function() {
	    $("#panel1 #op-panelContent").empty().append(
				'<span style="display: inline-block; vertical-align: top; padding: 5px; width: 100%">'+
					'<div id="myDiagram" style="background-color: Snow; width:100%;height: 600px"></div>'+
				'</span>');
	    loadDataFlow(data);    
	});
	return false;
}

function showCondition(_seqno){
	var _procName = logStore.root[0].PROC_NAME.toUpperCase();
	var errCode = logStore.root[0].ERRCODE?logStore.root[0].ERRCODE.toString():"";
	var status=logStore.root[0].TASK_STATE;
	var errInfo="";
	switch(errCode){
		case "201":
			errInfo="同任务名的相同批次的任务在执行";
			break;
		case "202":
			errInfo="同任务名的程序在执行";
			break;
		case "203":
			errInfo="上一批次任务未执行";
			break;
		case "204":
			errInfo="未知异常";
			break;
		case "301":
			errInfo="agent 挂了";
			break;
		case "302":
			errInfo="agent 满了";
			break;
		case "303":
			errInfo="找不到agent信息";
			break;
		case "304":
			errInfo="未知异常";
			break;
		case "305":
			errInfo="发送失败";
			break;
		case "306":
			errInfo="立即执行";
			break;
		default:
		break;
	}
	$("#panel1 #tab_fullname").empty().append("查看依赖条件"); //标题
	$("#panel1").css("z-index", 10011).slideDown(function() {
    $("#panel1 #op-panelContent").empty();
    $("#panel1 #op-panelContent").append(
    		'<div class="row">'
			+ '<div class="col-sm-12">'
			+ '<section class="panel panel-default">'
			+ '<header class="panel-heading"><b>任务序列：</b>'+_seqno+'&nbsp;&nbsp;&nbsp;&nbsp;<b>程序名：</b>'+_procName+ (errInfo&&(status==2||status==3)?'&nbsp;&nbsp;&nbsp;&nbsp;<b>排队等待原因：</b>'+errInfo:"")
			+ '<span class="pull-right btn btn-danger btn-xs" id="setCondiSuccess">强制执行</span>'
			+ '</header> '
			+ '</section>'
            + '<div class="table-responsive" id="relay_grid" style="width: 100%;overflow: auto;"></div>'
			+ '</div></div>'
	);
	$('#op-panelContent #setCondiSuccess').on('click',function(){
		if(confirm("确定要强制执行")){
			ai.executeSQL("update  proc_schedule_source_log set check_flag=1 where SEQNO='"+_seqno+"'",false,"METADBS");
		}
	});
    var _relayStore = new AI.JsonStore({
		//sql: "SELECT a.SEQNO,a.PROC_NAME,a.SOURCE,c.DATANAME,c.DBNAME,a.SOURCE_TYPE,a.DATA_TIME,a.CHECK_FLAG,CASE WHEN source_type='DATA' THEN c.CYCLETYPE ELSE b.CYCLETYPE END AS CYCLETYPE FROM PROC_SCHEDULE_SOURCE_LOG a LEFT JOIN proc b ON a.proc_name = b.proc_name LEFT JOIN TABLEFILE c ON a.SOURCE = c.XMLID  WHERE SEQNO = '"+_seqno+"' ORDER BY check_flag ",
		sql:"select a.seqno,a.proc_name,a.source,c.dataname,c.dbname,a.source_type,a.data_time,a.check_flag,case when source_type='DATA' then c.dataname  else b.proc_name end as sourcename ,case when source_type='DATA' then c.cycletype else b.cycletype end as cycletype from proc_schedule_source_log a left join proc b on a.source = b.xmlid left join tablefile c on a.source = c.xmlid  where seqno = '"+_seqno+"' order by check_flag ",
		pageSize:20,
		key:"SEQNO",
		table:"PROC_SCHEDULE_SOURCE_LOG",
		dataSource:"METADBS"
	});
	var config={
		id:'relay-grid',
		store:_relayStore,
		pageSize:20,
		containerId:'relay_grid',
		nowrap:true,
		columns:[
			 {"header":"名称","dataIndex":"SOURCENAME","className":"ai-grid-body-td-left"},
			 {"header":"类型","dataIndex":"SOURCE_TYPE","className":"ai-grid-body-td-left",
	  	    	 render:function(record,value){
		  	    		var res="--";
		  	    		switch(value){
			  	    		case "PROC":
								res = "程序";
								break;
							case "DATA":
								res = "表";
								break;
							default:
								break;
		  	    		}
		  	    		return res;
		  	    	 }
			 },
			 {"header":"周期","dataIndex":"CYCLETYPE","className":"ai-grid-body-td-left",
				render:function(record,value){
		    		var res="--";
		    		switch(value){
		  	    		case "year":
							res = "年";
							break;
						case "month":
							res = "月";
							break;
						case "day":
							res = "日";
							break;
						case "hour":
							res = "小时";
							break;
						case "minute":
							res = "分钟";
							break;
						default:
							break;
		    		}
	    			return res;
	    	 	}
			 },
			 {"header":"数据日期","dataIndex":"DATA_TIME","className":"ai-grid-body-td-left",
				 render:function(record,value){
					 var res="--";
					 if(value=="N"){
						 res="无";
					 }else{
						var argsType = record.data.CYCLETYPE;
						switch(argsType){
							case "month":
								res = value.indexOf('-')>0?value.substr(0,7):value.substr(0,6);
								break;
							case "year":
								res = value.substr(0,4);
								break;
							default:
								res = value
								break;
						}
					 }
					 return res;
				 }
			 },
			 {"header":"检测通过","dataIndex":"CHECK_FLAG",render:function(value){ return _.template('<span class="glyphicon glyphicon-<%=CHECK_FLAG==0?"remove":"ok"%>"></span>',{'CHECK_FLAG':value.get("CHECK_FLAG")});}}
		]
    };
    var grid =new AI.Grid(config);
	});
}

function showLog(seqno){
	var _title = logStore.root[0].PROC_NAME.toUpperCase();
	var _taskState = logStore.root[0].TASK_STATE;
	_taskState = _taskState>=50?7:_taskState;
	_taskState = _taskState<0&&_taskState>=-3?8:_taskState;
	_taskState = _taskState==0?9:_taskState;
	_taskState = _taskState==-5?10:_taskState;
	_taskState = _taskState==-6?11:_taskState;

	var tmpl = '';
	var _store = new AI.JsonStore({
		sql:"select a.seqno,a.proc_name,a.app_log,b.start_time,b.task_state,b.retrynum,b.status_time from proc_schedule_script_log a,proc_schedule_log b  where a.seqno=b.seqno and a.seqno='"+seqno+"'",
		dataSource:"METADBS"
	});

	if(_store.root.length==1){
		var log = _store.root[0].APP_LOG.replaceAll('<','&lt;');
		var cla = _CLASS[_taskState-1];
		var name = _VALUE[_taskState-1];
		var time = _store.root[0].UPDATE_TIME;
		var retryNum = _store.root[0].RETRYNUM?0:_store.root[0].RETRYNUM;

		var tmpl = _.template(
			'<section class="panel panel-default">'
			+ '<header class="panel-heading"> 脚本运行日志</header> '
			+ '<article class="media" style="overflow:auto">'
			+ '<div class="media-body" style="margin:0px 40px 40px 40px;">'
			+ '<div class="pull-right media-xs text-center text-muted"> '
			+ '<strong class="h4"><%=retry%></strong> 次<br> <small class="label bg-gray text-xs">失败重做</small>'
			+ '</div>'
			+ '<h4><%=time%> <span class="label <%=cla%>"><%=name%></span> </h4>'
			+ '<small class="block"><span>日志内容：</span></small>'
			+ '<small class="block" ><pre style="white-space: pre-wrap;"><%=log%></pre></small>'
			+ '</div>'
			+ '</article>'
			+'</section>',
			{"cla":cla,"name":name,"time":time,"log":log,"retry":retryNum });
	}else{
		tmpl = "找不到日志信息！";
	}
	openTableInfo("log",_title,tmpl,true);
}

function showRunningLog(seqno){
	var agentCode = logStore.root[0].AGENT_CODE;
	var _title = logStore.root[0].PROC_NAME.toUpperCase();
	var _taskState = logStore.root[0].TASK_STATE;
	_taskState = _taskState>=50?7:_taskState;
	_taskState = _taskState<0&&_taskState>=-3?8:_taskState;
	_taskState = _taskState==0?9:_taskState;
	_taskState = _taskState==-5?10:_taskState;
	_taskState = _taskState==-6?11:_taskState;
	
	
	var log = '';
	$.ajax({
		url:'/'+contextPath+'/syn/getLog?SEQNO='+seqno+'&AGENT_CODE='+agentCode+'&CMD=tail -n100 ',
		async:false,
		error:function(){     
		       alert('网络错误！');
		       return;
		    },
		success:function(msg){
			var msg = $.parseJSON(msg);
			if(msg.flag==true||msg.flag=="true"){
			     log = msg.response;
			}else{
				alert('获取运行日志失败');
				return false;
			}
		}
	});
	
	var tmpl = '';
	var _store = new AI.JsonStore({
		sql:"select seqno,proc_name,start_time,task_state,retrynum,status_time from proc_schedule_log   where  seqno='"+seqno+"'",
		dataSource:"METADBS"
	});

	if(_store.root.length==1){
		var log = log.replaceAll('<','&lt;');
		var cla = _CLASS[_taskState-1];
		var name = _VALUE[_taskState-1];
		var time = _store.root[0].UPDATE_TIME;
		var retryNum = _store.root[0].RETRYNUM?0:_store.root[0].RETRYNUM;

		var tmpl = _.template(
			'<section class="panel panel-default">'
			+ '<header class="panel-heading"> 脚本运行日志</header> '
			+ '<article class="media" style="overflow:auto">'
			+ '<div class="media-body" style="margin:0px 40px 40px 40px;">'
			+ '<div class="pull-right media-xs text-center text-muted"> '
			+ '<strong class="h4"><%=retry%></strong> 次<br> <small class="label bg-gray text-xs">失败重做</small>'
			+ '</div>'
			+ '<h4><%=time%> <span class="label <%=cla%>"><%=name%></span> </h4>'
			+ '<small class="block"><span>日志内容：</span></small>'
			+ '<small class="block" ><pre style="white-space: pre-wrap;"><%=log%></pre></small>'
			+ '</div>'
			+ '</article>'
			+'</section>',
			{"cla":cla,"name":name,"time":time,"log":log,"retry":retryNum });
	}else{
		tmpl = "找不到运行日志信息！";
	}
	openTableInfo("log",_title,tmpl,true);
}

function showUseTime(_seqno){
	var _title= logStore.root[0].PROC_NAME.toUpperCase();
	var _xmlid = logStore.root[0].XMLID;
	var tmpl = '';
	var $el = $('#panel1');
	var _store = new AI.JsonStore({
		sql:"select a.proc_name,b.proccnname,b.state from proc_schedule_log a,proc b where a.xmlid = b.xmlid and a.seqno='"+_seqno+"'",
		dataSource:"METADBS"
	});
	
	if(_store.root.length>=1){
		var proccnname = _store.root[0].PROCCNNAME;
		var state=_store.root[0].STATE;
		var tmpl = _.template(
			'<div class="row">'
			+ '<div class="col-md-6">'
			+ '<section class="panel panel-default">'
			+ '<header class="panel-heading font-bold">详细信息</header>'
			+ '<ul class="list-group no-radius">'
			+ '<li class="list-group-item"> <span class="pull-right"><%=proc_name%></span> 程序代码 </li>'
			+ '<li class="list-group-item"> <span class="pull-right"><%=proccnname%></span> 程序名称 </li>'
			+ '<li class="list-group-item"> <span class="pull-right"><%=state%></span> 状态 </li>'
			+ '</ul>'
			+ '<div class="line pull-in"></div>'
			+ '</div><div class="col-md-6">'
			+ '<section class="panel panel-default">'
			+ '<header class="panel-heading font-bold">运行时长分析</header>'
			+ '<section class="media-body"> '
			+ '<div id="flot-bar-h" style="height: 240px"></div>'
			+ '</div>'
			+ '</section>'
			+ '</div></div>'
			+ '<div class="row">'
			+ '<div class="col-md-12">'
			+ '<section class="panel panel-default">'
			+ '<header class="panel-heading font-font">运行时长分析趋势图</header>'
			+ '<section class="media-body">'
			+ '</section>'
			+ '<div class="panel-body">'
			+ '<div id="flot-line-h" style="height:240px"></div>'
			+ '</div>'
			+ '</section>'
			+ '</div>'	
			+ '</div>'
			,{"proc_name":_title,"proccnname":proccnname,"state":state});
	}else{
		tmpl =  "暂无数据！";
	}
	$el.on("finishRender",function(){					
			//获取数据
			if($el.find('#flot-bar-h').length==1){
				var _proc_name = _title;
				var _procTimerStore = new AI.JsonStore({
					sql: "select * from"
						+ " (select * from"
						+ " (select distinct status_time,TIMESTAMPDIFF(MINUTE,EXEC_TIME,END_TIME) as DURATION from"
						+ " proc_schedule_log where xmlid='"+_xmlid+"') T"
						+ " where T.DURATION IS NOT NULL order by T.status_time DESC LIMIT 30) T1 ORDER BY T1.status_time",
					initUrl: '/' + contextPath + '/newrecordService',
					url: '/' + contextPath + '/newrecordService',
					root: 'root',
					pageSize: -1,
					loadDataWhenInit: true,
					table: "proc",
					key: "PROC_NAME",
					dataSource:"METADBS"
				});
				var _categories=[];
				var _series=[];
				for(i=0;i<_procTimerStore.getCount();i++){
					_categories.push(_procTimerStore.root[i].STATUS_TIME);
					_series.push(_procTimerStore.root[i].DURATION);
				}
				/*
				_procTimerStore.root.each(function(dt){
					_categories.push(dt.get("STATUS_TIME"));
					_series.push(dt.get("DURATION"));
				});
                 */
			}
			
			//bar图：
			$el.find('#flot-bar-h').empty().highcharts({
		        chart: {type: 'bar'
		        	}, 
		        title: {text: null},
		        xAxis: {
		        	categories: _categories,
		            title: {text: null}
		        },
		        yAxis: {
		        	min: 0,
		            title: {
		                text: '运行时长 (分)',
		                align: 'high'                  
		            },
		            labels: {overflow: 'justify'}
		        },
		        tooltip: {valueSuffix: ' 分钟'},
		        plotOptions: {bar: {dataLabels: {enabled: true}}},   
		        legend: {
		            layout: 'vertical',
		            align: 'right',
		            verticalAlign: 'top',
		            x: -40,
		            y: 100,
		            floating: true,
		            borderWidth: 0,
		            backgroundColor: '#FFFFFF',
		            shadow: true
		        },                                                  
		        series: [{
		        	name: _proc_name,
		            data: _series                                 
		        }]
		    });
			
			//line图：
			$el.find('#flot-line-h').empty().highcharts({
				chart:{
					type: 'line',
					width: 1200
				},
		        title: {text: ''},
		        xAxis: {
		        	title: {text: '时间'},
		        	categories: _categories								            
		        },
		        yAxis: {
		        	min: 0,
		            title: {
		                text: '运行时长 (分)', 
		                align: 'high'           
		            }
		        },
		        tooltip: {valueSuffix: '分钟'},
		        series: [{
		        	name: _proc_name,
		            data: _series                                 
		        }]
		    });					
				
		});
	openTableInfo("dura",_title,tmpl,true);
}
function openTableInfo(tabname, title, template, flag) {
	$("#panel1 #tab_fullname").empty().append(title); //标题

	$("#panel1 #op-panelContent").empty().append(template);//内容
	$("#panel1").triggerHandler("finishRender");//注册后续触发时间

	$("#panel1").css("z-index", 10011).slideDown(function() {

	if (tabname.indexOf("ana") != -1) {
		var _type = tabname.split("-")[1];
		$("#panel1 #op-panelContent")
		.empty()
		.append('<span style="display: inline-block; vertical-align: top; padding: 5px; width: 100%"><div id="myDiagram" style="background-color: Snow;"></div></span>');
		init(_type.toLowerCase(), template);
	} else if (tabname === 'focusMonitor') {
	}
	});
	return false;
};
</script>
</head>
<body>
	<div id="panel1" class="op-panel" data-open="0" style="z-index: 10001; top: 0px; left: 0px; ">
	<div class="op-panelctrl solid-black">
		<div class="op-panelbt op-tab op-bt-nav">
			<h2 class="title" id="tab_fullname"></h2>
		</div>
		<div class="op-panelbt op-bt-closeall pull-right">
			<img src="${mvcPath}/dacp-res/task/images/close-white-48a.png" alt="close all">
		</div>
		<div class="clearspace"></div>
	</div>
	<div class="op-panelform" id="op-panelContent" style="padding: 15px 40px 100px"></div>
</div>
</body>
</html>