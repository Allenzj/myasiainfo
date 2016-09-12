<!DOCTYPE html>
<html lang="zh" class="app">
<head>
	<meta charset="utf-8" />
	<title>大数据开放平台</title>   
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"  />  
	<link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-view/aijs/css/ai.css" type="text/css" rel="stylesheet"  />

	<script type="text/javascript" src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js"></script>
	<script type="text/javascript" src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>

	<script src="${mvcPath}/dacp-lib/jquery-plugins/jquery.layout-latest.js" type="text/javascript"> </script>
	
	<!-- 使用ai.core.js需要将下面两个加到页面 -->
	<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
	<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>
	
	<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>
	<script src="${mvcPath}/dacp-lib/jquery-plugins/bootstrap-treeview.min.js"> </script>
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

.ui-layout-north {
	z-index: 10000 !important;
}

.ui-layout-center {
	overflow: auto;
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

</style>
<script>
	var Global ={};//跨窗口之间传递的全局变量
	if(window.parent)  Global = window.parent.Global;

$(document).ready(function() {
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

	var page = {
		sql:"select {XMLID}, {cols}  FROM {table} where 1=1 {condi}",
		treeSQL:"select {treeCol2},COUNT(*) NUM from {table} where 1=1 {condi} GROUP BY {treeCol}",
		/*treeSQL:"select TOPICNAME,CYCLETYPE,{level},COUNT(1) NUM from {table} where 1=1 {condi} group by TOPICNAME,{level},CYCLETYPE",*/
		cols:{
			flow:['FLOWCODE,FLOWNAME,AL_LEVEL,STATE,STATE_DATE,TOPICNAME,CYCLETYPE,CREATER','TRANSFLOW','AL_LEVEL','流程','DataFlow','AL_LEVEL','AL_LEVEL','XMLID'],
			proc:['PROC_NAME,PROCCNNAME,LEVEL_VAL,STATE,STATE_DATE,TOPICNAME,CYCLETYPE,CREATER','PROC','TOPICNAME,LEVEL_VAL,CYCLETYPE','任务','ETL','TOPICNAME,LEVEL_VAL,CYCLETYPE','TOPICNAME,LEVEL_VAL,CYCLETYPE','XMLID'],
			inter:['FULLINTERCODE,INTER_NAME,STATUS,CREATER','INTER_CFG','DATAREGION,SOURCESYS,INTER_CYCLE','任务','Inter',
			       'DATAREGION,'+'(SELECT rowname FROM metaedimdef WHERE dimcode=\'DIM_INTERDATAREGION\' AND rowcode=DATAREGION) DATAREGIONNAME,'
			    	+'SOURCESYS,'+'(SELECT rowname FROM metaedimdef WHERE dimcode=\'DIM_INTERSOURCESYS\' AND rowcode=SOURCESYS) SOURCESYSNAME,'
			        +'INTER_CYCLE,'+'(SELECT rowname FROM metaedimdef WHERE dimcode=\'DIM_INTERINTERCYCLE\' AND rowcode=INTER_CYCLE) INTER_CYCLENAME','DATAREGIONNAME,SOURCESYSNAME,INTER_CYCLENAME','XMLID'],
			data:['DATANAME,DATACNNAME,LEVEL_VAL,STATE,STATE_DATE,TOPICNAME,CYCLETYPE','TABLEFILE','TOPICNAME,LEVEL_VAL,CYCLETYPE','模型','Table','TOPICNAME,LEVEL_VAL,CYCLETYPE','TOPICNAME,LEVEL_VAL,CYCLETYPE','XMLID'],
			scope:['KPI_SCOPE_CODE,KPI_SCOPE_NAME,STATE,CREATE_USER as CREATER','KPI_SCOPE_DEF','STATE','指标组','KPI_SCOPE','STATE','STATE','KPI_SCOPE_ID'],
			kpi:['KPI_CODE,KPI_NAME,STATE,CREATE_USER as CREATER','KPI_DEF','STATE','指标','KPI','STATE','STATE','KPI_CODE']},
		nodeCondi:"",
		searchCondi:"",
		oldType:"",
		store:{},
		init:function(){
			var self = this;
			var defaultDisplay = 'flow';
			this.type = defaultDisplay;
			self.oldType = defaultDisplay;
			
			if(paramMap['TOPIC']&&paramMap['TOPIC'].length>0){
				this.sql = this.sql.replace('1=1'," TOPICNAME LIKE '%"+paramMap['TOPIC']+"%'");
				this.treeSQL = this.treeSQL.replace('1=1'," TOPICNAME LIKE '%"+paramMap['TOPIC']+"%'");
			}

			var sql = this.switchSQL(defaultDisplay);
			this.store = new AI.JsonStore({
				sql:sql,
				dataSource:'METADBS',
				pageSize:20,
			});
			this.store.removeEvent('dataload');
			this.store.addEvent('dataload',function(){
				if(self.type==self.oldType){
					flowGrid.build();
				}else{
					self.buildGrid(self.type);
					self.oldType = self.type;
				}
			});
			self.buildTreeView(self.switchTreeSQL());
			self.buildGrid(defaultDisplay);
		},
		switchSQL:function(){
			var self = this;
			return this.sql.replace('{cols}',self.cols[self.type][0])
			.replace('{table}',self.cols[self.type][1])
			.replace('{condi}',self.searchCondi+self.nodeCondi)
			.replace(/{XMLID}/g,self.cols[self.type][7]);
		},
		switchTreeSQL:function(){
			var self = this;
			return this.treeSQL.replace(/{treeCol}/g,self.cols[self.type][2])
			.replace('{table}',self.cols[self.type][1])
			.replace('{condi}',self.searchCondi+self.nodeCondi)
			.replace(/{treeCol2}/g,self.cols[self.type][5])
			.replace(/{XMLID}/g,self.cols[self.type][7]);
		},
		refresh:function(){
			var self = this;
			self.store.select(self.switchSQL());
			self.buildTreeView(self.switchTreeSQL());
		},
		buildTreeView:function(sql){
			var self = this;
			$('#treeview6').empty().treeview({
				color: "#428bca",
				expandIcon: "glyphicon glyphicon-chevron-right",
				collapseIcon: "glyphicon glyphicon-chevron-down",
				nodeIcon: "glyphicon glyphicon-user",
				showTags: true,
				onNodeSelected:function(event,node){
					var strArray=node.id.split(">");
					var where="";
					for(var i=0;i<strArray.length;i++){
						var str =strArray[i];
						var subWhere=str.split(":")[0]+" = '"+str.split(":")[1]+"'";
						if(str.split(":")[1]=='未知') subWhere = str.split(":")[0] +" is null ";
						if(where) where += " and "+ subWhere;
						else where=subWhere;
					}
					self.nodeCondi = where.length>0?(" and "+where):"";
					self.store.select(self.switchSQL());
				},
				groupfield:self.cols[self.type][2],
				titlefield:self.cols[self.type][6],
				sql:sql,
				dataSource:'METADBS',
				subtype:'grouptree',
				renderer:function(text){
					var t=text||'';
					var arr=text.split('|');
					return arr[arr.length-1]||text;
				}
			});
		},
		buildGrid:function(){
			var self = this;
			var _rowdblClickFunc = function(val,rowdata){
				if(self.type!='scope'&&self.type!='kpi'){
				if(rowdata){
					window.open("/"+contextPath+"/devmgr/WizCre"+self.cols[self.type][4]+".html?ACTTYPE=readOnly&OBJNAME="+rowdata.get('XMLID'));
				}
				}
				return false;
			};
			var flowStateRender = function(record, val){
				var res = '--';val = val||res;
				switch(val.toString().trim().toUpperCase()){
					case 'UNPUBLISH':res='待发布';break;
					case 'INVALID':res='失效';break;
					case 'VALID':res='生效';break;
					case 'PUBLISHED':res='已发布';break;
					default:res=val;break;
				}
				return res;
			};
			var columns = [
				{header: "主题", width:74, dataIndex: 'TOPICNAME',render:function(record,text){
					var t=text||'';
					var arr=text.split('|');
					return arr[arr.length-1]||text;
				}},
				{header: "周期", width:74, dataIndex: 'CYCLETYPE'},
				{header: "状态日期",dataIndex: 'STATE_DATE'},
				{header: "创建人", dataIndex: 'CREATER'}
			];
			var _cols = {
				flow:[{header:"名称",dataIndex: 'FLOWCODE',  sortable: true,maxLength:20},
					{header:"中文名称",dataIndex: 'FLOWNAME',  sortable: true,maxLength:20},
					{header: "状态", dataIndex: 'STATE',render:flowStateRender}],
				proc:[{header:"名称",dataIndex: 'PROC_NAME', sortable: true,maxLength:20},
					{header:"中文名称",dataIndex: 'PROCCNNAME',  sortable: true,maxLength:20},
					{header: "层次", width:74, dataIndex: 'LEVEL_VAL'},
					{header: "状态", dataIndex: 'STATE',render:flowStateRender}],
				inter:[{header:"名称",dataIndex: 'FULLINTERCODE',  sortable: true,maxLength:20},
					{header:"中文名称",dataIndex: 'INTER_NAME',  sortable: true,maxLength:20},
					{header: "状态", dataIndex: 'STATUS',render:flowStateRender}],
				data:[{header:"名称",dataIndex: 'DATANAME',  sortable: true,maxLength:20},
					{header:"中文名称",dataIndex: 'DATACNNAME',  sortable: true,maxLength:20},
					{header: "层次", width:74, dataIndex: 'LEVEL_VAL'},
					{header: "状态", dataIndex: 'STATE',render:flowStateRender}],
				scope:[{header:"名称",dataIndex: 'KPI_SCOPE_CODE',  sortable: true,maxLength:20},
					{header:"中文名称",dataIndex: 'KPI_SCOPE_NAME',  sortable: true,maxLength:20},
					{header: "状态", dataIndex: 'STATE',render:flowStateRender}],
				kpi:[{header:"名称",dataIndex: 'KPI_CODE',  sortable: true,maxLength:20},
					{header:"中文名称",dataIndex: 'KPI_NAME',  sortable: true,maxLength:20},
					{header: "状态", dataIndex: 'STATE',render:flowStateRender}]
			};
			$('#tabpanel').empty();
			flowGrid =new AI.Grid({
				store:self.store,
				containerId:'tabpanel',
				pageSize:15,
				nowrap:true,
				rowclick:function(rowdata){curdata= rowdata;},
				celldblclick:_rowdblClickFunc,
				columns:_cols[self.type].concat(columns)
			});
		}
	};

	page.init();

	$("#query_schedule_info").hide();
	$('#show-content .btn').on("click",function(){
		page.nodeCondi=page.searchCondi="";
		page.type = $(this).attr("id");
		if(page.type=='proc'){
			$("#query_schedule_info").show();
		}else{
			$("#query_schedule_info").hide();
		}
		page.refresh();
	});
	$('#obj-search').on("click",function(){
		var _searchText = $(this).parent().find('input#search-text').val().trim();
		var condis = {
			flow:['FLOWCODE','FLOWNAME'],
			proc:['PROC_NAME','PROCCNNAME'],
			inter:['FULLINTERCODE','INTER_NAME'],
			data:['DATANAME','DATACNNAME'],
			scope:['KPI_SCOPE_CODE','KPI_SCOPE_NAME'],
			kpi:['KPI_CODE','KPI_NAME']
		}
		var cond=" and ({code} like '%"+_searchText+"%' or {name} like '%"+_searchText+"%') ";
		page.searchCondi=cond.replace('{code}',condis[page.type][0]).replace('{name}',condis[page.type][1]);
		page.nodeCondi="";
		page.refresh();
	});

	//添加调度信息查看按钮
	$("#query_schedule_info").click(function(){	
		var selected = flowGrid.getCheckedRows();
		if(selected.length!=1){
			alert('只能选中一行！');
			return;
		}else if (selected[0].get('STATE').toUpperCase()!='PUBLISHED' && selected[0].get('STATE').toUpperCase()!='VALID'){
			alert("程序未上线！");
			return;
		}
		
		var proc_name =selected[0].get('PROC_NAME');
		$("#upsertForm").empty();
		
		var sql1="SELECT b.proc_name,b.creater,a.platform,a.agent_code,a.trigger_type,a.eff_time,a.exp_time,a.cron_exp,a.muti_run_flag,a.date_args,a.pri_level FROM proc_schedule_info a RIGHT JOIN proc b on a.proc_name = b.proc_name where b.proc_name ='" + proc_name + "'";
		ds_mydata=new AI.JsonStore({
			sql : sql1,
			filter : 'proctype =1',
			selfield : '',
			key : "PROC_NAME",
			pageSize : 15,
			table : "PROC"
		});
		var formcfg = ({
			id : 'form',
			store : ds_mydata,
			containerId : 'upsertForm',
			items : [ 
				{type : 'text',label : '程序名称',fieldName : 'PROC_NAME',isReadOnly:"y"},
				{type : 'date',label : '上线时间',fieldName : 'EFF_TIME',value:new Date().format('yyyy-mm-dd'),isReadOnly:"y"}, 
				{type : 'date',label : '下线时间',fieldName : 'EXP_TIME',isReadOnly:"y"},
				{type : 'combox',label : '资源组',fieldName : 'PLATFORM',storesql:"SELECT PLATFORM K, PLATFORM_CNNAME V  FROM PROC_SCHEDULE_PLATFORM",checkItems: 'AGENT_CODE',isReadOnly:"y"},
				{type : 'combox',label : '优先级',fieldName : "PRI_LEVEL",storesql:'20,高|15,高于正常|10,正常|5,低于正常|1,低',isReadOnly:"y"},
			    {type : 'combox',label : 'AGENT',fieldName : 'AGENT_CODE',storesql:"select AGENT_NAME K,HOST_NAME V  from AIETL_AGENTNODE where TASK_TYPE='TASK' and PLATFORM='{val}'",isReadOnly:"y"}, 
				{type : 'radio-custom',label : '运行模式',fieldName : 'MUTI_RUN_FLAG',storesql:'0,顺序启动|1,多重启动|2,唯一启动',isReadOnly:"y"},
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
		
           $('#myModal').modal({
			show : true,
			backdrop:false
		});
	});

	//取消
	$(".close-modal").on('click', function(){
       $('#myModal').modal('hide');
	});
});
</script>
</head>

<body class="">
	<div id="myModal" class="modal fade" style="z-index:99999"> 
		<div class="modal-dialog"> 
		    <div class="modal-content" > 
		     <div class="modal-header"> 
			      <button type="button" class="close close-modal" > <span aria-hidden="true">&times;</span><span class="sr-only">Close</span> </button> 
			      <h4 class="modal-title">程序上线</h4> 
		     </div> 
		     <div class="modal-body" id="upsertForm"></div> 
		     <div class="modal-footer">
				<button data-dismiss="modal" class="btn btn-default close-modal" type="button">取消</button> 
				<button id="dialog-ok" type="button" class="btn btn-primary">上线</button>
		     </div> 
		    </div>
		<!-- /.modal-content --> 
		</div> 
	<!-- /.modal-dialog --> 
	</div> 
	<div class="ui-layout-north">
		<nav class="navbar navbar-default" role="navigation"
			style="margin-bottom: 1px">
			<div class="container-fluid" style="padding-left: 0px">
				<div class="collapse navbar-collapse" style="padding-left: 0px">
					<div class="m-xs pull-left">
						<div id="show-content" data-toggle="buttons" class="btn-group">
							<label class="btn btn-sm btn-info active" id="flow">
								<input type="radio" name="flow" ><i
								class="fa fa-check text-active "></i> 流程
							</label> <label class="btn btn-sm btn-primary" id="proc">
								<input type="radio" name="proc" ><i
								class="fa fa-check text-active"></i> 任务
							</label> <label class="btn btn-sm btn-success" id="data">
								<input type="radio" name="data" ><i
								class="fa fa-check text-active"></i> 数据
							</label> <label class="btn btn-sm btn-warning" id="inter">
								<input type="radio" name="inter" ><i
								class="fa fa-check text-active"></i> 接口
							</label>
							<label class="btn btn-sm btn-info" id="scope">
								<input type="radio" name="scope" ><i
								class="fa fa-check text-active "></i> 指标组
							</label>
							<label class="btn btn-sm btn-info" id="kpi">
								<input type="radio" name="kpi" ><i
								class="fa fa-check text-active "></i> 指标
							</label>
						</div>
					</div>
					<form class="navbar-form navbar-left" role="search">
						<div class="form-group">
							<input id="search-text" type="text" class="form-control"
							 placeholder="输入名称/中文名称">
						</div>
						<button id="obj-search" type="button" class="btn btn-sm btn-default">
							<span class="fa fa-search"></span> 查找
						</button>
						<button id="query_schedule_info" type="button" class="btn btn-sm btn-warning">
							<span class="glyphicon glyphicon-eye-open"></span> 查询调度信息
						</button>
					</form>
				</div>
				<!-- /.navbar-collapse -->
			</div>
			<!-- /.container-fluid -->
		</nav>
	</div>
	<div class="ui-layout-west" style="overflow: auto;">
		<ul class="breadcrumb hide" style="margin-bottom: 1px; padding: 6px 0px;">
			<li style="cursor:pointer"><a class="  dropdown-toggle" data-toggle="dropdown" id="dbname_type"> 数据库<span
					class="caret hide"></span>
			</a>
				<ul class="dropdown-menu hide" role="menu">
					<li><a href="#"> 主题</a></li>
					<li><a href="#"> 层次</a></li>
					<li><a href="#"> 周期</a></li>
				</ul></li>
			<li style="cursor:pointer"><a class="dropdown-toggle" data-toggle="dropdown" id="level_type"> 层次<span
					class="caret hide"></span>
			</a>
				<ul class="dropdown-menu hide" role="menu">
					<li><a href="#"> 主题</a></li>
					<li><a href="#"> 层次</a></li>
					<li><a href="#"> 周期</a></li>
				</ul></li>
			<li style="cursor:pointer"><a class="  dropdown-toggle" data-toggle="dropdown" id="cycle_type"> 周期<span
					class="caret hide"></span>
			</a>
				<ul class="dropdown-menu hide" role="menu">
					<li><a href="#"> 主题</a></li>
					<li><a href="#"> 层次</a></li>
					<li><a href="#"> 周期</a></li>
				</ul></li>
		</ul>
		<div id="treeview6" class="test"></div>
	</div>
	<div class="ui-layout-center">
		<div id="tabpanel" style="margin-bottom: 120px;"></div>
		<ul id="tabpanel-page" class="pagination"></ul>
	</div>
</body>
</html>