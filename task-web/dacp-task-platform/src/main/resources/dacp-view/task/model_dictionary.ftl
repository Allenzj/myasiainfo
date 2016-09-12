<!DOCTYPE html>
<html lang="zh" class="app">
<head>
<meta charset="utf-8" />
<title>数据字典列表</title>
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

<script src="${mvcPath}/dacp-lib/underscore/underscore-min.js"></script>

<!-- <script src="app.plugin.js"></script> -->

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


var group="";

//当前选择的组ID
var curGroupId="";

//字典组配置
var groupCfg="";
//字典配置
var dimCfg="";
//默认选中第一组
var selectIndex =0;

//字典列表
var dimGrid="";

var groupSql = "SELECT a.xmlid,group_code,group_value,group_seq,a.remark,b.num FROM proc_schedule_dim_group a " +
			   " LEFT JOIN (SELECT dim_group_id ,COUNT(1) num FROM proc_schedule_dim GROUP BY dim_group_id) b ON a.xmlid = b.dim_group_id order by group_seq ";
var dimSql = "SELECT a.xmlid,dim_group_id,dim_code,dim_value,dim_seq,a.remark,b.group_value FROM proc_schedule_dim a " +
			 " left join proc_schedule_dim_group b on a.dim_group_id = b.xmlid where 1=1 {} order by dim_seq";
var groupStore = new AI.JsonStore({
	sql : groupSql,
	pageSize : -1,
	table : 'proc_schedule_dim_group',
	key : 'XMLID',
	dataSource:"METADB"
});

var dimStore = new AI.JsonStore({
	sql :dimSql.replace("{}",""),
	table:'proc_schedule_dim',
	key:'XMLID',
	dataSource:"METADB"
});


//数字验证  
var isNumber = function(n){
	var reg = /^\d+$/;
  return reg.test(n);
};

//左边树
var buildGroupList = function(){
	var groupList = "";
	$("#groupList").empty();
	for (var i = 0; i < groupStore.getCount(); i++) {
		var r = groupStore.getAt(i);
		var activeClass = "";
		if(i == selectIndex){
			activeClass = " active ";
			curGroupId = r.data.XMLID;
		}
		groupList += '<a data-xmlid="' + r.data.XMLID
			+ '" data-code="' + r.data.GROUP_CODE
			+ '" data-value="' + r.data.GROUP_VALUE
			+ '" data-index="' + i
			+ '" class="list-group-item' + activeClass
			+ '" > <i class="icon-users icon text-warning"></i>'
			+ (r.get("GROUP_VALUE") || "其他")
			+ '<b class="badge bg-warning pull-right"> '
			+ ''+(r.get("NUM") || "0")+' </b> </a>';
	}
	whereCase = " and dim_group_id='" + curGroupId + "'";
	dimStore.select(dimSql.replace("{}",whereCase));
	$("#groupList").append(groupList);
	
	$("#groupList .list-group-item").click( function() {
		$("#groupList .list-group-item").removeClass("active");
		$(this).addClass("active");
		curGroupId = $(this).attr("data-xmlid");
		selectIndex = $(this).attr("data-index");
  	    var whereCase = curGroupId.length>0?" and dim_group_id='" + curGroupId + "'":"";
 	    dimStore.select(dimSql.replace("{}",whereCase));
	});		
}

//打开编辑组界面
var showGroupInfoDialog = function(acttype){
	$("#group-upsertForm").empty();
	var isRead = 'n';
	if(acttype=='edit'){
		isRead='y';
	}
	
	groupCfg = ({
		id : 'form',
		store : groupStore,
		containerId : 'group-upsertForm',
		items : [ 
			{type: 'text',label: '编号',notNull:'N',fieldName:'GROUP_CODE',isReadOnly:isRead,width:250},
			{type: 'text',label: '组名',fieldName : 'GROUP_VALUE',notNull:'N',width : 250 },
			{type: 'text',label: '序号',fieldName : 'GROUP_SEQ',notNull:'Y',width : 250 },
			{type: 'text',label: '说明',fieldName : 'REMARK',notNull:'Y',width : 250 }
		]
	});

	var from = new AI.Form(groupCfg);
	$('#groupModal').modal({
		show : true,
		backdrop:false		
	});
	
	//取消
	$("#groupModal #dialog-cancel").on('click', function(){
		groupStore.select();
		$('#groupModal').modal("hide");
    });
}; 

//字典列表
var buildDimList = function(){
 	$("#dimList").empty();
	dimGrid = new AI.Grid({
		store:dimStore,
		pageSize:20,
		containerId:'dimList',
		nowrap:true,
		showcheck:true,
		columns:[
			{header: "字典编号", width:100,dataIndex: 'DIM_CODE', sortable: true},
			{header: "中文名", width:120, dataIndex: 'DIM_VALUE', sortable: true},
			{header: "所属组", width: 105, dataIndex: 'GROUP_VALUE', sortable: true },
			{header: "序号", width: 105, dataIndex: 'DIM_SEQ', sortable: true },
			{header: "说明", width: 105, dataIndex: 'REMARK', sortable: true }
		]
	});	
}

//字典编辑界面
var showDimInfoDialog=function(acttype){
	  
		$("#dim-upsertForm").empty();
		var isRead='y';
		var isSelect = 'n';
		if(acttype=='add'){
		   isRead = 'n';
		   isSelect = 'y';
		}
		dimCfg = ({
			id : 'form',
			store : dimStore,
			containerId : 'dim-upsertForm',
			items : [ 
				{type:'combox',label:'所属组',notNull:'N',fieldName :'DIM_GROUP_ID',storesql:'SELECT xmlid AS K ,group_value AS V FROM proc_schedule_dim_group',width:300},
				{type:'text',label:'字典编号',notNull:'N',fieldName:'DIM_CODE',isReadOnly:isRead,width:300}, 
				{type:'text',label:'中文名',fieldName :'DIM_VALUE',notNull:'N',width:300},
				{type:'text',label:'序号',fieldName :'DIM_SEQ',notNull:'Y',width:300},
				{type: 'text',label: '说明',fieldName : 'REMARK',notNull:'Y',width : 300 }
			]
		});
		var from = new AI.Form(dimCfg);
		$('#dimModal').modal({
			show : true,
			backdrop:false
		});
		/*
		if(curGroupId.length>0){
			$("#DIM_GROUP_ID").val(curGroupId);
		}*/
		
		//取消
		$("#dimModal #dialog-cancel2").on('click', function(){
			$('#dimModal').modal("hide");
	    });
	};

//必填验证
function checkInput(cfg){
	var items = cfg.items;
	for(var i=0; i< items.length; i++){
		if(items[i].notNull=="N"){
			var item = $("#"+items[i].fieldName);
			if(typeof(item)=="undefined" || item.val().length==0){
				alert(items[i].label + "为空！");
				return false;
			}
		}
	}
	
	return true;
}

$(document).ready(function() {
   		               
	//创建组
	$("#addGroup").click(function(){
		isAdd=true;
		groupStore.curRecord = groupStore.getNewRecord();
		showGroupInfoDialog('add');
	});
	
	//修改组
	$("#editGroup").click(function() {
		groupStore.select();
		if(groupStore.count==0)curGroupId="";
		if(curGroupId.length==0){
			alert("没有选择组");
			return false;
		}
		isAdd = false;
		groupStore.curRecord = groupStore.getRecordByKey(curGroupId); 
	    showGroupInfoDialog("edit");
	});
	
	//删除组
	$("#delGroup").click(function(){
		var r = groupStore.getRecordByKey(curGroupId);
		if(confirm("确定删除平台:" + r.data.GROUP_VALUE + "?")){
			groupStore.remove(r);
			groupStore.commit(false);
            var sql="delete from  proc_schedule_dim where dim_group_id ='" + r.data.XMLID + "'";
			ai.executeSQL(sql);
			selectIndex = 0;
			buildGroupList();
			alert('已删除！');
		};
	});
	
	//保存组确定
	$("#groupModal #dialog-ok").click(function() {
		if(checkInput(groupCfg)) {
			var seq = $("#GROUP_SEQ").val();
			if(seq.length>0){
				if(isNumber(seq)){
					if(seq.length > 6){
						alert("数字长度不能超过6位！")
						return false;
					}
				}else{
					alert("无效数字!")
					return false;
				}
			}
		}else{
			return false;
		}
		var record = groupStore.curRecord;
		if(isAdd){
			record.set("XMLID",ai.guid());
			groupStore.add(record);
		}
		groupStore.commit(false);
		groupStore.select();
		buildGroupList();
		dimStore.select();
		buildDimList();
		$('#groupModal').modal("hide");
   });
	
   //创建字典
   $("#addDim").click(function(){
	   if(typeof(curGroupId)== "undefined" || curGroupId.length==0){
		   alert("没有选择字典组！");
		   return false;
	   }
   	   isAdd = true;
	   dimStore.curRecord = dimStore.getNewRecord();
       showDimInfoDialog('add');

   });
   
   //修改字典
   $("#editDim").click(function(){
   	    isAdd = false;
     	var curDim = dimGrid.getCheckedRows();
   		if(curDim.length>1 || curDim.length==0){
   			alert("只能选中一项！")
   			return false;
   		}
   		dimStore.curRecord = curDim[0];
   		showDimInfoDialog('edit');
   });
   
   //删除字典
   $("#delDim").click(function(){
   	    var curDim = dimGrid.getCheckedRows();
   		if(curDim.length==0){
   			alert("至少选中一项！")
   			return false;
   		}
   		if(confirm("确定删除所有选中项吗?")){
   			var xmlids = "";
   			for(var i = 0; i < curDim.length; i++ ){
   				xmlids += "'" + curDim[i].data.XMLID + "',";
   			}
   			xmlids = xmlids.substr(0,xmlids.length-1);
   			ai.executeSQL("delete from proc_schedule_dim where xmlid in (" + xmlids + ")",false,"METADB");
   			dimStore.select();
   			groupStore.select();
   			buildGroupList();
   			alert("已删除！");
   		}
   });
    
	//保存字典 确定
	$("#dimModal #dialog-ok2").click(function() {
		if(checkInput(dimCfg)) {
			var seq = $("#DIM_SEQ").val();
			if(seq.length>0){
				if(isNumber(seq)){
					if(seq.length > 6){
						alert("数字长度不能超过6位！")
						return false;
					}
				}else{
					alert("无效数字!")
					return false;
				}
			}
		}else{
			return false;
		}
		var record = dimStore.curRecord;
		if(isAdd){
			record.set("XMLID",ai.guid());
			dimStore.add(record);
		}

		dimStore.commit(false);
		$('#dimModal').modal("hide");
		dimStore.select();
	    buildDimList();
	    groupStore.select();
		buildGroupList();
	});
	

   //查找
   $("#searchDim").click(function(){
   	   var whereCase = "";
   	   var key = $("#input_content").val();
   	   whereCase += curGroupId.length>0?" and dim_group_id='" + curGroupId + "' ":"";
   	   whereCase += key.length>0?" and (dim_code like'%" + key + "%' or dim_value like '%" + key + "%')":"";
   	   dimStore.select(dimSql.replace("{}",whereCase));
   });
	
   buildGroupList();
   buildDimList(); 
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
													<span class="font-thin m-l-md m-t">字典组列表</span>
												</div>
												<div class="panel-body">
													<div id="groupList" style="cursor:pointer" class="list-group no-radius no-border no-bg m-t-n-xxs m-b-none auto"></div>
												</div>
												<div class="panel-footer no-border">
													<a id="addGroup" class="btn btn-sm btn-primary"> 
														<i class="fa fa-css3"> </i> 创建
													</a>
													<a id="editGroup" class="btn btn-sm btn-primary"> 
														<i class="fa fa-css3"></i> 修改
													</a>
													<a id="delGroup" class="btn btn-sm btn-danger">
														<i class="fa fa-times"></i> 删除
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
												<li class="active"><a href="#activity" data-toggle="tab"> 字典列表 </a></li>
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
															<li class="navbar-text" style="margin-top: 12px;">
																<input type="text" id="input_content" placeholder = "请输入查询关键字">
															</li>
															<li>
																<button id="searchDim" class="btn btn-sm" style="float: left; margin-top: 10px;">
																<i class="glyphicon glyphicon-eye-open"></i>查找</button>
															</li>
															<li style="margin-left :10px;float: left; margin-top: 10px;"><button id="addDim" class="btn btn-sm btn-primary" >创建</button></li>
															<li style="margin-left :10px;float: left; margin-top: 10px;"><button id="editDim" class="btn btn-sm btn-primary" >修改</button></li>
															<li style="margin-left :10px;float: left; margin-top: 10px;"><button id="delDim" class="btn btn-sm btn-primary" >删除</button></li>
														</ul>
													</div>
													<div class="row row-sm" id="dimList"></div>
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
	
	<div id="groupModal" class="modal fade" style = "z-index:10000">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button id="dialog-cancel" type="button" class="close">
						<span aria-hidden="true">&times;</span><span class="sr-only">Close</span>
					</button>
					<h4 class="modal-title">字典组信息</h4>
				</div>
				<div class="modal-body" id="group-upsertForm"></div>
				<div class="modal-footer">
					<button id="dialog-cancel" type="button" class="btn btn-default">取消</button>
					<button id="dialog-ok" type="button" class="btn btn-primary">确认</button>
				</div>
			</div>
		</div>
	</div>

	<div id="dimModal" class="modal fade" style = "z-index:10000">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button id="dialog-cancel2" type="button" class="close">
						<span aria-hidden="true">&times;</span><span class="sr-only">Close</span>
					</button>
					<h4 class="modal-title">数据字典信息</h4>
				</div>
				<div class="modal-body" id="dim-upsertForm"></div>
				<div class="modal-footer">
					<button id="dialog-cancel2" type="button" class="btn btn-default">取消</button>
					<button id="dialog-ok2" type="button" class="btn btn-primary">确认</button>
				</div>
			</div>
		</div>
	</div>
</body>
</html>