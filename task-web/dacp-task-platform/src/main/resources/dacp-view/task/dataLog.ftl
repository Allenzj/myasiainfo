<!DOCTYPE html>
<html lang="en" class="app">
<head>
<meta charset="UTF-8">
<title>消息监控日志列表</title>   
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"  />
	<link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-lib/datepicker/datepicker.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-lib/datepicker/jquery.simpledate.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-lib/datepicker/jquery.pst-area-control.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-view/ve/css/dacp-ve-js-1.0.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="/dacp/dacp-res/task/css/implWidgets.css" type="text/css" rel="stylesheet"  />
	<link href="${mvcPath}/dacp-view/aijs/css/ai.css" type="text/css" rel="stylesheet"  />
	
	<script src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js" type="text/javascript"></script>
	<script src="${mvcPath}/dacp-lib/jquery/jquery-ui-1.10.2.min.js" type="text/javascript"></script>
	<script src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>
	<script src="${mvcPath}/dacp-lib/underscore/underscore.js" type="text/javascript"></script>
	<script src="${mvcPath}/dacp-lib/backbone/backbone-min.js" type="text/javascript"></script>
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
	.dropdown-submenu {
		position: relative;
	}
	
	.view_total_up_top{
		margin-top: 4px;
	}
	.dropdown-submenu>.dropdown-menu {
		top: 0;
		left: 100%;
		margin-top: -6px;
		margin-left: -1px;
		-webkit-border-radius: 0 6px 6px 6px;
		-moz-border-radius: 0 6px 6px;
		border-radius: 0 6px 6px 6px;
	}
	
	.dropdown-submenu:hover>.dropdown-menu {
		display: block;
	}
	
	.dropdown-submenu>a:after {
		display: block;
		content: " ";
		float: right;
		width: 0;
		height: 0;
		border-color: transparent;
		border-style: solid;
		border-width: 5px 0 5px 5px;
		border-left-color: #ccc;
		margin-top: 5px;
		margin-right: -10px;
	}
	
	.dropdown-submenu:hover>a:after {
		border-left-color: #fff;
	}
	
	.dropdown-submenu.pull-left {
		float: none;
	}
	
	.dropdown-submenu.pull-left>.dropdown-menu {
		left: -100%;
		margin-left: 10px;
		-webkit-border-radius: 6px 0 6px 6px;
		-moz-border-radius: 6px 0 6px 6px;
		border-radius: 6px 0 6px 6px;
	}
</style>

<script>
var _sql="SELECT seqno,d.proc_name,proc_date,target,dataname,b.dbname,c.cnname dbcnname,data_time,trigger_flag,generate_time,need_dq_check,dq_check_res  " +
			" FROM proc_schedule_meta_log a " +
			" left join tablefile b on a.target=b.xmlid " +
			" left join metadbcfg c on b.dbname=c.dbname " +
			" left join proc d on a.proc_name = d.xmlid  " +
			" where 1=1 {condi} ";

var _treeSql="select dbname,dbcnname,count(1) num from (" + _sql + ") t group by dbname,dbcnname";
 
_sql += " order by data_time desc";
var tableStore = new ve.SqlStore({
	sql: _sql.replace("{condi}",""),
	dataSource: "METADBS"
});

//查询条件
var getQueryCondi=function(){
	var searchText = $("#search-text input").val();
	var dbName = $("#db_name select").val();
	var runFreq = $("#run_freq select").val();
	var dataTime = $("#data_time input").val();
	
	var _condi = "";
	if(searchText) {
		_condi +=" AND (d.proc_name like '%" + searchText + "%' or b.dataname like '%" + searchText + "%' )" ;
	};
	if(dbName) {
		_condi +=" AND b.dbname='"+dbName+"'";
	};
	
	if(runFreq) {
		_condi +=" AND length(data_time) = "+runFreq+"' ";
	};
	
	if(dataTime) {
		dataTime =dataTime.replace(/\-/g,""); 
		_condi +=" AND data_time like '" + dataTime + "%' ";
	};
	return _condi;
};

//刷新版面
var switchContent = function(condi){
	if(!condi||typeof(condi)=="undefined"){
		condi="";
	}
	buildTreeView(_treeSql.replace("{condi}",condi));
	tableStore.config.sql = _sql.replace("{condi}",condi);
	tableStore.fetch();
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
				"placeholder":"表名，任务名",
				"style": "min-width:200px;width:180px;margin-left:210px;"
			},
			 {
				"type":"combox",
				"fieldLabel":"数据库",
				"id":"db_name",
				"style": "min-width:80px;width:140px;",
				"sql":"SELECT dbname AS `KEY`,cnname AS `VALUE` FROM metadbcfg",
				"dataSource": "METADBS"
			},
			{
				"type":"combox",
				"id":"run_freq",
				"fieldLabel":"周期",
				"style": "min-width:60px;width:80px;",
				"select":[{'key':8,'value':'日'},{'key':6,'value':'月'},{'key':10,'value':'小时'}]
			},
			{
				"type": "date",
				"id":"data_time",
				"fieldLabel":"数据日期",
			    "format" : "yyyy-mm-dd",
				"style": "min-width:60px;width:120px;"
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
				var subWhere="b."+str.split(":")[0]+" = '"+str.split(":")[1]+"'";
				if(str.split(":")[1]=='未知') subWhere = "b."+str.split(":")[0] +" IS NULL ";
				if(where) where += " AND "+ subWhere
				else where = subWhere;
			}
			where = where.length>0?(" AND "+ where):"";
			tableStore.select(_sql.replace("{condi}", where + getQueryCondi()));
		},
		groupfield:"DBNAME",
		titlefield:"DBCNNAME",
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

var _operIcon = function(value,data,index){
	var _tmpl=
	'<div class="btn-group '+(index>6?"dropup":"")+'">'+
	'<button class="btn btn-xs btn-default dropdown-toggle" data-toggle="dropdown" type="button">'+
	'数据关系'+
	'<span class="caret"></span>'+
	'</button>'+
	'<ul class="dropdown-menu" role="menu">'+
	'<li>'+
	'<a id="kinship_pre"  name="<%=_dataname%>" xmlid="<%=_xmlid%>">血缘分析</a>'+
	'</li>'+
	'<li>'+
	'<a id="kinship_next" name="<%=_dataname%>" xmlid="<%=_xmlid%>">影响分析</a>'+
	'</li>'+
	'</ul>'+
	'</div>';
	return _.template(_tmpl,{"_xmlid":data.TARGET,"_dataname":data.DATANAME});
};

var _grid = new ve.GridWidget({
	config:{
		"className":"grid",
		'showcheck': false,
		'id':'evaluateView_tab_evaluate_middle_down_grid',
		'pageSize':15,
		"header":[
			{"label":"表名", "dataIndex": "DATANAME", "className":"ai-grid-body-td-center"},
			{"label":"数据库","dataIndex": "DBCNNAME", "className":"ai-grid-body-td-center"},
			{"label":"数据日期", "dataIndex": "DATA_TIME", "className":"ai-grid-body-td-center"},
			{"label":"生成日期", "dataIndex": "GENERATE_TIME", "className":"ai-grid-body-td-center"},
			{"label":"源程序", "dataIndex": "PROC_NAME", "className":"ai-grid-body-td-center"},
			{"label":"操作", "dataIndex":"TARGET", "className":"ai-grid-body-td-center", renderer:_operIcon}
		 ],
		"events":{
			afterRender:function(){
				this.$el.find(".table-area").css("overflow","visible");
				this.$el.find(".table-outer").css("overflow","visible");
				this.$el.css("padding","0px 0px 10px 25px");
			},
			afterTabelBodyRender:function(){
				var _view = this;
				_view.$el.find("a#kinship_pre,a#kinship_next").on("click",function(e){
					var _id = $(e.currentTarget).attr("id");
					var xmlid = $(e.currentTarget).attr("xmlid");
					var dataname=$(e.currentTarget).attr("name");
					var op = "";
					if(_id=="kinship_pre"){
						op = "li_before";
					}else{
						op = "li_after";
					}
					window.open("/" + contextPath + "/ftl/task/monitorDialog?xmlid="+xmlid+"&dataname="+dataname+"&op="+op);
			    });
			}
		}
  	}
});

function openTableInfo(tabname, title, template, flag) {
	$("#panel1 #tab_fullname").empty().append(title); //标题

	$("#panel1 #op-panelContent").empty().append(template);//内容
	$("#panel1").triggerHandler("finishRender");//注册后续触发时间

	$("#panel1").css("z-index", 10011).slideDown(function() {
		/*
		if (tabname.indexOf("ana") != -1) {
			var _type = tabname.split("-")[1];
			$("#panel1 #op-panelContent")
			.empty()
			.append('<span style="display: inline-block; vertical-align: top; padding: 5px; width: 100%"><div id="myDiagram" style="background-color: Snow;"></div></span>');
			init(_type.toLowerCase(), template);
		} else if (tabname === 'focusMonitor') {
		}*/
	});
	return false;
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
	_queryPanel.$el=$("#queryPanel");
	_queryPanel.render();
	_grid.$el=$("#tabpanel");
	
	tableStore.on("reset",function(){
		_grid.store = tableStore;
		_grid.store.fetched = true;
		_grid.render();
	});
	tableStore.fetch();
	
	$("#search-text").on("keydown",function(e){
		if(e.keyCode == 13){ 
			document.getElementById("search").click();
		} 
	})
	
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