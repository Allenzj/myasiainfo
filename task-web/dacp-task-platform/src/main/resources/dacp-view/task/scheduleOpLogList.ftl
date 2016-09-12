<!DOCTYPE html>
<html lang="en" class="app">
<head>
<meta charset="UTF-8">
<title>调度操作日志列表</title>   
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
.table tr td{
	text-align:left;
}
</style>

<script>
var _act= "edit";
var _grid = "";
var _editPanel="";
var _sql=" select op_obj,a.op_user,b.usecnname,a.op_user_ip,a.op_type,a.op_sql,a.op_time  from schedule_op_log a " +
	      " left join metauser b on a.op_user = b.username " +
		  " WHERE 1=1 {condi} ";
var _treeSql="select op_type,count(1) num from (" + _sql + ") t group by op_type";
 
_sql += " order by op_time desc";
var tableStore = new AI.JsonStore({
	sql: _sql.replace("{condi}",""),
	pageSize: 15,
	table: "schedule_op_log",
	dataSource: "METADBS"
});

//查询条件
var getQueryCondi=function(){
	var searchText = $("#search-text input").val();
	var opUser = $("#op-user input").val();
	var opTime = $("#op-time input").val();
	
	var _condi = "";
	if(searchText) {
		_condi += " AND a.op_obj like '%" + searchText + "%' ";
	};
	if(opUser) {
		_condi += " AND (a.op_user like '%" + opUser + "%' or b.usecnname like '%" + opUser + "%')";
	};
	if(opTime) {
		_condi += " AND a.op_time like '%" + opTime + "%' ";
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
				"placeholder":"任务名",
				"style": "min-width:200px;width:180px;margin-left:210px;"
			},
			{
				"type": "text",
				"id":"op-user",
				"fieldLabel":"",
				"placeholder":"操作人",
				"style": "min-width:200px;width:180px;"
			},
			{
				"type": "text",
				"id":"op-time",
				"fieldLabel":"",
				"placeholder":"操作时间",
				"style": "min-width:200px;width:180px;"
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
			}
		],
		'events': {	
			afterRender:function(){
				var _view = this;
				_view.$el.find("#search").empty().append('<button type="button" class="btn btn-sm btn-warning"><span class="glyphicon glyphicon-eye-open"></span>查询</button>');
			},		
			'click #search':function(){
				switchContent(getQueryCondi());
			},
			'click #add':function(){
				var r = tableStore.getNewRecord();
				tableStore.curRecord = r;
				showDialog("add");
				$("#myModal").modal({
					show:true,
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
					for(var i=0;i< selected.length;i++){
						ai.executeSQL("delete from inter_cfg where XMLID='" + selected[i].get("XMLID") + "'","false","METADB")	
					}
					alert("删除成功")
		   			tableStore.select();
		   			buildTreeView(_treeSql.replace("{condi}",""));
				}
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
				var str =strArray[i];
				var subWhere=str.split(":")[0]+" = '"+str.split(":")[1]+"'";
				if(str.split(":")[1]=='未知') subWhere = str.split(":")[0] +" IS NULL ";
				if(where) where += " AND "+ subWhere
				else where = subWhere;
			}
			where = where.length>0?(" AND "+ where):"";
			tableStore.select(_sql.replace("{condi}", where + getQueryCondi()));
		},
		groupfield:"OP_TYPE",
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
			{header: "任务名", dataIndex: 'OP_OBJ', cls:"ai-grid-body-td-left"},
			{header: "操作人", dataIndex: 'USECNNAME', cls:"ai-grid-body-td-left"},
			{header: "操作", dataIndex: 'OP_TYPE', cls:"ai-grid-body-td-left"},
			{header: "操作时间", dataIndex: 'OP_TIME', cls:"ai-grid-body-td-left"},
			{header: "操作sql", dataIndex: 'OP_SQL', width:300, cls:"ai-grid-body-td-left"}
		]
	});
	
	buildTreeView(_treeSql.replace("{condi}",""));
	
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