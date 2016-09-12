<!DOCTYPE html>
<html lang="zh" class="app">
<head>
<meta charset="utf-8" />
<title>大数据开放平台</title>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
<link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet" media="screen"/>
<link href="${mvcPath}/dacp-view/aijs/css/ai.css" type="text/css" rel="stylesheet"/>
<script type="text/javascript" src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>

<!-- 使用ai.core.js需要将下面两个加到页面 -->
<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>

<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>

<script type="text/javascript" src="${mvcPath}/dacp-lib/underscore/underscore-min.js"></script>

<script src="${mvcPath}/dacp-res/task/js/app.plugin.js"></script>
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
</style>

<script>
//数字验证  
var isNumber = function(n){
	var reg = /^\d+$/;
    return reg.test(n);
};

//更新并发数
var updateIPS = function(platform,toalIps){
	var totalStore = ai.getStore("select sum(curips) TOTAL from aietl_agentnode where platform='"+platform+"' " , "METADBS");
	var total = (totalStore.root[0])["TOTAL"];
	if(total){
		var updateSql = "update aietl_agentnode set ips=(("+toalIps+"*curips)/"+total+") where platform='"+platform+"'";
		ai.executeSQL(updateSql,false,"METADBS");
		ai.executeSQL(updateSql,false,"METADB");
    }
};  
$(document).ready(function() {
    var platform="";//当前选择的团队
    var curPlatform=""; 
    var curPlatformName=""; 
    var curPlatformIPS=0; 
    var agentGrid = "";
    var isAdd = true;
    var whereCase="";
    var selectIndex=0;
    var platformSql = "SELECT a.platform platform,platform_cnname,ips,a.team_code,NUM FROM proc_schedule_platform a LEFT JOIN  (SELECT platform,COUNT(platform) NUM FROM aietl_agentnode GROUP BY platform) b ON a.platform=b.platform ORDER BY NUM DESC";
   	var agentSql = "select agent_name,task_type,node_ip,node_status,status_chgtime,a.ips ips,a.curips curips,script_path,platform_cnname,c.user_name, c.password, c.login_type, c.ipaddr, c.port, c.op_user, c.op_time, c.host_name, c.hostcnname from aietl_agentnode a left join proc_schedule_platform b on a.platform = b.platform left join dp_host_config c on a.host_name=c.host_name where  1=1 {}";
	
   	var platformStore = new AI.JsonStore({
		sql : platformSql,
		pageSize : -1,
		table : 'PROC_SCHEDULE_PLATFORM',
		key : 'PLATFORM',
		dataSource:"METADBS"
	});
   	
	var agentListStore = new AI.JsonStore({
		sql :agentSql.replace("{}",whereCase),
		table:'AIETL_AGENTNODE',
		//pageSize : -1,
		key:'AGENT_NAME',
		dataSource:"METADBS"
	});
	
	var ipsRender = function(record, val){
		return val;
	};                  
    //打开编辑平台界面
    var showPlatformInfoDialog = function(acttype){
  		$("#platform-upsertForm").empty();
  		var isRead = 'n';
  		if(acttype=='edit'){
  			isRead='y';
  		}
		var formcfg = ({
			id : 'form',
			store : platformStore,
			containerId : 'platform-upsertForm',
			items : [ 
			{type: 'text',label:'编号',notNull:'N',fieldName:'PLATFORM',isReadOnly:isRead,width:250}, 
			{type: 'text',label : '组名',fieldName : 'PLATFORM_CNNAME',notNull:'N',width : 250 }, 
			{type: 'text',label : '并发数',notNull:'N',fieldName : 'IPS',width : 250},
			//{type: 'combox',label : '所属团队',fieldName : 'TEAM_CODE',notNull:'N',width : 250, storesql:'SELECT team_code  AS K ,team_name AS V FROM meta_team'}
			{type:'text-button',label:'所属团队',fieldName :'TEAM_CODE',notNull:'N'}
			]
		});

		var from = new AI.Form(formcfg);
		$('#platformConfig').modal({
			show : true,
			backdrop:false		
		});
		
		$("#TEAM_CODE_1").val("选择团队").attr("style","width:80");
		$("#TEAM_CODE_1").click(function(){
			function afterIndexSelect(rs){
				if(rs.length == 0) return;
      			var partitionFeild='';
      			for(var i = 0; i < rs.length;i++){
      				if(partitionFeild){
      					partitionFeild +=","+rs[i].get("KEYFIELD");
   					}else{
      					partitionFeild +=rs[i].get("KEYFIELD");	
    				}
      			}
      			$("#TEAM_CODE").val(partitionFeild);
    		};
    		
    		var selectValue = "";
           	selectValue = $("#TEAM_CODE").val();
             
			var selcetBox = new SelectBox({
				sql: "select team_code KEYFIELD,team_code VALUES1,team_name VALUES2 from meta_team",
				dataSource: "METADB",
				selectedValue: selectValue,
				callback: afterIndexSelect
   			});
			selcetBox.show();
			$("#selectgrid table thead th span").eq(0).html("团队编号");
			$("#selectgrid table thead th span").eq(1).html("团队名称");
			
			$("#resultgrid table thead th span").eq(0).html("团队编号");
			$("#resultgrid table thead th span").eq(1).html("团队名称");
		})
		
		//取消
		$("#platformConfig #dialog-cancel").on('click', function(){
	   	    platformStore.select();
			$('#platformConfig').modal("hide");
	    });
	}; 
	var buildPlatformList = function(){
		var teamList = "";
		$("#teamList").empty();
		platformStore.select();
		for (var i = 0; i < platformStore.getCount(); i++) {
			var r=platformStore.getAt(i);
			var activeClass="";
			if(i==selectIndex){
				activeClass = " active ";
				curPlatform = r.get("PLATFORM");
				curPlatformName = r.get("PLATFORM_CNNAME");
				curPlatformIPS = r.get("IPS");
			}
			teamList += '<a data-topic="' +r.get("PLATFORM_CNNAME")
				+ '" data-name="'+r.get("PLATFORM")
				+ '" data-ips="'+r.get("IPS")
				+ '" data-index="'+i
				+ '" class="list-group-item' + activeClass
				+ '"> <i class="icon-users icon text-warning"></i>'
				+ (r.get("PLATFORM_CNNAME") || "其他")+'('+r.get("IPS")+')'
				+ '<b class="badge bg-warning pull-right"> '
				+ ''+(r.get("NUM") || "0")+' </b> </a>';
		}
		whereCase=" and a.platform='"+curPlatform+"'";
		agentListStore.select(agentSql.replace("{}",whereCase));
		$("#teamList").append(teamList);
		$("#teamList .list-group-item").click( function() {
			$("#teamList .list-group-item").removeClass("active");
			$(this).addClass("active");
			// $("a#saveResource").addClass("disabled");
			curPlatform=$(this).attr("data-name");
			curPlatformIPS=$(this).attr("data-ips");
			selectIndex = $(this).attr("data-index");
			curPlatformName=$(this).attr("data-topic");
	  	    var whereCase = curPlatform.length>0?" and a.platform='"+curPlatform+"'":"";
	 	    agentListStore.select(agentSql.replace("{}",whereCase));
		    $(".platform_label").html(curPlatformName+","+curPlatform);
		});		
	}

	$("#delPlaform").click(function(){
		if(curPlatform.length==0||curPlatformName.length==0) {
			alert("请选择接入平台");
			return false;
		}
		if(window.confirm("确定删除平台:"+ curPlatformName+"吗?")){
			var sql="delete from  proc_schedule_platform where platform ='" + curPlatform + "'";
			ai.executeSQL(sql,false,"METADBS");
			ai.executeSQL(sql,false,"METADB");
            sql="delete from  aietl_agentnode where platform ='" + curPlatform + "'";
			ai.executeSQL(sql,false,"METADBS");
			ai.executeSQL(sql,false,"METADB");
			alert('成功删除');
			buildPlatformList();
		};
	});
	//创建平台
	$("#addPlaform").click(function(){
		isAdd=true;
	   var r=platformStore.getNewRecord();
	   platformStore.curRecord=r;
	   showPlatformInfoDialog('add');
	});
	//修改平台
	$("#editPlaform").click(function() {
		isAdd=false;
		platformStore.curRecord = platformStore.getRecordByKey(curPlatform); 
	    showPlatformInfoDialog("edit");
	});
	
	//agent信息
	var buildAgentList = function(){
	 	$("#agentList").empty();
		agentGrid = new AI.Grid({
			store: agentListStore,
			pageSize:20,
			containerId:'agentList',
			nowrap:true,
			showcheck:true,
			columns:[
				{header: "Agent编号", width:100,dataIndex: 'AGENT_NAME', sortable: true},
				{header: "平台", width: 105, dataIndex: 'PLATFORM_CNNAME', sortable: true },
				{header: "所在主机", width: 105, dataIndex: 'HOSTCNNAME', sortable: true },
				{header: "资源权重", width:74, dataIndex: 'CURIPS',render:ipsRender},
				{header: "并发数", width:74, dataIndex: 'IPS',render:ipsRender},
				{header: "脚本路径", width:74, dataIndex: 'SCRIPT_PATH'}
			]
		});	
	}
	
   //Agent信息窗口
   var showAgentInfoDialog=function(acttype){
   	  
		$("#agent-upsertForm").empty();
		var isRead='y';
		var isSelect = 'n';
		if(acttype=='add'){
		   isRead = 'n';
		   isSelect = 'y';
		}
		var formcfg = ({
			id : 'form',
			store : agentListStore,
			containerId : 'agent-upsertForm',
			items : [ 
				{type:'text',label:'Agent编号',notNull:'N',fieldName:'AGENT_NAME',isReadOnly:isRead,width:300}, 
				{type:'combox',label:'所在主机',notNull:'N',fieldName :'HOST_NAME',storesql:'SELECT HOST_NAME AS K ,HOSTCNNAME AS V FROM dp_host_config',width:300},
				{type:'text',label:'资源权重',notNull:'N',fieldName:'CURIPS',width:300},
				{type:'text',label:'脚本路径',notNull:'N',fieldName:'SCRIPT_PATH',width:300},
				{type:'combox',label:'Agent类型',notNull:'N',fieldName:'TASK_TYPE',storesql: "TASK,调度|ETL,ETL",width:300}
			]
		});
		var from = new AI.Form(formcfg);
		$('#agentConfig').modal({
			show : true,
			backdrop:false
		});
		//取消
		$("#agentConfig #dialog-cancel2").on('click', function(){
			$('#agentConfig').modal("hide");
	    });
	}; 
   //查找
   $("#findAgent").click(function(){
   	   var whereCase = "";
   	   var key=$("#input_content").val();
   	   whereCase +=curPlatform.length>0?" and a.platform='"+curPlatform+"' ":"";
   	   whereCase +=key.length>0?" and (agent_name like'%"+key+"%' or host_name like '%"+key+"%')":"";
   	   agentListStore.select(agentSql.replace("{}",whereCase));
   });
   //创建
   $("#addAgent").click(function(){
	   if(typeof(curPlatform)== "undefined" || curPlatform.length==0){
		   alert("没有选择agent组！");
		   return false;
	   }
   	   isAdd = true;
       var r = agentListStore.getNewRecord();
       r.set("PLATFORM",curPlatform);
	   r.set("NODE_STATUS",0);
	   r.set("STATUS_CHGTIME",new Date().format("yyyy-MM-dd hh:mm:ss"));
	   agentListStore.curRecord = r;
       showAgentInfoDialog('add');

   });
   //修改
   $("#editAgent").click(function(){
   	    isAdd = false;
     	var curAgent=agentGrid.getCheckedRows();
   		if(curAgent.length>1 || curAgent.length==0){
   			alert("只能选中一项！")
   			return false;
   		}
   	   agentListStore.curRecord = curAgent[0];
	   showAgentInfoDialog('edit');
   });
   
   //删除
   $("#delAgent").click(function(){
   	    var curAgent=agentGrid.getCheckedRows();
   		if(!curAgent || curAgent.length==0){
   			alert("至少选中一项！")
   			return false;
   		}
   		if(confirm("确定删除所有选中项吗?")){
   			var agents = "";
   			for(var i =0;i<curAgent.length;i++){
   				agents +="'"+curAgent[i].get("AGENT_NAME")+"',";
   			}
   			agents = agents.substr(0,agents.length-1);
   			ai.executeSQL("delete from aietl_agentnode where agent_name in (" + agents + ")","false","METADBS");
   			ai.executeSQL("delete from aietl_agentnode where agent_name in (" + agents + ")","false","METADB");
   			//计算新的并发数
   			agentListStore.select();
   			updateIPS(curPlatform,curPlatformIPS);
   			platformStore.select();
   			buildPlatformList();
   		}
   });
    //确定
	$("#platformConfig #dialog-ok").click(function() {
		var record = platformStore.curRecord;
		var platform = record.get("PLATFORM");
		var platform_name = record.get("PLATFORM_CNNAME");
		var ips = record.get("IPS");
		var teamCodes = $("#platform-upsertForm").find("#TEAM_CODE").val();
		if(!platform||platform.trim().length<1){
		    alert("平台ID不为空！");
		    return false;
		}
		if(!platform||platform_name.trim().length<1){
		    alert("平台名不为空！");
		    return false;
		}
		if(!ips || ips.toString().trim().length<1 || !isNumber(ips)){
		    alert("平台并发数不为空！");
		    return false;
		}
		if(!teamCodes || teamCodes.toString().trim().length<1){
		    alert("请选择所属团队！");
		    return false;
		}
		
		//同步到metadb
		var sql="";
		if(isAdd){	
		   platformStore.add(record);
		   sql="insert into proc_schedule_platform (platform,platform_cnname,ips,team_code)"
		   sql+="values ('"+platform+"','"+platform_name+"','"+ips+"','"+ teamCodes +"')";
		}else{
			sql="update proc_schedule_platform set platform_cnname='"+platform_name+"',ips='"+ips+"',team_code='"+teamCodes+"' where platform='"+platform+"'";
		}
		ai.executeSQL(sql,false,"METADBS");
		ai.executeSQL(sql,false,"METADB");
		platformStore.select();
		buildPlatformList();
		updateIPS(curPlatform,curPlatformIPS);
		agentListStore.select();
		$('#platformConfig').modal("hide");
   });
	//确定
	$("#agentConfig #dialog-ok2").click(function() {
		var record = agentListStore.curRecord;
		var agentName = record.get("AGENT_NAME");
		var hostName = record.get("HOST_NAME");
		var curips = record.get("CURIPS");
		var scriptPath = record.get("SCRIPT_PATH");
		var taskType = record.get("TASK_TYPE");
		
		if(!agentName||agentName.trim().length==0){
		    alert("Agent名不能为空！");
		    return false;
		}
		if(!hostName||hostName.trim().length==0){
		    alert("请选择所在主机！");
		    return false;
		}
		
		if(!curips||curips.toString().trim().length==0||!isNumber(curips.toString().trim())){
		    alert("资源权重不能为空且只能为整数！");
		    return false;
		}
		
		if(!scriptPath||scriptPath.trim().length==0){
		    alert("脚本路径不能为空！");
		    return false;
		}
		if(!taskType||taskType.trim().length==0){
		    alert("请选择agent类型！");
		    return false;
		}
	
		if(isAdd){	
			var sql = "SELECT AGENT_NAME FROM aietl_agentnode";
			var rootStore = ai.getStore(sql,"METADBS");
			for(var i=0;i<rootStore.count;i++){
				if (rootStore.root[i]['AGENT_NAME']==agentName) {
					 alert("Agent名已存在，不能重复添加！"); 
				 	 return false;
					
				}
			}
		   	agentListStore.add(record);
		}
		record.set("HOST_NAME",hostName);
		agentListStore.commit(false);
		//同步到metadb
		var sql="";
		if(isAdd){
			sql="insert into aietl_agentnode (AGENT_NAME,HOST_NAME,CURIPS,SCRIPT_PATH,platform,NODE_STATUS,TASK_TYPE,STATUS_CHGTIME) ";
			sql+="values ('"+agentName+"','"+hostName+"','"+curips+"','"+scriptPath+"','"+curPlatform+"',0,'"+taskType+"','"+new Date().format("yyyy-MM-dd hh:mm:ss")+"')";
		}else{
			sql="update aietl_agentnode set HOST_NAME='"+hostName+"',CURIPS='"+curips+"',SCRIPT_PATH='"+scriptPath+"',task_type='"+taskType+"' where AGENT_NAME='"+agentName+"'";	
		}
		ai.executeSQL(sql,false,"METADB");
		updateIPS(curPlatform,curPlatformIPS);
		agentListStore.select();
		platformStore.select();
		buildPlatformList();
		$('#agentConfig').modal("hide");
	});
   buildPlatformList();
   buildAgentList(); 
});
</script>
</head>
<body class="">
	<section class="vbox">
		<section>
			<section class="hbox stretch">
				<section id="content">
					<section class="vbox">
						<section class="scrollable">
							<section class="hbox stretch">
								<aside class="aside bg-light dk" id="sidebar"
									style="width: 285px; height: 90%;">
									<section class="vbox animated fadeInUp">
										<section class="scrollable padder-lg w-f-md">
											<div class="panel panel-default">
												<div class="panel-heading">
													<span class="font-thin m-l-md m-t">Agent资源组列表</span>
												</div>
												<div class="panel-body">
													<div
														class="list-group no-radius no-border no-bg m-t-n-xxs m-b-none auto"
														id="teamList"></div>
												</div>
												<div class="panel-footer no-border">
													<a id="addPlaform" class="btn btn-sm btn-primary"> <i
														class="fa fa-css3"> </i> 创建
													</a> <a id="delPlaform" class="btn btn-sm btn-danger"> <i
														class="fa fa-times"> </i> 删除
													</a> <a id="editPlaform" class="btn btn-sm btn-primary"> <i
														class="fa fa-css3"> </i> 修改
													</a>
												</div>
											</div>
										</section>
									</section>
								</aside>
								<aside class="bg-white">
									<section class="vbox">
										<header class="bg-light lt">
											<ul class="nav nav-tabs nav-white" id="myTab">
												<li class="active"><a href="#activity" data-toggle="tab"> Agent列表 </a></li>
											</ul>
										</header>
										<div class="tab-content">
											<div class="tab-pane active" id="activity"
												style="background: white">
												<div id = "coverNember" style="position: absolute;background:#fff;z-index:10000;width:0px;height:0px;opacity:0.3;"></div>
												<div class="row" style="z-index = 10001;">
													<div class="col-md-12">
														<div class="row row-sm"  style="padding-left:20px">
														<ul class="nav navbar-nav">
															<li class="active" ><a class="platform_label">Agent信息</a></li>
															<li
																style="margin-top: 12px; margin-left: 1px; margin-right: 3px; border-left: 1px solid #ddd; height: 20px;"></li>
															<li class="navbar-text" style="margin-top: 10px;">
																	<input type="text" id="input_content" placeholder = "请输入查询关键字">
															</li>
															<li><button id="findAgent" class="btn btn-sm" style="float: left; margin-top: 10px;"><i class="glyphicon glyphicon-eye-open"></i>查找</button></li>
															<li
																style="margin-top: 12px; margin-left: 1px; margin-right: 3px; border-left: 1px solid #ddd; height: 20px;"></li>
															<li><button id="addAgent" class="btn btn-sm btn-primary" style="float: left; margin-top: 10px;">创建</button></li>
															<li
																style="margin-top: 12px; margin-left: 1px; margin-right: 3px; border-left: 1px solid #ddd; height: 20px;"></li>
															<li><button class="btn btn-sm btn-primary" id="editAgent" style="float: left; margin-top: 10px;">修改</button></li>
															<li
																style="margin-top: 12px; margin-left: 1px; margin-right: 3px; border-left: 1px solid #ddd; height: 20px;"></li>
															<li><button class="btn btn-sm btn-primary"id="delAgent" style="float: left; margin-top: 10px;">删除</button></li>
														</ul>
													</div>
													<div class="row row-sm" id="agentList"></div>
													</div> 
													
												</div>
											</div>
										</div>
									</section>
								</aside>
							</section>
						</section>
					</section>
				</section>
			</section>
		</section>
	</section>
	<!-- Bootstrap -->
	<!-- App -->
	<div id="platformConfig" class="modal fade" style = "z-index:10000">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button id="dialog-cancel" type="button" class="close">
						<span aria-hidden="true">&times;</span><span class="sr-only">Close</span>
					</button>
					<h4 class="modal-title">Agent组信息</h4>
				</div>
				<div class="modal-body" id="platform-upsertForm"></div>
				<div class="modal-footer">
					<button id="dialog-cancel" type="button" class="btn btn-default">取消</button>
					<button id="dialog-ok" type="button" class="btn btn-primary">确认</button>
				</div>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	</div>
	<!-- /.modal -->

	<!-- Bootstrap -->
	<!-- App -->
	<div id="agentConfig" class="modal fade" style = "z-index:10000">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button id="dialog-cancel2" type="button" class="close">
						<span aria-hidden="true">&times;</span><span class="sr-only">Close</span>
					</button>
					<h4 class="modal-title">Agent信息</h4>
				</div>
				<div class="modal-body" id="agent-upsertForm"></div>
				<div class="modal-footer">
					<button id="dialog-cancel2" type="button" class="btn btn-default">取消</button>
					<button id="dialog-ok2" type="button" class="btn btn-primary">确认</button>
				</div>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	</div>
	<!-- /.modal -->
</body>
</html>