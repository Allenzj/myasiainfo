<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="X-UA-Compatible" content="chrome=1" />  
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Agent监控</title>
<link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="${mvcPath}/dacp-lib/datepicker/datepicker.css" type="text/css" rel="stylesheet" media="screen"/>
<link href="${mvcPath}/dacp-res/task/css/styleForMonitor.css" type="text/css" rel="stylesheet" />
<link href="${mvcPath}/dacp-res/task/css/font-awesome.css" type="text/css" rel="stylesheet" />
<link href="${mvcPath}/dacp-res/task/css/font-awesome-ie7.min.css" type="text/css" rel="stylesheet" />
<link href="${mvcPath}/dacp-res/task/css/widgets.css" type="text/css" rel="stylesheet" />
<link href="${mvcPath}/dacp-res/task/css/dhtmlxgantt_broadway.css" rel="stylesheet" type="text/css" />
<link href="${mvcPath}/dacp-res/task/css/jquery.easy-pie-chart.css" rel="stylesheet" media="screen" />
<script type="text/javascript" src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-res/task/css/jquery.easy-pie-chart.js"></script>
 <!-- 使用ai.core.js需要将下面两个加到页面 -->
	<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
	<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>
	
	<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>

<script src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>
<script src="${mvcPath}/dacp-lib/datepicker/bootstrap-datepicker.js" type="text/javascript" ></script>
<script src="${mvcPath}/dacp-lib/underscore/underscore.js" type="text/javascript"></script>
<script src="${mvcPath}/dacp-lib/backbone/backbone-min.js" type="text/javascript"></script>
<script src="${mvcPath}/dacp-view/task/js/agentMonitor.js" type="text/javascript"></script>
<style type="text/css">
.hand-click{
	cursor: pointer;
}

body{
	background-color: #fff;
}

</style>
<!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
<!--[if lt IE 9]>
	<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->
<!-- Le fav and touch icons -->
<script type="text/javascript">
//查询全局sql
var totalSql="SELECT SUM(CASE WHEN (agent_name IS NOT NULL) THEN 1  ELSE 0 END ) AS total,SUM(CASE WHEN NODE_STATUS = 1 THEN 1  ELSE 0 END ) AS active,SUM(CASE WHEN NODE_STATUS = 0  THEN 1  ELSE 0  END ) AS dead FROM aietl_agentnode a inner join proc_schedule_platform c on a.platform=c.platform WHERE task_type = 'TASK'  {}";
var everytotalSql = " select a.platform,c.platform_cnname,a.agent_name,a.node_status,a.ips,SUM(CASE WHEN task_state = 4 OR task_state = 5 THEN 1 ELSE 0 END) curips from aietl_agentnode a left join proc_schedule_log b on a.agent_name = b.agent_code inner join proc_schedule_platform c on a.platform=c.platform {} group by a.platform,c.platform_cnname,a.agent_name,a.node_status,a.ips order by platform ";
var runFreq="day";//周期
var store="";

function StartAndStop(agentCode,status){
	//$("#"+agentCode).prop("disabled", "disabled")
	var type= status=="0"?"启动":"停止";
	var str="确定要"+type+"选中项吗？";
	
	var url = '/' + contextPath + '/syn/controllAgent?AGENT_CODE=' + agentCode;
	if(confirm(str)){
		$.ajax({
			url:url,
			beforeSend:function(){
				$("#loadingBackDrop",window.parent.document).show();
			},
			complete:function(){
				$("#loadingBackDrop",window.parent.document).hide();
			},
			error:function(){     
			       alert('网络错误！');
			    },
			success:function(msg){
				var message = $.parseJSON(msg);
				alert(message.response);
				location.reload();
			}
		});
	}
}


function getWhereCase(dateStr,runFreq){
   var _date = new Date().getTime();
   var whereCase = " and '"+_date+"'='"+_date+"'";
   whereCase += getTeamCondi();
   return whereCase;
}

function getTeamCondi(){
	var team_code=$("#treetitle span",window.parent.document).eq(0).attr("curteam");
	var team_codes=team_code;
	var curTeamCodeCondi="";
	
	if(typeof(team_codes)!="undefined" && team_codes.length>0){
		curTeamCodeCondi ="  and c.team_code in ('" + team_codes + "')";
	}
	return curTeamCodeCondi;
}

function showAllToal(dateStr,runFreq){
   $("#sumnum").empty().append(0);
   $("#oknum").empty().append(0);
   $("#alertnum").empty().append(0);

   var store = new AI.JsonStore({
   		sql:totalSql.replace("{}",getWhereCase(null,null)),
   		dataSource:"METADBS"
   });
   
   var data = store&&store.count>0?store.root[0]:null;
   if(data){
		var total   =   data["TOTAL"];
		var active  =   data["ACTIVE"];
		var dead    =   data["DEAD"];
		var total = total==undefined||total==null?0:total;
		var active = active==undefined||active==null?0:active;
		var dead = dead==undefined||dead==null?0:dead;
		$("#sumnum").empty().append(total);
		$("#oknum").empty().append(active);
		$("#alertnum").empty().append(dead);
   }
}

var checkKeyUnqi = function(objArray,key) {
	var _flag =  objArray[key]== undefined ? true:false;
	return _flag;
};

var checkKeyUnqi1 = function(objArray,key) {
	var _flag = true;
	for (var k = 0; k < objArray.length; k++) {
		if (objArray[k].key == key) {
			_flag = false;
		}
	}
	return _flag;
};

function showGroupToal(dateStr,runFreq){
   $("#topic_detail").empty();
   store=new AI.JsonStore({
   		sql:everytotalSql.replace("{}",getWhereCase(null,null)),
   		pageSize:100,
   		dataSource:"METADBS"
   });
  var platforms={};
  for(var i=0;store && i < store.count; i ++){
	  var agents=[];
	  var data =  store.root[i];
	  var platform = data.PLATFORM_CNNAME+" ["+data.PLATFORM+"]";
	  if(checkKeyUnqi(platforms,platform)){
		 agents.push(data);
		 platforms[platform] = agents;
	  }else{
		  platforms[platform].push(data);
	  }
  }
  
   var content="";
   var record=[];

   for(var p in platforms){
	   content +="<div style=' margin-left:10px;'>"+
	   "<fieldset style='margin-bottom:10px; border:2px solid #ccc;' >"+
		    "<legend><span style='font-size:14px; font-weight:bolder; color:rgb(0, 110, 255)'>"+p+"</span></legend>";
		for(var i =0;i<platforms[p].length;i++){
			content += createTemplate(platforms[p][i]); 
		}
	    content +="</fieldset>"+
	    "</div>";
   }

   if(content.length>0){
   	 $("#topic_detail").append(content);
   }
}

$(document).ready(function() {
   	dateStr=$("#inputDate").val();
	showAllToal(null,null);
	showGroupToal(null,null);
});

$(function() {
    // Easy pie charts
    var $chart = $('.chart');
    $chart.easyPieChart({animate: 1000});
});
</script> 
  </head>
  <body>
  	<div class="container-fluid" >
	    <div class="row">
	    <ul class="kpiValue" style="list-style:none;">
		    <li style="font-weight:bold;border-right: 1px solid #C6C6C6;height:50px;padding:0;">
			  <h2> Agent监控 </h2>
		    </li>
		    <li style="position:relative;">
				<div style="position:absolute;top:20px;left:0;width:0;line-height: 0;border:6px transparent dashed;border-left:6px solid #C6C6C6;">
				</div>
				<div style="position:absolute;top:20px;left:-1px;width:0;line-height: 0;border:6px transparent dashed;border-left:6px solid #EFF5FB;">
				</div>
		    </li>
			<li style="position: relative;">
				<div id="label1"> Agent总数 </div>
				<div id="sumnum" class="count"> 30 </div>
			</li>
			<li style="position: relative;">
				<div id="label2"> 正常 </div>
				<div id="oknum" class="count"> 20 </div>
			</li>
			<li>
				<div id="label3">异常</div>
				<div id="alertnum" class="count"> 10 </div>
			</li>
			<li>
			</li>
	    </ul>
        <div class="divider"> </div>
        </div>
	    <div class="row-fluid">
	   	  <div id="topic_detail" class="col-md-12" style=" height:550px; overflow-y:auto">

	      </div> 
        </div>
    </div>  
</body>
	
</html>