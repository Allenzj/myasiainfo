<!DOCTYPE html>
<html lang="zh" class="app">
<head>
<meta http-equiv="X-UA-Compatible" content="chrome=1, IE=edge"></meta>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></meta>
<meta charset="utf-8"></meta>
<meta name="viewport" content="width=device-width, initial-scale=1.0"></meta>
<title>统一调度平台</title>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />

<link href="${mvcPath}/dacp-res/task/images/favicon.ico" rel="shortcut icon" />
<link href="${mvcPath}/dacp-res/task/images/favicon.ico" rel="bookmark" />
<link href="${mvcPath}/dacp-view/aijs/css/ai.css" rel="stylesheet"  type="text/css" />
<link href="${mvcPath}/dacp-view/ve/css/dacp-ve-js-1.0.css" type="text/css" rel="stylesheet" media="screen"/>
<style>
html{
	height: 100%;
	overflow: hidden;
}
.top-level-nav .active {
  box-shadow: 5px 2px 6px #000000;
}

.arrow.signal {
  border-bottom-color: #E0EAEC;
  border-top-width: 0;
  content: " ";
  margin-left: 20px;
  bottom: -1px;
}

a {
  cursor: pointer;
}
</style>
<!--[if lt IE 9]>
	<script src="lib/ie/html5shiv.js">
	</script>
	<script src="lib/ie/respond.js">
	</script>
	<script src="lib/ie/excanvas.js">
	</script>
<![endif]-->
<script src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js" type="text/javascript" ></script>
<script src="${mvcPath}/dacp-lib/jquery/jquery-ui-1.10.2.min.js" type="text/javascript" ></script>
<script src="${mvcPath}/dacp-lib/underscore/underscore-min.js" type="text/javascript" ></script>
<script src="${mvcPath}/dacp-lib/backbone/backbone-min.js" type="text/javascript" ></script>
<script src="${mvcPath}/dacp-view/ve/js/dacp-ve-js-1.0.js" charset="utf-8" type="text/javascript" ></script>
<script src="${mvcPath}/ve/ve-context-path.js" charset="utf-8" type="text/javascript" ></script>
<script src="${mvcPath}/dacp-lib/gojs/go.js" type="text/javascript" ></script>
<script src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js" type="text/javascript" ></script>

<!-- 使用ai.core.js需要将下面两个加到页面 -->
<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>
	
<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
<script src="${mvcPath}/dacp-res/task/js/app.plugin.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>
<!-- 
<script src="public/js/analysis.js"></script>
<script src="dataFlow.js"></script> -->

<script type="text/javascript">
function loadTabStruct(tabname, tabcnname,readPara) {
	tabname = tabname.toUpperCase();
	var tablesql = "select a.*,(select b.usecnname from metauser b where b.username = a.curdutyer) CURDUTYER_CN,"+
	"(select c.rowname from metaedimdef c where c.rowcode = a.level_val and c.dimcode = 'DIM_DATALEVEL') LEVEL_VAL_CN,"+
	"(select count(*) from transdatamap_design d WHERE d.source = a.xmlid and d.targettype='PROC') REFCOUNT "+
	"from tablefile a where a.dataname = '" + tabname + "'";
	var ds_mydata = new AI.JsonStore({
		sql : tablesql,
		pageSize : 20
	});
	if (ds_mydata.getCount() == 0) return;
	var record = ds_mydata.getAt(0);

	$("#panelModel #tab_fullname").empty().html(tabname + "," + record.get('DATACNNAME') || "");
	for ( var key in record.data) {
		var proVal = record.get(key);
		if (key == "VERSEQ" && !proVal){
			proVal = "v1.0.0.1";
		}else if (key == "RIGHTLEVEL" && !proVal){
			proVal = '<span class="label label-danger">敏感</span>';
		}else if(key =='EXTEND_CFG' &&proVal){
			var extendcfgJson = JSON.parse(proVal);
			var partitions = extendcfgJson.PARTITIONS||'--';
			partitions = partitions.replace("month_id string","月").replace("day_id string","日").replace("hour_id string","小时").replace("city_id string","地市");
			$("#PARTITIONS").html(partitions);
			//分隔符也在这里特殊处理
			var delimiter = extendcfgJson.DELIMITER||'tab';
			$("#DELIMITER").html(delimiter);
		}
		$("#" + key).html(proVal);
	};
	
	var tabcolsql = "select col_seq,lower(colname) colname,colcnname,lower(datatype) datatype,length,remark,isnullable,key_seq from COLUMN_VAL where dataname='"
			+ tabname + "' order by col_seq";
	tabColStore = new AI.JsonStore({
		sql : tabcolsql,
		pageSize : -1,
		key : 'DATANAME',
		dataSource : 'METADB'
	});

	var gridcfg = {
		id : 'cfgtabColgrid',
		split : '',
		region : 'center',
		title : '',
		width : 120,
		height : 120,
		cfgcode : '',
		subtype : 'edgrid', //grid,ghgrid,expandgrid,edgrid,groupgrid, 
		store : tabColStore,
		columns : [
				{"header" : "编号", "width" : 70, "dataIndex" : "COL_SEQ"},
				{"header" : "字段名", "width" : 130, "dataIndex" : "COLNAME", render : function(rec) {
					return rec.get('COLNAME').toUpperCase();
				}},
				{"header" : "中文名", "width" : 130, "dataIndex" : "COLCNNAME"},
				{"header" : "类型", "width" : 81, "dataIndex" : "DATATYPE"},
				{"header" : "长度", "width" : 81, "dataIndex" : "LENGTH"},
				{"header" : "允许为空", "width" : 81, "dataIndex" : "ISNULLABLE"},
				//{"header" : "分区键", "width" : 81, "dataIndex" : "KEY_SEQ"},
				{"header" : "字段授权", "width" : 81, "dataIndex" : "COLCNNAME",
					render : function(rec) {
						//if (/号码/.test(rec.get('COLCNNAME'))) {
						if(readPara&&readPara.indexOf(rec.get('COLNAME').toUpperCase())!=-1) {
							return '<span class="label label-danger">敏感</span>';
						} else {
							return '<span class="label label-primary">非敏感</span>';
						}
					}
				},
				{"header" : "备注", "width" : 281, "dataIndex" : "REMARK"}
		],
		containerId : 'tabColgrid'
	};
	$('#tabColgrid').empty();
	var dataGrid = new AI.Grid(gridcfg);
	$("#panelModel").css({"z-index": 10011,"height":screen.height}).slideDown();
};
function openDataFlow1(objName, title,procDate,date_args,seqno,task_state) {
	$("#panel1 #tab_fullname").empty().append(title).append('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span id="overLoad"  onclick="load(\''+objName+'\',\'PROC\',\'\',\''+procDate+'\',\''+date_args+'\',\''+seqno+'\',\''+task_state+'\')" class="glyphicon glyphicon-refresh"></span>'); //标题
	$("#panel1").css("z-index", 10011).slideDown(function() {
    $("#panel1 #op-panelContent").empty().append(
			'<span style="display: inline-block; vertical-align: top; padding: 5px; width: 100%">'+
				'<div id="myDiagram" style="background-color: Snow; width:100%;height: 600px"></div>'+
			'</span>');
    loadDataFlow(objName,"PROC","",procDate,date_args,seqno,task_state);
	});
	return false;
};
function openDataFlow(objName, title,procDate,date_args,seqno,task_state) {
	$("#panel1 #tab_fullname").empty().append(title); //标题
	$("#panel1").css("z-index", 10011).slideDown(function() {
    $("#panel1 #op-panelContent").empty();
    $("#panel1 #op-panelContent").append('<span style="display: inline-block; vertical-align: top; padding: 5px; width: 100%"><div id="myDiagram" style="background-color: Snow; height: 500px"></div></span>');
          loadDataFlow(objName,"PROC","",procDate,date_args,seqno,task_state);
	});
	return false;
};
function openRelayCondition(_seqno,_procName,errCode,status){
	var errInfo="";
	switch(errCode){
		case "201":
			errInfo="同任务名的相同批次的任务在执行";
			break;
		case "202":
			errInfo="同任务名的程序在执行";
			break;
		case "203":
			errInfo="上一批次任务未执行";
			break;
		case "204":
			errInfo="未知异常";
			break;
		case "301":
			errInfo="agent 挂了";
			break;
		case "302":
			errInfo="agent 满了";
			break;
		case "303":
			errInfo="找不到agent信息";
			break;
		case "304":
			errInfo="未知异常";
			break;
		case "305":
			errInfo="发送失败";
			break;
		case "306":
			errInfo="立即执行";
			break;
		break;
		default:
		break;
	}
	$("#panel1 #tab_fullname").empty().append("查看依赖条件"); //标题
	$("#panel1").css("z-index", 10011).slideDown(function() {
    $("#panel1 #op-panelContent").empty();
    $("#panel1 #op-panelContent").append(
    		'<div class="row">'
			+ '<div class="col-sm-12">'
			+ '<section class="panel panel-default">'
			+ '<header class="panel-heading"><b>任务序列：</b>'+_seqno+'&nbsp;&nbsp;&nbsp;&nbsp;<b>程序名：</b>'+_procName+ (errInfo&&(status==2||status==3)?'&nbsp;&nbsp;&nbsp;&nbsp;<b>排队等待原因：</b>'+errInfo:"")
			+ '</b><span class="pull-right btn btn-danger btn-xs" id="setCondiSuccess">强制执行</span>'
			+ '</header> '
			+ '</section>'
            + '<div class="table-responsive" id="relay_grid" style="width: 100%;overflow: auto;"></div>'
			+ '</div></div>'
	);
	$('#op-panelContent #setCondiSuccess').on('click',function(){
		ai.executeSQL("update  proc_schedule_source_log set check_flag=1 where SEQNO='"+_seqno+"'",false,"METADBS");
	});
    var _relayStore = new AI.JsonStore({
		sql: "SELECT a.SEQNO,a.PROC_NAME,a.SOURCE,c.DATANAME,c.DBNAME,a.SOURCE_TYPE,a.DATA_TIME,a.CHECK_FLAG,CASE WHEN source_type='DATA' THEN c.CYCLETYPE ELSE b.CYCLETYPE END AS CYCLETYPE FROM PROC_SCHEDULE_SOURCE_LOG a LEFT JOIN proc b ON a.proc_name = b.proc_name LEFT JOIN TABLEFILE c ON a.SOURCE = c.XMLID  WHERE SEQNO = '"+_seqno+"' ORDER BY check_flag ",
		pageSize:20,
		key:"SEQNO",
		table:"PROC_SCHEDULE_SOURCE_LOG",
		dataSource:"METADBS"
	});
	var config={
		id:'relay-grid',
		store:_relayStore,
		pageSize:20,
		containerId:'relay_grid',
		nowrap:true,
		columns:[
			 {"header":"名称","dataIndex":"SOURCE","className":"ai-grid-body-td-left",
	  	    	 render:function(record,value){
	  	    		var res="--";
	  	    		var sourceType = record.data.SOURCE_TYPE;
	  	    		switch(sourceType){
		  	    		case "DATA":
							res = record.data.DATANAME;
							break;
						case "PROC":
							res = value;
							break;
						default:
							break;
	  	    		}
	  	    		return res;
	  	    	 }
	  	     },
			 {"header":"类型","dataIndex":"SOURCE_TYPE","className":"ai-grid-body-td-left",
	  	    	 render:function(record,value){
		  	    		var res="--";
		  	    		switch(value){
			  	    		case "PROC":
								res = "程序";
								break;
							case "DATA":
								res = "表";
								break;
							default:
								break;
		  	    		}
		  	    		return res;
		  	    	 }
			 },
			 {"header":"周期","dataIndex":"CYCLETYPE","className":"ai-grid-body-td-left",
				render:function(record,value){
		    		var res="--";
		    		switch(value){
		  	    		case "year":
							res = "年";
							break;
						case "month":
							res = "月";
							break;
						case "day":
							res = "日";
							break;
						case "hour":
							res = "小时";
							break;
						case "minute":
							res = "分钟";
							break;
						default:
							break;
		    		}
	    			return res;
	    	 	}
			 },
			 {"header":"数据日期","dataIndex":"DATA_TIME","className":"ai-grid-body-td-left",
				 render:function(record,value){
					 var res="--";
					 if(value=="N"){
						 res="无";
					 }else{
						var argsType = record.data.CYCLETYPE;
						switch(argsType){
							case "month":
								res = value.indexOf('-')>0?value.substr(0,7):value.substr(0,6);
								break;
							case "year":
								res = value.substr(0,4);
								break;
							default:
								res = value
								break;
						}
					 }
					 return res;
				 }
			 },
			 {"header":"检测通过","dataIndex":"CHECK_FLAG",render:function(value){ return _.template('<span class="glyphicon glyphicon-<%=CHECK_FLAG==0?"remove":"ok"%>"></span>',{'CHECK_FLAG':value.get("CHECK_FLAG")});}}
		]
    };
    var grid =new AI.Grid(config);
	});
}
function openTableInfo(tabname, title, template, flag) {
	$("#panel1 #tab_fullname").empty().append(title); //标题
	flag ? $("#panel1 .op-panelChange").show() : $("#panel1 .op-panelChange").hide();//隐藏、显示向左向右

	//注册向左向右的点击事件
	$("#panel1 .op-bt-close.op-panelChange").attr("id", "push-left-" + tabname);
	$("#panel1 .op-bt-nav.op-panelChange").attr("id", "push-right-" + tabname);

	$("#panel1 #op-panelContent").empty().append(template);//内容
	$("#panel1").triggerHandler("finishRender");//注册后续触发时间

	$("#panel1").css("z-index", 10011).slideDown(function() {
		if (tabname.indexOf("ana") != -1) {
			var _type = tabname.split("-")[1];
			$("#panel1 #op-panelContent")
			.empty()
			.append('<span style="display: inline-block; vertical-align: top; padding: 5px; width: 100%"><div id="myDiagram" style="background-color: Snow; height: 500px"></div></span>');
			init(_type.toLowerCase(), template);
		} else if (tabname === 'focusMonitor') {
		}
	});
	return false;
};
function openDialog(_url,title,w,h){
	$.dialog.open(_url, {
				resize: !0,
				fixed: !0,
			 
				//ico: core.ico("folder"),
				title:title||"详细信息...",
				width: 880,
				height: 450
			})
};
function exchangeTeam(groupCode){
	$('#exchange-team a[groupcode="'+groupCode+'"]').trigger('click');
};
function updateUserRole(rolename){
	_UserInfo['userRole']=rolename;
}
$(document).ready(function() {
	ai.loadWidget('dialog');
	$(window).resize(function() {
		var t;
		u = $(window).height();
		$("#panel1").css({height : u + "px"});
	});
	u = $(window).height();
	$("#panel1").css({height : u + "px"});
	$("#panel1 .op-bt-closeall").click(function() {
		$("#panel1").slideUp();
	});
	$("#panel1 .op-panelChange").on("click",function(e) {
		$("#panel1").trigger($(e.currentTarget).attr("id"));
	});
	$("#panelModel .op-bt-closeall").click(function() {
		$("#panelModel").slideUp();
	});
	
	//format 菜单
	var iconclassArray=['icon-user-following','icon-user-unfollow','icon-trophy','icon-speedometer','icon-social-youtube','icon-social-twitter','icon-social-tumblr','icon-social-facebook','icon-social-dropbox','icon-social-dribbble','icon-shield','icon-screen-tablet','icon-screen-smartphone','icon-screen-desktop','icon-plane','icon-notebook','icon-moustache','icon-mouse','icon-magnet','icon-magic-wand','icon-hourglass','icon-graduation','icon-ghost','icon-game-controller','icon-fire','icon-eyeglasses','icon-envelope-open','icon-envelope-letter','icon-energy','icon-emoticon-smile','icon-disc','icon-cursor-move','icon-crop','icon-credit-card','icon-chemistry','icon-bell','icon-badge','icon-anchor','icon-action-redo','icon-action-undo','icon-bag','icon-basket','icon-basket-loaded','icon-book-open','icon-briefcase','icon-bubbles','icon-calculator','icon-call-end','icon-call-in','icon-call-out','icon-compass','icon-cup','icon-diamond','icon-direction','icon-directions','icon-docs','icon-drawer','icon-drop','icon-earphones','icon-earphones-alt','icon-feed','icon-film','icon-folder-alt','icon-frame','icon-globe','icon-globe-alt','icon-handbag','icon-layers','icon-map','icon-picture','icon-pin','icon-playlist','icon-present','icon-printer','icon-puzzle','icon-speech','icon-vector','icon-wallet','icon-arrow-down','icon-arrow-left','icon-arrow-right','icon-arrow-up','icon-bar-chart','icon-bulb','icon-calendar','icon-control-end','icon-control-forward','icon-control-pause'];
	var modelcode = "";
	var createMainMenuJsonData = function(root) {
		//var modelcode = $("").val();
		var data, mainMenu, _i, _len, _results = [];
			for (_i = 0, _len = root.length; _i < _len; _i++) {
			data = root[_i];
		   var defaultIconClass= iconclassArray[_i % 30];
    	 	if(!data.IMAGES) data.IMAGES="fa "+ defaultIconClass+" icon text-info-dker"
    	};
		for (_i = 0, _len = root.length; _i < _len; _i++) {
			data = root[_i];
			 
			if (!(data.PARENTCODE === null || (modelcode && data.MODELCODE === modelcode))) {
				continue;
			}
			mainMenu = {
				name : data.MODELNAME,
				modelname : data.MODELCODE
			};
			createSubMenuJD(root, mainMenu);
			_results.push(mainMenu);
		}
		return _results;
	};
	var createSubMenuJD = function(root, currentNode) {
		var allSubMenu, localSubMenu, record, _i, _len;
		allSubMenu = [];
		for (_i = 0, _len = root.length; _i < _len; _i++) {
			record = root[_i];
			if (!(currentNode.modelname === record.PARENTCODE)) {
				continue;
			}
			localSubMenu = {
				name : record.MODELNAME,
				modelname : record.MODELCODE,
				parentcode : record.PARENTCODE,
				url : record.URL,
				image : record.IMAGES
			};
			allSubMenu.push(localSubMenu);
			createSubMenuJD(root, localSubMenu);
		}
		if (allSubMenu.length > 0) {
			return currentNode.submenu = allSubMenu;
		}
	};
	//点击顶级菜单
	var topNavLink = function(el){
		$("#left-nav-bar").empty();
		$("#left-nav-collapse").empty();
		var _menu = createMainMenuJsonData(ds_mydata.root);
		buildMenu(_menu);
		// var _newHref = "";
		// if (el.attr("href") == "#") {
		// 	for (var i = 0; i < _menu.length; i++) {
		// 		if (_menu[i].modelname == modelcode) {
		// 			var getURL = function(m){
		// 				var _u = "";
		// 				if(m.url&&m.url.length>0){
		// 					_u = m.url;
		// 				}else{
		// 					_u = getURL(m.submenu[0]);
		// 				}
		// 				return _u;
		// 			};
		// 			_newHref = getURL(_menu[i].submenu[0]);
		// 		}
		// 	}
		// } else {
		// 	_newHref = el.attr("href");
		// }
		// $("#framecontent").attr("src",_newHref);
/*		var _topHeight = $(".navbar-fixed-top-xs")
				&& $(".navbar-fixed-top-xs").length > 0 ? $(".navbar-fixed-top-xs")[0].offsetHeight
				: 0;
		$("#framecontent").css("height",window.screen.height - _topHeight*2);*/
		$(".top-level-nav .signal").addClass("hide");
		el.find(".signal").removeClass("hide");
		return false;
	};
	//顶级菜单
	var buildTopMenu=function(models){
    	var topMenuHtml="",moremenu="",moremenuItem="";
		for(var i=0;i<models.length;i++){
			var r=models[i];
    	 	var menuClass="top-level-nav blog-nav-item";
    	 	var arrowhide="hide";
    	 	if(i===0){
    	 		modelcode=r['modelname'];
				menuClass="top-level-nav blog-nav-item"; arrowhide="";
    	 	};
    	    if(i<5){
    	    	topMenuHtml+='<li><a href="#" id="'+r['modelname']+'" class="'+menuClass+'" style="font-size:16px;">'+r['name']+' <span class="arrow signal '+arrowhide+'"> </span></a></li>';
    	    }
    	    else {
    	    	if(!moremenu) moremenu='<li class="dropdown">'+
    	    	    '<a href="#" class="dropdown-toggle bg clear" data-toggle="dropdown"  style="font-size:16px;">更多..<b class="caret"></b>'+
    	    	    '<ul class="dropdown-menu animated fadeInRight aside-sm text-left">';
				moremenuItem+='<li><a class="top-level-nav" href="#" id="'+r['modelname']+'" ><i class="fa fa-bolt"></i><span class="m-l-sm">'+r['name']+' </span></a></li>'; 
    	    };
    	};
		if(moremenuItem)  moremenu=moremenu+moremenuItem+"</ul></li>";

		topMenuHtml+=moremenu;
    	$("#topMenu").empty().append(topMenuHtml);
    	$(".top-level-nav").on("click",function(e) {
    		modelcode = $(e.currentTarget).attr("id");
    		topNavLink($(e.currentTarget));
    	});
    };
    //菜单链接
	var navLink = function() {
		var linkHref = $(this).attr("href");
		if(!linkHref) return false;
		 
		var newhref = window.location.href.replace(/\/[^\/]+\.html/,'/');
		newhref =  linkHref;
		
		newhref = newhref.replace('{team_code}', _UserInfo.teamCode).replace('{username}', _UserInfo.username);
		newhref += newhref.indexOf('?')!=-1?'&':'?';
		newhref += ('USERROLE='+encodeURI(_UserInfo.userRole));
		newhref += ('&GROUPCODE='+encodeURI(_UserInfo.groupCode));
		if(newhref.indexOf('{contextPath}') > 0) {
			newhref = newhref.replace("{contextPath}", contextPath);
		}else{
			newhref = '${mvcPath}/'+newhref;
		}
		
		$("a.left-nav-link span").removeClass("text-warning");
		$(this).find("span").addClass("text-warning");
		var datatype = $(this).attr("data-type");

		if($(this).find('i').hasClass("window-open")){
			//modify for 湖北集成sa自助查询  通过metamodel.IMAGES字段配置的window-open的class来控制
			window.open(linkHref.replace('{team_code}', _UserInfo.teamCode).replace('{username}', _UserInfo.username));
		}else{

		if (datatype == "content") {
			$.ajax(newhref).done(function(r) {
				$("#content .vbox").empty().append(r);
			});
			return false;
		} else {
				if ($("#framecontent")) {
					$("#framecontent").attr("src", newhref);
				} else {
					$('<iframe id="framecontent" src="'+newhref+ '" width="100%" height="100%" frameborder="0" border="0" marginwidth="0" marginheight="0" ></iframe>')
							.appendTo($("#content .vbox"));
				}
/*			var _topHeight = $(".navbar-fixed-top-xs")
					&& $(".navbar-fixed-top-xs").length > 0 ? $(".navbar-fixed-top-xs")[0].offsetHeight
					: 0;
			$("#framecontent").css("height",window.screen.height - _topHeight*2);*/
			};
		};
		return false;
	};
	//构建菜单
	var buildUnionMenu = function(unionMenu){
		var _smChild = unionMenu.submenu || [];
		var _tmpl="";
		if(_smChild.length==0){
			_tmpl='<li>'
				+ '<a href="'
				+ (unionMenu.url == null ? "#" : unionMenu.url)
				+ '" class="auto left-nav-link" id="'+unionMenu['modelname']+'" style="font-size:14px;">'
				+ (unionMenu.parentcode==modelcode?' <i class="'+unionMenu.image+'"> </i>':' <i class="fa fa-angle-right text-xs"> </i> ')
				+ ' <span class="font-bold" style="font-size:14px;"> '
				+ unionMenu.name
				+ '</span> '
				+ '</a></li>';
		}else{
			_tmpl='<li>'
			+ '<a href="#" class="auto" >'
			+ '<span class="pull-right text-muted"> '
			+ '<i class="fa fa-angle-left text"> </i> '
			+ '<i class="fa fa-angle-down text-active"> </i>'
			+ '</span>'
			+ (unionMenu.parentcode==modelcode?' <i class="'+unionMenu.image+'"> </i>':' <i class="fa fa-angle-right text-xs"> </i> ')
			+ ' <span class="font-bold" style="font-size:14px;"> '
			+ unionMenu.name
			+ '</span> '
			+ '</a>'
			+ '<ul class="nav dk text-sm" id="'+unionMenu.modelname+'"" style="font-size:14px;">';
			for(var i=0;i<_smChild.length;i++){
				_tmpl+=buildUnionMenu(_smChild[i]);
			}
			_tmpl +='</ul></li>';
		}
		return _tmpl;
	};
	var buildMenu = function(menu) {
		var _menu = menu || [];
		for (var i = 0; i < _menu.length; i++) {
			if (_menu[i].modelname == modelcode) {
				var _sm = _menu[i].submenu || [];
				var _tmpl="";
				for (var j = 0; j < _sm.length; j++) {
					_tmpl += buildUnionMenu(_sm[j]);
				}
				$("#left-nav-collapse").empty().append(_tmpl);
			}
		}
		$("a.left-nav-link").bind("click", navLink);
		$("a.left-nav-link:lt(1)").click();
	};
	var _condi = _UserInfo.username==='sys'?" WHERE a.STATE = 'task' ":(", METAPERMISSION b  WHERE  a.STATE = 'task' AND b.groupcode='"+_UserInfo.groupCode+"' AND a.MODELCODE = b.MODELCODE");
	var _sql = "SELECT distinct a.MODELCODE,a.MODELNAME,a.PARENTCODE,a.IMAGES,a.REMARK,a.URL,a.SEQ FROM METAMODEL a {condi} ORDER BY a.SEQ,a.MODELCODE";
	var ds_mydata = new AI.JsonStore({
		sql : _sql.replace('{condi}', _condi),
		key : "MODELCODE",
		pageSize : -1,
		table : "METAMODEL"
	});
	ds_mydata.on('dataload',function(){
		var _wholeMenu = createMainMenuJsonData(ds_mydata.root);
		buildTopMenu(_wholeMenu);
		buildMenu(_wholeMenu);
	});
	ds_mydata.select();

	//左侧菜单伸缩
	$("#left-nav-toggle").on("click",function() {
		$("#nav").toggleClass("nav-xs");
		$("#left-logo").toggleClass("aside");
		$("#left-logo").is('.aside')?$("#left-logo img").hide():$("#left-logo img").show();
		$("#nav-toggle-arrow").toggleClass("icon-arrow-right");
		$("#nav-toggle-arrow").toggleClass("icon-arrow-left");
	});
	$("#toggleTitle").on("click",function(e){
		$(e.currentTarget).find("i").toggleClass("text");
		$(e.currentTarget).find("i").toggleClass("text-active");
		$('.navbar-fixed-top-xs').toggleClass("hide");
		if($('.navbar-fixed-top-xs').is(".hide")){
			$('#content').css('top:0;');
		}else{
			$('#content').css('top:40px;');
		}
	});
	//用户信息
	$("#current-user-info1").empty().append(
		' <span class="thumb-sm avatar pull-right m-t-n-sm m-b-n-sm m-l-sm">'
		+ '<img src="${mvcPath}/dacp-res/task/images/face.png" alt="...">'
		+ '</span>' + _UserInfo.usercnname
		+ '<b class="caret"></b>');
	//团队信息以及切换团队
	$('#current-team').append(_UserInfo.groupName+'<i class="fa fa-exchange"></i> ');
	$('#current-team').attr('groupCode',_UserInfo.groupCode);
	var html="";
	$.each(_UserInfo.userGroups,function(i, item){
		html += '<li>'
					+ '<a groupCode="' + item.groupCode + '" groupType="' + item.groupType + '" teamCode="' + item.teamCode + '">'
					+ '<i class="fa fa-briefcase"></i>'
					+ '<span class="m-l-sm">' + item.groupName + '</span></a>'
				+ '</li>'
	});
	$("#exchange-team").append(html);
	
	/*
	$("#exchange-team").append(_.template('<% _.each(models, function(model){%>'
			+ '<li>'
			+ '<a groupCode="<%=model["groupCode"]%>" groupType="<%=model["groupType"]%>" teamCode="<%=model["teamCode"]%>">'
			+ '<i class="fa fa-briefcase"></i>'
			+ '<span class="m-l-sm"><%=model["groupName"]%></span></a></li>'
			+ '<%});%>',{models:_UserInfo.userGroups}));*/
	$('#exchange-team a').on('click', function(e) {
				var currEl = $(e.currentTarget);
				var currGroupEl = $('#current-team');
				if (currEl.attr('groupCode') != currGroupEl.attr('groupCode')) {
					currGroupEl.attr('groupCode', currEl.attr('groupCode'));
					currGroupEl.empty().append(currEl.find('span').text() + '<i class="fa fa-exchange"></i> ');
					_UserInfo.groupCode = currEl.attr('groupCode');
					_UserInfo.groupName = currEl.find('span').text();
					_UserInfo.groupType = currEl.attr('groupType');
					_UserInfo.teamCode = currEl.attr('teamCode');
					_condi = currEl.attr('groupCode') === 'admin' || _UserInfo.username === 'sys' ? "WHERE a.STATE = 'on' " : (", METAPERMISSION b WHERE   a.STATE = 'on' AND  B.GROUPCODE = '"+_UserInfo.groupCode+"' AND a.MODELCODE = b.MODELCODE ");
					ds_mydata.select(_sql.replace('{condi}', _condi));
					}
	});
/*	var _topHeight = $(".navbar-fixed-top-xs")
				&& $(".navbar-fixed-top-xs").length > 0 ? $(".navbar-fixed-top-xs")[0].offsetHeight
				: 0;
	$("#framecontent").css({"height" : window.screen.height - _topHeight*2});*/
	$("#framecontent").load(function(){
		//var mainheight = $(this).contents().find("body").height()-10;
		var mainheight = $(this).parent().height()-10;
		$(this).height(mainheight);
	});
	$('#logout').on('click',function(){
		$.ajax({
			url:"/"+contextPath+"/sso/logout"
			,type : "post"
			,success:function(data, status){
				//window.location="/"+contextPath+"/index.html";
				window.location="/"+contextPath+"/login";
			}
		});
	});
});
</script>
</head>
<body>
	<section class="vbox">
		<section>
			<section class="hbox stretch">
				<!-- .aside -->
				<aside class="bg-dark dk aside hidden-print" id="nav">
					<section class="vbox">
 						<header class="header hidden-xs no-padder text-center-nav-xs">
							<div class="bg hidden-xs ">
								<div class="navbar-header hidden-xs bg-info dk aside" id="left-logo" style="height:40px">
									<a class="btn btn-link visible-xs"
										data-toggle="class:nav-off-screen,open"
										data-target="#nav,html"> <i class="icon-list"> </i>
									</a> <a href="index"
										class="navbar-brand text-lt hidden-nav-xs navbar-brand-title" ><img src="${mvcPath}/dacp-res/task/images/logo.png" alt="."
										style="max-height: 40px;display:none;"> <span
										class="hidden-nav-xs m-l-xs hide"> DACP </span>
										<span class="hidden-nav-xs m-l-xs"> 统一调度平台 </span>
									</a> <a class="btn btn-link visible-xs" data-toggle="dropdown"
										data-target=".user"> <i class="icon-settings"> </i>
									</a> <a class="hidden-nav-xs hide" id="toggleTitle"><span
										class="pull-right" style="padding:10px;"> <i
											class="fa fa-angle-double-left text"> </i> <i
											class="fa fa-angle-double-right text-active"> </i></span></a>
								</div>
							</div>
						</header>
						<section class="w-f-md scrollable">
							<div class="slim-scroll hidden-xs" data-height="auto"
								data-disable-fade-out="true" data-distance="0" data-size="10px"
								data-railOpacity="0.2">
								<!-- nav -->
								<nav class="nav-primary hidden-xs">
									<ul class="nav bg clearfix" id="left-nav-bar">
<!-- 										<li class="hidden-nav-xs padder m-t m-b-sm text-xs text-muted">
											开发配置信息</li> -->
									</ul>
 									<ul class="nav" data-ride="collapse" id="left-nav-collapse">
									</ul>
								</nav>
								<!-- / nav -->
							</div>
						</section>
						<footer class="footer hidden-xs no-padder text-center-nav-xs">
							<div class="hidden-xs ">
								<div class="wrapper-sm clearfix">
									<a class="auto" id="left-nav-toggle"> <i
										class="icon-arrow-left icon" id="nav-toggle-arrow"
										style="font-size: 20px;"> </i> <span
										class="hidden-nav-xs m-l m-b text text-muted m-t-xs">
											隐藏 </span>
									</a>
								</div>
							</div>
						</footer>
					</section>
				</aside>
				<!-- /.aside -->
				<section>
					<section class="vbox">
						<header
							class="bg-info header header-md navbar navbar-fixed-top-xs">
							<ul class="nav navbar-nav hidden-xs" id="topMenu"></ul>
							<form
								class="navbar-form navbar-left input-s-lg m-l-n-xs hidden-xs"
								role="search">
								<div class="form-group hide">
									<div class="input-group">
										<input id="searchkeyword" type="text"
											class="form-control input-sm no-border bg-white rounded"
											placeholder="请输入关键字..."> <span
											class="input-group-btn">
											<button class="btn btn-sm bg-white btn-icon rounded"
												id="searchbtn">
												<i class="fa fa-search"> </i>
											</button>
										</span>
									</div>
								</div>
							</form>
							<div class="navbar-right ">
								<ul class="nav navbar-nav m-n hidden-xs nav-user user">
									<li class="hidden-xs hide"><a href="#"
										class="dropdown-toggle lt" data-toggle="dropdown"> <i
											class="icon-bell"> </i> <span
											class="badge badge-sm up bg-danger count"> 2 </span>
									</a>
										<section class="dropdown-menu aside-xl animated fadeInUp">
											<section class="panel bg-white">
												<div class="panel-heading b-light bg-light">
													<strong> 你有<span class="count"> 3 </span> 消息
													</strong>
												</div>
												<div class="list-group list-group-alt">
													<a href="#" class="media list-group-item"> <span
														class="media-body block m-b-none">
															cai提交metamodel表的修改 <br> <small class="text-muted">
																3 分钟前 </small>
													</span>
													</a> <a href="#" class="media list-group-item"> <span
														class="media-body block m-b-none">
															cai提交metamodel表的修改 <br> <small class="text-muted">
																3 分钟前 </small>
													</span>
													</a>
												</div>
												<div class="panel-footer text-sm">
													<a href="#" class="pull-right"> <i class="fa fa-cog">
													</i>
													</a> <a href="mteam/devTeam.html" class="left-nav-link"
														data-toggle="class:show animated fadeInRight">进入消息页面 </a>
												</div>
											</section>
										</section></li>
									<li class="dropdown"><a id="current-team" class="dropdown-toggle bg clear" data-toggle="dropdown"></a>
										<ul id="exchange-team" class="dropdown-menu animated fadeInRight aside-sm text-left">
										</ul></li>
									<li class="dropdown"><a href="#"
										class="dropdown-toggle bg clear" data-toggle="dropdown"
										id="current-user-info1"> </a>
										<ul
											class="dropdown-menu animated fadeInRight aside-sm text-left">
											<li class="hide"><a href="profile.html"><i
													class="fa fa-briefcase"></i><span class="m-l-sm">
														数据规划 </span></a></li>
											<li class="hide"><a href="msg/msg.html" class="top-level-nav"
												id="msg"> <span class="badge bg-danger pull-right">
														3 </span> <i class="fa fa-envelope-o"></i><span class="m-l-sm">
														消息通知</span>
											</a></li>
											<li><span class="arrow top"> </span> <a href="#"
												id="sysmgr" class="top-level-nav"> <i class="fa fa-bolt"></i><span
													class="m-l-sm"> 系统管理</span></a></li>
											<li><a href="help/help.html" class="top-level-nav"
												id="help"> <i class="fa fa-question"></i> <span
													class="m-l-sm"> 帮助 </span>
											</a></li>
											<li class="divider"></li>
											<li><a href="modal.lockme.html" data-toggle="ajaxModal">
													<i class="fa fa-lock"></i><span class="m-l-sm"> 锁定 </span>
											</a></li>
											<li><a id="logout" >
													<i class="fa fa-lock"></i><span class="m-l-sm"> 登出 </span>
											</a></li>
										</ul></li>
								</ul>
							</div>
						</header>
						<section id="content">
							<section class="vbox">
								<iframe id="framecontent" src=""
									width="100%" height="100%" frameborder="0" border="0"
									marginwidth="0" marginheight="0"></iframe>
							</section>
						</section>
					</section>
				</section>
			</section>
		</section>
	</section>

	<!-- begin div panel1  -->
	<div id="panel1" class="op-panel solid-white" data-open="0"
		style="z-index: 10001; top: 0px; left: 0px; height: 342px; display: none;">
		<!-- Start Control -->
		<div class="op-panelctrl solid-black">
			<!-- Close Button -->
			<!-- <div class="op-panelbt op-bt-close op-panelChange" id="push-left">
				<img src="public/images/48-arrow-left.png" alt="close">
			</div> -->
			<!-- End Close button -->
			<!--<div class="op-panelbt op-tab op-bt-nav op-panelChange"
				id="push-right">
				<img src="public/images/48-arrow-right.png" alt="navbar">
			</div> -->
			<!-- NavBar Button -->
			<div class="op-panelbt op-tab op-bt-nav">
				<h2 class="title" id="tab_fullname">NWH.MBUSER,用户资料表</h2>
			</div>
			<!-- End NavBar Button -->
			<!-- Close All -->
			<div class="op-panelbt op-bt-closeall pull-right">
				<img src="${mvcPath}/dacp-res/task/images/close-white-48a.png" alt="close all">
			</div>
			<!-- End Close All -->
			<div class="clearspace"></div>
		</div>
		<!-- End Control -->
		<!-- Panel Content -->
		<div class="op-panelform" id="op-panelContent"
			style="padding: 15px 40px 100px"></div>
		<!-- End Panel Content -->
	</div>
	<!-- end div panel1  -->

	<!-- begin div panelModel -->
	<div id="panelModel" class="op-panel solid-white" data-open="0"
		style="z-index: 10001; top: 0px; left: 0px; height: 342px; display: none;">
		<!-- Start Control -->
		<div class="op-panelctrl solid-black">
			<!-- NavBar Button -->
			<div class="op-panelbt op-tab op-bt-nav">
				<h2 class="title" id="tab_fullname">NWH.MBUSER,用户资料表</h2>
			</div>
			<!-- End NavBar Button -->
			<!-- Close All -->
			<div class="op-panelbt op-bt-closeall pull-right">
				<img src="${mvcPath}/dacp-res/task/images/close-white-48a.png" alt="close all">
			</div>
			<!-- End Close All -->
			<div class="clearspace"></div>

		</div>
		<!-- End Control -->

		<!-- Panel Content -->
		<div class="op-panelform" style="padding: 0px 40px 200px; height: 600px;">

			<h3 class="light-text">表基本信息</h3>
			<div class="row">
				<div class="col-lg-4">
					<h4>基本信息1</h4>
					<table
						class="table table-condensed table-responsive table-user-information">
						<tbody>
							<tr>
								<td>敏感级别:</td>
								<td id="RIGHTLEVEL"></td>
							</tr>
							<tr>
								<td>责任人:</td>
								<td id="CURDUTYER_CN">CURDUTYER_CN</td>
							</tr>
							<tr>
								<td>层次:</td>
								<td id="LEVEL_VAL_CN">LEVEL_VAL_CN</td>
							</tr>
							<tr>
								<td>归属主题:</td>
								<td id="TOPICNAME">TOPICNAME</td>
							</tr>
							<tr>
								<td>状态:</td>
								<td id="STATE">STATE</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="col-lg-4">
                    <h4>基本信息2</h4>
					<table
						class="table table-condensed table-responsive table-user-information">
						<tbody>
							<tr>
								<td>创建时间:</td>
								<td><span id="EFF_DATE">EFF_DATE</span></td>
							</tr>
							<tr>
								<td>分区键:</td>
								<td id="PARTITIONS">PARTITIONS</td>
							</tr>
							<tr>
								<td>生命周期:</td>
								<td><span id='DATEFIELD'></span><span id='DATEFMT'></span></td>
							</tr>
							<tr>
								<td>分隔符:</td>
								<td id="DELIMITER">DELIMITER</td>
							</tr>
							<tr>
								<td>ETL引用次数:</td>
								<td id="REFCOUNT">REFCOUNT</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="col-lg-4 hide">
					<h4>存储信息</h4>
					<table
						class="table table-condensed table-responsive table-user-information">
						<tbody>
							<tr>
								<td>仓库:</td>
								<td><span class="label label-primary">Y</span></td>
							</tr>
							<tr>
								<td>web库:</td>
								<td><span class="label label-primary">Y</span></td>
							</tr>
							<tr>
								<td>云平台:</td>
								<td><span class="label label-default">N</span></td>
							</tr>
							<tr>
								<td>地市库:</td>
								<td><span class="label label-default">Y</span></td>
							</tr>
							<tr>
								<td>表大小</td>
								<td>字段数<span id="FIELDNUM"></span>,行:<span id="ROWNUM"></span>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="col-lg-4 hide">
					<h4>应用信息</h4>
					<table
						class="table table-condensed table-responsive table-user-information">
						<tbody>
							<tr>
								<td>当前可用周期:</td>
								<td><span id='DWDBMIN'></span>-<span id='DWDBMAX'></span></td>
							</tr>
							<tr>
								<td>ETL引用次数:</td>
								<td id="REFCOUNT">REFCOUNT</td>
							</tr>
							<tr>
								<td>应用引用次数:</td>
								<td></td>
							</tr>
							<tr>
								<td>数据生成时间:</td>
								<td id="STATE"></td>
							</tr>
							<tr>
								<td>重要程度</td>
								<td></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>

			<h3 class="light-text">字段结构信息</h3>
			<div id="tabColgrid"></div>
			<div class="clearspace"></div>
		</div>
		<!-- End Panel Content -->

	</div>
	<!-- End div panelModel -->
	<!-- modal -->
	<div id="genaral_modal" class="modal fade modal-lg">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">&times;</span><span class="sr-only">Close</span>
					</button>
					<h4 class="modal-title" id="genaral_modal_title"></h4>
				</div>
				<div class="modal-body" id="genaral_modal_content"></div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
				</div>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	</div>
	<!-- /.modal -->

<div id="loadingmask" class="modal fade in" style="display:none;">
	<div class="modal-body">
		<span class="loading-icon" ></span><h5 style="font-weight:700;">加载中请稍候....</h5>
	</div>
</div>
<div id="loadingBackDrop" class="modal-backdrop fade in" style="display:none;"></div>
</body>
</html>