<!DOCTYPE html>
<html lang="en" class="app">
<head>
<meta charset="UTF-8">
<title>Agent监控监控列表</title>   
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"  />
	<link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-lib/datepicker/datepicker.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-lib/datepicker/jquery.simpledate.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-lib/datepicker/jquery.pst-area-control.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-view/ve/css/dacp-ve-js-1.0.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="/dacp/dacp-res/task/css/implWidgets.css" type="text/css" rel="stylesheet"  />
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

<style>
body {     
	margin: 0;
	font-family: Roboto, arial, sans-serif;
	font-size: 13px;
	line-height: 20px;
	color: #444444;
	background-color: #f1f1f1;
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

#myModal {
	z-index: 999999;	
}

#queryPanel{
margin-top:10px;
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

.glyphicon{
	position: relative;
  top: 1px;
  display: inline-block;
  font-family: 'Glyphicons Halflings';
  font-style: normal;
  font-weight: normal;
  line-height: 1;
  -webkit-font-smoothing: antialiased;
}
</style>

<script>
var _grid = "";
var tableStore = "";
var _sql="select a.platform,c.platform_cnname,a.agent_name,SUM(CASE WHEN task_state in(4,5) THEN 1 ELSE 0 END) curips,a.ips,a.host_name,a.node_status,a.script_path,d.ipaddr,d.port,d.user_name " +
		 " from aietl_agentnode a " +
		 " left join proc_schedule_log b on a.agent_name = b.agent_code " +
		 " left join proc_schedule_platform c on a.platform=c.platform " +
		 " left join dp_host_config d on d.host_name=a.host_name " +
 		 " where 1=1 and a.task_type='TASK' {condi} " +
		 " group by a.platform,c.platform_cnname,a.agent_name order by platform ";
var _treeSql="select platform,platform_cnname,cast(node_status as char) node_status,(case when node_status=1 then '正常' else '异常' end) status,count(1) num from (" + _sql + ") agentList group by platform,node_status";

//查询条件
var getQueryCondi=function(){
	var agentName = $("#agentName-text input").val().trim();
	var ipAddr = $("#ipaddr-text input").val().trim();
	var platform = $("#platform_select select").val();
	var _condi = "";
	if(agentName.length>0) {
		_condi +=" AND a.agent_name like '%" + agentName + "%' ";
	};
	
	if(ipAddr.length>0) {
		_condi +=" AND d.ipaddr like '%" + ipAddr + "%' ";
	};
	
	if(platform.length>0) {
		_condi +=" AND c.platform = '" + platform + "' ";
	};

	_condi += getTeamCondi();
	return _condi;
};

function getTeamCondi(){
	var team_codes="";
	/*
	for(var i=0;i<_UserInfo.userGroups.length;i++){
		team_codes += "'"+_UserInfo.userGroups[i].groupCode+"',"
	}
	if(team_codes.length>0){
		team_codes = team_codes.substring(0,team_codes.length-1);
		curTeamCodeCondi ="  and c.team_code in (" + team_codes + ")";
	}else{
		curTeamCodeCondi = " and 1=2";
	}*/
	team_codes = paramMap["team_code"]||"";//_UserInfo.teamCode;
	curTeamCodeCondi = "  and (c.team_code = '" + team_codes + "' or c.team_code like '%," + team_codes + "' or c.team_code like '" + team_codes + ",%' or c.team_code like '%," + team_codes + ",%')";
	return curTeamCodeCondi;
}

//刷新版面
var switchContent = function(condi){
	if(!condi||typeof(condi)=="undefined"){
		condi="";
	}
	buildTreeView(_treeSql.replace("{condi}",condi));
	tableStore.select(_sql.replace("{condi}",condi))
	if(tableStore.count == 0) {
		$("#undefined_page").html('<li><a class=" pull-center">记录总数:0</a></li>');
	}
};

//查询面板
var _queryPanel = new ve.FormWidget({
	config:{
		"class":"form",
		"formClass":"form-inline",
		"id": "_query",
		"noJustfiyFilter":"on",
		"items": [
		    {
		    	"id":"tab-list",
				"value":"",
				"type":"button",
				"className":"search_btn btn-sm btn-primary",
		    },
		    {
				"type":"combox",
				"fieldLabel":"所属组",
				"id":"platform_select",
				"select":${platformList!"[]"},
				"style": "min-width:80px;width:100px;"
			},
			{
				"type": "text",
				"id":"agentName-text",
				"fieldLabel":"Agent名称",
				"placeholder":"",
				"style": "min-width:200px;width:180px;"
			},
			{
				"type": "text",
				"id":"ipaddr-text",
				"fieldLabel":"部署主机ip",
				"placeholder":"",
				"style": "min-width:200px;width:180px;"
			},
			{
				"id":"search",
				"value":"查询",
				"type":"button",
				"className":"btn btn-sm btn-warning"
			}/*,
			{
				"id":"refresh-btn",
				"value":"",
				"type":"button",
				"className":"btn btn-sm btn-success",
			}*/
		],
		'events': {	
			afterRender:function(){
				var _view = this;
				_view.$el.find("#platform_select").attr("style","margin-left:90px;");
				_view.$el.find("#search").empty().append('<button type="button" class="btn btn-sm btn-warning"><span class="glyphicon glyphicon-eye-open"></span>查询</button>');
				//_view.$el.find("#refresh-btn button").append('<span class="glyphicon glyphicon-refresh"></span>').attr("style","margin-left:10px");
				_view.$el.find("#tab-list").empty().append(
						'<div class="btn-group" data-toggle="buttons" style="margin-right: 2px;">'+
						'<label id="agentList" class="btn btn-sm btn-info active">'+
						'<input type="radio" name="options">'+
						'<i class="fa fa-check text-active" ></i>Agent</label>'+
						'<label id="serverList" class="btn btn-sm btn-success">'+
						'<input type="radio" name="options">'+
						'<i class="fa fa-check text-active"></i>Server</label>'+
						'</div>'
				);
			},		
			'click #search':function(){
				switchContent(getQueryCondi());
			},		
			'click #refresh-btn':function(){
				switchContent(getQueryCondi());
			}
		}
	}
});

//左边树   
var buildTreeView = function(sql){
	$('#treeview6').empty().treeview({
		color: "#428bca",
		expandIcon: "glyphicon glyphicon-chevron-right",
		collapseIcon: "glyphicon glyphicon-chevron-down",
		nodeIcon: "glyphicon glyphicon-tasks",
		showTags: true,
		onNodeSelected:function(event,node){
			var strArray = node.id.split(">");
			var where = "";
			for(var i=0;i<strArray.length;i++){
				var str = strArray[i];
				var subWhere = "a."+ str.split(":")[0]+" = '"+str.split(":")[1]+"'";
				if(str.split(":")[1]=='未知') subWhere = "a."+str.split(":")[0] +" IS NULL ";
				if(where) where += " AND "+ subWhere
				else where = subWhere;
			}
			where = where.length>0?(" AND "+ where):"";
			tableStore.select(_sql.replace("{condi}", where + getQueryCondi()));
		},
		groupfield:"PLATFORM,NODE_STATUS",
		titlefield:"PLATFORM_CNNAME,STATUS",
		sql:sql,
		dataSource:"METADBS",
		subtype:'grouptree',
		renderer: function(val,node){
			var res = '未知';
			res = val||res;
			return res;
		}
	});
};

function StartAndStop(agentCode,status){
	var type= status=="0"?"启动":"停止";
	var str="确定要" + type + agentCode+"吗？";
	
	var url = '/' + contextPath + '/syn/controllAgent?AGENT_CODE=' + agentCode;
	if(confirm(str)){
		$.ajax({
			url:url,
			beforeSend:function(){
				$("#loadingBackDrop",window.parent.document).show();
			},
			complete:function(){
				$("#loadingBackDrop",window.parent.document).hide();
			},
			error:function(){     
			       alert('未能调用启停服务！！');
			    },
			success:function(msg){
				var message = $.parseJSON(msg);
				$("#search").click();
				alert(message.response);
			}
		});
	}
}

$(document).ready(function(){
	 $('body').layout({
	    	sizable:						false
		,	animatePaneSizing:				true
		,	fxSpeed:						'slow'
		,	spacing_open:					0
		,	spacing_closed:					0
		,	west__spacing_closed:			8
		,	west__spacing_open:				8
		,	west__togglerLength_closed:		105
		,	west__togglerLength_open:		105
		,	west__size:						205
		,	north__size: 					50
	});
	//_totalPanel.$el=$("#totalPanel");
	_queryPanel.$el=$("#queryPanel");
	_queryPanel.render();
	
	tableStore = new AI.JsonStore({
		sql: _sql.replace("{condi}",getQueryCondi()),
		pageSize: 15,
		key: "XMLID",
		table: "tablefile",
		dataSource: "METADBS"
	});
	//表格
	_grid = new AI.Grid({
		store: tableStore,
		containerId: 'tabpanel',
		pageSize: 15,
		nowrap: true,
		rowclick: function(rowdata){
			curdata= rowdata;
		},
		celldblclick: function(rowdata){
			//showDialog('view');
		},
		showcheck: false,
		columns: [
			{header: "Agent名称", dataIndex: 'AGENT_NAME', className: "ai-grid-body-td-center"},
			{header: "所属组", dataIndex: 'PLATFORM_CNNAME', className: "ai-grid-body-td-center"},
			{header: "部署主机IP", dataIndex: 'IPADDR', className: "ai-grid-body-td-center"},
			{header: "部署路径", dataIndex: 'SCRIPT_PATH', className: "ai-grid-body-td-center"},
			{header: "状态", dataIndex: 'NODE_STATUS', className: "ai-grid-body-td-center",
				render:function(row,val){
					var normal = '<button type="button" class="btn btn-xs btn-success">正常</button>';
					var abnormal = '<button type="button" class="btn btn-xs btn-danger">异常</button>';
					return val==1?normal:abnormal;
				}
			},
			{header: "当前并发数", dataIndex: 'CURIPS', className: "ai-grid-body-td-center",render:function(row,val){return row.data.CURIPS;}},
			{header: "最大并发数", dataIndex: 'IPS', className: "ai-grid-body-td-center",render:function(row,val){return row.data.IPS;}},
			{header: "操作", dataIndex: 'OP', className: "ai-grid-body-td-center",
				render:function(row,val){
					var start='<span onclick="StartAndStop(\''+row.data.AGENT_NAME+'\',0)" style="color:blue;text-decoration:underline;">启动</span>';
					var stop ='<span onclick="StartAndStop(\''+row.data.AGENT_NAME+'\',1)" style="color:blue;text-decoration:underline;">停止</span>';
					return row.data.NODE_STATUS==1?stop:start;
				}
			}
		]
	});
	
	buildTreeView(_treeSql.replace("{condi}",getQueryCondi()));
	
	
	$('#tab-list .btn').on("click",function(){
		var type = $(this).attr("id");
		if(type=="serverList"){
			window.location.href = "/"+contextPath+"/task/miniServerMonitorList";
		}else{
			window.location.href = "/"+contextPath+"/task/miniAgentMonitorList";
		}
	});
});
</script>
</head>
<body>
	<div class="ui-layout-north">
		<div  id="queryPanel"></div>
	</div>
	<div class="ui-layout-west" >
		<div id="treeview6" class="test"></div>
	</div>
	<div class="ui-layout-center">
		<div id="tabpanel" style="margin-bottom: 120px;"></div>
	</div>
</body>
</html>