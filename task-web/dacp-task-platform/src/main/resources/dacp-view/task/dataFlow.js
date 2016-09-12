var bigfont = "bold 12pt Helvetica, Arial, sans-serif";
var smallfont = "bold 10pt Helvetica, Arial, sans-serif";
var flowSql=" select source,sourcetype,sourcefreq,target,targettype,targetfreq from transdatamap_design where 1=1 ";

var keys =[];
var ref=[];
function textStyle() {
	return { 
		margin : 6,  
		wrap : go.TextBlock.WrapFit, 
		textAlign : "center", 
		editable : true, 
		font : bigfont 
	}
}
var getTextName=function(xmlid,type){
	var col = "";
	var table = "";
	var pk="";
	switch(type){
		case "PROC":
		case "EVENT":
			pk ="xmlid";
			col = "proc_name";
			table = "proc";
			break;
		case "DATA":
			pk = "xmlid";
			col= "dataname";
			table = "tablefile";
			break;
		case "INTER":
			pk = "xmlid";
			col = "fullintercode";
			table = "inter_cfg";
			break;
		case "SCOPE":
			pk = "kpi_scope_id";
			col = "kpi_scope_code";
			table = "kpi_scope_def";
			break;
		default:
			break;
	}
	return getValue(table,col,pk,xmlid);
};

var getValue=function(table,val,pk,pkVal){
	var _sql = "select " + val + " from " + table + " where " + pk + "='"+pkVal+"'";
	var tableStore = ai.getStore(_sql,"METADBS");
	var item = tableStore&&tableStore.count>0?tableStore.root[0][val.toUpperCase()]:pkVal;
	return item;
}
var getProcState = function(xmlid,date_args){
	var _sql = "select task_state from proc_schedule_log where xmlid='" + xmlid + "' and  date_args = '" + date_args + "' and valid_flag=0"
	var stateStore=ai.getStore(_sql,"METADBS");
	var state = stateStore&&stateStore.count>0?stateStore.root[0]['TASK_STATE']:-8;
	var category="";
	if(state == -7){
		category = "PROC_NOT_TRIGGER";
	}else if(state==0){
		category = "PROC_WAIT"
	}else if(state==5){
		category = "PROC_RUNING";
	}else if(state==6){
		category = "PROC_SUCCESS";
	}else if (state==3||state==2){
		category = "PROC_QUEUING";
	}else if (state==1){
		category = "PROC_CREATE";
	}else if (state<=-1&&state>=-3){
		category = "PROC_RECOVERY";
	}else if (state==-8){
		category = "PROC_NO_LOG";
	}else {
		category = "PROC_FAIL";
	}
	return category;
};

var getScopeState = function(xmlid,date_args){
	return getProcState(xmlid,date_args);
};

var getKpiState = function(proc_name,procDate,date_args){
	var _sql = "select trigger_flag from proc_schedule_meta_log where obj ='" + proc_name + "' and  data_time = '" + date_args + "'"
	var stateStore=ai.getStore(_sql,"METADBS");
	var state = stateStore&&stateStore.count>0?stateStore.root[0]['TRIGGER_FLAG']:-8;
	if(state==1){
		return "PROC_SUCCESS";
	}
	else {
		return "PROC_NO_LOG";
	}
};

var getEventState= function(state){
	return "EVENT";
};

var getDataState=function(xmlid,date_args){
	var _sql = "select 1 as ISEXIST from proc_schedule_meta_log where target='" + xmlid + "' and  date_args = '" + date_args + "'"
	var num=ai.getStore(_sql,"METADBS");
	var category=""; 
	if(num.root.length!=0 && num.root[0]['ISEXIST']==1&&num.root[0]['ISEXIST']=='1'){
		category = "DATA_SUCCESS";
	}else{
		category = "DATA";
	}

	return category;
};

function getInterState(xmlid,date_args){
	var _sql = "SELECT check_put_status FROM inter_log WHERE xmlid ='"+ xmlid +"' AND op_time='"+ date_args.replaceAll("-","") +"'";
	var stateStore=ai.getStore(_sql,"METADBS");
	var state = stateStore&&stateStore.count>0?stateStore.root[0]['CHECK_PUT_STATUS']:null;
	switch(state){
		case "0":
			return "INTER_RUNING";
		case "1":
			return "INTER_FAIL";
		case "2":
			return "INTER_SUCCESS"
		default:
			return "INTER_INVALID";
	}
}

var checkKeyUnqi = function(objArray,key) {
	var _flag1 = true;
	for (var k = 0; k < objArray.length; k++) {
		if (objArray[k].key == key) {
			_flag1 = false;
		}
	}
	return _flag1;
};
var checkRefUnqi = function(objArray,from,to) {
	var _flag1 = true;
	for (var k = 0; k < objArray.length; k++) {
		if (objArray[k].from == from&&objArray[k].to==to) {
			_flag1 = false;
		}
	}
	return _flag1;
};
function getKeyVal(key){
	 switch(key){
	 	case "DATA":return "表：";
	 	case "PROC":return "程序：";
	 	case "INTER":return "接口：";
	 	case "EVENT":return "事件源：";
	 	case "FILE":return "文件：";
	 	case "SCOPE":return "指标组：";
	 	case "CAL_KPI":return "计算指标：";
	 	case "SCOPE_KPI":return "指标组指标：";
	 	default:return "";
	 }
}

function getCategory(xmlid,date_args,type){
	var category = "";
	switch(type){
		case "PROC":
			category = getProcState(xmlid,date_args);
			break;
		case "EVENT":
			category = getEventState(xmlid,date_args);
			break;
		case "SCOPE":
			category = getScopeState(xmlid,date_args);
			break;
		case "CAL_KPI":
			category = getKpiState(xmlid,date_args);
			break;
		case "SCOPE_KPI":
			category = getKpiState(xmlid,date_args);
			break;
		case "INTER":
			category = getInterState(xmlid,date_args);
			break;
		case "DATA":		
			category = getDataState(xmlid,date_args);
			break;
		case "FILE":
			category = "FILE";
			break;
		default:
			break;
	}
	return category;
}


function getChildModel(obj,date_args,type){
	var _realSql = flowSql;
	if(obj != null && obj.length > 0){
	  _realSql+=" AND "+ type+"='"+obj+"'";
	}
	/*
	if(freq&&freq.length>0){
	  _realSql+=" AND  "+ type+"FREQ='"+freq+"'";
	}*/
	var _store = ai.getStore(_realSql,"METADBS");
	if(_store&&_store.count>0){
		var item ="";
		var keyTar="";
		var keySrc="";
		var keyXmlID="";
	    var childType= type=="SOURCE"? "TARGET": "SOURCE";
		$.each(_store.root,function(i,item){
			 keySrc =  item["SOURCETYPE"]=="DATA"?(item["SOURCE"]+(item["SOURCEFREQ"]?"_"+item["SOURCEFREQ"]:"")):item["SOURCE"];
			 if(checkKeyUnqi(keys,keySrc)){
				 keys.push({
						"key" : keySrc,
					    "text" : getKeyVal(item["SOURCETYPE"]) + getTextName(item["SOURCE"],item["SOURCETYPE"]),
					    "category":getCategory(item["SOURCE"],date_args,item["SOURCETYPE"])
					});
			 }
			 keyTar =item["TARGETTYPE"]=="DATA"?( item["TARGET"]+(item["TARGETFREQ"]?"_"+item["TARGETFREQ"]:"")):item["TARGET"];
			 if(checkKeyUnqi(keys,keyTar)){
				 keys.push({
						"key" : keyTar,
					    "text" :getKeyVal(item["TARGETTYPE"]) + getTextName(item["TARGET"],item["TARGETTYPE"]),
					    "category":getCategory(item["TARGET"],date_args,item["TARGETTYPE"])
					});
			 }
			 if(checkRefUnqi(ref,keySrc,keyTar)){
				 ref.push({
						"from":keySrc,
						"to":keyTar
				});
			 }
			 getChildModel(item[childType],date_args,type);
		});
	}	
}

function getNowTime(){
	var d = new Date();
	var vYear = d.getFullYear();
	var vMon = d.getMonth() + 1;
	var vDay = d.getDate();
	var h = d.getHours();
	var m = d.getMinutes();
	var se = d.getSeconds();
	return vYear +"-"+(vMon<10 ? "0" + vMon : vMon)+"-"+(vDay<10 ? "0"+ vDay : vDay)+" "+(h<10 ? "0"+ h : h)+":"+(m<10 ? "0" + m : m)+":"+(se<10 ? "0" +se : se);
}

function getDataModel(data){
	keys =[];
	ref=[];
	keys.push({
			"key" : data.XMLID,
			"text": data.PROC_NAME,
		    "category": getCategory(data.XMLID, data.DATE_ARGS, data.NODE_TYPE),
		    "data": data
	});
	//影响
	getChildModel(data.XMLID, data.DATE_ARGS,"SOURCE");
	//血缘
	getChildModel(data.XMLID, data.DATE_ARGS,"TARGET");
}
	
function  load(data){
	getDataModel(data);
    myDiagram.model = new go.GraphLinksModel(keys, ref);
}

function loadDataFlow(data) {
	if (window.goSamples)
		goSamples(); // init for these samples -- you don't need to call this
	var $ = go.GraphObject.make; 
	// for conciseness in defining templates
    myDiagram=$(go.Diagram, "myDiagram");
    var yellowgrad = $(go.Brush, go.Brush.Linear, {0 : "rgb(254, 201, 0)",1 : "rgb(254, 162, 0)"});
    var blue       = $(go.Brush, go.Brush.Linear, {0 : "rgb(240,255,255)",1 : "rgb(230,255,255)"});
	var greengrad  = $(go.Brush, go.Brush.Linear, {0 : "#98FB98",1 : "#9ACD32"});
	var bluegrad   = $(go.Brush, go.Brush.Linear, {0 : "#B0E0E6",1 : "#87CEEB"});
	var redgrad    = $(go.Brush, go.Brush.Linear, {0 : "#C45245",1 : "#7D180C"});
	var whitegrad  = $(go.Brush, go.Brush.Linear, {0 : "#F0F8FF",1 : "#E6E6FA"});
	var radgrad    = $(go.Brush, go.Brush.Radial, {0: "rgb(240, 240, 240)", 1: "rgba(240, 240, 240, 0)" });
	var lavgrad    = $(go.Brush, go.Brush.Linear, {0: "#EF9EFA", 1: "#A570AD" });

	function returnContext(runState){
		var  contextMenu =""; 
		if(typeof(runState) == "undefined"){
			contextMenu =null;
		}
		if (runState=="") {
		 contextMenu=null;
		}
		if(runState=="PROC_SUCCESS"){
			contextMenu =$(go.Adornment, "Vertical", $("ContextMenuButton",
		        $(go.TextBlock, "重做后续"), { 
		        	click: function(e,obj){
		    			if(confirm("确定重做?")){
		    				var xmlid= obj.part.data.key;
		    				var dateArgs =obj.part.data.dataArgs;
							var execSql="update proc_schedule_log set task_state=0,trigger_flag=0,queue_flag=0,exec_time=NULL,end_time=NULL where xmlid ='"+xmlid+"' and date_args='"+dateArgs+"' and ( task_state >=50 or task_state=6 )";
							res=ai.executeSQL(execSql,false,"METADBS");
							load(data);
						}
		        	} 
		        }
		    	),$("ContextMenuButton",
		            $(go.TextBlock, "重做当前"),{ 
		            	click: function(e,obj){
			            	if(confirm("确定重做?")){
								var xmlid= obj.part.data.key;
			    				var dateArgs =obj.part.data.dataArgs;
								var execSql="update proc_schedule_log set task_state=1,trigger_flag=1,queue_flag=0,exec_time=NULL,end_time=NULL where xmlid ='"+xmlid+"' and date_args='"+dateArgs+"' and ( task_state >=50 or task_state=6 )";
								res=ai.executeSQL(execSql,false,"METADBS");
								load(data);
							}
		            	} 
		            }
				)
			); 
		}
		
		if (runState=="PROC_NOT_TRIGGER") {
			contextMenu =$(go.Adornment, "Vertical",$("ContextMenuButton",
		            $(go.TextBlock, "强制通过"),
		            { 
		            	click: function(e,obj){
	        				var  message =  prompt("请填写原因");
	        				if(message==null||message==""){
	        					alert("请填写原因")
        						return false;
	        				}else{
		        				var xmlid= obj.part.data.key;
		        				var dateArgs =obj.part.data.dataArgs;
								var execSql="update proc_schedule_log set TASK_STATE=6,QUEUE_FLAG=0,TRIGGER_FLAG=0 where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"' and task_state<>6 "
								res=ai.executeSQL(execSql,false,"METADBS");
								var findSeqno="select seqno from proc_schedule_log where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"'";
								res =ai.getStore(findSeqno,"METADBS");
								var _seqno=res.root[0]['SEQNO'];
								var sql1 ="select seqno from proc_schedule_script_log where seqno='"+_seqno+"' ";
								var store1=ai.getStore(sql1,'METADBS');
								var sql2="";
								if(store1&&store1.count>0){
								sql2=" update proc_schedule_script_log set app_log= CONCAT(app_log,'\\n\\n','【"+getNowTime()+"强制通过】,原因："+message+"') where seqno='"+_seqno+"' ";
								}else{
									sql2=" insert into proc_schedule_script_log values('"+_seqno+"',(select proc_name from proc_schedule_log where seqno='"+_seqno+"'),'DEFAULT_FLOW','【"+getNowTime()+"强制通过】,原因："+message+"')"
								}			
								ai.executeSQL(sql2,false,"METADBS");
								load(data);
	        				}	
		            	} 
		            }
		    	),$("ContextMenuButton",
		            $(go.TextBlock, "强制执行"),
		            { 
		            	click: function(e,obj){
		            		if(confirm("强制执行?")){
			            		var xmlid= obj.part.data.key;
		        				var dateArgs =obj.part.data.dataArgs;
								var execSql="update proc_schedule_log set TASK_STATE=2,trigger_flag=0,queue_flag=0 where  xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"' and (task_state=1 or task_state=-7)"
			            		res=ai.executeSQL(execSql,false,"METADBS");
								load(data);
		            		}
		            	} 
		            }
		    	)); 
		}
		if(runState=="PROC_QUEUING"){
			contextMenu=$(go.Adornment, "Vertical",$("ContextMenuButton",
		            $(go.TextBlock, "强制通过"),
		            { 
		            	click: function(e,obj){
	        				var  message =  prompt("请填写原因");
	        				if(message==null||message==""){
	        					alert("请填写原因")
        						return false;
	        				}else{
		        				var xmlid= obj.part.data.key;
		        				var dateArgs =obj.part.data.dataArgs;
								var execSql="update proc_schedule_log set TASK_STATE=6,QUEUE_FLAG=0,TRIGGER_FLAG=0 where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"' and task_state<>6 "
								res=ai.executeSQL(execSql,false,"METADBS");
								var findSeqno="select seqno from proc_schedule_log where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"'";
								res =ai.getStore(findSeqno,"METADBS");
								var _seqno=res.root[0]['SEQNO'];
								var sql1 ="select seqno from proc_schedule_script_log where seqno='"+_seqno+"' ";
								var store1=ai.getStore(sql1,'METADBS');
								var sql2="";
								if(store1&&store1.count>0){
								sql2=" update proc_schedule_script_log set app_log= CONCAT(app_log,'\\n\\n','【"+getNowTime()+"强制通过】,原因："+message+"') where seqno='"+_seqno+"' ";
								}else{
									sql2=" insert into proc_schedule_script_log values('"+_seqno+"',(select proc_name from proc_schedule_log where seqno='"+_seqno+"'),'DEFAULT_FLOW','【"+getNowTime()+"强制通过】,原因："+message+"')"
								}			
								ai.executeSQL(sql2,false,"METADBS");
								load(data);
	        				}	
		            	} 
		            }
		    	),$("ContextMenuButton",
		            $(go.TextBlock, "暂停执行"),
		            { 
		            	click: function(e,obj){
		            	if(confirm("确定暂停任务?")){
								var xmlid= obj.part.data.key;
		        				var dateArgs =obj.part.data.dataArgs;
		        				var findTaskState="select task_state from proc_schedule_log where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"'";
		        				res= ai.getStore(findTaskState,"METADBS");
								var task_state=res.root[0]['TASK_STATE'];
								var execSql= "update proc_schedule_log set TASK_STATE='"+(0-task_state)+"' where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"' and  task_state='"+task_state+"'";
								res=ai.executeSQL(execSql,false,"METADBS");
								load(data);
							}
		            	} 
		            }
		    	));
		}
		if(runState=="PROC_RECOVERY"){
			contextMenu=$(go.Adornment, "Vertical",$("ContextMenuButton",
		            $(go.TextBlock, "强制通过"),
		            { 
		            	click: function(e,obj){
	        				var  message =  prompt("请填写原因");
	        				if(message==null||message==""){
	        					alert("请填写原因")
        						return false;
	        				}else{
		        				var xmlid= obj.part.data.key;
		        				var dateArgs =obj.part.data.dataArgs;
								var execSql="update proc_schedule_log set TASK_STATE=6,QUEUE_FLAG=0,TRIGGER_FLAG=0 where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"' and task_state<>6 "
								res=ai.executeSQL(execSql,false,"METADBS");
								var findSeqno="select seqno from proc_schedule_log where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"'";
								res =ai.getStore(findSeqno,"METADBS");
								var _seqno=res.root[0]['SEQNO'];
								var sql1 ="select seqno from proc_schedule_script_log where seqno='"+_seqno+"' ";
								var store1=ai.getStore(sql1,'METADBS');
								var sql2="";
								if(store1&&store1.count>0){
								sql2=" update proc_schedule_script_log set app_log= CONCAT(app_log,'\\n\\n','【"+getNowTime()+"强制通过】,原因："+message+"') where seqno='"+_seqno+"' ";
								}else{
									sql2=" insert into proc_schedule_script_log values('"+_seqno+"',(select proc_name from proc_schedule_log where seqno='"+_seqno+"'),'DEFAULT_FLOW','【"+getNowTime()+"强制通过】,原因："+message+"')"
								}			
								ai.executeSQL(sql2,false,"METADBS");
								load(data);
	        				}	
		            	} 
		            }
		    	),$("ContextMenuButton",
		            $(go.TextBlock, "恢复任务"),
		            { 
		            	click: function(e,obj){
		            	if(confirm("确定恢复任务?")){
								var xmlid= obj.part.data.key;
		        				var dateArgs =obj.part.data.dataArgs;
								var findTaskState="select task_state from proc_schedule_log where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"'";
		        				res= ai.getStore(findTaskState,"METADBS");
								var task_state=res.root[0]['TASK_STATE'];
								var execSql= "update proc_schedule_log set TASK_STATE='"+(0-task_state)+"' where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"'  and  task_state='"+task_state+"'";
								res=ai.executeSQL(execSql,false,"METADBS");
								load(data);
							}
		            	} 
		            }
		    	));
		}
		if(runState=="PROC_CREATE"){
			contextMenu= $(go.Adornment, "Vertical",$("ContextMenuButton",
		            $(go.TextBlock, "强制通过"),
		            { 
		            	click: function(e,obj){
	        				var  message =  prompt("请填写原因");
	        				if(message==null||message==""){
	        					alert("请填写原因")
        						return false;
	        				}else{
		        				var xmlid= obj.part.data.key;
		        				var dateArgs =obj.part.data.dataArgs;
								var execSql="update proc_schedule_log set TASK_STATE=6,QUEUE_FLAG=0,TRIGGER_FLAG=0 where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"' and task_state<>6 "
								res=ai.executeSQL(execSql,false,"METADBS");
								var findSeqno="select seqno from proc_schedule_log where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"'";
								res =ai.getStore(findSeqno,"METADBS");
								var _seqno=res.root[0]['SEQNO'];
								var sql1 ="select seqno from proc_schedule_script_log where seqno='"+_seqno+"' ";
								var store1=ai.getStore(sql1,'METADBS');
								var sql2="";
								if(store1&&store1.count>0){
								sql2=" update proc_schedule_script_log set app_log= CONCAT(app_log,'\\n\\n','【"+getNowTime()+"强制通过】,原因："+message+"') where seqno='"+_seqno+"' ";
								}else{
									sql2=" insert into proc_schedule_script_log values('"+_seqno+"',(select proc_name from proc_schedule_log where seqno='"+_seqno+"'),'DEFAULT_FLOW','【"+getNowTime()+"强制通过】,原因："+message+"')"
								}			
								ai.executeSQL(sql2,false,"METADBS");
								load(data);
	        				}	
		            	} 
		            }
		    	),$("ContextMenuButton",
		            $(go.TextBlock, "强制执行"),
		            { 
		            	click: function(e,obj){
		            		if(confirm("强制执行?")){
			            		var xmlid= obj.part.data.key;
		        				var dateArgs =obj.part.data.dataArgs;
								var execSql="update proc_schedule_log set TASK_STATE=2,trigger_flag=0,queue_flag=0 where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"' and (task_state=1 or task_state=-7)"
			            		res=ai.executeSQL(execSql,false,"METADBS");
								load(data);
		            		}
		            	} 
		            }
		    	),$("ContextMenuButton",
		            $(go.TextBlock, "暂停执行"),
		            { 
		            	click: function(e,obj){
		            	if(confirm("确定暂停任务?")){
								var xmlid= obj.part.data.key;
		        				var dateArgs =obj.part.data.dataArgs;
		        				var findTaskState="select task_state from proc_schedule_log where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"'";
		        				res= ai.getStore(findTaskState,"METADBS");
								var task_state=res.root[0]['TASK_STATE'];
								var execSql= "update proc_schedule_log set TASK_STATE='"+(0-task_state)+"' where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"' and  task_state='"+task_state+"'";
								res=ai.executeSQL(execSql,false,"METADBS");
								load(data);
							}
		            	} 
		            }
		    	));
		}
		if(runState=="PROC_FAIL"){
			contextMenu=$(go.Adornment, "Vertical",$("ContextMenuButton",
		            $(go.TextBlock, "强制通过"),
		            { 
		            	click: function(e,obj){
	        				var  message =  prompt("请填写原因");
	        				if(message==null||message==""){
	        					alert("请填写原因")
        						return false;
	        				}else{
		        				var xmlid= obj.part.data.key;
		        				var dateArgs =obj.part.data.dataArgs;
								var execSql="update proc_schedule_log set TASK_STATE=6,QUEUE_FLAG=0,TRIGGER_FLAG=0 where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"' and task_state<>6 "
								res=ai.executeSQL(execSql,false,"METADBS");
								var findSeqno="select seqno from proc_schedule_log where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"'";
								res =ai.getStore(findSeqno,"METADBS");
								var _seqno=res.root[0]['SEQNO'];
								var sql1 ="select seqno from proc_schedule_script_log where seqno='"+_seqno+"' ";
								var store1=ai.getStore(sql1,'METADBS');
								var sql2="";
								if(store1&&store1.count>0){
								sql2=" update proc_schedule_script_log set app_log= CONCAT(app_log,'\\n\\n','【"+getNowTime()+"强制通过】,原因："+message+"') where seqno='"+_seqno+"' ";
								}else{
									sql2=" insert into proc_schedule_script_log values('"+_seqno+"',(select proc_name from proc_schedule_log where seqno='"+_seqno+"'),'DEFAULT_FLOW','【"+getNowTime()+"强制通过】,原因："+message+"')"
								}			
								ai.executeSQL(sql2,false,"METADBS");
								load(data);
	        				}	
		            	} 
		            }
		    	), $("ContextMenuButton",
		            $(go.TextBlock, "重做后续"),
		            { 
		            	click: function(e,obj){
		        			if(confirm("确定重做?")){
		        				var xmlid= obj.part.data.key;
		        				var dateArgs =obj.part.data.dataArgs;
								var execSql="update proc_schedule_log set task_state=0,trigger_flag=0,queue_flag=0,exec_time=NULL,end_time=NULL where xmlid ='"+xmlid+"' and   date_args='"+dateArgs+"' and ( task_state >=50 or task_state=6 )";
								res=ai.executeSQL(execSql,false,"METADBS");
								load(data);
							}
		            	} 
		            }
		    	));
		}

		return contextMenu;
	}



	myDiagram.nodeTemplateMap.add("FILE", $(go.Node, go.Panel.Auto, $(go.Shape,
			"Rectangle", {
				fill : "white",
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick 
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true
	}, new go.Binding("text", "text").makeTwoWay())));
	
	myDiagram.nodeTemplateMap.add("EVENT", $(go.Node, go.Panel.Auto, $(go.Shape,
			"Rectangle", {
				fill : "white",
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick 
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true
	}, new go.Binding("text", "text").makeTwoWay())));
	
	myDiagram.nodeTemplateMap.add("DATA", $(go.Node, go.Panel.Auto, $(go.Shape,
			"Rectangle", {
				fill : bluegrad,
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick 
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true
	}, new go.Binding("text", "text").makeTwoWay())));
	
	myDiagram.nodeTemplateMap.add("DATA_SUCCESS", $(go.Node, go.Panel.Auto, $(go.Shape,
			"Rectangle", {
				fill : greengrad,//表前置任务完成
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick 
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true,
		toolTip : $(go.Adornment,
					"Auto",
				    $(go.Shape, { fill: "#CCFFCC" }),
				    $(go.TextBlock, { margin: 4 },
			       "已完成"))
	}, new go.Binding("text", "text").makeTwoWay())));
	
	myDiagram.nodeTemplateMap.add("INTER_INVALID", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {//未生效 灰色
				fill : "grey",
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick 
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true,
		toolTip : $(go.Adornment,
					"Auto",
				    $(go.Shape, { fill: "#CCFFCC" }),
				    $(go.TextBlock, { margin: 4 },
			       "未生效"))
	}, new go.Binding("text", "text").makeTwoWay())));
	
	myDiagram.nodeTemplateMap.add("INTER_RUNING", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {//处理中 黄色
				fill : "yellow",
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick 
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true,
		toolTip : $(go.Adornment,
					"Auto",
				    $(go.Shape, { fill: "#CCFFCC" }),
				    $(go.TextBlock, { margin: 4 },
			       "处理中"))
	}, new go.Binding("text", "text").makeTwoWay())));
    myDiagram.nodeTemplateMap.add("INTER_SUCCESS", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {//处理成功 绿色
				fill : greengrad,
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true,
		toolTip : $(go.Adornment,
					"Auto",
				    $(go.Shape, { fill: "#CCFFCC" }),
				    $(go.TextBlock, { margin: 4 },
			       "处理成功"))
	}, new go.Binding("text", "text").makeTwoWay())));
	 myDiagram.nodeTemplateMap.add("INTER_FAIL", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {//运行失败 红色
				fill : "red",
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick  
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true,
		toolTip : $(go.Adornment,
					"Auto",
				    $(go.Shape, { fill: "#CCFFCC" }),
				    $(go.TextBlock, { margin: 4 },
			       "运行失败"))
	}, new go.Binding("text", "text").makeTwoWay())));
	
	myDiagram.nodeTemplateMap.add("PROC_NO_LOG", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {
				fill : yellowgrad,
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick 
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source'
	}, new go.Binding("text", "text").makeTwoWay())));
	
	myDiagram.nodeTemplateMap.add("PROC_NOT_TRIGGER", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {//未触发 白色
				fill : "white",
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick,
		 //contextMenu:returnContext("PROC_NOT_TRIGGER")
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true,
		toolTip : $(go.Adornment,
					"Auto",
				    $(go.Shape, { fill: "#CCFFCC" }),
				    $(go.TextBlock, { margin: 4 },
			       "未触发"))
	}, new go.Binding("text", "text").makeTwoWay())));

	myDiagram.nodeTemplateMap.add("PROC_WAIT", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {//排队中 灰色
				fill : "grey",
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick 
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true,
		toolTip : $(go.Adornment,
					"Auto",
				    $(go.Shape, { fill: "#CCFFCC" }),
				    $(go.TextBlock, { margin: 4 },
			       "排队等待"))
	}, new go.Binding("text", "text").makeTwoWay())));
	
	myDiagram.nodeTemplateMap.add("PROC_QUEUING", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {//依赖检测通过/排队等待 灰色
				fill : "grey",
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick,
		 //contextMenu:returnContext("PROC_QUEUING")
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true,
		toolTip : $(go.Adornment,
					"Auto",
				    $(go.Shape, { fill: "#CCFFCC" }),
				    $(go.TextBlock, { margin: 4 },
			       "依赖检测通过/排队等待"))
	}, new go.Binding("text", "text").makeTwoWay())));

	myDiagram.nodeTemplateMap.add("PROC_RECOVERY", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {//排队中 灰色
				fill : "yellow",
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick,
		 //contextMenu:returnContext("PROC_RECOVERY") 
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true,
		toolTip : $(go.Adornment,
					"Auto",
				    $(go.Shape, { fill: "#CCFFCC" }),
				    $(go.TextBlock, { margin: 4 },
			       "暂停执行"))
	}, new go.Binding("text", "text").makeTwoWay())));

	myDiagram.nodeTemplateMap.add("PROC_CREATE", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {//排队中 灰色
				fill : "grey",
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick,
		 //contextMenu:returnContext("PROC_CREATE") 
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true,
		toolTip : $(go.Adornment,
					"Auto",
				    $(go.Shape, { fill: "#CCFFCC" }),
				    $(go.TextBlock, { margin: 4 },
			       "创建成功"))
	}, new go.Binding("text", "text").makeTwoWay())));

	myDiagram.nodeTemplateMap.add("PROC_RUNING", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {//运行中 黄色
				fill : "yellow",
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true,
		toolTip : $(go.Adornment,
					"Auto",
				    $(go.Shape, { fill: "#CCFFCC" }),
				    $(go.TextBlock, { margin: 4 },
			       "正在运行"))
	}, new go.Binding("text", "text").makeTwoWay())));
	
    myDiagram.nodeTemplateMap.add("PROC_SUCCESS", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {//运行成功 绿色
				fill : greengrad,
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick,
		 //contextMenu:returnContext("PROC_SUCCESS")
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true,
		toolTip : $(go.Adornment,
					"Auto",
				    $(go.Shape, { fill: "#CCFFCC" }),
				    $(go.TextBlock, { margin: 4 },
			       "运行成功"))
	}, new go.Binding("text", "text").makeTwoWay())));
    
	 myDiagram.nodeTemplateMap.add("PROC_FAIL", $(go.Node, go.Panel.Auto, $(go.Shape,
			"RoundedRectangle", {//运行失败 红色
				fill : "red",
				portId : "",
				fromLinkable : true,
				cursor : "pointer"
			}), {
		 doubleClick : nodeDoubleClick,
		 //contextMenu:returnContext("PROC_FAIL") 
	}, // 鼠标单击事件函数
	$(go.TextBlock, textStyle(), {
		text : 'Source',
		editable : true,
		toolTip : $(go.Adornment,
					"Auto",
				    $(go.Shape, { fill: "#CCFFCC" }),
				    $(go.TextBlock, { margin: 4 },
			       "运行失败"))
	}, new go.Binding("text", "text").makeTwoWay())));
	 
     // replace the default Link template in the linkTemplateMap
	myDiagram.linkTemplate = $(go.Link, // the whole link panel
	{
		curve : go.Link.Bezier,
		toShortLength : 15
	}, new go.Binding("curviness", "curviness"), $(go.Shape, // the link
	// shape
	{
		isPanelMain : true,
		stroke : "#2F4F4F",
		strokeWidth : 2.5
	}), $(go.Shape, // the arrowhead
	{
		toArrow : "kite",
		fill : '#2F4F4F',
		stroke : null,
		scale : 2
	}));
	myDiagram.linkTemplateMap.add("Comment", $(go.Link, {
		selectable : false
	}, $(go.Shape, {
		strokeWidth : 2,
		stroke : "darkgreen"
	})));
	myDiagram.toolManager.mouseWheelBehavior = go.ToolManager.WheelZoom;
	myDiagram.allowDrop = true;
	myDiagram.initialAutoScale = go.Diagram.Uniform;
	myDiagram.toolManager.linkingTool.direction = go.LinkingTool.ForwardsOnly;
	myDiagram.initialContentAlignment = go.Spot.Center;
	myDiagram.layout = $(go.LayeredDigraphLayout, {isOngoing : false,layerSpacing : 50});
    getDataModel(data);
    myDiagram.model = new go.GraphLinksModel(keys, ref);
    
}