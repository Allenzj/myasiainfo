var REFRESHTIMER;
var curTeamCodeCondi = "";
var agent_code="";
var run_freq="day"; 
var task_state="";
var _status=['0','1',' and task_state>-7 ','3',' and (task_state between -4 and 4) ',' and task_state= 5 ',' and task_state=6 ',' and task_state>=50 ',' and task_state=-7'];
var _CLASS=['btn-default','btn-info','btn-info','btn-primary','btn-warning','btn-success','btn-danger','btn-warning','btn-default','btn-danger','btn-info','btn-warning','btn-danger'];
var _VALUE=['创建成功','依赖检测通过','并发检测成功','发送至agent','正在运行','运行成功','运行失败','暂停任务','重做后续','等待中断','失效','未触发','等待重做'];
var _finalQuerySql=" SELECT SEQNO,PRI_LEVEL,PLATFORM,AGENT_CODE,PROC_NAME,RUN_FREQ,TASK_STATE,STATUS_TIME,START_TIME,EXEC_TIME,END_TIME,'' DURATION,RETRYNUM,PROC_DATE,DATE_ARGS,QUEUE_FLAG from proc_schedule_log a where  1=1 {}  order by START_TIME desc";
var  finalQuerySql=" SELECT SEQNO,PRI_LEVEL,PLATFORM,AGENT_CODE,a.PROC_NAME,RUN_FREQ,TASK_STATE,STATUS_TIME,a.START_TIME,EXEC_TIME,END_TIME,'' DURATION,RETRYNUM,PROC_DATE,a.DATE_ARGS ,QUEUE_FLAG "+
                                  " FROM (SELECT PROC_NAME,DATE_ARGS ,MAX(START_TIME) START_TIME  FROM proc_schedule_log GROUP BY PROC_NAME,DATE_ARGS) a "+
                                  " LEFT JOIN proc_schedule_log b ON a.DATE_ARGS=b.DATE_ARGS AND a.PROC_NAME=b.PROC_NAME AND a.START_TIME=b.START_TIME WHERE 1=1 {} ORDER BY  a.START_TIME DESC ";
//var   finalQuerySql="select SEQNO,PRI_LEVEL,PLATFORM,AGENT_CODE,PROC_NAME,RUN_FREQ,TASK_STATE,STATUS_TIME,START_TIME,EXEC_TIME,END_TIME,substring(timediff(END_TIME,EXEC_TIME),1,8) as DURATION,RETRYNUM,PROC_DATE,DATE_ARGS from (select * from proc_schedule_log order by start_time desc) as log  where 1=1  {} group by proc_name,date_args order by START_TIME desc";//var   finalQuerySql="select SEQNO,PRI_LEVEL,PLATFORM,AGENT_CODE,PROC_NAME,RUN_FREQ,TASK_STATE,STATUS_TIME,START_TIME,EXEC_TIME,END_TIME,substring(timediff(END_TIME,EXEC_TIME),1,8) as DURATION,RETRYNUM,PROC_DATE,DATE_ARGS from (select * from proc_schedule_log order by start_time desc) as log  where 1=1  {} group by proc_name,date_args order by START_TIME desc";
var _realSql = finalQuerySql;
var getQuerySql=function(_view){
	proc_name = _view._getValues({id : "proc_name",type : "text"}).value.value;
	date_args = _view._getValues({id : "date_args",type : "date"}).value.value;
	timestamp = new Date().getTime();
	var _condi = " and  '" + timestamp + "'='" + timestamp + "'";
	if(agent_code.length>0){
		_condi +=" and agent_code='"+agent_code+"' ";
	}
	if(task_state.length>0){
		_condi +=task_state;
	}else{
		_condi +=" and task_state>-7 ";   
	}
	if(proc_name.length>0){
		_condi +=" AND (a.proc_name like '%"+proc_name+"%' ) " ;
	}
	if(run_freq=="month"){
		_condi += date_args.length>0?(" and run_freq='month' and a.date_args = '"+date_args.substr(0,8)+"01'"):"";
	}else if(run_freq=="day"){
		_condi += date_args.length>0?(" and run_freq='day'      and a.date_args = '"+date_args+"'"):"";	
	}else if(run_freq=="hour"){
		_condi += date_args.length>0?(" and run_freq='hour'     and a.date_args like '"+date_args+"___'"):"";
	}else if(run_freq.length==0){
		if(date_args.length>0){
			date_args = date_args.replace(/\-/g,""); 
			_condi +=" and run_freq<>'manual'  and proc_date like '"+date_args+"%' ";
		} 
	}
	//_condi +=curTeamCodeCondi;
	var execSql = _realSql.replace("{}",_condi);
	return execSql;
};
var _timeDiffRender = function(value,data,index){
	var end= data.END_TIME;
	var start =data.EXEC_TIME;
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
var _stateIcon = function(value,data,index){
	value = value>=50&&data.QUEUE_FLAG==1?7:value;
	value = value<0&&value>=-3?8:value;
	value = value==0?9:value;
	value = value==-5?10:value;
	value = value==-6?11:value;
	value = value==-7?12:value;
	value = value>=50&&data.QUEUE_FLAG==0? 13:value;
	var _tmpl = 
		'<div class="btn-group '+(index>6?"dropup":"")+'">'+
		'<button type="button" class="btn btn-xs <%=cla%> dropdown-toggle" data-toggle="dropdown">'+
		' <%=name%> <%if(value!=4&&value!=9&&value!=10&value!=11){%><span class="caret"></span>'+
		'</button>'+
		'<ul class="dropdown-menu" role="menu">'+
		'<%if(value!=12){%>'+
		'<li><a  id="relay"  seq="<%=seqno%>" name="<%=procName%>">查看执行条件</a></li>'+
		'<%}%>'+ 
		'<%if(value!=6&&value!=4&&value!=5){%>'+
		'<li><a  id="pass"  seq="<%=seqno%>">强制通过</a></li>'+
		'<%}%>'+ 
		'<%if(value==5){%>'+
		'<li><a  id="stop_drive"  seq="<%=seqno%>">停止触发</a></li>'+
		'<%}%>'+ 
		'<%if(value==1){%>'+
		'<li><a  id="force"  seq="<%=seqno%>" >强制执行</a></li>'+
		'<%}%>'+
		'<%if(value<=3&&value>=1){%>'+
		'<li><a  id="pause"  seq="<%=seqno%>" task_status="<%=task_status%>">暂停执行</a></li>'+
		'<%}%>'+
		'<%if(value>=6&&value<8||value==13){%>'+
		'<li><a  id="redo"   seq="<%=seqno%>">重做当前</a></li>'+
		'<li><a  id="conti"  seq="<%=seqno%>">重做后续</a></li>'+
		'<li><a  id="log"    seq="<%=seqno%>">查看日志</a></li>'+
		'<li><a  id="dura"   seq="<%=procName%>">时长分析</a></li>'+
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
		'<li><a id="goon" seq="<%=seqno%>" task_status="<%=task_status%>">恢复任务</a></li>'+
		'<%}%>'+
		'</ul><%}else{%>'+
		'</button>'+
		'<%}%>'+
		'</div>';
	return _.template(_tmpl,{"cla":_CLASS[value-1],"name":_VALUE[value-1],"value":value,"seqno":data.SEQNO,"priLevel":data.PRI_LEVEL,"procName":data.PROC_NAME,"task_status":data.TASK_STATE});
};
var runFreqRender = function(value,data,index){
		value=value=="hour"?"小时":value;
		value=value=="month"?"月":value;
		value=value=="day"?"日":value;
		return value;
};
var dateRender=function(value,data,index){
	//var _dateStr = value.substring(5);
	//return _dateStr;
	return value;
}
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
						{'id' : 'view_total_up','splitType' : 'row',
							children : [
							            {'id':'view_total_up_total'},
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
				var view_total = $("#view_total");
				var view_search = $("#view_search");
				this.$el.addClass("vbox");
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
	//概况总览--总体概况
	{
		"className": "html",
		"parentElementId": "view_total_up_total",
		"id": "view_total_up_total_id",
		"storeId":"appStatic",
		"template":'<div class="total_line row"><div class="total_run col-sm-2"><div class="total_1 ">任务运行概况</div><div class="total_2 "><%=curDate%></div></div>'//<div class="detail_0 col-sm-2">'
			       + '<div class="total_detail col-sm-10">'
			       + '<div class="detail_1"><label class="total_label_1"><%=finishRate%>%</label><div><label class="sm-detail">运行成功率</label></div></div>'
			       + '<div class="detail_2"><label class="total_label_2 detail_label" id="2"><%=total%></label><div><label class="sm-detail">今日总程序数</label></div></div>'
			       + '<div class="detail_3"><label class="total_label_3 detail_label" id="6"><%=finish%></label><div><label class="sm-detail">执行成功</label></div></div>'
			       + '<div class="detail_4"><label class="total_label_4 detail_label" id="7"><%=fail%></label><div><label class="sm-detail">执行失败</label></div></div>'
			       + '<div class="detail_5"><label class="total_label_5 detail_label" id="5"><%=running%></label><div><label class="sm-detail">正在执行</label></div></div>'
			       + '<div class="detail_6"><label class="total_label_6 detail_label" id="4"><%=queue%></label><div><label class="sm-detail">排队等待</label></div></div>'
			       + '<div class="detail_7"><label class="total_label_7 detail_label" id="8"><%=unqueue%></label><div><label class="sm-detail">未触发</label></div></div>'
			       + '</div></div>',
		"events":{
			afterRender:function(){
				
				var _view = this;
				_view.$el.css("padding","5px 5px 5px 30px");
				var clock = function(){
					var date = new Date();
			  		var curDateStr = date.format("yyyy-mm-dd");
			  		var finish = _view.store.models[0].get("FINISH");
			  		var fail =         _view.store.models[0].get("FAIL");
			  		var running = _view.store.models[0].get("RUNNING");
			  		var unqueue= _view.store.models[0].get("UNQUEUE");
			  		var queue = _view.store.models[0].get("QUEUE");
			  		var total = _view.store.models[0].get("TOTAL");
			  		var finish = finish==undefined||finish==null?0:finish;
			  		var fail = fail==undefined||fail==null?0:fail;
			  		var running = running==undefined||running==null?0:running;
			  		var queue = queue==undefined||queue==null?0:queue;
			  		var unqueue = unqueue==undefined||unqueue==null?0:unqueue;
			  		var finishRate = (finish*100/(total==0?1:total)).toFixed(2);
			  		_view.$el.addClass('info-general').empty().append(_.template(_view.config.template,{'curDate':curDateStr,'finishRate':finishRate,'total':total,'finish':finish,'fail':fail,'running':running,'queue':queue,'unqueue':unqueue}));
			  		_view.$el.find('.detail_label').on('click',function(e){
			  			var _id = $(e.currentTarget).attr("id");
			  			$("#task_state_select select").val(_id);
				  		$("#task_state_select select").trigger("change");
			  		});
				};
				clock();
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
				"fieldLabel":"状态",
				"select":[{'key':'2','value':'全部状态'},{'key':'4','value':'排队等待'},{'key':'5','value':'正在运行'},{'key':'6','value':'执行成功'},{'key':'7','value':'执行失败'},{'key':'8','value':'未触发'}],
			    "style": "min-width:60px;width:100px;"
			},
			{
				"type":"combox",
				"fieldLabel":"Agent",
				"id":"agent_code_select",
				"sql":"SELECT AGENT_NAME AS K ,HOST_NAME AS V FROM AIETL_AGENTNODE WHERE TASK_TYPE='TASK'",
				"style": "min-width:60px;width:120px;"
			},
			{
				"type":"combox",
				"fieldLabel":"周期",
				"id":"run_freq_select",
				"select":[{'key':'day','value':'日'},{'key':'month','value':'月'},{'key':'hour','value':'小时'},{'key':'','value':'全部'}],
				"style": "min-width:50px;width:60px;"
			},
			{
				"type": "date",
				"id":"date_args",
				"fieldLabel":"参数",
				"placeholder":"日期参数",
				"format" : "yyyy-mm-dd",
				//"sql":"SELECT CURDATE() AS DEFVAL FROM metauser GROUP BY DEFVAL",
				"style": "min-width:60px;width:80px;"
			},
			{
				"type": "text",
				"id":"proc_name",
				"fieldLabel":"",
				"placeholder":"程序名称",
				"style": "min-width:60px;width:150px;"
			},
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
			},
			{
				"id":"switch-mode",
				"value":"",
				"type":"button",
				"className":"search_btn btn-sm btn-primary",
			}
		],
		'events': {
			afterRender:function(){
				var _view = this;
				_view.$el.find('form').addClass('form_personal');
				//_view.$el.css("padding","5px");
				_view.$el.css("padding","5px 5px 5px 30px");
				_view.$el.find("#switch-mode").empty().append(
						'<div class="btn-group" data-toggle="buttons" style="margin-right: 2px;">'+
						'<label id="m-simple" class="btn btn-sm btn-info active">'+
						'<input type="radio" name="options">'+
						'<i class="fa fa-check text-active" ></i>去重</label>'+
						'<label id="m-all" class="btn btn-sm btn-success">'+
						'<input type="radio" name="options">'+
						'<i class="fa fa-check text-active"></i>全量</label>'+
						'</div>'
				);
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
				_view.$el.find("#m-all").on("click",function(e){
					_realSql = _finalQuerySql;
				});
				_view.$el.find("#m-simple").on("click",function(e){
					_realSql = finalQuerySql;
			   });
				_view.$el.find("#m-g").on("click",function(e){
					_view.$el.find("#refresh-btn button").addClass("hide");
					_refresh(true);
				});
				_view.$el.find("#m-o").on("click",function(e){
					_view.$el.find("#refresh-btn button").removeClass("hide");
					_refresh(false);
				});
			},
			'change #agent_code_select select':function(e){
				agent_code = $(e.currentTarget).val();
				var _view = this;
				this.getPage().stores.appEvaluation.config.sql = getQuerySql(_view);
				this.getPage().stores.appEvaluation.fetch();
			},
			'change #run_freq_select select':function(e){
			    run_freq = $(e.currentTarget).val();
				var _view = this;
				this.getPage().stores.appEvaluation.config.sql = getQuerySql(_view);
				this.getPage().stores.appEvaluation.fetch();
			},
			'change #task_state_select select':function(e){
				task_state = _status[$(e.currentTarget).val()];
				var _view = this;
	            this.getPage().stores.appEvaluation.config.sql = getQuerySql(_view);
				this.getPage().stores.appEvaluation.fetch();
				this.getPage().stores.appStatic.fetch();
			},
			'click #search':function(){
				var _view = this;
				this.getPage().stores.appEvaluation.config.sql = getQuerySql(_view);
				this.getPage().stores.appEvaluation.fetch();
				this.getPage().stores.appStatic.fetch();
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
		'pageSize':12,
		"header":[
			{"label":"程序名称","dataIndex":"PROC_NAME","className":"ai-grid-body-td-left"},
			{"label":"周期","dataIndex":"RUN_FREQ","className":"ai-grid-body-td-left",renderer:runFreqRender},
			{"label":"Agent","dataIndex":"AGENT_CODE"},
			{"label":"状态","dataIndex":"TASK_STATE","className":"ai-grid-body-td-left",renderer:_stateIcon},
			//{"label":"优先级","dataIndex":"PRI_LEVEL"},
			{"label":"创建时间","dataIndex":"START_TIME"},
			{"label":"开始执行时间","dataIndex":"EXEC_TIME"},
			{"label":"执行结束时间","dataIndex":"END_TIME"},
			{"label":"运行时长"       ,"dataIndex":"DURATION",renderer:_timeDiffRender},
			//{"label":"自动重做次数","dataIndex":"RETRYNUM"},
			{"label":"日期参数","dataIndex":"DATE_ARGS"}
		],
		"events":{
			afterRender:function(){
				this.$el.find(".table-area").css("overflow","visible");
			},
			rowDblClick:function(index,data,_view){
					var proc_name=data.PROC_NAME;
					var _title=proc_name+"任务流程图";
					parent.openDataFlow(proc_name,_title,data.PROC_DATE,data.DATE_ARGS);
			},
			afterTabelBodyRender:function(){
				var _view = this;
				_view.$el.find("a#log").on("click",function(e){
					var $el = parent.$('#panel1');
					var seqno = $(e.currentTarget).attr("seq");
					var _procListStore = new Asiainfo.data.AsiaInfoJsonStore({
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
								+ '<div class="media-body" style="margin:0px 40px 40px 40px;">'
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
				_view.$el.find("a#dura").on("click",function(e){
					var _procName = $(e.currentTarget).attr("seq");
					var $el = parent.$('#panel1');
					if(_procName&&_procName.length>0){
						var _procListStore = new Asiainfo.data.AsiaInfoJsonStore({
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
									var _procTimerStore = new Asiainfo.data.AsiaInfoJsonStore({
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
									_procTimerStore.data.each(function(dt){
										_categories.push(dt.get("STATUS_TIME"));
										_series.push(dt.get("DURATION"));
									});
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
				_view.$el.find("a#relay").on("click",function(e){
					var _seqno = $(e.currentTarget).attr("seq");
					var _procName=$(e.currentTarget).attr("name");
					parent.openRelayCondition(_seqno,_procName);
				});
				_view.$el.find("a#force,a#pause,a#goon,a#redo,a#conti,a#pass,a#setPLevel,a#stop_drive").on("click",function(e){
					var _seqno = $(e.currentTarget).attr("seq");
					var _workType = $(e.currentTarget).attr("id");
				     var task_status= $(e.currentTarget).attr("task_status");
					//var _newLog = proc_log.getNewRecord();
					var finalSql="update proc_schedule_log  ";
					var execSql="";
					var res="";
					if(_workType=='pause'||_workType=='goon'){
						var alterStr = _workType=='pause'?"确定暂停程序?":"确定恢复程序?";
						if(confirm(alterStr)){
							execSql=finalSql + "set TASK_STATE='"+(0-task_status)+"' where seqno='"+_seqno+"' and  task_state='"+task_status+"'";
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
					}else if(_workType=='stop_drive'){
						//_log.set("TASK_STATE",2);
						if(confirm("停止触发?")){
							execSql=finalSql+" set where seqno='"+_seqno+"' and trigger_flag=1";
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

$(document).ready(function() {
	var curTeamCode = paramMap['TEAM_CODE'];
	curTeamCodeCondi = (typeof(curTeamCode)=="undefined" || curTeamCode =='' || curTeamCode == 'undefined' )?(''):("  and team_code = '"+curTeamCode+"' ")
   var timestamp = new Date().getTime();
	var formater = new Date();
	formater.setDate(formater.getDate()-1); 
	var _date = formater.format("yyyy-mm-dd hh:mm:ss").substr(0,10);
	var _condi=" and '"+timestamp + "'='" + timestamp + "' and run_freq<>'manual' and a.date_args = '"+_date+"' and task_state >-7 ";
	//_condi +=curTeamCodeCondi;
	curTeamCodeCondi="";
	var execSql = _realSql.replace("{}",_condi);
	var pageDefs = [ {
		id : "main-content1",
		title : "<div></div>",
		widgetDefs : implWidgets,
		stores : {
			'appEvaluation':new ve.SqlStore({
				sql:execSql
			}),
			'appStatic':new ve.SqlStore({
				sql:"select count(*) as total, sum(case when task_state=6 then 1 else 0 end ) as finish, sum(case when task_state=5 then 1 else 0 end ) as running, sum(case when task_state<=4 and task_state>-4 then 1 else 0 end ) as queue, sum(case when task_state=-7 then 1 else 0 end) as unqueue,sum(case when task_state>6 then 1 else 0 end ) as fail from proc_schedule_log where '" + timestamp + "'='" + timestamp + "' and date_args like '"+_date+"%'"+curTeamCodeCondi
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