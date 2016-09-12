<!DOCTYPE html>
<html lang="en" class="app">
<head>
<meta charset="UTF-8">
<title>Server管理</title>   
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
var isAdd = true;
var _sql= "select a.server_id,a.host_name,a.deploy_path,a.server_status,a.status_time,b.ipaddr,b.port,b.user_name from aietl_servernode a "+
		  " left join dp_host_config b on a.host_name=b.host_name " +
		  " where 1=1 {condi}";
var _treeSql=" select  cast(server_status as char) node_status, (case when server_status=1 then '正常' when server_status =0 then '待运行' else '异常' end) status,count(1) num from (" + _sql + ") agentList group by server_status ";

//查询条件
var getQueryCondi=function(){
	var serverName = $("#serverName-text input").val().trim();
	var ipAddr = $("#ipaddr-text input").val().trim();
	var _condi = "";
	if(serverName.length>0) {
		_condi +=" AND a.server_id like '%" + serverName + "%' ";
	};

	if(ipAddr.length>0) {
		_condi +=" AND b.ipaddr like '%" + ipAddr + "%' ";
	};
	
	return _condi;
};

//检测server是否已经存在
function isExists(serverId){
	var sql ="select 1 from aietl_servernode where server_id='"+serverId+"'";
	var store = new AI.JsonStore({
		sql : sql,
		table : 'aietl_servernode',
		key : 'SERVER_ID',
		dataSource: "METADBS"
	});
	return store.count==1;
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
				"type": "text",
				"id":"serverName-text",
				"fieldLabel":"Server名称",
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
				"className":"btn btn-default"
			},
			{
				"id":"add",
				"value":"新增",
				"type":"button",
				"className":"btn btn-sm btn-default"
			},
			{
				"id":"edit",
				"value":"修改",
				"type":"button",
				"className":"btn btn-sm btn-default"
			},
			{
				"id":"delete",
				"value":"删除",
				"type":"button",
				"className":"btn btn-sm btn-default"
			}
		],
		'events': {	
			afterRender:function(){
				var _view = this;
				_view.$el.find("#serverName-text").attr("style","margin-left:90px;");
				_view.$el.find("#search").empty().append('<button type="button" class="btn btn-sm btn-default" style="margin-right:10px;"><span class="glyphicon glyphicon-eye-open"></span>查询</button>');
				//_view.$el.find("#refresh-btn button").append('<span class="glyphicon glyphicon-refresh"></span>').attr("style","margin-left:10px");
				_view.$el.find("#tab-list").empty().append(
						'<div class="btn-group" data-toggle="buttons" style="margin-right: 2px;">'+
						'<label id="agentList" class="btn btn-sm btn-info">'+
						'<input type="radio" name="options">'+
						'<i class="fa fa-check text-active" ></i>Agent</label>'+
						'<label id="serverList" class="btn btn-sm btn-success active">'+
						'<input type="radio" name="options">'+
						'<i class="fa fa-check text-active"></i>Server</label>'+
						'</div>'
				);
			},		
			'click #search':function(){
				switchContent(getQueryCondi());
			},		
			'click #add':function(){
			    isAdd = true;
		        var r = tableStore.getNewRecord();
			    r.set("SERVER_STATUS",0);
			    r.set("OP_USER",_UserInfo.username);
			    r.set("OP_TIME",new Date().format("yyyy-MM-dd hh:mm:ss"));
			    tableStore.curRecord = r;
				showServerInfoDialog("add");
			},		
			'click #edit':function(){
				var curServer = _grid.getCheckedRows();
		   		if(!curServer || curServer.length!=1){
		   			alert("只能选中一项！")
		   			return false;
		   		}
				isAdd = false;
				 tableStore.curRecord = _grid.getCheckedRows()[0];
				showServerInfoDialog("edit");
			},		
			'click #delete':function(){
				var curServer = _grid.getCheckedRows();
		   		if(!curServer || curServer.length==0){
		   			alert("至少选中一项！")
		   			return false;
		   		}
		   		if(confirm("确定删除所有选中项吗?")){
		   			var servers = "";
		   			for(var i =0;i<curServer.length;i++){
		   				servers +="'"+ curServer[i].get("SERVER_ID")+"',";
		   			}
		   			servers = servers.substr(0,servers.length-1);
		   			ai.executeSQL("delete from aietl_servernode where server_id in (" + servers + ")",false,"METADBS");
		   			
		   			switchContent(getQueryCondi());
		   		}
			}
		}
	}
});

//server配置信息窗口
var showServerInfoDialog=function(acttype){
		$("#server-upsertForm").empty();
		var isRead='y';
		var isSelect = 'n';
		if(acttype=='add'){
		   isRead = 'n';
		   isSelect = 'y';
		}
		var formcfg = ({
			id : 'form',
			store : tableStore,
			containerId : 'server-upsertForm',
			items : [ 
				{type:'text',label:'Server编号',notNull:'N',fieldName:'SERVER_ID',isReadOnly:isRead,width:300}, 
				{type:'combox',label:'所在主机',notNull:'N',fieldName :'HOST_NAME',storesql:'SELECT HOST_NAME AS K ,HOSTCNNAME AS V FROM dp_host_config',width:300},
				{type:'text',label:'部署路径',notNull:'N',fieldName:'DEPLOY_PATH',width:300}
			]
		});
		var from = new AI.Form(formcfg);
		$('#serverInfo').modal({
			show : true,
			backdrop:false
		});
	}; 

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
		groupfield:"NODE_STATUS",
		titlefield:"STATUS",
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

function StartAndStop(serverId,status){
	var type= status=="0"?"启动":"停止";
	var str="确定要" + type + serverId+"吗？";
	
	var url = '/' + contextPath + '/syn/controllServer?serverId=' + serverId;
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
			       alert('未能调用启停服务！');
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
		key: "SERVER_ID",
		table: "aietl_servernode",
		dataSource: "METADBS"
	});
	//表格
	_grid = new AI.Grid({
		store: tableStore,
		containerId: 'tabpanel',
		pageSize: 15,
		nowrap: true,
		rowclick: function(index,data){
			curdata= index;
		},
		celldblclick: function(rowdata){
			//showDialog('view');
		},
		showcheck: true,
		columns: [
			{header: "Server名称", dataIndex: 'SERVER_ID', className: "ai-grid-body-td-center"},
			{header: "部署主机IP", dataIndex: 'IPADDR', className: "ai-grid-body-td-center"},
			{header: "部署路径", dataIndex: 'DEPLOY_PATH', className: "ai-grid-body-td-center"},
			{header: "状态", dataIndex: 'SERVER_STATUS', className: "ai-grid-body-td-center",
				render: function(row,val){
					var res="--";
					switch(row.data.SERVER_STATUS){
						case 1:
							res = '<button type="button" class="btn btn-xs btn-success">正常</button>';
							break;
						case 0:
							res = '<button type="button" class="btn btn-xs btn-warning">待运行</button>';
							break;
						case -1:
							res = '<button type="button" class="btn btn-xs btn-danger">异常</button>';
							break;
						default:
							break;
					}
					return res;
				}
			},
			{header: "状态变更时间", dataIndex: 'STATUS_TIME', className: "ai-grid-body-td-center"},
			{header: "操作", dataIndex: 'OP', className: "ai-grid-body-td-center",
				render:function(row,val){
					var start='<span onclick="StartAndStop(\''+row.data.SERVER_ID+'\',0)" style="color:blue;text-decoration:underline;">启动</span>';
					var stop ='<span onclick="StartAndStop(\''+row.data.SERVER_ID+'\',1)" style="color:blue;text-decoration:underline;">停止</span>';
					
					var res="";
					switch(row.data.SERVER_STATUS){
					case 1:
						res = stop;
						break;
					case 0:
						res = stop;
						break;
					case -1:
						res = start;
						break;
					}
					return res;
				}
			}
		]
	});
	
	buildTreeView(_treeSql.replace("{condi}",getQueryCondi()));
	
	
	$("#search-text").on("keydown",function(e){
		if(e.keyCode == 13){ 
			document.getElementById("search").click();
		} 
	});
	
	$('#tab-list .btn').on("click",function(){
		var type = $(this).attr("id");
		if(type=="serverList"){
			window.location.href = "/"+contextPath+"/task/miniServerMonitorList";
		}else{
			window.location.href = "/"+contextPath+"/task/miniAgentMonitorList";
		}
	});
	
	
	//确定
	$("#serverInfo #dialog-ok").click(function() {
		var record = tableStore.curRecord;
		var serverId = record.get("SERVER_ID");
		var hostname = record.get("HOST_NAME");
		var deployPath = record.get("DEPLOY_PATH");
		
		if(!serverId||serverId.trim().length<1){
		    alert("server编号不为空！");
		    return false;
		}
		
		if(!hostname || hostname.toString().trim().length<1){
		    alert("请选择所属主机！");
		    return false;
		}
		
		if(!deployPath || deployPath.toString().trim().length<1){
		    alert("部署路径不能为空！");
		    return false;
		}
		//同步到metadb
		if(isAdd){	
			if(isExists(serverId)){
				alert("server编号已存在");
				return false;
			}else{
				tableStore.add(record);
			}
		}
		
		tableStore.commit(false);
		$('#serverInfo').modal("hide");
		switchContent(getQueryCondi());
	});
	
	//取消
	$("#serverInfo .close-modal").on('click', function(){
		$('#serverInfo').modal("hide");
	});
});
</script>
</head>
<body>
	<div id="serverInfo" class="modal fade" style = "z-index:99999">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button id="dialog-cancel" type="button" class="close close-modal">
						<span aria-hidden="true">&times;</span><span class="sr-only">Close</span>
					</button>
					<h4 class="modal-title">server配置信息</h4>
				</div>
				<div class="modal-body" id="server-upsertForm"></div>
				<div class="modal-footer">
					<button id="dialog-cancel" type="button" class="btn btn-default close-modal">取消</button>
					<button id="dialog-ok" type="button" class="btn btn-primary">确认</button>
				</div>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	</div>
	<!-- /.modal -->
	
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