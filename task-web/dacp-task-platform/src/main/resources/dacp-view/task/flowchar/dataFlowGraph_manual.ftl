<!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=5,IE=9" ><![endif]-->
<!DOCTYPE html>
<html>
<head> 
    <title>流程图编辑</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link href="${mvcPath}/dacp-view/aijs/css/ai.css" type="text/css" rel="stylesheet"/>
    <link rel="stylesheet" type="text/css" href="${mvcPath}/dacp-view/task/flowchar/styles/grapheditor.css">
   <style>
		.geSidebar .geItem:hover {
		border: 1px solid gray !important;
		}
		.geSidebar .geItem {
		display: inline-block;
		border: 1px solid white !important;
		margin: 0px solid gray !important;
		padding: 0px solid gray !important;
		background-repeat: no-repeat;
		background-position: 50% 50%;
		 
		border-radius: 0px;
		width: 80px;
		height: 70px;
		 
		}
		.geSidebar .geItem {
		float: left;
		/*width: 50%;
		*/
		width: 80px;
		height: 70px;
		padding: 10px;
		font-size: 10px;
		line-height: 1.4;
		text-align: center;
		background-color: #f9f9f9;
		border: 1px solid #fff;
		}

		 
		.geSidebar .geItem:hover {
		color: #fff;
		background-color: #563d7c;
		}
		.bs-glyphicons .glyphicon {
		margin-top: 5px;
		margin-bottom: 10px;
		font-size: 24px;
		}
		table hr{
			margin-top: 0px; 
			margin-bottom: 0px; 
		} 
		body div.mxPopupMenu {
			-webkit-box-shadow: 3px 3px 6px #C0C0C0;
			-moz-box-shadow: 3px 3px 6px #C0C0C0;
			box-shadow: 3px 3px 6px #C0C0C0;
			background: white;
			position: absolute;
			border: 3px solid #e7e7e7;
			padding: 3px;
		}
		body table.mxPopupMenu {
			border-collapse: collapse;
			margin: 0px;
		}
		body tr.mxPopupMenuItem {
			color: black;
			cursor: default;
		}
		body td.mxPopupMenuItem {
			padding: 6px 60px 6px 30px;
			font-family: Arial;
			font-size: 10pt;
		}
		body td.mxPopupMenuIcon {
			background-color: white;
			padding: 0px;
		}
		body tr.mxPopupMenuItemHover {
			background-color: #eeeeee;
			color: black;
		}
		table.mxPopupMenu hr {
			border-top: solid 1px #cccccc;
		}
		table.mxPopupMenu tr {
			font-size: 4pt;
		}
	</style>
	<script type="text/javascript">
	// Public global variables
	var MAX_REQUEST_SIZE = 10485760;
	var MAX_WIDTH = 6000;
	var MAX_HEIGHT = 6000;

	// URLs for save and export
	var EXPORT_URL = '/export';
	var SAVE_URL = '/save';
	var OPEN_URL = '/open';
	var RESOURCES_PATH = '${mvcPath}/dacp-view/task/flowchar/resources';
	var RESOURCE_BASE = RESOURCES_PATH + '/grapheditor';
	var STENCIL_PATH = '${mvcPath}/dacp-view/task/flowchar/stencils';
	var IMAGE_PATH = '${mvcPath}/dacp-view/task/flowchar/images';
	var STYLE_PATH = '${mvcPath}/dacp-view/task/flowchar/styles';
	var CSS_PATH = '${mvcPath}/dacp-view/task/flowchar/styles';
	var OPEN_FORM = 'open.html';

	// Specifies connection mode for touch devices (at least one should be true)
	var tapAndHoldStartsConnection = true;
	var showConnectorImg = true;

	// Parses URL parameters. Supported parameters are:
	// - lang=xy: Specifies the language of the user interface.
	// - touch=1: Enables a touch-style user interface.
	// - storage=local: Enables HTML5 local storage.
	var urlParams = (function(url)
	{
		var result = new Object();
		var idx = url.lastIndexOf('?');

		if (idx > 0)
		{
			var params = url.substring(idx + 1).split('&');
			
			for (var i = 0; i < params.length; i++)
			{
				idx = params[i].indexOf('=');
				
				if (idx > 0)
				{
					result[params[i].substring(0, idx)] = params[i].substring(idx + 1);
				}
			}
		}
		
		return result;
	})(window.location.href);

	// Sets the base path, the UI language via URL param and configures the
	// supported languages to avoid 404s. The loading of all core language
	// resources is disabled as all required resources are in grapheditor.
	// properties. Note that in this example the loading of two resource
	// files (the special bundle and the default bundle) is disabled to
	// save a GET request. This requires that all resources be present in
	// each properties file since only one file is loaded.
	mxLoadResources = false;
	mxBasePath = '${mvcPath}/dacp-view/task/flowchar/';
	mxLanguage = urlParams['lang'];
	mxLanguages = ['de'];
	</script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>

<script type="text/javascript" src="${mvcPath}/dacp-view/task/flowchar/mxClient.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-view/task/flowchar/js/Editor.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-view/task/flowchar/js/Graph.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-view/task/flowchar/js/Shapes.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-view/task/flowchar/js/EditorUi.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-view/task/flowchar/js/Actions.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-view/task/flowchar/js/Menus.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-view/task/flowchar/js/Sidebar.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-view/task/flowchar/js/Toolbar.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-view/task/flowchar/js/Dialogs.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-view/task/flowchar/jscolor/jscolor.js"></script>


<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>

<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
<!-- <script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script> -->
<script src="${mvcPath}/dacp-view/task/js/ai.field.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>

<script src="${mvcPath}/dacp-view/aijs/js/ai.funcEditer.js"></script>
<script src="${mvcPath}/dacp-res/task/js/metaStore.v1.js"></script>
   <script type="text/javascript">
	//guid函数
	var getUuid = function (len, radix) {//len长度，radix进制（如十进制为10）
		var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
		var uuid = [], i;
		radix = radix || chars.length;
	  
		if (len) {
			// Compact form
			for (i = 0; i < len; i++) uuid[i] = chars[0 | Math.random()*radix];
		} else {
			// rfc4122, version 4 form
			var r;
	  
			// rfc4122 requires these characters
			uuid[8] = uuid[13] = uuid[18] = uuid[23] = '-';
			uuid[14] = '4';

			// Fill in random data.  At i==19 set the high bits of clock sequence as
			// per rfc4122, sec. 4.1.5
			for (i = 0; i < 36; i++) {
				if (!uuid[i]) {
					r = 0 | Math.random()*16;
					uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r];
				}
			}
		}
		return uuid.join('');
	};

	var Global ={};//跨窗口之间传递的全局变量
	if(window.parent) Global = window.parent.Global;

	var FLOWCODE = paramMap.FLOWCODE||paramMap.OBJNAME;
	var FLOWNAME = paramMap.FLOWNAME;
	var CYCLETYPE = paramMap.CYCLETYPE||"day";
	var TOPICNAME = paramMap.TOPICNAME||"";
	var LEVEL = paramMap.LEVEL||"" ;
	var editor;
	var graph;//图形对象
	var graphStore;//数据存储对象
	var OBJ_TYPE = {
		"PROC"  : "PROC",
		"TAB"   : "TAB",
		"EVENT" : "EVENT",
		"INTER" : "INTER"
	}
	//所有程序节点默认公共定义
	var procScheduleCommonInfo = 
	{
		"platForm" : "BI", //运行平台
		"resouceLevel" : "1", //资源级别
		"redoNum" : "0", //自动重做次数
		"execClass" : "9998", //运行平台
		"dateArgs" : "1", //程序运行参数偏移量
		"duraMax" : "1444", //程序运行持续最大时间（分钟）
		"expTime" : "9999-12-31", //程序失效日期
		"onFocus" : "1", //重点监控：0否，1是
		"redoInterval" : "5" //自动重做间隔
	}

	//周期转换类型
	var freqType = 
	{
		"hour"  : "H",
		"day"   : "D",
		"month" : "M",
		"minute": "MI",
		"year"	: "Y"
	}
	//cron 表达式默认值
	var DEFAULT_CRON=
	{
		"hour_cron"  : "0 0 * * * ? ",
		"day_cron"   : "0 0 0 * * ? ",
		"month_cron" : "0 0 0 1 * ? ",
		"minute_cron": "0 0/10 * * * ? ",
		"year_cron"	 : "0 0 0 1 1 ? * "
	}

///从数据库加载流程图
var loadfromDatabaseFlow=function(){
	if(!FLOWCODE) return ;
	graphStore = new AI.JsonStore({
		root: 'root',
		sql: "select flowcode,flowname,xml,creater,state, state_date, cycletype from transflow_manual where FLOWCODE='"+FLOWCODE+"'",
		dataSource: "METADBS",
		table: "TRANSFLOW_MANUAL",
		key: "FLOWCODE"
	});
	if(graphStore.getCount()==0){
		var flowrec = graphStore.getNewRecord();
		for (var key in Global) {
			if(typeof (Global[key]) !="object"){
				flowrec.set(key.toUpperCase(), Global[key]);
			}
		};
		for (var key in paramMap) {
			flowrec.set(key.toUpperCase(), paramMap[key]);
		};
		flowrec.set('FLOWCODE',FLOWCODE);
		flowrec.set('FLOWNAME',FLOWNAME||"新建流程");

		flowrec.set('EFF_DATE',new Date());
		flowrec.set('CREATER',_UserInfo.usercnname);
		flowrec.set('STATE','新建');
		flowrec.set('STATE_DATE',new Date());
		flowrec.set('CURDUTYER',_UserInfo.usercnname);
		flowrec.set('VERSEQ',0);
		flowrec.dirty=true;
		graphStore.add(flowrec);
	}else{
		var record = graphStore.getAt(0);
		var xml =record.get("XML");
		if (xml != null && xml.length > 0){
			try{
				editor.setGraphXml(xml);
			}catch(e){}
		}
	}
};

//保存到transdatamap_design_manual
var savetoDatabaseFlow = function(xmltext){
	if($("#date_args").val().length==0){
		alert("请填写日期批次！")
		return false;
	}
	if(!/^\d{4}(-\d{2}(-\d{2}(\s\d{2}(\s\d{2})?)?)?)?$/.test($("#date_args").val())){
		alert("日期批次格式格式有误！")
		return false;
	}
	var graph =  editor.graph;
	var parent = graph.getDefaultParent();
	if(!graphStore) return;
	if( graphStore.getCount()==0) return;
	var r=graphStore.getAt(0);
	r.set('STATE_DATE',new Date());
	r.set('CURDUTYER',_UserInfo.usercnname);
	r.set("XML",xmltext);
	graphStore.commit();
	
	var getTriggerType = function(cell){
		return isFirstProcObj(cell)?0:1;
	};

	var childCount=graph.model.getChildCount(parent);

	for(var i=0;i<childCount;i++){
		var child = graph.model.getChildAt(parent, i);
		child.remark=getObjSourceTargetXMLID(child);
		var c_childCount = graph.model.getChildCount(child);
		for(var j=0;j<c_childCount;j++){
			c_child =graph.model.getChildAt(child, j);
			c_child.remark="level:"+i+","+j;
		};
		
		//保存flow信息前更新程序首节点信息
		if(child.isVertex()&&child.objType=="PROC"){

			child.triggerType = getTriggerType(child);			

			if(0 == child.triggerType) //时间触发则继承flow的cron或设置的时间
			{
				child.cronExp = graphStore.getAt(0).get('CRON_EXP');
			}
			else
			{
				child.cronExp = '';
			}

		}
	};
	var msg = '保存流程图成功!';
	saveScheduleToDb(msg);
}; 
//begin schedule*************************************************************

//判断前驱节点中是否有程序
function haveSourceProcObj(cell){
	var ret = false;

	for (var i = 0 ; i < cell.getEdgeCount(); i++){
		var edge = cell.getEdgeAt(i);
		var sObj=edge.source;
		var tObj=edge.target;

		if(!tObj || !sObj) continue;

		//判断前驱节点
		if(tObj==cell && sObj!=cell ){
			if(OBJ_TYPE.PROC == sObj.objType){	//是程序
				return true;
			}/*else{	
			    //非程序则以此为参递归判断
			    
				ret = haveSourceProcObj(sObj);
				if(ret){
					return true;
				}
			}*/
		}
	}
	return ret;
};

//判断是否是程序首结点(cell为程序节点)
function isFirstProcObj(cell){
	//独立节点则作为首节点
	return 0==cell.getEdgeCount()?true:(!haveSourceProcObj(cell));
};

//获取数据节点的输入源
function getSrcObjOfTab(tabCell)
{
	var source="";
	for(var i=0; i<tabCell.getEdgeCount(); i++){
		var edge = tabCell.getEdgeAt(i);
		var sObj=edge.source;
		var tObj=edge.target;
		if(!tObj || !sObj) continue;
		if(sObj==cell && tObj!=cell ){
		if(target) target+=','+tObj.id  
		else target=tObj.id;
		}
		else if(tObj==cell && sObj!=cell ){
		if(source) source+=','+sObj.id
		else source=sObj.id;
		}
   }

}

//判断流程中的表是否由仅有一个输入（仅考虑输出表，即作为线段末端的表）
function isTabHasOneProcInput(tabCell)
{
	//1、先从本图找
	if(tabCell.getEdgeCount() > 1)
	{
		var srcProcCount = 0;
		for(var i=0; i<tabCell.getEdgeCount(); i++)
		{
			var edge = tabCell.getEdgeAt(i);
			var source = edge.source;
			if(tabCell == edge.target && source && OBJ_TYPE.PROC == source.objType)
			{
				srcProcCount ++ ;
			}

			if(srcProcCount > 1)
			{
				return false;
			}
		}
	}

	//2、再从全局transdatamap_design找
	var ds_transMap = new AI.JsonStore({
		sql:"select count(1) RESCOUNT"
		 	+ " from  transdatamap_design where target = '"+tabCell.id+"'"
		 	+ " and targettype = 'DATA' and flowcode<>'"+FLOWCODE+"'",
		loadDataWhenInit:true,
		pageSize:-1,
		table:"transdatamap_design",
		key:"XMLID"
	});	

	if (ds_transMap.getCount() > 0 && ds_transMap.getAt(0).get('RESCOUNT') > 0)
	{
		return false;
	}


	return true;
}
//判断是否是维表
var isDimTab = function (xmlid){
	var tabStore = ai.getStore("select xmlid,dataname from transflowobj_static where xmlid='"+xmlid+"'");
	if(typeof(tabStore) != "undefined"&&tabStore.count>0){
		return true;
	}
	return false;
};
//判断是否是维表
var isNotExist = function (proc_name){
	var procStore = ai.getStore("select proc_name from proc_schedule_info where proc_name='"+proc_name+"'");
	if(procStore.count>0){
		return false;
	}
	return true;
};

function getSeqNo(){
	var now = new Date();
	now = now.format("yyyyMMddhhmmss") +"0"+ now.getMilliseconds();
	return now;
}

//提交调度信息响应函数
var saveScheduleToDb = function(msg){
	var graph =  editor.graph;
	var parent = graph.getDefaultParent();
	if(!graphStore) return;
	if( graphStore.getCount()==0) return;
	
	//transdatamap_design中的周期
	var transRunFreq = freqType[graphStore.getAt(0).get('CYCLETYPE')] + '-0';
	var procSql="select cycletype from proc where xmlid='{}'";
	var procFreq = "day";
	
	//空的任务纪录
	var procScheduleLogStore=new AI.JsonStore({
		sql:"select * from proc_schedule_log where 1=2",
		table:"PROC_SCHEDULE_LOG",
		key:"PROC_NAME",
		dataSource:"METADBS"
	});

	//原来的调度信息
	var old_ds_transDataMap = new AI.JsonStore({
		sql:"select flowcode, transname, source, sourcetype, sourcefreq, target, targettype, targetfreq"
			+ " from transdatamap_design_manual where flowcode='"+FLOWCODE+"'",
		loadDataWhenInit:true,
		pageSize:-1,
		table:"TRANSDATAMAP_DESIGN_MANUAL",
		key:"FLOWCODE",
		dataSource:"METADBS"
	});

	//删除原有信息
	var sql_del_transDataMap = "delete from transdatamap_design_manual where flowcode='"+FLOWCODE+"'";	
    	ai.executeSQL(sql_del_transDataMap,false,"METADBS");

	//准备需插入的空对象
    var ds_transDataMap = new AI.JsonStore({
		sql:"select flowcode, transname, source, sourcetype, sourcefreq"
			+ ", target, targettype, targetfreq"
			+ " from  transdatamap_design_manual where 1<>1 ",
		loadDataWhenInit:true,
		pageSize:-1,
		table:"TRANSDATAMAP_DESIGN_MANUAL",
		key:"FLOWCODE",
		dataSource:"METADBS"
	});
	
	//开始遍历筛选
	var childCount=graph.model.getChildCount(parent); 	 
	for(var i=0;i<childCount;i++){
		var child = graph.model.getChildAt(parent, i);

		//判断是否含有未初始化节点
		if((child.isVertex()) && (OBJ_TYPE.PROC == child.objType || OBJ_TYPE.TAB == child.objType)
			&& (!child.xmlid))
		{
			alert('流程图中存在未初始化节点，请完善信息后再提交！\n保存临时调度信息失败！');
			return false;
		}
		
		//首节点判断
		if(child.xmlid && isFirstProcObj(child)){
			if(OBJ_TYPE.PROC!= child.objType){
				alert('临时调度中首节点必须是程序！\n保存临时调度信息失败！');
				return false;
			}else{
				//首节点任务
				var firstTask = ai.getStore("select a.*,b.runpara,b.proctype,b.path,b.team_code from proc_schedule_info a inner join proc b on a.xmlid = b.xmlid where a.xmlid = '"+child.xmlid+"'","METADBS");
				if(firstTask.count>0){
					var newLog = procScheduleLogStore.getNewRecord();
					var dateArgs = $("#date_args").val();
					if(firstTask.root[0].RUN_FREQ.toLocaleLowerCase()=="month"){
						dateArgs+="-01";
					}
					newLog.set("seqno", getSeqNo());
					newLog.set("xmlid", firstTask.root[0].XMLID);
					newLog.set("proc_name", firstTask.root[0].PROC_NAME);
					newLog.set("task_state", 1);
					newLog.set("start_time", new Date().format("yyyy-MM-dd hh:mm:ss"));
					newLog.set("status_time", new Date().format("yyyy-MM-dd hh:mm:ss"));
					newLog.set("retrynum", 0);
					newLog.set("date_args", dateArgs);
					newLog.set("proc_date", dateArgs.replaceAll("-", "").replaceAll(" ", ""));
					newLog.set("queue_flag", 0);
					newLog.set("trigger_flag", 0);
					newLog.set("platform", firstTask.root[0].PLATFORM);
					newLog.set("agent_code", firstTask.root[0].AGENT_CODE);
					newLog.set("pri_level", firstTask.root[0].PRI_LEVEL);
					newLog.set("run_freq", firstTask.root[0].RUN_FREQ);
					newLog.set("team_code", firstTask.root[0].TEAM_CODE);
					newLog.set("time_win", firstTask.root[0].TIME_WIN);
					newLog.set("flowcode", FLOWCODE);
					newLog.set("runpara", firstTask.root[0].RUNPARA);
					newLog.set("proctype", firstTask.root[0].PROCTYPE);
					newLog.set("path", firstTask.root[0].PATH);
					newLog.set("valid_flag", 0);
					procScheduleLogStore.add(newLog);
				}else{
					alert("未找到首节点任务的配置信息！")
					return false;
				}
			}
		}

		//1、保存程序节点
		if((child.isVertex()) && (OBJ_TYPE.PROC == child.objType)){
			//var trigger_type = isFirstProcObj(child)?0:1;
			var trigger_type = 1;
			var _now = new Date();
			var curTime =  _now.format("yyyy-mm-dd hh:mm:ss").substr(0,10);
		    //检查首节点是否有前序节点！
            var procBaseStore = ai.getStore(procSql.replace("{}",child.getId()),"METADBS");
            if(procBaseStore&&procBaseStore.count==1){
            	procFreq = (procBaseStore.root[0])["CYCLETYPE"];
            }else{
            	procFreq = graphStore.getAt(0).get('CYCLETYPE');
            }
           	// 判断当前程序的调度配置是否存在
			// 临时调度值选取已上线的数据
		}

		//2、保存数据与程序之间的依赖关系
		if(child.isEdge()){	
			var preVetex = child.source;
			var backVetex = child.target; 
			var preVxType = preVetex.objType;
			var backVxType = backVetex.objType;
			var rec = null;

			//目标与源周期
			var targetfreq = transRunFreq; 
			var sourcefreq = targetfreq;	
			//仅处理表及程序（从线末端判断）
			if(OBJ_TYPE.PROC == backVxType){ //末端是程序	

				if(OBJ_TYPE.PROC == preVxType){//前端是程序	
					rec = ds_transDataMap.getNewRecord();//双向插入第二次开始
					rec.set("TRANSNAME", backVetex.xmlid);
					rec.set("SOURCE", preVetex.xmlid);
					rec.set("SOURCETYPE", "PROC");
					rec.set("SOURCEFREQ", sourcefreq);
					rec.set("TARGET", backVetex.xmlid);
					rec.set("TARGETTYPE", "PROC");
					rec.set("TARGETFREQ", targetfreq); 	 	 			
				}else if(OBJ_TYPE.TAB == preVxType){//前端是数据
					rec = ds_transDataMap.getNewRecord();
					rec.set("TRANSNAME", backVetex.xmlid);
					rec.set("SOURCE", preVetex.xmlid);
					rec.set("SOURCETYPE", "DATA");
					rec.set("SOURCEFREQ", sourcefreq);
					if(OBJ_TYPE.TAB==preVxType&&isDimTab(preVetex.xmlid)){
						rec.set("SOURCEFREQ", "N");  
					}
					rec.set("TARGET", backVetex.xmlid);
					rec.set("TARGETTYPE", "PROC");
					rec.set("TARGETFREQ", targetfreq);
				}else if(OBJ_TYPE.EVENT==preVxType){//前端是事件
					rec = ds_transDataMap.getNewRecord();
					rec.set("TRANSNAME", backVetex.xmlid);
					rec.set("SOURCE",preVetex.getId());
					rec.set("SOURCETYPE", OBJ_TYPE.EVENT);
					rec.set("SOURCEFREQ", sourcefreq);
					rec.set("TARGET", backVetex.xmlid);
					rec.set("TARGETTYPE", "PROC");
					rec.set("TARGETFREQ", targetfreq);
				} else if(OBJ_TYPE.INTER == preVxType){
					rec = ds_transDataMap.getNewRecord();
					rec.set("TRANSNAME", backVetex.xmlid);
					rec.set("SOURCE", preVetex.xmlid);
					rec.set("SOURCETYPE", OBJ_TYPE.INTER);
					rec.set("SOURCEFREQ", sourcefreq);
					rec.set("TARGET", backVetex.xmlid);
					rec.set("TARGETTYPE", "PROC");
					rec.set("TARGETFREQ", targetfreq);
				}
			}else if(OBJ_TYPE.TAB == backVxType){//末端是数据

				//!硬性条件限制：同一个表仅能有一个程序作为输入
				if(!isTabHasOneProcInput(backVetex))
				{
					alert("表名为" + backVetex.xmlid + "的数据不能由2个及以上的程序触发！\n保存调度信息失败！");
					return false;
				}

				if(OBJ_TYPE.PROC == preVxType){//前端是程序
					rec = ds_transDataMap.getNewRecord();
					rec.set("TRANSNAME", preVetex.xmlid);
					rec.set("SOURCE", preVetex.xmlid);
					rec.set("SOURCETYPE", "PROC");
					rec.set("SOURCEFREQ", sourcefreq);
					rec.set("TARGET", backVetex.xmlid);
					rec.set("TARGETTYPE", "DATA");
					rec.set("TARGETFREQ", targetfreq);
				}
			}

			if(rec){//满足条件
				rec.set("FLOWCODE", FLOWCODE);
				ds_transDataMap.add(rec);
			}
		}//end if 2
	} //end for
	var rs = true;
	
	var retTransDataMap = ds_transDataMap.commit(false);
	
	if((true == retTransDataMap || eval("("+retTransDataMap+")").success) ){
		msg+='\n保存临时调度信息成功！';
		//开始执行首节点任务
		procScheduleLogStore.commit(false)
	}else{
		//删除新入的数据
		ai.executeSQL(sql_del_transDataMap,false,"METADBS");
		//导入原来的数据
		old_ds_transDataMap.commit(false);
		msg+='\n保存临时调度信息失败!';
		rs=false;
	}
	alert(msg);
	return rs;
}; 

//end schedule*************************************************************

function getObjByValue(value){
	var _result=null;
	var parent = graph.getDefaultParent();
	var childCount=graph.getModel().getChildCount(parent);
	for (var i=0;i<childCount;i++){
		var child=graph.getModel().getChildAt(parent,i);
		if(child.value==value) {_result=child;break;}
	}
	return _result;
};
function getObjSourceTargetXMLID(cell){
	 
   var source="",target="";
   for(var j = 0;j< cell.getEdgeCount();j++){
       var edge = cell.getEdgeAt(j);
       var sObj=edge.source;
       var tObj=edge.target;
       if(!tObj || !sObj) continue;
       if(sObj==cell && tObj!=cell ){
       	if(target) target+=','+tObj.xmlid  
       	else target=tObj.xmlid;
       }
       else if(tObj==cell && sObj!=cell ){
       	if(source) source+=','+sObj.xmlid
       	else source=sObj.xmlid;
       }
   }
   return source+";"+target;
};
function getObjSourceTargetId(cell){
   var source="",target="";
   for(var j = 0;j< cell.getEdgeCount();j++){
       var edge = cell.getEdgeAt(j);
       var sObj=edge.source;
       var tObj=edge.target;
       if(!tObj || !sObj) continue;
       if(sObj==cell && tObj!=cell ){
       	if(target) target+=','+tObj.id  
       	else target=tObj.id;
       }
       else if(tObj==cell && sObj!=cell ){
       	if(source) source+=','+sObj.id
       	else source=sObj.id;
       }
   }
   return source+";"+target;
};

function getObjSourceTarget(cell){
   var source="",target="";
   function getSourceObj(theCell){
   	for(var j = 0;j< theCell.getEdgeCount();j++){
   		 var edge = theCell.getEdgeAt(j);
       var sObj=edge.source;
       var tObj=edge.target;
       if(!tObj || !sObj) continue;
      
       if(tObj==theCell && sObj!=theCell ){
       	  var objtype =sObj.objType;
       	  if(objtype=='datasource' || objtype == 'dataout'){
       	  	 var tmpstr=sObj.value;
       	  	 if(source) source+=','+ tmpstr   
       		   else source=tmpstr;
       	  }
       	  else{
       	  	getSourceObj(sObj)
       	  }
       }
   	}  
   };
   getSourceObj(cell);
   
   function getTargetObj(theCell){
   	for(var j = 0;j< theCell.getEdgeCount();j++){
   		 var edge = theCell.getEdgeAt(j);
       var sObj=edge.source;;
       var tObj=edge.target;
       if(!tObj || !sObj) continue;
      
       if(sObj==theCell && tObj!=theCell ){
       	  var objtype =tObj.objType;
       	  if(objtype=='datasource' || objtype == 'dataout'){
       	  	 var tmpstr=tObj.value;
       	  	 if(target) target+=','+ tmpstr   
       		   else target=tmpstr;
       	  }
       	  else{
       	  	getTargetObj(tObj)
       	  }
       }
   	}  
   };
   getTargetObj(cell);
   
   return source+";"+target;
};

//获取某类节点对象名称，返回值格式：''或'proc1','proc2'...
function getObjNamesInGraph(cell)
{
	var objType = cell.objType;
	var objId  = cell.id;
	var parent = graph.getDefaultParent();
	var childCount = graph.getModel().getChildCount(parent);
	var procNames = [];
	for (var i=0; i<childCount; i++){
		var child = graph.getModel().getChildAt(parent,i);
		//只统计已初始化过的程序节点
		if(objType == child.objType && child.xmlid &&child.id!=objId)
		{
			procNames.push("'" + child.xmlid + "'");
		}		
	}

	if(0 == procNames)
		return "''";
	else
		return procNames.join(',');
};

function GraphPropotyInit(){
	// Extends EditorUi to update I/O action states
	var editorUiInit = EditorUi.prototype.init;

	if(paramMap.hidemenu != 'n') {
		EditorUi.prototype.menubarHeight = 0;
		EditorUi.prototype.footerHeight = 0;
	};
	// EditorUi.prototype.menubarHeight = 0;
	//      EditorUi.prototype.toolbarHeight=0;
	//    EditorUi.prototype.footerHeight=0; 
	EditorUi.prototype.splitSize = (mxClient.IS_TOUCH) ? 6 : 4;
	EditorUi.prototype.init = function() {
		editorUiInit.apply(this, arguments);
	};
	EditorUi.prototype.savetoDatabase = function(xmltext) {
		savetoDatabaseFlow(xmltext);
	};
	EditorUi.prototype.setProcState = function(state){
		var procStore = new AI.JsonStore({
			sql:"SELECT * FROM proc WHERE proc_name IN (SELECT proc_name FROM proc_schedule_info WHERE flowcode = '"+FLOWCODE+"')",
			loadDataWhenInit:true,
			pageSize:-1,
			table:"PROC",
			key:"XMLID"
		});
		for(var i=0;i<procStore.getCount();i++){
			var r = procStore.getAt(i);
			r.set('STATE',state);
		}
		procStore.commit();
		ai.executeSQL("UPDATE transflow SET state='"+state+"' WHERE flowcode='"+FLOWCODE+"'");
		if(state=='UNPUBLISH'){
			/*ai.executeSQL("delete from proc_schedule_log where flowcode='"+FLOWCODE+"'");
			ai.executeSQL("delete from proc_schedule_source_log where flowcode='"+FLOWCODE+"'");
			ai.executeSQL("delete from proc_schedule_meta_log where flowcode='"+FLOWCODE+"'");
			ai.executeSQL("delete from proc_schedule_script_log where flowcode='"+FLOWCODE+"'");*/
		}
	};
	
	EditorUi.prototype.setProcsOnline = function() {
		this.setProcState('UNPUBLISH');
		alert("已提交申请");
	};
	EditorUi.prototype.setProcsOffline = function() {
		this.setProcState('UNPUBLISH');
		alert("已提交申请");
	};
};

//begin 以拖拽方式创建或选择对象所用函数 ******************************************
//处理新建对象	
function doCreateObj(cell)
{
	var objtype = cell.objType;

	var metaInfo=meta.metaStore[objtype];
	if(!metaInfo){alert('未知对象:'+objtype+",无法创建");return false};
	
	function beforeSave(fieldVal){
		console.log(fieldVal);
		if(!fieldVal.OBJNAME && !fieldVal[metaInfo.KEYFIELD]){alert('请填写名称');return false};
		if(!fieldVal.OBJCNNAME && !fieldVal[metaInfo.NAMEFIELD]){alert('请填写中文名称');return false};
		if(!fieldVal.OBJCNNAME && fieldVal[metaInfo.NAMEFIELD]){fieldVal.OBJCNNAME=metaInfo.NAMEFIELD };
		if(!fieldVal.OBJNAME && fieldVal[metaInfo.KEYFIELD]){fieldVal.OBJNAME=fieldVal[metaInfo.KEYFIELD]};
		return true;
		
	};
	function aftSave(fieldVal,objstore){
		if(!fieldVal.OBJNAME && fieldVal[metaInfo.KEYFIELD]){fieldVal.OBJNAME=fieldVal[metaInfo.KEYFIELD]};
		if(!fieldVal.OBJCNNAME && fieldVal[metaInfo.NAMEFIELD]){fieldVal.OBJCNNAME=fieldVal[metaInfo.NAMEFIELD] };
		if(objstore.curRecord){
			fieldVal.OBJNAME = objstore.curRecord.get('OBJNAME');
			fieldVal.OBJCNNAME = objstore.curRecord.get('OBJCNNAME');
			fieldVal.XMLID = objstore.curRecord.get('XMLID');
		}
		refreshCurCell(cell, fieldVal.OBJNAME,fieldVal.OBJCNNAME,fieldVal.XMLID);
	};

	meta.registNewMetaObj(objtype,beforeSave,aftSave); 
};
//处理选择对象
function doSelectObj(cell)
{
	function afterSelect(rs){
		for(var i=0;i<rs.length;i++){
		 	var r=rs[i];
		 	refreshCurCell(cell,r.get('VALUES1'),r.get('VALUES2'),r.get('KEYFIELD'));
		};
	};
    var selSql ="";
    if(cell.objType==OBJ_TYPE.EVENT){ 
    	selSql="select objname VALUES1,objcnname VALUES2,REMARK VALUES3,xmlid KEYFIELD from metaobj"
	 	+ " where  objtype='PROC' and objname not in (''," + getObjNamesInGraph(cell) + ")";
    }else if(cell.objType==OBJ_TYPE.TAB){
	    //限制：同一个程序只能参与一次调度
	    selSql="select objname VALUES1,objcnname VALUES2,dbname VALUES3,xmlid KEYFIELD from metaobj"
	 	+ " where objtype='" + cell.objType + "'"
	 	//已在图中的也不可选
	 	+ " and objname not in (''," + getObjNamesInGraph(cell) + ")";
	 }else if(cell.objType==OBJ_TYPE.PROC){
		 //临时调度 只选取生产库已上线的任务
	 	//限制：同一个程序只能参与一次调度
	    selSql=" SELECT a.proc_name VALUES1,a.proccnname VALUES2,a.REMARK VALUES3,a.xmlid KEYFIELD FROM proc a"
	          +" LEFT JOIN proc_schedule_info b ON a.xmlid=b.xmlid WHERE 1=1 and a.state='VALID' "
              //周期一致
	          +" and CYCLETYPE='"+CYCLETYPE+"'"
	 	      //已在图中的也不可选
	 	      +" and a.xmlid not in (''," + getObjNamesInGraph(cell) + ")";
	 }else{
	 	selSql="select objname VALUES1,objcnname VALUES2,REMARK VALUES3,xmlid KEYFIELD from metaobj"
	 	+ " where  objtype='"+cell.objType+"'";
	}
     var selBox=new SelectBox({sql:selSql,selectedValue:cell.value,callback:afterSelect,dataSource:"METADBS"});
     selBox.show();
     $("#selectgrid .sortable:lt(2)").prop("width","200px");
     $("#resultgrid .sortable:lt(2)").prop("width","200px");
};
//更新具体的cell对象
function refreshCurCell(cell,objname,objcnname,xmlid)
{
	if(OBJ_TYPE.TAB==cell.objType){
		cell.id = xmlid
	}else{
        cell.id = objname
	}
	cell.value= objname;
	cell.cnname=objcnname;
	cell.xmlid = xmlid;
	//针对程序，扩充xml内容
	if(OBJ_TYPE.PROC == cell.objType)
	{
		//默认值
		cell.triggerType = '1';  //触发类型:0时间触发，1事件触发
		cell.cronExp = '';  //cron表达式
		cell.priLevel = 10;  //优先级：5低，10中，15高

		//如果是选择的对象，从proc_schedule_info获取
		var ds_procInfo = new AI.JsonStore({
			sql:"select agent_code, muti_run_flag"
			 	+ " from  PROC_SCHEDULE_INFO where proc_name = '"+objname+"'",
			loadDataWhenInit:true,
			pageSize:-1,
			table:"PROC_SCHEDULE_INFO",
			key:"FLOWCODE"
		});	

		//与proc_schedule_info关联的值
		if (ds_procInfo.getCount() > 0)
		{
			cell.agentCode = ds_procInfo.getAt(0).get('AGENT_CODE');	//agent名称	
			cell.mutiRunFlag = ds_procInfo.getAt(0).get('MUTI_RUN_FLAG'); //是否单一启动：0否，1是
		}
		else
		{
			cell.agentCode = '';		
			cell.mutiRunFlag = '0';	
		}
	}
	//更新显示
	graph.refresh(cell);
};

//end以拖拽方式创建或选择对象所用函数**********************************************

function extendUi(ui){//扩展UI界面
	/*
	ui.toolbar.addItem('glyphicon glyphicon-cloud-upload','online','申请上线');
	ui.toolbar.addSeparator();
	ui.toolbar.addItem('glyphicon glyphicon-cloud-download','offline','申请下线');
	ui.toolbar.addSeparator();*/
	ui.toolbar.addButton('glyphicon glyphicon-file','导入导出',importOrExportProc,'导入导出');
	graph.setTooltips(false);
	
	$(ui.toolbar.container).append("<span>日期批次：<input id='date_args' type='text' placeholder='yyyy-MM-dd hh mm' /></span>");
    //开始执行按钮
	ui.toolbar.addItem('glyphicon glyphicon-play','save','开始执行');
	ui.toolbar.addSeparator();

};
//构造sidebar所需参数
	var flowSiderBar = {};
	//icon路径
	flowSiderBar['iconPath'] = IMAGE_PATH;
	//组内对象,暂时直接定义，以后组内对象从xml或数据库读取
	/*为区分是创建还是新建，暂时以定义的顺序号作为判断依据：1为创建、2为选择
	  以后如果从数据库读取时请使用1.xx 2.xx的形式方便sql排序,为了兼容，迫不得已！
	*/
	flowSiderBar['groupItems'] = 
		{
			"创建对象" :
			[  {
					"name" : "接口",
					"icon" : "inter.png",
					"id" : 'INTER'
				},
				{
					"name" : "程序",
					"icon" : "proc.png",
					"id" : 'PROC'
				},
				{
					"name" : "表",
					"icon" : "tab.png",
					"id" : 'TAB'
				},
				{
					"name" : "指标",
					"icon" : "zb.png",
					"id" : 'ZB'
				},
				{
					"name" : "应用",
					"icon" : "rep.gif",
					"id" : 'APPREP'
				}
			],

			"选择对象" : 
			[  /*{
					"name" : "接口",
					"icon" : "inter.png",
					"id" : 'INTER'
				},*/
				{
					"name" : "程序",
					"icon" : "proc.png",
					"id" : 'PROC'
				}/*,
				{
					"name" : "表",
					"icon" : "tab.png",
					"id" : 'TAB'
				},{
					"name" : "指标",
					"icon" : "zb.png",
					"id" : 'ZB'
				},{
					"name" : "应用",
					"icon" : "rep.gif",
					"id" : 'APPREP'
				},
				{   
					"name" : "事件源",
					"icon" : "relay_gray.png",
					"id"   : 'EVENT'
				}*/
			]

		};

//对象查看或双击响应函数
function manageObj(cell)
{	
	//以xmlid作为是否被初始化的依据
	if(!cell.xmlid)
	{
		if('create' == cell.state)
		{
			doCreateObj(cell);
		}
		else
		if('select' == cell.state)
		{	
			doSelectObj(cell);
		}
	}
	else //已初始化
	{
		if(OBJ_TYPE.PROC == cell.objType||OBJ_TYPE.EVENT==cell.objType)
			window.open("/"+contextPath+"/devmgr/WizCreETL.html?OBJNAME="+cell.xmlid)
		else if(OBJ_TYPE.TAB == cell.objType)
			window.open("/"+contextPath+"/devmgr/WizCreTable.html?OBJNAME="+cell.xmlid)
		else if("ZB" == cell.objType)
			window.open("/"+contextPath+"/devmgr/WizCreZB.html?OBJTYPE=ZB&OBJNAME="+cell.xmlid)
		else if("APPREP" == cell.objType)
			window.open("/"+contextPath+"/apptools/appide/index.html?APPCODE="+cell.xmlid)			
	}
};

//导入导出
var importOrExportProc = function(){
	var enc = new mxCodec(mxUtils.createXmlDocument());
	var node = enc.encode(graph.getModel());
	var xml = mxUtils.getPrettyXml(node);
	var formcfg = ({
            	 title:'导入/导出XML',
            	  lock:true,
                store: null,
                items: [
                {label:'xml',fieldName:'xml',width:"100%", type:'textarea',value:xml}
                ]
            });
	  function afterOk(fieldVals){
	   
	  	 var xml=fieldVals.xml;
	  	 if (xml != null && xml.length > 0){
					var doc = mxUtils.parseXml(xml); 
					var dec = new mxCodec(doc); 
					dec.decode(doc.documentElement, graph.getModel()); 
		}
	  };
	   ai.openFormDialog('导入/导出',formcfg.items,afterOk);
	   	     
};


$(document).ready(function(){
 
	GraphPropotyInit();

	editor = new Editor();
	//为不受数据处理模块逻辑影响，此属性必须赋值为空
	editor.loadwidgetSql="";
	//构造sidebar所需参数
	editor.flowSiderBar = flowSiderBar;

	graph = editor.graph;
	ui = new EditorUi(editor);

	extendUi(ui);

	var currentCell=null;
	loadfromDatabaseFlow();
	
	graph.click=function(evt,cell){return false;};
	var afterFunctionOkClick=function(formVals){
		currentCell.script=ai.encode(formVals)
		return true;
	};
	graph.dblClick=function(evt,cell){
		if(!cell) return;		
		manageObj(cell);
		currentCell=cell;
		return false;
	};
 	// 覆写右键单击事件  
	graph.panningHandler.factoryMethod = function(menu, cell, evt){
		if(cell && (OBJ_TYPE.PROC == cell.objType || OBJ_TYPE.TAB == cell.objType)){

			if(!cell.xmlid) //还未创建
			{
				if('create' == cell.state)
				{
					menu.addItem(('PROC' == cell.objType) ? '创建程序' : '创建表',
						null ,function(){
						doCreateObj(cell);
					});
				}
				else
				if('select' == cell.state)
				{
					menu.addItem(('PROC' == cell.objType) ? '选择程序' : '选择表',
						null ,function(){
						doSelectObj(cell);
					});

				}
			}
			else//已创建
			{
				if(OBJ_TYPE.TAB == cell.objType)
				{
					menu.addItem('查看', null ,function(){
						window.open("/"+contextPath+"/devmgr/WizCreTable.html?OBJNAME="+cell.xmlid);
					});
					menu.addItem('重新选择', null ,function(){
						doSelectObj(cell);
					});	
				}
				else
				if(OBJ_TYPE.PROC == cell.objType)
				{
					menu.addItem('配置调度', null ,function(){
						if($("#ge-editor #schedule_modal").length==0){
							$("#ge-editor").append('<div id="schedule_modal" class="modal fade">'
							+'<div class="modal-dialog">'
							+'<div class="modal-content">'
							+'<div class="modal-header">'
							+'<button type="button" class="close" data-dismiss="modal">'
							+'<span aria-hidden="true">&times;</span><span class="sr-only">Close</span>'
							+'</button>'
							+'<h4 class="modal-title" id="genaral_modal_title">调度配置</h4>'
							+'</div>'
							+'<div class="modal-body" id="schedule_modal_content"></div>'
							+'<div class="modal-footer">'
							+'<button type="button" class="btn btn-default" id="save-proc-schedule">保存</button>'
							+'<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>'
							+'</div>'
							+'</div>'
							+'</div>'
							+'</div>');
						}
						var $el = $("#ge-editor #schedule_modal");
						$el.find('#schedule_modal_content').empty();
						var _store = new AI.JsonStore({
							sql:"SELECT a.PROC_NAME,b.PRI_LEVEL,b.MUTI_RUN_FLAG,b.AGENT_CODE ,c.flowcode,c.cycletype RUN_FREQ,c.CRON_EXP FROM proc a,proc_schedule_info b JOIN transflow c ON c.flowcode='"+FLOWCODE+"' WHERE a.proc_name=b.proc_name and a.xmlid='"+cell.xmlid+"'",
							key:"PROC_NAME",
							table:"PROC_SCHEDULE_INFO"
						});
						var formcfg = ({
							id : 'form',
							store : _store,
							containerId : 'schedule_modal_content',
							items : [
								{type:'combox',label:'优先级',fieldName:'PRI_LEVEL',width:300,storesql:"15,高|10,中|5,低", value: cell.priLevel || '10'},
								{type:'combox',label:'执行模式',fieldName:'MUTI_RUN_FLAG', width : 300,storesql:"1,多重启动|0,单一启动", value: cell.mutiRunFlag || '0'},
								{type:'combox',label:'AGENT',fieldName:'AGENT_CODE',width:300,storesql:"select agent_name from aietl_agentnode", value: cell.agentCode},
							]
						});
						var scheduleForm = new AI.Form(formcfg);
						$el.modal({
							backdrop:false,
							show:true
						}).css('top','90px');
						$el.find("#save-proc-schedule").on("click",function(){
							//将所选信息存储cell中
							cell.priLevel = $('#PRI_LEVEL').val();
							cell.mutiRunFlag = $('#MUTI_RUN_FLAG').val();
							cell.agentCode = $('#AGENT_CODE').val();

							$el.modal("hide");
						});
					});
					menu.addItem('查看', null ,function(){
						window.open("/"+contextPath+"/devmgr/WizCreETL.html?OBJNAME="+cell.xmlid);
					});
					menu.addItem('重新选择', null ,function(){
						doSelectObj(cell);
					});	
				}

			}

		}
	};  
	editor.modified=false;
	$(".geSidebarContainer").children(0).eq(0).hide();
});
</script>
</head>
<body class="geEditor" id="ge-editor">
</body>
</html>
