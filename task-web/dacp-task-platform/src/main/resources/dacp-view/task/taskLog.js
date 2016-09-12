var REFRESHTIMER;
var argsAgent="";
var runFreq="";
var curTeamCodeCondi = "";
var _CLASS=['btn-default','btn-info','btn-info','btn-primary','btn-warning','btn-success','btn-danger','btn-warning','btn-default','btn-danger','btn-info'];
var _VALUE=['创建成功','依赖检测通过','并发检测成功','发送至agent','正在运行','运行成功','运行失败','暂停任务','等待重做','等待中断','失效'];
var finalQuerySql="select  SEQNO,PRI_LEVEL,AGENT_CODE,PLATFORM,PROC_NAME,RUN_FREQ,TASK_STATE,STATUS_TIME,START_TIME,EXEC_TIME,END_TIME,RETRYNUM,PROC_DATE,DATE_ARGS from (select * from proc_schedule_log order by start_time desc) as log  ";
var _stateIcon = function(value,data,index){
	value = value>=50?7:value;
	value = value<0&&value>=-3?8:value;
	value = value==0?9:value;
	value = value==-5?10:value;
	value = value==-6?11:value;
	var _tmpl = 
		'<div class="btn-group '+(index>6?"dropup":"")+'">'+
		'<button type="button" class="btn btn-xs <%=cla%> dropdown-toggle" data-toggle="dropdown">'+
		' <%=name%> <%if(value!=4&&value!=5&&value!=9&&value!=10&value!=11){%><span class="caret"></span>'+
		'</button>'+
		'<ul class="dropdown-menu" role="menu">'+
		'<%if(value!=6){%>'+
		'<li><a  id="pass" seq="<%=seqno%>">强制通过</a></li>'+
		'<%}%>'+
		'<%if(value==1){%>'+
		'<li><a  id="force" seq="<%=seqno%>">强制执行</a></li>'+
		'<li><a  id="relay" seq="<%=seqno%>" name="<%=procName%>">查看执行条件</a></li>'+
		'<%}%>'+
		'<%if(value<=3){%>'+
		'<li><a  id="pause" seq="<%=seqno%>">暂停执行</a></li>'+
		'<%}%>'+
		'<%if(value>=6&&value<8){%>'+
		'<li><a  id="redo" seq="<%=seqno%>">重做当前</a></li>'+
		//'<li><a  id="conti" seq="<%=seqno%>">重做后续</a></li>'+
		'<li><a id="log" seq="<%=seqno%>">查看日志</a></li>'+
		'<li><a id="dura" seq="<%=procName%>">时长分析</a></li>'+
		'<%}%>'+
		'<%if(value==1||value==2||value==3){%>'+
		'<li class="dropdown-submenu">'+
        '<a tabindex="-1" href="javascript:;">设置优先级</a>'+
        '<ul class="dropdown-menu">'+
            '<li class="'+'<%=(priLevel==20?"active":"")%>">'+'<a id="setPLevel" name="20" seq="<%=seqno%>" href="javascript:;">'+'<span class="glyphicon glyphicon-ok <%=priLevel==20?"":"hide"%>"></span>'+' 高（20）</a></li>'+
            '<li class="'+'<%=(priLevel>14&&priLevel<20?"active":"")%>">'+'<a id="setPLevel" name="15" seq="<%=seqno%>" href="javascript:;">'+'<span class="glyphicon glyphicon-ok <%=priLevel>14&&priLevel<20?"":"hide"%>"></span>'+' 高于正常（15）</a></li>'+
            '<li class="'+'<%=(priLevel>9&&priLevel<15?"active":"")%>">'+'<a id="setPLevel" name="10" seq="<%=seqno%>" href="javascript:;">'+'<span class="glyphicon glyphicon-ok <%=priLevel>9&&priLevel<15?"":"hide"%>"></span>'+' 正常（10）</a></li>'+
            '<li class="'+'<%=(priLevel>5&&priLevel<10?"active":"")%>">'+'<a id="setPLevel" name="5" seq="<%=seqno%>" href="javascript:;">'+'<span class="glyphicon glyphicon-ok <%=priLevel>5&&priLevel<10?"":"hide"%>"></span>'+' 低于正常（5）</a></li>'+
            '<li class="'+'<%=priLevel<5?"active":""%>">'+'<a id="setPLevel" name="1" seq="<%=seqno%>" href="javascript:;">'+'<span class="glyphicon glyphicon-ok <%=priLevel<5?"":"hide"%>"></span>'+' 低（1）</a></li>'+
        '</ul></li>'+
		'<%}%>'+
		'<%if(value==8){%>'+
		'<li><a id="goon" seq="<%=seqno%>">恢复任务</a></li>'+
		'<%}%>'+
		'</ul><%}else{%>'+
		'</button>'+
		'<%}%>'+
		'</div>';
	return _.template(_tmpl,{"cla":_CLASS[value-1],"name":_VALUE[value-1],"value":value,"seqno":data.SEQNO,"priLevel":data.PRI_LEVEL,"procName":data.PROC_NAME});
};
var runFreqRender = function(value,data,index){
	value=value=="hour"?"小时":value;
	value=value=="month"?"月":value;
	value=value=="day"?"日":value;
	return value;
	};
var implWidgets = [
	{	"id" : 'mian_view',
		"parentElementId":"main-content1",
		"className" : "fluidLayout",
		'layout' : {
			'splitType' : 'col-side',
			children:[
		        //监控列表
	          	{'id' : 'view_total','splitType' : 'row','class':'content',
	          		children:[
						{'id' : 'view_total_up_top','splitType' : 'row',
							children : [
							            {'id':'view_total_up_total_tab_nav'},
							            {'id':'view_total_up_list_info'}
							]
						}
					]
	          	},
			]
		},
		"events":{
			afterRender:function(){
				this.$el.addClass("vbox");
				var view_total = $("#view_total");
				var view_search = $("#view_search");
				this.getPage().on("view_total",function(){
					view_total.show();
					view_search.hide();
				});
				this.getPage().on("view_search",function(){
					view_total.hide();
					view_search.show();
				});
				this.getPage().on("view_operate",function(){
					var view_total = $("#view_total");
					if(view_total.is(":hidden")){
						view_total.show();
					}else{
						view_total.hide();
					}
				});
			}
		}
	},
	//概况总览---中间选择
	{
		"className": "form",
		"parentElementId": "view_total_up_total_tab_nav",
		"formClass":"form-inline",
		"id": "view_total_up_total_tab_nav",
		"items": [
			{
				"type":"combox",
				"id":"task_state_select",
				"select":[{'key':-1,'value':'选择运行状态'},{'key':-3,'value':'排队等待'},{'key':1,'value':'创建成功'},{'key':2,'value':'依赖检测通过'},{'key':3,'value':'并发检测成功'},{'key':4,'value':'发送至agent'},{'key':5,'value':'正在运行'},{'key':6,'value':'运行成功'},{'key':7,'value':'运行失败'}]
			},
			{
				"type": "date",
				"id":"search_time",
				"fieldLabel":"",
				//"sql":"SELECT CURDATE() AS DEFVAL FROM metauser GROUP BY DEFVAL",
				"format" : "yyyy-mm-dd",
				"style": "width:50px;"
			},
			{
				"type":"combox",
				"placeholder":"请选择Agent",
				"id":"agent_code_select",
				"sql":"SELECT AGENT_NAME AS K ,HOST_NAME AS V FROM AIETL_AGENTNODE WHERE TASK_TYPE='TASK'"
			},
			{
				"type":"combox",
				"placeholder":"请选周期",
				"id":"run_freq_select",
				"select":[{'key':'day','value':'日'},{'key':'month','value':'月'},{'key':'hour','value':'小时'},{'key':'','value':'全部'}]
			},
			{
				"type": "text",
				"id":"proc_name",
				"fieldLabel":"",
				"placeholder":"程序名称"
			},/*
			{
				"type":"combox",
				"id":"run_freq",
				"select":[{'key':'all','value':'全部'},{'key':'day','value':'天'},{'key':'hour','value':'小时'},{'key':'month','value':'月'}]
			},*/
			{
				"id":"search",
				"value":"查询",
				"type":"button",
				"className":"search_btn btn-sm btn-primary",
			},
			{
				"id":"refresh-grid",
				"value":"",
				"type":"button",
				"className":"search_btn btn-sm btn-primary",
			},
			{
				"id":"refresh-btn",
				"value":"",
				"type":"button",
				"className":"btn btn-sm btn-primary hide",
			}
		],
		'events': {
			afterRender:function(){
				var _view = this;
				//_view.$el.find('#agent_code option:lt(1)').text('请选择Agent');
				_view.$el.find('form').addClass('form_personal');
				_view.$el.css("padding","5px 20px");
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
				var _refresh = function(flag){
					if(flag){
						REFRESHTIMER = setTimeout(function(){
							_view.getPage().stores.appEvaluation.fetch();
							_view.getPage().stores.appStatic.fetch();
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
			},
			'change #agent_code_select select':function(e){
				argsAgent = $(e.currentTarget).val();
			},
			'change #run_freq_select select':function(e){
			    runFreq = $(e.currentTarget).val();
			},
			'change #task_state_select select':function(e){
				var _val = $(e.currentTarget).val();
				var timestamp = new Date();
				var _condi = _val==-1?(" where '" + timestamp + "'='" + timestamp + "' "):("where '" + timestamp + "'='" + timestamp + "' and task_state"+(_val==7?">=50":(_val==-5?"<5":("="+_val))));
				this.getPage().stores.appEvaluation.config.sql = finalQuerySql+_condi+ curTeamCodeCondi + " group by log.PROC_NAME,log.DATE_ARGS order by log.START_TIME desc";
				this.getPage().stores.appEvaluation.fetch();
			},
			'click #search':function(){
				var argsDate = this._getValues({
						id : "search_time",
						type : "date"
				}).value.value;
				var argsProc = this._getValues({
					id : "proc_name",
					type : "text"
				}).value.value;
				var timestamp = new Date();
				var _condi = " where '" + timestamp + "'='" + timestamp + "'";
				_condi += runFreq.length>0?(" and run_freq='"+runFreq+"'"):"";
				if(runFreq=='month'){
					_condi += argsDate.length>0?(" and date_args like '"+argsDate.substr(0,7)+"%'"):"";
				}
				else{
					_condi += argsDate.length>0?(" and date_args like '"+argsDate+"%'"):"";	
				}
				_condi += argsAgent.length>0?(" and agent_code='"+argsAgent+"'"):"";
				_condi += argsProc.length>0?(" and proc_name like '%"+argsProc+"%'"):"";
				this.getPage().stores.appEvaluation.config.sql = finalQuerySql+_condi+ curTeamCodeCondi + " group by log.PROC_NAME,log.DATE_ARGS order by log.START_TIME desc";
				this.getPage().stores.appEvaluation.fetch();
			},
			'click #refresh-btn':function(){
				this.getPage().stores.appEvaluation.fetch();
				this.getPage().stores.appStatic.fetch();
			}
		}
	},
	//概况总览-----总览列表
	{
		"className":"grid",
		'showcheck': false,
		"storeId":"appEvaluation",
		'parentElementId': 'view_total_up_list_info',
		'id':'evaluateView_tab_evaluate_middle_down_grid',
		'pageSize':15,
		"header":[
			{"label":"程序名称","dataIndex":"PROC_NAME","className":"ai-grid-body-td-left"},
			{"label":"周期","dataIndex":"RUN_FREQ","className":"ai-grid-body-td-left",renderer:runFreqRender},
			{"label":"Agent","dataIndex":"AGENT_CODE"},
			{"label":"状态","dataIndex":"TASK_STATE","className":"ai-grid-body-td-left",renderer:_stateIcon},
			//{"label":"状态时间","dataIndex":"STATUS_TIME"},
			{"label":"优先级","dataIndex":"PRI_LEVEL"},
			{"label":"创建时间","dataIndex":"START_TIME"},
			{"label":"开始执行时间","dataIndex":"EXEC_TIME"},
			{"label":"执行结束时间","dataIndex":"END_TIME"},
			//{"label":"运行时长","dataIndex":"DURATION"},
			{"label":"自动重做次数","dataIndex":"RETRYNUM"},
			//{"label":"运行日期","dataIndex":"PROC_DATE"},
			{"label":"日期参数","dataIndex":"DATE_ARGS"}
		],
		"events":{
			afterRender:function(){
				this.$el.find(".table-area").css("overflow","visible");
				this.$el.css("padding","0px 0px 10px 25px");
			},
			afterTabelBodyRender:function(){
				var _view = this;
				_view.$el.find("a#log").on("click",function(e){
					var $el = parent.$('#panel1');
					var seqno = $(e.currentTarget).attr("seq");
					var _procListStore = new AI.JsonStore({
						sql: "select proc_name,seqno from proc_schedule_log",
						initUrl: '/' + contextPath + '/newrecordService',
						url: '/' + contextPath + '/newrecordService',
						root: 'root',
						pageSize: -1,
						loadDataWhenInit: true,
						table: "proc",
						key: "PROC_NAME"
					});
					var _curIndex = 0;
					for(var i=0;i<_procListStore.getCount();i++){
						if(_procListStore.getAt(i).get("SEQNO")==seqno){
							_curIndex = i;
						}
					}
					var _store = new ve.SqlStore({
						sql:"select a.seqno,a.proc_name,a.app_log,b.start_time,b.task_state,b.retrynum,b.status_time from proc_schedule_script_log a,proc_schedule_log b  where a.seqno=b.seqno and a.seqno='"+seqno+"'"
					});
					_store.on("reset",function(store){
						var tmpl = '';
						var _title = _procListStore.getAt(_curIndex).get("PROC_NAME").toUpperCase();
						if(store.models.length==1){
							var _taskState = store.models[0].get("TASK_STATE");
							_taskState = _taskState>=50?7:_taskState;
							_taskState = _taskState<0&&_taskState>=-3?8:_taskState;
							_taskState = _taskState==0?9:_taskState;
							_taskState = _taskState==-5?10:_taskState;
							_taskState = _taskState==-6?11:_taskState;
							
							tmpl = _.template(
								'<section class="panel panel-default">'
								+ '<header class="panel-heading"> 脚本运行日志</header> '
								+ '<article class="media">'
								+ '<div class="media-body" style="margin-left:60px;">'
								+ '<div class="pull-right media-xs text-center text-muted"> '
								+ '<strong class="h4"><%=retry%></strong> 次<br> <small class="label bg-gray text-xs">失败重做</small>'
								+ '</div>'
								+ '<h4><%=time%> <span class="label <%=cla%>"><%=name%></span> </h4>'
								+ '<small class="block"><span>日志内容：</span></small>'
								+ '<small class="block" ><pre><%=log%></pre></small>'
								+ '</div>'
								+ '</article>'
								+'</section>',
								{"cla":_CLASS[_taskState-1],"name":_VALUE[_taskState-1],"time":store.models[0].get("STATUS_TIME"),"log":store.models[0].get("APP_LOG"),"retry":store.models[0].get("RETRYNUM")});
						}else{
							tmpl = "找不到日志信息！";
						}
						parent.openTableInfo("log",_title,tmpl,true);
					},_view);
					_store.fetch();
					
					$el.on("push-left-log",function(){
						var _index = _curIndex==0?_procListStore.getCount()-1:_curIndex-1;
						_curIndex = _index;
						_store.config.sql = "select a.seqno,a.proc_name,a.app_log,b.start_time,b.task_state,b.retrynum,b.status_time from proc_schedule_script_log a,proc_schedule_log b  where a.seqno=b.seqno and a.seqno='"+_procListStore.getAt(_index).get("SEQNO")+"'";
						_store.fetch();
					});
					$el.on("push-right-log",function(){
						var _index = _curIndex==_procListStore.getCount()-1?0:_curIndex+1;
						_curIndex = _index;
						_store.config.sql = "select a.seqno,a.proc_name,a.app_log,b.start_time,b.task_state,b.retrynum,b.status_time from proc_schedule_script_log a,proc_schedule_log b  where a.seqno=b.seqno and a.seqno='"+_procListStore.getAt(_index).get("SEQNO")+"'";
						_store.fetch();
					});
				});
				_view.$el.find("a#relay").on("click",function(e){
					var _seqno = $(e.currentTarget).attr("seq");
					var _procName=$(e.currentTarget).attr("name");
					var $el = parent.$('#panel1');
					var tmpl = _.template(
							'<div class="row">'
							+ '<div class="col-sm-12">'
							+ '<section class="panel panel-default">'
							+ '<header class="panel-heading">任务序列：'+_seqno+'&nbsp;&nbsp;&nbsp;&nbsp;程序名：'+_procName+'</header> '
							+ '<div class="media-body" id="cfg-filter">'
							+ '</div>'
							+ '<div class="media-body" id="cfg-content">'
							+ '</div>'
							+ '</section></div></div>',
							{"name":"name"});
					$el.on("finishRender",function(){
						var sql = "SELECT SEQNO ,PROC_NAME ,SOURCE,DATANAME,DBNAME,SOURCE_TYPE,DATA_TIME,CHECK_FLAG FROM PROC_SCHEDULE_SOURCE_LOG a ,TABLEFILE b WHERE SOURCE=XMLID AND SEQNO='"+_seqno+"'  ORDER BY check_flag";
						var cfgVeStore ={};
						cfgVeStore = new ve.SqlStore({
							sql:sql
						});
						var cfgGrid = new ve.GridWidget({
							config:{
								"className" : "grid",
								"id":"relay-grid",
								"pageSize":20,
								"header":
								[
								 	//{"label":"任务序列","dataIndex":"seqno","className":"ai-grid-body-td-left"},
									//{"label":"程序名称","dataIndex":"PROC_NAME","className":"ai-grid-body-td-left"},
									{"label":"表ID","dataIndex":"SOURCE","className":"ai-grid-body-td-left"},
									{"label":"表名","dataIndex":"DATANAME","className":"ai-grid-body-td-left"},
									{"label":"数据库","dataIndex":"DBNAME","className":"ai-grid-body-td-left"},
									//{"label":"源类型","dataIndex":"SOURCE_TYPE",renderer:function(value){ return value=='DATA'?'表':'程序'; }},
									{"label":"数据日期","dataIndex":"DATA_TIME","className":"ai-grid-body-td-left",renderer:function(value){ return value=='N'?'无':value;}},
									{"label":"检测通过","dataIndex":"CHECK_FLAG",renderer:function(value){ return _.template('<span class="glyphicon glyphicon-<%=CHECK_FLAG==0?"remove":"ok"%>"></span>',{'CHECK_FLAG':value});}}
								],
								"events":{
									beforeRender:function(){
										cfgGrid.store = cfgVeStore;
									},
									afterRender:function(){
										this.$el.find(".page-container .pagination").css("margin","0");
									}
								}
							}
						});
						cfgGrid.$el = $el.find('#cfg-content');
						cfgVeStore.on("reset",function(){
							cfgGrid.render();
						});
						cfgVeStore.fetch();
					});
					parent.openTableInfo("relayOn","查看执行条件",tmpl,false);
				});
				_view.$el.find("a#dura").on("click",function(e){
					var _procName = $(e.currentTarget).attr("seq");
					var $el = parent.$('#panel1');
					if(_procName&&_procName.length>0){
						var _procListStore = new AI.JsonStore({
							sql: "select distinct proc_name from proc",
							initUrl: '/' + contextPath + '/newrecordService',
							url: '/' + contextPath + '/newrecordService',
							root: 'root',
							pageSize: -1,
							loadDataWhenInit: true,
							table: "proc",
							key: "PROC_NAME"
						});
						var _curIndex = 0;
						for(var i=0;i<_procListStore.getCount();i++){
							if(_procListStore.getAt(i).get("PROC_NAME")==_procName){
								_curIndex = i;
							}
						}
						var _store = new ve.SqlStore({
							sql:"select a.proc_name,b.proccnname,b.state from proc_schedule_log a,proc b where a.proc_name = b.proc_name and a.proc_name='"+$(e.currentTarget).attr("seq")+"'"
						});
						_store.on("reset",function(store){
							var _tmpl='';
							var _title = _procListStore.getAt(_curIndex).get("PROC_NAME").toUpperCase();
							if(store.models.length>0){
								var _proc=store.models[0];
								_tmpl =_.template(
										'<div class="row">'
									+ '<div class="col-md-6">'
									+ '<section class="panel panel-default">'
									+ '<header class="panel-heading font-bold">详细信息</header>'
									+ '<ul class="list-group no-radius">'
									+ '<li class="list-group-item"> <span class="pull-right"><%=proc_name%></span> 程序代码 </li>'
									+ '<li class="list-group-item"> <span class="pull-right"><%=proccnname%></span> 程序名称 </li>'
									+ '<li class="list-group-item"> <span class="pull-right"><%=state%></span> 状态 </li>'
									+ '</ul>'
									+ '<div class="line pull-in"></div>'
									+ '</div><div class="col-md-6">'
									+ '<section class="panel panel-default">'
									+ '<header class="panel-heading font-bold">运行时长分析</header>'
									+ '<section class="media-body"> '
									+'<form class="m-b-none hide" action="index.html"> '
									+ '<div class="input-group"> '
									+ '<input type="text" placeholder="Input your comment here" class="form-control"> '
									+ '<span class="input-group-btn"> '
									+ '<button type="button" class="btn btn-primary">POST</button> </span> </div> </form> </section>'
									+ '<div class="panel-body">'
									+ '<div id="flot-bar-h" style="height: 240px"></div>'
									+ '</div>'
									+ '</section>'
									+ '</div></div>'
									+ '<div class="row">'
									+ '<div class="col-md-12">'
									+ '<section class="panel panel-default">'
									+ '<header class="panel-heading font-font">运行时长分析趋势图</header>'
									+ '<section class="media-body">'
									+ '</section>'
									+ '<div class="panel-body">'
									+ '<div id="flot-line-h" style="height:240px"></div>'
									+ '</div>'
									+ '</section>'
									+ '</div>'	
									+ '</div>'
									,{"proc_name":_proc.get("PROC_NAME"),"proccnname":_proc.get("PROCCNNAME"),"state":_proc.get("STATE")});
							}else{
								_tmpl = "暂无数据！";
							}
							$el.on("finishRender",function(){					
								//获取数据
								if($el.find('#flot-bar-h').length==1){
									var _proc_name = _procListStore.getAt(_curIndex).get("PROC_NAME");
									var _procTimerStore = new AI.JsonStore({
										sql: "select * from"
											+ " (select * from"
											+ " (select distinct status_time,TIMESTAMPDIFF(MINUTE,EXEC_TIME,END_TIME) as DURATION from"
											+ " proc_schedule_log where proc_name='"+_proc_name+"') T"
											+ " where T.DURATION IS NOT NULL order by T.status_time DESC LIMIT 30) T1 ORDER BY T1.status_time",
										initUrl: '/' + contextPath + '/newrecordService',
										url: '/' + contextPath + '/newrecordService',
										root: 'root',
										pageSize: -1,
										loadDataWhenInit: true,
										table: "proc",
										key: "PROC_NAME"
									});
									var _categories=[];
									var _series=[];
									for(var i=0;i<_procTimerStore.getCount();i++){
										_categories.push(_procTimerStore.getAt(i).get("STATUS_TIME"));
										_series.push(_procTimerStore.getAt(i).get("DURATION"));
									}
									/*
									_procTimerStore.data.each(function(dt){
										_categories.push(dt.get("STATUS_TIME"));
										_series.push(dt.get("DURATION"));
									});*/
								}
								
								//bar图：
								$el.find('#flot-bar-h').empty().highcharts({
							        chart: {type: 'bar'
							        	}, 
							        title: {text: null},
							        xAxis: {
							        	categories: _categories,
							            title: {text: null}
							        },
							        yAxis: {
							        	min: 0,
							            title: {
							                text: '运行时长 (分)',
							                align: 'high'                  
							            },
							            labels: {overflow: 'justify'}
							        },
							        tooltip: {valueSuffix: ' 分钟'},
							        plotOptions: {bar: {dataLabels: {enabled: true}}},   
							        legend: {
							            layout: 'vertical',
							            align: 'right',
							            verticalAlign: 'top',
							            x: -40,
							            y: 100,
							            floating: true,
							            borderWidth: 0,
							            backgroundColor: '#FFFFFF',
							            shadow: true
							        },                                                  
							        series: [{
							        	name: _proc_name,
							            data: _series                                 
							        }]
							    });
								
								//line图：
								$el.find('#flot-line-h').empty().highcharts({
									chart:{
										type: 'line',
										width: 1200
									},
							        title: {text: ''},
							        xAxis: {
							        	title: {text: '时间'},
							        	categories: _categories								            
							        },
							        yAxis: {
							        	min: 0,
							            title: {
							                text: '运行时长 (分)', 
							                align: 'high'           
							            }
							        },
							        tooltip: {valueSuffix: '分钟'},
							        series: [{
							        	name: _proc_name,
							            data: _series                                 
							        }]
							    });					
									
							});
							parent.openTableInfo("dura",_title,_tmpl,true);
						},_view);
						_store.fetch();
						
						$el.on("push-left-dura",function(){
							var _index = _curIndex==0?_procListStore.getCount()-1:_curIndex-1;
							_curIndex = _index;
							_store.config.sql = "select a.proc_name,b.proccnname,b.state from proc_schedule_log a,proc b where a.proc_name = b.proc_name and a.proc_name='"+_procListStore.getAt(_index).get("PROC_NAME")+"'";
							_store.fetch();
						});
						$el.on("push-right-dura",function(){
							var _index = _curIndex==_procListStore.getCount()-1?0:_curIndex+1;
							_curIndex = _index;
							_store.config.sql = "select a.proc_name,b.proccnname,b.state from proc_schedule_log a,proc b where a.proc_name = b.proc_name and a.proc_name='"+_procListStore.getAt(_index).get("PROC_NAME")+"'";
							_store.fetch();
						});
					}else{
						alert("没有找到表！");
					}
				});
				_view.$el.find("a#force,a#pause,a#goon,a#redo,a#conti,a#pass,a#setPLevel").on("click",function(e){
					var _seqno = $(e.currentTarget).attr("seq");
					var _workType = $(e.currentTarget).attr("id");
					//var _newLog = proc_log.getNewRecord();
					var finalSql="update proc_schedule_log  ";
					var execSql="";
					var res="";
					if(_workType=='pause'||_workType=='goon'){
						var alterStr = _workType=='pause'?"确定暂停程序?":"确定恢复程序?";
						if(confirm(alterStr)){
							execSql=finalSql + "set TASK_STATE='"+(0-_log.get("TASK_STATE"))+"' where seqno='"+_seqno+"' and task_state<=3 ";
							res=ai.executeSQL(execSql,false,"");
						}
					}else if(_workType=='setPLevel'){
						if(confirm("确定调整优先级?")){
						var _level = $(e.currentTarget).attr("name")
						_log.set("PRI_LEVEL",parseInt(_level));
						}
					}else if(_workType=='pass'){
						if(confirm("确定强制通过?")){
							execSql=finalSql +"set TASK_STATE=6,QUEUE_FLAG=0,TRIGGER_FLAG=0 where seqno='"+_seqno+"' and task_state<>6 ";
							res=ai.executeSQL(execSql,false,"");
						}
					}else if(_workType=='force'){
						//_log.set("TASK_STATE",2);
						if(confirm("确定强制执行?")){
							execSql=finalSql+" set TASK_STATE=2 where seqno='"+_seqno+"' and task_state=1";
							res=ai.executeSQL(execSql,false,"");
						}
					}else {
						if(confirm("确定重做?")){
						var date = new Date();
						_dateStr=date.format("yyyy-mm-dd hh:mm:ss").substr(0,16);
						execSql=finalSql+" set TASK_STATE="+(_workType=="redo"?1:0)+", TRIGGER_FLAG="+(_workType=="redo"?1:0)+",QUEUE_FLAG=0,END_TIME=NULL,EXEC_TIME=NULL,START_TIME='"+_dateStr+"' where seqno='"+_seqno+"' and ( task_state=6 or task_state>=50 )";
						res=ai.executeSQL(execSql,false,"");
						}
					}
					_view.getPage().stores.appEvaluation.fetch();
				});
			}
		}
	}
];
var index = 0;
$(document).ready(function() {
	var curTeamCode = paramMap['TEAM_CODE'];
	curTeamCodeCondi = (typeof(curTeamCode)=="undefined" || curTeamCode =='' || curTeamCode == 'undefined' )?(''):("  and team_code = '"+curTeamCode+"' ")
    var formater = new Date();
	formater.setDate(formater.getDate()-1); 
	var _date = formater.format("yyyy-mm-dd hh:mm:ss").substr(0,10);
	var timestamp = new Date();
	var pageDefs = [ {
		id : "main-content1",
		title : "<div></div>",
		widgetDefs : implWidgets,
		stores : {
			'appEvaluation':new ve.SqlStore({
				sql:finalQuerySql+"  where '" +timestamp + "'='" + timestamp + "' and date_args like '"+_date+"%' " + curTeamCodeCondi + " group by log.proc_name,log.date_args order by log.start_time desc" 
			}),
			'appStatic':new ve.SqlStore({
				sql:"select count(*) as total, sum(case when task_state=6 then 1 else 0 end ) as finish, sum(case when task_state=5 then 1 else 0 end ) as running, sum(case when task_state<=4 then 1 else 0 end ) as queue, sum(case when task_state>6 then 1 else 0 end ) as fail from proc_schedule_log where '" + timestamp + "'='" + timestamp + "' and date_args like '"+_date+"%'" + curTeamCodeCondi
			})
		},
		events : {}
	} ];
	window.app = new ve.Context({
		pageDefs : pageDefs,
		el : ".main-area"
	});
	window.app.render();
});