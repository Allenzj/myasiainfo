<html lang="zh">
<head>
<title>程序步骤编排</title>
<meta http-equiv="X-UA-Compatible" content="chrome=1, IE=edge"></meta>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" type="text/css" href="${mvcPath}/dacp-lib/ext/resources/css/ext-all.css" />
<link rel="stylesheet" type="text/css" href="${mvcPath}/dacp-lib/ext/resources/css/xtheme-gray.css" />
<script type="text/javascript" src="${mvcPath}/dacp-lib/ext/lib/ext/ext-base.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/ext/lib/ext/ext-all.js"></script>
<link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet" media="screen"/>
<link rel="stylesheet" type="text/css" href="${mvcPath}/dacp-res/task/css/grapheditor.css">
<style>
#nodeform input {} 
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
    /*width: 50%;*/
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

#nodeform .form-group{
	margin-bottom: 5px;
}

table{
	word-wrap:break-word; 
	table-layout: auto; 
	max-width: 100%;
	background-color: transparent;
}
table th {
	padding:5px;
	border:1px solid #EAEEF1;
	border-width:0 0px 0px 1px;
	}
thead th {
		background:#36B0C8;
		 
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
var RESOURCES_PATH = 'resources';
var RESOURCE_BASE = RESOURCES_PATH + '/grapheditor';
var STENCIL_PATH = 'stencils';
var IMAGE_PATH = 'images';
var STYLE_PATH = 'styles';
var CSS_PATH = 'styles';
var OPEN_FORM = 'open.html';

// Specifies connection mode for touch devices (at least one should be true)
var tapAndHoldStartsConnection = true;
var showConnectorImg = true;

// Parses URL parameters. Supported parameters are:
// - lang=xy: Specifies the language of the user interface.
// - touch=1: Enables a touch-style user interface.
// - storage=local: Enables HTML5 local storage.
var urlParams = (function(url) {
    var result = new Object();
    var idx = url.lastIndexOf('?');

    if (idx > 0) {
        var params = url.substring(idx + 1).split('&');

        for (var i = 0; i < params.length; i++) {
            idx = params[i].indexOf('=');

            if (idx > 0) {
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
mxBasePath = './';
mxLanguage = urlParams['lang'];
mxLanguages = ['zh'];
</script>

<script type="text/javascript" src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/underscore/underscore-min.js"></script>

<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>

<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>

<script src="${mvcPath}/dacp-view/aijs/js/ai.funcEditer.js"></script>
<script src="${mvcPath}/dacp-res/task/js/metaStore.v1.js"></script>

<script type="text/javascript" src="${mvcPath}/dacp-lib/ext/aiext/flowchar/mxClient.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/ext/aiext/flowchar/Editor.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/ext/aiext/flowchar/Graph.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/ext/aiext/flowchar/Shapes.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/ext/aiext/flowchar/EditorUi.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/ext/aiext/flowchar/Actions.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/ext/aiext/flowchar/Menus.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/ext/aiext/flowchar/Sidebar.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/ext/aiext/flowchar/Toolbar.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/ext/aiext/flowchar/Dialogs.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/ext/aiext/flowchar/jscolor/jscolor.js"></script>
<script type="text/javascript">
	var actType = paramMap.ACTTYPE||"";
    var METAPRJ = paramMap.METAPRJ || "";
    var _METAPRJ = METAPRJ ? "_" + METAPRJ : "";
    var UPDATESERIALID = paramMap.UPDATESERIALID || "";
    var teamCode = paramMap.TEAMCODE;

    var procName = (paramMap.PROCNAME || paramMap.objname) || "AcAcct";
    var CYCLE = paramMap.CYCLE || "日",
        TOPICNAME = paramMap.TOPICNAME || "",
        LEVEL = paramMap.LEVEL || "";
    var editor;
    var graph; ///图形对象
    var graphStore; //数据存储对象
    var funcEditer;

    var checkGraph = function() {
        var parent = graph.getDefaultParent();
        var childCount = graph.getModel().getChildCount(parent);
        var msg = null;
        //var startCell;
        ///先检查连线

        for (var i = 0; i < childCount; i++) {
            var child = graph.getModel().getChildAt(parent, i);
            if (child.isEdge()) {
                if (child.source == null) {
                    msg = '警告：有对象未正确连接';
                    graph.setCellStyles(mxConstants.STYLE_STROKECOLOR, '#FFD700', [child]);
                    break;
                }
                if (child.target == null) {
                    msg = '警告：有对象未正确连接';
                    graph.setCellStyles(mxConstants.STYLE_STROKECOLOR, '#FFD700', [child]);
                    break;
                }

                if(child.source != null && child.target != null){
                     if (graph.getCellStyle(child).strokeColor == '#FFD700') {
                        if(child.getValue() == "失败时")
                            graph.setCellStyles(mxConstants.STYLE_STROKECOLOR, '#FF0000', [child]);
                        else if(child.getValue() == "成功时")
                            graph.setCellStyles(mxConstants.STYLE_STROKECOLOR, '#00FF00', [child]);
                        else if(child.getValue() == "完成时")
                            graph.setCellStyles(mxConstants.STYLE_STROKECOLOR, '#000000', [child]);
                        else
                            graph.setCellStyles(mxConstants.STYLE_STROKECOLOR, '#000000', [child]);
                    }
                }

                graph.refresh(child);

            }
        };
        //if (!startCell) {
        //    return '没有开始节点'
        //};
        //getSameCellId(startCell);
        return msg;
    };
     function getNextCellId(cell, linkType) {
        var nextid;
        var isEnd = true;
        var parent = cell.getParent()||graph.getDefaultParent();
        var childCount = graph.getModel().getChildCount(parent);
        var nextCell = null;
        for(var i = 0; i < childCount; i++) {
            var child = graph.getModel().getChildAt(parent, i);
            if(child.isVertex())continue;
            console.log(child );
            if(child.source && child.source.getId() == cell.getId()) isEnd = false; ///是去S_STEP,而且有作为源,则不是最后节点
            if(child.isEdge() && child.source && child.linktype == linkType && child.source.getId() == cell.getId()) {
                nextCell = child.target;
            }
        }
        nextid = nextCell != null ? nextCell.getId() : -1;
        if(isEnd && linkType == 0) nextid = 99;
        return nextid;
    }
    ///从数据库加载流程图
		var procSql = "select PROC_NAME,PROCCNNAME,INTERCODE,INORFULL,CYCLETYPE,TOPICNAME,REMARK,PROCTYPE,RUNPARA,DEVELOPER,EFF_DATE,CREATER, STATE, STATE_DATE, CURDUTYER,VERSEQ,XML,DBUSER,EXTEND_CFG from PROC" + _METAPRJ + " where PROC_NAME='" + procName + "'";
		if(METAPRJ=="HIS"){
			procSql ="select PROC_NAME,PROCCNNAME,INTERCODE,INORFULL,CYCLETYPE,TOPICNAME,REMARK,PROCTYPE,RUNPARA,DEVELOPER,EFF_DATE,CREATER, STATE, STATE_DATE, CURDUTYER,VERSEQ,XML,DBUSER,EXTEND_CFG,UPDATE_SERIALID from PROC" + _METAPRJ + " where PROC_NAME='" + procName + "' AND UPDATE_SERIALID='"+UPDATESERIALID+"'";
		}
    var loadfromDatabaseProc = function() {
        ds_proc = new AI.JsonStore({
            root: 'root',
            sql: procSql,
            loadDataWhenInit: true,
            table: "PROC" + _METAPRJ,
            key: METAPRJ=="HIS"?"PROC_NAME,UPDATE_SERIALID":"PROC_NAME"
        });
       
        if (ds_proc.getCount() == 0) {
            var rec = ds_proc.getNewRecord();
            //记录初始化
            rec.set('PROC_NAME', procName);
            rec.set('CYCLETYPE', CYCLE || '日');
            rec.set('LEVEL_VAL', LEVEL || 'DWD');
            rec.set('TOPICNAME', TOPICNAME || '');
            rec.set('EFF_DATE', new Date());
            rec.set('CREATER', _UserInfo.username);
            rec.set('STATE', '新建');
            rec.set('STATE_DATE', new Date());
            rec.set('PROCTYPE', 'METAPROC');
            rec.set('RUNMODE', '调度');
            rec.set('DEVELOPER', _UserInfo.username);
            rec.set('CURDUTYER', _UserInfo.username);
            rec.set('VERSEQ', '1');
            ds_proc.add(rec);

        }
        var procrec = ds_proc.getAt(0);

        if (!procrec.get('VERSEQ')) procrec.set('VERSEQ', 1);

        graph.getModel().beginUpdate();
        try {
            var xml = procrec.get("XML");
             
            if (xml != null && xml != "null" && xml.length > 10) {
                var doc = mxUtils.parseXml(xml);
                var dec = new mxCodec(doc);
                dec.decode(doc.documentElement, graph.getModel());
            }
            else{
            		var parent = graph.getDefaultParent();
            		
            		var extend_cfg={};
            		var extend_cfgstr = procrec.get('EXTEND_CFG');
                if (extend_cfgstr) {
                    var extend_cfg = JSON.parse(extend_cfgstr);
                }
                //var dbname=procrec.get('DBNAME');
                
            		var sourcetabArray = (extend_cfg.SOURCE_TAB||"").split(",");
            		var targettabArray = (extend_cfg.TARGET_TAB||"").split(",");    
            		var dbname = extend_cfg.DBNAME||"";
            		dbname=procrec.get('DBNAME');
            		/*
            		 var sqlNode = graph.insertVertex(parent, null,"SQL语句", 375, 120 , 65, 50,
							'image;image=images/etlwidget/dop-sql.gif');
					 sqlNode.templateId="sql";
					 sqlNode.script="{dsName:'"+dbname+"'}";
				*/
					 
                //考虑一个程序只能输出一张表
                var targetNode=null;
                for(var i=0;i<targettabArray.length;i++){
                	 var targetNode = graph.insertVertex(parent, null, targettabArray[i], 570, 120+(i*80), 65, 50,
							'image;image=images/etlwidget/dataout-dbtab.png');
						 targetNode.templateId="outputTab";
						 targetNode.script="{dsName:'"+dbname+"',metaTableName:'"+targettabArray[i]+"',tableName:'"+targettabArray[i]+"',override:'true'}";
						 //var targetNodeLast = graph.insertEdge(parent, null, '', sqlNode,targetNode );
						 
                }; 
                for(var i=0;i<sourcetabArray.length;i++){
                	 var sourceNode = graph.insertVertex(parent, null, sourcetabArray[i], 220, 20+(i*80) , 65, 50,
							'image;image=images/etlwidget/datasource-dbtab.gif');
						 sourceNode.templateId="inputTab";
						 sourceNode.script="{dsName:'"+dbname+"',tableName:'"+sourcetabArray[i]+"',override:'true'}";
						 sourceNode.script="{dsName:'"+dbname+"',metaTableName:'"+sourcetabArray[i]+"',tableName:'"+sourcetabArray[i]+"',override:'true'}";
						 //var e1 = graph.insertEdge(parent, null, '', sourceNode, sqlNode);
						 
						 var e1 = graph.insertEdge(parent, null, '', sourceNode, targetNode);
                };
            	

               
						 
                
            };

        } finally {
            // Updates the display
            graph.getModel().endUpdate();

        }
    };
   
    var savetoDatabaseProc = function() {
          var msg = checkGraph();
            if(msg != null) {
                if(!confirm(msg + " , 继续保存？")) return;
            }
       
        var enc = new mxCodec(mxUtils.createXmlDocument());
        var parent = graph.getDefaultParent();
        var childCount = graph.getModel().getChildCount(parent);
        var node = enc.encode(graph.getModel());

        var rec = ds_proc.getAt(0);

        rec.set('XML', mxUtils.getXml(node));
        rec.set('STATE_DATE', new Date());
        rec.dirty = true;
        if (!ds_proc.commit(false)) {
            alert('程序信息保存失败');
            return;
        };

        //delete from table PROC_STEP
        var _sql = "delete from PROC_STEP" + _METAPRJ + " where proc_name='" + procName + "'"+(METAPRJ=="HIS"?" AND UPDATE_SERIALID='"+UPDATESERIALID+"'":"");
        ai.executeSQL(_sql, false);

        //insert into table  PROC_STEP            
       var stepStore = new AI.JsonStore({
            table: "PROC_STEP" + _METAPRJ,
            root: 'root',
            sql: 'select PROC_NAME,STEP_SEQ,S_STEP,F_STEP,N_STEP,STEP_NAME,STEP_TYPE,SQL_TEXT,DBNAME,REMARK from PROC_STEP' + _METAPRJ,
            key: METAPRJ=="HIS"?"PROC_NAME,UPDATE_SERIALID":"PROC_NAME"
        });
        for (var i = 0; i < childCount; i++) {
            var child = graph.getModel().getChildAt(parent, i);
            if (child.isVertex()) {
                var sourceTarget = getObjSourceTargetId(child);
                var sourceId = sourceTarget.source;
                var targetId = sourceTarget.target;
                rec = stepStore.getNewRecord();
                rec.set('PROC_NAME', procName);
                rec.set('STEP_SEQ', child.getId());
                rec.set('STEP_NAME', child.getValue());
                // rec.set('DBNAME', child.getobjType() || "");
                 rec.set('S_STEP', getNextCellId(child, '0'));
                 rec.set('F_STEP', getNextCellId(child, '1'));
                 rec.set('N_STEP', getNextCellId(child, '2'));
                rec.set('PREID', sourceId||"-1");
                if(METAPRJ=="HIS"){
                	rec.set('UPDATE_SERIALID', UPDATESERIALID);
                }
                //begin按照循环结构修改增加循环执行第一步
                var loopStartStep="";
                
                if(child.getChildCount()>0){
                	/*c_child = child.getChildAt(0);
                	 if (c_child.isVertex()) {
                		 loopStartStep=c_child.getId();
                	 }
                	 */
                	 loopStartStep=getLoopStartId(child);
                }
               
               
                if(loopStartStep!=""){
                	var targetAid=targetId?(","+targetId):"";
                	rec.set('AFTID', loopStartStep+targetAid);
                }else{
                	//alert("循环体内部无对象，请添加！");
                	rec.set('AFTID', targetId||"-1");
                }
                //end
                
                rec.set('PARENT_ID', "");
                rec.set('STEP_CODE',child.templateId);
                 
                rec.set('SQL_TEXT', child.script == null ? '' : child.script);
                rec.set('REMARK', child.remark == null ? '' : child.remark);
                stepStore.add(rec);
                ////保存子节点
                
                for (var j = 0; j < child.getChildCount(); j++) {
                    c_child = child.getChildAt(j);
                    if (c_child.isVertex()) {
                        var sourceTarget = getObjSourceTargetId(c_child);
                			var sourceId = sourceTarget.source;
               				var targetId = sourceTarget.target;
                        rec = stepStore.getNewRecord();
                        rec.set('PROC_NAME', procName);
                        rec.set('STEP_SEQ', c_child.getId());
                        rec.set('STEP_NAME', c_child.getValue());
                        // rec.set('DBNAME', c_child.getobjType() || "");
                         rec.set('S_STEP', getNextCellId(c_child, '0'));
                         rec.set('F_STEP', getNextCellId(c_child, '1'));
                         rec.set('N_STEP', getNextCellId(c_child, '2'));
                        rec.set('PREID', sourceId||"-1");
                        rec.set('AFTID', targetId||"-1");
                        rec.set('PARENT_ID',  child.getId()+"");
                	    // rec.set('STEP_CODE',child.templateId);
                        rec.set('STEP_CODE',c_child.templateId);
                        rec.set('SQL_TEXT', c_child.script);
                        rec.set('REMARK', c_child.remark);
                        if(METAPRJ=="HIS"){
                					rec.set('UPDATE_SERIALID', UPDATESERIALID);
                				}
                        stepStore.add(rec);
                    };
                };
            }

        }
        if (!stepStore.commit(false)) {
            alert('程序信息保存失败');
            return;
        };
		 alert("保存成功！");
    };
    
    //获取循环内部的起点
    function getLoopStartId(child){
    	var loopStartId="";
        for (var j = 0; j < child.getChildCount(); j++) {
            c_child = child.getChildAt(j);
            if (c_child.isVertex()) {
            	var sourceTarget = getObjSourceTargetId(c_child);
        		//var sourceId = c_child.source;
       			var sourceId = sourceTarget.source;
       			if(sourceId==null || sourceId==""){
       				loopStartId=c_child.getId();
       				break;
       			}
       		}
        }
        return loopStartId;
    }
    ////根据节点编号取节点
    function getNodeById(cellId) {
        var result=null;
        var parent =  graph.getDefaultParent();
        var childCount = graph.getModel().getChildCount(parent);
        
        for(var i = 0; i < childCount; i++) {
            var child = graph.getModel().getChildAt(parent, i);
            if(child.getId()===cellId){
            	   result = child;
            	   break;
            };  
        }
        return result;
    }
    function getObjSourceTargetId(cell) {
        var source = "",  target = "",sourceName="",targetName="";
        for (var j = 0; j < cell.getEdgeCount(); j++) {
            var edge = cell.getEdgeAt(j);
            var sObj = edge.source; //edge.getSource();
            var tObj = edge.target; //edge.getTarget();
            if (!tObj || !sObj) continue;
            if (sObj == cell && tObj != cell) {
                if (target){ 
                	target += ',' + tObj.id;
                	targetName+= ',' + tObj.getValue();
                }
                else { target = tObj.id;targetName=tObj.getValue()};
            } else if (tObj == cell && sObj != cell) {
                if (source){ source += ',' + sObj.id;sourceName+= ',' + sObj.getValue();}
                else{ source = sObj.id;sourceName=sObj.getValue()};
            }
        }
        return {source:source,sourceName:sourceName,target:target,targetName:targetName};
    };
/*
    function getObjSourceTarget(cell) {

        var source = "",
            target = "";

        function getSourceObj(theCell) {
            for (var j = 0; j < theCell.getEdgeCount(); j++) {
                var edge = theCell.getEdgeAt(j);
                var sObj = edge.getSource();
                var tObj = edge.getTarget();
                if (!tObj || !sObj) continue;

                if (tObj == theCell && sObj != theCell) {
                    var objtype = sObj.getobjType();
                    if (objtype == 'datasource' || objtype == 'dataout') {
                        var tmpstr = sObj.getValue();
                        if (source) source += ',' + tmpstr
                        else source = tmpstr;
                    } else {
                        getSourceObj(sObj)
                    }
                }
            }
        };
        getSourceObj(cell);

        function getTargetObj(theCell) {
            for (var j = 0; j < theCell.getEdgeCount(); j++) {
                var edge = theCell.getEdgeAt(j);
                var sObj = edge.getSource();
                var tObj = edge.getTarget();
                if (!tObj || !sObj) continue;

                if (sObj == theCell && tObj != theCell) {
                    var objtype = tObj.getobjType();
                    if (objtype == 'datasource' || objtype == 'dataout') {
                        var tmpstr = tObj.getValue();
                        if (target) target += ',' + tmpstr
                        else target = tmpstr;
                    } else {
                        getTargetObj(tObj)
                    }
                }
            }
        };
        getTargetObj(cell);

        return source + ";" + target;
    };
    */
    // Extends EditorUi to update I/O action states
    (function() {
        var editorUiInit = EditorUi.prototype.init;
        
        if (paramMap.hidemenu != 'n') {
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
            savetoDatabaseProc(xmltext);
        };
    })();
    var myfun = function() {
        //alert('kk');
    };
    var parserProcMeta=function(){
        var _sql = "delete from transdatamap" + _METAPRJ + " where transname='" + procName + "'";
        ai.executeSQL(_sql);
        var _sql = "delete from transmap" + _METAPRJ + " where transname='" + procName + "'";
        ai.executeSQL(_sql);
    	meta.parserProcMeta(procName);
    };
    //导入导出
    var importOrExportProc = function(){
    		var btn_1= new Ext.Button({
					text: '导入',
					handler:function(button,event){
						var xml=fd_3.getValue();
						if (xml != null && xml.length > 0){
							var doc = mxUtils.parseXml(xml); 
							var dec = new mxCodec(doc); 
							dec.decode(doc.documentElement, graph.getModel()); 
						}
						w.close();									     				
					}
				});
				var btn_2= new Ext.Button({
					text: '关闭',
					handler:function(button,event){
						w.close();									     				
					}
				});
				var enc = new mxCodec(mxUtils.createXmlDocument());
				var node = enc.encode(graph.getModel());
				var fd_3 = new Ext.form.TextArea({
					width:590,
					height:336,
					fieldLabel:'Content',
					name:'oText',
					id:'oText',
					labelStyle: "text-align: right",
					preventScrollbars:true,
					value:mxUtils.getPrettyXml(node),
					allowBlank:false
				});																		                  
        var w=new Ext.Window({
        			width:600,
					height:400,
					title:'Pase xml text into/output the textarea please' ,
					items:[fd_3],
					buttons:[btn_1,btn_2],
					buttonAlign:'center',
					modal:true
				}); 
				w.show();				     
    };


        //导入导出
    var viewProc = function(){
        var url="../../devmgr/GetDoc.html?procName="+procName;                                                                           
        var w=new Ext.Window({
                    title : '查看:'+procName,
                    // maximizable : true,
                    //maximized : true,
                    width : "100%",
                    height : 600,
                    // autoScroll : true,
                    // bodyBorder : true,
                    // draggable : true,
                    isTopContainer : true,
                    modal : true,
                    resizable : false,
                    contentEl : Ext.DomHelper.append(document.body, {
                    tag : 'iframe',
                    style : "border 0px none;scrollbar:true",
                    src : url,
                    height : "100%",
                    width : "100%"
                })
                }); 
                w.show();                    
    };
    $(document).ready(function() {
		Ext.BLANK_IMAGE_URL = '../../sysmgr/asiainfo/ext/resources/images/default/s.gif';
		Ext.QuickTips.init();		
        editor = new Editor();
        var normalSql="SELECT a.FUNC_CODE,a.MEMO WIDGETNAME, a.FUNC_ID, a.CFGJSON, a.FUN_ORDSEQ ,a.FUNC_ICON,'1.常用' APPLY FROM proc_func_def_java a WHERE func_code IN ('outputTab','inputTab','crtTab','sql','print','if','var','dropTable','localCmd')"
        editor.loadwidgetSql =normalSql+ " union select a.FUNC_CODE,a.MEMO WIDGETNAME, a.FUNC_ID, a.CFGJSON, a.FUN_ORDSEQ ,a.FUNC_ICON,a.APPLY from PROC_FUNC_DEF_JAVA a ,meta_role_func b where  a.skip_flag=0 and a.func_type<>'appwidget'and a.func_code = b.func_code and b.groupcode = '"+_UserInfo.groupCode+"'  and b.state ='1'  order by APPLY, FUN_ORDSEQ";
        if(_UserInfo.username ==='sys'){
            editor.loadwidgetSql =normalSql+ " union select FUNC_CODE,MEMO WIDGETNAME, FUNC_ID, CFGJSON, FUN_ORDSEQ ,FUNC_ICON,APPLY from PROC_FUNC_DEF_JAVA  where skip_flag=0 and func_type<>'appwidget' order by APPLY, FUN_ORDSEQ";
        }
        graph = editor.graph;
        graph.setTooltips(false);

        ui = new EditorUi(editor);

        ui.toolbar.addSeparator();
        ui.toolbar.addItem('glyphicon glyphicon-floppy-disk', 'save', '保存');
        ui.toolbar.addSeparator();
        //ui.toolbar.addButton('glyphicon glyphicon-play','my test button',myfun);
        //ui.toolbar.addButton('glyphicon glyphicon-forward', 'my test button', myfun, '测试');
        // ui.toolbar.addSeparator();
        ui.toolbar.addButton('glyphicon glyphicon-hand-up', '元数据解析', parserProcMeta, '元数据解析');
        ui.toolbar.addSeparator();
        ui.toolbar.addButton('glyphicon glyphicon-file','导入导出',importOrExportProc,'导入导出');
        ui.toolbar.addSeparator();
        ui.toolbar.addButton('glyphicon glyphicon-record','导出文档',viewProc,'导出文档');
        ui.toolbar.addSeparator();

        //ui.toolbar.addHtml('<button type="button" class="btn btn-sm  btn-success" style="margin-left:10px" data-action="create-table"><i class="glyphicon glyphicon-log-out"></i>创建表</button>','hello');
        //parserProcMeta
        var currentCell = null;
        loadfromDatabaseProc();
        editor.modified = false;
        graph.click = function(evt, cell) {
            return false;

        };

        var afterFunctionOkClick = function(formVals) {
       		 if (!currentCell && graph.getSelectionCells().length==1){
		   			 currentCell=graph.getSelectionCells()[0];
		  		};
		  		if (!currentCell && graph.getSelectionCells().length==0){this.win.hide(); return;}
        		 
        		currentCell.script = ai.encode(formVals);
        		var stepname = formVals['name'];
        		
        		if(currentCell.templateId=="inputTab" || currentCell.templateId=="outputTab") stepname = formVals["tableName"];
        		if(currentCell.templateId=="if"){
        			var ifcfg={statements:[]};
        			for(var key in formVals){
        				 if(key.indexOf('goto')>=0) {;
        						 var rule = {expression:formVals[key],stepId:key.replace("goto_","")};
        						 ifcfg.statements.push(rule);
        				};
        			};
        			currentCell.script = ai.encode(ifcfg);
        		}
	 			
	 			if(stepname) currentCell.setValue(stepname);
	 				
				graph.refresh(currentCell); 
                // alert(ai.encode(formVals));
            return true;
        };
        
        
       var afterLinkOkClick=function(formVals){
        
       	 if (!currentCell && graph.getSelectionCells().length==1){
		   			 currentCell=graph.getSelectionCells()[0];
		  		};
		    if (!currentCell && graph.getSelectionCells().length==0){this.win.hide(); return;}
		    var linktype=formVals["linktype"]||"0";
		    currentCell.linktype=linktype;
		   
       	 if(linktype == "0") {
            graph.setCellStyles(mxConstants.STYLE_STROKECOLOR, '#00FF00', [currentCell]);
            currentCell.setValue('成功时');
            graph.getCellStyle(currentCell).strokeColor == '#FF0000';
        }
        else if(linktype == "1") {
            graph.setCellStyles(mxConstants.STYLE_STROKECOLOR, '#FF0000', [currentCell]);
            currentCell.setValue('失败时');
        }
        else if(linktype == "2") {
            graph.setCellStyles(mxConstants.STYLE_STROKECOLOR, '#000000', [currentCell]);
            currentCell.setValue('完成时');
        }  ;
        
        graph.refresh(currentCell);
       
       };
       
        //TODO处理帮助信息的展开
        var afterShowHelpInfo = function(panel, helpInfo) {
      		 if (!currentCell && graph.getSelectionCells().length==1){
	   			 currentCell=graph.getSelectionCells()[0];
	  		};
	  		
	  		var sql = "SELECT  CFGJSON from proc_func_def_java where func_code ='"+currentCell.templateId+"'";

            var ds_col =new AI.JsonStore({
                root: 'root',
                sql: sql,
                pageSize:-1,
                loadDataWhenInit: true
            });

            if(ds_col.getCount()==0){
                tab.empty().append('<div style="color:red">暂无帮助信息</div>');
                return;
            }
            
            helpInfo.empty().append('<div><p>'+ds_col.getAt(0).get("CFGJSON")+'</p></div>');
            
            if(currentCell.templateId=="var"){
            	sql = "SELECT var_name,memo FROM `proc_global_val` ORDER BY var_name";
                var varList =new AI.JsonStore({
                    root: 'root',
                    sql: sql,
                    pageSize:-1,
                    loadDataWhenInit: true
                });
                var globalVarInfo = [];
                for (var i = 0; i < varList.getCount(); i++) {
                    var vars = {};
                    vars.varname = varList.getAt(i).get("VAR_NAME");
                    vars.varDesc = varList.getAt(i).get("MEMO");

                    globalVarInfo.push(vars);
                }
                
                var template = _.template('<div class="panel-group" id="accordion" role="tablist" aria-multiselectable="true">'+
                        '<div class="form-group has-success has-feedback"><strong>全局时间参数:</strong><p class="info">程序传入日期参数${taskid},下表日期参数都是根据${taskid}计算生成.如：20141111,201411</p><div>'+
                		'      <table class="table table-striped table-bordered table-condensed">'+
                        '        <%_.each(vars,function(gvar){%>'+
                        '                       <tr><td><%=gvar.varname%></td><td><%=gvar.varDesc%></td></tr>'+
                        '               <%})%>'+
                        '      </table>'+
                        '</div>');
                
                helpInfo.append(template({vars:globalVarInfo}));
            }
            
            if(currentCell.templateId=="sql"){
            	sql = "SELECT var_name,memo FROM `proc_global_val` ORDER BY var_name";
                var varList =new AI.JsonStore({
                    root: 'root',
                    sql: sql,
                    pageSize:-1,
                    loadDataWhenInit: true
                });
                var globalVarInfo = [];
                for (var i = 0; i < varList.getCount(); i++) {
                    var vars = {};
                    vars.varname = varList.getAt(i).get("VAR_NAME");
                    vars.varDesc = varList.getAt(i).get("MEMO");

                    globalVarInfo.push(vars);
                }
                
                var template = _.template(
                        '<div class="form-group has-success has-feedback"><strong>全局时间参数:</strong><p class="info">程序传入日期参数${taskid},下表日期参数都是根据${taskid}计算生成.如：20141111,201411</p><div>'+
                		'      <table class="table table-striped table-bordered table-condensed">'+
                        '        <%_.each(vars,function(gvar){%>'+
                        '                       <tr><td><%=gvar.varname%></td><td><%=gvar.varDesc%></td></tr>'+
                        '               <%})%>'+
                        '      </table>'
                        );
                helpInfo.empty().append('<div><p>'+ds_col.getAt(0).get("CFGJSON")+'</p></div>');
                helpInfo.append(template({vars:globalVarInfo}));
                
            }
            
            
        }

        graph.dblClick = function(evt, cell) {
            if (!cell) return;
            currentCell=cell;
            if(cell.isVertex()) {
            		if (!funcEditer) funcEditer = new AI.FuncEditer({
		                callback: afterFunctionOkClick,
		                showHelpInfo: afterShowHelpInfo
		            });
            	var sourceTarget=getObjSourceTargetId(cell);
           	 	currentCell = cell;
           	 	var curValObj = ai.decode(currentCell.script) || {};
           		funcEditer.sourceTarget=sourceTarget;
           		 
            	funcEditer.show(cell.templateId, currentCell.value, curValObj, teamCode,cell);
           }
           else{
           	   if(!cell.linktype) {
                    if(graph.getCellStyle(cell).strokeColor == '#00FF00') {
                        cell.linktype=0;
                        cell.value = '成功时';
                    } else if(graph.getCellStyle(cell).strokeColor == '#FF0000') {
                        cell.linktype=1;
                        cell.value = '失败时';
                    } else if(graph.getCellStyle(cell).strokeColor == '#000000') {
                        cell.linktype=2;
                        cell.value = '完成时';
                    }
                };
         
               var formItems=[  {
             	type: 'radio',
             	label: '条件',
            		notNull:   'Y',
             	storesql: "0,成功时|1,失败时|2,完成时",
             	value: cell.linktype+"",
             	fieldName: "linktype",
             	width: 300,
             	tip: "设置连线成功时或失败时"
         		}]
               ai.openFormDialog("连线设置",formItems,afterLinkOkClick,undefined,300,200);
          };
        };

        //覆盖右键事件为空
        graph.panningHandler.factoryMethod = function(menu, cell, evt){};
        
        //添加的自动保存功能
        /*var REFRESHTIMER;
        var autoSave = function(flag){
            if(flag){
                REFRESHTIMER = setTimeout(function(){
                    savetoDatabaseProc();
                    autoSave(true);
                },300000);
            }else{
                clearTimeout(REFRESHTIMER);
            }
        };*/
        
        if(actType=="readOnly"){
        	$(".geToolbar").addClass("hide")
        	$("button").addClass("hide")
        }
        /*
        else{
            autoSave(true);
        }*/

    });
</script>
</head>

<body class="geEditor">

</body>

</html>
