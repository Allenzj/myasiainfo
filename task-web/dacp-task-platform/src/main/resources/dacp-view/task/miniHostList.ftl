<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>主机列表</title>   
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"  />  
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
    <script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
	<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>
    <script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>
	<script src="${mvcPath}/dacp-lib/jquery-plugins/bootstrap-treeview.min.js"> </script>
	<script src="${mvcPath}/dacp-lib/underscore/underscore-min.js"></script>
    <script src="${mvcPath}/dacp-view/aijs/js/ai.treeview.js"></script>
    
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
var _act= "edit";
var _grid = "";
var _treeSql="SELECT login_type, COUNT(1) AS NUM FROM dp_host_config WHERE 1=1 {condi} GROUP BY login_type";
var _sql="SELECT host_name,hostcnname,login_type,ipaddr,port,chartset,workdir,user_name,password,op_user,op_time,'' OP FROM dp_host_config WHERE 1=1 {condi}";
var tableStore = new AI.JsonStore({
	sql: _sql.replace("{condi}",""),
	pageSize: 15,
	key: "HOST_NAME",//！！！必须大写
	table: "dp_host_config",
	dataSource: "METADBS"
});

//查询条件
var getQueryCondi=function(){
	var topicName = $("#search-text input").val()
	var _condi = "";
	if(topicName) {
		_condi +=" AND  (host_name like '%" + topicName + "%' or hostcnname like '%" + topicName + "%' or ipaddr like '%" + topicName + "%' )";
	};
	return _condi;
};

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
				"type": "text",
				"id":"search-text",
				"fieldLabel":"",
				"placeholder":"主机编号, 主机名, ip地址",
				"style": "min-width:200px;width:180px;margin-left:210px;"
			},
			{
				"type": "text",
				"style": "display: none"
			},
			{
				"id":"search",
				"value":"查询",
				"type":"button",
				"className":"btn btn-sm btn-warning"
			},
			{
				"id":"add",
				"value":"新增",
				"type":"button",
				"className":"btn btn-sm btn-primary"
			},
			{
				"id":"edit",
				"value":"修改",
				"type":"button",
				"className":"btn btn-sm btn-primary"
			},
			{
				"id":"delete",
				"value":"删除",
				"type":"button",
				"className":"btn btn-sm btn-primary"
			}
		],
		'events': {	
			afterRender:function(){
				var _view = this;
				_view.$el.find("#search").empty().append('<button type="button" class="btn btn-sm btn-warning"><span class="glyphicon glyphicon-eye-open"></span>查询</button>');
				_view.$el.find("#add").empty().append('<button id="cre-ojb" type="button" class="btn btn-sm btn-success" style="margin:0px 5px"><span class="fa fa-plus"></span> 新增</button>')
				_view.$el.find("#delete").empty().append('<button id="delete-data" type="button" class="btn btn-sm btn-danger"><span class="fa fa-trash-o"></span> 删除</button>')
			},		
			'click #search':function(){
				switchContent(getQueryCondi());
			},
			'click #add':function(){
				var r = tableStore.getNewRecord();
				tableStore.curRecord = r;
				showDialog("add");
			},
			'click #edit':function(){
				var selected = _grid.getCheckedRows();
				if(selected && selected.length!=1){
					alert('只能选中一行！');
					return false;
				}
				tableStore.curRecord = selected[0];
				showDialog("edit")
			},
			'click #delete':function(){
				var selected = _grid.getCheckedRows();
				if(!selected || selected.length < 1){
					alert('至少选中一项！');
					return false;
				}
				if(confirm("确定要删除选择项吗？")){
					var hosts = "";
					for(var i=0;i< selected.length;i++){
						hosts +="'" + selected[i].data.HOST_NAME + "',";
		   			}
					hosts = hosts.substr(0,hosts.length-1);
					ai.executeSQL("delete from dp_host_config where host_name in (" + hosts + ")",false,"METADBS")	
					ai.executeSQL("delete from dp_host_config where host_name in (" + hosts + ")",false,"METADB")	
					alert("删除成功")
		   			tableStore.select();
		   			buildTreeView(_treeSql.replace("{condi}",""));
				}
			}
		}
	}
});

//配置界面
function showDialog(actType){
	$('#upsertForm').empty();
	$(".modal-title").val("主机信息配置");
	$("#dialog-ok2").hide();
	$("#dialog-ok").show();
	_act = actType;
	var isRead = 'n';
	$("#dialog-ok").show();
	$("#dialog-cancel").html("取消");	
	if(actType == "view"){
		isRead = 'y';
		$("#dialog-ok").hide();
		$("#dialog-cancel").html("关闭");
	}
	var itemscfg =[
		{type:'text',label:'IP地址',notNull:'N',fieldName :'IPADDR',isReadOnly: _act=="add"?'n':'y',width:300},
		{type:'text',label:'端口',notNull:'Y',fieldName :'PORT',isReadOnly: isRead,width:300},
		{type:'text',label:'主机名',notNull:'Y',fieldName :'HOSTCNNAME',isReadOnly: isRead,width:300},
		{type:'radio',label:'登录方式',notNull:'N',fieldName :'LOGIN_TYPE',isReadOnly: isRead,width:300,storesql:'ssh,ssh|telnet,telnet'},
		{type:'text',label:'用户名',notNull:'N',fieldName :'USER_NAME',isReadOnly: _act=="add"?'n':'y',width:300}
    ];
	if(_act == "add"){
		itemscfg.push({type:'password',label:'密码',notNull:'N',fieldName :'PASSWORD',isReadOnly: isRead,width:300});
	}
	var _editPanel = new AI.Form({
		id: 'baseInfoForm',
		store: tableStore,
		containerId: 'upsertForm',
		fieldChange: function(fieldName, newVal){},
		items: itemscfg
	});
	
	
	
	$("#myModal").modal({
		show:true,
		backdrop:false
	});
}

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
				var str =strArray[i];
				var subWhere=str.split(":")[0]+" = '"+str.split(":")[1]+"'";
				if(str.split(":")[1]=='未知') subWhere = str.split(":")[0] +" IS NULL ";
				if(where) where += " AND "+ subWhere
				else where = subWhere;
			}
			where = where.length>0?(" AND "+ where):"";
			tableStore.select(_sql.replace("{condi}", where + getQueryCondi()));
		},
		groupfield:"LOGIN_TYPE",
		sql:sql,
		dataSource:"METADBS",
		subtype:'grouptree',
		renderer: function(val,node){
			var res = '未知';
			val=val||res;
			switch(val.toString().trim().toUpperCase()){
				case 'H':res='时接口';break;
				case 'D':res='日接口';break;
				case 'M':res='月接口';break;
				case 'X':res='实时接口';break;
				default:res=val;break;
			}
			return res;
		}
	});
};

function isExists(hostName){
	var sql ="select 1 from dp_host_config where host_name='"+hostName+"'";
	var store = new AI.JsonStore({
		sql : sql,
		table : 'dp_host_config',
		key : 'host_name',
		dataSource: "METADBS"
	});
	return store.count==1;
}

function changePassword(hostName){
	$("#upsertForm").empty();
	$(".modal-title").val("密码修改");
	$("#dialog-ok").hide();
	$("#dialog-ok2").show();
	var itemscfg =[
		{type:'password',label:'新密码',notNull:'N',fieldName :'NEWPWD', width:300},
		{type:'hidden',label:'主机编号',notNull:'Y',fieldName :'HOST_NAME', width:300}
    ];
	var _editPanel = new AI.Form({
		id: 'baseInfoForm',
		store: tableStore,
		containerId: 'upsertForm',
		fieldChange: function(fieldName, newVal){},
		items: itemscfg
	});	
	
	$("#myModal").modal({
		show:true,
		backdrop:false
	});
}

function encrypt(pwd){
	var encryptPwd = pwd;
	var URL="/"+contextPath+"/crypto/encrypt/des?message="+encodeURIComponent(pwd);
	encryptPwd = ai.remoteData(URL);
	return encryptPwd;
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
	$("#topicName").on("keydown",function(e){
		if(e.keyCode == 13){ 
			document.getElementById("search").click();
		} 
	})
	//表格
	_grid = new AI.Grid({
		store: tableStore,
		containerId: 'tabpanel',
		pageSize: 15,
		nowrap: true,
		rowclick: function(rowdata){
			//curdata= rowdata;
		},
		celldblclick: function(rowdata){
			showDialog('view');
		},
		showcheck: true,
		columns: [
				{header: "主机编号", width:120, dataIndex: 'HOST_NAME', sortable: true},
				{header: "主机名", width:120, dataIndex: 'HOSTCNNAME', sortable: true},
				{header: "IP地址", width: 105, dataIndex: 'IPADDR', sortable: true },
				{header: "端口", width:120, dataIndex: 'PORT', sortable: true},
				{header: "登录方式", width:74, dataIndex: 'LOGIN_TYPE'},
				{header: "用户名", width:74, dataIndex: 'USER_NAME'},
				{header: "操  作", width:74, dataIndex: 'OP',
					render: function(record,value,index){
						var htm="";
						var hostName = record.data.HOST_NAME;
						htm = '<a href="javascript:void(0)" style="color:blue;" onclick="changePassword(\''+hostName+'\')">修改密码</a>';
						return htm;
					}	
				}
		]
	});
	buildTreeView(_treeSql.replace("{condi}",""));
	
	//确定
	$("#dialog-ok").on('click', function(){
		var record = tableStore.curRecord;
		var ipAddr = record.get("IPADDR");
		var loginType = record.get("LOGIN_TYPE");
		var userName = record.get("USER_NAME");
		var pwd = $("#PASSWORD").val();
		var port = $("#PORT").val().trim();
		var cnname = $("#HOSTCNNAME").val().trim();

		if(!ipAddr||ipAddr.trim().length==0){
		    alert("IP地址不能为空！");
		    return false;
		}else{
			if(!/^(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])$/
					.test(ipAddr)){
				alert("无效的ip地址");
				return false;
			}
		}
		
		if(port.length>0){
			if(!/^[0-9]*$/.test(port)){
				alert("无效的端口号");
				return false;
			}
		}
		
		if(!loginType||loginType.trim().length==0){
		    alert("请选择登录类型！");
		    return false;
		}
		if(!userName||userName.trim().length==0){
		    alert("用户名不为空！");
		    return false;
		}
		if(_act=="add" ){
			if(!pwd || pwd.trim().length==0){
			    alert("密码不为空！");
			    return false;
			}else if(pwd.trim().length>32){
				alert("密码不能超过16位");
				return false;
			}
		}
		
		var hostName= userName+'@'+ipAddr;
		if( _act == "add"){
			if(isExists(hostName)){
				alert("已存在该ip下该用户主机信息")
				return false;
			}

			record.set("HOST_NAME",hostName);
			tableStore.add(record);
			pwd = encrypt(pwd);
		}
		
		var opUser=_UserInfo.username;
		var opTime= new Date().format("yyyy-MM-dd hh:mm:ss");
		record.set("PASSWORD",pwd);
		record.set("OP_USER",opUser);
		record.set("OP_TIME",opTime);
		
		var r = tableStore.commit(false);
		var rJson = $.parseJSON(r);
		if(r==true||rJson.success){
			//同步数据到metadb
			var sql="";
			if(_act=="add" ){
				sql="insert into dp_host_config(host_name,hostcnname,login_type,ipaddr,port,user_name,password,op_user,op_time)";
				sql+="values ('"+hostName+"','"+cnname+"','"+loginType+"','"+ipAddr+"','"+port+"','"+userName+"','"+pwd+"','"+opUser+"','"+opTime+"')";
			}else{
				sql="update dp_host_config set hostcnname='"+cnname+"',LOGIN_TYPE='"+loginType+"',port='"+port+"',OP_USER='"+opUser+"',OP_TIME='"+opTime+"' where host_name='"+hostName+"'";	
			}
			ai.executeSQL(sql,false,"METADB");
			alert("更新数据成功！");
		}else{
			alert("出错：" + rJson.msg);
		}
        $('#myModal').modal('hide');
		tableStore.select();
		buildTreeView(_treeSql.replace("{condi}",""));
	});
	
	//确定
	$("#dialog-ok2").on('click', function(){
		var newpwd = $("#NEWPWD").val();
		if(!newpwd||newpwd.length==0){
			alert("请输入新密码");
			return false;
		}else if(newpwd.length>16){
			alert("密码不能超过16位");
			return false;
		}
		
		var hostName = tableStore.curRecord.data.HOST_NAME;
		newpwd = encrypt(newpwd);
		var opUser=_UserInfo.username;
		var opTime= new Date().format("yyyy-MM-dd hh:mm:ss");
		sql="update dp_host_config set password='"+newpwd+"',op_user='"+opUser+"',op_time='"+opTime+"' where host_name='"+hostName+"'";
		ai.executeSQL(sql,false,"METADBS");
		ai.executeSQL(sql,false,"METADB");
		alert("更新成功！");
		$('#myModal').modal('hide');
		tableStore.select();
		buildTreeView(_treeSql.replace("{condi}",""));
	});
	
	//取消
	$(".close-modal").on('click', function(){
       $('#myModal').modal('hide');
	});
});
</script>
</head>
<body>
	<div id="myModal" class="modal fade"> 
	   <div class="modal-dialog"> 
		   <div class="modal-content" > 
			   <div class="modal-header"> 
				   <button type="button" class="close close-modal" > <span aria-hidden="true">&times;</span><span class="sr-only">Close</span> </button> 
				   <h4 class="modal-title">主机信息配置</h4> 
			   </div> 
			   <div class="modal-body" id="upsertForm"></div> 
			   <div class="modal-footer"> 
				   <button id="dialog-cancel" type="button" class="btn btn-default close-modal" >取消</button> 
				   <button id="dialog-ok" type="button" class="btn btn-primary">确定</button> 
				   <button id="dialog-ok2" type="button" class="btn btn-primary">确定</button> 
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