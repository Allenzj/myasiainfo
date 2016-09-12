<!DOCTYPE html>
<html lang="zh" class="app">
<head>
	<meta charset="utf-8" />
	<title>大数据开放平台</title>   
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"  />  
	<link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-view/aijs/css/ai.css" type="text/css" rel="stylesheet"/>
	
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

	<script src="${mvcPath}/dacp-view/aijs/meta/metaStore.v1.js"></script>
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
.dian:hover, .dian:focus, .dian:active, .btn-default.active, .open .dropdown-toggle.dian {
    color: #FFF !important;
    background-color: #159253;
    border-color: #159253;
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

	var TEAMCODE = paramMap['TEAM_CODE'];
	
	if (typeof(TEAMCODE) == "undefined")
	{
		TEAMCODE="";
	}
	
	var page = {
		sql:"select * from (select SUBSTRING_INDEX(TOPICNAME, '|', 1) TOP1NAME ,SUBSTRING_INDEX(SUBSTRING_INDEX(TOPICNAME, '|', 2),'|',-1) TOP2NAME,SUBSTRING_INDEX(TOPICNAME, '|', -1) TOP3NAME,XMLID, {cols}, STATE, STATE_DATE, CURDUTYER,CREATER, TOPICNAME,CYCLETYPE FROM {table} where team_code like '%"+TEAMCODE+"%') tt where 1=1 {condi} order by STATE_DATE desc",
		treeSQL:"SELECT TOP1NAME,TOP2NAME,TOP3NAME,COUNT(1) NUM FROM (SELECT SUBSTRING_INDEX(TOPICNAME, '|', 1) top1name ,SUBSTRING_INDEX(SUBSTRING_INDEX(TOPICNAME, '|', 2),'|',-1) top2name,SUBSTRING_INDEX(TOPICNAME, '|', -1) top3name FROM {table}  WHERE team_code like '%"+TEAMCODE+"%' {condi}) tt GROUP BY top1name,top2name,top3name",
		cols:{
			flow:['FLOWCODE,FLOWNAME,AL_LEVEL','TRANSFLOW','AL_LEVEL','流程','DataFlow'],
			proc:['PROC_NAME,PROCCNNAME,LEVEL_VAL','PROC','LEVEL_VAL','任务','ETL'],
			data:['DATANAME,DATACNNAME,LEVEL_VAL','TABLEFILE','LEVEL_VAL','模型','Table']},
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
			self.switchAddBtn();
		},
		switchSQL:function(){
			var self = this;
			return this.sql.replace('{cols}',self.cols[self.type][0]).replace('{table}',self.cols[self.type][1]).replace('{condi}',self.searchCondi+self.nodeCondi);
		},
		switchTreeSQL:function(){
			var self = this;
			return this.treeSQL.replace(/{level}/g,self.cols[self.type][2]).replace('{table}',self.cols[self.type][1]).replace('{condi}',self.searchCondi+self.nodeCondi);
		},
		refresh:function(){
			var self = this;
			self.store.select(self.switchSQL());
			$('#treeview6').unbind();
			self.buildTreeView(self.switchTreeSQL());
			self.switchAddBtn();
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
				groupfield:"TOP1NAME,TOP2NAME,TOP3NAME",
				sql:sql,
				subtype:'grouptree'
				// ,renderer:function(text){
				// 	var t=text||'';
				// 	var arr=text.split('|');
				// 	return arr[arr.length-1]||text;
				// }
			});
		},
		buildGrid:function(){
			var self = this;
			var _rowdblClickFunc = function(val,rowdata){
				if(rowdata){
					window.open("/" + contextPath + "/ftl/task/WizCre"+self.cols[self.type][4]+"?TEAM_CODE="+TEAMCODE+"&OBJNAME="+rowdata.get('XMLID'));
				}
				return false;
			};
			var renderCycle = function(record, val){
				var res = '--';val = val||res;
				switch(val.trim()){
					case 'day':res='日';break;
					case 'month':res='月';break;
					case 'hour':res='小时';break;
					case 'minute':res='分钟';break;
					case 'year':res='年';break;
					default:res=val;break;
				}
				return res;
			};
			var flowStateRender = function(record, val){
				var res = '--';val = val||res;
				switch(val.toString().trim().toUpperCase()){
					case 'NEW':res='新建';break;
					case 'UNPUBLISH':res='待发布';break;
					case 'INVALID':res='失效';break;
					case 'VALID':res='生效';break;
					case 'PUBLISHED':res='已发布';break;
					case 'CHECK-OK':res='审批通过';break;
					case 'CHECK-FAIL':res='申请驳回';break;
					case '-1':res='申请驳回';break;
					case '-2':res='上线驳回';break;
					case '99':res='审批通过';break;
					case '1':res='已上线';break;
					default:res=val;break;
				}
				return res;
			};
			var flowUserName = ai.getStoreData("select USERNAME,USECNNAME from metauser");
			var getUserCNName = function(record,val){
				for (var i =0; i < flowUserName.length; i++) {
					if (val == flowUserName[i]["USERNAME"]) {
						return flowUserName[i]["USECNNAME"]
					};
				};
				return val;
			};
			var columns = [
				{header: "主题", width:74, dataIndex: 'TOPICNAME'},
				{header: "周期", width:74, dataIndex: 'CYCLETYPE' ,render:renderCycle},
				{header: "状态", dataIndex: 'STATE',render:flowStateRender},
				{header: "状态日期",dataIndex: 'STATE_DATE'},
				{header: "当前负责人", dataIndex: 'CURDUTYER',render:getUserCNName}
			];
			var _cols = {
				flow:[{header:"名称",dataIndex: 'FLOWCODE',  sortable: true,maxLength:20},
					{header:"中文名称",dataIndex: 'FLOWNAME',  sortable: true,maxLength:20}],
				proc:[{header:"名称",dataIndex: 'PROC_NAME', sortable: true,maxLength:20},
					{header:"中文名称",dataIndex: 'PROCCNNAME',  sortable: true,maxLength:20},
					{header: "层次", width:74, dataIndex: 'LEVEL_VAL'}],
				data:[{header:"名称",dataIndex: 'DATANAME',  sortable: true,maxLength:20},
					{header:"中文名称",dataIndex: 'DATACNNAME',  sortable: true,maxLength:20},
					{header: "层次", width:74, dataIndex: 'LEVEL_VAL'}]
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
		},
		switchAddBtn:function(){
			var self = this;
			$("#cre-ojb").empty()
			.append('<span class="fa fa-plus"></span> 新建'+self.cols[self.type][3])
			.off("click").on("click",function(){
				window.open("${mvcPath}/ftl/task/WizCre"+self.cols[self.type][4]+"?TEAM_CODE="+TEAMCODE);
			});
		}
	};

	page.init();

	$('#show-content .btn').on("click",function(){
		page.nodeCondi=page.searchCondi="";
		page.type = $(this).attr("id");
		page.refresh();
	});
	$('#obj-search').on("click",function(){
		var _searchText = $(this).parent().find('input#search-text').val().trim();
		var condis = {
			flow:['FLOWCODE','FLOWNAME'],
			proc:['PROC_NAME','PROCCNNAME'],
			data:['DATANAME','DATACNNAME']
		}
		var othersCondition = "";
		var cond = " and ({code} like '%"+_searchText+"%' or {name} like '%"+_searchText+"%' {others}) ";
		cond = cond.replace('{code}',condis[page.type][0]).replace('{name}',condis[page.type][1]);
		if(page.type == "flow" && _searchText != ""){
			othersCondition = " or flowcode in (SELECT FLOWCODE FROM transdatamap_design WHERE source LIKE '%" + _searchText + "%' OR target LIKE '%" + _searchText + "%' GROUP BY FLOWCODE) or CURDUTYER IN (SELECT USECNNAME FROM metauser WHERE USERNAME LIKE '%"+ _searchText + "%' OR USECNNAME LIKE '%"+ _searchText + "%' UNION SELECT USERNAME FROM metauser  WHERE USERNAME LIKE '%"+ _searchText + "%' OR USECNNAME LIKE '%"+ _searchText + "%' )";
		}
		cond = cond.replace('{others}',othersCondition);
		page.searchCondi = cond;
		page.nodeCondi = "";
		page.refresh();
	});
	
	$('#search-text').on('keydown',function(e){
		if(e.keyCode == 13){
			$('#obj-search').click();
		}
	});
});
</script>
</head>

<body class="">
	<div class="ui-layout-north">
		<nav class="navbar navbar-default" role="navigation"
			style="margin-bottom: 1px">
			<div class="container-fluid" style="padding-left: 0px">
				<div class="collapse navbar-collapse" style="padding-left: 0px">
					<div class="m-xs pull-left hide">
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
							</label>
						</div>
					</div>
					<form class="navbar-form navbar-left" role="search">
						<div class="form-group">
							<input id="search-text" type="text" class="form-control"
							 placeholder="输入名称/中文名称/当前负责人">
							 <input id="search-text1" type="text" class="form-control"
							 placeholder=""  style = "display:none">
						</div>
						<button id="obj-search" type="button" class="btn btn-sm btn-default">
							<span class="fa fa-search"></span> 查找
						</button>
						<div class="btn-group hide" style="margin-left: 10px">
							<button type="button" class="btn btn-sm dropdown-toggle" id="meta-data">
									<span class="glyphicon glyphicon-log-out"></span> 元数据
							</button>
						</div>
						<button id="cre-ojb" type="button" class="btn btn-sm dian btn-default">
							<span class="fa fa-plus"></span> 新建
						</button>
						<button id="edit-obj" type="button" class="btn btn-sm  btn-default hide">
							<span class="fa fa-wrench"></span> 修改
						</button>
						<button id="del-obj" type="button" class="btn btn-sm  btn-default hide">
							<span class="fa fa-pencil"></span> 删除
						</button>
					</form>
				</div>
			</div>
		</nav>
	</div>
	<div class="ui-layout-west" style="overflow: auto;">
		<ul class="breadcrumb hide" style="margin-bottom: 1px; padding: 6px 0px;">
			<li style="cursor:pointer"><a class="  dropdown-toggle" data-toggle="dropdown" id="dbname_type"> 主题<span class="caret hide"></span>
			</a>
				<ul class="dropdown-menu hide" role="menu">
					<li><a href="#"> 主题</a></li>
					<li><a href="#"> 层次</a></li>
					<li><a href="#"> 周期</a></li>
				</ul></li>
			<li style="cursor:pointer"><a class="dropdown-toggle" data-toggle="dropdown" id="level_type"> 层次<span class="caret hide"></span>
			</a>
				<ul class="dropdown-menu hide" role="menu">
					<li><a href="#"> 主题</a></li>
					<li><a href="#"> 层次</a></li>
					<li><a href="#"> 周期</a></li>
				</ul></li>
			<li style="cursor:pointer"><a class="  dropdown-toggle" data-toggle="dropdown" id="cycle_type"> 周期<span class="caret hide"></span>
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
		<div id="tabpanel" style=""></div>
		<ul id="tabpanel-page" class="pagination"></ul>
	</div>
</body>
</html>