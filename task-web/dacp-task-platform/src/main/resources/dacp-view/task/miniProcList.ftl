
<!DOCTYPE html>
<html lang="en" class="app">
    <head>
    <meta charset="utf-8" /> 
    <title>DACP数据云图</title>   
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"  />  
	<link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-res/task/css/app.v1.css" type="text/css" rel="stylesheet"/>
	
	<script type="text/javascript" src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js"></script>
	<script type="text/javascript" src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="${mvcPath}/dacp-lib/underscore/underscore-min.js"></script>
	<script src="${mvcPath}/dacp-lib/backbone/backbone-min.js" type="text/javascript"></script>
	<!-- <script src="${mvcPath}/dacp-view/ve/js/dacp-ve-js-1.0.js" type="text/javascript" charset="utf-8"></script> -->
	<!--<script src="${mvcPath}/ve/ve-context-path.js" type="text/javascript" charset="utf-8"></script>-->
	<script src="${mvcPath}/dacp-lib/jquery-plugins/jquery.layout-latest.js" type="text/javascript"> </script>
	<script src="${mvcPath}/dacp-lib/jquery-plugins/bootstrap-treeview.min.js"> </script>
	<script src="${mvcPath}/dacp-res/task/js/app.plugin.js"></script>
      
	<!-- 使用ai.core.js需要将下面两个加到页面 -->
	<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
	<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>
	
	<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>
	<script src="${mvcPath}/dacp-lib/jquery-plugins/bootstrap-treeview.min.js"> </script>
	<script type="text/javascript" src="${mvcPath}/dacp-lib/underscore/underscore-min.js"></script>
	
	<script src="${mvcPath}/dacp-view/aijs/js/ai.treeview.js"></script>
  	<script src="${mvcPath}/dacp-view/task/js/scheduleOpLog.js"></script>
	  
<style>
body {
	margin: 0;
	font-family: Roboto, arial, sans-serif;
	font-size: 13px;
	line-height: 20px;
	color: #444444;
	background-color: #f1f1f1;
}

a{
	cursor:pointer;
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
var proc_state="";
var run_freq="";
var trigger_type="";
var team_code = paramMap["team_code"]||"";
var getQueryCondition = function(){
	var _searchText = $("#search-text").val().trim();
	var _searchCondi  = _searchText.length>0?" AND (proccnname LIKE '%"+ _searchText+"%' or a.proc_name LIKE '%"+_searchText+"%')":"";
	    _searchCondi += trigger_type.length>0?" AND  trigger_type='"+trigger_type+"'":"";
	    _searchCondi += proc_state.length>0?" AND state='"+proc_state+"'":"";
	    _searchCondi += run_freq.length>0?" AND run_freq='"+run_freq+"'":"";
	    _searchCondi += getTeamCondi();
    return _searchCondi;
};

function getTeamCondi(){
	var team_codes = team_code;
	var curTeamCodeCondi = "";
	if(typeof(team_code)!="undefined" && team_codes.length>0){
		curTeamCodeCondi ="  and a.team_code = '" + team_codes + "' ";
	}
	return curTeamCodeCondi;
}

function getTopicCodes(node){
	var codes = [];
	
	function getChildTopicCodes(node){
		if(node.nodes && node.nodes.length>0){
			$.each(node.nodes,function(i,item){
				if(item.nodes && item.nodes.length>0){
					getChildTopicCodes(item);
				}else{
					//codes.push(item.id);
					codes.push(item.id.substr(item.id.lastIndexOf("-")+1));
				}
			});
		}else{
			codes.push(node.id.substr(node.id.lastIndexOf("-")+1));
		}
	}
	
	getChildTopicCodes(node,codes);
	return codes;
}

$(document).ready(function() {
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
		,	west__size:						0//205
		,	north__size: 					50
	});
    var platformStore = new AI.JsonStore({
        sql:"select PLATFORM,PLATFORM_CNNAME from PROC_SCHEDULE_PLATFORM ",
        key:"PLATFORM",
        pageSize:-1,
        table:"PROC_SCHEDULE_PLATFORM",
        dataSource:"METADBS"
    });
    var procSql=" SELECT a.xmlid xmlid, a.xmlid proc_id,a.proc_name,a.proccnname,a.topicname,a.LEVEL_VAL,a.proctype,a.cycletype,a.path,a.creater,a.eff_date,a.curdutyer,a.state_date, " +
        		"        b.xmlid proc_info_id,agent_code,trigger_type,run_freq,st_day,st_time,cron_exp,pri_level,platform,resouce_level,redo_num,date_args,muti_run_flag,dura_max,state,eff_time " +
                " FROM proc a " +
                " LEFT JOIN proc_schedule_info b ON a.xmlid = b.xmlid " +
		    	" WHERE 1=1 {condi}  order by state_date desc ";
    
    
    var procStore = new AI.JsonStore({
		sql:procSql.replace("{condi}",getQueryCondition()),
		pageSize:15,
		key:"PROC_NAME",
		table:"proc_schedule_info"
	});
    
	var buildTreeView = function(sql){
		/*
		$('#treeview6').treeview({
			color: "#428bca",
			expandIcon: "glyphicon glyphicon-chevron-right",
			collapseIcon: "glyphicon glyphicon-chevron-down",
			nodeIcon: "glyphicon glyphicon-user",
			showTags: true,
			levels: 4,
			onNodeSelected:function(event,node){
				var topicCodes = getTopicCodes(node);
				var codes = "";
				if(topicCodes && topicCodes.length>0){
					for(var i=0; i< topicCodes.length; i++){
						codes += "'"+topicCodes[i]+"',"
					}
					codes = codes.substr(0,codes.length-1);
				}
				
				var topicCondi = "and a.topiccode in (" + codes + ")";
				switchContent(topicCondi + getQueryCondition());
			},
			// groupfield:"DBNAME,LEVEL_VAL,CYCLETYPE",//SCHEMA_NAME,TABSPACE,
			pkeyfield:"PARENTCODE",
			keyfield:"RULE_CODE",
			titlefield:"RULENAME",
			rootval: "R01",
			iconfield:"",
			sql:sql,
			dataSource:"METADB",
			// subtype: 'grouptree' 
			subtype: 'simpletree' 
		});*/
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
		  	if(DBNAME!='defaultDB') caption=DBNAME;
		  	  
		  	if(r.get('PROCTYPE')=='WIDETAB'){
	  			Asiainfo.addTabSheet(r.get('PROC_NAME'),caption+'模型:'+r.get('PROC_NAME'),'../devmgr/procDesign.html?PROCNAME='+r.get('PROC_NAME')+'&DBNAME='+DBNAME+'&METAPRJ='+METAPRJ);
		  	} else  if (r.get('PROCTYPE')=='SCRIPT') {
	   	        Asiainfo.addTabSheet(DBNAME+r.get('PROC_NAME'),caption+'程序:'+r.get('PROC_NAME'),'../asiainfo/ProcGraph/procGraph.html?PROCNAME='+r.get('PROC_NAME')+'&DBNAME='+DBNAME+'&METAPRJ='+METAPRJ);
		  	} else {
		  		var url = "${mvcPath}/ftl/task/proschedInfoAdd?type=edit&xmlid="+r.get('PROC_ID')+"&team_code="+team_code;
		    	window.open(url);
		   	        //Asiainfo.addTabSheet(DBNAME+r.get('PROC_NAME'),caption+'程序:'+r.get('PROC_NAME'),'../devmgr/ObjEditer.html?&OBJTYPE=PROC&OBJNAME='+r.get('PROC_NAME')+'&DBNAME='+DBNAME+'&METAPRJ='+METAPRJ);
		  	}   
		}
		return false;
	};
	var _stateRender=function (value,data,index){
		 var _val=value.get("STATE");
	 		 var finalVal="";
	 		 if(_val=="CHANGE"){
	 			finalVal='<div><font color="blue">变更</font></div>';
	 		 }else if(_val=="INVALID"){
	 			finalVal='<div><font color="red">失效</font></div>';
	 		 }else if(_val=="VALID"){
	 			finalVal='<div><font color="green">生效</font></div>';
	 		 }else if(_val=="PUBLISHED"){
	 			 finalVal='<div><font color="black">已发布</font></div>';
	 		 }else if(_val=="NEW"){
	 			 finalVal='<div><font color="blue">新建</font></div>';
	 		 }else {
	 			 finalVal='<div><font color="blue">待发布</font></div>';
	 		 }
	 		 return finalVal; 
	};
	var _platformRender=function(value,data,index){
	 	    var r=  platformStore.getRecordByKey(value.get("PLATFORM"));
	 	    return r?r.get("PLATFORM_CNNAME"):"--";
    };
    var _runFreqRender=function(data,value,index){
	    	 var _freq= data.get("CYCLETYPE");
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
		store:procStore,
		pageSize:12,
		containerId:'datagrid',
		nowrap:true,
		showcheck:true,
		rowclick:_rowClickFunc,
		celldblclick:_rowdblClickFunc,
		columns:[
		　  	 {header: "程序名称", width:130,dataIndex: 'PROC_NAME'},
	  	     {header: "中文名称", width:200, dataIndex: 'PROCCNNAME'},
	  	     {header: "当前状态", width:74, dataIndex: 'STATE',render:_stateRender},
	  	     //{header: "路径", width:116, dataIndex: 'PATH'},
	  	     {header: "触发类型", width:75, dataIndex: 'TRIGGER_TYPE',render:function(val){ return val.get("TRIGGER_TYPE")==0?"时间触发":"事件触发";}},
	  	     {header: "Agent", width:64, dataIndex: 'AGENT_CODE'},
	  	     //{header: "程序类型", width:60, dataIndex: 'PROCTYPE'},
	  	     //{header: "周期", width:60, dataIndex: 'RUN_FREQ',render:_runFreqRender},
	  	     {header: "周期", width:60, dataIndex: 'CYCLETYPE',render:_runFreqRender},
	  	   	 {header: "优先级", width:100, dataIndex: 'PRI_LEVEL' },
	  	 	 //{header: "接入平台", width:100, dataIndex: 'PLATFORM',render:_platformRender },
	  	 	 {header: "创建者", width:80, dataIndex: 'CREATER' },
	  	 	 {header: "修改者", width:80, dataIndex: 'CURDUTYER' },
	  	 	 {header: "修改时间", width:100, dataIndex: 'STATE_DATE' }
	  	 	 
		]
	};
	var grid =new AI.Grid(config);


	_treeSql="SELECT dbname,topicname,rule_code,parentcode,ruletype,rulename,ruletext FROM meta_team_permission WHERE 1=1 {team_code}  AND ruletype IN('database','topic') ORDER BY rule_code";
	_treeSql=_treeSql.replace("{team_code}",typeof(team_code)=="undefined" || team_code==""?"":" and team_code = '" + team_code + "'");
	buildTreeView(_treeSql);
	
	var switchContent = function(condi){
		procStore.select(procSql.replace("{condi}",condi));
	};
	
	$('#trigger_type_select').on('change',function(e){
		trigger_type= $("#trigger_type_select").val();
		searchCondi = getQueryCondition();
        switchContent(searchCondi);
	});
	$('#proc_state_select').on('change',function(e){
		proc_state = $("#proc_state_select").val();
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
    $("#insertBtn").click(function(){
    	var proc_name = '';
    	var DBNAME = '';
    	var METAPRJ = '';
    	var caption = '';
    	//ai.addTabSheet(DBNAME + proc_name,caption+'程序:'+proc_name,'${mvcPath}/task/addProcInfo?'+ proc_name +'&DBNAME='+DBNAME+'&METAPRJ='+METAPRJ);

    	var url = "${mvcPath}/ftl/task/proschedInfoAdd?type=add&xmlid="+ai.guid()+"&team_code="+team_code;
    	window.open(url);
   });
	$("#publishBtn").on("click",function(){
		var dataArray = grid.getCheckedRows();
		var date = new Date();
		var _date = date.format("yyyy-mm-dd hh:mm:ss");
		var msg1="";
		var msg2="";
		if(dataArray.length>0){
			for(var i=0;i<dataArray.length;i++){
				var xmlid = dataArray[i].data.XMLID
				var proc_name = dataArray[i].data.PROC_NAME
				var updateProc = "update proc set state='PUBLISHED' ,CURDUTYER='"+_UserInfo.usercnname+"',EFF_DATE='"+_date+"' where xmlid='"+xmlid+"'" ;
				ai.executeSQL(updateProc,false,"METADB");
				var result = dataMigrate(xmlid,proc_name);
				var sql="";
				if(result){
					msg1 += proc_name+"上线成功\n";
					//修改开发库proc和metaobj状态
					sql="update proc set state = 'VALID' where xmlid='"+xmlid+"'";
					ai.executeSQL(sql,false,"METADB");
				}else{
					msg2 += proc_name+"上线失败\n";
					sql="update PROC set state='CHANGE' where xmlid='"+xmlid+"'";
		            ai.executeSQL(sql,false,"METADB");
				}
				
				//记录上线日志
				taskOpLog("'"+proc_name+"'","上线",updateProc+"; " + sql,result);
			}
			alert(msg1+"\n"+msg2);
			procStore.select();
		}else{
			alert("请先勾选要发布的程序！");
		}
		return false;
	});
	
	//同步函数
	var dataMigrate = function(xmlid,proc_name){
		var procSql="select * from proc where xmlid='"+xmlid+"'";
		var schdSql="select * from proc_schedule_info where xmlid='"+xmlid+"'";
		var stepSql="select * from proc_step where proc_name='"+proc_name+"'";
		var scheParaSql = "select * from proc_schedule_runpara where xmlid='"+xmlid+"'";
		var mapSql="select * from transdatamap_design where TRANSNAME='"+xmlid+"'";
		var tabs={
			proc:[
			      [mapSql,'TRANSDATAMAP_DESIGN'],
			      [schdSql,'PROC_SCHEDULE_INFO'],
			      [stepSql,'PROC_STEP','PROC_NAME'],
			      [procSql,'PROC'],
			      [scheParaSql,'PROC_SCHEDULE_RUNPARA','XMLID']
		    ]
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
			var deleteSql1 = "delete from proc where xmlid='"+xmlid+"'";
			var deleteSql2 = "delete from proc_schedule_info where xmlid='"+xmlid+"'";
			var deleteSql3 = "delete from proc_step where proc_name='"+proc_name+"'";
			var deleteSql4 = "delete from transdatamap_design where transname='"+xmlid+"'";
			var deleteSql5 = "delete from proc_schedule_runpara where xmlid='"+xmlid+"'";
				//在metadbs中，复制步骤到历史表，复制程序到历史表，中并删除程序信息，调度信息，程序步骤，依赖关系
			var MultiSql = '[\"'+deleteSql1+'\",\"'+deleteSql2+'\",\"'+deleteSql3+'\",\"'+deleteSql4+'\",\"'+deleteSql5+'\"]';
			var result=ai.executeMultiSql(MultiSql.toString(), null, "METADBS");
			if(result.success&&(result.success==true||result.success=='true')){
				flag=true;
			}
		for(var i=0;flag&&i<tabs['proc'].length;i++){
			 recordStore = new AI.JsonStore({
                 sql:tabs['proc'][i][0],
                 table:tabs['proc'][i][1],
                 key:"XMLID",
                 pageSize:20,
         });
         if(recordStore.count<1){
         continue;
         }
			var result = migCell(tabs['proc'][i][0],tabs['proc'][i][1]);
			flag=$.parseJSON(result).success==true||$.parseJSON(result).success=='true';
		}
		return flag;
	};	
	$("#invalidBtn").on("click",function(){
		var dataArray = grid.getCheckedRows();
		var format = function(val){ return val<10?("0"+val):val;};
		var date = new Date();
		var _date =  date.format("yyyy-mm-dd hh:mm:ss");
		date.setDate(date.getDate()-1); 
		var exp_time = date.format("yyyy-mm-dd");
		var xmlid = "";
		var proc_name="";
		var updateProc = "";
		var updateInfo  = "";
		if(dataArray.length>0){
			for(var i=0;i<dataArray.length;i++){
				proc_name=dataArray[i].get("PROC_NAME");
				xmlid = dataArray[i].get("XMLID");
				updateProc = "update proc set state='PUBLISHED' ,CURDUTYER='"+_UserInfo.usercnname+"',EFF_DATE='"+_date+"' where xmlid='"+xmlid+"'" ;
				updateInfo  = "update proc_schedule_info set EXP_TIME='"+exp_time+"' where xmlid='"+xmlid+"'" ;
				ai.executeSQL(updateInfo,false,"METADB");
				ai.executeSQL(updateProc,false,"METADB");
				ai.executeSQL(updateInfo,false,"METADBS");//失效正式环境
				ai.executeSQL(updateProc,false,"METADBS");//失效正式环境
				
				//修改开发库proc和metaobj状态
				ai.executeSQL("update proc set state = 'INVALID' where xmlid='"+xmlid+"'",false,"METADB");
				ai.executeSQL("update metaobj set state = 'INVALID' where xmlid='"+xmlid+"'",false,"METADB");
			}
			//记录下线日志
			taskOpLog("'"+proc_name+"'","下线",updateProc+"; " + updateInfo ,true);
			procStore.select();
		}else{
			alert("请先勾选要失效的程序！");
		}
		return false;
	});
	$('#refreshBtn').on("click",function(){
		procStore.select();
	});
	$("a.deleteBtn").on("click",function(){
		var _indexArray = [];
		$(".ai-grid-body-check").each(function(index,el) {
            if($(this).prop("checked")){
            	_indexArray.push(index);
            }
        });
        if(_indexArray.length==0){
        	alert('没有选择任何一条数据！');
        }else{
        	if(confirm("确定删除?")){
			    var in_condition=[];
			    var transSql = " delete from transdatamap_design where transname='{}' ";
			    var infoSql = " delete from proc_schedule_info where proc_name='{}'";
        		for(var i=_indexArray.length-1;i>=0;i--){
        			var r = procStore.getAt(_indexArray[i]);
					if(r.get("STATE")=="INVALID"){
						procStore.remove(r);
						realTransSql = transSql.replace("{}",r.get("PROC_NAME"));
						realInfoSql = infoSql.replace("{}",r.get("PROC_NAME"));
						ai.executeSQL(realInfoSql,false,"");
						ai.executeSQL(realTransSql,false,"");
					}			
        		}
				procStore.commit();
				procStore.select();
				switchContent(searchCondi);
   			 }
        }
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
	
	$('a.btn_realDown').on("click",function(){
		if(_checkUniq($('.ai-grid-body-check:checked'))){
			var _index = $('.ai-grid-body-check:checked').attr('rowindex');
			var r = procStore.getAt(_index);
			procStore.curIndex = _index;
			var _title = "程序:"+r.get('PROC_NAME')+" 影响分析";
			parent.openTableInfo("ana-After",_title,r.get('PROC_NAME'),true);
			//bindCarouselWithProc("ana-After");
		}
	});
	
	$('a.btn_realUp').on("click",function(){
		if(_checkUniq($('.ai-grid-body-check:checked'))){
			var _index = $('.ai-grid-body-check:checked').attr('rowindex');
			var r = procStore.getAt(_index);
			procStore.curIndex = _index;
			var _title ="程序:"+r.get('PROC_NAME')+" 血缘分析";
			parent.openTableInfo("ana-Before",_title,r.get('PROC_NAME'),true);
			//bindCarouselWithProc("ana-Before");
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
					<ul class="nav navbar-nav">
						<li><a><i class="fa fa-home"> </i> 程序列表</a></li>
					</ul>
					<form class="navbar-form navbar-left" role="search">
						<div class="form-group" >
							<select id="trigger_type_select" class="form-control formElement">
								<option value="">触发类型</option>
								<option value="0">时间触发</option>
								<option value="1">事件触发</option>
							</select>
						</div>
						<div class="form-group">
							<select id="proc_state_select" class="form-control formElement">
								<option value="">程序状态</option>
								<option value="CHANGE">变更</option>
								<option value="NEW">新建</option>
								<option value="VALID">生效</option>
								<option value="INVALID">失效</option>
							</select>
						</div>
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
							<input id="search-text" type="text" class="form-control"  style="width: 200px" placeholder="输入程序名,中文名">
						</div>
						<button id="search-key" type="button" class="btn btn-success btn-xs">查找</button>
						<div class="form-group">
<!-- 						<ul class="nav navbar-nav"> -->
<!-- 							<li> -->
<!-- 								<div class="btn-group"> -->
<!-- 									<button type="button" -->
<!-- 										class="btn btn-primary btn-xs dropdown-toggle" -->
<!-- 										data-toggle="dropdown"> -->
<!-- 										流程分析 -->
<!-- 										<span class="caret"></span> <span class="sr-only">ToggleDropdown</span> -->
<!-- 									</button> -->
<!-- 									<ul class="dropdown-menu" role="menu"> --> 
<!-- 										<li><a class="btn_realDown" id="openBtn">影响分析</a></li> --> 
<!-- 									<li><a class="btn_realUp" id="anaBefore">血缘分析</a></li> --> 
<!-- 										 -->
<!-- 										<li class="hide"><a class="btn_fielemap" href="#">字段映射</a></li> --> 
<!-- 										<li class="divider hide"></li> --> 
<!--  										<li><a class="priBtn hide">优先级</a></li> --> 
<!--  										<li class="divider"></li> --> 
<!--  										<li><a class="deleteBtn">删除</a></li> --> 
<!--  										 -->
<!--  										<li><a class="updateBtn">修改</a></li> --> 
<!--                                          --> 
<!-- 								</ul> --> 
<!-- 								</div> -->
<!-- 							</li> -->
<!-- 						</ul> -->
<!-- 					</div> -->
					<button id="insertBtn" type="button" class="btn btn-primary btn-xs">增加</button>
					<button id="publishBtn" type="button" class="btn btn-info btn-xs">发布</button>
			        <button id="invalidBtn" type="button" class="btn btn-danger btn-xs">失效</button>
			        <button id="refreshBtn" type="button" class="btn btn-info btn-xs">
				    <i class="fa fa-refresh"></i>
					</button>
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
		<div id="datagrid"  style="margin-bottom: 10px;margin-right:10px"></div>
		<div id="tabpanel2"  style="margin-bottom: 10px"></div>
	</div>
</body>
</html>