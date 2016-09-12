var _stateIcon = function(value,data,index){
	var st = [
		{'val':-4,'name':'入hive失败','class':'text-danger'}
		,{'val':-3,'name':'加载hdfs失败','class':'text-danger'}
		,{'val':-2,'name':'ok文件校验失败','class':'text-danger'}
		,{'val':-1,'name':'未发现ok文件','class':'text-warning'}
		,{'val':0,'name':'扫描到文件','class':'text-warning'}
		,{'val':1,'name':'加载hdfs成功','class':'text-success'}
		,{'val':2,'name':'入hive成功','class':'text-success'}];
	var _tmpl = '<div>'+
		'<label class="<%=model.class%>" name="<%=model.val%>"><%=model.name%></label>'+
		'</div>';
	return _.template(_tmpl,{"model":st[value+4]});
};
var _stateIcon2 = function(value,data,index){
	var _tmpl =
		'<div class="btn-group '+(index>6?"dropup":"")+'">'+
		'<button type="button" class="btn btn-xs <%=cla%> dropdown-toggle" data-toggle="dropdown">'+
		' <%=name%> <%if(value==1||value==2){%><span class="caret"></span>'+
		'</button>'+
		'<ul class="dropdown-menu" role="menu">'+
		'<%if(value==1){%>'+
		'<li><a  id="redo"  fullintercode="<%=fullintercode%>" batchno="<%=batchno%>">重做当前批次</a></li>'+
		'<li><a  id="conti"  fullintercode="<%=fullintercode%>" batchno="<%=batchno%>">执行后续批次</a></li>'+
		'<%}%>'+
		'<%if(value==2){%>'+
		'<li><a  id="winredo"  fullintercode="<%=fullintercode%>" batchno="<%=batchno%>">重做当前批次</a></li>'+
		'<li><a  id="winconti"  fullintercode="<%=fullintercode%>" batchno="<%=batchno%>">执行后续批次</a></li>'+
		'<%}%>'+
		'<%if(value==3){%>'+
		'<li><a  id="excepredo"  fullintercode="<%=fullintercode%>" batchno="<%=batchno%>">重做当前批次</a></li>'+
		'<li><a  id="excepconti"  fullintercode="<%=fullintercode%>" batchno="<%=batchno%>">执行后续批次</a></li>'+
		'<%}%>'+
		'</ul><%}else{%>'+
		'</button>'+
		'<%}%>'+
		'</div>';
	return _.template(_tmpl,{"cla":_CLASS[value=='--'?3:value],"name":_VALUE[value=='--'?3:value],"value":value,"fullintercode":data.FULLINTERCODE,"batchno":data.BATCH_NO});
};
var _stateIcon3 = function(value,data,index){
	var _tmpl = 
		'<div>'+
		'<%if(value==0){%>'+
		'<label class="label label-default">处理中</label>'+
		'<%}%></div>'+
		'<%if(value==1){%>'+
		'<label class="label label-danger">处理失败</label>'+
		'<%}%></div>'+
		'<%if(value==2){%>'+
		'<label class="label label-success">处理成功</label>'+
		'<%}%></div>'+
		'<%if(value==3){%>'+
		'<label class="label label-primary">处理异常</label>'+
		'<%}%></div>'+
		'<%if(value=="--"){%>'+
		'<label class="label label-warning">等待处理</label>'+
		'<%}%></div>';
	return _.template(_tmpl,{"value":value});
};
var timeFormat = function(val){
	var _d = val?val.toString():'';
	var rs="--";
	if(_d!=null&&_d.length>0){
		rs = _d;
	}
	return rs;
};
var maxLen = function(val){
	var valShorten='';
	if(val.length>15) valShorten = val.slice(0,10)+"...";
	return valShorten;
};
var _unitJudge = function(value,data,index){
	var _tmpl = value;
	if(value =='false'){
			_tmpl ='不启用';
	}else if (value == 'chkFile'){
			_tmpl ='CHK文件校验';
	}
	return 	_.template(_tmpl,{"value":value});
};

//所属域
	var dataregion_sql="SELECT rowcode,rowname FROM metaedimdef WHERE dimcode='DIM_INTERDATAREGION'";
	var dataregion_Store = new AI.JsonStore({
	                sql:dataregion_sql,
	                pageSize:-1
	          });
	var getdataregion = function(val){
		if (!val) return val;
			var dataregion = val;
			for(var k=0;k<dataregion_Store.getCount();k++){
				var rdataregion=dataregion_Store.getAt(k);
				if(rdataregion.get("ROWCODE")==dataregion){
					dataregion=rdataregion.get("ROWNAME");
					break;
				}
			}
			return 	dataregion;
	};
//源系统
	var sourcesys_sql="SELECT rowcode,rowname FROM metaedimdef WHERE dimcode='DIM_INTERSOURCESYS'";
	var sourcesys_Store = new AI.JsonStore({
                sql:sourcesys_sql,
                pageSize:-1
          });
	var getsourcesys = function(val){
		if (!val) return val;
		var sourcesys = val;
		for(var k=0;k<sourcesys_Store.getCount();k++){
			var rsourcesys=sourcesys_Store.getAt(k);
			if(rsourcesys.get("ROWCODE")==sourcesys){
				sourcesys=rsourcesys.get("ROWNAME");
				break;
			}
		}
		return 	sourcesys;
	};
//采集周期
	var intercycle_sql="SELECT rowcode,rowname FROM metaedimdef WHERE dimcode='DIM_INTERINTERCYCLE'";
	var intercycle_Store = new AI.JsonStore({
                sql:intercycle_sql,
                pageSize:-1
          });
	var getintercycle = function(val){
		if (!val) return val;
		var intercycle = val;
		for(var k=0;k<intercycle_Store.getCount();k++){
			var rintercycle=intercycle_Store.getAt(k);
			if(rintercycle.get("ROWCODE")==intercycle){
				intercycle=rintercycle.get("ROWNAME");
				break;
			}
		}
		return 	intercycle;
	};

var getQuerCondi=function(){
	task_state = task_state=="-1"?"0":task_state;
	var fullintercode = $("#fullintercode input").val().trim();
	var _condi = fullintercode&&fullintercode.length>0?(" and (c.fullintercode  like '%"+fullintercode+"%' or c.inter_name like '%"+fullintercode+"%' or c.TARGET_TABLE like '%"+fullintercode+"%')"):"";
	_condi += (task_state&&task_state.length>0&&task_state!="0"?(" and c.inter_cycle='"+task_state+"'"):"");
	var date_args = $("#date_args").val()
	_condi += (date_args&&date_args.trim().length>0?(" and op_time like '"+(date_args.indexOf("-")>0?date_args.replaceAll("-","").replaceAll(" ",""):date_args)+"%'"):"");
	return _condi;
};

var switchContent = function(condi){
	if(!condi||typeof(condi)=="undefined"){
		condi="";
	}
	buildTreeView(_realTreeSql.replace("{condi}",condi));
	_contentStore.config.sql=_realQuerySql.replace("{condi}",condi);
	_contentStore.fetch();
	_totalStore.config.sql = _realTotalSql.replace("{condi}",condi);
	_totalStore.fetch();
};
//统计面板
var _totalPanel = new ve.HtmlWidget({
	config:{
		"className": "html",
		"id": "view_total_up_total_id",
		"template":'<div class="total_line row"><div class="total_run col-sm-2"><div class="total_1 ">接口总体运行概况</div><div class="total_2 "><%=curDate%></div></div>'
			+ '<div class="total_detail col-sm-10">'
			+ '<%_.each(models,function(model,i){%>'
			+ '<div class="detail_<%=i%>"><label class="total_label_<%=i%> detail_label <%if(model.highLight){%>totalhighLight<%}%>" name="<%=i%>"><%=model.num%></label><div><label class="sm-detail <%if(model.highLight){%>totalhighLight<%}%>"><%=model.name%></label></div></div>'
			+ '<%});%>'
			+ '</div></div>',
		"events":{
			afterRender:function(){
				var _view = this;
				_view.$el.css("padding","5px 10px 10px 20px");
				var status=[
					{name:'未生效',val:null,num:0,highLight:false},
					{name:'处理中',val:0,num:0,highLight:false},
					{name:'处理失败',val:1,num:0,highLight:false},
					{name:'处理成功',val:2,num:0,highLight:false}];
				var clock = function(){
					var checkTime = function(val){
						return val<10?("0"+val):val;
					};
					var date = new Date();
			  		var yea = date.getYear()<1900 ? date.getYear()+1900 : date.getYear();
			  		var mon = date.getMonth()+1;
			  		var day = date.getDate();
					var hou = date.getHours();
					var min = date.getMinutes();
					var sec = date.getSeconds();
					mon = checkTime(mon);
					min = checkTime(min);
					sec = checkTime(sec);
					var curDateStr = yea+"."+mon+"."+day+" "+hou+":"+min+":"+sec;
					_.each(_view.store.models,function(model){
						_.each(status,function(s){
							if(s['val']==model.get('CHECK_PUT_STATUS')){
								s['num']=model.get('COUNT');
							}
							if(s['val']==totalSelectoin){
								s['highLight']=true;
							}
						});
					});
					_view.$el.addClass('info-general').empty().append(_.template(_view.config.template,{'curDate':curDateStr,'models':status}));
					
					/**setTimeout(function(){
						clock();
					},500);**/
					_view.$el.find('.detail_label').on('click',function(e){
						var _condi = "";
			  			var _id = $(this).attr("name");
			  			totalSelectoin=status[_id].val;
			  			if(status[_id].val==null){
			  				_condi += " and c.CHECK_PUT_STATUS is null";
			  			}else{
			  				_condi += (" and c.CHECK_PUT_STATUS ='"+status[_id].val+"'");
			  			}
			  			_finalTotalCondi = _condi;
			  			_condi +=getQuerCondi();
			  			switchContent(_condi);
				  	});
				};
				clock();
			}
		}
	}
});
//查询面板
var _queryPanel = new ve.FormWidget({
	config:{
		"className": "form",
		"formClass":"form-inline",
		"id": "view_total_up_total_tab_nav",
		"items": [
			{
				"type":"combox",
				"id":"task_state_select",
				"style": "margin-left:20px;",
				"sql":"SELECT rowcode k,rowname v FROM metaedimdef WHERE dimcode='DIM_INTERINTERCYCLE'"
			},
			{
				"type": "text",
				"id":"fullintercode",
				"fieldLabel":"",
				"style": "width:210px;",
				"placeholder":"请输入接口编号，接口名，接口表名"
			},
			{
				"id":"search",
				"value":"查询",
				"type":"button",
				"className":"search_btn btn-sm btn-primary"
			},
			{
				"id":"switch-mode",
				"value":"",
				"type":"button",
				"className":"search_btn btn-sm btn-primary",
			},
			{
				"id":"refresh-grid",
				"value":"",
				"type":"button",
				"className":"search_btn btn-sm btn-primary"
			},
			{
				"id":"refresh-btn",
				"value":"",
				"type":"button",
				"className":"btn btn-sm btn-primary hide"
			}
		],
		'events': {
			afterRender:function(){
				_viewform = this;
				var _view = this;
				_view.$el.find('form').addClass('form_personal');
				_view.$el.css("padding","0px");
				_view.$el.find("#refresh-grid").empty().append(
					'<div class="btn-group" data-toggle="buttons" style="margin-right: 5px;">'+
					'<label id="m-g" class="btn btn-sm btn-info">'+
					'<input type="radio" name="options">'+
					'<i class="fa fa-check text-active "></i> 实时刷新</label>'+
					'<label id="m-o" class="btn btn-sm btn-success">'+
					'<input type="radio" name="options">'+
					'<i class="fa fa-check text-active"></i> 手动刷新</label>'+
					'</div>');
				_view.$el.find("#refresh-btn button").append('<span class="glyphicon glyphicon-refresh"></span>');
				_view.$el.find("#switch-mode").empty().append(
						'<div class="btn-group" data-toggle="buttons" style="margin-right: 2px;">'+
						'<label id="m-simple" class="btn btn-sm btn-info active">'+
						'<input type="radio" name="options">'+
						'<i class="fa fa-check text-active" ></i>去重</label>'+
						// '<label id="m-all" class="btn btn-sm btn-success">'+
						// '<input type="radio" name="options">'+
						// '<i class="fa fa-check text-active"></i>全量</label>'+
						'</div>'
				);
				var _refresh = function(flag){
					if(flag){
						REFRESHTIMER = setTimeout(function(){
							_finalTotalCondi +=getQuerCondi();
							switchContent(_finalTotalCondi);
							_refresh(true);
						},10000);
					}else{
						clearTimeout(REFRESHTIMER);
					}
				};
				$("#m-g").on("click",function(){
					_view.$el.find("#refresh-btn button").addClass("hide");
					_refresh(true);
				});
				$("#m-o").on("click",function(){
					_view.$el.find("#refresh-btn button").removeClass("hide");
					_refresh(false);
				});
				
				_view.$el.find("#m-all").on("click",function(e){
					searchAct="all";
					$("#date_args").remove();
					$("#task_state_select").append("<input id='date_args' type='text' placeholder='批次号' class='form-control formElement' />")
					_realQuerySql = _finalTotalSql2;
					_realTotalSql = _finalQuerySql2;
					_realTreeSql= _finalTreeSql2;
				});
				_view.$el.find("#m-simple").on("click",function(e){
					searchAct="simple";
					$("#date_args").remove();
					_realQuerySql = _finalQuerySql;
					_realTotalSql = _finalTotalSql;
					_realTreeSql= _finalTreeSql;
			   });
			},
			
			'change #task_state_select select':function(e){
				totalSelectoin="-1";
				task_state = $(e.currentTarget).val();
				switchContent(getQuerCondi());
			},
			'click #search':function(){
				totalSelectoin="-1";
				isDefault=false;
				switchContent(getQuerCondi());
			},
			'click #refresh-btn':function(){
				totalSelectoin="-1";
				_finalTotalCondi +=getQuerCondi();
				switchContent(_finalTotalCondi);
			}
		}
	}	
});	
//显示信息面板
var _grid = new ve.GridWidget({
	config:{
		"className":"grid",
		'showcheck': false,
		'id':'evaluateView_tab_evaluate_middle_down_grid',
		'pageSize':30,
		"header":[
			{"label":"接口编号","dataIndex":"FULLINTERCODE"},
			{"label":"接口名","dataIndex":"INTER_NAME","className":"ai-grid-body-td-left"},
			{"label":"所属域","dataIndex":"DATAREGION",renderer:getdataregion},
			{"label":"采集周期","dataIndex":"INTER_CYCLE",renderer:getintercycle},
			{"label":"源系统","dataIndex":"SOURCESYS","className":"ai-grid-body-td-left",renderer:getsourcesys},
			{"label":"接口表名","dataIndex":"TARGET_TABLE","className":"ai-grid-body-td-left","maxlength":15},
			{"label":"更新时间","dataIndex":"UPDATE_TIME",renderer:timeFormat},
			{"label":"最新批次","dataIndex":"BATCH_NO"},
			{"label":"最新状态","dataIndex":"CHECK_PUT_STATUS",renderer:_stateIcon2},
			{"label":"说明","dataIndex":"REMARK","className":"ai-grid-body-td-left","maxlength":15},
		],
		"events":{
			afterRender:function(){
				this.$el.find(".table-area").css("overflow","visible");
				if(searchAct=="all"){
					this.$el.find(".ai-grid-head-th[dataindex='BATCH_NO']").html(this.$el.find(".ai-grid-head-th[dataindex='BATCH_NO']").html().replace("最新批次","批次"));
					this.$el.find(".ai-grid-head-th[dataindex='CHECK_PUT_STATUS']").html(this.$el.find(".ai-grid-head-th[dataindex='CHECK_PUT_STATUS']").html().replace("最新状态","状态"));
				}
			},
			rowDblClick:function(i,record){
				var $el = parent.$('#panel1');
				_opStore = new ve.SqlStore({
					dataSource:'METADBS',
					sql:"select inter_code fullintercode,op_time BATCH_NO,UPDATE_TIME,CHECK_PUT_STATUS,REMARK,STD_FILE_NUM,REAL_FILE_NUM,STD_FILE_SIZE,REAL_FILE_SIZE from inter_log where inter_code='"+record['FULLINTERCODE']+"' order by op_time desc"
				});
				var tmpl = '';
				if(_opStore.models.length>0){
					tmpl = _.template('<section class="panel panel-default">'
						+ '<header class="panel-heading">接口编号:<%=no%> 脚本运行日志 <span class="hide" id="file-to-batch"> <span id="batch-no"></span> <span class="btn btn-success">返回批次列表</span></span></header> '
						+ '<article class="media">'
						+ '<div class="media-body" >'
						+ '<div id="op-content"></div>'
						+ '<div id="file-content" style="width:1276px;display: none;"></div>'
						+ '</div></article>'
						+'</section>',{'no':record['FULLINTERCODE'],'batch':record['BATCH_NO']});
					$el.off("finishRender").on("finishRender",function(){
						var opGrid = new ve.GridWidget({
							config:{
								"className" : "grid",
								"id":"op-grid",
								"pageSize":20,
								"header":[
									{"label":"批次号","dataIndex":"BATCH_NO"},
									{"label":"更新时间","dataIndex":"UPDATE_TIME",renderer:timeFormat},
									{"label":"最新状态","dataIndex":"CHECK_PUT_STATUS",renderer:_stateIcon2},
									{"label":"说明","dataIndex":"REMARK","className":"ai-grid-body-td-left"},
									{"label":"预计文件数量","dataIndex":"STD_FILE_NUM","className":"ai-grid-body-td-right"},
									{"label":"实际到达数量","dataIndex":"REAL_FILE_NUM","className":"ai-grid-body-td-right"},
									{"label":"预计文件大小","dataIndex":"STD_FILE_SIZE","className":"ai-grid-body-td-right"},
									{"label":"实际到达总量","dataIndex":"REAL_FILE_SIZE","className":"ai-grid-body-td-right"}
								],
								"events":{
									beforeRender:function(){
										opGrid.store = _opStore;
									},
									afterRender:function(){
										this.$el.find(".page-container .pagination").css("margin","0");
									},
									rowDblClick:function(i,record){
										this.$el.hide();
										$el.find('#file-to-batch').removeClass('hide').find('#batch-no').empty().append('批次：'+record['BATCH_NO']);
										var _fileStore = new ve.SqlStore({
											dataSource:'METADBS',
											sql:"SELECT inter_code,inter_file,source_dir,update_time,put_status,hdfs_path,remarks,scan_times,load_time,imp_hive_time FROM inter_file_log where inter_code = '"+record['FULLINTERCODE']+"' and op_time = '"+record['BATCH_NO']+"' and inter_file NOT LIKE '%OK' AND inter_file NOT LIKE '%CHK' order by update_time desc"
										});
										var fileGrid = new ve.GridWidget({
											config:{
												"className" : "grid",
												"id":"relay-grid",
												"pageSize":20,
												"header":[
													{"label":"接口编号","dataIndex":"INTER_CODE","className":"ai-grid-body-td-left"},
													{"label":"文件名称","dataIndex":"INTER_FILE","className":"ai-grid-body-td-left"},
													{"label":"源文件路径","dataIndex":"SOURCE_DIR","className":"ai-grid-body-td-left"},
													{"label":"目标文件路径","dataIndex":"HDFS_PATH","className":"ai-grid-body-td-left"},
													{"label":"处理状态","dataIndex":"PUT_STATUS",renderer:_stateIcon},
													{"label":"扫描时间","dataIndex":"SCAN_TIMES"},
													{"label":"加载hdfs时间","dataIndex":"LOAD_TIME"},
													{"label":"入hive时间","dataIndex":"IMP_HIVE_TIME"},
													{"label":"备注","dataIndex":"REMARKS","className":"ai-grid-body-td-left"}
												],
												"events":{
													beforeRender:function(){
														fileGrid.store = _fileStore;
													},
													afterRender:function(){
														this.$el.find(".page-container .pagination").css("margin","0");
													}
												}
											}
										});
										fileGrid.$el = $el.find('#file-content');
										_fileStore.on("reset",function(){
											fileGrid.render();
											$el.find('#file-content').show();
										});
										_fileStore.fetch();
									},afterTabelBodyRender:function(){
										var _view = this;
										_view.$el.find("a#redo,a#conti,a#winconti,a#excepredo,a#excepconti").on("click",function(e){
											updatebacthno(e);
										});
										_view.$el.find("a#winredo").on("click",function(e){
											deleteinterlog(e);
										});
									}											
								}
							}
						});
						opGrid.$el = $el.find('#op-content');
						_opStore.on("reset",function(){
							opGrid.render();
						});
						_opStore.fetch();
						$el.find('#file-to-batch .btn').on('click',function(){
							$el.find('#op-content').show();
							$el.find('#file-content').hide();
							$el.find('#file-to-batch').addClass('hide')
						});
					});	
				}else{
					tmpl = "找不到日志信息！";
				}
				parent.openTableInfo("log","接口日志信息",tmpl,false);
			},
			afterTabelBodyRender:function(){
				var _view = this;
				_view.$el.find("a#redo,a#conti,a#winconti").on("click",function(e){
					updatebacthno(e);
				});
				_view.$el.find("a#winredo").on("click",function(e){
					deleteinterlog(e);
				});	
			}	
		}
	}
});	
var updatebacthno = function(e){
	var _fullintercode = $(e.currentTarget).attr("fullintercode");
	var _workType = $(e.currentTarget).attr("id");
	var _batchno=$(e.currentTarget).attr("batchno"); 
	var confirmtext ="";
	var remarktext ="";
	var _finalbatchno=_batchno;
	if(_workType=='redo'){
		confirmtext='确定执行当前批次?';
		remarktext ='开始执行当前批次';
	}
	if(_workType =='conti'||_workType=='winconti'){
		_finalbatchno=Number(_batchno)+1;
		confirmtext='确定执行后续批次?';
		remarktext ='开始执行后续批次';
	}
	if(confirm(confirmtext)){
		var finalSql="update inter_cfg  set batch_no='"+_finalbatchno+"',remark='"+remarktext+"' where fullintercode='"+_fullintercode+"'";
		ai.executeSQL(finalSql,false,"METADBS");
		_contentStore.fetch();
		if(_opStore!=null&&_opStore!=''){
			_opStore.fetch();
		}
	}
};
//成功重做
var deleteinterlog = function(e){
	var _fullintercode = $(e.currentTarget).attr("fullintercode");
	var _workType = $(e.currentTarget).attr("id");
	var _batchno=$(e.currentTarget).attr("batchno"); 
	if(confirm("确定重做当前批次?")){
		//删除inter_log
		var deletelogSql = "delete from inter_log where op_time='"+_batchno+"' and inter_code='"+_fullintercode+"'";
		var deletefilelogSql ="delete from inter_file_log where op_time='"+_batchno+"' and inter_code='"+_fullintercode+"'";
		var finalSql="update inter_cfg  set batch_no='"+_batchno+"' where fullintercode='"+_fullintercode+"'";
		ai.executeSQL(deletelogSql,false,"METADBS");
		ai.executeSQL(deletefilelogSql,false,"METADBS");
		ai.executeSQL(finalSql,false,"METADBS");	
		_contentStore.fetch();
		if(_opStore!=null&&_opStore!=''){
			_opStore.fetch();
		}
	}
}
//左边树
var buildTreeView = function(sql){
	$('#treeview6').treeview({
		color: "#428bca",
		expandIcon: "glyphicon glyphicon-chevron-right",
		collapseIcon: "glyphicon glyphicon-chevron-down",
		nodeIcon: "glyphicon glyphicon-user",
		showTags: true,
		onNodeSelected:function(event,node){
			var strArray=node.id.split(">");
			var where="";
			for(var i=0;i<strArray.length;i++){
				var str =strArray[i];
				var subWhere=str.split(":")[0]+" = '"+str.split(":")[1]+"'";
				if(str.split(":")[1]=='未知') subWhere = str.split(":")[0] +" is null ";
				if(where) where += " and "+ subWhere
				else where=subWhere;
			}
			where = where.length>0?(" and "+where):"";
			temp_state = "and c.CHECK_PUT_STATUS ='1'";//这里默认显示处理失败的，状态为1
			if(isDefault){
               _contentStore.config.sql=_realQuerySql.replace("{condi}",where+getQuerCondi()+temp_state);
			}else{
               _contentStore.config.sql=_realQuerySql.replace("{condi}",where+getQuerCondi());
			}
			_contentStore.fetch();
			totalSelectoin="-1";
			_totalStore.fetch(); 
		},
		groupfield:"DATAREGION,SOURCESYS,INTER_CYCLE",//SCHEMA_NAME,TABSPACE,
		titlefield:"DATAREGIONNAME,SOURCESYSNAME,INTER_CYCLENAME",
		iconfield:"",
		sql:sql,
		dataSource:'METADBS',
		maxLength:6,
		subtype: 'grouptree' 
	});
};