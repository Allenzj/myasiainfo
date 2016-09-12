var finalQuerySql="SELECT  XMLID,SEQNO,PRI_LEVEL,AGENT_CODE,PROC_NAME,RUN_FREQ,TASK_STATE,STATUS_TIME,START_TIME,EXEC_TIME,END_TIME,'--' DURATION,RETRYNUM,PROC_DATE,DATE_ARGS,TEAM_CODE,PATH FROM PROC_SCHEDULE_LOG WHERE RUN_FREQ='manual' {} order by EXEC_TIME desc";
var index = "";
var isClick = "0"; 
var data_type = "";
var catStore = "";
var ds_mydata="";
var condi="";
var _rowdblClickFunc = function(val,rowdata){
	if(rowdata){
		var _seqno = rowdata.get("SEQNO");
	    var _procName=rowdata.get("PROC_NAME");
		var logStore = new AI.JsonStore({
	        sql:"select SEQNO,PROC_NAME,APP_LOG from PROC_SCHEDULE_SCRIPT_LOG where seqno='"+_seqno+"'",
	        key:"SEQNO",
	        pageSize:-1,
	        dataSource:"METADBS",
	        table:"PROC_SCHEDULE_SCRIPT_LOG"
	    });
	    var r=  logStore.getRecordByKey(_seqno);
	    var _log =r==null?"无数据":r.get("APP_LOG"); 
		var _title = rowdata.get("PROC_NAME")+"的日志";
		var tmpl = _.template(
				'<section class="panel panel-default">'
				+ '<header class="panel-heading"> 脚本运行日志</header> '
				+ '<article class="media">'
				+ '<div class="media-body" style="margin:0px 40px 40px 40px;">'
				+ '<small class="block"><span>日志内容：</span></small>'
				+ '<small class="block" ><pre><%=log%></pre></small>'
				+ '</div>'
				+ '</article>'
				+'</section>',
				{"name":_procName,"log":_log});
		parent.openTableInfo("log",_title,tmpl,false);
	}
	return false;
};
function checkForm(){ 
	 _val = $("#upsertForm #PROC_NAME");
	 if(_val[0].value.trim().length<1){
		 alert("程序名 不能为空");
		 return false;
	 }
	 /*
	 var _a=_val[0].value.trim().split(".")
	 if(!(_a.length==2&&(_a[1]=="bat"||_a[1]=="tcl"||_a[1]=="sh"||_a[1]=="py"||_a[1]=="jar"))){
		 alert("请输入后缀为“.tcl,.sh,.py,.jar”格式的程序名");
		 return false;
	 }*/
	 _val = $("#upsertForm #DATE_ARGS");
	 if(_val[0].value.trim().length<1){
		 alert("日期参数不能为空");
		 return false;
	 }
	 _val = $("#upsertForm #AGENT_CODE");
	 if(_val[0].value.trim().length<1){
		 alert("请选择Agent");
		 return false;
	 }
	 return true;
}
var _timeDiffRender = function(value,data,index){
	var end= value.get("END_TIME");
	var start =value.get("EXEC_TIME");
	if(start&&start.length>0&&end&&end.length>0){
		start +=":00";
		start = start.replace(/-/g,"/");
		end  +=":00";
		end  = end.replace(/-/g,"/");
		var _start = new Date(start);
		var _end = new Date(end);
		var diff = _end.getTime()-_start.getTime();
		//计算出相差天数
		var days=Math.floor(diff/(24*3600*1000))
		//计算出小时数
		var leave1=diff%(24*3600*1000)    
		//计算天数后剩余的毫秒数
		var hours=Math.floor(leave1/(3600*1000))
		//计算相差分钟数
		var leave2=leave1%(3600*1000)      
		//计算小时数后剩余的毫秒数
		var minutes=Math.floor(leave2/(60*1000))
		if(days>1){
			hours += days*24;
		}
		minutes = minutes==0?1:minutes;
		var _hours = hours<=9?"0"+hours:""+hours;
		var _minutes=minutes<=9?"0"+minutes:""+minutes;
		if(_minutes.length>0 && _hours.length>0){
			return _hours+":"+_minutes;
		}else{
			return "--";
		}
	}else{
		return "--";
	}
};
function getCondition(state){
	var _res=" AND TASK_STATE<=4";
	 if(state==4){
		 _res = "AND TASK_STATE<=4";
	 }else if(state==5){
		 _res = "AND TASK_STATE=5"
	 }else if(state==6){
		 _res = "AND TASK_STATE=6";
	 }else if(state>=50) {
		 _res = "AND TASK_STATE>=50";
	 }
	 return _res;
}
function convertState(state){
	var _res="排队";
	 if(state==4){
		 _res = "排队";
	 }else if(state==5){
		 _res = "正在运行"
	 }else if(state==6){
		 _res = "成功";
	 }else if(state>=50) {
		 _res = "失败";
	 }
	 return _res;
}
// 创建分组列表
function refreshTree() {
	var treeSql = "SELECT CASE WHEN task_state<=3 THEN 4 WHEN task_state>=4 AND task_state<=6 THEN task_state WHEN task_state>=50 THEN 50 END TASK_STATUS ,COUNT(1) NUM FROM PROC_SCHEDULE_LOG  WHERE RUN_FREQ='manual' GROUP BY TASK_STATUS ORDER BY TASK_STATUS,NUM";
	catStore = ai.getStore(treeSql,"METADBS").root;
	$("#gridsumList").empty();
	var activeClass = "";
	for (var i = 0; i < catStore.length; i++) {
		if (isClick == 0) {
			if (i == 0) {
				activeClass = " active "
			} else {
				activeClass = "";
			}
		} else {
			if (index == getCondition(catStore[i]["TASK_STATUS"])) {
				activeClass = " active "
			} else {
				activeClass = "";
			}
		}
	   $("#gridsumList").append(
				'<a href="#" data-name="' + catStore[i]["TASK_STATUS"]
						+ '"  data-topic="' + getCondition(catStore[i]["TASK_STATUS"])
						+ '" class="list-group-item' + activeClass + '"> '
						+ (convertState(catStore[i]["TASK_STATUS"]) || "未知")
						+ '<b class="badge bg-primary pull-right"> '
						+ catStore[i]["NUM"] + ' </b> </a>');
	};
	$("#gridsumList .list-group-item").click(function() {
		$("#gridsumList .list-group-item").removeClass("active");
		$(this).addClass("active");
		index = $(this).attr("data-topic");
		isClick = "1";
		var newsql = finalQuerySql.replace("{}",index);
		ds_mydata.select(newsql);
		return false;
	});
}

// 刷新列表
function refreshList() {
	condi = index == '' ? data_type : index;
	var newsql = finalQuerySql.replace("{}",condi);
	ds_mydata.select(newsql);
}
// 查询操作
function search() {
	var key = document.getElementById("searchContent").value;
	var creater = document.getElementById("createrContent").value;
	condi = "";
    key =key.trim();
    creater = creater.trim();
	if(key.length>0){
		condi =  index+" AND (SEQNO LIKE '%" + key + "%' OR PROC_NAME LIKE '%"+ key + "%')";
	}
	if(creater.length>0){
	   condi +=" AND team_code like '%"+creater+"%'";
	}
	var newsql = finalQuerySql.replace("{}",condi);
	ds_mydata.select(newsql);
    refreshTree();
}
var operationRender = function(value, data, index) {
	var operationIcon = '<div >'
		    + '<a class="redo" id="'
		    + value.get("SEQNO")
		    + '" state="'
		    +value.get("TASK_STATE")
	 	    + '"  style="cursor:pointer" ><span class="fa fa-refresh" title="重做"></span></a>'
	 		+ '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
	 		+ '<a class="delete" id="'
			+ value.get("SEQNO")
			+ '"  style="cursor:pointer" ><span class="glyphicon glyphicon-trash" title="删除"></span></a>'
			+ '</div>';

	return operationIcon;
}
$(document)
		.ready(
				function() {
					var currenttranstype = '';
					sql = finalQuerySql.replace("{}","");
					ds_mydata = new AI.JsonStore({
						sql : sql,
						filter : 'proctype =1',
						selfield : '',
						key : "SEQNO",
						dataSource:"METADBS",
						pageSize : 15,
						table : "PROC_SCHEDULE_LOG"
					});
					var insertData = "";
					 var isUpdate=true;
					$("#insertBtn").click(function() {
						isUpdate = false;
						$("#upsertForm").empty();
						var _date = new Date();
						insertData=ds_mydata.getNewRecord();
						insertData.set("XMLID",ai.guid());
						insertData.set("SEQNO",_date.getTime().toString());
						insertData.set("PROC_DATE",_date.format("yyyymmddhhmmss").substr(0,12));
						insertData.set("PRI_LEVEL",10);
						insertData.set("START_TIME",_date.format("yyyy-mm-dd hh:mm:ss").substr(0,16));
						insertData.set("TASK_STATE",3);
						insertData.set("RUN_FREQ","manual");
						insertData.set("PLATFORM","bi");
						insertData.set("QUEUE_FLAG",0);
						insertData.set("TRIGGER_FLAG",1);
						insertData.set("RETRYNUM",0);
						insertData.set("TEAM_CODE", _UserInfo.usercnname);
						insertData.set("VALID_FLAG",0);//设置程序日志有效性
						ds_mydata.add(insertData);
						ds_mydata.curRecord = insertData;
						var formcfg = ({
							id : 'form',
							store : ds_mydata,
							containerId : 'upsertForm',
							fieldChange: function(fieldName,newVal){
								if(fieldName=='PROCTYPE'){
									if(newVal=='dp'){
										insertData.set("PATH","go.sh");
										$('#PATH').val("go.sh");
									}
								}
							},
							items : [ 
							       {type : 'text',label : '程序名',fieldName : 'PROC_NAME',width : 400}, 
							       {type : 'combox',label : '程序类型',fieldName:'PROCTYPE',width:400,storesql:"SELECT PROCTYPE K,PROCTYPE_NAME V FROM proc_schedule_exe_class "},
								   {type : 'combox',label : 'Agent',fieldName : 'AGENT_CODE',width : 400,storesql:"select AGENT_NAME K,HOST_NAME V  from AIETL_AGENTNODE where TASK_TYPE='TASK'"}, 
								   {type : 'text',label : '日期参数',fieldName : 'DATE_ARGS',width : 400},
								   {type : 'text',label : '脚本路径',fieldName : 'PATH',width : 400}
							  ]
						
						});
						var from = new AI.Form(formcfg);
						$('#dialog-ok').attr("name", "insert");
						$('#myModal').modal({
							show : true
						});
					});
					$("#dialog-ok").click(function() {
						if(checkForm()){
							var result = ds_mydata.commit();
							var jsonResult = $.parseJSON(result);
							if (jsonResult.success) {
								ds_mydata.fireEvent("dataload");
								$('#myModal').modal('hide');
								isClick='0';
								refreshList();
								refreshTree();
							} else {
								alert(jsonResult.msg);
							}
						}

					});
					$(".close-modal").on('click', function(){
						 if(!isUpdate){
	                    	   ds_mydata.remove(insertData);	
	                    	   isUpdate=true;
	                       } 
	                       $('#myModal').modal('hide');
	        		});
					var localcellclick = function(dataIndex, record) {
						alert(record);
					};
					var localBindEvent = function() {
						$('a.redo').each(function() {$(this).click(	function() {
									var _seqno=$(this).attr("id");
									var _state = $(this).attr("state");
									if (_state>=6&&confirm("确认重做手工任务?")) {
										var execSql = " update proc_schedule_log set task_state=3,queue_flag=0,trigger_flag=1 where seqno='"+_seqno+"' and  task_state>=6";
										res=ai.executeSQL(execSql,false,"METADBS");
										refreshList();
										refreshTree();
									}
							});
						});
						$('a.delete').each(function() {$(this).click(function() {
									var _seqno=$(this).attr("id");
									ds_mydata.curRecord = ds_mydata.getRecordByKey(_seqno);
									if (confirm("是否将此信息删除?")) {
										var r = ds_mydata.curRecord;
										ds_mydata.remove(r);
										var result = ds_mydata.commit();
										var jsonResult = $.parseJSON(result);
										if (jsonResult.success
												&& jsonResult.success == false) {
											alert(jsonResult.msg);
										}
										refreshList();
										refreshTree();
									}
								});
					     });
					};
					var config = {
						id : 'datagrid',
						region : 'center',
						store : ds_mydata,
						pageSize : 15,
						containerId : 'datagrid',
						showcheck : false,
						// celldblclick:cellclick,
						celldblclick:_rowdblClickFunc,
						bindEvent : localBindEvent,
						pageContainer : "mypagination",
						columns : [ 
							{header: '程序名称','dataIndex':'PROC_NAME',width: 120,sortable: true},
							{header: 'Agent','dataIndex':'AGENT_CODE',width: 120,sortable: true},
							{header: '开始执行时间','dataIndex':'EXEC_TIME',width: 120,sortable: true},
							{header: '执行结束时间','dataIndex':'END_TIME',width: 120,sortable: true},
							{header: '运行时长','dataIndex':'DURATION',width: 120,sortable: true,render:_timeDiffRender},
							{header: '日期参数','dataIndex':'DATE_ARGS',width: 120,sortable: true},
							{header: '创建者','dataIndex':'TEAM_CODE',width: 120,sortable: true},
							{header: "操作", width:100,sortable:false,dataIndex:'SEQNO',render:operationRender}
                         ]

					};
					var grid = new AI.Grid(config);
					$("#searchBtn").click(function() {
						    search();
					});
					$('#refreshBtn').on("click",function(){
						refreshList();
						refreshTree();
	                });
					refreshTree();
});