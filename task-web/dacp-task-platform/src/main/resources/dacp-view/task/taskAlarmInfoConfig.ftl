<!DOCTYPE html>
<html lang="zh" class="app">
<head>
<meta http-equiv="X-UA-Compatible" content="chrome=1, IE=edge"></meta>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></meta>
<meta charset="utf-8"></meta>
<meta name="viewport" content="width=device-width, initial-scale=1.0"></meta>
<title>任务告警信息配置</title>
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"  />
	<link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet" media="screen"/>
	<link href="${mvcPath}/dacp-view/aijs/css/ai.css" type="text/css" rel="stylesheet"/>
		
	<script src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js" type="text/javascript"></script>
	<script src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>
		
	<script src="${mvcPath}/dacp-lib/jquery-plugins/bootstrap-treeview.min.js"> </script>
   	<script src="${mvcPath}/dacp-lib/jquery-plugins/jquery.layout-latest.js" type="text/javascript"> </script>
   	
   	<!-- 使用ai.core.js需要将下面两个加到页面 -->
	<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
	<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>
	
	<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>
   	<script src="${mvcPath}/dacp-view/aijs/js/ai.treeview.js"></script>	

<script type="text/javascript">

$(document).ready(function() {
	var sql = {
		content:"SELECT a.xmlid as proc_xmlid,a.proc_name,a.proccnname,b.run_freq,c.sms_group_id,c.alarm_type,c.max_send_count,c.interval_time,c.is_valid,c.due_time_cron,c.offset  FROM proc a inner join proc_schedule_info b on a.xmlid = b.xmlid LEFT JOIN proc_schedule_alarm_info c ON c.proc_xmlid=a.xmlid and a.state='VALID' where 1=1 {condi}",
		getContent:function(condition){
			return this.content.replace('{condi}',condition||"");
		}
	};

	var alarmInfoStore = new AI.JsonStore({
		sql: sql.getContent(),
		key: "PROC_XMLID",
        pageSize: 20,
        dataSource: "METADBS"
    });

	var smsTasksql ="select * from  proc_schedule_alarm_info where proc_xmlid ='{proc_xmlid}'";
	var smsTaskStore = new AI.JsonStore({
 		sql:smsTasksql,
  		table:"proc_schedule_alarm_info",
		key:"XMLID",
		pageSize:-1,
	    dataSource:"METADBS"
	});

	var _rowdblClickFunc = function(){
		//alert('行双击事件！');
		//buildForm();
	};

	var smsGroupStore = new AI.JsonStore({
		sql:"select * from sms_message_group",
		key:"SMS_GROUP_ID",
	    pageSize:-1,
	    dataSource:"METADBS"
    });
	
	
	function getsmsGroupName(v){
		if (!v) return "--";
		var smsGroupId = v;
		var smsgroupName;
		for(var k=0;k<smsGroupStore.getCount();k++){
			var record=smsGroupStore.getAt(k);
			if(record.get("SMS_GROUP_ID")==smsGroupId){
				smsgroupName=record.get("SMS_GROUP_NAME");
				break;
			}
		}
		if(!smsgroupName)
			smsgroupName="未设置";
		return 	smsgroupName;
	};

  	var warnTypeStore = new AI.JsonStore({
		sql:"select * from warning_type",
		key:"TYPE_CODE",
	    pageSize:-1,
	    dataSource:"METADBS"
    });
	
	
	 function getWarnType(v){
		if (!v) return "--";
		var rtnVal="";
		if(v&&v.length>0){inputVals = v.split(",");}
		for(var i=0;i<inputVals.length;i++){
			var record = warnTypeStore.getRecordByKey(inputVals[i]);
			if(record) rtnVal+=record.get("TYPE_NAME")+",";
		}
		
		if(rtnVal.length>0){
			rtnVal=rtnVal.substr(0,rtnVal.length-1);
		}else{
			rtnVal="未设置";
		}
		return 	rtnVal;
	};    

  var statusFlag={"0":"生效","1":"失效",'null':'--'};
  	$("#grid-container").empty();
	var grid = new AI.Grid({							//表格组件
		store:alarmInfoStore,									//表格渲染的数据源										
		id:'expl',										//组件在html标签中的id
		containerId:'grid-container',					//组件在html中父节点id
		pageSize:5,									//每一页的记录条数
		nowrap:true,									//是否换行（true不换行，false换行）
		showcheck:true,								//是否显示勾选框（true显示，false不显示）
		//rowclick:function(){alert('行单击事件！');},		//行单击事件
		//celldblclick:_rowdblClickFunc,				//单元格双击事件，实现在43行
		columns:[										//列表头配置
			// {
			// 	header:"XMLID",							//列名
			// 	dataIndex: 'XMLID',					//对应store中的字段，注意要大写
			// 	sortable: true,							//是否允许排序（true允许，false不允许）
			// 	maxLength:20,							//单元格最大显示字符长度
			// 	render:function(record,value){			//自定义渲染，record参数为当前记录，value为当前列字段值
			// 		return value;
			// 	}
			// },
			{header:"程序名",dataIndex: 'PROC_NAME',  sortable: true,maxLength:30},
			{header:"程序中文名",dataIndex: 'PROCCNNAME',  sortable: true,maxLength:30},
			{header:"用户组",dataIndex: 'SMS_GROUP_ID',  sortable: true,maxLength:50},
			{header:"用户组名",dataIndex: 'SMS_GROUP_ID',  sortable: true,maxLength:50,
				render:function(rec, cellVal){
					return getsmsGroupName(cellVal);
				}
			},
			{header:"告警类型",dataIndex: 'ALARM_TYPE',  sortable: true,maxLength:200,
				render:function(rec, cellVal){
					return getWarnType(cellVal);
				}
			},
			{header:"最大发送次数",dataIndex: 'MAX_SEND_COUNT',  sortable: true,maxLength:20},
			{header:"发送时间间隔",dataIndex: 'INTERVAL_TIME',  sortable: true,maxLength:20},
			{header:"是否生效",dataIndex: 'IS_VALID',  sortable: true,maxLength:20,
				render:function(record,value){
					return statusFlag[record.get("IS_VALID")+""];
				}
			}
		],
	});
	
	
	var getComboxStoreSql=function(sql,dataSource){
		var _store = new AI.JsonStore({
			sql: sql,
			pageSize: -1,
	    	dataSource: dataSource
		});
		var res="";
		if(_store.count>0){
			$.each(_store.root,function(index,item){
				res += item.K+","+item.V+"|"
			});
		}
		if(res.length>0)res=res.substr(0,res.length-1);
		return res;
	}

	var buildForm = function(){
		var selected=grid.getCheckedRows();
		if(selected && selected.length==0){
			alert("请选择数据修改");
			return;
		}
		if(selected && selected.length>1){
			alert("请选择一行记录修改");
			return;
		}
		$('#upsertForm').empty();
		var xmlId=selected[0].get("PROC_XMLID");
		
		alarmInfoStore.curRecord = alarmInfoStore.getRecordByKey(xmlId);
		
		$('#myModal').modal('show');
			
		var form = new AI.Form({							//表单组件
			id : 'form',									//组件在html标签中的id
			store : alarmInfoStore,									//表单数据存储的数据源
			containerId : 'upsertForm',						//组件在html中父节点id
			items : [ 										//表单内容
				{											//formField，表单实例对象
					type : 'hidden',						//表单类型，text文本框，password密码框，date日期框，combox筛选框，radio选择框，multilevel多级筛选
					label : 'PROC_XMLID',						//表单名称
					fieldName : 'PROC_XMLID',					//对应字段
					isReadOnly:"y",							//是否只读
					value:"dbuer",								//默认值
					// storesql:"",							//参数值，有两种设置值的方式，sql：“select col from tab”，
															// “select col1，col2 from tab“，定值：“1,2”,"1,是|0,否"
					notNull:  'Y',							//是否允许为空
					isReadOnly: 'y',						//是否只读，y只读，n可以修改
					width: '100px',							//设置宽度
					//tip: 'notice that…',					//备注
					dependencies: '{val}=2',				//依赖关系条件，｛val｝为依赖表单的值
					checkItems: 'FIELD2'					//影响的底钻名称
				},
				{type : 'text',label : '程序名',fieldName : 'PROC_NAME',isReadOnly:"y"}, 
				{type : 'hidden',label : '程序周期',fieldName : 'RUN_FREQ',isReadOnly:"y"}, 
				{type : 'combox',label : '用户组',fieldName : 'SMS_GROUP_ID',notNull:'N',storesql: getComboxStoreSql('select sms_group_id as K,sms_group_name as V from sms_message_group order by sms_group_id',"METADBS")},
				{type : 'checkbox',label : '告警类型',fieldName : 'ALARM_TYPE',notNull:'N',storesql: getComboxStoreSql("select dim_code as K,dim_value as V from proc_schedule_dim a,proc_schedule_dim_group b where a.dim_group_id = b.xmlid and b.group_code='ALARM_TYPE' order by dim_seq","METADB")},
				{type : 'text-button',label : '告警时间',fieldName : 'DUE_TIME_CRON',notNull:'N'},
				{type : 'text',label : '告警批次偏移量',fieldName : 'OFFSET',notNull:'N'},
				{type : 'text',label : '最大发送次数',fieldName : 'MAX_SEND_COUNT',notNull:'N'},
				{type : 'combox',label : '发送时间间隔',fieldName : 'INTERVAL_TIME',notNull:'N',storesql:'5,5分钟|10,10分钟|20,20分钟|30,30分钟|40,40分钟|60,60分钟'},
				{type : 'radio-custom',label : '是否生效',fieldName : 'IS_VALID',value:'0',storesql:'0,生效|1,失效',notNull:'N'}
			],
			fieldChange: function(fieldName, newVal){
				if(fieldName=="ALARM_TYPE"){
					if(newVal.indexOf('1')>-1){
						$("#upsertForm").find("#DUE_TIME_CRON").parent().parent().show();
						$("#upsertForm").find("#OFFSET").parent().parent().show();
						$("#upsertForm").find("#MAX_SEND_COUNT").parent().parent().show();
						$("#upsertForm").find("#INTERVAL_TIME").parent().parent().show();
					}else{
						$("#upsertForm").find("#DUE_TIME_CRON").val("");
						$("#upsertForm").find("#OFFSET").val("");
						$("#upsertForm").find("#MAX_SEND_COUNT").val("");
						$("#upsertForm").find("#INTERVAL_TIME").val("");
						$("#upsertForm").find("#DUE_TIME_CRON").parent().parent().hide();
						$("#upsertForm").find("#OFFSET").parent().parent().hide();
						$("#upsertForm").find("#MAX_SEND_COUNT").parent().parent().hide();
						$("#upsertForm").find("#INTERVAL_TIME").parent().parent().hide();
					}
				}
			}			
		});
		
		var warnTypes = $("#upsertForm").find("input[type='checkbox'][name='ALARM_TYPE']");
		$("#upsertForm").find("#DUE_TIME_CRON").parent().parent().hide();
		$("#upsertForm").find("#OFFSET").parent().parent().hide();
		$("#upsertForm").find("#MAX_SEND_COUNT").parent().parent().hide();
		$("#upsertForm").find("#INTERVAL_TIME").parent().parent().hide();
		$.each(warnTypes,function(index,item){
			if(item.value=="1" && item.checked){
				$("#upsertForm").find("#DUE_TIME_CRON").parent().parent().show();
				$("#upsertForm").find("#OFFSET").parent().parent().show();
				$("#upsertForm").find("#MAX_SEND_COUNT").parent().parent().show();
				$("#upsertForm").find("#INTERVAL_TIME").parent().parent().show();
			}
		});
		$("#upsertForm").find("#DUE_TIME_CRON_1").val("配置").attr("style","width:45px;height:28px;")
		$("#upsertForm").find("#DUE_TIME_CRON_1").click(function(){
			var iWidth =650;//弹出窗口的宽度;
			var iHeight=400;//弹出窗口的高度;
			var iTop = (window.screen.availHeight-30-iHeight)/2;//获得窗口的垂直位置;
			var iLeft = (window.screen.availWidth-10-iWidth)/2; //获得窗口的水平位置;
			var defaultVal=  $('#DUE_TIME_CRON').val();
			var freq=$("#upsertForm").find("#RUN_FREQ").val();
			var url = "${mvcPath}/ftl/task/cron/cron?freq="+freq+"&cron="+defaultVal+"&cron_id=DUE_TIME_CRON&current_freq="+freq+"&open=open";
			var _window=window.open(url,'','height='+iHeight+',innerHeight='+iHeight+',width='+iWidth+',innerWidth='+iWidth+',top='+iTop+',left='+iLeft+',toolbar=no,menubar=no,scrollbars=auto,resizeable=no,location=no,status=no');
			window.onclick=function (){_window.focus();};
		})
		
	};

	var addRecord = function(){
		var rec = store.getNewRecord();
		store.add(rec);
		store.curRecord = rec;
	};


	/*
	 *插入数据
	 */
	$('#insert').on('click',function(){
		addRecord();
		buildForm();
	});

	/*
	 *修改数据
	 */
	$('#modify').on('click',function(){
		buildForm();
	});


	function getCheckedValue(name){
		var radio = $("input[type='radio'][name='" + name + "']");
		for(var i=0; i < radio.length; i++){
			if(radio[i].checked){
				return $(radio[i]).val();
			}			
		}
	}

	function getCheckedBoxValue(name){
		var checkedValue="";
		checkedValue = $("input:checkbox[name='"+name+"']:checked").map(function(index,elem){
			return $(elem).val();
		}).get().join(',');
		return checkedValue;
	}
	
	
	function isNumber(inputString){
		if(inputString==null) return false;
	    if(inputString.match("[0-9]")){
	         return true;
	    }else{
	         return false;
	    }
	};
	
	function isNullOrEmpty(inputString){
		if(inputString==null || inputString=="" || inputString.length==0){
			return true;
		}
		return false;
	}
	
	$('#dialog-ok').on('click',function(){
		var record =alarmInfoStore.curRecord;
		var PROC_XMLID = record.get("PROC_XMLID");
		var SMS_GROUP_ID=record.get("SMS_GROUP_ID");
		var ALARM_TYPE = getCheckedBoxValue("ALARM_TYPE");
		var MAX_SEND_COUNT = record.get("MAX_SEND_COUNT");
		var DUE_TIME_CRON = $("#upsertForm").find("#DUE_TIME_CRON").val();
		var OFFSET = $("#upsertForm").find("#OFFSET").val();
		var INTERVAL_TIME = record.get("INTERVAL_TIME");
		var IS_VALID = getCheckedValue("IS_VALID");
		
		
		if(isNullOrEmpty(SMS_GROUP_ID) || isNullOrEmpty(ALARM_TYPE) || isNullOrEmpty(IS_VALID)){
			alert("请检查,必填项不能为空");
			return false;
		}
		if(ALARM_TYPE.indexOf("1")>-1 && isNullOrEmpty(DUE_TIME_CRON)){
			alert("请检查,告警时间必填");
			return false;			
		}
		if(ALARM_TYPE.indexOf("1")>-1 && !isNumber(OFFSET)){
			alert("请检查,告警批次偏移量必须是数字");
			return false;			
		}
		
		if(ALARM_TYPE.indexOf("1")>-1 ){
			if(isNullOrEmpty(MAX_SEND_COUNT) || !isNumber(MAX_SEND_COUNT)){
				alert("请检查,发送次数必填且必须是数字");
				return false;
			}
			if(isNullOrEmpty(INTERVAL_TIME)){
				alert("请检查,选择发送间隔");
				return false;
			}
		}

		smsTaskStore.sql=smsTasksql.replace('{proc_xmlid}',PROC_XMLID);
		smsTaskStore.select();
		var record="";
		if(smsTaskStore.count==0){//新增
			record=smsTaskStore.getNewRecord();
			var XMLID = ai.guid();
		    record.set("XMLID",XMLID);
		    record.set("PROC_XMLID",PROC_XMLID);
        	smsTaskStore.add(record);
		}else if (smsTaskStore.count=1){//修改
			record = smsTaskStore.curRecord;
		}
	    record.set("SMS_GROUP_ID",SMS_GROUP_ID);
	    record.set("ALARM_TYPE",ALARM_TYPE);
	    record.set("DUE_TIME_CRON",DUE_TIME_CRON);
	    record.set("OFFSET",OFFSET);
	    record.set("MAX_SEND_COUNT",MAX_SEND_COUNT);
	    record.set("INTERVAL_TIME",INTERVAL_TIME);
	    record.set("IS_VALID",IS_VALID);
	    record.set("FLAG",'0');
	    
		var rs=smsTaskStore.commit(false);
		var rsJson =  $.parseJSON(rs);
		if(rsJson.success){
				alarmInfoStore.select();
				$('#userModal').modal('hide');
				//alert("修改成功");
			}else{
				alert("修改失败");
			}
		$('#myModal').modal('hide');
	});
	$('#dialog-cancel').on('click',function(){
		alarmInfoStore.cache={
			save:[],
			remove:[],
			update:[]
		};
		$('#myModal').modal('hide');
	});
	
	$(".close-modal").click(function(){
		alarmInfoStore.cache={
			save:[],
			remove:[],
			update:[]
		};
		$('#myModal').modal('hide');
	})
	
	function initsmsGroup_select(){
		$("#smsGroup_select").append("<option value=''>全部用户组</option>");
		for(var i=0;i<smsGroupStore.count;i++){
			var record=smsGroupStore.getAt(i);
			var smsGroupId=record.get("SMS_GROUP_ID");
			var smsGroupName=record.get("SMS_GROUP_NAME");
			$("#smsGroup_select").append("<option value='"+smsGroupId+"'>"+smsGroupId+"->"+smsGroupName+"</option>");
		}
	};
	initsmsGroup_select();
	
		//触发类型
	$('#smsGroup_select').on('change',function(e){
		$("#queryOne").trigger("click");
	});
	
		/*
	 *查询数据
	 */
	$('#queryOne').on('click',function(){
		var condi = " and (a.PROC_NAME like '%"+$("#for-query").val().trim()+"%'"+" or a.PROCCNNAME like '%"+$("#for-query").val().trim()+"%')"
		var smsGroup= $("#smsGroup_select").val();
		if(smsGroup.length>0){
			condi += " and c.SMS_GROUP_ID='"+smsGroup+"'";
		}
		alarmInfoStore.sql=sql.getContent()+condi,
		alarmInfoStore.select();
	});
	
});




</script>
<body>
	<div class="ui-layout-north">
		<nav class="navbar navbar-default" role="navigation"
			style="margin-bottom: 1px">
			<div class="container-fluid" style="padding-left: 0px">
				<div class="collapse navbar-collapse" style="padding-left: 0px">
					<form class="navbar-form navbar-left" role="search">
						<div class="form-group" >
							<select id="smsGroup_select" class="form-control formElement">
							</select>
						</div>
						<div class="form-group">
							<input type="text" class="form-control" placeholder="输入程序名/程序中文名" id="for-query">
							<input class="hide" />
						</div>
						<button class="btn btn-default" type="button" id="queryOne">查询</button>
					  <button class="btn btn-default" type="button" id="modify">设置告警信息</button>
					</form>			
   			 </div><!-- /input-group -->
  			</div><!-- /.col-lg-6 -->
  		</nav>	
  </div>
</div>
<div class="row">
  <div class="col-xs-12 col-md-12" id="grid-container"></div>
</div>
<div class="row">
  <div class="col-xs-12 col-md-12" id="tabsheet"></div>
</div>
<div class="row">
  <div class="col-xs-12 col-md-12" id="grid-ve"></div>
</div>
</div>
<input type='hidden' id='curFreq' />
<div id="myModal" class="modal fade"> 
	<div class="modal-dialog"> 
	    <div class="modal-content" > 
	     <div class="modal-header"> 
		      <button type="button" class="close close-modal" > <span aria-hidden="true">&times;</span><span class="sr-only">Close</span> </button> 
		      <h4 class="modal-title">用户管理</h4> 
	     </div> 
	     <div class="modal-body" id="upsertForm"></div> 
	     <div class="modal-footer">
			<button id="dialog-cancel" type="button" class="btn btn-default">取消</button> 
			<button id="dialog-ok" type="button" class="btn btn-primary">保存</button>
	     </div> 
	    </div>
	<!-- /.modal-content --> 
	</div> 
<!-- /.modal-dialog --> 
</div>
</body>
</html>