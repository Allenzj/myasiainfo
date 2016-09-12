<!DOCTYPE html>
<html lang="en" class="app">
<head>
<meta charset="UTF-8">
<title>表模型列表</title>   
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
var _act= "edit";
var _grid = "";
var _editPanel="";
var tableStore = "";
var _sql="SELECT a.xmlid,dataname,datacnname,a.dbname,level_val,topicname,cycletype,a.remark,b.dim_value topic_value,c.dim_value level_value,d.cnname dbcnname FROM tablefile a " +
	 	 " LEFT JOIN proc_schedule_dim b ON a.topicname = b.dim_code " +
	  	 " LEFT JOIN proc_schedule_dim c ON a.level_val = c.dim_code " + 
	  	 " LEFT JOIN metadbcfg d ON a.dbname = d.dbname " + 
 		 " WHERE 1=1 {condi} ";
var _treeSql="select topicname,level_val,cycletype,count(1) num from (" + _sql + ") tablefile group by topicname,level_val,cycletype";

//查询条件
var getQueryCondi=function(){
	var searchText = $("#search-text input").val().trim();
	var dbname = $("#db_select select").val()
	var _condi = "";
	if(searchText.length>0) {
		_condi +=" AND  (dataname like '%" + searchText + "%' or datacnname like '%" + searchText + "%' )";
	};
	
	if(dbname.length>0) {
		_condi +=" AND  a.dbname = '" + dbname + "' ";
	};
	_condi += getTeamCondi();
	return _condi;
};

function getTeamCondi(){
	var team_codes="";
	for(var i=0;i<_UserInfo.userGroups.length;i++){
		team_codes += "'"+_UserInfo.userGroups[i].groupCode+"',"
	}
	if(team_codes.length>0){
		team_codes = team_codes.substring(0,team_codes.length-1);
		curTeamCodeCondi ="  and a.team_code in (" + team_codes + ")";
	}else{
		curTeamCodeCondi = " and 1=2";
	}
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
				"type":"combox",
				"fieldLabel":"数据库",
				"id":"db_select",
				"select":${dbList},
				"style": "min-width:60px;"
			},
			{
				"type": "text",
				"id":"search-text",
				"fieldLabel":"",
				"placeholder":"名称, 中文名",
				"style": "min-width:200px;width:180px;"
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
			'cahnge #db_select':function(){
				switchContent(getQueryCondi());
			},
			'click #add':function(){
				var r = tableStore.getNewRecord();
				tableStore.curRecord = r;
				showDialog("add");
				$("#myModal").modal({
					show:true,
					drag:true,
					backdrop:false
				});
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
					var xmlids="";
					for(var i=0;i< selected.length;i++){
						xmlids += "'"+selected[i].data.XMLID+"',";
					}
					xmlids = xmlids.substr(0,xmlids.length-1);
					ai.executeSQL("delete from tablefile where XMLID in (" + xmlids + ")",false,"METADB");
					alert("删除成功")
		   			tableStore.select();
		   			buildTreeView(_treeSql.replace("{condi}",getQueryCondi()));
				}
			}
		}
	}
});

//配置界面
function showDialog(actType){
	$('#upsertForm').empty();
	var isRead = 'n';
	$("#dialog-ok").show();
	$("#dialog-cancel").html("取消");	
	if(actType=="add"){
		_act = "add";
	}else if(actType=="edit"){
		_act = "edit";	
	}else if(actType == "view"){
		_act = "view";
		isRead = 'y';
		$("#dialog-ok").hide();
		$("#dialog-cancel").html("关闭");
	}
	_editPanel = new AI.Form({
		id: 'baseInfoForm',
		store: tableStore,
		containerId: 'upsertForm',
		fieldChange: function(fieldName, newVal){},
		items: [
			{type : 'text', label : '名称', notNull: 'N', fieldName : 'DATANAME', isReadOnly: _act=="add"?'n':'y', width : 220 },
			{type : 'text', label : '中文名', notNull: 'N', fieldName : 'DATACNNAME', isReadOnly: isRead, width : 220 },
			{type : 'combox', label : '数据库', notNull: 'N', fieldName : 'DBNAME', isReadOnly: isRead, width : 220, storesql:"SELECT dbname,cnname FROM metadbcfg " },
			{type : 'combox', label : '主题', notNull: 'N', fieldName : 'TOPICNAME', isReadOnly: isRead, width : 220, storesql:"SELECT dim_code k,dim_value v FROM proc_schedule_dim WHERE dim_group_id IN (SELECT xmlid FROM proc_schedule_dim_group WHERE group_code = 'TOPIC_TYPE') order by dim_seq" },
			{type : 'combox', label : '层次', notNull: 'N', fieldName : 'LEVEL_VAL', isReadOnly: isRead, width : 220, storesql:"SELECT dim_code k,dim_value v FROM proc_schedule_dim WHERE dim_group_id IN (SELECT xmlid FROM proc_schedule_dim_group WHERE group_code = 'LEVEL_TYPE') order by dim_seq" },
			{type : 'combox', label : '周期', notNull: 'N', fieldName : 'CYCLETYPE', isReadOnly: isRead, width : 220, storesql:"SELECT dim_code k,dim_value v FROM proc_schedule_dim WHERE dim_group_id IN (SELECT xmlid FROM proc_schedule_dim_group WHERE group_code = 'CYCLE_TYPE') order by dim_seq" },
			{type : 'textarea', label : '说明', notNull: 'Y', fieldName : 'REMARK', isReadOnly: isRead, width : 220 }
		]
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
				var str = strArray[i];
				var subWhere = str.split(":")[0]+" = '"+str.split(":")[1]+"'";
				if(str.split(":")[1]=='未知') subWhere = str.split(":")[0] +" IS NULL ";
				if(where) where += " AND "+ subWhere
				else where = subWhere;
			}
			where = where.length>0?(" AND "+ where):"";
			tableStore.select(_sql.replace("{condi}", where + getQueryCondi()));
		},
		groupfield:"TOPICNAME,LEVEL_VAL,CYCLETYPE",
		sql:sql,
		dataSource:"METADB",
		subtype:'grouptree',
		renderer: function(val,node){
			var res = '未知';
			res = val||res;/*
			switch(val.toString().trim().toUpperCase()){
				case 'H':res='时接口';break;
				case 'D':res='日接口';break;
				case 'M':res='月接口';break;
				case 'X':res='实时接口';break;
				default:res=val;break;
			}*/
			return res;
		}
	});
};

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
	$("#search-text").on("keydown",function(e){
		if(e.keyCode == 13){ 
			document.getElementById("search").click();
		} 
	})
	tableStore = new AI.JsonStore({
		sql: _sql.replace("{condi}",getQueryCondi()),
		pageSize: 15,
		key: "XMLID",
		table: "tablefile",
		dataSource: "METADB"
	});
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
			{header: "名称", dataIndex: 'DATANAME', className: "ai-grid-body-td-center"},
			{header: "中文名", dataIndex: 'DATACNNAME', className: "ai-grid-body-td-center"},
			{header: "周期", dataIndex: 'CYCLETYPE', className: "ai-grid-body-td-center",
				render: function(data, val){
							var res="--";
							val = data.get(this.dataIndex);
							switch(val){
								case 'minute': res = "分钟"; break;
								case 'hour': res = "小时"; break;
								case 'day': res = "日"; break;
								case 'month': res = "月"; break;
								case 'year': res = "年"; break;
								default: break;
							}
							return res;
						}
			},
			{header: "数据库", dataIndex: 'DBCNNAME', className: "ai-grid-body-td-center"},
			{header: "层次", dataIndex: 'LEVEL_VALUE', className: "ai-grid-body-td-center"},
			{header: "主题", dataIndex: 'TOPIC_VALUE', className: "ai-grid-body-td-center"}
		]
	});
	
	buildTreeView(_treeSql.replace("{condi}",getQueryCondi()));
	
	function checkInput(){
		var items = _editPanel.config.items;
		for(var i=0; i< items.length; i++){
			if(items[i].notNull=="N"){
				var item = $("#"+items[i].fieldName);
				if(typeof(item)=="undefined" || item.val().length==0){
					alert(items[i].label + "为空！");
					return false;
				}
			}
		}
		
		return true;
	}
	
	//确定
	$("#dialog-ok").on('click', function(){
		if(!checkInput()) return false;
		
		var record = tableStore.curRecord;
		
		if( _act == "add"){
			record.set("XMLID",ai.guid());
			record.set("TEAM_CODE",_UserInfo.groupCode);
			record.set("CREATER",_UserInfo.username);
			record.set("EFF_DATE",new Date().format("yyyy-MM-dd hh:mm:ss"));
			tableStore.add(record);
		}
		var r = tableStore.commit(false);
		var rJson = $.parseJSON(r);
		if(rJson || rJson.success){
			alert("数据更新成功");
		}else{
			alert("出错：" + rJson.msg);
		}
        $('#myModal').modal('hide');
		tableStore.select();
		buildTreeView(_treeSql.replace("{condi}",getQueryCondi()));
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
				   <h4 class="modal-title">基本信息</h4> 
			   </div> 
			   <div class="modal-body" id="upsertForm"></div> 
			   <div class="modal-footer"> 
				   <button id="dialog-cancel" type="button" class="btn btn-default close-modal" >取消</button> 
				   <button id="dialog-ok" type="button" class="btn btn-primary">确定</button> 
			   </div> 
		  </div>
	   </div>
	</div>
	
	<div class="ui-layout-north">
		   			<ul class="nav navbar-nav" style="margin-top:4px">
						<li><a><i class="fa fa-home"> </i> 数据列表</a></li>
					</ul>
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