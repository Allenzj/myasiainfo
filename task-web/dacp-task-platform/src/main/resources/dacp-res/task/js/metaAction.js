/**
 * @fileoverview 元数据操作控制器
 * @author Soon.Cai
 **/
var metaActionController = {
    do:function(actionName){
        switch(actionName){
            case 'createTAB':
                return this.createTAB();
        }
    },
    /*跳转到创建表页面*/
    createTAB: function() {
        window.open(contextPath + "/devmgr/WizCreTable.html?TEAM_CODE=" + paramMap.TEAM_CODE + "&USERROLE=" + paramMap.USERROLE + "&OBJNAME=" + paramMap.OBJNAME);
    },
    /*基本信息*/
    editTABMeatInfo: {
        objStore: {},
        objrecord: {},
        attrArray: {},
        metadb: {},
        formItems: [],
        DB2Items: [],
        HiveItems: [],
        OracleItems:[],
        applyTableSql: function(OBJNAME, TEAMCODE,TABNAME) {
            var applyTableSql = "SELECT a.* FROM "+TABNAME+" a {condi} a.XMLID='" + OBJNAME + "'";
            if (TEAMCODE && TEAMCODE.length > 0) {
                applyTableSql = applyTableSql.replace("{condi}", (" ,META_TEAM_USER_OBJECT b WHERE a.XMLID=b.XMLID AND b.TEAM_CODE='" + TEAMCODE + "' AND "));
            } else {
                applyTableSql = applyTableSql.replace('{condi}', ' where ');
            }
            return applyTableSql;
        },
        getMetaInfo: function(objtype) { ////取元模型信息和表对象信息
            ///相关表:METAOBJINFO:基本信息配置表,属性配置表:METAOBJCFG,
            var sendObj = {
                paras: [{
                    paraname: "objinfo",
                    paratype: "map",
                    sql: "select OBJTYPE, OBJCODE, OBJNAME, ORDSEQ, REMARK, TABNAME,  RULETAB, KEYFIELD, NAMEFIELD, LOGTAB, TIMEFIELD, RUNTABNAME,  DETAILURL, RUNURL from DQOBJMODEL where objtype='" + objtype + "'"
                }, {
                    paraname: "objattr",
                    paratype: "array",
                    sql: "select OBJTYPE, ATTRGROUP, ATTRNAME, ATTRCNNAME, INPUTTYPE,INPUTPARA, ISNULL, SELVAL, SELMODEL, SEQ, REMARK, DEPENDENCIES, CHECKITEMS, MINLENGTH,MAXLENGTH from METAOBJCFG where objtype='" + objtype + "' order by ATTRGROUP,SEQ "
                }, {
                    paraname: "metadb",
                    paratype: "array",
                    sql: "SELECT DBNAME,CNNAME,DRIVERCLASSNAME  FROM metadbcfg"
                }]
            };
            var URL = '/' + contextUrl + '/olapquery?json=' + ai.encode(sendObj);
            var obj = ai.remoteData(URL);
            return obj;
        },
        ////对象基本信息
        baseInfoForm: {},
        ds_memberTableStore: {},
        refreshForm: function(formElements,USERFIELDSETS) {
            var formcfg = ({
                fieldsets:USERFIELDSETS&&USERFIELDSETS==true?formElements:null,
                items:USERFIELDSETS&&USERFIELDSETS==true?null:formElements,
                id: 'baseInfoForm',
                store: metaActionController.editTABMeatInfo.objStore,
                containerId: 'baseInfoForm',
                fieldChange: function(fieldName, newVal) {
                    if (fieldName === 'DATANAME') {} else {
                        metaActionController.editTABMeatInfo.objrecord.set(fieldName.toUpperCase(), newVal);
                        if (fieldName === 'DBNAME') {
                            for (var i = 0; i < metaActionController.editTABMeatInfo.metadb.length; i++) {
                                if (metaActionController.editTABMeatInfo.metadb[i]['dbname'] === newVal) {
                                    _dbtype = metaActionController.editTABMeatInfo.metadb[i]['driverclassname'];
                                }
                            }
                            metaActionController.editTABMeatInfo.refreshWizardStep(_dbtype);
                            metaActionController.editTABMeatInfo.objrecord.set(fieldName, newVal);
                            if (_dbtype.indexOf('db2') != -1) {
                                metaActionController.editTABMeatInfo.refreshForm(metaActionController.editTABMeatInfo.DB2Items,metaActionController.editTABMeatInfo.USERFIELDSETS);
                            } else if (_dbtype.indexOf('hive') != -1) {
                                metaActionController.editTABMeatInfo.refreshForm(metaActionController.editTABMeatInfo.HiveItems,metaActionController.editTABMeatInfo.USERFIELDSETS);
                            } else if (_dbtype.indexOf('oracle') != -1){
                            	 metaActionController.editTABMeatInfo.refreshForm(metaActionController.editTABMeatInfo.OracleItems,metaActionController.editTABMeatInfo.USERFIELDSETS);
                            }else {
                                metaActionController.editTABMeatInfo.refreshForm(metaActionController.editTABMeatInfo.formItems,metaActionController.editTABMeatInfo.USERFIELDSETS);
                            }
                        }
                    }
                    //浙江分表策略
                    if(fieldName === 'LEVEL_VAL'){
                    	var oldDataName =metaActionController.editTABMeatInfo.objrecord.get('DATANAME') || '';
                      if(/(_YYYY|_YYYYMM|_XXX|_XXX_YYYY|_XXX_YYYYMM|_X)$/.test(oldDataName)&&/分表$/.test(newVal)){
                      	oldDataName = 	oldDataName.replace(/(_YYYY|_YYYYMM|_XXX|_XXX_YYYY|_XXX_YYYYMM|_X)$/,'');
                      }
                      var newDataName = oldDataName;
                      if(newVal == "按年分表"){
                      	newDataName = oldDataName+"_YYYY";
                      }else if (newVal == "按年月分表"){
                      	newDataName = oldDataName+"_YYYYMM";
                      }else if (newVal == "按地市分表"){
                      	newDataName = oldDataName+"_XXX";
                      }else if (newVal == "按地市年分表"){
                      	newDataName = oldDataName+"_XXX_YYYY";
                      }else if (newVal == "按地市年月分表"){
                      	newDataName = oldDataName+"_XXX_YYYYMM";
                      }else if (newVal == "按尾号分表"){
                      	newDataName = oldDataName+"_X";
                      }
                      metaActionController.editTABMeatInfo.objrecord.set('DATANAME', newDataName);
                      $('#baseInfoForm #DATANAME').val(newDataName);
                    }
                }
            });
            $('#baseInfoForm').empty();
            var from = new AI.Form(formcfg);
            return from;
        },
        refreshWizardStep:function(_dbtype){
        	if(_dbtype.indexOf('oracle') != -1){
        		var  numSteps =$('#myWizard').find('.steps li').length;
        		if(numSteps ==3){
        				$('#myWizard').wizard('addSteps', 3,[{
        						badge: '',
										label: '索引信息',
										pane: '<nav class="navbar navbar-default" role="navigation" style="margin-bottom: 1px">'
													+'<div class="container-fluid">'
														+'<div class="collapse navbar-collapse">'
															+'<form class="navbar-form navbar-left" role="search">'
																+'<label> 索引操作 </label>'
																+'<button id="save-indexs" type="button" class="btn btn-sm btn-default " style="margin-left: 10px">'
        													+'<i class="glyphicon glyphicon-eye-open"></i>保存'
        												+'</button>'
        												+'<button id="show-create-indexs" type="button" class="btn btn-sm btn-default " style="margin-left: 10px">'
																	+'<i class="glyphicon glyphicon-eye-open"></i>查看建索引语句'
																+'</button>'
															+'</form>'
														+'</div>'
													+'</div>'
												+'</nav>'		
												+'<div style="height: 500px;overflow: auto">'
					      					+'<div id="tabIndexgrid" style="height: 100%"></div>'
					   	 					+'</div>'		
        				},{
        						badge: '',
										label: '分区信息',
										pane: '<nav class="navbar navbar-default" role="navigation" style="margin-bottom: 1px">'
													+'<div class="container-fluid">'
														+'<div class="collapse navbar-collapse">'
															+'<form class="navbar-form navbar-left" role="search">'
																+'<label> 分区操作 </label>'
																+'<button id="save-partitions" type="button" class="btn btn-sm btn-default " style="margin-left: 10px">'
        													+'<i class="glyphicon glyphicon-eye-open"></i>保存'
        												+'</button>'
        												+'<button id="show-create-partitions" type="button" class="btn btn-sm btn-default " style="margin-left: 10px">'
																	+'<i class="glyphicon glyphicon-eye-open"></i>查看建表语句'
																+'</button>'
															+'</form>'
														+'</div>'
													+'</div>'
												+'</nav>'		
												+'<div style="height: 500px;overflow: auto">'
					      					+'<div id="tabPartitiongrid" style="height: 100%"></div>'
					   	 					+'</div>'
        				},{
        					badge: '',
									label: '脚本执行',
									pane: '<nav class="navbar navbar-default" role="navigation" style="margin-bottom: 1px">'
													+'<div class="container-fluid">'
														+'<div class="collapse navbar-collapse">'
															+'<form class="navbar-form navbar-left" role="search">'
																+'<label >执行数据库:</label>'
																+'<select id="excute-db" class="form-control input-sm"></select>'
																+'<label style="margin-left: 10px">执行SCHEMA:</label>'
																+'<input id="excute-schema" type="text" class="form-control" placeholder="输入SCHEMA">'
																+'<label style="margin-left: 10px">执行表空间:</label>'
																+'<input id="excute-tabspace" type="text" class="form-control" placeholder="输入表空间">'
																+'<label style="margin-left: 10px">执行索引空间:</label>'
																+'<input id="excute-indexspace" type="text" class="form-control" placeholder="输入索引空间">'
																+'<button id="create-script" type="button" class="btn btn-sm btn-default " style="margin-left: 10px">'
																	+'<i class="glyphicon glyphicon-eye-open"></i>生成执行脚本'
																+'</button>'
															+'</form>'
														+'</div>'
													+'</div>'
												+'</nav>'	
												+'<div class="form-horizontal" id="executeform">'
													+'<div class="form-group form-group-sm">'
		                	 			+'<label for="excutesql" class="col-sm-2 control-label">执行脚本</label>'
		                	 			+'<div class="col-sm-10">' 
			                	 				+'<textarea class="form-control" style="width:620px;height:350px" cols="60" rows="5" id="excute-sql" name="excute-sql"></textarea>'
			                	 				+'<p>以上是根据配置信息生成的可执行脚本</p>'
		                	 			+'</div>'
		                			+'</div>'
        									+'<button id="execute-check" type="button" class="btn btn-sm btn-success" style="margin-left: 220px"> <i class="glyphicon glyphicon-eye-open"></i>执行结果检验</button>'
        									+'<button id="execute-unit" disabled="disabled" type="button" class="btn btn-sm btn-success" style="margin-left: 220px"> <i class="glyphicon glyphicon-eye-open"></i>单元测试</button>'
        								+'</div>'	
        								+'<div class="ui-layout-center">'
													+'<div id="scriptPanel"></div>'
												+'</div>'  					
        				}]);
        				
        				/*初始化表索引，表分区信息,脚本页面*/
		        		metaActionController.editTABIndex.loadTabIndexInfo();
		        		metaActionController.editTABPartition.loadTabPartitionInfo();
		        		metaActionController.editTABScript.loadTABScriptInfo();
		        		/*初始化表索引，表分区事件*/
		        		metaActionController.addIndexEvent();
		        		metaActionController.addPartitionEvent();
		        		metaActionController.addScriptexecuteEvent();
		        		
        				$('#myWizard').off('actionclicked.fu.wizard').on('actionclicked.fu.wizard', function(event, stepInfo) {
			            if (stepInfo.step == 1 && stepInfo.direction == 'next' && paramMap.ACTTYPE != "readOnly") {
			                if (metaActionController.editTABField.checkInputForm() == false) return false;
			                metaActionController.editTABMeatInfo.objStore.commit();
			            } else if (stepInfo.step == 5 && stepInfo.direction == 'next') {
			                $("#dqmgrfram").attr("src", "../dqmgr/MetaDqResult.html?OBJTYPE=TAB&OBJNAME=" +
			                    metaActionController.editTABMeatInfo.objStore.curRecord.get('DATANAME'))
		            	};
        				});
        				$('#myWizard').on('changed.fu.wizard', function(event, stepInfo) {
				            if (stepInfo.step == 2 && !metaActionController.editTABField.hadLoad) {
				               metaActionController.editTABFieldFun().loadTabFieldInfo();
				               metaActionController.editTABField.hadLoad = true;
				            }
				        });
						        	
        		}
        	}else{
        		var  numSteps =$('#myWizard').find('.steps li').length;
        		if(numSteps > 3){
        			$('#myWizard').wizard('removeSteps', 3, 3);
        			
        			$('#myWizard').off('actionclicked.fu.wizard').on('actionclicked.fu.wizard', function(event, stepInfo) {
			            if (stepInfo.step == 1 && stepInfo.direction == 'next' && paramMap.ACTTYPE != "readOnly") {
			                if (metaActionController.editTABField.checkInputForm() == false) return false;
			                metaActionController.editTABMeatInfo.objStore.commit();
			            } else if (stepInfo.step == 2 && stepInfo.direction == 'next') {
			                $("#dqmgrfram").attr("src", "../dqmgr/MetaDqResult.html?OBJTYPE=TAB&OBJNAME=" +
			                    metaActionController.editTABMeatInfo.objStore.curRecord.get('DATANAME'))
		            	};
        			});
        			
        			$('#myWizard').on('changed.fu.wizard', function(event, stepInfo) {
				            if (stepInfo.step == 2 && !metaActionController.editTABField.hadLoad) {
				               metaActionController.editTABFieldFun().loadTabFieldInfo();
				               metaActionController.editTABField.hadLoad = true;
				            }
				        });
        		}
        	}	
        },
        init: function() {
            var USERFIELDSETS = true; //是否启用fieldsets分组
            metaActionController.editTABMeatInfo.USERFIELDSETS = USERFIELDSETS;
            var OBJTYPE = paramMap.OBJTYPE || 'TAB';
            var OPTTYPE = paramMap.OPTTYPE || '';
            var OBJNAME = paramMap.OBJNAME || '';
            if (OBJNAME && OBJTYPE == 'INTER' && OBJNAME.indexOf(".") > 0) {
                OBJTYPE = 'TAB';
            };
            var OBJCNNAME = paramMap.OBJCNNAME || '';
            var METAPRJ = paramMap.METAPRJ || "";
            var _METAPRJ = METAPRJ ? "_" + METAPRJ : "";
            var xmlid = '';
            var TEAMCODE = paramMap.TEAM_CODE || "";
            var actType = paramMap.ACTTYPE || "edit";
            var curRole = paramMap.USERROLE || '';
            var _dbtype = '';
            var groupType = paramMap.GROUPTYPE || '';
            var metaBaseInfo = this.getMetaInfo(OBJTYPE);
            var metaInfo = metaBaseInfo.root[0].objinfo;
            this.ds_memberTableStore = new AI.JsonStore({
                sql: this.applyTableSql(OBJNAME, TEAMCODE,metaInfo.tabname),
                table: 'META_TEAM_USER_OBJECT',
                key: 'DBNAME,OBJNAME,USERNAME,APPLY_USER',
                pageSize: 20
            });
            this.attrArray = metaBaseInfo.root[1].objattr;
            metaActionController.editTABMeatInfo.metadb = metaBaseInfo.root[2].metadb;
            metaActionController.editTABMeatInfo.objStore = new AI.JsonStore({
                sql: "select * from " + metaInfo.tabname + " where " + metaInfo.keyfield + "='" + OBJNAME + "'",
                table: tabname,
                secondTable: "METAOBJ",
                loadDataWhenInit: true,
                key: metaInfo.keyfield
            });
            metaActionController.editTABMeatInfo.objStore.on("beforecommit", function() {
                for (var i = 0; i < metaActionController.editTABMeatInfo.objStore.getCount(); i++) {
                    var r = metaActionController.editTABMeatInfo.objStore.getAt(i);
                    r.set('OBJNAME', r.get('DATANAME'));
                    r.set('OBJCNNAME', r.get(metaInfo.namefield));
                    var EXTEND_CFG = {
                        FILEFORMAT: r.get("EXTEND_CFG--FILEFORMAT"),
                        DELIMITER: r.get("EXTEND_CFG--DELIMITER")
                    };
                    r.set('EXTEND_CFG', JSON.stringify(EXTEND_CFG));
                };
                return true;
            });
            if (metaActionController.editTABMeatInfo.objStore.getCount() == 0) {
                actType = "add";
                metaActionController.editTABMeatInfo.objrecord = metaActionController.editTABMeatInfo.objStore.getNewRecord();
                for (var key in paramMap) {
                    metaActionController.editTABMeatInfo.objrecord.set(key.toUpperCase(), paramMap[key]);
                };
                for (var key in Global) {
                    if (typeof Global[key] != 'object' && key != 'objtype')
                        metaActionController.editTABMeatInfo.objrecord.set(key.toUpperCase(), Global[key]);
                };
                metaActionController.editTABMeatInfo.objrecord.set('XMLID', ai.guid());
                xmlid = metaActionController.editTABMeatInfo.objrecord.get('XMLID');
                OBJNAME = metaActionController.editTABMeatInfo.objrecord.get('XMLID');
                metaActionController.editTABMeatInfo.objrecord.set('TEAM_CODE', TEAMCODE);
                metaActionController.editTABMeatInfo.objrecord.set('CREATER', _UserInfo['username']);
                metaActionController.editTABMeatInfo.objrecord.set('EFF_DATE', new Date());
                metaActionController.editTABMeatInfo.objrecord.set('STATE', '新建');
                metaActionController.editTABMeatInfo.objrecord.set('STATE_DATE', new Date());
                metaActionController.editTABMeatInfo.objrecord.set('CURDUTYER', _UserInfo['username']);
                metaActionController.editTABMeatInfo.objrecord.set('VERSEQ', 1);
                metaActionController.editTABMeatInfo.objrecord.set('OBJTYPE', OBJTYPE);
                metaActionController.editTABMeatInfo.objrecord.set(metaInfo.nameField, OBJCNNAME);
                metaActionController.editTABMeatInfo.objStore.add(metaActionController.editTABMeatInfo.objrecord);
            } else {
                metaActionController.editTABMeatInfo.objrecord = metaActionController.editTABMeatInfo.objStore.getAt(0);
                xmlid = metaActionController.editTABMeatInfo.objrecord.get('XMLID');
                actType = ai.checkCurdutyer(metaActionController.editTABMeatInfo.objrecord.get('CURDUTYER')) ? actType : 'readOnly';
                if (_UserInfo.username == 'sys') actType = 'edit';
                var extend_cfg = metaActionController.editTABMeatInfo.objrecord.get('EXTEND_CFG');
                if (extend_cfg) {
                    try {
                        var cfg = JSON.parse(extend_cfg);
                        $.each(cfg, function(key, value) {
                            metaActionController.editTABMeatInfo.objrecord.set('EXTEND_CFG--' + key, value);
                        })
                    } catch (e) {}
                    // var cfg = JSON.parse(extend_cfg);
                    // $.each(cfg, function(key, value) {
                    //     metaActionController.editTABMeatInfo.objrecord.set('EXTEND_CFG--' + key, value);
                    // })
                }
            }
            for (var i = 0; i < this.ds_memberTableStore.getCount(); i++) {
                var _r = this.ds_memberTableStore.getAt(i);
                if (_r.get('XMLID') === metaActionController.editTABMeatInfo.objrecord.get('XMLID') && _r.get('AUDIT_STATUS') === 'applying') {
                    actType = "readOnly";
                    this.ds_memberTableStore.curRecord = _r;
                    $('#save-table-info').attr('disabled', 'disabled');
                }
            }

            for (var i = 0; i < metaActionController.editTABMeatInfo.metadb.length; i++) {
                if (metaActionController.editTABMeatInfo.metadb[i]['dbname'] === metaActionController.editTABMeatInfo.objrecord.get('DBNAME')) {
                    _dbtype = metaActionController.editTABMeatInfo.metadb[i]['driverclassname'];
                }
            }

            for (var i = 0; i < this.attrArray.length; i++) {
                var attrItem = this.attrArray[i];
                defaultwidth = 220;
                if (attrItem.inputtype == 'textarea') defaultwidth = 420;
                if (attrItem.inputtype == 'pick-grid') defaultwidth = 320;
                if (attrItem.inputtype == 'check') attrItem.inputtype = 'checkbox';
                if (attrItem.inputtype == 'combo') attrItem.inputtype = 'combox';
                if (attrItem.inputtype == 'label') continue; //attrItem.inputtype='html';
                if (!attrItem.inputtype) attrItem.inputtype = 'text';
                if (actType == "readOnly") attrItem.readOnly = 'y';
                if (_UserInfo.username == 'sys') attrItem.readOnly = 'n';
                if (attrItem.inputpara && attrItem.inputpara.length > 0) {
                    attrItem.inputpara = attrItem.inputpara.replace(/{team_code}/g, TEAMCODE);
                }
                if (groupType == 'normal' || !TEAMCODE || TEAMCODE.length < 1) {
                    if (attrItem.attrname == 'DBNAME') {
                        attrItem.inputpara = "select dbname,cnname from metadbcfg";
                    } else if (attrItem.attrname == 'EXTEND_CFG.SOURCE_TAB') {
                        attrItem.inputpara = "select dataname values1,datacnname values2 FROM tablefile";
                    }
                }
                if (attrItem.attrname == 'DATANAME' && actType == 'edit') {
                    attrItem.readOnly = 'y';
                }
                var formItem = {
                    fieldset:attrItem.attrgroup,
                    type: attrItem.inputtype || 'text',
                    label: attrItem.attrcnname,
                    notNull: attrItem.isnull || 'Y',
                    storesql: attrItem.inputpara,
                    isReadOnly: attrItem.readOnly || '',
                    fieldName: attrItem.attrname,
                    width: defaultwidth,
                    tip: attrItem.remark,
                    editable:'N',
                    dependencies: attrItem.dependencies,
                    checkItems: attrItem.checkitems
                };

                if(attrItem.attrname == 'LEVEL_VAL'){
                //查询是否开启自定义层次和主题的开关
                var define_switch=new AI.JsonStore({
                    sql:"SELECT OBJTYPE,ATTRNAME,ATTRCNNAME FROM metaobjcfg WHERE OBJTYPE='DEFINE_SWITCH'",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAOBJCFG",          //新增修改删除表的名称，注意要大写
                    key:"OBJTYPE"
                });

                var ifSwitch=false;
                if(define_switch.getCount()>0){
                   var ret=define_switch.getAt(0);
                   if(ret.get("ATTRNAME")=='0'){
                      ifSwitch=true;
                   }
                }

            //查询自定义表中是否有该租户的数据
            var table_switch;
            if(actType=='add'&&ifSwitch){
                table_switch=new AI.JsonStore({
                    sql:"SELECT DIMCODE,ROWCODE FROM metaedimdef_define WHERE dimcode='DIM_DATALEVEL' AND team_code ='"+TEAMCODE+"' AND rowcode IS NOT NULL",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAEDIMDEF_DEFINE",          //新增修改删除表的名称，注意要大写
                    key:"DIMCODE"
                });
            }

            //查询该数据是否是开关开启后添加的数据
            var data_switch;
            if(actType=='edit'&&ifSwitch){
                var rowcodeRet = metaActionController.editTABMeatInfo.objrecord.get('LEVEL_VAL');
                data_switch=new AI.JsonStore({
                    sql:"SELECT DIMCODE,ROWCODE FROM metaedimdef_define WHERE dimcode='DIM_DATALEVEL' AND team_code ='"+TEAMCODE+"' AND rowcode='"+rowcodeRet+"'",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAEDIMDEF_DEFINE",          //新增修改删除表的名称，注意要大写
                    key:"DIMCODE"
                });
            }

            var retSql2="";
             if(ifSwitch){
                 //自定义开关开启
                 if(actType=='edit'){
                    //编辑操作
                   if(data_switch.getCount()>0){
                      //该数据是开关开启后添加的数据
                      retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='"+TEAMCODE+"'";
                   }else{
                      //该数据是开关关闭时添加的数据
                      retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')";
                   }
                 }else if(actType=='add'){
                    //添加操作
                     if(table_switch.getCount()>0){
                       //如果该租户有自定义层次
                       retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='"+TEAMCODE+"'";
                     }else{
                       //如果该租户没有自定义层次
                       retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='S0001'" ;
                     }
                 }else if(actType=='readOnly'){
                    retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')";
                 }
             }else{
                //自定义开关关闭
                retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF WHERE dimcode='DIM_DATALEVEL'";
             }

                   formItem = {
                    fieldset:attrItem.attrgroup,
                    type: attrItem.inputtype || 'text',
                    label: attrItem.attrcnname,
                    notNull: attrItem.isnull || 'Y',
                    //storesql: actType=='edit'?"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF WHERE dimcode='DIM_DATALEVEL' UNION SELECT ROWCODE,ROWNAME FROM metaedimdef_define WHERE DIMCODE='DIM_DATALEVEL' AND TEAM_CODE='"+TEAMCODE+"'"
                    //:ifSwitch?attrItem.inputpara:"select  ROWCODE,ROWNAME from METAEDIMDEF where dimcode='DIM_DATALEVEL'",          
                    storesql:retSql2,
                    /*ifSwitch?actType=='edit'?
                    data_switch.getCount()>0?"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='"+TEAMCODE+"'":"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')"
                    :table_switch.getCount()>0?"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='"+TEAMCODE+"'":"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='S0001'" 
                    :"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF WHERE dimcode='DIM_DATALEVEL'",*/
                    
                    isReadOnly: attrItem.readOnly || '',
                    fieldName: attrItem.attrname,
                    width: defaultwidth,
                    tip: attrItem.remark,
                    editable:'N',
                    dependencies: attrItem.dependencies,
                    checkItems: attrItem.checkitems
                };
                }

                if (attrItem.attrname == 'TOPICNAME') {
                    //查询是否开启自定义层次和主题的开关
                var define_switch=new AI.JsonStore({
                    sql:"SELECT OBJTYPE,ATTRNAME,ATTRCNNAME FROM metaobjcfg WHERE OBJTYPE='DEFINE_SWITCH'",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAOBJCFG",          //新增修改删除表的名称，注意要大写
                    key:"OBJTYPE"
                });

                var ifSwitch=false;
                if(define_switch.getCount()>0){
                   var ret=define_switch.getAt(0);
                   if(ret.get("ATTRNAME")=='0'){
                      ifSwitch=true;
                   }
                }

            //查询自定义表中是否有数据
            var table_switch;
            if(actType=='add'&&ifSwitch){
                table_switch=new AI.JsonStore({
                    sql:"SELECT DIMCODE,rowcode FROM metaedimdef_define WHERE dimcode='DIM_TOPIC' AND team_code ='"+TEAMCODE+"' AND rowcode IS NOT NULL",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAEDIMDEF_DEFINE",          //新增修改删除表的名称，注意要大写
                    key:"DIMCODE"
                });
            }

                //查询该数据是否是开关开启后添加的数据
                var data_switch;
                if(actType=='edit'&&ifSwitch){
                    var rowcodeRet2 = metaActionController.editTABMeatInfo.objrecord.get('TOPICNAME');
                    var rets;
                    if(rowcodeRet2!=null){
                       rets=rowcodeRet2.split('|');
                    }else{
                        rets=['undefined'];
                    }
                    data_switch=new AI.JsonStore({
                       sql:"SELECT DIMCODE,ROWCODE FROM metaedimdef_define WHERE dimcode='DIM_TOPIC' AND team_code ='"+TEAMCODE+"' AND rowcode='"+rets[0]+"'",      //store查询的sql语句
                       dataSource:"METADB",       //数据源，对应一个数据库
                       table:"METAEDIMDEF_DEFINE",          //新增修改删除表的名称，注意要大写
                       key:"DIMCODE"
                     });
                }

                 var retSql=[];
                if(ifSwitch){
                //自定义主题开关开启
                   if(actType=='edit'){
                    //编辑操作
                     if(data_switch.getCount()>0){
                        //该数据是开关开启后添加的数据
                        retSql=[
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='"+TEAMCODE+"'",
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'",
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'"
                        ];
                     }else{
                        //该数据是开关关闭时添加的数据
                        retSql=[
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')"
                        ];
                     }
                   }else if(actType=='add'){
                    //添加操作
                    if(table_switch.getCount()>0){
                      //该租户有自定义的主题
                      retSql=[
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='"+TEAMCODE+"'",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'"
                      ];
                    }else{
                      //该租户没有自定义的主题
                      retSql=[
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='S0001'",
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='S0001'",
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='S0001'"
                      ];
                    }
                   }else if(actType=='readOnly'){
                     retSql=[
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')"
                        ];
                   }
                }else{
                //自定义主题开关关闭
                    retSql=["select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC'", "select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}'", "select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}'"
                        ];
                }
               

                    formItem = {
                        fieldset:attrItem.attrgroup,
                        type: 'mulitLevel',
                        label: attrItem.attrcnname,
                        editable:'N',
                        notNull: 'Y',
                        fieldName: attrItem.attrname,
                        levelSqls:retSql,
                        /*ifSwitch?actType=='edit'?
                        [data_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         data_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         data_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')"]
                        :[table_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='S0001'",
                         table_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='S0001'",
                         table_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='S0001'"                          
                        ]:["select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC'", "select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}'", "select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}'"
                        ],*/
                        isReadOnly: attrItem.readOnly || ''
                    };
                }
                metaActionController.editTABMeatInfo.formItems.push(formItem);
            };
            
            var fieldSetsFormat = function(items){
                var fieldSetNames="",fieldSets = [],sets={};
                for (var i = 0;i<items.length; i++) {
                    var item = items[i];
                    if(fieldSetNames.indexOf(item['fieldset'])==-1){
                        sets[item['fieldset']] =[];
                        fieldSetNames += item['fieldset'];
                    }
                    sets[item['fieldset']].push(item);
                };
                for (var set in sets) {
                    fieldSets.push({
                        legend:set,
                        items:sets[set]
                    });
                };
                return fieldSets;
            };

            var addDB2Items = [{
                fieldset:'DB2配置',
                type: 'text',
                label: '表空间',
                notNull: 'Y',
                fieldName: 'TABSPACE',
                isReadOnly: actType == "readOnly" ? 'y' : 'n'
            }];
            var addHiveItems = [{
                fieldset:'Hive配置',
                type: 'combox',
                label: '存储格式',
                notNull: 'Y',
                editable:'N',
                storesql: "SELECT  ROWCODE,ROWNAME  FROM METAEDIMDEF WHERE dimcode='DIM_FILEFORMAT'",
                fieldName: 'EXTEND_CFG.FILEFORMAT',
                isReadOnly: actType == "readOnly" ? 'y' : 'n'
            }, {
                fieldset:'Hive配置',
                type: 'combox',
                label: '分隔符',
                notNull: 'Y',
                editable:'N',
                storesql: "SELECT  ROWCODE,ROWNAME  FROM METAEDIMDEF WHERE dimcode='DIM_DELIMITER'",
                fieldName: 'EXTEND_CFG.DELIMITER',
                isReadOnly: actType == "readOnly" ? 'y' : 'n'
            }];
            var addOracleItems =[{
                fieldset:'Oracle配置',
            	type: 'text',
                label: 'SCHEMA',
                notNull: 'Y',
                fieldName: 'SCHEMA_NAME',
                isReadOnly: actType == "readOnly" ? 'y' : 'n'
            
            },{
                fieldset:'Oracle配置',
          		type: 'text',
                label: '表空间',
                notNull: 'Y',
                fieldName: 'TABSPACE',
                isReadOnly: actType == "readOnly" ? 'y' : 'n'
          	},{
                fieldset:'Oracle配置',
          		type: 'combox',
                label: '是否压缩',
                notNull: 'Y',
                storesql: "yes,no",
                fieldName: 'COMPRESSION',
                isReadOnly: actType == "readOnly" ? 'y' : 'n'
          	}]
            this.DB2Items = USERFIELDSETS&&USERFIELDSETS==true?fieldSetsFormat(_.union(this.formItems, addDB2Items)):_.union(this.formItems, addDB2Items);
            this.HiveItems = USERFIELDSETS&&USERFIELDSETS==true?fieldSetsFormat(_.union(this.formItems, addHiveItems)):_.union(this.formItems, addHiveItems);
            this.OracleItems = USERFIELDSETS&&USERFIELDSETS==true?fieldSetsFormat(_.union(this.formItems, addOracleItems)):_.union(this.formItems, addOracleItems);
            this.formItems = USERFIELDSETS&&USERFIELDSETS==true?fieldSetsFormat(this.formItems):this.formItems;

            this.refreshWizardStep(_dbtype);
            if (_dbtype.indexOf('db2') != -1) {
                this.baseInfoForm = this.refreshForm(this.DB2Items,USERFIELDSETS);
            } else if (_dbtype.indexOf('hive') != -1) {
                this.baseInfoForm = this.refreshForm(this.HiveItems,USERFIELDSETS);
            } else if (_dbtype.indexOf('oracle') != -1) {
            	this.baseInfoForm = this.refreshForm(this.OracleItems,USERFIELDSETS);
            }else {
                this.baseInfoForm = this.refreshForm(this.formItems,USERFIELDSETS);
            }
        }
    },
    editTABMeatInfoFun: function() {
        return this.editTABMeatInfo;
    },
    /*数据结构*/
    editTABField: {
        handsontable: null,
        fieldStdCfg: {},
        loadTabFieldInfo: function() {
            var OBJTYPE = paramMap.OBJTYPE || 'TAB';
            var OPTTYPE = paramMap.OPTTYPE || '';
            var OBJNAME = paramMap.OBJNAME || '';
            if (OBJNAME && OBJTYPE == 'INTER' && OBJNAME.indexOf(".") > 0) {
                OBJTYPE = 'TAB';
            };
            var OBJCNNAME = paramMap.OBJCNNAME || '';
            var METAPRJ = paramMap.METAPRJ || "";
            var _METAPRJ = METAPRJ ? "_" + METAPRJ : "";
            var xmlid = '';
            var TEAMCODE = paramMap.TEAM_CODE || "";
            var actType = paramMap.ACTTYPE || "edit";
            var edition = actType;
            var curRole = paramMap.USERROLE || '';
            var _dbtype = '';
            var groupType = paramMap.GROUPTYPE || '';
            var self = this;
            ai.loadWidget("sheetgrid");
            var tabcolsql = "select col_seq,colname,colcnname,datatype,length,PRECISION_VAL,remark,isnullable,key_seq,PARTY_SEQ from COLUMN_VAL where xmlid='" + OBJNAME + "' order by col_seq";
            tabColStore = new AI.JsonStore({
                sql: tabcolsql,
                pageSize: -1,
                key: 'DATANAME',
                dataSource: 'METADB'
            });
            if (tabColStore.getCount() === 0) {
                var tab = tabColStore.getNewRecord();
                tab.set('COLNAME', 'new');
                tab.set('COLCNNAME', 'new');
                tab.set('DATATYPE', 'new');
                tab.set('LENGTH', '0');
                tab.set('ISNULLABLE', 'n');
                tabColStore.add(tab);
            }
            var yellowRenderer = function(instance, td, row, col, prop, value, cellProperties) {
                Handsontable.renderers.TextRenderer.apply(this, arguments);
            };
            var $container = $("#tabfieldgrid");
            $container.handsontable({
                data: tabColStore.root,
                colHeaders: ['字段名', '类型', '长度', '精度', '中文名', '分区键', '主键标识', '备注', '标准化命名'],
                columns: [
                    {
                        data: 'COLNAME',
                        renderer: yellowRenderer,
                        readOnly: edition === 'readOnly' ? true : false
                    }, {
                        data: 'DATATYPE',
                        type: 'autocomplete',
                        source: ["int", "long", "decimal", "varchar", "date", "datetime", "blob"],
                        readOnly: edition === 'readOnly' ? true : false
                    }, {
                        data: 'LENGTH',
                        readOnly: edition === 'readOnly' ? true : false
                    }, {
                        data: 'PRECISION_VAL',
                        readOnly: edition === 'readOnly' ? true : false
                    }, {
                        data: 'COLCNNAME',
                        readOnly: edition === 'readOnly' ? true : false
                    }, {
                        data: 'PARTY_SEQ',
                        type: 'autocomplete',
                        source: ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
                        readOnly: edition === 'readOnly' ? true : false
                    },
                    {
                        data: 'KEY_SEQ',
                        type: 'autocomplete',
                        source: ['0', '1'],
                        readOnly: edition === 'readOnly' ? true : false
                    }, {
                        data: 'REMARK',
                        readOnly: edition === 'readOnly' ? true : false
                    }, {
                        data: 'ELEMENT_CODE',
                        readOnly: edition === 'readOnly' ? true : false
                    }
                ],
                cells: function(row, col, prop) {
                    var cellProperties = {};
                    if (col != 6) return;
                    if (col == 6 && self.fieldStdCfg["row_" + row] && self.fieldStdCfg["row_" + row].length > 0) {
                        cellProperties.type = "handsontable";
                        cellProperties.handsontable = {
                            colHeaders: ["编号", "名称", "中文名", "类型"],
                            data: self.fieldStdCfg["row_" + row]
                        };
                    }
                    return cellProperties;
                },
                rowHeaders: true,
                manualRowResize: true,
                minSpareRows: 1,
                colWidths: [160, 150, 60, 60, 200, 60, 60, 200, 200],
                rowHeaders: true,
                columnSorting: true,
                manualColumnMove: true,
                manualColumnResize: true,
                minSpareRows: 1,
                stretchH: 'all',
                contextMenu: true
            });
            $('#tabfieldgrid table').addClass('table table-striped');
            this.handsontable = $container.data('handsontable');
            return this.handsontable;
        },
        checkInputForm: function() {
            var result = true;
            var extend_cfg = {};
            var extend_cfgstr = metaActionController.editTABMeatInfo.objrecord.get('EXTEND_CFG');
            if (extend_cfgstr) {
                extend_cfg = JSON.parse(extend_cfgstr);
            }
            var r = metaActionController.editTABMeatInfo.objStore.curRecord;
            for (var i = 0; i < metaActionController.editTABMeatInfo.attrArray.length; i++) {
                var attr = metaActionController.editTABMeatInfo.attrArray[i];
                if (attr.isnull == 'N') {
                    if (attr.attrname.indexOf("EXTEND_CFG.") >= 0) {
                        var attrKey = attr.attrname.split(".")[1];
                        if (!extend_cfg[attrKey]) {
                            alert(attr.attrcnname + ",扩展信息,不允许为空");
                            result = false;
                            break;
                        } else if (attr.length && extend_cfg[attrKey].length > attr.length) {
                            alert(attr.attrcnname + "长度超出！");
                            result = false;
                            break;
                        }
                    } else if (!r.get(attr.attrname)) {
                        alert(attr.attrcnname + "不允许为空");
                        result = false;
                        break;
                    } else if (attr.length && r.get(attr.attrname).length > attr.length) {
                        alert(attr.attrcnname + "长度超出！");
                        result = false;
                        break;
                    }
                }

                if(attr.minlength && attr.minlength != null && r.get(attr.attrname).length < attr.minlength)  //如果属性的最小长度配置了
                {
                    alert(attr.attrcnname + "输入内容长度不足！");
                    result = false;
                    break;
                }

                if(attr.maxlength && attr.maxlength != null && r.get(attr.attrname).length > attr.maxlength)  //如果属性的最小长度配置了
                {
                    alert(attr.attrcnname + "输入内容长度超出！");
                    result = false;
                    break;
                }
            }

            return result;
        }

    },
    editTABFieldFun: function() {
        return this.editTABField;
    },
    /*索引信息*/
    editTABIndex: {
    	handsontable: null,
    	loadTabIndexInfo: function() {
          var OBJTYPE = paramMap.OBJTYPE || 'TAB';
          var OPTTYPE = paramMap.OPTTYPE || '';
          var OBJNAME = paramMap.OBJNAME || '';
          if (OBJNAME && OBJTYPE == 'INTER' && OBJNAME.indexOf(".") > 0) {
              OBJTYPE = 'TAB';
          };
          var OBJCNNAME = paramMap.OBJCNNAME || '';
          var METAPRJ = paramMap.METAPRJ || "";
          var _METAPRJ = METAPRJ ? "_" + METAPRJ : "";
          var xmlid = '';
          var TEAMCODE = paramMap.TEAM_CODE || "";
          var actType = paramMap.ACTTYPE || "edit";
          var edition = actType;
          var curRole = paramMap.USERROLE || '';
          var _dbtype = '';
          var groupType = paramMap.GROUPTYPE || '';
          var self = this;
          ai.loadWidget("sheetgrid");
          var tabindexsql = "SELECT indexname,indexspace,indextype,indexcolumn FROM INDEXCFG_BOSS where xmlid='" + OBJNAME + "'";
          tabIndexStore = new AI.JsonStore({
              sql: tabindexsql,
              pageSize: -1,
              key: 'XMLID',
              dataSource: 'METADB'
          });
          if (tabIndexStore.getCount() === 0) {
              var tab = tabIndexStore.getNewRecord();
              tab.set('INDEXNAME', 'new');
              tab.set('INDEXSPACE', 'new');
              tab.set('INDEXTYPE', '一般索引');
              tabIndexStore.add(tab);
          }
          var yellowRenderer = function(instance, td, row, col, prop, value, cellProperties) {
              Handsontable.renderers.TextRenderer.apply(this, arguments);
          };
          var $container = $("#tabIndexgrid");
          $container.handsontable({
              data: tabIndexStore.root,
              colHeaders: ['索引名称', '索引空间', '索引类型', '索引字段'],
              columns: [
                  {
                      data: 'INDEXNAME',
                      renderer: yellowRenderer,
                      readOnly: edition === 'readOnly' ? true : false
                  },{
                      data: 'INDEXSPACE',
                      readOnly: edition === 'readOnly' ? true : false
                  },{
                      data: 'INDEXTYPE',
                      type: 'autocomplete',
                      source: ["一般索引","唯一索引","复合索引"],
                      readOnly: edition === 'readOnly' ? true : false
                  }, {
                      data: 'INDEXCOLUMN',
                      readOnly: edition === 'readOnly' ? true : false
                  }
              ],
              afterOnCellMouseDown:function(event,coords,td){
              	var row = coords.row;
              	var col = coords.col;
              	if(row>=0&&col==3){
              		var afterIndexSelect = function(rs){
              			if(rs.length == 0) return;
              			var indexFeild='';
              			for(var i = 0; i < rs.length;i++){
              				if(indexFeild){
              					indexFeild +=","+rs[i].get("VALUES1");
              					}else{
              					indexFeild +=rs[i].get("VALUES1");	
              					}
              			}
              			metaActionController.editTABIndex.handsontable.setDataAtCell(row, col, indexFeild);
              		}
              		var selBox = new SelectBox({
                		sql: "SELECT DISTINCT COLNAME as VALUES1,COLCNNAME as VALUES2 FROM COLUMN_VAL WHERE XMLID='"+metaActionController.editTABMeatInfo.objrecord.get('XMLID')+"'",
                		callback: afterIndexSelect
            			});
            			selBox.show();
              	}
              },
              rowHeaders: true,
              manualRowResize: true,
              minSpareRows: 1,
              colWidths: [160, 150, 60, 200],
              rowHeaders: true,
              columnSorting: true,
              manualColumnMove: true,
              manualColumnResize: true,
              minSpareRows: 1,
              stretchH: 'all',
              contextMenu: true
          });
          $('#tabIndexgrid table').addClass('table table-striped');
          this.handsontable = $container.data('handsontable');
          return this.handsontable;
      },
      checkInputForm: function() {
      }
    },
    editTABPartition: {
    	handsontable: null,
    	loadTabPartitionInfo: function() {
          var OBJTYPE = paramMap.OBJTYPE || 'TAB';
          var OPTTYPE = paramMap.OPTTYPE || '';
          var OBJNAME = paramMap.OBJNAME || '';
          if (OBJNAME && OBJTYPE == 'INTER' && OBJNAME.indexOf(".") > 0) {
              OBJTYPE = 'TAB';
          };
          var OBJCNNAME = paramMap.OBJCNNAME || '';
          var METAPRJ = paramMap.METAPRJ || "";
          var _METAPRJ = METAPRJ ? "_" + METAPRJ : "";
          var xmlid = '';
          var TEAMCODE = paramMap.TEAM_CODE || "";
          var actType = paramMap.ACTTYPE || "edit";
          var edition = actType;
          var curRole = paramMap.USERROLE || '';
          var _dbtype = '';
          var groupType = paramMap.GROUPTYPE || '';
          var self = this;
          ai.loadWidget("sheetgrid");
          var tabpartirionsql = "SELECT PARTITIONNAME,VALUES1,CLAUSE,KEYCOMPRESSION,PARTITIONTYPE,PARTITIONCOL FROM PARTITIONCFG_BOSS where xmlid='" + OBJNAME + "'";
          tabPartitionStore = new AI.JsonStore({
              sql: tabpartirionsql,
              pageSize: -1,
              key: 'XMLID',
              dataSource: 'METADB'
          });
          if (tabPartitionStore.getCount() === 0) {
              var tab = tabPartitionStore.getNewRecord();
              tab.set('PARTITIONNAME', 'new');
              tab.set('PARTIRIONTYPE', 'range');
              tabPartitionStore.add(tab);
          }
          var yellowRenderer = function(instance, td, row, col, prop, value, cellProperties) {
              Handsontable.renderers.TextRenderer.apply(this, arguments);
          };
          var $container = $("#tabPartitiongrid");
          $container.handsontable({
              data: tabPartitionStore.root,
              colHeaders: ['分区键名称', '值', 'clause', 'keycompression', '分区类型', '分区键字段'],
              columns: [
                  {
                      data: 'PARTITIONNAME',
                      renderer: yellowRenderer,
                      readOnly: edition === 'readOnly' ? true : false
                  },  {
                      data: 'VALUES1',
                      readOnly: edition === 'readOnly' ? true : false
                  },  {
                      data: 'CLAUSE',
                      readOnly: edition === 'readOnly' ? true : false
                  },	{
                      data: 'KEYCOMPRESSION',
                      readOnly: edition === 'readOnly' ? true : false
                  },	{
                      data: 'PARTITIONTYPE',
                      type: 'autocomplete',
                      source: ["range","hash","list"],
                      readOnly: edition === 'readOnly' ? true : false
                  }, {
                      data: 'PARTITIONCOL',
                      readOnly: edition === 'readOnly' ? true : false
                  }
              ],
              afterOnCellMouseDown:function(event,coords,td){
              	var row = coords.row;
              	var col = coords.col;
              	if(row>=0&&col==5){
              		var afterPartitionSelect = function(rs){
              			if(rs.length == 0) return;
              			var partitionFeild='';
              			for(var i = 0; i < rs.length;i++){
              				if(partitionFeild){
              					partitionFeild +=","+rs[i].get("VALUES1");
              					}else{
              					partitionFeild +=rs[i].get("VALUES1");	
              					}
              			}
              			metaActionController.editTABPartition.handsontable.setDataAtCell(row, col, partitionFeild);
              		}
              		var selBox = new SelectBox({
                		sql: "SELECT DISTINCT COLNAME as VALUES1,COLCNNAME as VALUES2 FROM COLUMN_VAL WHERE XMLID='"+metaActionController.editTABMeatInfo.objrecord.get('XMLID')+"'",
                		callback: afterPartitionSelect
            			});
            			selBox.show();
              	}
              },
              rowHeaders: true,
              manualRowResize: true,
              minSpareRows: 1,
              colWidths: [160, 150, 60, 200, 60, 200],
              rowHeaders: true,
              columnSorting: true,
              manualColumnMove: true,
              manualColumnResize: true,
              minSpareRows: 1,
              stretchH: 'all',
              contextMenu: true
          });
          $('#tabPatitiongrid table').addClass('table table-striped');
          this.handsontable = $container.data('handsontable');
          return this.handsontable;
      },
      checkInputForm: function() {
      }
    },
    /*执行脚本信息*/
    editTABScript:{
    	executeScriptStore :{},
    	loadTABScriptInfo : function(){
    		var executeScriptSql = "select * from table_physical_script_boss where data_type='开发' and xmlid='"+metaActionController.editTABMeatInfo.objrecord.get('XMLID')+"' and paratype='script'";
      	metaActionController.editTABScript.executeScriptStore = new AI.JsonStore({
					sql:executeScriptSql,
					pageSize:-1,
					key:"XMLID,ATTRCODE,PARATYPE",
					table:"table_physical_script_boss"
				});
      	var config={
					store:metaActionController.editTABScript.executeScriptStore,
					pageSize:-1,
					containerId:'scriptPanel',
					nowrap:true,
					showcheck:false,
					columns:[
						{header: "实体表", width:74, vertical_align:'middle',dataIndex: 'PARANAME'},
						{header: "脚本", width:200, dataIndex: 'PARACODE', vertical_align:'middle',sortable: true},
						{header: "数据库", width: 75, dataIndex: 'DBNAME', vertical_align:'middle',sortable: true },
						{header: "SCHAME", width:74, vertical_align:'middle',dataIndex: 'SCHEMA_NAME'},
						{header: "表空间", width:74, vertical_align:'middle',dataIndex: 'TABSPACE'},
						{header: "索引空间", width:74, vertical_align:'middle',dataIndex: 'INDEXSPACE'},
						{header: "状态", width:70, vertical_align:'middle',dataIndex: 'STATE'},
						{header: "执行时常", width:100, dataIndex: 'EXECUTE_TIMES', vertical_align:'middle'},
						{header: "报错原因", width:100, dataIndex: 'REMARK', vertical_align:'middle'}
					]
				};
				var grid =new AI.Grid(config);
    	}
    	
    },
    /*创建表格流程事件添加*/
    addTabEvent: function() {
        var self = this;
        var actType = paramMap.ACTTYPE || "edit";
        $('#myWizard').wizard('selectedItem', {
	            step: 1
	      });
        var  numSteps =$('#myWizard').find('.steps li').length;
        if(numSteps == 3){
	        $('#myWizard').on('actionclicked.fu.wizard', function(event, stepInfo) {
                var r = metaActionController.editTABMeatInfo.objStore.curRecord;
	            if (stepInfo.step == 1 && stepInfo.direction == 'next' && paramMap.ACTTYPE != "readOnly") {
	                if (metaActionController.editTABField.checkInputForm() == false) return false;
                    if(ai.getStoreData("select XMLID from tablefile where XMLID = '"+r.get('XMLID')+"' and DATANAME = '"+r.get('DATANAME')+"'")[0]){
                    }else if (meta.checkObjExists('TAB', r.get('DATANAME'), '') == true) {
                        alert("表:" + r.get('DATANAME') + ",已经存在!!!");
                        return false;
                    };
	                metaActionController.editTABMeatInfo.objStore.commit();
	            } else if (stepInfo.step == 2 && stepInfo.direction == 'next') {
	                $("#dqmgrfram").attr("src", "../dqmgr/MetaDqResult.html?OBJTYPE=TAB&OBJNAME=" +
	                    metaActionController.editTABMeatInfo.objStore.curRecord.get('DATANAME'))
	            };
	        });
      	}
      	
      	$('#myWizard').on('changed.fu.wizard', function(event, stepInfo) {
            if (stepInfo.step == 2 && !metaActionController.editTABField.hadLoad) {
               metaActionController.editTABFieldFun().loadTabFieldInfo();
               metaActionController.editTABField.hadLoad = true;
            }
        });
        //相似性检查
        $("#dataSimilarity").click(function() {
            window.open("/" + contextPath + "/sysmgr/asiainfo/ProcGraph/dataSimilarity.html");
        });
        $('#db-import').on('click', function() {
            var afterSelect = function(records) {
                for (var i = 0; i < records.length; i++) {
                    var r = records[i];
                    var countRows = metaActionController.editTABField.handsontable.countRows();
                    metaActionController.editTABField.handsontable.setDataAtCell(countRows - 1, 0, r.get('VALUES1').toUpperCase());
                    metaActionController.editTABField.handsontable.setDataAtCell(countRows - 1, 1, r.get('VALUES4'));
                    metaActionController.editTABField.handsontable.setDataAtCell(countRows - 1, 2, r.get('VALUES3'));
                    metaActionController.editTABField.handsontable.setDataAtCell(countRows - 1, 5, r.data["REMARK"]);
                };
                metaActionController.editTABField.handsontable.render();
            };
            var selBox = new SelectBox({
                sql: "SELECT DISTINCT COLNAME as VALUES1,DATANAME as VALUES2,COLCNNAME as VALUES3,XMLID,DATATYPE as VALUES4,LENGTH,REMARK FROM COLUMN_VAL",
                callback: afterSelect
            });
            selBox.show();
        });
        $('#dataElement-import').on('click', function() {
            var afterElementSelect = function(records) {
                metaActionController.editTABField.handsontable.alter('insert_row', records.length);
                var countRows = metaActionController.editTABField.handsontable.countRows();
                for (var i = 0; i < records.length; i++) {
                    var r = records[i];
                    metaActionController.editTABField.handsontable.setDataAtCell(countRows - i, 0, r.get('VALUES3').toLowerCase());
                    metaActionController.editTABField.handsontable.setDataAtCell(countRows - i, 1, r.get('HADOOP_TYPE'));
                    metaActionController.editTABField.handsontable.setDataAtCell(countRows - i, 2, r.get('VALUES2'));
                    metaActionController.editTABField.handsontable.setDataAtCell(countRows - i, 5, r.data["REMARK"]);
                    metaActionController.editTABField.handsontable.setDataAtCell(countRows - i, 6, r.get('VALUES1'));
                };
                metaActionController.editTABField.handsontable.render();
            };
            var selBox = new SelectBox({
                sql: "SELECT ELEMENT_CODE as VALUES1,ELEMENT_NAME as VALUES2,FILED_NAME VALUES3,DB2_TYPE,HADOOP_TYPE,FIELD_LENGTH,NULL_ABLE,REMARK FROM table_element ",
                callback: afterElementSelect
            });
            selBox.show();
        });
        $('#metaCheck').on('click', function() { ///规范化简称
            self.fieldStdCfg = {};
            for (var j = 0; j < metaActionController.editTABField.handsontable.getData().length; j++) {
                var row = metaActionController.editTABField.handsontable.getData()[j];
                //console.log(row); 
                var where = " where 1=1 ";
                if (row.COLCNNAME) where += " and element_name like '%" + row.COLCNNAME + "%'";
                if (row.COLNAME) where += " and FIELD_NAME like '%" + row.COLNAME.toUpperCase() + "%'";
                if (where.length > 12) {
                    var sql = "select ELEMENT_CODE,ELEMENT_NAME,FILED_NAME,HADOOP_TYPE,REMARK from table_element " + where + " order by user_num desc";
                    var elementData = ai.getStoreData(sql);
                    if (elementData && elementData.length > 0) {
                        self.fieldStdCfg["row_" + j] = elementData;
                        if (!row.COLNAME) metaActionController.editTABField.handsontable.setDataAtCell(j, 0, elementData[0].FILED_NAME);
                        metaActionController.editTABField.handsontable.setDataAtCell(j, 1, elementData[0].HADOOP_TYPE);
                        if (!row.COLCNNAME) metaActionController.editTABField.handsontable.setDataAtCell(j, 2, elementData[0].ELEMENT_NAME);
                        metaActionController.editTABField.handsontable.setDataAtCell(j, 5, elementData[0].REMARK);
                        metaActionController.editTABField.handsontable.setDataAtCell(j, 6, elementData[0].ELEMENT_CODE);
                    };
                }
            };
            var settiongs = metaActionController.editTABField.handsontable.getSettings();
            var col = settiongs.columns[6];
            metaActionController.editTABField.handsontable.updateSettings(settiongs);
            return false;
        });
        $('#metaSampleCheck').on('click', function() {
            return false;
        });
        $('#autofieldByFieldName').on('click', function() { ///根据中文名填充
            self.fieldStdCfg = {};
            for (var j = 0; j < metaActionController.editTABField.handsontable.getData().length; j++) {
                var row = metaActionController.editTABField.handsontable.getData()[j];
                var where = " where 1=1 ";
                if (row.COLCNNAME) where += " and element_name like '%" + row.COLCNNAME + "%'";
                if (row.COLNAME) where += " and FIELD_NAME like '%" + row.COLNAME.toUpperCase() + "%'";
                if (where.length > 12) {
                    var sql = "select ELEMENT_CODE,ELEMENT_NAME,FILED_NAME,HADOOP_TYPE,REMARK from table_element " + where + " order by user_num desc";
                    var elementData = ai.getStoreData(sql);
                    if (elementData && elementData.length > 0) {
                        self.fieldStdCfg["row_" + j] = elementData;
                        if (!row.COLNAME) metaActionController.editTABField.handsontable.setDataAtCell(j, 0, elementData[0].FILED_NAME);
                        metaActionController.editTABField.handsontable.setDataAtCell(j, 1, elementData[0].HADOOP_TYPE);
                        if (!row.COLCNNAME) metaActionController.editTABField.handsontable.setDataAtCell(j, 2, elementData[0].ELEMENT_NAME);
                        metaActionController.editTABField.handsontable.setDataAtCell(j, 5, elementData[0].REMARK);
                        metaActionController.editTABField.handsontable.setDataAtCell(j, 6, elementData[0].ELEMENT_CODE);
                    };
                }
            };
            var settiongs = metaActionController.editTABField.handsontable.getSettings();
            var col = settiongs.columns[6];
            metaActionController.editTABField.handsontable.updateSettings(settiongs);
            return false;
        });

        $('#save-table-info').on('click', function() {
            if (metaActionController.editTABField.checkInputForm() == true) {
                var length = metaActionController.editTABMeatInfo.objStore.c
                var dataname = metaActionController.editTABMeatInfo.objStore.curRecord.data["DATANAME"];
                var dbname = metaActionController.editTABMeatInfo.objStore.curRecord.data["DBNAME"];
                var xmlid = metaActionController.editTABMeatInfo.objStore.curRecord.data["XMLID"];
                if(ai.getStoreData("select XMLID from tablefile where XMLID = '"+xmlid+"' and DATANAME = '"+dataname+"'")[0]){
                }else if (meta.checkObjExists('TAB', dataname, '') == true) {
                    alert("表:" + dataname + ",已经存在!!!");
                    return;
                };
                var rs = metaActionController.editTABMeatInfo.objStore.commit(true);
                var rsJson = $.parseJSON(rs);
                alert(rsJson.msg);
            }
        });

        $('#regist-table-info').on('click', function() {
            if (metaActionController.editTABField.checkInputForm() == true) {
                var users = ai.getStoreData("SELECT DATANAME FROM tableall WHERE DATANAME='" + metaActionController.editTABMeatInfo.objStore.curRecord.get("DATANAME") + "' AND XMLID='" + metaActionController.editTABMeatInfo.objStore.curRecord.get("XMLID") + "' ");
                if (users && users.length > 0) {
                    alert("该表已导入系统！");
                    return;
                }
                var rs = ai.executeSQL("insert into tableall (dbname,dataname,schema_name,datatype,tabspace,index_tabspace,eff_date,rownum,xmlid,modeltab,creator,state,state_date,datacnname) select dbname,dataname,schema_name,datatype,tabspace,index_tabspace,eff_date,rownum_val,xmlid,dataname,creater,state,state_date,datacnname from tablefile where xmlid='" + metaActionController.editTABMeatInfo.objStore.curRecord.get("XMLID") + "'");
                var str = rs.success || rs.success == "true" ? "导入成功" : "导入失败！";
                alert(str);
            }
        });
        $('#show-create-columns').on('click',function(){
        	var resultSql = metaActionController.getCreateTabSql();
        	var fd_script = new Ext.form.TextArea({
						fieldLabel: 'Content',
						name: 'oText',
						id: 'oText',
						width: 500,
						height: 400,
						anchor: '99%',
						labelStyle: "text-align: right",
						preventScrollbars: true,
						allowBlank: false
					});
					var w = new Ext.Window({
						width: 500,
						height: 400,
						title: '脚本脚本',
						items: [fd_script],
		
						modal: true
					});
					fd_script.setValue(resultSql);
					w.show();
        });

        $('#save-columns').on('click', function() {
            var tableColumns = new AI.JsonStore({
                sql: "select * from COLUMN_VAL where XMLID='" + metaActionController.editTABMeatInfo.objrecord.get('XMLID') + "'",
                pageSize: -1,
                key: 'XMLID,COLNAME',
                table: 'COLUMN_VAL'
            });
            for (var i = tableColumns.getCount() - 1; i > -1; i--) {
                tableColumns.remove(tableColumns.getAt(i));
            }
            //校验是否重复出现
            function checkcolName(doneCol, COLNAME) {
                var flag = true;
                for (var j = 0; j < doneCol.length; j++) {
                    if (COLNAME && COLNAME == doneCol[j]) {
                        flag = false;
                        alert('字段［'+COLNAME+'］重复！');
                        break;
                    }
                }
                return flag;
            };
            //校验非空字段是否为空
            function checkcolIsnull(_model) {
                if (_model['COLNAME'] && _model['COLNAME'] != '' && _model['COLCNNAME'] && _model['COLCNNAME'] != '' && _model['DATATYPE'] && _model['DATATYPE'] != '') {
                    return true;
                } else {
                    alert('请检查必填字段【字段名，字段类型，字段中文名】内容是否为空！');
                    return false;
                }
            };

            var inputRecords = function() {
                var validate = true;
                var doneCol = [];
                for (var j = 0; j < metaActionController.editTABField.handsontable.getData().length - 1; j++) {
                    var _model = metaActionController.editTABField.handsontable.getData()[j];
                    if (checkcolIsnull(_model) && checkcolName(doneCol, _model['COLNAME'])) {
                        var _record = tableColumns.getNewRecord();
                        var _keys = _.keys(_model);
                        for (var k = 0; k < _keys.length; k++) {
                            if (typeof _model[_keys[k]] == 'string') {
                                _model[_keys[k]] = _model[_keys[k]].trim();
                            }
                            if (_keys[k] == 'LENGTH' && _model[_keys[k]] == '') { //转换字段为null  便于入库int类型，否则会报错 
                                _record.set(_keys[k], null);
                            } else if (_keys[k] == 'PARTY_SEQ' && _model[_keys[k]] == '') {
                                _record.set(_keys[k], null);
                            } else if (_keys[k] == 'KEY_SEQ' && _model[_keys[k]] == '') {
                                _record.set(_keys[k], null);
                            } else if (_keys[k] == 'PRECISION_VAL' && _model[_keys[k]] == '') {
                                _record.set(_keys[k], null);
                            } else {
                                _record.set(_keys[k], _model[_keys[k]]);
                            }
                        }
                        _record.set('COL_SEQ', j + 1);
                        _record.set('XMLID', metaActionController.editTABMeatInfo.objrecord.get('XMLID'));
                        _record.set('DATANAME', metaActionController.editTABMeatInfo.objrecord.get('DATANAME'));
                        tableColumns.add(_record);
                        doneCol.push(_model['COLNAME']);
                    } else {
                        return false;
                    }
                }
                return validate;
            };
            if (inputRecords()) {
                tableColumns.cache.update == [];
                var rs = tableColumns.commit(true);
                var rsJson = $.parseJSON(rs);
                alert(rsJson.msg);
                tabColStore.select();
                if (tabColStore.root.length > 0) {
                    metaActionController.editTABField.handsontable.loadData(tabColStore.root);
                }

            }
        });
        $('#columns-export-to-excel').on('click', function() {
            var header = [{
                "label": '序号',
                "dataIndex": "COLSEQ"
            }, {
                "label": '字段名',
                "dataIndex": "COLNAME"
            }, {
                "label": '中文名',
                "dataIndex": "COLCNNAME"
            }, {
                "label": '类型',
                "dataIndex": "DATATYPE"
            }, {
                "label": '长度',
                "dataIndex": "LENGTH"
            }, {
                "label": '备注',
                "dataIndex": "REMARK"
            }, {
                "label": '允许空',
                "dataIndex": "ISNULLABLE"
            }, {
                "label": '主键标识',
                "dataIndex": "KEY_SEQ"
            }];
            var sql = "select COL_SEQ, COLNAME, COLCNNAME, DATATYPE, LENGTH, REMARK, ISNULLABLE, KEY_SEQ from COLUMN_VAL where xmlid='" + paramMap.xmlid + "'";
            var contextPath = location.pathname.split('/')[1] || '';
            contextPath = '/' + contextPath + '/ve/download';
            ve.DownloadHelper.download({
                sql: sql,
                dataSource: '',
                header: JSON.stringify(header),
                url: contextPath,
                fileName: encodeURIComponent("allbasedate(" + paramMap.OBJNAME + ")"),
                fileType: 'excel'
            });
        });
        if (actType == "readOnly"&&_UserInfo.username != 'sys') {
            $("button").not(".btn-prev").not(".btn-next").attr("disabled", "disabled");
            $("#save-table-info").hide();
            $("#regist-table-info").hide();
            $("#dataSimilarity").parent().hide();
            $(".glyphicon-edit").hide();
            $("select").attr("disabled", "disabled");
        }
    },
    /*创建索引信息添加*/
    addIndexEvent: function() {
    	$('#save-indexs').on('click', function() {
            var tableIndexs = new AI.JsonStore({
                sql: "select * from INDEXCFG_BOSS where XMLID='" + metaActionController.editTABMeatInfo.objrecord.get('XMLID') + "'",
                pageSize: -1,
                key: 'XMLID,INDEXNAME',
                table: 'INDEXCFG_BOSS'
            });
            for (var i = tableIndexs.getCount() - 1; i > -1; i--) {
                tableIndexs.remove(tableIndexs.getAt(i));
            }
            //校验是否重复出现
            function checkIndexName(doneIndex, INDEXNAME) {
                var flag = true;
                for (var j = 0; j < doneIndex.length; j++) {
                    if (INDEXNAME && INDEXNAME == doneIndex[j]) {
                        flag = false;
                        break;
                    }
                }
                return flag;
            };
            //校验非空字段是否为空
            function checkIndexIsnull(_model) {
                if (_model['INDEXNAME'] && _model['INDEXNAME'] != '' && _model['INDEXSPACE'] && _model['INDEXSPACE'] != '' && _model['INDEXTYPE'] && _model['INDEXTYPE'] != ''&& _model['INDEXCOLUMN'] && _model['INDEXCOLUMN'] != '') {
                    return true;
                } else {
                    alert('请检查必填字段【索引名称，索引空间，索引类型，索引字段】内容是否为空！');
                    return false;
                }
            };

            var inputRecords = function() {
                var validate = true;
                var doneIndex = [];
                for (var j = 0; j < metaActionController.editTABIndex.handsontable.getData().length - 1; j++) {
                    var _model = metaActionController.editTABIndex.handsontable.getData()[j];
                    if (checkIndexIsnull(_model) && checkIndexName(doneIndex, _model['INDEXNAME'])) {
                        var _record = tableIndexs.getNewRecord();
                        var _keys = _.keys(_model);
                        for (var k = 0; k < _keys.length; k++) {
                            if (typeof _model[_keys[k]] == 'string') {
                                _model[_keys[k]] = _model[_keys[k]].trim();
                            }
                            _record.set(_keys[k], _model[_keys[k]]);
                        }
                        _record.set('XMLID', metaActionController.editTABMeatInfo.objrecord.get('XMLID'));
                        _record.set('TABNAME', metaActionController.editTABMeatInfo.objrecord.get('DATANAME'));
                        tableIndexs.add(_record);
                        doneIndex.push(_model['INDEXNAME']);
                    } else {
                        return false;
                    }
                }
                return validate;
            };
            if (inputRecords()) {
                tableIndexs.cache.update == [];
                var rs = tableIndexs.commit(true);
                var rsJson = $.parseJSON(rs);
                alert(rsJson.msg);
                tabIndexStore.select();
                if (tabIndexStore.root.length > 0) {
                    metaActionController.editTABIndex.handsontable.loadData(tabIndexStore.root);
                }

            }
        });
      $('#show-create-indexs').on('click',function(){
      	var fd_script = new Ext.form.TextArea({
					fieldLabel: 'Content',
					name: 'oText',
					id: 'oText',
					width: 500,
					height: 400,
					anchor: '99%',
					labelStyle: "text-align: right",
					preventScrollbars: true,
					allowBlank: false
				});
				var w = new Ext.Window({
					width: 500,
					height: 400,
					title: '脚本脚本',
					items: [fd_script],
	        
					modal: true
				});
				var sql_sqlw = " ";
				for (var i = 0; i < metaActionController.editTABIndex.handsontable.getData().length - 1; i++) {
					var _model = metaActionController.editTABIndex.handsontable.getData()[i];
					if(_model['INDEXTYPE']=='唯一索引'){
						sql_sqlw += " create unique index "+_model['INDEXNAME']+" on "+metaActionController.editTABMeatInfo.objrecord.get('DATANAME')+"("+_model['INDEXCOLUMN']+") TABLESPACE " +_model['INDEXSPACE'] +";";
					 sql_sqlw += "\n";
					}else{
						sql_sqlw += " create index "+_model['INDEXNAME'] +" on "+metaActionController.editTABMeatInfo.objrecord.get('DATANAME')+"("+_model['INDEXCOLUMN']+")  TABLESPACE " + _model['INDEXSPACE'] +";";
					 sql_sqlw += "\n";
					}
				}	
				fd_script.setValue(sql_sqlw);
				w.show();
      });
    },
    /*创建分区信息添加*/
    addPartitionEvent: function() {
    	$('#save-partitions').on('click', function() {
            var tablePartitions = new AI.JsonStore({
                sql: "select * from PARTITIONCFG_BOSS where XMLID='" + metaActionController.editTABMeatInfo.objrecord.get('XMLID') + "'",
                pageSize: -1,
                key: 'XMLID,PARTITIONNAME',
                table: 'PARTITIONCFG_BOSS'
            });
            for (var i = tablePartitions.getCount() - 1; i > -1; i--) {
                tablePartitions.remove(tablePartitions.getAt(i));
            }
            //校验是否重复出现
            function checkPartitionName(donePartition, PARTITIONNAME) {
                var flag = true;
                for (var j = 0; j < donePartition.length; j++) {
                    if (PARTITIONNAME && PARTITIONNAME == donePartition[j]) {
                        flag = false;
                        break;
                    }
                }
                return flag;
            };
            //校验非空字段是否为空
            function checkPartitionIsnull(_model) {
                if (_model['PARTITIONNAME'] && _model['PARTITIONNAME'] != '' && _model['PARTITIONTYPE'] && _model['PARTITIONTYPE'] != '' && _model['PARTITIONCOL'] && _model['PARTITIONCOL'] != '') {
                    return true;
                } else {
                    alert('请检查必填字段【分区键名称，分区类型，分区键类型】内容是否为空！');
                    return false;
                }
            };

            var inputRecords = function() {
                var validate = true;
                var donePartition = [];
                for (var j = 0; j < metaActionController.editTABPartition.handsontable.getData().length - 1; j++) {
                    var _model = metaActionController.editTABPartition.handsontable.getData()[j];
                    if (checkPartitionIsnull(_model) && checkPartitionName(donePartition, _model['PARTITIONNAME'])) {
                        var _record = tablePartitions.getNewRecord();
                        var _keys = _.keys(_model);
                        for (var k = 0; k < _keys.length; k++) {
                            if (typeof _model[_keys[k]] == 'string') {
                                _model[_keys[k]] = _model[_keys[k]].trim();
                            }
                            _record.set(_keys[k], _model[_keys[k]]);
                        }
                        _record.set('XMLID', metaActionController.editTABMeatInfo.objrecord.get('XMLID'));
                        _record.set('TABNAME', metaActionController.editTABMeatInfo.objrecord.get('DATANAME'));
                        tablePartitions.add(_record);
                        donePartition.push(_model['PARTITIONNAME']);
                    } else {
                        return false;
                    }
                }
                return validate;
            };
            if (inputRecords()) {
                tablePartitions.cache.update == [];
                var rs = tablePartitions.commit(true);
                var rsJson = $.parseJSON(rs);
                alert(rsJson.msg);
                tabPartitionStore.select();
                if (tabPartitionStore.root.length > 0) {
                    metaActionController.editTABPartition.handsontable.loadData(tabPartitionStore.root);
                }

            }
        });
    	$('#show-create-partitions').on('click',function(){
        	var resultSql = metaActionController.getCreateTabSql();
        	var fd_script = new Ext.form.TextArea({
						fieldLabel: 'Content',
						name: 'oText',
						id: 'oText',
						width: 500,
						height: 400,
						anchor: '99%',
						labelStyle: "text-align: right",
						preventScrollbars: true,
						allowBlank: false
					});
					var w = new Ext.Window({
						width: 500,
						height: 400,
						title: '脚本脚本',
						items: [fd_script],
		
						modal: true
					});
					fd_script.setValue(resultSql);
					w.show();
      });
    },
    /*创建脚本执行添加*/
    addScriptexecuteEvent: function(){
    	var allOptions = metaActionController.editTABMeatInfo.metadb;
    	var optionsHtml='<option value=""> </option>';
    	for(var i=0;i<allOptions.length;i++){
				var option=allOptions[i];
				optionsHtml+='<option value="'+option['dbname']+'">'+option['cnname']+'</option>';
			}
    	$("#excute-db").empty().append(optionsHtml);
    	var _recordSchema = metaActionController.editTABMeatInfo.objrecord.get('SCHEMA_NAME');
    	$('#excute-schema').val(_recordSchema);
    	var _recordTabspace = metaActionController.editTABMeatInfo.objrecord.get('TABSPACE');
    	$('#excute-tabspace').val(_recordTabspace);
    	var tabIndexs = metaActionController.editTABIndex.handsontable.getData();
    	if(tabIndexs.length>1){
    		var _recordIndexspace =tabIndexs[0]['INDEXSPACE'];
    		$('#excute-indexspase').val(_recordIndexspace);
    	}
    	
    	$("#create-script").on('click',function(){
    		var excute_schema = $('#excute-schema').val();
    		var excute_tabspace = $('#excute-tabspace').val();
    		var excute_indexspace = $('#excute-indexspace').val();
    		var modelSql = metaActionController.getCreateTabSql(excute_schema,excute_tabspace,excute_indexspace);
    		var dataLevel = metaActionController.editTABMeatInfo.objrecord.get('LEVEL_VAL');
    		var dataName = metaActionController.editTABMeatInfo.objrecord.get('DATANAME');
    		var xmlid = metaActionController.editTABMeatInfo.objrecord.get('XMLID');
    		var divideDate = metaActionController.editTABMeatInfo.objrecord.get('DIVIDE_DATE');
    		var divideRegion = metaActionController.editTABMeatInfo.objrecord.get('DIVIDE_REGION');
    		//生成逻辑脚本
    		var modelmsg = createModelScript();
    		if(modelmsg&&modelmsg.indexOf("成功")<= 0){
    			alert("生成逻辑脚本失败！！");
    			return;	
    		}
    		//更新实体表
    		var tablePhysicalScripts = new AI.JsonStore({
              sql: "select * from table_physical_script_boss where XMLID='" + metaActionController.editTABMeatInfo.objrecord.get('XMLID') + "' AND DATA_TYPE='开发'",
              pageSize: -1,
              key: 'XMLID,DATA_TYPE',
              table: 'table_physical_script_boss'
          });
        for (var i = tablePhysicalScripts.getCount() - 1; i > -1; i--) {
              tablePhysicalScripts.remove(tablePhysicalScripts.getAt(i));
        }
        var physicalRecord = tablePhysicalScripts.getNewRecord();
        physicalRecord.set("XMLID",xmlid);
        physicalRecord.set("DATA_TYPE","开发");
        physicalRecord.set("ATTRCODE",dataName);
        physicalRecord.set("PARACODE",dataName);
        physicalRecord.set("PARANAME",dataName);
        physicalRecord.set("PARATYPE","model");
        physicalRecord.set("TABLESEQ",0);
        physicalRecord.set("SCHEMA_NAME",excute_schema);
        physicalRecord.set("TABSPACE",excute_tabspace);
        physicalRecord.set("INDEXSPACE",excute_indexspace);
        physicalRecord.set("STATE","未执行");
        tablePhysicalScripts.add(physicalRecord);
    		var resultSql="";
    		if(dataLevel == "按年分表"||dataLevel == "按年月分表"){
        	var dateArr = divideDate.split("-");
        	if(dateArr.length>1){
        		for(var i = dateArr[0];i<=dateArr[1];i++ ){
        			var tempDataName = dataName.replace(/(_YYYY|_YYYYMM)$/,"_"+i);
        			var entitysql= modelSql.replaceAll(dataName	,tempDataName)
	        		tablePhysicalScripts = addPhysicalScripts(tablePhysicalScripts,tempDataName,dataName,xmlid,tablePhysicalScripts.getCount(),entitysql,excute_schema,excute_tabspace,excute_indexspace);
	        		resultSql += "\n"+entitysql;
        		}
        	}else{
        		alert("请检查日期枚举值！");
        		return;
        	}
        }else if (dataLevel == "按地市分表"){
        	var regionArr = divideRegion.split(",");
        	for(var j = 0; j < regionArr.length; j++){
        		var tempDataName = dataName.replace(/(_XXX)$/,"_"+regionArr[j]);
        		var entitysql= modelSql.replaceAll(dataName,tempDataName)
        		tablePhysicalScripts = addPhysicalScripts(tablePhysicalScripts,tempDataName,dataName,xmlid,tablePhysicalScripts.getCount(),entitysql,excute_schema,excute_tabspace,excute_indexspace);
        		resultSql += "\n"+entitysql;
        	}
        }else if(dataLevel == "按地市年分表"||dataLevel == "按地市年月分表"){
        	var regionArr = divideRegion.split(",");
        	var dateArr = divideDate.split("-");
        	for(var m = 0; m < regionArr.length; m++){
        		if(dateArr.length>1){
        			for(var n = dateArr[0];n<=dateArr[1];n++ ){
        				var tempDataName = dataName.replace(/(_XXX_YYYY|_XXX_YYYYMM)$/,"_"+regionArr[m]+"_"+n);
        				var entitysql= modelSql.replaceAll(dataName,tempDataName)
		        		tablePhysicalScripts = addPhysicalScripts(tablePhysicalScripts,tempDataName,dataName,xmlid,tablePhysicalScripts.getCount(),entitysql,excute_schema,excute_tabspace,excute_indexspace);
		        		resultSql += "\n"+entitysql;
        			}
        		}else{
        			alert("请检查日期枚举值！");
        			return;
        		}
        	}
        }else if (dataLevel == "按尾号分表"){
        }else{
        	tablePhysicalScripts = addPhysicalScripts(tablePhysicalScripts,dataName,dataName,xmlid,tablePhysicalScripts.getCount(),modelSql,excute_schema,excute_tabspace,excute_indexspace);
        	resultSql = modelSql;
        }
  			tablePhysicalScripts.cache.update == [];
        var rs = tablePhysicalScripts.commit(true);
        var rsJson = $.parseJSON(rs);
        alert(rsJson.msg);
    		$("#excute-sql").val(resultSql);
    	});
    	
    	function createModelScript(){
    		var tableDiffs = new AI.JsonStore({
              sql: "select * from TABLE_DIFF_RESULT_BOSS where XMLID='" + metaActionController.editTABMeatInfo.objrecord.get('XMLID') + "'",
              pageSize: -1,
              key: 'XMLID,SQL_TEXT',
              table: 'TABLE_DIFF_RESULT_BOSS'
          });
          for (var i = tableDiffs.getCount() - 1; i > -1; i--) {
              tableDiffs.remove(tableDiffs.getAt(i));
          }
          var resultSql =  metaActionController.getCreateTabSql();
          var resultSqlArr = resultSql.split(";");
          for(var j = 0 ; j < resultSqlArr.length; j++){
          		if(!resultSqlArr[j]) return;
          		var _record = tableDiffs.getNewRecord();
          		_record.set('XMLID', metaActionController.editTABMeatInfo.objrecord.get('XMLID'));
              _record.set('TABLE_NAME', metaActionController.editTABMeatInfo.objrecord.get('DATANAME'));
              if(resultSqlArr[j].indexOf('index')!=-1){
              	_record.set('DIFF_TYPE','INDEX');
              }else{
              	_record.set('DIFF_TYPE','CREATE');
              }
              _record.set('SQL_TEXT',resultSqlArr[j]);
              _record.set('STATE_VAL','新建');
              _record.set('CREATER', _UserInfo['username']);
              _record.set('EFF_DATE', new Date());
              _record.set('STATE_DATE', new Date());
              _record.set('CURDUTYER', _UserInfo['username']);
              tableDiffs.add(_record);
          }
        	tableDiffs.cache.update == [];
          var rs = tableDiffs.commit(true);
          var rsJson = $.parseJSON(rs);
          return rsJson.msg;
    	}    	
    	function addPhysicalScripts(tablePhysicalScripts,tempDataName,dataName,xmlid,tablseq,entitysql,excute_schema,excute_tabspace,excute_indexspace){
        	var _entityRecord = tablePhysicalScripts.getNewRecord();
        	_entityRecord.set("XMLID",xmlid);
	        _entityRecord.set("DATA_TYPE","开发");
	        _entityRecord.set("ATTRCODE",tempDataName);
	        _entityRecord.set("PARACODE",tempDataName);
	        _entityRecord.set("PARANAME",tempDataName);
	        _entityRecord.set("PARENTCODE",dataName);
	        _entityRecord.set("PARATYPE","entity");
	        _entityRecord.set("TABLESEQ",tablseq);
	        _entityRecord.set("SCHEMA_NAME",excute_schema);
	        _entityRecord.set("TABSPACE",excute_tabspace);
	        _entityRecord.set("INDEXSPACE",excute_indexspace);
	        _entityRecord.set("STATE","未执行");
	        tablePhysicalScripts.add(_entityRecord);
	        var entityScriptArr = entitysql.split(";");
	        for(var i = 0; i < entityScriptArr.length; i++){
	        	var _scpritRecord = tablePhysicalScripts.getNewRecord();
	        	if(entityScriptArr[i]){
	        		_scpritRecord.set("XMLID",xmlid);
			        _scpritRecord.set("DATA_TYPE","开发");
			        _scpritRecord.set("ATTRCODE",tempDataName+"_"+i);
			        _scpritRecord.set("PARACODE",entityScriptArr[i]);
			        _scpritRecord.set("PARENTCODE",tempDataName);
			        _scpritRecord.set("PARANAME",tempDataName);
			        _scpritRecord.set("PARATYPE","script");
			        _scpritRecord.set("SCRIPTSEQ",i);
			        _scpritRecord.set("TABLESEQ",tablseq);
			        _scpritRecord.set("SCHEMA_NAME",excute_schema);
			        _scpritRecord.set("TABSPACE",excute_tabspace);
			        _scpritRecord.set("INDEXSPACE",excute_indexspace);
			        _scpritRecord.set("STATE","未执行");
			        tablePhysicalScripts.add(_scpritRecord);
	        	}
	        }
	        return tablePhysicalScripts;
      }
      
      $("#execute-check").on('click',function(){
      	var excute_db = $("#excute-db").val();
      	if(!excute_db){
      		alert("请选择要执行的数据库");
      		return;	
      	}
				var executeFlag = true;
				var failCount = 0;
				metaActionController.editTABScript.executeScriptStore.select();
				for(var i = 0; i < metaActionController.editTABScript.executeScriptStore.getCount(); i++){
					var executeScript = metaActionController.editTABScript.executeScriptStore.getAt(i);
					var _scriptState = executeScript.get("STATE");
					if(_scriptState=='未执行'||_scriptState=='执行失败'){
						var _script = executeScript.get("PARACODE");
						var date1 = new Date();
						var scriptMsg = ai.executeSQL(_script,"",excute_db);
						var date2 = new Date();
						var dateSpace = date2.getTime() - date1.getTime();
						var seconds = Math.floor(dateSpace/1000);
						executeScript.set("DBNAME",excute_db);
						executeScript.set("EXECUTE_TIMES",seconds);
						if(scriptMsg.success){
							executeScript.set("STATE","执行成功");
						}else{
							executeScript.set("STATE","执行失败");
							executeFlag = false;
							failCount++
							var index = scriptMsg.msg.indexOf(' nested exception');
							var errMsg = scriptMsg.msg.substring(index);
							executeScript.set("REMARK",errMsg);
						}	
					}
				}
				if(executeFlag){
					metaActionController.editTABMeatInfo.objrecord.set("STATE","脚本执行成功");
      		metaActionController.editTABMeatInfo.objStore.commit();	
      		var _fields = metaActionController.editTABMeatInfo.baseInfoForm.config.items;
					for(var i=0;i<_fields.length;i++){
							_fields[i].isReadOnly = 'y';
					}
					metaActionController.editTABMeatInfo.refreshForm(_fields);
	    		$("button").not(".btn-prev").not(".btn-next").attr("disabled", "disabled");
	    		$("#execute-unit").removeAttr("disabled");
				}
				
				metaActionController.editTABScript.executeScriptStore.commit();
      });
    	$("#execute-unit").on('click',function(){
    		var tableState = metaActionController.editTABMeatInfo.objStore.curRecord.data['STATE'];
    		if(!tableState||!tableState=='脚本执行成功'){
    			alert("请检查脚本执行是否成功,不成功不能做单元测试！");	
    			return;
    		}
    		Ext.Msg.confirm('信息','确认单元测试通过之后不能再调整脚本，是否单元测试通过?',function(btn){
				if(btn=='yes'){
        	var afterTaskSelect = function(rs){
      			if(rs.length == 0) return;
      			if(rs.length >1){
      				alert("一个对象只能关联一个任务单，请重新选择！！ ");
      				return;	
      			}
      			 metaActionController.editTABMeatInfo.objrecord.set("STATE","单元测试通过");
      			 metaActionController.editTABMeatInfo.objStore.commit();
      			var scriptObjs = new AI.JsonStore({
              sql: "select * from script_obj_boss where 1=2",
              pageSize: -1,
              key: 'OBJ_ID',
              table: 'script_obj_boss'
          	}); 
      			var scriptObj = scriptObjs.getNewRecord();
      			scriptObj.set("OBJ_ID",metaActionController.editTABMeatInfo.objrecord.get("XMLID"));
      			scriptObj.set("OBJ",metaActionController.editTABMeatInfo.objrecord.get("DATANAME"));
      			scriptObj.set("OBJ_NAME",metaActionController.editTABMeatInfo.objrecord.get("DATACNNAME"));
      			scriptObj.set("OBJ_BELONGSYS",metaActionController.editTABMeatInfo.objrecord.get("TOPICNAME"));	
      			scriptObj.set("OBJ_CREATER",metaActionController.editTABMeatInfo.objrecord.get("CREATER"));
      			scriptObj.set("OBJ_CURDUTYER",metaActionController.editTABMeatInfo.objrecord.get("CURDUTYER"));
      			scriptObj.set("OBJ_DEV_STATE","单元测试通过");
      			scriptObj.set("TASK_ID",rs[0].get("VALUES1")); 
      			scriptObj.set("create_time",new Date());
      			scriptObjs.add(scriptObj);
      			scriptObjs.commit();
      		}
      		var selBox = new SelectBox({
        		sql: "SELECT TASK_ID AS VALUES1,TASK_NAME AS VALUE2 FROM TASK_BOSS WHERE TASK_STATE IN ('新建','回退')",
        		callback: afterTaskSelect
    			});
    			selBox.show();
        }
        });
    	});
    	
    },
    /*查看创建表语句*/
    getCreateTabSql: function(excute_schema,excute_tabspace,excute_indexspace) {
    	var _sql ='';
    	var dataName = metaActionController.editTABMeatInfo.objStore.curRecord.data["DATANAME"];
    	var dataCnName = metaActionController.editTABMeatInfo.objStore.curRecord.data["DATACNNAME"];
    	var schema = excute_schema||metaActionController.editTABMeatInfo.objStore.curRecord.data["SCHEMA_NAME"];
    	var _tabspace = excute_tabspace||metaActionController.editTABMeatInfo.objStore.curRecord.data["TABSPACE"];
    	var _compression = metaActionController.editTABMeatInfo.objStore.curRecord.data["COMPRESSION"]; 
    	var _dbName = metaActionController.editTABMeatInfo.objStore.curRecord.data['DBNAME'];
    	var _dataType = '';
    	for (var i = 0; i < metaActionController.editTABMeatInfo.metadb.length; i++) {
          if (metaActionController.editTABMeatInfo.metadb[i]['dbname'] === _dbName) {
              _dataType = metaActionController.editTABMeatInfo.metadb[i]['driverclassname'];
              break;
          }
      }
    	var columnsData = metaActionController.editTABField.handsontable.getData();
    	if(!(dataName&&columnsData.length>1)) return _sql;
    	
    	var _schema =dataName.substr(0,dataName.indexOf(".")+1);
    	var _tabname = dataName.substr(dataName.indexOf(".")+1,dataName.length);
    	if(_dataType.indexOf('oracle')!=-1){
    		_sql += 'create table ' + (schema ? schema + '.' : _schema) + _tabname;
				_sql += '\n(\n\t';
				//表列定义
				var _commentsql ='';
				var primarykeys=[];
				for (var i = 0; i < columnsData.length-1; i++) {
							var _item = columnsData[i];
							
							var defaultVal ='';
							if(_item['DEFAULT_VALUE']!=''&&_item['DEFAULT_VALUE']!=undefined&&(_item['DATATYPE'].toUpperCase() == 'VARCHAR' || _item['DATATYPE'].toUpperCase() == 'VARCHAR2')){
								defaultVal = "DEFAULT VALUE '"+_item['DEFAULT_VALUE']+"'";
							}else if(_item['DEFAULT_VALUE']!=''&&_item['DEFAULT_VALUE']!=undefined){
								defaultVal = 'DEFAULT VALUE '+_item['DEFAULT_VALUE'];	
							}
							var _colType = _item['DATATYPE'];
							if (_item['LENGTH'] && parseInt(_item['LENGTH']) > 0) {
								if (_item['PRECISION_VAL'] && parseInt(_item['PRECISION_VAL']) > 0) {
									_colType += '(' + _item['LENGTH'] + ',' + _item['PRECISION_VAL'] + ')';
								} else {
									_colType += '(' + _item['LENGTH'] + ')';
								}
							}
							//TODO - 校验是否主键
							if (_item['KEY_SEQ'] && _item['KEY_SEQ'] == 1) {
								primarykeys.push(_item['COLNAME']);
							}
							
							//TODO - 校验是否为空
							if (_item['ISNULLABLE'] &&_item['ISNULLABLE'] == 'N' ) {
								_colType += '\t not null ';
					    }
							
							
							if (defaultVal !='' &&defaultVal !='undefined'){
								_sql += _item['COLNAME'] + ' \t' + _colType + ' ' + (defaultVal || '') + ' ' ;
						  } else {
						   _sql += _item['COLNAME'] + ' \t' + _colType + '  ' ;	
						  }
						  
						  _commentsql +="\n COMMENT ON COLUMN "+(schema ? schema + "." : _schema) + _tabname+"."+_item['COLNAME'] +" IS '"+_item['COLCNNAME']+"';";
						  
							if (i < columnsData.length - 2||(primarykeys && primarykeys.length > 0)) {
								_sql += ',\n\t';
							}
						}
				if (primarykeys && primarykeys.length > 0){
					_sql += ' primary key (' + (primarykeys.join(',') || '')+')';
				}
				_sql += '\n)\n';
				
				var partitionStore = metaActionController.editTABPartition.handsontable.getData();
				if (partitionStore.length>1&&partitionStore[0]){
					_sql += "partition by "+ partitionStore[0]['PARTITIONTYPE']+"("+partitionStore[0]['PARTITIONCOL']+") ";
					_sql += "\n(\n";
					for (var j = 0;j <partitionStore.length-1;j++ )
					if (partitionStore[0]['PARTITIONTYPE'] == 'range'){
						if(partitionStore[j]['PARTITIONNAME']){
						
						if (j == partitionStore.length-2){
							_sql += "partition "+partitionStore[j]['PARTITIONNAME']+" values less than("+partitionStore[j]['VALUES1']+")";}
						else {_sql += "partition "+partitionStore[j]['PARTITIONNAME']+" values less than("+partitionStore[j]['VALUES1']+"),\n";}
						
					}} else if (partitionStore[0]['PARTITIONTYPE'] == 'hash'){
						if(partitionStore[j]['PARTITIONNAME']){
						
						if (j == partitionStore.length-2){
							_sql += "partition "+partitionStore[j]['PARTITIONNAME'];}
						else {_sql += "partition "+partitionStore[j]['PARTITIONNAME']+",\n";}
					
					}} else if (partitionStore[0]['PARTITIONTYPE'] == 'list'){
						if(partitionStore[j]['PARTITIONNAME']){
					
						if (j == partitionStore.length-2){
						_sql += "partition "+partitionStore[j]['PARTITIONNAME']+" values ("+partitionStore[j]['VALUES1']+")";}
						else {_sql += "partition "+partitionStore[j]['PARTITIONNAME']+" values ("+partitionStore[j]['VALUES1']+"),\n";}
						
					}}
					_sql += "\n)";
				}
					
				//表其他属性定义 存储|分区
				if (_compression == "yes") {
					_sql += ' compress ' ;
				}
				if(_compression == "no")	{
					_sql += ' nocompress ' ;
				}
				if(_tabspace)	{
				_sql += ' tablespace ' + _tabspace ;
				}
				_sql += ';';
				
				_sql +="\n COMMENT ON TABLE "+(schema ? schema + "." : _schema) + _tabname+" IS '"+dataCnName+"';";
				_sql +=_commentsql;
				
				var indexStore = metaActionController.editTABIndex.handsontable.getData();
				for(var k = 0;k < indexStore.length - 1;k++ ){
					var indexItem = indexStore[k];
					if(indexItem['INDEXTYPE'] == '唯一索引'){
						_sql += '\n create unique index '+indexItem['INDEXNAME']+' on '+_tabname+"("+indexItem['INDEXCOLUMN']+")";
						if(excute_tabspace||indexItem['INDEXSPACE']){
							_sql += ' tablespace ' + (excute_tabspace||indexItem['INDEXSPACE']) + ';';
						}else{
							_sql +=';';
						}	
					}else{
						_sql += '\n create index '+indexItem['INDEXNAME']+' on '+_tabname+"("+indexItem['INDEXCOLUMN']+")";
						if(excute_tabspace||indexItem['INDEXSPACE']){
							_sql += ' tablespace ' + (excute_tabspace||indexItem['INDEXSPACE']) + ';';
						}else{
							_sql +=';';
						}		
					}	
				}
				
    	}else if(_dataType.indexOf('hive')!=-1){
    		_sql += 'create table ' + (schema ? schema + '.' : _schema) + _tabname;
				_sql += '\n(\n\t';
				//表列定义
				var primarykeys=[];
				for (var i = 0; i < columnsData.length-1; i++) {
							var _item = columnsData[i];
							
							var defaultVal ='';
							if(_item['DEFAULT_VALUE']!=''&&_item['DEFAULT_VALUE']!=undefined&&(_item['DATATYPE'].toUpperCase() == 'VARCHAR' || _item['DATATYPE'].toUpperCase() == 'VARCHAR2')){
								defaultVal = "DEFAULT VALUE '"+_item['DEFAULT_VALUE']+"'";
							}else if(_item['DEFAULT_VALUE']!=''&&_item['DEFAULT_VALUE']!='undefined'){
								defaultVal = 'DEFAULT VALUE '+_item['DEFAULT_VALUE'];	
							}
							var _colType = _item['DATATYPE'];
							if (_item['LENGTH'] && parseInt(_item['LENGTH']) > 0) {
								if (_item['PRECISION_VAL'] && parseInt(_item['PRECISION_VAL']) > 0) {
									_colType += '(' + _item['LENGTH'] + ',' + _item['PRECISION_VAL'] + ')';
								} else {
									_colType += '(' + _item['LENGTH'] + ')';
								}
							}
							//TODO - 校验是否主键
							if (_item['KEY_SEQ'] && _item['KEY_SEQ'] == 1) {
								primarykeys.push(_item['COLNAME']);
							}
							
							//TODO - 校验是否为空
							if (_item['ISNULLABLE'] &&_item['ISNULLABLE'] == 'N' ) {
								_colType += '\t not null ';
					    }
							
							if (defaultVal !='' &&defaultVal !='undefined'){
								_sql += _item['COLNAME'] + ' \t' + _colType + ' ' + (defaultVal || '') + ' ' ;
						  } else {
						   _sql += _item['COLNAME'] + ' \t' + _colType + '  ' ;	
						  }
							if (i < columnsData.length - 2||(primarykeys && primarykeys.length > 0)) {
								_sql += ',\n\t';
							}
						}
				if (primarykeys && primarykeys.length > 0){
					_sql += ' primary key (' + (primarykeys.join(',') || '')+')';
				}
				_sql += '\n)\n';
				
    	}
    	return _sql;
    },
    /*创建任务基本信息*/
    editProcMeatInfo: {
        objStore: {},
        baseObjInfo: {},
        objrecord: {},
        metaInfo: null,
        getMetaInfo: function(objtype) { ////取元模型信息和表对象信息
            ///相关表:METAOBJINFO:基本信息配置表,属性配置表:METAOBJCFG,
            var sendObj = {
                paras: [{
                    paraname: "objinfo",
                    paratype: "map",
                    sql: "select OBJTYPE, OBJCODE, OBJNAME, ORDSEQ, REMARK, TABNAME,  RULETAB, KEYFIELD, NAMEFIELD, LOGTAB, TIMEFIELD, RUNTABNAME,  DETAILURL, RUNURL from DQOBJMODEL where objtype='" + objtype + "'"
                }, {
                    paraname: "objattr",
                    paratype: "array",
                    sql: "select OBJTYPE, ATTRGROUP, ATTRNAME, ATTRCNNAME, INPUTTYPE,INPUTPARA, ISNULL, SELVAL, SELMODEL, SEQ, REMARK from METAOBJCFG where objtype='" + objtype + "' order by SEQ "
                }]
            };
            var URL = '/' + contextUrl + '/olapquery?json=' + ai.encode(sendObj);
            var obj = ai.remoteData(URL);

            return obj;
        },
        ////对象基本信息
        getBaseInfo: function(metaInfo, attrArray) {
            var Global = {};
            if (window.parent) Global = window.parent.Global;
            var OBJTYPE = paramMap.OBJTYPE || 'PROC';
            var OPTTYPE = paramMap.OPTTYPE || '';
            var OBJNAME = paramMap.OBJNAME || '';
            if (OBJNAME && OBJTYPE == 'INTER' && OBJNAME.indexOf(".") > 0) {
                OBJTYPE = 'TAB';
            };
            var OBJCNNAME = paramMap.OBJCNNAME || '';
            var METAPRJ = paramMap.METAPRJ || "";
            var _METAPRJ = METAPRJ ? "_" + METAPRJ : "";
            var TEAMCODE = paramMap.TEAM_CODE || '';
            var groupType = paramMap.GROUPTYPE || '';
            var actType = paramMap.ACTTYPE || "edit";

            this.objStore = new AI.JsonStore({
                sql: "select * from " + metaInfo.tabname + " where " + metaInfo.keyfield + "='" + OBJNAME + "'",
                table: metaInfo.tabname,
                loadDataWhenInit: true,
                secondTable: "METAOBJ",
                key: metaInfo.keyfield
            });
            this.objStore.on("beforecommit", function() {

                for (var i = 0; i < metaActionController.editProcMeatInfo.objStore.getCount(); i++) {
                    var r = metaActionController.editProcMeatInfo.objStore.getAt(i);
                    r.set('XMLID', r.get('XMLID'));
                    r.set('OBJNAME', r.get('PROC_NAME'));
                    r.set('OBJCNNAME', r.get(metaInfo.namefield));
                    r.set('PATH', 'go.sh');
                };
                return true;
            });
            if (this.objStore.getCount() == 0) {
                actType = "add";
                this.objrecord = this.objStore.getNewRecord();

                for (var key in paramMap) {
                    this.objrecord.set(key.toUpperCase(), paramMap[key]);
                };
                for (var key in Global) {
                    if (typeof Global[key] != 'object' && key != 'objtype')
                        this.objrecord.set(key.toUpperCase(), Global[key]);
                };
                if (OBJCNNAME) this.objrecord.set(metaInfo.nameField, OBJCNNAME);
                this.objrecord.set('XMLID', ai.guid());
                this.objrecord.set('CREATER', _UserInfo['username']);
                this.objrecord.set('EFF_DATE', new Date());
                this.objrecord.set('STATE', 'NEW');
                this.objrecord.set('STATE_DATE', new Date());
                this.objrecord.set('CURDUTYER', _UserInfo['username']);
                this.objrecord.set('VERSEQ', 1);
                this.objrecord.set('TEAM_CODE', TEAMCODE);
                this.objrecord.set('PLATFORM', 'bus');
                this.objrecord.set('OBJTYPE', OBJTYPE);
                this.objStore.add(this.objrecord);

            } else {
                this.objrecord = this.objStore.getAt(0);
                actType = ai.checkCurdutyer(this.objrecord.get('CURDUTYER')) ?actType:'readOnly';
                if (_UserInfo.username == 'sys') actType = 'edit';
                var extend_cfg = this.objrecord.get('EXTEND_CFG');
                if (extend_cfg) {
                    var cfg = JSON.parse(extend_cfg);
                    $.each(cfg, function(key, value) {
                        metaActionController.editProcMeatInfo.objrecord.set('EXTEND_CFG--' + key, value);
                    })
                }
            };

            var formItems = [];
            for (var i = 0; i < attrArray.length; i++) {
                var attrItem = attrArray[i];
                if (!attrItem.attrgroup) continue;
                defaultwidth = 220;
                if (attrItem.inputtype == 'textarea') defaultwidth = 320;
                if (attrItem.inputtype == 'pick-grid') defaultwidth = 320;
                if (attrItem.inputtype == 'check') attrItem.inputtype = 'checkbox';
                if (attrItem.inputtype == 'combo') attrItem.inputtype = 'combox';
                if (attrItem.inputtype == 'label') continue; //attrItem.inputtype='html';
                if (!attrItem.inputtype) attrItem.inputtype = 'text';

                var readonly = "";
                if (attrItem.attrname == 'DBUSER') readonly = 'y';
                if(attrItem.attrname=='EXTEND_CFG.MAP_NUM') readonly='y';
                if(attrItem.attrname=='EXTEND_CFG.REDUE_NUM') readonly='y';
                if(attrItem.attrname=='RUNPARA') readonly='y';
                if (attrItem.attrname == 'PROC_NAME' && actType == 'edit') {
                    readonly = 'y';
                } else if (attrItem.attrname == 'PROC_NAME' && actType == 'add') {
                    readonly = 'n';
                }
                if (actType == "readOnly") readonly = 'y';

                if (attrItem.inputpara && attrItem.inputpara.length > 0) {
                    if (attrItem.attrname == 'DBNAME') {
                        if (TEAMCODE) {
                            attrItem.inputpara = attrItem.inputpara.replace(/{team_code}/g, TEAMCODE).replace('{username}', _UserInfo['username']);
                        } else {
                            attrItem.inputpara = "select dbname,cnname from metadbcfg";
                        }
                    } else {
                        attrItem.inputpara = attrItem.inputpara.replace(/{team_code}/g, TEAMCODE).replace('{username}', _UserInfo['username']);
                    }
                }
                if (groupType == 'normal' || !TEAMCODE || TEAMCODE.length < 1) {
                    if (attrItem.attrname == 'EXTEND_CFG.SOURCE_TAB' || attrItem.attrname == 'EXTEND_CFG.TARGET_TAB') {
                        attrItem.inputpara = "select dataname values1,datacnname values2,dbname values3 FROM tablefile where team_code is null or team_code='T0000'";
                    }
                }
                var formItem = {
                    type: attrItem.inputtype || 'text',
                    label: attrItem.attrcnname || attrItem.attrname,
                    notNull: attrItem.isnull || 'Y',
                    isReadOnly: readonly,
                    storesql: attrItem.inputpara,
                    fieldName: attrItem.attrname,
                    width: defaultwidth,
                    editable:'N',
                    tip: attrItem.remark
                };

                
                if(attrItem.attrname == 'LEVEL_VAL'){
                      //查询是否开启自定义层次和主题的开关
                var define_switch=new AI.JsonStore({
                    sql:"SELECT OBJTYPE,ATTRNAME,ATTRCNNAME FROM metaobjcfg WHERE OBJTYPE='DEFINE_SWITCH'",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAOBJCFG",          //新增修改删除表的名称，注意要大写
                    key:"OBJTYPE"
                });

                var ifSwitch=false;
                if(define_switch.getCount()>0){
                   var ret=define_switch.getAt(0);
                   if(ret.get("ATTRNAME")=='0'){
                      ifSwitch=true;
                   }
                }
                
            //查询自定义表中是否有该租户的数据
            var table_switch;
            if(actType=='add'&&ifSwitch){
                table_switch=new AI.JsonStore({
                    sql:"SELECT DIMCODE,ROWCODE FROM metaedimdef_define WHERE dimcode='DIM_DATALEVEL' AND team_code ='"+TEAMCODE+"' AND rowcode IS NOT NULL",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAEDIMDEF_DEFINE",          //新增修改删除表的名称，注意要大写
                    key:"DIMCODE"
                });
            }

            //查询该数据是否是开关开启后添加的数据
            var data_switch;
            if(actType=='edit'&&ifSwitch){
                var rowcodeRet = this.objrecord.get('LEVEL_VAL');
                data_switch=new AI.JsonStore({
                    sql:"SELECT DIMCODE,ROWCODE FROM metaedimdef_define WHERE dimcode='DIM_DATALEVEL' AND team_code ='"+TEAMCODE+"' AND rowcode='"+rowcodeRet+"'",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAEDIMDEF_DEFINE",          //新增修改删除表的名称，注意要大写
                    key:"DIMCODE"
                });
            }

            var retSql2="";
             if(ifSwitch){
                 //自定义开关开启
                 if(actType=='edit'){
                    //编辑操作
                   if(data_switch.getCount()>0){
                      //该数据是开关开启后添加的数据
                      retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='"+TEAMCODE+"'";
                   }else{
                      //该数据是开关关闭时添加的数据
                      retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')";
                   }
                 }else if(actType=='add'){
                    //添加操作
                     if(table_switch.getCount()>0){
                       //如果该租户有自定义层次
                       retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='"+TEAMCODE+"'";
                     }else{
                       //如果该租户没有自定义层次
                       retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='S0001'" ;
                     }
                 }else if(actType=='readOnly'){
                    retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')";
                 }
             }else{
                //自定义开关关闭
                retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF WHERE dimcode='DIM_DATALEVEL'";
             }

                   formItem = {
                    fieldset:attrItem.attrgroup,
                    type: attrItem.inputtype || 'text',
                    label: attrItem.attrcnname,
                    notNull: attrItem.isnull || 'Y',
                    storesql:retSql2,
                    /*ifSwitch?actType=='edit'?
                    data_switch.getCount()>0?"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='"+TEAMCODE+"'":"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')"
                    :table_switch.getCount()>0?"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='"+TEAMCODE+"'":"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='S0001'" 
                    :"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF WHERE dimcode='DIM_DATALEVEL'",*/
                    
                    isReadOnly: readonly,
                    fieldName: attrItem.attrname,
                    width: defaultwidth,
                    tip: attrItem.remark,
                    editable:'N',
                    dependencies: attrItem.dependencies,
                    checkItems: attrItem.checkitems
                };
                }

                if(attrItem.attrname=='TOPICNAME'){
                    //查询是否开启自定义层次和主题的开关
                var define_switch=new AI.JsonStore({
                    sql:"SELECT OBJTYPE,ATTRNAME,ATTRCNNAME FROM metaobjcfg WHERE OBJTYPE='DEFINE_SWITCH'",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAOBJCFG",          //新增修改删除表的名称，注意要大写
                    key:"OBJTYPE"
                });

                var ifSwitch=false;
                if(define_switch.getCount()>0){
                    var ret=define_switch.getAt(0);
                   if(ret.get("ATTRNAME")=='0'){
                      ifSwitch=true;
                   }
                }

            //查询自定义表中是否有数据
            var table_switch;
            if(actType=='add'&&ifSwitch){
                table_switch=new AI.JsonStore({
                    sql:"SELECT DIMCODE,rowcode FROM metaedimdef_define WHERE dimcode='DIM_TOPIC' AND team_code ='"+TEAMCODE+"' AND rowcode IS NOT NULL",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAEDIMDEF_DEFINE",          //新增修改删除表的名称，注意要大写
                    key:"DIMCODE"
                });
            }
            
            //查询该数据是否是开关开启后添加的数据
            var data_switch;
            if(actType=='edit'&&ifSwitch){
                    var rowcodeRet2 = this.objrecord.get('TOPICNAME');
                    var rets;
                     if(rowcodeRet2!=null){
                       rets=rowcodeRet2.split('|');
                    }else{
                        rets=['undefined'];
                    }
                    data_switch=new AI.JsonStore({
                       sql:"SELECT DIMCODE,ROWCODE FROM metaedimdef_define WHERE dimcode='DIM_TOPIC' AND team_code ='"+TEAMCODE+"' AND rowcode='"+rets[0]+"'",      //store查询的sql语句
                       dataSource:"METADB",       //数据源，对应一个数据库
                       table:"METAEDIMDEF_DEFINE",          //新增修改删除表的名称，注意要大写
                       key:"DIMCODE"
                    });
            }

                 var retSql=[];
                if(ifSwitch){
                //自定义主题开关开启
                   if(actType=='edit'){
                    //编辑操作
                     if(data_switch.getCount()>0){
                        //该数据是开关开启后添加的数据
                        retSql=[
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='"+TEAMCODE+"'",
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'",
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'"
                        ];
                     }else{
                        //该数据是开关关闭时添加的数据
                        retSql=[
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')"
                        ];
                     }
                   }else if(actType=='add'){
                    //添加操作
                    if(table_switch.getCount()>0){
                      //该租户有自定义的主题
                      retSql=[
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='"+TEAMCODE+"'",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'"
                      ];
                    }else{
                      //该租户没有自定义的主题
                      retSql=[
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='S0001'",
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='S0001'",
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='S0001'"
                      ];
                    }
                   }else if(actType=='readOnly'){
                      retSql=[
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')"
                        ];
                   }
                }else{
                //自定义主题开关关闭
                    retSql=["select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC'", "select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}'", "select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}'"
                        ];
                }

                    formItem={
                        type:'mulitLevel',
                        label:attrItem.attrcnname,
                        notNull:'Y',
                        editable:'N',
                        fieldName:attrItem.attrname,
                        levelSqls:retSql,
                        /*ifSwitch?actType=='edit'?
                        [data_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         data_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         data_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')"]
                        :[table_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='S0001'",
                         table_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='S0001'",
                         table_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='S0001'"                          
                        ]:["select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC'", "select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}'", "select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}'"
                        ],*/
                        isReadOnly:readonly
                    };
            }
                formItems.push(formItem);
            };

            var formcfg = ({
                id: 'baseInfoForm',
                store: this.objStore,
                containerId: 'baseInfoForm',
                fieldChange: function(fieldName, newVal) {
                    metaActionController.editProcMeatInfo.baseObjInfo[fieldName] = newVal;
                    metaActionController.editProcMeatInfo.objrecord.set(fieldName.toUpperCase(), newVal);
                    if (fieldName == 'DBNAME') {
                        if (TEAMCODE) {
                            var dbuser = ai.getStoreData("select USERNAME from data_trans_database where TEAM_CODE='" + TEAMCODE + "' and DBNAME='" + newVal + "'")[0].USERNAME;
                        } else {
                            var dbuser = ai.getStoreData("select USERNAME from metadbcfg where DBNAME='" + newVal + "'")[0].USERNAME;
                        }
                        metaActionController.editProcMeatInfo.baseObjInfo['DBUSER'] = dbuser;
                        $('#baseInfoForm #DBUSER').val(dbuser);
                    }
                },
                items: formItems
            });
            var from = new AI.Form(formcfg);
            var runpara = $("#RUNPARA").val()
            $("#PROCTYPE").change(function(){
                if($("#PROCTYPE").val() == "taskTypeFunc"){
                    $("#RUNPARA").attr("disabled",false);
                    $("#RUNPARA").val(runpara)
                    metaActionController.editProcMeatInfo.objStore.curRecord.set('RUNPARA',runpara);
                } else{
                    $("#RUNPARA").attr("disabled",true);
                    $("#RUNPARA").val($("#PROC_NAME").val());
                    metaActionController.editProcMeatInfo.objStore.curRecord.set('RUNPARA',$("#PROC_NAME").val());
                }
            });

            $("#PROC_NAME").blur(function() {
                if($("#PROCTYPE").val() != "taskTypeFunc"){
                    $("#RUNPARA").val($("#PROC_NAME").val());
                    metaActionController.editProcMeatInfo.objStore.curRecord.set('RUNPARA', $("#PROC_NAME").val());
                }
            });

            $("#REMARK").css("width", "320px");
            $("#RUNPARA").css("height", "60px");
        },
        init: function() {
            var OBJTYPE = paramMap.OBJTYPE || 'PROC';
            /*加载对象的元模型*/
            this.metaInfo = this.getMetaInfo(OBJTYPE);
            /*初始化对象基本信息*/
            this.getBaseInfo(this.metaInfo.root[0].objinfo, this.metaInfo.root[1].objattr);
        }

    },
    editProcMeatInfoFun: function() {
        return this.editProcMeatInfo;
    },
    /*加载任务界面事件*/
    addProcEvent: function() {
        var TEAMCODE = paramMap.TEAM_CODE || '';
        var actType = paramMap.ACTTYPE || "edit";
        var curdutyerRet=metaActionController.editProcMeatInfo.objStore.curRecord.get("CURDUTYER");
        actType = ai.checkCurdutyer(curdutyerRet)?actType:'readOnly';
        var checkInputForm = function() {
            var result = true;
            var extend_cfg = {};
            var extend_cfgstr = metaActionController.editProcMeatInfo.objrecord.get('EXTEND_CFG');
            if (extend_cfgstr) {
                extend_cfg = JSON.parse(extend_cfgstr);
            }

            var r = metaActionController.editProcMeatInfo.objStore.curRecord;
            var attrArray = metaActionController.editProcMeatInfo.metaInfo.root[1].objattr;

            for (var i = 0; i < attrArray.length; i++) {
                var attr = attrArray[i];
                if (attr.isnull == 'N') {
                    if (attr.attrname.indexOf("EXTEND_CFG.") >= 0) {
                        var attrKey = attr.attrname.split(".")[1];
                        if (!extend_cfg[attrKey]) {
                            alert(attr.attrcnname + ",扩展信息,不允许为空");
                            result = false;
                            break;
                        } else if (attr.length && extend_cfg[attrKey].length > attr.length) {
                            alert(attr.attrcnname + "长度超出！");
                            result = false;
                            break;
                        }
                    } else if (!r.get(attr.attrname)) {
                        alert(attr.attrcnname + "不允许为空");
                        result = false;
                        break;
                    } else if (attr.length && r.get(attr.attrname).length > attr.length) {
                        alert(attr.attrcnname + "长度超出！");
                        result = false;
                        break;
                    }
                }
            };
            return result;
        };

        $("#proc_compare").click(function(){
                 window.open('/'+contextPath+'/devmgr/ObjCompare.html?OBJTYPE=PROC&OBJNAME='+metaActionController.editProcMeatInfo.objStore.curRecord.get('PROC_NAME')+'&TARDB=&SOURDB=METADB&ONLYDIFF=F');
            });
        
        $('#myWizard').wizard('selectedItem', {
            step: 1
        });
        $('#myWizard').on('actionclicked.fu.wizard', function(event, stepInfo) {
            var r = metaActionController.editProcMeatInfo.objStore.curRecord;
            if (stepInfo.step == 1 && stepInfo.direction == 'next') {
                if (actType != "readOnly") {
                    if (checkInputForm() == false) return false;
                    if(ai.getStoreData("select XMLID from proc where XMLID = '"+r.get('XMLID')+"' and PROC_NAME = '"+r.get('PROC_NAME')+"'")[0]){
                    }else if (actType == "add" && meta.checkObjExists('PROC', r.get('PROC_NAME'), '') == true) {
                        alert("程序:" + r.get('PROC_NAME') + ",已经存在!!!");
                        return false;
                    };
                    metaActionController.editProcMeatInfo.objStore.commit();
                }
                if (r.get('PROCTYPE') == 'taskTypeFunc') {
                    $("#procstepfrm").attr("src", "/" + contextPath + "/lib/codemirror/sqlEditer.html?PROCNAME=" + r.get('PROC_NAME'));
                } else {
                    var procstepUrl = "/" + contextPath + "/public/flowchar/procGraph.html?PROCNAME=" + r.get('PROC_NAME') + "&TEAMCODE=" + TEAMCODE + "&ACTTYPE=" + actType;
                    if ($("#procstepfrm").attr("src") != procstepUrl) {
                        $("#procstepfrm").attr("src", procstepUrl);
                    }
                }
            } else if (stepInfo.step == 2 && stepInfo.direction == 'next') {
                $("#developQulityfrm").attr("src", "/" + contextPath + "/dqmgr/MetaDqResult.html?OBJTYPE=PROC&OBJNAME=" + r.get('PROC_NAME') + "&DBNAME=defaultDB&METAPRJ=" + "&ACTTYPE=" + actType);
            } else if (stepInfo.step == 3 && stepInfo.direction == 'next') {
                $("#testfram").attr("src", "/" + contextPath + "/sysmgr/asiainfo/ProcGraph/procTestGraph.html?TEAM_CODE=" + TEAMCODE + "&PROCNAME=" + r.get('PROC_NAME') + "&METAPRJ=" + "&ACTTYPE=" + actType);
            }
            if (stepInfo.step == 2 && stepInfo.direction == 'previous') {
                if (actType == "add") {
                    window.location.href = window.location.href + r.get('XMLID');
                }
            }
            if(stepInfo.step == 3 && stepInfo.direction == 'next'){
                $("#proc_compare").show();
            }else{
                $("#proc_compare").hide();
            }
        });
        //保存
        $('#save-table-info').on('click', function() {
            var r = metaActionController.editProcMeatInfo.objStore.curRecord;
            if (checkInputForm() == true) {
                if(ai.getStoreData("select XMLID from proc where XMLID = '"+r.get('XMLID')+"' and PROC_NAME = '"+r.get('PROC_NAME')+"'")[0]){
                }else if (actType == "add" && meta.checkObjExists('PROC', r.get('PROC_NAME'), '') == true) {
                    alert("程序:" + r.get('PROC_NAME') + ",已经存在!!!");
                    return false;
                };
                var rs = metaActionController.editProcMeatInfo.objStore.commit(true);
                var rsJson = $.parseJSON(rs);
                alert(rsJson.msg);
                $("#PROC_NAME").attr("disabled", "disabled")
                actType = "edit";
            }
        });

        if (actType == "readOnly" &&_UserInfo.username != 'sys') {
            $("#save-table-info").hide();
            $("button").not(".btn-prev").not(".btn-next").attr("disabled", "disabled");
        }
    },

    editInterMeatInfo: {
        metaInfo: null,
        objStore: {},
        getMetaInfo: function(objtype) { ////取元模型信息和表对象信息
            ///相关表:METAOBJINFO:基本信息配置表,属性配置表:METAOBJCFG,
            var sendObj = {
                paras: [{
                    paraname: "objinfo",
                    paratype: "map",
                    sql: "select OBJTYPE, OBJCODE, OBJNAME, ORDSEQ, REMARK, TABNAME,  RULETAB, KEYFIELD, NAMEFIELD, LOGTAB, TIMEFIELD, RUNTABNAME,  DETAILURL, RUNURL from DQOBJMODEL where objtype='" + objtype + "'"
                }, {
                    paraname: "objattr",
                    paratype: "array",
                    sql: "select OBJTYPE, ATTRGROUP, ATTRNAME, ATTRCNNAME, INPUTTYPE,INPUTPARA, ISNULL, SELVAL, SELMODEL, SEQ, REMARK, DEPENDENCIES, CHECKITEMS from METAOBJCFG where objtype='" + objtype + "' order by ATTRGROUP,SEQ "
                }]
            };
            var URL = '/' + contextUrl + '/olapquery?json=' + ai.encode(sendObj);
            var obj = ai.remoteData(URL);

            return obj;
        },
        //对象基本信息
        getBaseInfo: function(metaInfo, attrArray) {
            var Global = {};
            if (window.parent) Global = window.parent.Global;
            var OBJTYPE = paramMap.OBJTYPE || 'INTER';
            var OPTTYPE = paramMap.OPTTYPE || '';
            var OBJNAME = paramMap.OBJNAME || '';
            if (OBJNAME && OBJTYPE == 'INTER' && OBJNAME.indexOf(".") > 0) {
                OBJTYPE = 'TAB';
            };
            var OBJCNNAME = paramMap.OBJCNNAME || '';
            var METAPRJ = paramMap.METAPRJ || "";
            var _METAPRJ = METAPRJ ? "_" + METAPRJ : "";
            var TEAMCODE = paramMap.TEAM_CODE || "";
            var actType = paramMap.ACTTYPE || "edit";
            this.objStore = new AI.JsonStore({
                sql: "select * from " + metaInfo.tabname + " where " + metaInfo.keyfield + "='" + OBJNAME + "'",
                table: metaInfo.tabname,
                loadDataWhenInit: true,
                key: metaInfo.keyfield,
                secondTable: "metaobj"
            });
            var changeSourceDir = function(val) {
                if (val.indexOf("£") == -1) {
                    return val;
                } else {
                    var valArr = val.split(";");
                    var rs = "";
                    for (var i = 0; i < valArr.length; i++) {
                        var valCell = valArr[i].split("£");
                        if (/file/gi.test(valCell[0])) {
                            rs += ((i == 0 ? "" : ";") + valCell[0] + valCell[1]);
                        } else {
                            rs += ((i == 0 ? "" : ";") + "${" + valCell[0] + "}" + valCell[1]);
                        }
                    }
                    return rs;
                }
            };
            this.objStore.on("beforecommit", function() {
                for (var i = 0; i < metaActionController.editInterMeatInfo.objStore.getCount(); i++) {
                    var r = metaActionController.editInterMeatInfo.objStore.getAt(i);
                    r.set('OBJNAME', r.get('FULLINTERCODE'));
                    r.set('OBJCNNAME', r.get('INTER_NAME'));
                    r.set('SOURCEDIR', changeSourceDir(r.get('SOURCEDIR')));
                };
                return true;
            });
            var objrecord = null;
            if (this.objStore.getCount() == 0) {
                actType = "add";
                objrecord = this.objStore.getNewRecord();

                for (var key in paramMap) {
                    objrecord.set(key.toUpperCase(), paramMap[key]);
                };
                for (var key in Global) {
                    if (typeof Global[key] != 'object' && key != 'objtype')
                        objrecord.set(key.toUpperCase(), Global[key]);
                };

                if (OBJNAME && OBJNAME.length > 0) objrecord.set(metaInfo.keyfield, OBJNAME);
                if (OBJCNNAME && OBJCNNAME.length > 0) objrecord.set(metaInfo.nameField, OBJCNNAME);

                objrecord.set('XMLID', ai.guid());
                objrecord.set('TEAM_CODE', TEAMCODE);
                objrecord.set('CREATER', _UserInfo['username']);
                objrecord.set('EFF_DATE', new Date());
                objrecord.set('STATE', '新建');
                objrecord.set('STATE_DATE', new Date());
                objrecord.set('CURDUTYER', _UserInfo['username']);
                objrecord.set('VERSEQ', 1);
                objrecord.set('OBJTYPE', OBJTYPE);

                objrecord.set('PRI_LEVEL', 4);
                objrecord.set('FILEJUDGE', 'false');
                objrecord.set('UNITJUDGE', 'false');
                objrecord.set('ENABLE_MERGE', '0');
                objrecord.set('CHAR_TYPE', 'UTF-8');
                objrecord.set('FILE_START_ROW', 0);

                this.objStore.add(objrecord);

                var no = ai.remoteData("/" + contextPath + "/sequenceService").toString();
                for (var i = 6 - no.length; i > 0; i--) {
                    no = '0' + no;
                }
                objrecord.set('BASENO', no);
            } else {
                objrecord = this.objStore.getAt(0);
                // actType = ai.checkAct(objrecord.get('CURDUTYER'), objrecord.get('XMLID'), metaInfo.tabname) ? 'readOnly' : actType;
                actType = ai.checkCurdutyer(objrecord.get('CURDUTYER')) ?actType:'readOnly';
                if (_UserInfo.username == 'sys') actType = 'edit';
                objrecord.set('BASENO', objrecord.get('FULLINTERCODE').slice(1, 7));
                var sd = objrecord.get('SOURCEDIR') || '';
                var sdArray = sd.split(";");
                var sdResult = "";
                for (var j = 0; j < sdArray.length; j++) {
                    if (/^file/i.test(sdArray[j])) {
                        sdResult += sdArray[j] + ';';
                    } else {
                        sdResult += sdArray[j].replace(/\${/, '').replace(/\}/, '£') + ';';
                    }
                }
                if (/;$/.test(sdResult)) {
                    sdResult = sdResult.substring(0, sdResult.length - 1);
                }
                objrecord.set('SOURCEDIR', sdResult.replace(/file\:\/\//g, 'file://£'));
            }
            objrecord.set('HIVE_LOAD', 1);

            var formItems = [];
            for (var i = 0; i < attrArray.length; i++) {
                var attrItem = attrArray[i];
                defaultwidth = 220;
                var editFlag = ''; //是否展示checkbox后面的toggle按钮
                if (attrItem.inputtype == 'textarea') defaultwidth = 420;
                if (attrItem.inputtype == 'pick-grid') defaultwidth = 320;
                if (attrItem.inputtype == 'check') attrItem.inputtype = 'checkbox';
                if (attrItem.inputtype == 'combo') attrItem.inputtype = 'combox';
                if (attrItem.inputtype == 'label') continue; //attrItem.inputtype='html';
                if (!attrItem.inputtype) attrItem.inputtype = 'text';
                var readonly = "";
                if (attrItem.attrname == 'DBUSER') readonly = 'y';
                if (attrItem.attrname == 'fullintercode' && actType == 'edit') {
                    readonly = 'y';
                } else if (attrItem.attrname == 'fullintercode' && actType == 'add') {
                    readonly = 'n';
                }
                if (attrItem.attrname == 'EXTENDNAME') editFlag = 'y';
                if (actType == "readOnly") {
                    readonly = 'y';
                    attrItem.selmodel = 'readOnly';
                }

                if (attrItem.inputpara && attrItem.inputpara.length > 0) {
                    attrItem.inputpara = attrItem.inputpara.replace(/{team_code}/g, TEAMCODE).replace('{username}', _UserInfo['username']);
                }
                var formItem = {
                    type: attrItem.inputtype || 'text',
                    label: attrItem.attrcnname,
                    value: attrItem.selval,
                    notNull: attrItem.isnull || 'Y',
                    isReadOnly: readonly,
                    storesql: attrItem.inputpara,
                    fieldName: attrItem.attrname,
                    width: defaultwidth,
                    tip: attrItem.remark,
                    isEditable: editFlag,
                    editable:'N',
                    dependencies: attrItem.dependencies,
                    checkItems: attrItem.checkitems
                };
                formItems.push(formItem);
            };

            var formcfg = ({
                id: 'baseInfoForm',
                store: this.objStore,
                containerId: 'baseInfoForm',
                fieldChange: function(fieldName, newVal) {
                    if (fieldName == 'INTER_TYPE' || fieldName == 'DATAREGION' || fieldName == 'SOURCESYS') {
                        var intertype = objrecord.get('INTER_TYPE') || '';
                        var dataregion = objrecord.get('DATAREGION') || '';
                        var sourcesys = objrecord.get('SOURCESYS') || '';
                        var fullID = intertype + objrecord.get('BASENO') + dataregion + sourcesys;
                        objrecord.set('FULLINTERCODE', fullID);
                        $('#baseInfoForm #FULLINTERCODE').val(fullID);
                    }
                    if (fieldName == 'DATAREGION' && newVal == 'B') {
                        $('#baseInfoForm #FILE_START_ROW').val(0);
                    }
                    if (fieldName == 'FILENUM' || fieldName == 'FILESIZE') {
                        if (isNaN(newVal)) {
                            $('#baseInfoForm #' + fieldName).val('');
                            alert("不能为数字!!");
                        }
                    }
                    if (fieldName == 'HIVE_LOAD' && newVal == 0) {
                        objrecord.set('TARGET_TABLE', 'NoTable');
                    }
                    if (fieldName == 'UNITJUDGE' || fieldName == 'FILEJUDGE') {
                        objrecord.set(fieldName, newVal);
                        if (objrecord.get('UNITJUDGE') == 'chkFile' || objrecord.get('FILEJUDGE') == 'okFile') {
                            $('#baseInfoForm input[name="chk"]').prop('checked', false).parent().addClass('hide');
                            $('#baseInfoForm input[name="ok"]').prop('checked', false).parent().addClass('hide');
                        } else {
                            $('#baseInfoForm input[name="chk"]').parent().removeClass('hide');
                            $('#baseInfoForm input[name="ok"]').parent().removeClass('hide');
                        }
                    }
                    console.log(newVal);
                },
                items: formItems
            });
            var from = new AI.Form(formcfg);
        },
        init: function() {
            var OBJTYPE = paramMap.OBJTYPE || 'INTER';
            /*加载对象的元模型*/
            this.metaInfo = this.getMetaInfo(OBJTYPE);
            /*初始化对象基本信息*/
            this.getBaseInfo(this.metaInfo.root[0].objinfo, this.metaInfo.root[1].objattr);
        }
    },
    editInterMeatInfoFun: function() {
        return this.editInterMeatInfo;
    },
    addInterEvent: function() {
        var actType = paramMap.ACTTYPE || "edit";

        function checkInputForm() {
            var result = true;
            var r = metaActionController.editInterMeatInfo.objStore.curRecord;
            var attrArray = metaActionController.editInterMeatInfo.metaInfo.root[1].objattr;

            for (var i = 0; i < attrArray.length; i++) {
                var attr = attrArray[i];
                if (attr.isnull == 'N') {
                    if (!r.get(attr.attrname)) {
                        alert(attr.attrcnname + "不允许为空");
                        result = false;
                        break;
                    } else if (attr.length && r.get(attr.attrname).length > attr.length) {
                        alert(attr.attrcnname + "长度超出！");
                        result = false;
                        break;
                    }
                }
            };
            return result;
        };
        var wizcontentmodel = '<iframe id="{contentid}" src="" width="100%" height="600" frameborder="0" border="0" marginwidth="0" marginheight="0"></iframe>';
        var wiz = new AI.Wizard({
            containerId: 'test',
            id: 'myWizard',
            items: [{
                label: '基本信息',
                content: '<div class="baseformscroll" id="baseInfoForm"></div>',
                previous: function() {},
                next: function() {
                    var r = metaActionController.editInterMeatInfo.objStore.curRecord;
                    if (checkInputForm()) {
                        if (actType = "readOnly") {
                            metaActionController.editInterMeatInfo.objStore.commit();
                            if (r.get('TARGET_TABLE')) {
                                var fileSource = (r.get('FILENAMEFILTER') ? r.get('FILENAMEFILTER') : '') + '*';
                                var extendNames = r.get('EXTENDNAME') != null ? r.get('EXTENDNAME').split(',') : [];
                                if (extendNames.length > 0) {
                                    fileSource += extendNames[0];
                                }
                                ai.executeSQL("delete from transdatamap_design where transname = '" + r.get('FULLINTERCODE') + "'");
                                var _sql = "INSERT INTO transdatamap_design(xmlid,transname,source,sourcetype,sourcefreq,target,targettype,targetfreq)" + " values ('" + ai.guid() + "','" + r.get('FULLINTERCODE') + "','" + fileSource + "','FILE','" + r.get('INTER_CYCLE') + "-0','" + r.get('FULLINTERCODE') + "','INTER','" + r.get('INTER_CYCLE') + "-0')";
                                ai.executeSQL(_sql);
                                var targetTabs = r.get('TARGET_TABLE').split(',');
                                for (var i = 0; i < targetTabs.length; i++) {
                                    _sql = "INSERT INTO transdatamap_design(xmlid,transname,source,sourcetype,sourcefreq,target,targettype,targetfreq)" + " select '" + ai.guid() + "','" + r.get('FULLINTERCODE') + "','" + r.get('FULLINTERCODE') + "','INTER','" + r.get('INTER_CYCLE') + "-0',xmlid,'DATA','" + r.get('INTER_CYCLE') + "-0' from tablefile where dataname = '" + targetTabs[i] + "'";
                                    ai.executeSQL(_sql);
                                }

                            }
                        }
                        $("#testfram").attr("src", "/" + contextPath + "/sysmgr/asiainfo/ProcGraph/procTestGraph.html?FULLINTERCODE=" + r.get('FULLINTERCODE') + "&PROCNAME=inter_test_flow&METAPRJ=");
                        var targetTab = metaActionController.editInterMeatInfo.objStore.curRecord.get('TARGET_TABLE');
                        $("#queryForm").attr("src", "/" + contextPath + "/meta/queryEdit.html?DBNAME=hive2&TAB_NAME=" + targetTab + "&ACTTYPE=" + actType);
                    } else {
                        return false;
                    }
                }
            }, {
                label: '数据查询',
                content: wizcontentmodel.replace('{contentid}', 'queryForm'),
                previous: function() {},
                next: function() {
                    var r = metaActionController.editInterMeatInfo.objStore.curRecord;
                    $("#uplinefram").attr("src", "/" + contextPath + "/devmgr/InterOnline.html?OBJNAME=" + r.get('FULLINTERCODE') + "&ACTTYPE=" + actType);
                }
            }, {
                label: '上线',
                content: wizcontentmodel.replace('{contentid}', 'uplinefram'),
                previous: function() {},
                next: function() {}
            }]
        });
        if (actType == "readOnly"&&_UserInfo.username != 'sys') {
            $("#plus-btn").hide();
            $(".glyphicon-trash").hide();
            $(".input-group").removeAttr("style").attr("style", "width:220px");
            $(".glyphicon-edit").hide();
            $("button").not(".btn-prev").not(".btn-next").attr("disabled", "disabled");
        }
    },
    editDataMeatInfo: {
        objStore: {},
        metaInfo: null,
        getBaseInfo: function(metaInfo, attrArray) {
            var Global = {};
            if (window.parent) Global = window.parent.Global;
            var OBJTYPE = paramMap.OBJTYPE || 'INTER';
            var OPTTYPE = paramMap.OPTTYPE || '';
            var OBJNAME = paramMap.OBJNAME || '';
            if (OBJNAME && OBJTYPE == 'INTER' && OBJNAME.indexOf(".") > 0) {
                OBJTYPE = 'TAB';
            };
            var OBJCNNAME = paramMap.OBJCNNAME || '';
            var METAPRJ = paramMap.METAPRJ || "";
            var _METAPRJ = METAPRJ ? "_" + METAPRJ : "";
            var TEAMCODE = paramMap.TEAM_CODE || "";
            var actType = paramMap.ACTTYPE || "edit";
            this.objStore = new AI.JsonStore({
                sql: "select * from " + metaInfo.tabname + " where " + metaInfo.keyfield + "='" + OBJNAME + "'",
                table: metaInfo.tabname,
                secondTable: "METAOBJ",
                loadDataWhenInit: true,
                key: metaInfo.keyfield
            });

            this.objStore.on("beforecommit", function() {
                for (var i = 0; i < metaActionController.editDataMeatInfo.objStore.getCount(); i++) {
                    var r = metaActionController.editDataMeatInfo.objStore.getAt(i);
                    r.set('OBJNAME', r.get('FLOWCODE'));
                    r.set('OBJCNNAME', r.get('FLOWNAME'));
                    r.set('TOPICNAME', r.get('TOPICNAME'));
                };
                return true;
            });
            if (this.objStore.getCount() == 0) {
                actType = "add";
                this.objrecord = this.objStore.getNewRecord();

                for (var key in paramMap) {
                    this.objrecord.set(key.toUpperCase(), paramMap[key]);
                };
                for (var key in Global) {
                    if (typeof Global[key] != 'object' && key != 'objtype')
                        this.objrecord.set(key.toUpperCase(), Global[key]);

                };

                if (OBJNAME && OBJNAME.length > 0) this.objrecord.set(metaInfo.keyfield, OBJNAME);
                if (OBJCNNAME && OBJCNNAME.length > 0) this.objrecord.set(metaInfo.nameField, OBJCNNAME);

                this.objrecord.set('XMLID', ai.guid());
                this.objrecord.set('CREATER', _UserInfo['username']);
                this.objrecord.set('EFF_DATE', new Date());
                this.objrecord.set('STATE', 'UNPUBLISH');
                this.objrecord.set('STATE_DATE', new Date());
                this.objrecord.set('CURDUTYER', _UserInfo['username']);
                this.objrecord.set('VERSEQ', 1);
                this.objrecord.set('OBJTYPE', OBJTYPE);
                this.objStore.add(this.objrecord);
            } else {
                this.objrecord = this.objStore.getAt(0);
                // actType = ai.checkAct(this.objrecord.get('CURDUTYER'), this.objrecord.get('XMLID'), metaInfo.tabname) ? 'readOnly' : actType;
                actType = ai.checkCurdutyer(this.objrecord.get('CURDUTYER')) ?actType:'readOnly';
                if (_UserInfo.username == 'sys') actType = 'edit';
            }

            var formItems = [];
            for (var i = 0; i < attrArray.length; i++) {
                var attrItem = attrArray[i];
                defaultwidth = 220;
                if (attrItem.inputtype == 'textarea') defaultwidth = 420;
                if (attrItem.inputtype == 'pick-grid') defaultwidth = 320;
                if (attrItem.inputtype == 'check') attrItem.inputtype = 'checkbox';
                if (attrItem.inputtype == 'combo') attrItem.inputtype = 'combox';
                if (attrItem.inputtype == 'label') continue; //attrItem.inputtype='html';
                if (!attrItem.inputtype) attrItem.inputtype = 'text';
                var readonly = "";
                if (attrItem.attrcnname == "" || attrItem.attrcnname == null) continue;
                if (attrItem.inputpara && attrItem.inputpara.length > 0) {
                    attrItem.inputpara = attrItem.inputpara.replace(/{team_code}/g, TEAMCODE).replace('{username}', _UserInfo['username']);
                }

                if (attrItem.attrname == 'FLOWCODE' && actType == 'edit') {
                    readonly = 'y';
                } else if (attrItem.attrname == 'FLOWCODE' && actType == 'add') {
                    readonly = 'n';
                }
                if (actType == "readOnly") {
                    readonly = 'y';
                }
                var formItem = {
                    type: attrItem.inputtype || 'text',
                    label: attrItem.attrcnname,
                    notNull: attrItem.isnull || 'Y',
                    isReadOnly: readonly,
                    storesql: attrItem.inputpara,
                    fieldName: attrItem.attrname,
                    width: defaultwidth,
                    tip: attrItem.remark,
                    editable:'N',
                    dependencies: attrItem.dependencies,
                    checkItems: attrItem.checkitems
                };

                
                if(attrItem.attrname == 'LEVEL_VAL'){
                      //查询是否开启自定义层次和主题的开关
                var define_switch=new AI.JsonStore({
                    sql:"SELECT OBJTYPE,ATTRNAME,ATTRCNNAME FROM metaobjcfg WHERE OBJTYPE='DEFINE_SWITCH'",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAOBJCFG",          //新增修改删除表的名称，注意要大写
                    key:"OBJTYPE"
                });

                var ifSwitch=false;
                if(define_switch.getCount()>0){
                   var ret=define_switch.getAt(0);
                   if(ret.get("ATTRNAME")=='0'){
                      ifSwitch=true;
                   }
                }

                //查询自定义表中是否有该租户的数据
            var table_switch;
            if(actType=='add'&&ifSwitch){
                table_switch=new AI.JsonStore({
                    sql:"SELECT DIMCODE,ROWCODE FROM metaedimdef_define WHERE dimcode='DIM_DATALEVEL' AND team_code ='"+TEAMCODE+"' AND rowcode IS NOT NULL",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAEDIMDEF_DEFINE",          //新增修改删除表的名称，注意要大写
                    key:"DIMCODE"
                });
            }

            //查询该数据是否是开关开启后添加的数据
            var data_switch;
            if(actType=='edit'&&ifSwitch){
                var rowcodeRet = this.objrecord.get('LEVEL_VAL');
                data_switch=new AI.JsonStore({
                    sql:"SELECT DIMCODE,ROWCODE FROM metaedimdef_define WHERE dimcode='DIM_DATALEVEL' AND team_code ='"+TEAMCODE+"' AND rowcode='"+rowcodeRet+"'",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAEDIMDEF_DEFINE",          //新增修改删除表的名称，注意要大写
                    key:"DIMCODE"
                });
            }

            var retSql2="";
             if(ifSwitch){
                 //自定义开关开启
                 if(actType=='edit'){
                    //编辑操作
                   if(data_switch.getCount()>0){
                      //该数据是开关开启后添加的数据
                      retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='"+TEAMCODE+"'";
                   }else{
                      //该数据是开关关闭时添加的数据
                      retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')";
                   }
                 }else if(actType=='add'){
                    //添加操作
                     if(table_switch.getCount()>0){
                       //如果该租户有自定义层次
                       retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='"+TEAMCODE+"'";
                     }else{
                       //如果该租户没有自定义层次
                       retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='S0001'" ;
                     }
                 }else if(actType=='readOnly'){
                    retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')";
                 }
             }else{
                //自定义开关关闭
                retSql2="SELECT ROWCODE,ROWNAME FROM METAEDIMDEF WHERE dimcode='DIM_DATALEVEL'";
             }

                   formItem = {
                    fieldset:attrItem.attrgroup,
                    type: attrItem.inputtype || 'text',
                    label: attrItem.attrcnname,
                    notNull: attrItem.isnull || 'Y',
                    storesql:retSql2,
                    /*ifSwitch?actType=='edit'?
                    data_switch.getCount()>0?"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='"+TEAMCODE+"'":"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')"
                    :table_switch.getCount()>0?"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='"+TEAMCODE+"'":"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF_DEFINE WHERE dimcode='DIM_DATALEVEL' AND TEAM_CODE='S0001'" 
                    :"SELECT ROWCODE,ROWNAME FROM METAEDIMDEF WHERE dimcode='DIM_DATALEVEL'",*/
                    
                    isReadOnly: attrItem.readOnly || '',
                    fieldName: attrItem.attrname,
                    width: defaultwidth,
                    tip: attrItem.remark,
                    editable:'N',
                    dependencies: attrItem.dependencies,
                    checkItems: attrItem.checkitems
                };
                }

                if (attrItem.attrname == 'TOPICNAME') {
                    //查询是否开启自定义层次和主题的开关
                var define_switch=new AI.JsonStore({
                    sql:"SELECT OBJTYPE,ATTRNAME,ATTRCNNAME FROM metaobjcfg WHERE OBJTYPE='DEFINE_SWITCH'",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAOBJCFG",          //新增修改删除表的名称，注意要大写
                    key:"OBJTYPE"
                });

                var ifSwitch=false;
                if(define_switch.getCount()>0){
                    var ret=define_switch.getAt(0);
                   if(ret.get("ATTRNAME")=='0'){
                      ifSwitch=true;
                   }
                }

            //查询自定义表中是否有数据
            var table_switch;
            if(actType=='add'&&ifSwitch){
                table_switch=new AI.JsonStore({
                    sql:"SELECT DIMCODE,rowcode FROM metaedimdef_define WHERE dimcode='DIM_TOPIC' AND team_code ='"+TEAMCODE+"' AND rowcode IS NOT NULL",      //store查询的sql语句
                    dataSource:"METADB",       //数据源，对应一个数据库
                    table:"METAEDIMDEF_DEFINE",          //新增修改删除表的名称，注意要大写
                    key:"DIMCODE"
                });
            }
                //查询该数据是否是开关开启后添加的数据
                var data_switch;
                if(actType=='edit'&&ifSwitch){
                    var rowcodeRet2 = this.objrecord.get('TOPICNAME');
                    var rets;
                    if(rowcodeRet2!=null){
                       rets=rowcodeRet2.split('|');
                    }else{
                       rets=['undefined'];
                    }
                    data_switch=new AI.JsonStore({
                       sql:"SELECT DIMCODE,ROWCODE FROM metaedimdef_define WHERE dimcode='DIM_TOPIC' AND team_code ='"+TEAMCODE+"' AND rowcode='"+rets[0]+"'",      //store查询的sql语句
                       dataSource:"METADB",       //数据源，对应一个数据库
                       table:"METAEDIMDEF_DEFINE",          //新增修改删除表的名称，注意要大写
                       key:"DIMCODE"
                     });
                }

                var retSql=[];
                if(ifSwitch){
                //自定义主题开关开启
                   if(actType=='edit'){
                    //编辑操作
                     if(data_switch.getCount()>0){
                        //该数据是开关开启后添加的数据
                        retSql=[
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='"+TEAMCODE+"'",
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'",
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'"
                        ];
                     }else{
                        //该数据是开关关闭时添加的数据
                        retSql=[
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')"
                        ];
                     }
                   }else if(actType=='add'){
                    //添加操作
                    if(table_switch.getCount()>0){
                      //该租户有自定义的主题
                      retSql=[
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='"+TEAMCODE+"'",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'"
                      ];
                    }else{
                      //该租户没有自定义的主题
                      retSql=[
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='S0001'",
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='S0001'",
                        "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='S0001'"
                      ];
                    }
                   }else if(actType=='readOnly'){
                       retSql=[
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         "select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')"
                        ];
                   }
                }else{
                //自定义主题开关关闭
                    retSql=["select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC'", "select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}'", "select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}'"
                        ];
                }

                    formItem = {
                        type: 'mulitLevel',
                        label: attrItem.attrcnname,
                        notNull: 'Y',
                        fieldName: attrItem.attrname,
                        levelSqls:retSql,
                        /*ifSwitch?actType=='edit'?
                        [data_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         data_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')",
                         data_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE IN ('S0001','"+TEAMCODE+"')"]
                        :[table_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC' AND TEAM_CODE ='S0001'",
                         table_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='S0001'",
                         table_switch.getCount()>0?"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='"+TEAMCODE+"'":"select ROWCODE,ROWNAME from metaedimdef_define where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}' AND TEAM_CODE ='S0001'"                          
                        ]:["select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='HBTOPIC'", "select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}'", "select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_TOPIC' and PARENTCODE='{parentcode}'"
                        ],*/
                        isReadOnly: readonly,
                        editable:'N'
                    };
                }
                formItems.push(formItem);
            };

            var formcfg = ({
                id: 'baseInfoForm',
                store: this.objStore,
                containerId: 'baseInfoForm',
                fieldChange: function(fieldName, newVal) {
                    if (fieldName === 'FLOWCODE' && actType == "add") {
                        if(ai.getStoreData("select XMLID from transflow where XMLID = '"+r.get('XMLID')+"' and FLOWCODE = '"+newVal+"'")[0]){
                        }else if (meta.checkObjExists('DATAFLOW', newVal, '') == true) {
                            alert("数据流编号:" + newVal + ",已经存在!!!");
                            $('#baseInfoForm #FLOWCODE').val('');
                            metaActionController.editDataMeatInfo.objrecord.set(fieldName, '');
                        };
                    }
                    metaActionController.editDataMeatInfo.objrecord.set(fieldName, newVal);
                },
                items: formItems
            });
            var from = new AI.Form(formcfg);
        },
        /*取元模型信息和表对象信息*/
        getMetaInfo: function(objtype) {

            /*相关表:METAOBJINFO:基本信息配置表,属性配置表:METAOBJCFG*/
            var sendObj = {
                paras: [{
                    paraname: "objinfo",
                    paratype: "map",
                    sql: "select OBJTYPE, OBJCODE, OBJNAME, ORDSEQ, REMARK, TABNAME,  RULETAB, KEYFIELD, NAMEFIELD, LOGTAB, TIMEFIELD, RUNTABNAME,  DETAILURL, RUNURL from DQOBJMODEL where objtype='" + objtype + "'"
                }, {
                    paraname: "objattr",
                    paratype: "array",
                    sql: "select OBJTYPE, ATTRGROUP, ATTRNAME, ATTRCNNAME, INPUTTYPE,INPUTPARA, ISNULL, SELVAL, SELMODEL, SEQ, REMARK, DEPENDENCIES, CHECKITEMS from METAOBJCFG where objtype='" + objtype + "' order by ATTRGROUP,SEQ "
                }]
            };
            var URL = '/' + contextUrl + '/olapquery?json=' + ai.encode(sendObj);
            var obj = ai.remoteData(URL);
            return obj;
        },
        init: function() {
            var OBJTYPE = paramMap.OBJTYPE || 'DATAFLOW';
            /* 加载对象的元模型 */
            this.metaInfo = this.getMetaInfo(OBJTYPE);
            /* 初始化对象基本信息 */
            this.getBaseInfo(this.metaInfo.root[0].objinfo,
                this.metaInfo.root[1].objattr);
        }
    },
    /*初始化页面信息*/
    editDataMeatInfoFun: function() {
        return this.editDataMeatInfo;
    },
    /*添加html元素和绑定事件*/
    addDataEvent: function() {
        var actType = paramMap.ACTTYPE || "edit";
        var wizcontentmodel = '<iframe id="{contentid}" src="" width="100%" height="600" frameborder="0" border="0" marginwidth="0" marginheight="0"></iframe>';
        var wiz = new AI.Wizard({
            containerId: 'test',
            id: 'myWizard',
            items: [{
                label: '基本信息',
                content: '<div class="" id="baseInfoForm"></div><button id="save-table-info" type="button" class="btn btn-sm btn-success" style="margin-left: 230px"><i class="glyphicon glyphicon-eye-open"></i>保存</button>',
                previous: function() {},
                next: function() {
                    var r = metaActionController.editDataMeatInfo.objStore.curRecord;
                    metaActionController.editDataMeatInfo.objrecord.set('CRON_EXP', $("#CRON_EXP").val());
                    if (checkInputForm()) {
                        metaActionController.editDataMeatInfo.objStore.commit();
                        $("#dataFlowDesign").attr("src", "/" + contextPath + "/ftl/task/flowchar/dataFlowGraph?CYCLETYPE=" + r.get('CYCLETYPE') + "&FLOWCODE=" + r.get('FLOWCODE'));
                    } else {
                        return false;
                    }
                }
            }, {
                label: '流程设计',
                content: wizcontentmodel.replace('{contentid}', 'dataFlowDesign'),
                previous: function() {},
                next: function() {}
            }]
        });

        function checkInputForm() {
            var result = true;
            var r = metaActionController.editDataMeatInfo.objStore.curRecord;
            var attrArray = metaActionController.editDataMeatInfo.metaInfo.root[1].objattr;
            for (var i = 0; i < attrArray.length; i++) {
                var attr = attrArray[i];
                if (attr.isnull == 'N') {
                    if (!r.get(attr.attrname)) {
                        alert(attr.attrcnname + "不允许为空");
                        result = false;
                        break;
                    } else if (attr.length && r.get(attr.attrname).length > attr.length) {
                        alert(attr.attrcnname + "长度超出！");
                        result = false;
                        break;
                    }
                }
            };
            return result;
        };

        function showDailog() {
            var iWidth = 650; //弹出窗口的宽度;
            var iHeight = 400; //弹出窗口的高度;
            var iTop = (window.screen.availHeight - 30 - iHeight) / 2; //获得窗口的垂直位置;
            var iLeft = (window.screen.availWidth - 10 - iWidth) / 2; //获得窗口的水平位置;
            var defaultVal = document.getElementById('CRON_EXP').value;
            var url = "/" + contextPath + "/devmgr/Cron/cron.html?freq=" + metaActionController.editDataMeatInfo.objrecord.get("CYCLETYPE") + "&cron=" + defaultVal + "&cron_id=" + 'CRON_EXP';
            var _window = window.open(url, '', 'height=' + iHeight + ',innerHeight=' + iHeight + ',width=' + iWidth + ',innerWidth=' + iWidth + ',top=' + iTop + ',left=' + iLeft + ',toolbar=no,menubar=no,scrollbars=auto,resizeable=no,location=no,status=no');
            window.onclick = function() {
                _window.focus();
            };
        }
        $("#save-table-info").click(function() {
            if (checkInputForm()) {
                var rs = metaActionController.editDataMeatInfo.objStore.commit(true);
                var rsJson = $.parseJSON(rs);
                alert(rsJson.msg);
            }
        });
        $("#CRON_EXP_1").click(function() {
            showDailog();
        });
        if (actType == "readOnly"&&_UserInfo.username != 'sys') {
            $("button").not(".btn-prev").not(".btn-next").attr("disabled", "disabled");
            $("#save-table-info").hide();
            $("select").attr("disabled", "disabled");
        }
    },
        /*跳转到创建指标页面*/
    createZB: function() {
        window.open(contextPath + "/devmgr/WizCreZB.html?TEAM_CODE=" + paramMap.TEAM_CODE + "&USERROLE=" + paramMap.USERROLE + "&OBJNAME=" + paramMap.OBJNAME);
    },
    /*基本信息*/
    editZBMeatInfo: {
        objStore: {},
        objrecord: {},
        attrArray: {},
        metadb: {},
        formItems: [],
        applyZBSql: function(OBJNAME, TEAMCODE) {
            var applyTableSql = "SELECT * FROM stat_zb_def a {condi} a.XMLID='" + OBJNAME + "'";
            if (TEAMCODE && TEAMCODE.length > 0) {
                applyTableSql = applyTableSql.replace("{condi}", ("WHERE a.TEAM_CODE='" + TEAMCODE + "' AND "));
            } else {
                applyTableSql = applyTableSql.replace('{condi}', ' where ');
            }
            return applyTableSql;
        },
        getMetaInfo: function(objtype) { ////取元模型信息和表对象信息
            ///相关表:METAOBJINFO:基本信息配置表,属性配置表:METAOBJCFG,
            var objattrsql = "select OBJTYPE, ATTRGROUP, ATTRNAME, ATTRCNNAME, INPUTTYPE,INPUTPARA, ISNULL, SELVAL, SELMODEL, SEQ, REMARK,DEPENDENCIES,CHECKITEMS from METAOBJCFG where objtype='" + objtype + "' {condi} order by ATTRGROUP,SEQ ";
            var ATTRGROUPTYPE = ai.getStoreData("select CONTENT from infopermission where  OBJTYPE = 'ZB' and GROUPCODE = '"+_UserInfo.groupCode+"'");
            var condi = '';
            if(!ATTRGROUPTYPE){
                objattrsql=objattrsql.replace('{condi}','');//不需要分权限展示信息的情况，没有infopermission表
            }else if(_UserInfo.username == 'sys'||paramMap.ACTTYPE=='add'){
                objattrsql=objattrsql.replace('{condi}','');
            }else{
                for(var i=0;i<ATTRGROUPTYPE.length;i++){
                    condi+=" ATTRGROUP = '"+ATTRGROUPTYPE[i]["CONTENT"]+"' or ";
                }
                condi="and ("+condi+" 1=2)";
                objattrsql=objattrsql.replace('{condi}',condi);
            }
            var sendObj = {
                paras: [{
                    paraname: "objinfo",
                    paratype: "map",
                    sql: "select OBJTYPE, OBJCODE, OBJNAME, ORDSEQ, REMARK, TABNAME,  RULETAB, KEYFIELD, NAMEFIELD, LOGTAB, TIMEFIELD, RUNTABNAME,  DETAILURL, RUNURL from DQOBJMODEL where objtype='" + objtype + "'"
                }, {
                    paraname: "objattr",
                    paratype: "array",
                    sql: objattrsql
                }, {
                    paraname: "metadb",
                    paratype: "array",
                    sql: "SELECT DBNAME,CNNAME,DRIVERCLASSNAME  FROM metadbcfg"
                }]
            };
            var URL = '/' + contextUrl + '/olapquery?json=' + ai.encode(sendObj);
            var obj = ai.remoteData(URL);
            return obj;
        },
        ////对象基本信息
        baseInfoForm: {},
        // ds_memberTableStore: {},
        refreshForm: function(formElements,USERFIELDSETS) {
            // var group ='';
            // var fieldsetContent=[];
            // var fieldsetitems=[];
            // for(var i=0;i<formElements.length;i++){
            //     if(group!=formElements[i].group){
            //         if(i>1) fieldsetContent.push({legend:formElements[i-1].group,items:fieldsetitems});
            //         fieldsetitems = [];
            //         group=formElements[i].group;
            //         fieldsetitems.push(formElements[i]);
            //     }else{
            //         fieldsetitems.push(formElements[i]);
            //         if(i==formElements.length-1){
            //             fieldsetContent.push({legend:formElements[i].group,items:fieldsetitems});
            //             fieldsetitems = [];
            //         }
            //     }
            // }
            var formcfg = ({
                id: 'baseInfoForm',
                store: metaActionController.editZBMeatInfo.objStore,
                fieldsets:USERFIELDSETS&&USERFIELDSETS==true?formElements:null,
                items:USERFIELDSETS&&USERFIELDSETS==true?null:formElements,
                containerId: 'baseInfoForm',
                fieldChange: function(fieldName, newVal) {
                    if (fieldName === 'ZB_CODE') {} else {
                        metaActionController.editZBMeatInfo.objrecord.set(fieldName.toUpperCase(), newVal);
                    }
                    if(fieldName == 'SOURCE'){
                    	var targetZbCode = ai.getNewCode('','ZB_CODE',newVal,'STAT_ZB_DEF');
                    	$('#baseInfoForm #ZB_CODE').val(targetZbCode);
                    	metaActionController.editZBMeatInfo.objrecord.set('ZB_CODE', targetZbCode);
                    }
                },
                // items: formElements
            });
            $('#baseInfoForm').empty();
            var from = new AI.Form(formcfg);
            return from;
        },
        init: function() {
            var USERFIELDSETS = true; //是否启用fieldsets分组
            metaActionController.editZBMeatInfo.USERFIELDSETS = USERFIELDSETS;
            var OBJTYPE = paramMap.OBJTYPE || 'ZB';
            var OPTTYPE = paramMap.OPTTYPE || '';
            var OBJNAME = paramMap.OBJNAME || '';
            var OBJCNNAME = paramMap.OBJCNNAME || '';
            var METAPRJ = paramMap.METAPRJ || "";
            var _METAPRJ = METAPRJ ? "_" + METAPRJ : "";
            var xmlid = '';
            var TEAMCODE = paramMap.TEAM_CODE || "";
            var actType = paramMap.ACTTYPE || "edit";
            var curRole = paramMap.USERROLE || '';
            var _dbtype = '';
            var groupType = paramMap.GROUPTYPE || '';
            var metaBaseInfo = this.getMetaInfo(OBJTYPE);
            var metaInfo = metaBaseInfo.root[0].objinfo;
            this.attrArray = metaBaseInfo.root[1].objattr;
            metaActionController.editZBMeatInfo.metadb = metaBaseInfo.root[2].metadb;
            metaActionController.editZBMeatInfo.objStore = new AI.JsonStore({
                sql: "select * from " + metaInfo.tabname + " where " + metaInfo.keyfield + "='" + OBJNAME + "'",
                table: metaInfo.tabname,
                secondTable: "METAOBJ",
                loadDataWhenInit: true,
                key: metaInfo.keyfield
            });
            metaActionController.editZBMeatInfo.objStore.on("beforecommit", function() {
                for (var i = 0; i < metaActionController.editZBMeatInfo.objStore.getCount(); i++) {
                    var r = metaActionController.editZBMeatInfo.objStore.getAt(i);
                    r.set('OBJNAME', r.get('ZB_CODE'));
                    r.set('OBJCNNAME', r.get(metaInfo.namefield));
                };
                return true;
            });
            if (metaActionController.editZBMeatInfo.objStore.getCount() == 0) {
                actType = "add";
                metaActionController.editZBMeatInfo.objrecord = metaActionController.editZBMeatInfo.objStore.getNewRecord();
                for (var key in paramMap) {
                    metaActionController.editZBMeatInfo.objrecord.set(key.toUpperCase(), paramMap[key]);
                };
                for (var key in Global){
                    if (typeof Global[key] != 'object' && key != 'objtype')
                        metaActionController.editZBMeatInfo.objrecord.set(key.toUpperCase(), Global[key]);
                };
                metaActionController.editZBMeatInfo.objrecord.set('XMLID', ai.guid());
                xmlid = metaActionController.editZBMeatInfo.objrecord.get('XMLID');
                OBJNAME = metaActionController.editZBMeatInfo.objrecord.get('XMLID');
                metaActionController.editZBMeatInfo.objrecord.set('TEAM_CODE', TEAMCODE);
                metaActionController.editZBMeatInfo.objrecord.set('AUDITER', _UserInfo['username']);
                metaActionController.editZBMeatInfo.objrecord.set('EFF_DATE', new Date());
                metaActionController.editZBMeatInfo.objrecord.set('STATE', '新建');
                metaActionController.editZBMeatInfo.objrecord.set('STATE_DATE', new Date());
                metaActionController.editZBMeatInfo.objrecord.set('CURDUTYER', _UserInfo['username']);
                metaActionController.editZBMeatInfo.objrecord.set('VERSEQ', 1);
                metaActionController.editZBMeatInfo.objrecord.set('OBJTYPE', OBJTYPE);
                metaActionController.editZBMeatInfo.objrecord.set(metaInfo.nameField, OBJCNNAME);
                metaActionController.editZBMeatInfo.objStore.add(metaActionController.editZBMeatInfo.objrecord);
            } else {
                metaActionController.editZBMeatInfo.objrecord = metaActionController.editZBMeatInfo.objStore.getAt(0);
                xmlid = metaActionController.editZBMeatInfo.objrecord.get('XMLID');
                actType = ai.checkAct(metaActionController.editZBMeatInfo.objrecord.get('CURDUTYER'), xmlid, metaInfo.tabname) ? actType : 'readOnly';
                if (_UserInfo.username == 'sys') actType = 'edit';
            }
            for (var i = 0; i < metaActionController.editZBMeatInfo.metadb.length; i++) {
                if (metaActionController.editZBMeatInfo.metadb[i]['dbname'] === metaActionController.editZBMeatInfo.objrecord.get('DBNAME')) {
                    _dbtype = metaActionController.editZBMeatInfo.metadb[i]['driverclassname'];
                }
            }

            for (var i = 0; i < this.attrArray.length; i++) {
                var attrItem = this.attrArray[i];
                defaultwidth = 220;
                if (attrItem.inputtype == 'textarea') defaultwidth = 420;
                if (attrItem.inputtype == 'pick-grid') defaultwidth = 320;
                if (attrItem.inputtype == 'check') attrItem.inputtype = 'checkbox';
                if (attrItem.inputtype == 'combo') attrItem.inputtype = 'combox';
                if (attrItem.inputtype == 'label') continue; //attrItem.inputtype='html';
                if (!attrItem.inputtype) attrItem.inputtype = 'text';
                if (actType == "readOnly") attrItem.readOnly = 'y';
                if (_UserInfo.username == 'sys') attrItem.readOnly = 'n';
                if (attrItem.inputpara && attrItem.inputpara.length > 0) {
                    attrItem.inputpara = attrItem.inputpara.replace(/{team_code}/g, TEAMCODE);
                }
                if (attrItem.attrname == 'ZB_CODE') {
                    attrItem.readOnly = 'y';
                }
                var formItem = {
                    fieldset:attrItem.attrgroup ||'...',//fieldsets分组标准
                    type: attrItem.inputtype || 'text',
                    label: attrItem.attrcnname,
                    notNull: attrItem.isnull || 'Y',
                    storesql: attrItem.inputpara,
                    isReadOnly: attrItem.readOnly || '',
                    fieldName: attrItem.attrname,
                    dependencies: attrItem.dependencies,
                    checkItems: attrItem.checkitems,
                    width: defaultwidth,
                    tip: attrItem.remark
                };
                if (attrItem.attrname == 'AREALEVEL') {
                    formItem = {
                        fieldset:attrItem.attrgroup ||'...',
                        type: 'mulitLevel',
                        label: attrItem.attrcnname,
                        notNull: 'N',
                        fieldName: attrItem.attrname,
                        levelSqls: [
                            "select ROWCODE,ROWNAME from metaedimdef where dimcode='DIM_ZB_AREALEVEL' and PARENTCODE='AREALEVEL'", "select ROWCODE,ROWNAME from metaedimdef where PARENTCODE='{parentcode}'", "select ROWCODE,ROWNAME from metaedimdef where PARENTCODE='{parentcode}'"
                        ],
                        isReadOnly: attrItem.readOnly || ''
                    };
                }
                metaActionController.editZBMeatInfo.formItems.push(formItem);
            };
             var fieldSetsFormat = function(items){
                var fieldSetNames="",fieldSets = [],sets={};
                for (var i = 0;i<items.length; i++) {
                    var item = items[i];
                    if(fieldSetNames.indexOf(item['fieldset'])==-1){
                        sets[item['fieldset']] =[];
                        fieldSetNames += item['fieldset'];
                    }
                    sets[item['fieldset']].push(item);
                };
                for (var set in sets) {
                    fieldSets.push({
                        legend:set,
                        items:sets[set]
                    });
                };
                return fieldSets;
            };
            this.baseInfoForm = this.refreshForm(fieldSetsFormat(this.formItems),metaActionController.editZBMeatInfo.USERFIELDSETS);
        }
    },
    editZBMeatInfoFun: function() {
        return this.editZBMeatInfo;
    },
            checkInputForm: function() {
            var result = true;
            var r = metaActionController.editZBMeatInfo.objStore.curRecord;
            for (var i = 0; i < metaActionController.editZBMeatInfo.attrArray.length; i++) {
                var attr = metaActionController.editZBMeatInfo.attrArray[i];
                if (attr.isnull == 'N') {
                    if (!r.get(attr.attrname)) {
                        alert(attr.attrcnname + "不允许为空");
                        result = false;
                        break;
                    } else if (attr.length && r.get(attr.attrname).length > attr.length) {
                        alert(attr.attrcnname + "长度超出！");
                        result = false;
                        break;
                    }
                }
            }
            return result;
        },
    /*创建表格流程事件添加*/
    addZBEvent: function() {
        var self = this;
        var actType = paramMap.ACTTYPE || "edit";
        $('#myWizard').wizard('selectedItem', {
            step: 1
        });
        $('#myWizard').on('actionclicked.fu.wizard', function(event, stepInfo) {
            var r = metaActionController.editZBMeatInfo.objStore.curRecord;
            if (stepInfo.step == 1 && stepInfo.direction == 'next') {
                if (actType != "readOnly") {
                    if (self.checkInputForm() == false) return false;
                    if(ai.getStoreData("select XMLID from stat_zb_def where XMLID = '"+r.get('XMLID')+"' and ZB_CODE = '"+r.get('ZB_CODE')+"'")[0]){
                    }else if (actType == "add" && meta.checkObjExists('ZB', r.get('ZB_CODE'), '') == true) {
                        alert("指标:" + r.get('ZB_CODE') + ",已经存在!!!");
                        return false;
                    };
                metaActionController.editZBMeatInfo.objStore.commit();
                }
                FlowMgr.getflowAct(metaActionController.editZBMeatInfo.objStore,'ZB',"auditaction","funaction");
                $("#dqmgrfram").attr("src", "../dqmgr/MetaDqResult.html?OBJTYPE=ZB&OBJNAME=" +
                    metaActionController.editZBMeatInfo.objStore.curRecord.get('ZB_CODE'));
            }
        });
        $('#save-table-info').on('click', function() {
            if (self.checkInputForm() == true) {
                var zbcode = metaActionController.editZBMeatInfo.objStore.curRecord.data["ZB_CODE"];
                var xmlid = metaActionController.editZBMeatInfo.objStore.curRecord.data["XMLID"];
                if(ai.getStoreData("select XMLID from stat_zb_def where XMLID = '"+xmlid+"' and ZB_CODE = '"+zbcode+"'")[0]){
                }else if (actType == "add"&&meta.checkObjExists('ZB', zbcode,'') == true) {
                    alert("指标:" + zbcode + ",已经存在!!!");
                    return;
                };
                var rs = metaActionController.editZBMeatInfo.objStore.commit(true);
                var rsJson = $.parseJSON(rs);
                alert(rsJson.msg);
            }
        });
        $("#similar-analyze").on('click',function(){
        	var zbName = metaActionController.editZBMeatInfo.objStore.curRecord.data["ZB_NAME"];
        	ai.openDialog("ZBSimilarAnalyze.html?zbName="+zbName,"",zbName+"相似性列表");
        });
        $('#format－sql').on('click', function() {
            var sqlval = meta.prettySql($("#ZB_PROCESS").val());
            $("#ZB_PROCESS").val(sqlval)
        });
        if (actType == "readOnly"&&_UserInfo.username != 'sys') {
            $("button").not(".btn-prev").not(".btn-next").attr("disabled", "disabled");
            $("#save-table-info").hide();
            $("#format－sql").hide();
            $("#similar-analyze").hide();
            $("select").attr("disabled", "disabled");
        }
    }
};