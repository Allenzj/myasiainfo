<!DOCTYPE html>
<html lang="zh" class="app">
<head>
	<meta charset="utf-8" />
	<title>大数据开放平台</title>   
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"  />  
	<link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-view/aijs/css/ai.css" type="text/css" rel="stylesheet"  />
	<link href="${mvcPath}/dacp-view/ve/css/dacp-ve-js-1.0.css" type="text/css" rel="stylesheet" media="screen"/>

<script type="text/javascript" src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/underscore/underscore-min.js"></script>
<script src="${mvcPath}/dacp-lib/backbone/backbone-min.js" type="text/javascript"></script>
<script src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>
<script src="${mvcPath}/dacp-lib/datepicker/bootstrap-datepicker.js" ></script>
<script src="${mvcPath}/dacp-lib/datepicker/jquery.simpledate.js"></script>
<script src="${mvcPath}/dacp-lib/datepicker/jquery.pst-area-control.js" ></script>
<script src="${mvcPath}/dacp-lib/jquery-plugins/jquery.layout-latest.js"> </script>
<script src="${mvcPath}/dacp-lib/jquery-plugins/bootstrap-treeview.min.js"> </script>
<script src="${mvcPath}/dacp-view/ve/js/dacp-ve-js-1.0.js" type="text/javascript" charset="utf-8"></script>

<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>

<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>

<script src="${mvcPath}/dacp-view/aijs/js/public/js/ai.treeview.js"></script>

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
a{
	cursor:pointer;
}

.ui-layout-north {
	z-index: 10000 !important;
}

.ui-layout-center {
	overflow: hidden;
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
.actionlist{
	border:1px solid transparent;
	background-color: #eee;
}
#myModal{
	z-index:10001;
}
</style>
<script>
var proc_state="";
var run_freq="";
var trigger_type="";
var model_type="proc";//模型类型
var _tSql="";
var _treeSql="";
var searchCondi="";
var _store="";

var getQueryCondition = function(type){
	var _searchText = $("#search-text input").val().trim();
	var run_freq = $("#run_freq_select select").val();
	var state = $("#proc_state_select select").val();
	var trigger_type = $("#trigger_type_select select").val();
	var _searchCondi="";
	switch(type){
		case "proc":
			_searchCondi =_searchText.length>0 ? " AND a.proc_name LIKE '%"+_searchText+"%'":"";
		    _searchCondi += trigger_type.length>0 ? " AND trigger_type='"+trigger_type+"'":"";
		    _searchCondi += run_freq.length>0 ? " AND run_freq='"+run_freq+"'":"";
		    _searchCondi += state.length>0 ? " AND state='"+state+"'":"";
			break;
		case "data":
			_searchCondi =_searchText.length>0 ? " AND dataname LIKE '%"+_searchText+"%'":"";
		    _searchCondi += run_freq.length>0 ? " AND cycletype='"+run_freq+"'":"";
			break;
		case "inter":
			_searchCondi =_searchText.length>0 ? " AND (fullintercode LIKE '%"+_searchText+"%' or inter_name like '%"+_searchText+"%')":"";
			break;
		default:
			break;
	}
    return _searchCondi;
};

//查询面板
var _queryPanel = new ve.FormWidget({
	config:{
		"class":"form",
		"formClass":"form-inline",
		"items": [
            {
				"type":"combox",
				"id":"trigger_type_select",
				"fieldLabel":"",
				"select":[{'key':'','value':'触发类型'},
				          {'key':'0','value':'时间触发'},
						  {'key':'1','value':'事件触发'}],
				"style": "min-width:60px;width:100px;"
			},
            {
				"type":"combox",
				"id":"proc_state_select",
				"fieldLabel":"",
				"select":[{'key':'','value':'程序状态'},
				          {'key':'UNPUBLISH','value':'待发布'},
				          {'key':'VALID','value':'生效'},
						  {'key':'INVALID','value':'失效'}],
				"style": "min-width:60px;width:100px;"
			},
            {
				"type":"combox",
				"id":"run_freq_select",
				"fieldLabel":"",
				"select":[{'key':'','value':'周期'},
				          {'key':'year','value':'年'},
				          {'key':'month','value':'月'},
				          {'key':'day','value':'日'},
				          {'key':'hour','value':'时'},
						  {'key':'minute','value':'分'}],
				"style": "min-width:60px;width:70px;"
			},
			{
				"type": "text",
				"id":"search-text",
				"fieldLabel":"",
				"placeholder":"输入名称，中文名",
				"className":"form-control",
				"style": "min-width:80px;width:180px;"
			},
			{
				"id":"search",
				"value":"查询",
				"type":"button",
				"className":"btn btn-sm ",
			},
			{
				"id":"op_online",
				"value":"上线",
				"type":"button",
				"className":"btn btn-sm btn-success",
			},
			{
				"id":"op_offline",
				"value":"下线",
				"type":"button",
				"className":"btn btn-sm btn-danger",
			}/*,
			{
				"id":"search",
				"value":"血缘分析",
				"type":"button",
				"className":"actionlist btn btn-sm ",
			},
			{
				"id":"search",
				"value":"影响分析",
				"type":"button",
				"className":"actionlist btn btn-sm ",
			}*/
		]
	}
});

//左边树
var buildTreeView = function(sql){
	var groupfield="STATE";
	switch(model_type){
		case "proc":
		case "data":
			groupfield="STATE";
			break;
		case "inter":
			groupfield="STATUS";
			break;
		default:
			break;
	}
	$('#treeview6').treeview({
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
				if(str.split(":")[1]=='未知') subWhere = "("+str.split(":")[0] +" is null or "+str.split(":")[0] +"='') ";
				if(where) where += " and "+ subWhere;
				else where=subWhere;
			}
			topicCondi = where.length>0?(" and " + where):"";
			_store.select(_tSql.replace("{condi}",topicCondi + searchCondi));
		},
		groupfield:groupfield,
		sql:sql,
		subtype: 'grouptree',
		renderer: function(val,node){
			var res = '未知';
			val=val||res;
			switch(val.toString().trim().toUpperCase()){
				case 'NEW':res='新建';break;
				case 'UNPUBLISH':res='待发布';break;
				case 'INVALID':res='失效';break;
				case 'VALID':res='生效';break;
				case 'PUBLISHED':res='已发布';break;
				case 'CHECK-OK':res='审批通过';break;
				case 'CHECK-FAIL':res='申请驳回';break;
				case 'OFF-APPLY':res='下线申请中';break;
				case 'OFF-CHECK-OK':res='下线审批通过';break;
				case 'OFF-CHECK-FAIL':res='下线申请驳回';break;
				case '-1':res='申请驳回';break;
				case '-2':res='上线驳回';break;
				case '99':res='审批通过';break;
				case '1':res='已上线';break;
				default:res=val;break;
			}
			return res;
		}
	});
};

$(document).ready(function() {
	$("#search-text").on("keydown",function(e){
		if(e.keyCode == 13){ 
			document.getElementById("search").click();
		} 
	});
	var searchCondi = "";
	var curTeamCode = _UserInfo['groupCode'];
	var curDisplayType="grid";
	var topicCondi='';var searchCondi='';
	var toggleButtons = '<div class="btnCenter"></div>'
		+ '<div class="btnBoth"></div>'
		+ '<div class="btnWest"></div>';
	$('body').layout({
    	sizable: false,	
    	animatePaneSizing: true ,
		fxSpeed: 'slow',	
		spacing_open: 0,
		spacing_closed:	0,
		west__spacing_closed: 8,
		west__spacing_open: 8,
		west__togglerLength_closed: 105,
		west__togglerLength_open: 105,
		west__togglerContent_closed: toggleButtons,
		west__togglerContent_open: toggleButtons,
		west__size: 205,
		north__size: 50
	});
	//渲染查询面板	
	_queryPanel.$el=$("#queryPanel");	
	_queryPanel.render();
	
	_tSql = "SELECT "+  
       "a.xmlid,a.proc_name,proccnname,state,creater,curdutyer,team_code,topicname,level_val,cycletype,"+
       "platform,agent_code,trigger_type,eff_time,exp_time,cron_exp,muti_run_flag,"+
       "date_args,exec_class,alarm_class,on_focus,redo_interval,pri_level,run_freq,"+
       "redo_num,resouce_level from proc a left join proc_schedule_info b on a.proc_name=b.proc_name where 1=1 {condi} order by eff_date desc"; 
	
    _store = new AI.JsonStore({
		sql:_tSql.replace("{condi}",""),
		pageSize:15,
		key:"PROC_NAME",
		table:"PROC"
	});
	
	
	_treeSql  = "SELECT STATE, CYCLETYPE, COUNT(1) NUM FROM PROC a left  join proc_schedule_info b on a.PROC_NAME = b.proc_name where 1=1 {condi} GROUP BY STATE, CYCLETYPE"
	buildTreeView(_treeSql.replace("{condi}",''));
	
	var _rowClickFunc = function (rowdata){
		curdata= rowdata;
	};
	var _rowdblClickFunc = function(val,rowdata){
		if(model_type=="proc"){
			showInfoDialog(true);
		}
		return false;
	};
	var procUserName = ai.getStoreData("select USERNAME,USECNNAME from metauser");
	var getUserCNName = function(record,val){
		for (var i =0; i < procUserName.length; i++) {
			if (val == procUserName[i]["USERNAME"]) {
				return procUserName[i]["USECNNAME"]
			};
		};
		return val;
	};
	var levelCNval=ai.getStoreData("select rowcode,rowname from metaedimdef where dimcode='DIM_DATALEVEL'");
	var renderLevel = function(record,val){
		for (var i =0; i < levelCNval.length; i++) {
			if (val == levelCNval[i]["ROWCODE"]) {
				return levelCNval[i]["ROWNAME"]
			};
		};
		return val;
	};
	
	var procColumns = [
   		{header: "名称", dataIndex: 'PROC_NAME'},
   		{header: "中文名", dataIndex: 'PROCCNNAME'},
   		{header: "数据库", dataIndex: 'DBNAME'},
   		{header: "创建人", dataIndex: 'CREATER',render:getUserCNName},
   		{header: "负责人", dataIndex: 'CURDUTYER',render:getUserCNName},
   		{header: "状态", dataIndex: 'STATE',render:function(record, val){
   			var res = '--';val = ""+val||res;
   			switch(val.trim().toUpperCase()){
	   			case 'NEW':res='新建';break;
				case 'UNPUBLISH':res='待发布';break;
				case 'INVALID':res='失效';break;
				case 'VALID':res='生效';break;
				case 'PUBLISHED':res='已发布';break;
				case 'CHECK-OK':res='审批通过';break;
				case 'CHECK-FAIL':res='申请驳回';break;
				case 'OFF-APPLY':res='下线申请中';break;
				case 'OFF-CHECK-OK':res='下线审批通过';break;
				case 'OFF-CHECK-FAIL':res='下线申请驳回';break;
				case '-1':res='申请驳回';break;
				case '-2':res='上线驳回';break;
				case '99':res='审批通过';break;
				case '1':res='已上线';break;
				default:res=val;break;
   			}
   			return res;
   		}},
   		{header: "周期", dataIndex: 'CYCLETYPE',
   			render:function(record,val){
   				var res='--';
   				switch(val){
   					case "minute":res="分钟";break;
   					case "hour":res="小时";break;
   					case "day":res="日";break;
   					case "month":res="月";break;
   					case "year":res="年";break;
   					default:break;
   				}
   				return res
   			}
   		}
   	];
	var _grid = new AI.Grid({
		store:_store,
		containerId:'tabpanel',
		pageSize:20,
		showcheck:true,
		rowclick:_rowClickFunc,
		celldblclick:_rowdblClickFunc,
		columns:procColumns
	});

	var switchContent = function(id,condi){
		buildTreeView(_treeSql.replace("{condi}",condi));
		_store.select(_tSql.replace("{condi}",condi));
		if(_store.count == 0) {
			$("#undefined_page").html('<li><a class=" pull-center">记录总数:0</a></li>');
		}
	};
	
	//查询
	$('#search').on('click',function(e){
		var _searchText = $(e.currentTarget).parent().find('#search-text input').val().trim();
		searchCondi = getQueryCondition(model_type);
		switchContent(model_type,searchCondi);
	});
	
	var insertData = "";
	var isUpdate=true;
	var ds_mydata="";
	var curdata="";//勾选数据行
	function showInfoDialog(isReadOnly){
		var selected= _grid.getCheckedRows();
		if(!isReadOnly && selected && selected.length!=1){
			alert('只能选中一行！');
			return false;
		}
		_store.curRecord = selected[0];
		$("#upsertForm").empty();
		var formcfg = {
			id : 'form',
			store : _store,
			containerId : 'upsertForm',
			items : [ 
			       {type : 'text',label : '程序名称',fieldName : 'PROC_NAME',isReadOnly:"y",notNull:'N'},
			       {type : 'date',label : '上线时间',fieldName : 'EFF_TIME',notNull:'N',value:new Date().format('yyyy-mm-dd')}, 
			       {type : 'date',label : '下线时间',fieldName : 'EXP_TIME',notNull:'N',value:new Date("9999/12/31").format('yyyy-mm-dd')},
			       {type : 'combox',label : '资源组',fieldName : 'PLATFORM',storesql:"SELECT PLATFORM K, PLATFORM_CNNAME V  FROM PROC_SCHEDULE_PLATFORM",checkItems: 'AGENT_CODE',notNull:'N'},
				   {type : 'combox',label : 'AGENT',fieldName : 'AGENT_CODE',storesql:"select AGENT_NAME K,HOST_NAME V  from AIETL_AGENTNODE where TASK_TYPE='TASK' and PLATFORM='{val}'"},
				   {type : 'combox',label : '优先级',fieldName : 'PRI_LEVEL',storesql:'20,高|15,高于正常|10,正常|5,低于正常|1,低',notNull:'N',value:10},
				   {type : 'radio-custom',label : '运行模式',fieldName : 'MUTI_RUN_FLAG',storesql:'0,顺序启动|1,多重启动|2,唯一启动',notNull:'N'},  
				   {type:  "radio-custom", label: "触发类型", fieldName: "TRIGGER_TYPE",storesql:'0,时间触发|1,事件触发'},
			       {type : 'text-button',label : 'cron表达式',fieldName : 'CRON_EXP',isReadOnly:"y"}, 
			       {type : 'text',label : '日期偏移量',fieldName : 'DATE_ARGS'}
			 ],
			fieldChange: function(fieldName, newVal){
				if(fieldName=='TRIGGER_TYPE'){
	            	if(newVal==0){
	            		$("#CRON_EXP").parent().parent().show();
	            		$("#DATE_ARGS").parent().parent().show();
	            		
	            	}else{
	            		$("#CRON_EXP").parent().parent().hide();
	            		$("#DATE_ARGS").parent().parent().hide();
	            	}
				}						           
			}
		};

		if(isReadOnly){
			formcfg={
				id : 'form',
				store : _store,
				containerId : 'upsertForm',
				items : [ 
				       {type : 'text',label : '程序名称',fieldName : 'PROC_NAME',isReadOnly:"y",notNull:'N'},
				       {type : 'text',label : '上线时间',fieldName : 'EFF_TIME',isReadOnly:"y"}, 
				       {type : 'text',label : '下线时间',fieldName : 'EXP_TIME',isReadOnly:"y"},
				       {type : 'text',label : '资源组',fieldName : 'PLATFORM',isReadOnly:"y"},
					   {type : 'text',label : 'AGENT',fieldName : 'AGENT_CODE',isReadOnly:"y"},
					   {type : 'text',label : '优先级',fieldName : 'PRI_LEVEL',isReadOnly:"y"},
					   {type : 'radio-custom',label : '运行模式',fieldName : 'MUTI_RUN_FLAG',storesql:'0,顺序启动|1,多重启动|2,唯一启动',isReadOnly:"y"},
					   {type:  "radio-custom", label: "触发类型", fieldName: "TRIGGER_TYPE",storesql:'0,时间触发|1,事件触发',isReadOnly:"y"},
				       {type : 'text',label : 'cron表达式',fieldName : 'CRON_EXP',isReadOnly:"y"}, 
				       {type : 'text',label : '日期偏移量',fieldName : 'DATE_ARGS',isReadOnly:"y"}
				 ]
			}
			$("#dialog-ok").hide();
		}else{
			$("#dialog-ok").show();
		}
				
		var from = new AI.Form(formcfg);
		$("#CRON_EXP_1").click(function() {
			var cycle = selected[0].get('CYCLETYPE');
			showDailog(cycle);
		});
		$("#CRON_EXP").parent().parent().hide();
		$("#DATE_ARGS").parent().parent().hide();    		
		$(".datepicker").css("z-index", 99999);
		
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
		$('#myModal').modal({show : true,backdrop:false});
	}

	//上线
	$("#op_online").click(function() {
		var selected= _grid.getCheckedRows();
		if(!selected || selected.length==0){
			alert('没有选中项！');
			return false;
		}
		if (model_type=="proc"){
			showInfoDialog(false);
			
		}else{
			if(confirm("确定要上线所选项吗？")){
				var xmlids ="";
				for (var i = 0; i < selected.length; i++) {
					xmlids +="'"+selected[0].get('XMLID')+"',";
				};
				xmlids=xmlids.substring(0,xmlids.length-1);
				var sql="";
				if(model_type=="inter"){
					sql="update inter_cfg set STATUS=1 where xmlid in ("+xmlids+")";
				
				}else if(model_type=="data"){
					sql="update tablefile set state='已上线' where xmlid in ("+xmlids+")";
				}
				ai.executeSQL(sql);
				
				var result=dataMigrate(selected);
				if(result==false){
					//上线失败还原状态
					if(model_type=="inter"){
						sql="update inter_cfg set STATUS=-2 where xmlid in ("+xmlids+")";
					
					}else if(model_type=="data"){
						sql="update tablefile set state='新建' where xmlid in ("+xmlids+")";
					}
					ai.executeSQL(sql);
					alert("上线失败！");
				}else{
					alert("上线成功！");
				}
			}
		}
	});
	
	//下线
	$("#op_offline").click(function() {
		var selected= _grid.getCheckedRows();
		if(!selected || selected.length==0){
			alert('没有选中项！');
			return false;
		}else{
			if(confirm("确定要下线所选项吗？")){
				var procs ="";
				for (var i = 0; i < selected.length; i++) {
					var state = selected[i].get('STATE');
					var procName = selected[i].get("PROC_NAME");
					if(state && procName && (state.toUpperCase()==="VALID"|| state.toUpperCase()=="PUBLISHED")){
						procs +="'"+procName+"',";
					}else{
						alert("选中项中包含未上线任务！");
						return false;
					}
				};
				procs=procs.substring(0,procs.length-1);
				//修改exp_time
				var _date = new Date();
				effDate = _date.format("yyyy-mm-dd hh:mm:ss");
				_date.setDate(_date.getDate()-1);
				dateStr = _date.format('yyyy-mm-dd');
				var sql1="update proc_schedule_info set EXP_TIME='"+dateStr+"' where proc_name in ("+procs+")";
				var sql2="update proc set eff_date='"+effDate+"',state='PUBLISHED' where proc_name in ("+procs+")";
				ai.executeSQL(sql1,false,"METADBS");
				ai.executeSQL(sql2,false,"METADBS");
				//同步数据
				sql2="update proc set eff_date='"+effDate+"',state='INVALID' where proc_name in ("+procs+")";
				ai.executeSQL(sql1,false,"METADB");
				ai.executeSQL(sql2,false,"METADB");
				_store.select();
			}
		}
	});	
	
	//血缘分析，影响分析
	$(".actionlist").click(function(){
		if(curdata){
			var objname=curdata.DATANAME;
			var actionname = $(this).text();
			var _url="";
			var bindCarouselWithProc = function(tabName,store,objname,title){
				var $el = parent.$('#panel1');
				var pushTab = function(dir){
					curIndex = parseInt(store.curIndex);
					if(dir==='left'){
						var _index = curIndex==0?store.getCount()-1:curIndex-1;
					}else{
						var _index = curIndex==store.getCount()-1?0:curIndex+1;
					}
					var r = store.getAt(_index);
					parent.openTableInfo(tabName,title.replace('{name}',r.get(objname).toUpperCase()),r.get("PROC_NAME"),true);
					store.curIndex = _index;
				};
				$el.on("push-left-"+tabName,function(){
					pushTab('left');
				});
				$el.on("push-right-"+tabName,function(){
					pushTab('right');
				});
			};
			var _checkLength = function(arr){
				if(arr.length!=1) alert('只能选中一行！');
				return arr.length===1?true:false;
			}
		
			var viewMetaEffect = function(name){
				var tabname = name==='血缘分析'?"ana-Before":"ana-After";
				if(_checkLength(_grid.getCheckedRows())){
					var _index = _grid.tableEl.find('.ai-grid-body-check:checked').attr('rowindex');
					var r = _store.getAt(_index);
					_store.curIndex = _index;
					var _title ="程序:"+r.get('PROC_NAME').toUpperCase()+" "+name;
					parent.openTableInfo(tabname,_title,r.get('PROC_NAME'),true);
					bindCarouselWithProc(tabname,_store,'PROC_NAME',"程序:"+'{name} '+name);
				}
			};
			if(actionname=='血缘分析') viewMetaEffect("血缘分析");
			else if(actionname=='影响分析') viewMetaEffect("影响分析");
			if(_url)window.open(_url);
		}else{
			alert("请先选取一行！");
		}
		return false;
	});
	
	function checkForm(){
		var triggerType = getCheckedValue("TRIGGER_TYPE")
		var mutiRunFlag = getCheckedValue("MUTI_RUN_FLAG")
		var effTime = $("#EFF_TIME").val()
		var expTime = $("#EXP_TIME").val()
		var cronExp = $("#CRON_EXP").val()
		var dateArgs = $("#DATE_ARGS").val().trim()
		var platform = $("#PLATFORM").val()
		var today= new Date()
		var currentDate = today.getFullYear() + "-" 
						+ (today.getMonth()+1<10 ? "0"+(today.getMonth()+1) : (today.getMonth()+1)) + "-" 
						+ (today.getDate()<10 ? "0" + today.getDate() : today.getDate())
		
		if(!effTime){
			alert("上线时间不能为空！");
			return false;
		}if(!expTime){
			alert("下线时间不能为空！");
			return false;
		}else if(!mutiRunFlag){
			alert("请选择运行模式！");
			return false;
		}else if(!platform){
			alert("请选择资源组！");
			return false;
		}else if(effTime && expTime && effTime > expTime){
			alert("下线时间不得早于上线时间！");
			return false;				
		}else if(expTime && expTime < currentDate){
			alert("下线时间不得早于当前时间！");
			return false;
		}else if(triggerType==="0"){
			if(cronExp==""){
				alert("cron表达式不能为空！")
				return false;
			}else if(dateArgs==""){
				alert("日期偏移量不能为空！")
				return false;
			}else if(! /^(\d|1[0-5])$/.test(dateArgs)){				
				alert("日期偏移量只允许0~15之间的整数数字！")
				return false;
			}else {
				return true
			}
		}else{
			return true
		}
	}
	
	//确认上线
	$("#dialog-ok").click(function() {		
		if(!checkForm()){
			return false;
		}
		var selected= _grid.getCheckedRows();
		var infoStore=new AI.JsonStore({
			sql : "select * from PROC_SCHEDULE_INFO where PROC_NAME='"+selected[0].get('PROC_NAME')+"'",
			key : "PROC_NAME",
			pageSize : 15,
			table : "PROC_SCHEDULE_INFO"
		});
		var _mydata =[];
		var isNew = false;
		if(infoStore.getCount() ==0 ){
			isNew = true;
			_mydata=infoStore.getNewRecord();
			
			_mydata.set('PROC_NAME',selected[0].get('PROC_NAME'));
			_mydata.set("RUN_FREQ", selected[0].get('CYCLETYPE'));
			_mydata.set("RESOUCE_LEVEL", 1);
			_mydata.set("REDO_NUM", 3);
			_mydata.set("REDO_INTERVAL", 5);
			_mydata.set("ALARM_CLASS", "9997");
		    _mydata.set("EXEC_CLASS", "9998");
		    _mydata.set("DURA_MAX", 1440);
		    _mydata.set("ON_FOCUS", 0);
		}else{
			isNew = false;
			_mydata =infoStore.getAt(0);
		}
		_mydata.set('EFF_TIME',$("#EFF_TIME").val());
		_mydata.set('EXP_TIME',$("#EXP_TIME").val());
		_mydata.set('PLATFORM',$("#PLATFORM").val());
		_mydata.set('AGENT_CODE',$("#AGENT_CODE").val());
		_mydata.set('PRI_LEVEL',$("#PRI_LEVEL").val());
		if(getCheckedValue("TRIGGER_TYPE")) {
			_mydata.set('TRIGGER_TYPE',getCheckedValue("TRIGGER_TYPE"));
		}
		if(getCheckedValue("MUTI_RUN_FLAG")){
			_mydata.set('MUTI_RUN_FLAG',getCheckedValue("MUTI_RUN_FLAG"));
		} 
		if(getCheckedValue("TRIGGER_TYPE")==0){			
			_mydata.set('CRON_EXP',$("#CRON_EXP").val());
			_mydata.set('DATE_ARGS',$("#DATE_ARGS").val().trim());
		}else{
			_mydata.set('CRON_EXP',null);
			_mydata.set('DATE_ARGS',1);				
		}
		var curProc = _store.getRecordByKey(selected[0].get('PROC_NAME'));
		curProc.set('STATE',"PUBLISHED");
		var effDate = new Date();
		curProc.set('EFF_DATE',effDate.format("yyyy-mm-dd hh:mm:ss"));
		if(isNew){
			infoStore.add(_mydata);
		}
		var rs = _store.commit(false);
		var rsJson =  $.parseJSON(rs);
		var rs2 = infoStore.commit(false);
		var rsJson2 =  $.parseJSON(rs2);

		if(rsJson.success && rsJson2.success){
			var result=dataMigrate(selected);
			if(result){
				alert("上线成功！");
			}else{
				_mydata.set("STATE","UNPUBLISH");
				var rs = infoStore.commit(false);
				alert("上线失败！");
			}
		}
		_store.select();
		$('#myModal').modal('hide');
	});
	
	//取消
	$(".close-modal").click(function(){
       $('#myModal').modal('hide');
	});
	
	//tab切换
	$("#show-content label").click(function(){
		switch(this.id){
			case "proc":
				model_type="proc";
				$("#op_offline").show();
				$("#run_freq_select").show();
				$("#trigger_type_select").show();
				$("#proc_state_select").show();
				_tSql = "SELECT "+  
				       "a.xmlid,a.proc_name,proccnname,state,creater,curdutyer,team_code,topicname,level_val,cycletype,"+
				       "platform,agent_code,trigger_type,eff_time,exp_time,cron_exp,muti_run_flag,"+
				       "date_args,exec_class,alarm_class,on_focus,redo_interval,pri_level,run_freq,"+
				       "redo_num,resouce_level from proc a left join proc_schedule_info b on a.proc_name=b.proc_name where 1=1 {condi} order by eff_date desc"; 
				_treeSql  = "SELECT STATE, CYCLETYPE, COUNT(1) NUM FROM PROC a left  join proc_schedule_info b on a.PROC_NAME = b.proc_name where 1=1 {condi} GROUP BY STATE, CYCLETYPE";
				break;
			case "inter":
				model_type="inter";
				$("#op_offline").hide();
				$("#run_freq_select").hide();
				$("#trigger_type_select").hide();
				$("#proc_state_select").hide();
				_treeSql=" SELECT status,COUNT(1) NUM FROM inter_cfg where 1=1 {condi} GROUP BY status ";
				_tSql=" SELECT xmlid,fullintercode proc_name,inter_name proccnname,STATUS state,creater,curdutyer,inter_cycle cycletype FROM inter_cfg WHERE 1=1 {condi} ORDER BY active_time DESC ";
				break;
			case "data":
				model_type="data";
				$("#op_offline").hide();
				$("#run_freq_select").show();
				$("#trigger_type_select").hide();
				$("#proc_state_select").hide();
				_treeSql=" SELECT state,COUNT(1) NUM FROM tablefile where 1=1 {condi} GROUP BY state ";
				_tSql=" SELECT xmlid,dataname proc_name,datacnname proccnname,state,creater,curdutyer,cycletype ,dbname FROM tablefile WHERE 1=1 {condi} ORDER BY eff_date DESC ";
				break;
			default:
				break;
		}
		
		reloadData();
		
	});

	function reloadData(){
		searchCondi = getQueryCondition(model_type);
		switchContent(model_type,searchCondi);
	}

});

var dataMigrate=function(selected){
	var procSql="select * from proc where xmlid='"+selected[0].get('XMLID')+"'";
	var schdSql="select * from proc_schedule_info where proc_name='"+selected[0].get('PROC_NAME')+"'";
	var stepSql="select * from proc_step where proc_name='"+selected[0].get('PROC_NAME')+"'";
	var mapSql="select * from transdatamap_design where TRANSNAME='"+selected[0].get('PROC_NAME')+"'";
	var tabSql="select * from tablefile where xmlid='"+selected[0].get('XMLID')+"'";
	var colSql="select * from COLUMN_VAL where xmlid='"+selected[0].get('XMLID')+"'";
	var interSql="select * from inter_cfg where xmlid='"+selected[0].get('XMLID')+"'";

	var tabs={
		proc:[[mapSql,'TRANSDATAMAP_DESIGN'],[schdSql,'PROC_SCHEDULE_INFO'],[stepSql,'PROC_STEP'],[procSql,'PROC']],
		data:[[tabSql,'TABLEFILE'],[colSql,'COLUMN_VAL']],
		inter:[[interSql,'INTER_CFG']]
	};
	var migCell=function(sql,tab){
		var data={
			sourceDs:"METADB",
			targetDs:"METADBS",
			migDataSql:sql,
			migInTabname:tab,
			migInColumns:""
		};
		var rs = $.ajax({
			url:'/'+contextPath+'/dataMigration',
			data:data,
			async: false
		}).responseText;
		return rs;
	};
	var flag = false;
	var transactValidate = function(result,callback){
		if(result.success&&(result.success==true||result.success=='true')){
			callback();
		}else if(DEBUGMODEL==true){
			alert(result.msg);
		}else{
			alert('记录历史版本失败！');
		}
	};
	if(model_type=='proc'){
		var insertProc = "insert into proc_his(XMLID,PROC_NAME,INTERCODE,PROCCNNAME,INORFULL,CYCLETYPE,TOPICNAME,STARTDATE,STARTTIME,ENDTIME,PARENTPROC,REMARK,EFF_DATE,CREATER,STATE,STATE_DATE,PROCTYPE,PATH,RUNMODE,DBNAME,DBUSER,CURTASKCODE,DESIGNER,EXTEND_CFG,AUDITER,DEPLOYER,RUNPARA,RUNDURA,TEAM_CODE,DEVELOPER,CURDUTYER,VERSEQ,LEVEL_VAL,AREACODE,XML) select XMLID,PROC_NAME,INTERCODE,PROCCNNAME,INORFULL,CYCLETYPE,TOPICNAME,STARTDATE,STARTTIME,ENDTIME,PARENTPROC,REMARK,EFF_DATE,CREATER,STATE,STATE_DATE,PROCTYPE,PATH,RUNMODE,DBNAME,DBUSER,CURTASKCODE,DESIGNER,EXTEND_CFG,AUDITER,DEPLOYER,RUNPARA,RUNDURA,TEAM_CODE,DEVELOPER,CURDUTYER,VERSEQ,LEVEL_VAL,AREACODE,XML from proc where xmlid='"+selected[0].get('XMLID')+"'";
		var insertStep = "insert into proc_step_his(PROC_NAME,STEP_SEQ,S_STEP,F_STEP,N_STEP,STEP_NAME,STEP_TYPE,STEP_CODE,SQL_TEXT,DBNAME,AREACODE,REMARK,PREID,AFTID,PARENT_ID) select PROC_NAME,STEP_SEQ,S_STEP,F_STEP,N_STEP,STEP_NAME,STEP_TYPE,STEP_CODE,SQL_TEXT,DBNAME,AREACODE,REMARK,PREID,AFTID,PARENT_ID from proc_step where proc_name='"+selected[0].get('PROC_NAME')+"'";
		var updateSql = "update proc set state='PUBLISHED' where xmlid='"+selected[0].get('XMLID')+"'";
		var deleteSql1 = "delete from proc where proc_name='"+selected[0].get('PROC_NAME')+"'";
		var deleteSql2 = "delete from proc_schedule_info where proc_name='"+selected[0].get('PROC_NAME')+"'";
		var deleteSql3 = "delete from proc_step where proc_name='"+selected[0].get('PROC_NAME')+"'";
		var deleteSql4 = "delete from transdatamap_design where transname='"+selected[0].get('PROC_NAME')+"'";
		
		//在metadb中，更新程序状态，复制步骤到历史表，复制程序到历史表
		var MultiSql = '[\"'+updateSql+'\",\"'+insertStep+'\",\"'+insertProc+'\"]';
		var result=ai.executeMultiSql(MultiSql.toString(), null, "METADB");
		
		transactValidate(result,function(){
			//在metadbs中，复制步骤到历史表，复制程序到历史表，中并删除程序信息，调度信息，程序步骤，依赖关系
			var MultiSql = '[\"'+insertStep+'\",\"'+insertProc+'\",\"'+deleteSql1+'\",\"'+deleteSql2+'\",\"'+deleteSql3+'\",\"'+deleteSql4+'\"]';
			var result=ai.executeMultiSql(MultiSql.toString(), null, "METADBS");
			transactValidate(result,function(){
				flag = true;
			});
		});
	}else if(model_type=='data'){
		var xmlids ="";
		for (var i = 0; i < selected.length; i++) {
			xmlids +="'"+selected[0].get('XMLID')+"',";
		};
		xmlids=xmlids.substring(0,xmlids.length-1);
		var insertCol = "insert into column_his(XMLID,DATANAME,COLNAME,COLCNNAME,DATATYPE,LENGTH,REMARK,ISNULLABLE,ISPRIMARYKEY,PRECISION_VAL,SCALE,COL_SEQ,KEY_SEQ,INDEX_SEQ,PARTY_SEQ,FKTABNAME,FKCOLNAME,STARTPOS,ENDPOS,EFF_DATE,CREATER,STATE_DATE,STATE,UNICODE,DBDATATYPE,HIVEDATATYPE) "
			+ " select XMLID,DATANAME,COLNAME,COLCNNAME,DATATYPE,LENGTH,REMARK,ISNULLABLE,ISPRIMARYKEY,PRECISION_VAL,SCALE,COL_SEQ,KEY_SEQ,INDEX_SEQ,PARTY_SEQ,FKTABNAME,FKCOLNAME,STARTPOS,ENDPOS,EFF_DATE,CREATER,STATE_DATE,STATE,UNICODE,DBDATATYPE,HIVEDATATYPE from COLUMN_VAL where xmlid in ("+xmlids+")";
		var deleteCol = "delete from column_val where xmlid in ("+xmlids+")";

		var insertTab = "insert into table_his(XMLID,DATANAME,DATACNNAME,TEAM_CODE,SCHEMA_NAME,DATATYPE,DBNAME,TABSPACE,INDEX_TABSPACE,LEVEL_VAL,RIGHTLEVEL,DELIMITER,SPLITTYPE,TOPICNAME,CYCLETYPE,COMPRESSION,FIELDNUM,TABSIZES,ROWNUM_VAL,REFCOUNT,EFF_DATE,CREATER,STATE,STATE_DATE,DEVELOPER,CURDUTYER,VERSEQ,DESIGNER,AUDITER,DATEFIELD,DATEFMT,DATETYPE,EXTEND_CFG,REMARK) select XMLID,DATANAME,DATACNNAME,TEAM_CODE,SCHEMA_NAME,DATATYPE,DBNAME,TABSPACE,INDEX_TABSPACE,LEVEL_VAL,RIGHTLEVEL,DELIMITER,SPLITTYPE,TOPICNAME,CYCLETYPE,COMPRESSION,FIELDNUM,TABSIZES,ROWNUM_VAL,REFCOUNT,EFF_DATE,CREATER,STATE,STATE_DATE,DEVELOPER,CURDUTYER,VERSEQ,DESIGNER,AUDITER,DATEFIELD,DATEFMT,DATETYPE,EXTEND_CFG,REMARK from tablefile where  xmlid in ("+xmlids+")";
		var deleteTab = "delete from tablefile where  xmlid in ("+xmlids+")";

		//在metadb中，先复制字段到历史表，再复制模型到历史表
		var MultiSql = '[\"'+insertCol+'\",\"'+insertTab+'\"]';
		var result=ai.executeMultiSql(MultiSql.toString(), null, "METADB");
		
		transactValidate(result,function(){
			//在metadbs中，先复制字段到历史表，删除字段，再复制模型到历史表，删除模型
			var MultiSql = '[\"'+insertCol+'\",\"'+deleteCol+'\",\"'+insertTab+'\",\"'+deleteTab+'\"]';
			var result=ai.executeMultiSql(MultiSql.toString(), null, "METADBS");
			transactValidate(result,function(){
				flag = true;
			});
		});
	}else if(model_type=='inter'){
		var xmlids ="";
		for (var i = 0; i < selected.length; i++) {
			xmlids +="'"+selected[0].get('XMLID')+"',";
		};
		xmlids=xmlids.substring(0,xmlids.length-1);
		var insertSql = "insert into inter_his(XMLID,FULLINTERCODE,INTER_NO,INTER_NAME,INTER_BUSI_TYPE,INTER_TYPE,INTER_CYCLE,INTER_SOURCE,SOURCE_TABLE,STATUS,INTER_NUM,ACTIVE_TIME,END_TIME,UPDATE_TIME,DATA_OFFSET,DIR_OFFSET,TARGET_TABLE,LEVEL_VAL,DB_CRT_SQL,UNION_SQL,RENAME_SQL,DATAREGION,SOURCESYS,EXTRACTMETHOD,SOURCEDIR,CHECKTYPE,FILENUM,FILESIZE,PRI_LEVEL,DELIMITER,TABLEPARTITION,STD_TIME,EXTENDNAME,FILENAMEFILTER,FILEJUDGE,UNITJUDGE,SOURCEDATADURATION,SOURCEDBURI,SOURCEDBUSERNAME,SOURCEDBPWD,SOURCEDBPORT,SOURCEDBTABLENAME,CHAR_TYPE,ENABLE_MERGE,LINK_DUTYER,REMARK,CHECK_FILE_PATH,CREATER,CURDUTYER,BUSINESSTYPE,BATCH_NO,FILE_START_ROW,RESET_BATCH_TIME,DELIMIT_LENGTH,SCAN_DEPTHWISE,ARRIVE_STD_TIME) "
			+ " select XMLID,FULLINTERCODE,INTER_NO,INTER_NAME,INTER_BUSI_TYPE,INTER_TYPE,INTER_CYCLE,INTER_SOURCE,SOURCE_TABLE,STATUS,INTER_NUM,ACTIVE_TIME,END_TIME,UPDATE_TIME,DATA_OFFSET,DIR_OFFSET,TARGET_TABLE,LEVEL_VAL,DB_CRT_SQL,UNION_SQL,RENAME_SQL,DATAREGION,SOURCESYS,EXTRACTMETHOD,SOURCEDIR,CHECKTYPE,FILENUM,FILESIZE,PRI_LEVEL,DELIMITER,TABLEPARTITION,STD_TIME,EXTENDNAME,FILENAMEFILTER,FILEJUDGE,UNITJUDGE,SOURCEDATADURATION,SOURCEDBURI,SOURCEDBUSERNAME,SOURCEDBPWD,SOURCEDBPORT,SOURCEDBTABLENAME,CHAR_TYPE,ENABLE_MERGE,LINK_DUTYER,REMARK,CHECK_FILE_PATH,CREATER,CURDUTYER,BUSINESSTYPE,BATCH_NO,FILE_START_ROW,RESET_BATCH_TIME,DELIMIT_LENGTH,SCAN_DEPTHWISE,ARRIVE_STD_TIME from inter_cfg where xmlid in("+xmlids+")";
		var deleteSql = "delete from inter_cfg where xmlid in ("+xmlids+")";

		//在metadb中，复制接口到历史表
		var MultiSql = '[\"'+insertSql+'\"]';
		var result=ai.executeMultiSql(MultiSql.toString(), null, "METADB");
		transactValidate(result,function(){
			//在metadbs中，先复制接口到历史表，再删除接口
			var MultiSql = '[\"'+insertSql+'\",\"'+deleteSql+'\"]';
			var result=ai.executeMultiSql(MultiSql.toString(), null, "METADBS");
			transactValidate(result,function(){
				flag = true;
			});
		});
	}
	for(var i=0;flag&&i<tabs[model_type].length;i++){
		 recordStore = new AI.JsonStore({
             sql:tabs[model_type][i][0],
             table:tabs[model_type][i][1],
             key:"PROC_NAME",
             pageSize:20,
     });
     if(recordStore.count<1){
     continue;
     }
		var result = migCell(tabs[model_type][i][0],tabs[model_type][i][1]);
		flag=$.parseJSON(result).success==true||$.parseJSON(result).success=='true';
	}
	return flag;
};

function getCheckedValue(name){
	var radio = $("input[type='radio'][name='" + name + "']");
	for(var i=0; i < radio.length; i++){
		if(radio[i].checked){
			return $(radio[i]).val();
		}			
	}
}

 //展示cron表达式对话框
function showDailog(cycle){ 	
	var iWidth =650;                         //弹出窗口的宽度;
  	var iHeight=400;                       //弹出窗口的高度;
  	var iTop = (window.screen.availHeight-30-iHeight)/2;       //获得窗口的垂直位置;
 	var iLeft = (window.screen.availWidth-10-iWidth)/2;           //获得窗口的水平位置;
  	var defaultVal=  document.getElementById('CRON_EXP').value;
  	var url = "/"+contextPath+"/devmgr/Cron/cron.html?freq="+cycle+"&cron="+defaultVal+"&cron_id="+'CRON_EXP';
  	var _window=window.open(url,'','height='+iHeight+',innerHeight='+iHeight+',width='+iWidth+',innerWidth='+iWidth+',top='+iTop+',left='+iLeft+',toolbar=no,menubar=no,scrollbars=auto,resizeable=no,location=no,status=no');
    window.onclick = function (){_window.focus();};
}


</script>
</head>

<body class="" style="over-flow:auto;">	
	<div id="myModal" class="modal fade"> 
	   <div class="modal-dialog"> 
		    <div class="modal-content" > 
		     <div class="modal-header"> 
			      <button type="button" class="close close-modal" > <span aria-hidden="true">&times;</span><span class="sr-only">Close</span> </button> 
			      <h4 class="modal-title">程序上线</h4> 
		     </div> 
		     <div class="modal-body" id="upsertForm"></div> 
		     <div class="modal-footer"> 
			      <button type="button" class="btn btn-default close-modal" >取消</button> 
			      <button id="dialog-ok" type="button" class="btn btn-primary">上线</button> 
		     </div> 
		    </div> x
	    <!-- /.modal-content --> 
	   </div> 
	   <!-- /.modal-dialog --> 
  	</div> 
	
	<div class="ui-layout-north">
		<nav class="navbar navbar-default" role="navigation"style="margin-bottom: 1px">
			<div class="container-fluid" style="padding-left: 0px">
				<div class="collapse navbar-collapse" style="padding-left: 0px">
					<div class="m-xs pull-left">
						<div id="show-content" data-toggle="buttons" class="btn-group">
							</label> <label class="btn btn-sm btn-primary active" id="proc">
								<input type="radio" name="proc" ><i
								class="fa fa-check text-active"></i> 任务
							</label> <label class="btn btn-sm btn-success" id="data">
								<input type="radio" name="data" ><i
								class="fa fa-check text-active"></i> 数据
							</label>
							<label class="btn btn-sm btn-info" id="inter">
								<input type="radio" name="inter" ><i
								class="fa fa-check text-active "></i> 接口
						</div>
					</div>
					<div  id="queryPanel" style="margin-top:5px;"></div>
				</div>
				<!-- /.navbar-collapse -->
			</div>
			<!-- /.container-fluid -->
		</nav>
	</div>
	
	
	<div class="ui-layout-west">
		<div id="treeview6" class="test"></div>
	</div>
	
	<div class="ui-layout-center">
		<div id="tabpanel" style="margin-bottom: 120px;"></div>
	</div>
	
</body>
</html>