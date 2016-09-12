
<!DOCTYPE html>
<html lang="en" class="app">
<head>
<meta charset="utf-8" />
<title>DACP数据云图</title>
<meta name="viewport"
	content="width=device-width, initial-scale=1, maximum-scale=1" />
<link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css"
	type="text/css" rel="stylesheet" media="screen" />
<link href="${mvcPath}/dacp-res/task/css/app.v1.css" type="text/css" rel="stylesheet" />
<script type="text/javascript"
	src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js"></script>
<script type="text/javascript"
	src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript"
	src="${mvcPath}/dacp-lib/underscore/underscore-min.js"></script>
<script src="${mvcPath}/dacp-lib/backbone/backbone-min.js"
	type="text/javascript"></script>
<!-- <script src="${mvcPath}/dacp-view/ve/js/dacp-ve-js-1.0.js" type="text/javascript" charset="utf-8"></script> -->
<!--<script src="${mvcPath}/ve/ve-context-path.js" type="text/javascript" charset="utf-8"></script>-->
<script src="${mvcPath}/dacp-lib/jquery-plugins/jquery.layout-latest.js"
	type="text/javascript"> </script>
<script
	src="${mvcPath}/dacp-lib/jquery-plugins/bootstrap-treeview.min.js"> </script>
<script src="${mvcPath}/dacp-res/task/js/app.plugin.js"></script>

<!-- 使用ai.core.js需要将下面两个加到页面 -->
<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>

<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>
<script
	src="${mvcPath}/dacp-lib/jquery-plugins/bootstrap-treeview.min.js"> </script>
<script type="text/javascript"
	src="${mvcPath}/dacp-lib/underscore/underscore-min.js"></script>

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

a {
	cursor: pointer;
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
var curTeamCodeCond="";
var curTeamCode="";
var proc_state="";
var run_freq="";
var trigger_type="";
var getQueryCondition = function(){
	var _searchText = $("#search-text").val().trim();
	var _searchCondi =_searchText.length>1?" AND (b.dataname LIKE '%"+ _searchText+"%' or b.datacnname LIKE '%"+_searchText+"%')":"";
	var _searchDate=$("#search-date-time").val().trim();
	_searchCondi += _searchDate.length>0?" AND a.data_time='"+_searchDate+"'":"";
	var _cycletype=$("#run_freq_select").val();
	 _searchCondi += _cycletype.length>0?" AND b.cycletype='"+_cycletype+"'":"";
	var curTeamCodeCond = (typeof(curTeamCode)=="undefined" || curTeamCode =='' || curTeamCode == 'undefined' )?(''):("  and team_code = '"+curTeamCode+"' ")
	 _searchCondi += curTeamCodeCond;
    return _searchCondi;
};
$(document).ready(function() {
	curTeamCode = paramMap['team_code'];
	
	//curTeamCodeCondi="";
	var curDisplayType="grid";
	var searchCondi='';
	var curdata;
	var toggleButtons = '<div class="btnCenter"></div>'
		+ '<div class="btnBoth"></div>'
		+ '<div class="btnWest"></div>';
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
		,	west__togglerContent_closed:	toggleButtons
		,	west__togglerContent_open:		toggleButtons
		,	west__size:						205
		,	north__size: 					50
	});
    var procSql=" SELECT a.target,b.dbname,b.dataname,b.datacnname,a.data_time,a.generate_time ,b.team_code,b.topicname " +
                " FROM proc_schedule_meta_log a,tablefile b " +
                " where a.target=b.xmlid " +
		    	" and 1=1 #condi#  order by data_time desc ";
    
    var condi=getQueryCondition();
    var procStore = new AI.JsonStore({
		sql:procSql.replace("#condi#","" + condi),
		pageSize:15,
		key:"target",
		table:"proc_schedule_meta_log",
		dataSource:"METADBS"
	});
	var buildTreeView = function(sql){
		$('#treeview6').treeview({
			color: "#428bca",
			expandIcon: "glyphicon glyphicon-chevron-right",
			collapseIcon: "glyphicon glyphicon-chevron-down",
			nodeIcon: "glyphicon glyphicon-tasks",
			showTags: true,
			onNodeSelected:function(event,node){
				var strArray=node.id.split(">");
				var where="";
				for(var i=0;i<strArray.length;i++){
					var str =strArray[i];
					var subWhere=str.split(":")[0]+" = '"+str.split(":")[1]+"'";
					if(str.split(":")[1]=='未知') subWhere = str.split(":")[0] +" is null ";
					if(where) where += " and "+ subWhere
					else where=subWhere;
				}
				where = where.length>0?(" and "+where):"";
				procStore.select(procSql.replace("#condi#",where+searchCondi));
				if(curDisplayType=="card"){
					$("#tabpanel2").show();
					$("#datagrid").hide();
				}else{
					$("#datagrid").show();
					$("#tabpanel2").hide();
				}
			},
			groupfield:"TOPICNAME,LEVEL_VAL",//"TOPICNAME,LEVEL_VAL",//SCHEMA_NAME,TABSPACE,
			titlefield:"TOPICNAME",
			iconfield:"",
			sql:sql,
			subtype: 'grouptree' 
		});
	};
	var _rowClickFunc = function (e,agr){
		curdata= agr.data;
	};
	var celldblclick = function(dataIndex, record){};
	var _rowdblClickFunc = function(val,rowdata){
		if(rowdata){
			//window.open("WizCreTable.html?OBJNAME="+rowdata.get('DATANAME'));
			//parent.loadTabStruct(rowdata.get('DATANAME'));
			var r = procStore.curRecord;
		   	var DBNAME = DBNAME='defaultDB';
		  	var METAPRJ = '';
		  	var caption='';
			var _title ="表:"+r.get('TARGET')+" 血缘分析";
			parent.openTableInfo("ana-Before",_title,r.get('PROC_NAME'),true);
		}
		return false;
	};
	var _stateRender=function (value,data,index){
		 var _val=value.get("STATE");
	 		 var finalVal="";
	 		 if(_val=="UNPUBLISH"){
	 			finalVal='<div><font color="blue">待发布</font></div>';
	 		 }else if(_val=="INVALID"){
	 			finalVal='<div><font color="red">失效</font></div>';
	 		 }else if(_val=="VALID"){
	 			finalVal='<div><font color="green">生效</font></div>';
	 		 }else  if(_val=="PUBLISHED"){
	 			 finalVal='<div><font color="black">已发布</font></div>';
	 		 }else {
	 			 finalVal='<div><font color="blue">待发布</font></div>';
	 		 }
	 		 return finalVal; 
	};
    var _runFreqRender=function(value,data,index){
	    	 var _freq= value.get("RUN_FREQ");
  	    	 _freq=_freq=="day"?"日":_freq;
  	    	 _freq=_freq=="month"?"月":_freq;
  	    	 _freq=_freq=="hour"?"小时":_freq;
  	    	 _freq=_freq=="week"?"周":_freq;
  	    	 _freq=_freq=="year"?"年":_freq;
  	    	 _freq=_freq=="minute"?"分钟":_freq;
  	    	 return _freq;
  	} ;
  	var _levelRender=function(value,data,index){
  		return value.get("RESOUCE_LEVEL")==3?"高":value.get("RESOUCE_LEVEL")==2?"中":"低";
  	};

	var config={
		id:'datagrid',
		store:	procStore,
		pageSize:12,
		containerId:'datagrid',
		nowrap:true,
		showcheck:true,
		rowclick:_rowClickFunc,
		celldblclick:_rowdblClickFunc,
		columns:[
		         {header: "数据名", width:130,dataIndex: 'DBNAME'},
			　  	 {header: "表名", width:130,dataIndex: 'DATANAME'},
		  	     {header: "中文名称", width:200, dataIndex: 'DATACNNAME'},
		  	     {header: "数据日期", width:74, dataIndex: 'DATA_TIME'},
		  	     {header: "生成时间", width:75, dataIndex: 'GENERATE_TIME'} 
		]
	};
	var grid =new AI.Grid(config);
	var _treeSql  = " SELECT  TOPICNAME,COUNT(1) NUM FROM (" + procSql + ") t "
		  _treeSql+= " WHERE 1=1 #condi#  GROUP BY TOPICNAME ORDER BY NUM DESC";
	buildTreeView(_treeSql.replaceAll("#condi#",condi));
	var switchContent = function(condi){
		buildTreeView(_treeSql.replace("#condi#",condi));
		procStore.select(procSql.replace("#condi#",condi));
	};
	$('#trigger_type_select').on('change',function(e){
		trigger_type= $("#trigger_type_select").val();
		searchCondi = getQueryCondition();
        switchContent(searchCondi);
	});

	$('#run_freq_select').on('change',function(e){
		run_freq = $("#run_freq_select").val();
		searchCondi = getQueryCondition();
		switchContent(searchCondi);
	});
	$('#search-key').on('click',function(e){
		searchCondi = getQueryCondition();
		switchContent(searchCondi);
	});

	var _checkUniq = function(arr){
		if(arr.length!=1){
			alert("请选取一项！");
		}
		return arr.length==1?true:false;
	}
	
	var $el = parent.$('#panel1');
	
	var bindCarouselWithProc = function(tabName){
		$el.on("push-left-"+tabName,function(){
			curIndex = parseInt(procStore.curIndex);
			var _index = curIndex==0?procStore.getCount()-1:curIndex-1;
			var r = procStore.getAt(_index);
			var _title = "程序:"+r.get('PROC_NAME').toUpperCase()+" 影响分析";
			parent.openTableInfo(tabName,_title,r.get('PROC_NAME'),true);
			procStore.curIndex = _index;
		});
		$el.on("push-right-"+tabName,function(){
			curIndex = parseInt(procStore.curIndex);
			var _index = curIndex==procStore.getCount()-1?0:curIndex+1;
			var r = procStore.getAt(_index);
			var _title = "程序:"+r.get('PROC_NAME').toUpperCase()+" 影响分析";
			parent.openTableInfo(tabName,_title,r.get('PROC_NAME'),true);
			procStore.curIndex = _index;
		});
	};

});
</script>
</head>

<body class="">
	<div class="ui-layout-north">
		<nav class="navbar navbar-default" role="navigation"
			style="margin-bottom: 1px">
			<div class="container-fluid" style="padding-left: 0px">
				<div class="collapse navbar-collapse" style="padding-left: 0px">
					<ul class="nav navbar-nav">
						<li><a><i class="fa fa-home"> </i> 数据生成记录</a></li>
					</ul>
					<form class="navbar-form navbar-left" role="search">
						<div class="form-group">
							<select id="run_freq_select" class="form-control formElement">
								<option value="">周期</option>
								<option value="year">年</option>
								<option value="month">月</option>
								<option value="day">日</option>
								<option value="hour">小时</option>
								<option value="minute">分钟</option>
							</select>
						</div>
						<div class="form-group">
							<input id="search-text" type="text" class="form-control"
								style="width: 200px" placeholder="输入表名,中文名">
							<input id="search-date-time" type="text" class="form-control"
								style="width: 200px" placeholder="数据日期">								
						</div>
						<button id="search-key" type="button"
							class="btn btn-success btn-xs">查找</button>
						<button id="insertBtn" type="button"
							class="btn btn-primary btn-xs">分析</button>
					</form>
				</div>
				<!-- /.navbar-collapse -->
			</div>
			<!-- /.container-fluid -->
		</nav>
	</div>
	<div class="ui-layout-west" style="overflow: auto;">
		<div id="treeview6" class="test"></div>
	</div>
	<div class="ui-layout-center">
		<div id="datagrid" style="margin-bottom: 10px; margin-right: 10px"></div>
		<div id="tabpanel2" style="margin-bottom: 10px"></div>
	</div>
</body>
</html>