<!DOCTYPE html>
<html>
<head>      
	<meta charset="utf-8" />         
	<title>大数据开放平台</title>     
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-lib/datepicker/datepicker.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-res/task/css/implWidgets.css" type="text/css" rel="stylesheet"  />
	<link href="${mvcPath}/dacp-view/aijs/css/ai.css" type="text/css" rel="stylesheet"  />
	<link href="${mvcPath}/dacp-view/css/zTreeStyle.css" type="text/css" rel="stylesheet"> 
	<script src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js" type="text/javascript"></script>
	<script src="${mvcPath}/dacp-view/js/jquery.ztree.all-3.5.min.js" type="text/javascript"></script>
	<!-- 使用ai.core.js需要将下面两个加到页面 -->
	<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
	<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>
	
	<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>
		
	<style type="text/css">
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
.line{
	height:initial;
}

</style>
<script>
var  buildZtree=[];
var setting = {
		check: {
			enable: true
		},
		data: {
			simpleData: {
				enable: true
			}
		}
	};
function getSeqNo(){
	var now = new Date();
	now = now.format("yyyyMMddhhmmss") +"0"+ now.getMilliseconds();
	return now;
}
$(function(){
	var _seqno=paramMap["seqno"];
	var procName=paramMap["procName"];
	var dataArgs=paramMap["dateArgs"];
	var template='<section class="panel panel-default">'
			+ '<header class="panel-heading"> 临时重做任务 '
			+ '<div class="pull-right media-xs text-center text-muted"> '
			+'<strong class="h4"><button id="pullright" class="btn btn-xs btn-success">保存</button></strong>'
			+ '</div> </header>'
			+ '<article class="media" style="overflow:auto">'
			+ '<div class="media-body" style="margin:0px 40px 40px 40px;">'
			+ '<small class="block"><span>选择程序：</span></small>'
			+ '<small class="block" ><pre style="white-space: pre-wrap;">'
			+'<ul id="treeDemo" class="ztree"></ul><ul id="code" class="log" style="height:20px;"></ul>'
			+'</pre></small>'
			+ '</div>'
			+ '</article>'
			+'</section>';
	openTableInfo("log",procName,template,true);
	// var  nodeData=getZtree(_seqno);
	$(".op-bt-closeall").click(function(){
		window.close();
	})
	$.ajax({
		url:'/'+contextPath+'/flow/getZTreeNode/'+_seqno,
		async:false,
		error:function(){     
		       alert('网络错误！');
		       return;
		   	},
		success:function(msg){
			// var msg = $.parseJSON(msg);
			if(msg!=null&&msg!=""){
			    buildZtree = eval(msg);
			    $.fn.zTree.init($("#treeDemo"), setting,buildZtree);
			}else{
				alert('获取运行日志失败');
				return;
			}
		}
	});

	$("#pullright").on('click',function(){
		var zTree = $.fn.zTree.getZTreeObj("treeDemo");
			nodes = zTree.getCheckedNodes();
		var setTransDataMapSql ="insert into transdatamap_design_manual (FLOWCODE,TRANSNAME,SOURCE,SOURCETYPE,SOURCEFREQ,TARGET,TARGETTYPE,TARGETFREQ) values(";
			if(nodes.length>=1){
				if(confirm("确定重做当前任务?")){
					var flowCode = ai.guid();
					var proc_name= nodes[0].name;
					var logStore = getValidStore(_seqno);
					if(!logStore) {
						alert("该批次已被重做，当前记录失效！")
						return;
					}
					var updateProcSql = "update proc_schedule_log set flowCode='"+flowCode+"' where 1=1";
					for(var i=nodes.length-1;i>=0;i--){
						var node=nodes[i];
						if(node.source!=node.target){
							var sql = updateProcSql+" and proc_name='"+node.name+"' and  date_args='"+dataArgs+"'";
							var insertSql=setTransDataMapSql+"'"+flowCode+"','"+node.target+"','"+node.source+"','PROC','"+node.sourcefreq+"','"+node.target+"','PROC','"+node.targetfreq+"')";
							ai.executeSQL(insertSql,false,"METADBS");
							ai.executeSQL(sql,false,"METADBS");
						}
						
					}

					var date = new Date();
					_dateStr = date.format("yyyy-mm-dd hh:mm:ss");
					var sql1=" update proc_schedule_log set valid_flag=1,status_time='"+_dateStr+"' where seqno='"+_seqno+"' and ( task_state=6 or task_state>=50 ) ";
					var sql2=" update proc_schedule_script_log set app_log=CONCAT(app_log,'\\n \\n【前置任务重做，此任务失效】') where seqno='"+_seqno+"' ";
					ai.executeSQL(sql1,false,"METADB");
					ai.executeSQL(sql2,false,"METADB");

					//录入一条重做记录
					var newlog = logStore.getAt(0);
					newlog.set("SEQNO",getSeqNo());
					newlog.set("TASK_STATE",0);
					newlog.set("START_TIME",_dateStr)
					newlog.set("EXEC_TIME",null)
					newlog.set("END_TIME",null)
					newlog.set("STATUS_TIME",_dateStr);
					newlog.set("QUEUE_FLAG",0); 
					newlog.set("TRIGGER_FLAG",0);
					newlog.set("VALID_FLAG",0);
					newlog.set("RETURN_CODE",0);
					newlog.set("AGENT_CODE",newlog.data.AGENT_CODE);
					newlog.set("FLOWCODE",flowCode);
					logStore.add(newlog);
					logStore.commit(false);
					alert("临时重做任务生效！");
				}
		}else{
			alert("请选择程序！");
		}
	});

	function getValidStore(seqno){
		var store = new AI.JsonStore({
			sql :"select * from proc_schedule_log where seqno='"+seqno+"' and valid_flag=0",
			table:'proc_schedule_log',
			key:"SEQNO",
			dataSource:"METADBS"
		});
		if(store.count>0)return store;
		return null;
	}	
});

function openTableInfo(tabname, title, template, flag) {
	$("#panel1 #tab_fullname").empty().append(title); //标题

	$("#panel1 #op-panelContent").empty().append(template);//内容
	$("#panel1").triggerHandler("finishRender");//注册后续触发时间
	$("#panel1 .op-bt-close.op-panelChange").attr("id", "push-left-" + tabname);
	$("#panel1").css("z-index", 10011).slideDown(function() {
		
		if (tabname.indexOf("ana") != -1) {
			var _type = tabname.split("-")[1];
			$("#panel1 #op-panelContent")
			.empty()
			.append('<span style="display: inline-block; vertical-align: top; padding: 5px; width: 100%"><div id="myDiagram" style="background-color: Snow;"></div></span>');
			init(_type.toLowerCase(), template);
		} else if (tabname === 'focusMonitor') {
		}
	});
	return false;
};

var code;

function setCheck() {
	var zTree = $.fn.zTree.getZTreeObj("treeDemo"),
	py = $("#py").attr("checked")? "p":"",
	sy = $("#sy").attr("checked")? "s":"",
	pn = $("#pn").attr("checked")? "p":"",
	sn = $("#sn").attr("checked")? "s":"",
	type = { "Y":py + sy, "N":pn + sn};
	zTree.setting.check.chkboxType = type;
	showCode('setting.check.chkboxType = { "Y" : "' + type.Y + '", "N" : "' + type.N + '" };');
}
function showCode(str) {
	if (!code) code = $("#code");
	code.empty();
	code.append("<li>"+str+"</li>");
}
</script>
</head>
<body>
<div id="panel1" class="op-panel" data-open="0" style="z-index: 10001; top: 0px; left: 0px; ">
	<div class="op-panelctrl solid-black">
		<div class="op-panelbt op-tab op-bt-nav">
			<h2 class="title" id="tab_fullname"></h2>
		</div>
		<div class="op-panelbt op-bt-closeall pull-right">
			<img src="${mvcPath}/dacp-res/task/images/close-white-48a.png" alt="close all">
		</div>
		<div class="clearspace"></div>
	</div>
	<div class="op-panelform" id="op-panelContent" style="padding: 15px 40px 100px"></div>
</div>
</body>
</html>