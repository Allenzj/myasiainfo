/*
 * jQuery store - 基本元数据组件
 * 
 * Authors: wangqs
 * Web: http://wangqs/visizemodel/
 * 
 * Licensed under
 *   MIT License http://www.opensource.org/licenses/mit-license
 *   GPL v3 http://opensource.org/licenses/GPL-3.0
 *
 */
  

nameSpaceDef("AI.Field");
nameSpaceDef("AI.ToolBar");
nameSpaceDef("AI.Form");
nameSpaceDef("AI.Action");//常用操作
 
 
 
AI.Action = function() {
 return {
   dealSqlWithStore:function(cfgsql){///"select * from tab where id={store1.id}' and name={store2.area}" 
      var sql=cfgsql;
      if(sql.indexOf("{")==-1 || sql.indexOf("}")==-1) return sql;
     
      var i=0;
      while(i<5){
        var oldstr=sql.substring(sql.indexOf("{")+1, sql.indexOf("}"));
        var strArray=oldstr.split('.');
          
        if(strArray.length>=2){
          var tmpStore=ai.getCmp(strArray[0]);
          if(tmpStore && tmpStore.curRecord)
            sql=sql.replaceAll('{'+oldstr+'}',tmpStore.curRecord.get(strArray[1]));
        }
        i++;
     };
 
     return sql;
   },
   /* select * from tab where id={store1.id}' and name={store2.area} 某个store的当前记录的值
      {username},当前用户
      {userarea},当前用户归属的地市
      {today},当前日期,{today-1m}
      {CMPID},对象的ID，如{CITY}
   */
   dealSql:function(cfgsql,paraname){///复杂的参数替换，形成最终的运行sql
   	
	  var sql=cfgsql;
	  if(sql.indexOf("{")==-1 || sql.indexOf("}")==-1) return sql;
	  var strTemp=AI.Action.extractSqlObj(sql);
	  if(!strTemp) return;
	  var containObjs = strTemp.split(",");
	  if(!containObjs && containObjs.length==0) return;
	  for(var i=0;i<containObjs.length;i++){
	  	var objstr=containObjs[i];
	  	if(objstr.indexOf(".")==-1){
	  		  var cmp=ai.getCmp(objstr);
	  		  if(cmp && cmp.getValue()){
	  		  	sql = sql.replace("{"+objstr+"}",cmp.getValue());  
	  		  };
	  	};
	  	 
	  };
	  if(!paraname) paraname='';
	  ///外部参数替换
	  
	  ///用户身份信息替换处理
	     paramMap={};///外部参数
	     paramUser={};///用户相关的身份信息
	     paramUser['USERNAME']=_UserInfo.username ||'sys';
	     paramUser['USERCNNAME']=_UserInfo.usercnname || '系统管理员';
	     for(paraname in paramMap){
	  	    sql=sql.replace(new RegExp('{PARAM.'+paraname+'}',"gm"),paramMap[paraname]); 
	     };
	     for(paraname in paramUser){
	        sql=sql.replace(new RegExp('{USER.'+paraname+'}',"gm"),paramUser[paraname]); 
	     };
	    if(sql.indexOf("{")==-1 || sql.indexOf("}")==-1) return sql;
	  ///根据数据对象的参数处理
	  
	  sql=this.dealSqlWithStore(sql);
	  if(sql.indexOf("{")==-1 || sql.indexOf("}")==-1) return sql;
	  
		///工具栏参数替换
		var caluse = [];
		var where=" ";
		//if(sql.indexOf("{")==-1 || sql.indexOf("}")==-1) return sql;
		while(sql.indexOf("{now.")!=-1){
				var iPos=sql.indexOf("{now.");
				var dt=new Date();
				var format=sql.substr(iPos+5);
				format=format.substr(0,format.indexOf('}'));
				 
			  sql=sql.replaceAll("{now."+format+"}",dt.format(format));
			   
			};
    
		///组件对象的参数处理
		while(sql.indexOf("{")!=-1 && sql.indexOf("}")!=-1){
		  var newStr=-99999;
		  var oldstr=sql.substring(sql.indexOf("{")+1, sql.indexOf("}"));
		   
		  if(oldstr.indexOf(".")<0){  //某个组件对象的值
		  	var cmp=ai.getCmp(oldstr);
		  	if(cmp && cmp.getValue){
		  		 newStr=cmp.getValue();
		  	};
		  }
		  else{
				  var strArray=oldstr.split('.');
				  if(strArray[1]=='getwhere'){
				     var cmp=ai.getCmp(strArray[0]);
				     if(cmp && cmp.getValue)newStr=cmp.getwhere();
		  	     else newStr=' 1=1 '
				  }
				  else{
				    var store=ai.getCmp(strArray[0]);
				    if(store){////store
				    	 if(store.curRecord) record=store.curRecord
				    	 else if(store.getCount()>0) record=store.getAt(0);
				    	 if(record){
				    	 	 newStr=record.get(strArray[1]);
				    	};
				    }
				 }
		   }
		  sql=sql.replace("{"+oldstr+"}",newStr);
		}
		return sql;
   },
   checkChina:function(str){ ///检查是否含有中文，存在则返回false
		 
			if(/.*[\u4e00-\u9fa5]+.*$/.test(str)) 
			{ 
			   return true; 
			} 
			return false; 
   }, 
   extractSqlObj:function(sql){  ///根据脚本中,提取{}的变量
	    var i=0;
	    var result="";
      while(i<10){
        var oldstr=sql.substring(sql.indexOf("{")+1, sql.indexOf("}"));
        if(oldstr){ 
        	if(!result) result=oldstr
        	else result+=","+oldstr;
          sql=sql.replaceAll('{'+oldstr+'}',"");
       }
        i++;
     };
     return result;
   },
   actFun:function(clickfun,clickpara,befoeSaveFn,cfg){
   	 	 
	  var objs= clickpara.split(',');
	  if( clickfun=='refresh'){
    for(var i=0;i<=objs.length;i++){
	   	this.RefreshView(objs[i]); 
	   } 
	  }
 
	else if( clickfun=='openmodel'){
		var _url=this.DealSql(clickpara);
		 
		_url=_url.replaceAll('%&',',');
		Asiainfo.ShowWin('信息',_url)
	}
	else if( clickfun=='openwin'){
		var _url=this.DealSql(clickpara);
		var paras=_url.split(',')
		for(var i=0;i<paras.length;i++){
			if(typeof paras[i] == 'string')
				paras[i]=paras[i].replaceAll('%&',',');
		}
		if(paras.length==3)Asiainfo.addTabSheet(paras[0],paras[1],paras[2])
		else if(paras.length==1)Asiainfo.addTabSheet(this.getId(),'详细',_url)
	}
	else if( clickfun=='openoutwin'){
		var _url=this.DealSql(clickpara);
		window.open(_url); 
	}
	else if( clickfun=='wizard'){
		var paras=clickpara.split(',')
		var wizCmp=Ext.getCmp(paras[0]);
		if(!wizCmp) return;
		if(paras[1]=='next') wizCmp.onNextClick()
		else if(paras[1]=='pre') wizCmp.onPreviousClick()
		else if(paras[1]=='finish') wizCmp.onFinish()
		else wizCmp.setActiveStep(parseInt(paras[1]));
	}
	else if( clickfun=='save'){
		for(var i=0;i<objs.length;i++){
		  if(Ext.StoreMgr.get(objs[i]))
		  Ext.StoreMgr.get(objs[i]).commit() ;
			//if(_main.CompMgr.dsArray[objs[i]])_main.CompMgr.dsArray[objs[i]].commit();
		}
	}
	
	else if( clickfun=='upstore'){
		 
		 var _ds=minderGraph.allWidget[objs[0]].getStore();
	   
	  var newSql = AI.Action.dealSql(_ds.oldsql);
	  if(newSql!=_ds.oldsql){
	   
	  	_ds.select(newSql);
	  };
	  
	}
	else if( clickfun=='query'){
		 var _ds=ai.getCmp(objs[0]);
		 if(!_ds){alert("查询参数第一个变量storeID,找不到对象或没有指定");return false};
	   
	   var newSql = _ds.oldsql ;
	   
	   var _aitbar=ai.getCmp(objs[1]);
	   
	   if(_aitbar){ 
	   	var where = _aitbar.getWhere()+"";
	   	//alert("查询参数第二个变量为工具栏ID,找不到对象或没有指定");
	   	
	   	if(where && where.length>5){
	   	   if(newSql.toLowerCase().indexOf(" where ")>0) 
	   	     newSql = newSql+" and " +where
         else 
         	 newSql =newSql+" where "+where;
      };
	   };
	   
	   
	  newSql = AI.Action.dealSql(newSql);
	   
	 
	  if(newSql!=_ds.oldsql){
	  	_ds.select(newSql);
	  };
	  
	}
	else if( clickfun=='add'){
		var _ds=Ext.StoreMgr.get(objs[0]);
		if(!_ds) return ;
		var rec=_ds.getNewRecord();
		_ds.add(rec);
		//dataManager.fresh(_ds,null,_ds.itemindex);
	}
	else if( clickfun=='delete'){
		 
		var _ds =  Ext.StoreMgr.get(objs[0]);
		var commitFlag = objs[1];

		if(!_ds)return ;
		Ext.Msg.confirm('信息','确定要删除当前记录吗?',function (btn){

			if(btn=='yes'){
				var rec=_ds.curRecord;
				if(rec){
					_ds.remove(rec);
					if(commitFlag && commitFlag=='true') _ds.commit(false);
					dataManager.fresh(_ds,null,_ds.itemindex);

				}
	
			}

		})
	}
	else if( clickfun=='help'){
	   Asiainfo.ShowWin('帮助信息','../forum/help.html?MODELCODE='+Asiainfo.GerUrlInfo(window.location,'Pathname'))
	}
	else if( clickfun=='pickobj'){

		baseFun.loadScript("../asiainfo/form/searchWin4.js");

		try{

			eval(this.clickpara);

		}catch(e){

			alert('按钮配置错误'+this.text+','+this.clickpara);

		}
		mywin=searchWin.init(funAftPickTo,_main.CompMgr.DealSql(this.listvalue))

	}
	else if( clickfun=='expdata'){
           if(ai.getCmp(objs[0])) this.expData(ai.getCmp(objs[0]));
	} 
   },
   RefreshView : function(objcode){
   	 
   	   if(!objcode) return;
   	   
   	   var store = Ext.StoreMgr.get(objcode);
   	   
    	   if(store){
    	  
    	    var newsql=this.DealSql(store.oldSql,store.paraname);
	       
	    if (newsql!=store.sql){
		     store.updateSql(newsql);
		     store.select();
	     };
	     if(store.cmps && store.cmps.length>0){
		   
		   for(var i=0;i<store.cmps.length;i++){
		   	if(store.cmps[i].RefreshView) store.cmps[i].RefreshView(); 
		   }
		}
	   }
	   else {
	   var cmp=Ext.getCmp(objcode);
	   if(cmp && cmp.RefreshView){
	      cmp.RefreshView();
	   }
	   else if(cmp && cmp.mgrCmp &&  cmp.mgrCmp.RefreshView){
	   	cmp.mgrCmp.RefreshView();
	   }
	}
   },
 
  expData:function(gd_result){
  	
  	var cm = gd_result.config.columns;
	var cmLen = cm.length;
	var cmHeader = [];
	var dataIndex=[];
	var start=0;
	var exportSql = gd_result.exportSql || gd_result.store.sql.replace(/@/g,'+').replace(/\$/g,'&'); 
	var dataSource = gd_result.store.dataSource || '';
	var fieldmap=gd_result.store.map;
	var fieldmapStr="";
	if(fieldmap) fieldmapStr = ai.encode(fieldmap);
 
	//if(cm.getColumnHeader(0).indexOf('x-grid3-hd-checker') == -1) start=0;
	// for(var i=start;i<cmLen;i+=1){
	// 	 dataIndex.push(cm[i].name); 
	// };
	for(var i=start;i<cmLen;i+=1){
		if(cm[i].display != 'none'){
			var header ={};
			header["dataIndex"] = cm[i].dataIndex;
			header["label"] = cm[i].header;
			cmHeader.push(header);
		}
	};
 	
	this.FormSubmit('/'+contextPath+'/ve/download',{
		sql:exportSql,
		dataSource:dataSource,
		header:ai.encode(cmHeader),
		fileName:"DATA_"+new Date().format("yyyymmddhhmmss"),
		fileType:"excel"
	});
  },
  FormSubmit : function(url,params){ ///模拟表单提交，经常用于下载所用
	//手工创建form表单
	var submitForm = document.createElement("FORM");
	//手工放置在body中
	document.body.appendChild(submitForm);
	//设置提交方式
	submitForm.method = "POST";
	//在表单中设置参数
	for(var key in params){
		var value = params[key];
		var arr = [];
		if(typeof value=='string'){
			arr.push(value);
		}else{
			arr = value;
		}
		for(var i=0,l=arr.length;i<l;i+=1){
			var newElement = document.createElement("input"); 
			newElement.type='hidden';
			newElement.name = key;
		 	submitForm.appendChild(newElement);
		 	newElement.value = (arr[i]);
		}
	}
	//手工设置提交地址
	submitForm.action=url;
	//手工提交
 	submitForm.submit();
  }
}}();
 
AI.Toolbar=function(config){
//	ai.registerCmp(config.id||(new Date().getTime()),this);
	this.config=config;
	this.fields=[];
	var containerId = config.containerId;
	$('#'+containerId).addClass("toolbar");
	$('#'+containerId).append('<ul id="ul_'+containerId+'" class="nav navbar-nav"></ul>'); 
	for(var i=0;i<config.items.length;i++){
		var item = config.items[i];
		item.containerId ='ul_'+ containerId;
		item.parent = this;
		item.parenttype='toolbar';
		this.fields.push(new AI.FormField(item));
	};
	$('#'+containerId).append('<br><div class="line line-dashed b-b line-lg pull-in" style="margin-left:20px;margin-right:20px;"></div>');
};
 
AI.Toolbar.prototype.getFieldVal=function(fieldName){
	var result = "";
	for(var i=0;i<this.fields.length;i++){
		var field = this.fields[i];
		if(field.id == fieldName){
			 result = field.getValue();
		}
	}
	return result;
};
AI.Toolbar.prototype.fieldChange=function(fieldName,newVal){
	 if(this.config.fieldChange){
	 	this.config.fieldChange(fieldName,newVal);
	 };
};
AI.Toolbar.prototype.getAllFieldValue=function(){///得到当前所有字段的值
	var result={};
	for(var i=0;i<this.fields.length;i++){
		 var field=this.fields[i];
		 if(field.config.type=='button') continue;
		 result[field.id]=field.val;
	};
	return result;
};
AI.Toolbar.prototype.getWhere=function(){///得到当前所有字段的值
	  var caluse=[];
		for(var i=0;i<this.fields.length;i++){
			var field=this.fields[i];
			 
      if(!field.config) continue;
      if(!field.config.where) continue;
			var fdVal=field.getValue()||field.getRawValue();
			if(!fdVal)continue;
			fdVal=fdVal.trim();
			if(!fdVal ||fdVal=="") continue;
	   if(fdVal&&field.config.type=='date')fdVal=Ext.util.Format.date(fdVal,'Y-m-d');
      if(field.cofing&&field.cofing.caseType=='upper') fdVal=fdVal.toUpperCase()
      if(field.cofing&&field.cofing.caseType=='lower') fdVal=fdVal.toLowerCase();
      	    fdVal=fdVal.trim();
			if(fdVal!='all' && fdVal!='所有')
			  caluse.push(field.config.where.replace('{'+field.id+'}',fdVal).replace('{'+field.id+'}',fdVal).replace('{'+field.id+'}',fdVal));
		}
		var where=" ";
		if(caluse.length!=0)where+=' '+caluse.join(' and ')
	 
	 
		return where;
	  
};
AI.Form=function(config){
	this.fields=[];
	this.config = config;
	if(!config.labelColSpan)config.labelColSpan=2;
	this.store=config.store;
	var containerId = config.containerId;
	$('#'+containerId).addClass("form-horizontal");
	if(config.fieldsets && config.fieldsets.length>0){
		for(var i=0;i<config.fieldsets.length;i++){
			var fieldset = config.fieldsets[i];

			var $setBlock = $('<fieldset id="'+containerId+'_set_'+i+'"> <legend  style="font-size:15px; color:#788188;cursor:pointer"><a href = "#"><i class="icon-chevron-up fieldset"></i></a>'+fieldset.legend+'</legend>').appendTo($('#'+containerId));
			$("legend",$setBlock).click(function(){
				var collapseDiv = $("i",$(this));
				if(collapseDiv.hasClass("icon-chevron-up")){
					$("i",$(this)).removeClass("icon-chevron-up fieldset");
					$("i",$(this)).addClass("icon-chevron-down fieldset");
					$(".fieldset-ul",$(this).parent()).toggle();
				}else {
					$("i",$(this)).removeClass("icon-chevron-down fieldset");
					$("i",$(this)).addClass("icon-chevron-up fieldset");
					$(".fieldset-ul",$(this).parent()).show();
				}
			});
			var $set =$('<div id="set_'+i+'" class="fieldset-ul"></div>').appendTo($setBlock);
			for(var j=0;j<fieldset.items.length;j++){
				var item = fieldset.items[j];
				item.containerId = 'set_'+i;
				item.parenttype='form';
				item.parent = this;
				if(!item.labelColSpan) item.labelColSpan=config.labelColSpan||2;
				this.fields.push(new AI.FormField(item));
			};
		};
	}else if(config.rownums && config.rownums.length > 0){
		for(var i=0;i<config.rownums.length;i++){
			var rownum = config.rownums[i];
			
			var $rowhtml = $('<div class="row table-bordered" id="'+containerId+'_row_'+i+'"></div>').appendTo($('#'+containerId));
			var rowWidthAvg = 0;
			if(rownum.items.length > 0){
				rowWidthAvg = (100/rownum.items.length).toFixed(4);
			}
			var rowWidthLast = Number(Number(rowWidthAvg)+(100 -(rowWidthAvg*rownum.items.length))).toFixed(4) ;
			for(var j = 0;j <rownum.items.length;j++){
				if(j == rownum.items.length-1){
					var $rowdiv = $('<div id="row_'+i+'_'+j+'" class="col-sm-2" style="border-right: 1px solid #ddd;width:'+rowWidthLast+'%"></div>').appendTo($rowhtml);
				}else{
					var $rowdiv = $('<div id="row_'+i+'_'+j+'" class="col-sm-2" style="border-right: 1px solid #ddd;width:'+rowWidthAvg+'%"></div>').appendTo($rowhtml);
				}
				
				var item = rownum.items[j];
				item.containerId = 'row_'+i+'_'+j;
				item.parenttype='form';
				item.parent = this;
				if(!item.labelColSpan) item.labelColSpan=config.labelColSpan||2;
				this.fields.push(new AI.FormField(item));
			}
		}
	}else{
		for(var i=0;i<config.items.length;i++){
			var item = config.items[i];
			if(!item) continue;
			item.containerId = containerId;
			item.parent = this;
			item.parenttype='form';
			if(!item.labelColSpan) item.labelColSpan=config.labelColSpan||2;
			if(config.cardType&&config.cardType==true){item.type='card';}
			this.fields.push(new AI.FormField(item));
		}
  }
};
AI.Form.prototype.rebuildField=function(fieldName,fieldConfig){
	for(var j=0;j<this.config.items.length;j++){
		var item = this.config.items[j];
		if(item.fieldName==fieldName){
			item = fieldConfig||item;
			item.containerId = 'set_'+i;
			item.parent = this;
			this.fields[j]=new AI.FormField(item);
		}
	};
};
AI.Form.prototype.fieldChange=function(fieldName,newVal){
	  if(this.store && this.store.curRecord){
	  		if(fieldName.indexOf('--')>-1){
	  			var _fieldname = fieldName.split('--')[0];
	  			var _key = fieldName.split('--')[1];
	  			var _record = this.store.curRecord.get(_fieldname);
	  			var changeVal = {};
	  			changeVal[_key] = newVal;
	  			_record = (typeof _record === 'undefined') ? {} : JSON.parse(_record);
	  			var _value = $.extend(_record,changeVal);
	  			this.store.curRecord.set(_fieldname,JSON.stringify(_value));
	  		}else{
	  			this.store.curRecord.set(fieldName,newVal);
	  		}
	   		
	 	}; 
	 if(this.config.fieldChange){
	 	this.config.fieldChange(fieldName,newVal);
	 };
	
};
AI.Form.prototype.getAllFieldValue=function(){///得到当前所有字段的值
	var result={};
	for(var i=0;i<this.fields.length;i++){
		 var field=this.fields[i];
		 try{
		 	field.val=field.getValue();
		 }catch(e){
		 	console.log(e);
		 }
		 if(field.config.type=='button') continue;
		 result[field.id]=field.val;
	};
	return result;
};
AI.Form.prototype.getFieldValue=function(fieldName){///得到当前所有字段的值
	for(var i=0;i<this.fields.length;i++){
		 var field=this.fields[i];
		 if(field.id==fieldName) return field.val;
	};
	return "";
};
AI.FormField=function(config){
	this.val=config.value||"";//当前值
	this.rawVal=(config.valname||config.value)||"";///当前值对应的名称，适应于select,combox,checkbox,radio
	if(config.fieldName) config.fieldName = config.fieldName.replace('.','--');
	if(!config.id) config.id=config.fieldName;
	this.id=config.id||config.fieldName;
	this.type =config.type;
	this.fieldName = config.fieldName;
	this.config = $.extend({}, this.defaults, config);
	this.checkItems = config.checkItems;
	this.parentItems = config.parent.config.items;
	this.parentFieldsets = config.parent.config.fieldsets;
	this.dependencies = config.dependencies;

	/*
	 * 配置联动取值时，当被关联字段为空，关联字段取全部还是取空，
	 * 在这里加一个配置项，DEFAULT_ALL_SELECT为true时表示取空，false为取全部
	 * 允许在配置表单item时制定allSelect的值来修改
	 */
	this.DEFAULT_ALL_SELECT = config.allSelect||true; 
	
	////分析依赖对象
	if(config.storesql){
	var parentCmp = AI.Action.extractSqlObj(config.storesql);
	 if(parentCmp){
	    	 config.dependParent=parentCmp;
	    	 var parentCmps=parentCmp.split(",")
	    	 for(var i=0;i<parentCmps.length;i++){
	    	    var parentCmp=ai.getCmp(parentCmps[i]);
	    	    if(parentCmp){
	    	    	 if(!parentCmp.config.child) parentCmp.config.child=this.id
	    	    	 else if(parentCmp.config.child.indexOf(this.id)<0) parentCmp.config.child+=","+this.id;
	    	    	}
	    	 };
	 };
	};
	if(this.config.parent && this.config.parent.store){
		var store = this.config.parent.store;
		if(!store.curRecord && store.getCount()>0) store.curRecord=store.getAt(0);
		if(store.curRecord && store.curRecord.get(this.id)!= undefined){
			this.config.value=store.curRecord.get(this.id);
		}
	};
	this.init();
//  ai.registerCmp(config.id,this); 
};
AI.FormField.prototype.getParent =function(){
	return this.config.parent;
}; 
AI.FormField.prototype.fieldInfluence = function(item,val){
	var self=this;
	var flag;
	
	if(item.dependencies){
		val = val&&val.toString().length>0?val:undefined;
		flag = eval(item.dependencies.replace(/{val}/g,val));
	}else{
		flag = true;
	}
	if(flag){
		if(item.type&&item.type == 'radio'){
			$("input[name='"+item.fieldName+"']").parents('.form-group').show();
		}else if(item.type&&item.type == 'checkbox'){
			$("label[for='"+item.fieldName+"']").parents('.form-group').show();
		}else{
			$("#"+item.id).parents('.form-group').show();
		}
	}else{
		if(item.type&&item.type == 'radio'){
			$("input[name='"+item.fieldName+"']").parents('.form-group').hide();
		}else if(item.type&&item.type == 'checkbox'){
			$("label[for='"+item.fieldName+"']").parents('.form-group').hide();
		}else{
			$("#"+item.id).parents('.form-group').hide();
		}
	}
	if(item.type=="combox"){
		var allOptions=this.getOptions(self.rebuildSQL(item.storesql,val),item.value);
		var optionsHtml='<option value=""> </option>';
		for(var i=0;i<allOptions.length;i++){
			var option=allOptions[i];
			var isChecked=option.selected?'selected=true':'';
			optionsHtml+='<option value="'+option.id+'" '+isChecked+'>'+option.name+'</option>';
		}
		$("#"+item.containerId).find("select#"+item.fieldName).empty().append(optionsHtml);
	}else if(item.type=="selbox"){
		function afterSelect(records){
			var val="";
			for(var i=0;i<records.length;i++){
				var valTmp = records[i].get('KEYFIELD')||records[i].get('VALUES1');
				val += ((i==0?"":",")+valTmp);
			};
			$("#"+item.containerId).find("input#"+item.fieldName).val(val);
			var fields = self.config.parent.fields;
			for(var j=0;j<fields.length;j++){
				var field = fields[j];
				if(field.id==item.fieldName){
						field.triggerFieldChage(val);
				}
			}
		}; 
		$("#"+item.containerId).find("input#"+item.fieldName).parent().find(".input-group-addon").off("click").on("click",
			function(){
				var selectedValue = $("#"+item.containerId).find("input#"+item.fieldName).val();//选中的值
				var selBox=new SelectBox({sql:self.rebuildSQL(item.storesql,val),callback:afterSelect,selectedValue:selectedValue});
				selBox.show();
				return true;
			});
	}else if(item.type=="mapbox"){
		function afterSelect(records){
			var keyval="";
			var valueval ="";
			for(var i=0;i<records.length;i++){
				var keyvalTmp = records[i].get('KEYFIELD')||records[i].get('VALUES4');
				keyval += ((i==0?"":",")+keyvalTmp);
				var valuevalTmp = records[i].get('VALUEFIELD')||records[i].get('VALUES1');
				valueval += ((i==0?"":",")+valuevalTmp);
			};
			var val = keyval+"|"+valueval;
			$("#"+item.containerId).find("input#"+item.fieldName).val(valueval);
			var fields = self.config.parent.fields;
			for(var j=0;j<fields.length;j++){
				var field = fields[j];
				if(field.id==item.fieldName){
						field.triggerFieldChage(val);
				}
			}
		}; 
		$("#"+item.containerId).find("input#"+item.fieldName).parent().find(".input-group-addon").off("click").on("click",
			function(){
				var selectedValue = $("#"+item.containerId).find("input#"+item.fieldName).val();//选中的值
				var selBox=new SelectBox({sql:self.rebuildSQL(item.storesql,val),callback:afterSelect,selectedValue:selectedValue});
				selBox.show();
				return true;
			});
	}else if(item._fieldInfluence){
		item._fieldInfluence(item,val);
	}
};
AI.FormField.prototype.rebuildSQL = function(sql,val){
	var rs="";
	if(this.DEFAULT_ALL_SELECT||val){
		rs = sql.replace(/{val}/g,val);
	}else{
		var sqlArr = sql.split(/\swhere\s|\sand\s/i);
		for(var i=0;i<sqlArr.length;i++){
			var _sqlSplit = sqlArr[i];
			if(/{val}/g.test(_sqlSplit)){
				sqlArr[i] = " 1=1 "
			}
			rs += (sqlArr[i]+(i==0&&sqlArr.length!=1?" where ":i==sqlArr.length-1?"":" and "));
		}
	}
	return rs;
};
AI.FormField.prototype.init = function(){
	this.control = this.getElement(this.config);
	var self=this;
	//if(self.dependencies&&self.dependencies.length>0){
		for(var i=0;i<self.config.parent.fields.length;i++){
			var _item = self.config.parent.fields[i].config;
			if(_item.checkItems&&_item.checkItems.indexOf(self.config.fieldName)!=-1){
				self.config.dep = _item.fieldName;
				if(_item.type&&_item.type=='mapbox'){
					self.fieldInfluence(self.config,_item.value&&_item.value.toString().length>0?_item.value.substring(0,_item.value.indexOf("|")):_item.value);
				}else{
					self.fieldInfluence(self.config,_item.value);
				}
			}
		}
	//}
	$("#"+this.id,this.control).change(function(){
		self.triggerFieldChage(self.getValue());
	});
};
AI.FormField.prototype.triggerFieldChage = function(newVal,newRawVal){///向父窗口通知数据变化
	this.val=newVal;
	this.rawVal=newRawVal;
	var self = this;
	if(self.checkItems&&self.checkItems.length>0){
		if(self.parentItems&&self.parentItems.length > 0){
			for(var i=0;i<self.parentItems.length;i++){
				var _item = self.parentItems[i];
				if(self.checkItems.indexOf(_item.fieldName)!=-1){
					_item.dep = self.fieldName;
					if(self.type&&self.type=='mapbox'){
						self.fieldInfluence(_item,newVal&&newVal.toString().length>0?newVal.substring(0,newVal.indexOf("|")):newVal);
					}else{
						self.fieldInfluence(_item,newVal);	
					}
					
				}
			}
		}
		if(self.parentFieldsets&&self.parentFieldsets.length >0){
			for(var j=0;j<self.parentFieldsets.length;j++){
				var _fieldset = self.parentFieldsets[j];
				for(var k=0;k<_fieldset.items.length;k++){
					var _item = _fieldset.items[k];
					if(self.checkItems.indexOf(_item.fieldName)!=-1){
						_item.dep = self.fieldName;
						if(self.type&&self.type=='mapbox'){
							self.fieldInfluence(_item,newVal&&newVal.toString().length>0?newVal.substring(0,newVal.indexOf("|")):newVal);
						}else{
							self.fieldInfluence(_item,newVal);	
						}
					}
				}
			}
		}
		
	}
	if(this.config.fieldChage){
		this.config.fieldChage(newVal);
	};
	if(this.config.parent && this.config.parent.fieldChange){
		this.config.parent.fieldChange(this.id,newVal,newRawVal);
	}
	//更新依赖对象
	if(this.config.child){
		var cmp = ai.getCmp(this.config.child);
		cmp.chageOptions(); 
	}
	var cmpId = this.id;
	if(typeof(minderGraph)!='undefined' && minderGraph && minderGraph.allWidget){
		var thisWidget = minderGraph.allWidget[cmpId];
		if(thisWidget) thisWidget.publish("fieldchange",newVal,newRawVal);
	}
};
AI.FormField.prototype.getRawValue = function(){
	this.getValue();
	return this.rawVal||this.value;
};
AI.FormField.prototype.getValue = function(){
	var $this = $("#"+this.id)

	var itemcfg=this.config;
	var fieldName=itemcfg.fieldName;
	var type=itemcfg.type;

	var newVal="",newRawVal="";
	var $inputField=this.control.find("#"+fieldName);

	if(type=='checkbox' || type=='mulitselect'){
		var newVal="",newValName="";
		var containerId="container_"+(this.id);
		var $inputField = $("#"+containerId).find(":checkbox");

		for(var i=0;i<$inputField.length;i++){
			var item = $inputField[i];
			if($(item).is(':checked')){
				if(newVal){
					newVal+=","+$(item).attr('value');
					newValName+=","+$(item).attr("name");
				}else {
					newVal=$(item).attr('value');
					newValName=$(item).attr("name");
				};
			}
		};
		$("#"+this.id).val(newValName);
		this.val=newVal;
		this.rawVal = newValName;
	}else if(type=='radio'){
		$inputField = $("input:radio[name="+itemcfg.id+"]");
		for(var i=0;i<$inputField.length;i++){
			var item = $inputField[i];
			var result = $(item).attr('checked');
			if($(item).is(':checked')){
				newVal=$(item).attr('value');
				newValName=$(item).attr("name")
				this.val=newVal;
				this.rawVal = newValName;
			};
		};
	}else if(type=='combox'){
		var $select = $("select#"+this.id);
		var newVal = $select.val();
		var newRawVal = $("select#"+this.id+" option[value='"+newVal+"']").text();
		if($select.hasClass('custom-val')){
			newVal = newRawVal = $("input[name='"+this.id+"']").val();
		}
		this.val=newVal;
		this.rawVal = newRawVal;
	}else if(type=='textarea'){
		newVal=$inputField.val();
	}else if(type=='seltag'){
		//初始化对象
		var tagEle=$("#"+this.id+" .tag-list").tags();
		//取值
		newVal=tagEle.tagsArray1;
	}else if(type=='mapbox'){
		newVal = this.val;
	}else{
		newVal=$inputField.val();
	};
	this.val=newVal;
	return newVal;
};
AI.FormField.prototype.setValue = function(newVal){
//	alert('kkk');
	$("#"+this.config.id).val(newVal);
	if(this.config.type=="checkbox"){
		  //alert("kkk");
	}else if(this.config.type=="seltag"){
		//初始化对象
		 var tagEle=  $("#"+this.id+" .tag-list").tags();
		 for(var i=0;i<newVal.length;i++){
		 	//添加新的tag
		 	var option=newVal[i];
		 	 tagEle.addTag(option);
		 	}
		};
};
AI.FormField.prototype.getLabel=function(elmentcfg){
   //return '<label style="float:left;margin-right:5px">'+elmentcfg.label+'</label>';
   return (elmentcfg.label||elmentcfg.fieldLabel)+(elmentcfg.notNull=='N'?'<b><font color=red ">*</font></b>':'');
};
AI.FormField.prototype.getOptions=function (storesql,selVal,elementType,elmentcfg){  ///根据配置返回一个数组，包含key,value,当前选中的值
	var self=this;
	var allOptions=[];//{id,name}
	var dataSource=null;
	if(elmentcfg!=null&&elmentcfg!=''&&elmentcfg!='undefined'){
		dataSource=elmentcfg.dataSource;
	}
	
	var isSelVal=function(optionsId){
		if(selVal&&elementType&&elementType=='checkbox'){
			var checkVals = selVal.split(",");
			var checkSel = false;
			for(var m in checkVals){
				if(checkVals[m]&&optionsId&&(checkVals[m].toString().trim()==optionsId.trim())){
					checkSel = true;
					break;
				}
			}
			return checkSel;
		}else{
			return selVal&&optionsId?(selVal.toString().trim()==optionsId.trim()):false;
		}
	};
	if(storesql){
		if(storesql.toLowerCase().indexOf('select ')!=-1 &&
		storesql.toLowerCase().indexOf(' from ')!=-1){
			var store='';
			if(dataSource!=null||dataSource!=''){
					store=ai.getStoreData(self.rebuildSQL(storesql),dataSource);
			}else{
				store=ai.getStoreData(self.rebuildSQL(storesql));
			}
			var attrNames=store&&store.length>0?ai.getJsonAttrName(store[0]):'';
			for(var i=0;store&&i<store.length;i++){
				var r=store[i];var optionRec={};
				for(var k in r){
					optionRec[k.toLowerCase()]=r[k];
				}
				optionRec.id=r[attrNames[0]];
				optionRec.name=r[attrNames.length==1?attrNames[0]:attrNames[1]];
				optionRec.selected=isSelVal(r[attrNames[0]]);
				allOptions.push(optionRec);
			}
		}else if(storesql.indexOf("|")>=1){ //1,中国|2,美国
			var tmpArray=storesql.split("|");
			for(var i=0;i<tmpArray.length;i++){
				var option=tmpArray[i];
				allOptions.push({
					id:option.split(",")[0]
					,name:option.split(",")[1]
					,selected:isSelVal(option.split(",")[0])
				});
			}
		}else if(storesql){
			var tmpArray=storesql.split(",");
			for(var i=0;i<tmpArray.length;i++){
				allOptions.push({
					id:tmpArray[i]
					,name:tmpArray[i]
					,selected:isSelVal(tmpArray[i])
				});
			}
		}
	}
	return allOptions;
};
AI.FormField.prototype.getItemValue=function (elementcfg){
	var result =  elementcfg.value;
	if(this.config.store){
		var curRecord=this.config.store.getAt(0);
		var fieldName=elementcfg.fieldName;
		result = curRecord.get(fieldName)||elementcfg.value;
	}
  return  result;
};
AI.FormField.prototype.getElement=function(elementcfg){
	elementcfg.value=this.getItemValue(elementcfg) ;
	var formField=null;
	switch (elementcfg.type) {
		case 'text' :formField= this.buildTextElement(elementcfg);break;
		case 'password' :formField= this.buildTextElement(elementcfg);break;
		case 'textfield' :formField= this.buildTextElement(elementcfg);break;
		case 'hidden' :formField= this.buildTextElement(elementcfg);break; 
		case 'text-button' :formField= this.buildTextButtonElement(elementcfg);break; 
		case 'file' :formField= this.buildFileElement(elementcfg);  break;
		case 'radio' :formField= this.buildRadioElement(elementcfg); break;
		case 'radio-custom' :formField= this.buildRadioElement1(elementcfg); break;
		case 'checkbox' :formField= this.buildCheckBoxElement(elementcfg);break;
		case 'textarea' :formField= this.buildRemarkElement(elementcfg); break;
		case 'combox' :formField= this.buildComboxElement(elementcfg); break;
		case 'mulitselect' :formField= this.buildMulitselectElement(elementcfg); break;
		case 'mulitLevel' :formField= this.buildMulitLevelElement(elementcfg); break;
		case 'mulitselect2' :formField= this.buildMulitselectElement2(elementcfg); break;
		case 'selectList' :formField= this.buildSelectListElement(elementcfg); break;
		case 'date' :formField= this.buildDateElement(elementcfg);break;
		case 'daterange' :formField= this.buildDateRangeElement(elementcfg);break;
		case 'color':formField= this.buildColorElement(elementcfg);break;
		case 'html' :formField= this.buildHtmlElement(elementcfg);break;
		case 'imgpicker' :formField= this.buildImgPicker(elementcfg);break;
		case 'button':formField= this.buildButton(elementcfg);break;
		case 'buttongroup':  formField= this.buildButtonGroup(elementcfg);break;
		case 'dropmenu': formField = this.buildDropMenu(elementcfg);break;
		case 'selbox' : formField= this.buildSelBoxElement(elementcfg);break;
		case 'mapbox' : formField= this.buildMapBoxElement(elementcfg);break;
		case 'pick-grid' : formField= this.buildSelBoxElement(elementcfg);break;
		case 'seltag' : formField= this.buildSelTagElement(elementcfg);break;
		case 'card' : formField= this.buildCard(elementcfg);break;
		default:
			alert('未知组件类型:'+elementcfg.type);break;
	}
	return formField;
};

AI.FormField.prototype.buildCard=function(elementcfg){
	var html = '<div class="col-md-6"><h4><strong>'+ (elementcfg.value||'未知') +'</strong><p><a>'+this.getLabel(elementcfg)+'</a></p></h4></div>';
	var $that=$(html).appendTo($("#"+elementcfg.containerId));
	return $that;
};

AI.FormField.prototype.buildTextElement=function(elmentcfg){
    	var label =this.getLabel(elmentcfg);
    	var value=elmentcfg.value;
    	var tip = elmentcfg.tip;
    	var popover = elmentcfg.popover;
    	var notNullValue=elmentcfg.notNull;
    	var fieldName=elmentcfg.fieldName||label;
    	var elementType = elmentcfg.type || "text";
    	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
    	var labelColSpan = elmentcfg.labelColSpan||2;
    	var popoverHtml = "";
    	if(popover)popoverHtml = '<span id="popover-btn" class="glyphicon glyphicon-question-sign" style="cursor:pointer;padding:10px;" data-toggle="popover" data-content="'+popover+'" data-placement="right"  aria-hidden="true"></span>';
    	var tipHtml="";
    	if(tip) tipHtml='<span class="help-block text-warning">'+tip+'</span>';
    	if(elmentcfg.parenttype=='form'){
    	var html= '<div class="form-group form-group-sm">'
   +	'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>' 
   +  '<div class="col-sm-'+(12-labelColSpan)+'">'
   +  '   <input type="'+elementType+'" class="form-control input-sm" id="'+fieldName+'" style="float:left;width:'+(elmentcfg.width||220)+'px" type="text" notNull="'+notNullValue+'" value="'+(value||"")+'" '+readOnly+'>'
   + popoverHtml+tipHtml
   + '</div>'
   +'</div>';
   }else{
    	if(elmentcfg.subtype && elmentcfg.subtype=='inline'){
   		var html= '<li style="margin-left:3px"> <input type="'+elementType+'" class="form-control" id="'+fieldName+'" style="width:'+(elmentcfg.width||220)+'px" type="text" value="'+(value||"")+'" placeholder="'+label+'"></li>'
 	 	}
 	else {var html= '<li >'
 	  +'<label class="navbar-label">'+label+'</label>'
 	  + '   <input type="'+elementType+'" class="form-control" id="'+fieldName+'" style="width:'+(elmentcfg.width||220)+'px" type="text" value="'+(value||"")+'">'
 	  +'</li>'
 	 }
   };
	var $that=$(html).appendTo($("#"+elmentcfg.containerId));
	$that.find("#popover-btn").popover();
	$that.find("#popover-btn").on('click',function(){
		$that.find('#popover-btn').toggleClass('glyphicon-question-sign').toggleClass('glyphicon-info-sign');
	});
	if(elmentcfg.type==='hidden'){
		$that.hide();
	}
	return $that;
 };
 
 AI.FormField.prototype.buildTextButtonElement=function(elmentcfg){
	 
	 var label=elmentcfg.label||elmentcfg.fieldLabel;
	 var label =this.getLabel(elmentcfg);
	 var value=elmentcfg.value;
	 var tip = elmentcfg.tip;
	 var notNullValue=elmentcfg.notNull;
	 var fieldName=elmentcfg.fieldName||label;
	 var elementType = elmentcfg.type || "text";
	 var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	 var labelColSpan = elmentcfg.labelColSpan||2;
	 var tipHtml="";
	 if(tip) tipHtml='<span class="help-block text-warning">'+tip+'</span>'
	 var html= '<div class="form-group form-group-sm">'
       +	'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>' 
       +  '<div class="col-sm-'+(12-labelColSpan)+'">'
       +  '   <input type="text" class="form-control input-sm" id="'+fieldName+'" style="width:'+(elmentcfg.width||220)+'px;float:left" notNull="'+notNullValue+'" value="'+(value||"")+'" disabled/>&nbsp;'
       +  tipHtml
       + '<input type="button" style="width:40px;" id="'+fieldName+'_1"  name="'+fieldName+'" value="生成"/>';
       + '</div>'
       +'</div>';

	var $that=$(html).appendTo($("#"+elmentcfg.containerId));
	return $that;
 };
AI.FormField.prototype.buildFileElement = function(elmentcfg){
	var label=elmentcfg.label||elmentcfg.fieldLabel;
	var label =this.getLabel(elmentcfg);
	var value=elmentcfg.value;
	var tip = elmentcfg.tip;
	var notNullValue=elmentcfg.notNull;
	var fieldName=elmentcfg.fieldName||label;
  var elementType = elmentcfg.type || "file";
  var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
  var labelColSpan = elmentcfg.labelColSpan||2;
  var tipHtml="";
  var tipHtml="";
  if(tip) tipHtml='<span class="help-block text-warning">'+tip+'</span>';
  var self = this;
  var html = '<div class="form-group form-group-sm">'
  	+'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>' 
  	+ '<div class="col-sm-'+(12-labelColSpan)+'">'
  	+  '<input type="'+elementType+'"  id="'+fieldName+'FILE" name ="file" style="position: fixed; left: -500px;width:'+(elmentcfg.width||220)+'px;"></input>'
  	+	 '<div style="display: inline;">'
  	+   '<input type="text" id="'+fieldName+'" class="form-control inline v-middle input-s" style="width:'+(elmentcfg.width||220)+'px" value="'+(value||"")+'" readonly>'
  	+		'<label for="'+fieldName+'FILE" class="btn btn-default">'
  	+			'<span class="glyphicon glyphicon-folder-open" style="cursor:pointer;" aria-hidden="true"> 浏览</span>'
  	+		'</label>'
  	+  '</div>'
  	+ '</div>'
		+'</div>';
	var $that=$(html).appendTo($("#"+elmentcfg.containerId));
	$that.find('#'+fieldName+'FILE').on('change',function(){
		var _val = $(this).val();
		$that.find(":text").val(_val.split("\\").pop());
		self.triggerFieldChage(_val.split("\\").pop());
	})	
	return $that;
};
 
AI.FormField.prototype.buildRemarkElement=function(elmentcfg){
	var label=elmentcfg.label;
	var value=elmentcfg.value || "";
	var fieldName=elmentcfg.fieldName;
	var elementType = elmentcfg.type;
	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	var tip = elmentcfg.tip;
	var popover = elmentcfg.popover;
	
	var popoverHtml = "";
	if(popover)popoverHtml = '<span id="popover-btn" class="glyphicon glyphicon-question-sign" style="cursor:pointer;padding:10px;" data-toggle="popover" data-content="'+popover+'" data-placement="right"  aria-hidden="true"></span>';
	var tipHtml="";
	if(tip) tipHtml='<span class="help-block text-warning">'+tip+'</span>'
	//var label =this.getLabel(elmentcfg);
 
	var labelColSpan = elmentcfg.labelColSpan||2;
	var label =this.getLabel(elmentcfg);
 
	var html='<div class="form-group form-group-sm">'
 
		+'<label for="'+fieldName+'" class="col-sm-'+elmentcfg.labelColSpan+' control-label">'+label+'</label>'
		+'<div class="col-sm-'+(12-elmentcfg.labelColSpan)+'"> <textarea class="form-control" style="float:left;width:'+elmentcfg.width+'px;height:'+(elmentcfg.height||150)+'px" cols='+(elmentcfg.cols||60)+' rows='+(elmentcfg.rows||5)+' id="'+fieldName+'" name="'+fieldName+'" '+readOnly+'>'+value+'</textarea>'
		+ popoverHtml + tipHtml
		+'</div>';
    	//var html='<div>'+label+'<'+elementType+' style="width:'+elmentcfg.width+'px" cols='+(elmentcfg.cols||60)+' rows='+(elmentcfg.rows||5)+' id="'+fieldName+'" name="'+fieldName+'">'+value+'</textarea></div>';
     
	var $that=$(html).appendTo($("#"+elmentcfg.containerId));
	$that.find("#popover-btn").popover();
	$that.find("#popover-btn").on('click',function(){
		$that.find('#popover-btn').toggleClass('glyphicon-question-sign').toggleClass('glyphicon-info-sign');
	});
  return $that;
 };
AI.FormField.prototype.buildHtmlElement=function(elmentcfg){
	var label=elmentcfg.label||'';
    	var value=elmentcfg.value;
    	var fieldName=elmentcfg.fieldName;
    	var elementType = elmentcfg.type;
    	//var label =this.getLabel(elmentcfg);
    	var html="";
   	if(elmentcfg.parenttype=='form')
      	html= 	'<a>' + (label||'') +  (elmentcfg.html||elmentcfg.value) +  '</a>'
    else 
    	   html= 	'<li>' + (label||'') +  (elmentcfg.html||elmentcfg.value) +  '</li>';
    	
     var $that=$(html).appendTo($("#"+elmentcfg.containerId));
			return  $that;
};
AI.FormField.prototype.getOptionTip=function(elementcfg,optionId,optionName){
	if(!elementcfg.tips) return optionName;
	if(!elementcfg.tips[optionId]) return optionName;
	return '<a class="tooltip" href="#">'+optionName+'<span class="info">'+elementcfg.tips[optionId]+'</span></a>'
};
AI.FormField.prototype.chageOptions=function(){
	$("select#"+this.id).empty();
	var storesql=this.config.storesql;
	var storesql = AI.Action.dealSql(storesql);
  
	var allOptions=this.getOptions(storesql,this.val)
  var self=this;
     
  var optionsHtml='<option></option>';
  for(var i=0;i<allOptions.length;i++){
    		 var option=allOptions[i];
    		 var isChecked="";
    		 if(option.selected) isChecked='selected=true'; 
    		 //var optionHtml =self.getOptionTip(elmentcfg,option.id,option.name); 
				 optionsHtml+='<option value="'+option.id+'" '+isChecked+'>'+option.name+'</option>';
	};
	$(optionsHtml).appendTo($("select#"+this.id));
	
};
AI.FormField.prototype.buildRadioElement=function(elmentcfg){
	    var label=elmentcfg.label;
    	var value=elmentcfg.value;
    	var storesql=elmentcfg.storesql;
    	var fieldName=elmentcfg.fieldName;
    	var elementType = elmentcfg.type;
    	var notNull = elmentcfg.notNull;
    	var label =this.getLabel(elmentcfg); 
    	var allOptions=this.getOptions(storesql,value)
      	var self=this;
      	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
      	var labelColSpan = elmentcfg.labelColSpan||2;
      
    	var optionsHtml='';
    	for(var i=0;i<allOptions.length;i++){
    		 var option=allOptions[i];
    	      // optionsHtml+='<input type="radio" name="'+fieldName+'" value="'+option.id+'"/>'+option.name+"&nbsp&nbsp;";
    	       optionsHtml+='<label class="radio-inline"> <input type="radio" name="'+fieldName+'" id="'+option.id+'" value="'+option.id+'" '+(option.selected ? 'checked="checked"':'')+'" '+readOnly+'> '+option.name+'</label>'
			};
			
		  var label='<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>';
		  var html=  '<div class="form-group form-group-sm">' +label+'<div class="col-sm-'+(12-labelColSpan)+'">'+optionsHtml +  '</div></div>';
			var $that=$(html).appendTo($("#"+elmentcfg.containerId));
			 
      var $checks = $that.find(":radio");
      var self=this;
      $checks.bind("click",function(e){
     	  self.triggerFieldChage($(e.currentTarget).attr('value'));
     });
	 return  $that;
 };
 AI.FormField.prototype.buildRadioElement1=function(elmentcfg){
 	var label=elmentcfg.label;
 	var value=elmentcfg.value;
 	var storesql=elmentcfg.storesql;
 	var fieldName=elmentcfg.fieldName;
 	var elementType = elmentcfg.type;
 	var notNull = elmentcfg.notNull;
 	var label =this.getLabel(elmentcfg); 
 	var allOptions=this.getOptions(storesql,value)
   	var self=this;
   	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
   	var labelColSpan = elmentcfg.labelColSpan||2;
   
 	var optionsHtml='';
 	for(var i=0;i<allOptions.length;i++){
 		 var option=allOptions[i];
 	      // optionsHtml+='<input type="radio" name="'+fieldName+'" value="'+option.id+'"/>'+option.name+"&nbsp&nbsp;";
 	       optionsHtml+='<label class="radio-inline"> <input type="radio" name="'+fieldName+'" id="'+option.id+'" value="'+option.id+'" '+(option.id == value ? 'checked="checked"':'')+'" '+readOnly+'> '+option.name+'</label>'
			};
			
		  var label='<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>';
		  var html=  '<div class="form-group form-group-sm">' +label+'<div class="col-sm-'+(12-labelColSpan)+'">'+optionsHtml +  '</div></div>';
			var $that=$(html).appendTo($("#"+elmentcfg.containerId));
			 
   var $checks = $that.find(":radio");
   var self=this;
   $checks.bind("click",function(e){
  	  self.triggerFieldChage($(e.currentTarget).attr('value'));
  });
   return  $that;
};
 
AI.FormField.prototype.buildCheckBoxElement=function(elmentcfg){
	var label=elmentcfg.label||elmentcfg.fieldLabel;
	var label=this.getLabel(elmentcfg);
	var value=elmentcfg.value;
	var storesql=elmentcfg.storesql;
	var fieldName=elmentcfg.fieldName;
	var height=elmentcfg.height||180;
	var elementType=elmentcfg.type;
	var readOnly=elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	var isEditable=elmentcfg.isEditable||"";
	var labelColSpan = elmentcfg.labelColSpan||2;
//	var label =this.getLabel(elmentcfg);
	var editHtml = '<input id="custom-input" type="text" class="form-control input-sm hide" style="float:left;width:220px;"/>'
		+'<span id="edit-btn" class="glyphicon glyphicon-edit" style="cursor:pointer;padding:10px;" aria-hidden="true"></span>';
	var allOptions=this.getOptions(storesql,value,elementType,elmentcfg);

	var optionsHtml='<span id="container_'+this.id+'" style="border:1px;margin-top:2px">';
	for(var i=0;i<allOptions.length;i++){
		var option=allOptions[i];
		var isChecked="";
		if(option.selected) isChecked='checked';
		//var optionHtml =self.getOptionTip(elmentcfg,option.id,option.name);
		var option=allOptions[i];
		var isChecked=option.selected?"checked=true":"";
		//optionsHtml+='<span><input type="checkbox" name="'+option.name+'" value="'+option.id+'" '+isChecked+' '+readOnly+'/>'+option.name+"&nbsp;</span>";
		optionsHtml+='<span><input type="checkbox" name="'+this.id+'" value="'+option.id+'" '+isChecked+' '+readOnly+'/>'+option.name+"&nbsp;</span>";
	}
	optionsHtml+="</span>";
	if(isEditable){optionsHtml +=editHtml};
	if(elmentcfg.parenttype=='form'){
		var html= '<div class="form-group form-group-sm">'
		+'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>' 
		+	'<div class="col-sm-'+(12-labelColSpan)+'">'
		+	optionsHtml
		+	'</div>'
		+'</div>';
	}else{
		var html= '<li style="margin-left:2px;margin-top:12px>'
		+'<label class="navbar-label">'+label+'</label>'
		+ optionsHtml
		+'</li>';
	}
	// var html= '<li style="float:left;overflow:hidden;">'+label+ optionsHtml +'</li>';

	var $that=$(html).appendTo($("#"+elmentcfg.containerId));
	var $checks = $that.find(":checkbox");
	var self=this;
	$checks.each(function(index,el){
		$(el).click(function(){
			self.triggerFieldChage(self.getValue());
		});
	});

	$that.find('#edit-btn').on('click',function(){
		$that.find('#edit-btn').toggleClass('glyphicon-edit').toggleClass('glyphicon-check');
		$that.find('#custom-input').toggleClass('hide');
		$that.find(':checkbox').parent('span').toggleClass('hide');
	});
	$that.find('#custom-input').on('change',function(){
		var _val = $(this).val();
		if($that.find(':checkbox[value="'+_val+'"]').length==0){
			$that.find(':checkbox').parent('span').append('<input type="checkbox" name="'+_val+'" value="'+_val+'" checked/>'+_val+'&nbsp;');
		}else{
			$that.find(':checkbox[value="'+_val+'"]').attr("checked","checked");
		}
		self.triggerFieldChage(_val);
	});	
	return $that;
};
AI.FormField.prototype.buildComboxElement=function(elmentcfg){
	var label=elmentcfg.label||elmentcfg.fieldLabel;
	var label=this.getLabel(elmentcfg);
	var value=elmentcfg.value;
	var storesql=elmentcfg.storesql;
	var fieldName=elmentcfg.fieldName;
	var elementType = elmentcfg.type;
	var notNull = elmentcfg.notNull;
	var tip = elmentcfg.tip||"";
	var labelColSpan = elmentcfg.labelColSpan||2;
	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	var editable=elmentcfg.editable||"Y";
	var attr=elmentcfg.attr||'';
	//var tipHtml=tip&&tip.length>0?('<span class="help-block text-warning">'+tip+'</span>'):"";
	var tipHtml = '<input id="custom-input" name="'+this.id+'" type="text" class="form-control input-sm hide" style="float:left;width:220px;" />';
	if(elmentcfg.parenttype=='form') 
	    tipHtml += '<span id="edit-btn" class="glyphicon glyphicon-edit" style="cursor:pointer;padding:10px;" aria-hidden="true"></span>';
	tipHtml=readOnly=='disabled'?"":tipHtml;
	// tipHtml=editable?tipHtml:"";

	//tip标注
	tipHtml+=(tip&&tip.length>0?('<span class="help-block text-warning">'+tip+'</span>'):"");
	var self=this;
	var allOptions=this.getOptions(storesql,value,null,elmentcfg);
	
	
	var optionsHtml='<option value=""> </option>';
	var isDefaultValInOptions = false;
	for(var i=0;i<allOptions.length;i++){
		var option=allOptions[i];
		var isChecked=option.selected?'selected=true':'';
		optionsHtml+='<option value="'+option.id+'" '+isChecked+'>'+option.name+'</option>';
		if(option.selected==true){isDefaultValInOptions = true;}
	};
	if(!isDefaultValInOptions&&value){
		optionsHtml+='<option value="'+value+'" selected=true>'+value+'</option>';
	}
	var label =this.getLabel(elmentcfg);
	if(elmentcfg.parenttype=='form'){
		var html= '<div class="form-group form-group-sm">'
			+'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>' 
			+'	<div class="col-sm-'+(12-labelColSpan)+'">'
			+'		<select id="'+this.id+'" class="form-control input-sm"  style="float:left;width:'+(elmentcfg.width||220)+'px" '+readOnly+'>'
			+		optionsHtml
			+'		</select>'
			+		tipHtml
			+'	</div>'
			+'</div>';
	}else{
		var html= '<li style="margin-left:2px;margin-rig:2px;" '+attr+'>'
		+'<label class="navbar-label">'+label+'</label>'
		+'	<select id="'+this.id+'" class="form-control" style="width:'+(elmentcfg.width||220)+'px" placeholder="'+label+'" '+readOnly+'>'
		+	optionsHtml
		+'	</select>'
		+	tipHtml
		+'</li>';
	}
	var $that = $(html).appendTo($("#"+elmentcfg.containerId));
	var editBtnSwitch = function(){
		$that.find('#edit-btn').toggleClass('glyphicon-edit').toggleClass('glyphicon-check');
		$that.find('#custom-input').toggleClass('hide');
		$that.find('select').toggleClass('hide').toggleClass('custom-val');
	};
	$that.find('#edit-btn').on('click',function(){
		editBtnSwitch();
	});
	$that.find('#custom-input').on('change',function(){
		var _val = $(this).val();
		if($that.find('select option[value="'+_val+'"]').length==0){
			$that.find('select').append('<option value="'+_val+'" selected>'+_val+'</option>');
		}else{
			$that.find('select').val(_val);
		}
		self.triggerFieldChage(_val);
	});
	// if(!isDefaultValInOptions&&value){
	// 	editBtnSwitch();
	// 	$that.find('#custom-input').val(value);
	// }
	if(editable == "N") {
		$that.find('#edit-btn').hide();
	}
	return $that;
};
 
 AI.FormField.prototype.buildMulitselectElement2=function(elmentcfg){
     var label=elmentcfg.label;
    	var value=elmentcfg.value;
    	var storesql=elmentcfg.storesql;
    	var fieldName=elmentcfg.fieldName;
    	var height=elmentcfg.height||180;
    	var width=elmentcfg.width||200;	 
    	var elementType = elmentcfg.type;
    	var elId = elmentcfg.id||elmentcfg.fieldName;
      var label =this.getLabel(elmentcfg);
      var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
      var labelColSpan = elmentcfg.labelColSpan||2;

      ai.loadRemotJsCss("/{contextPath}/lib/multiselect/bootstrap-multiselect.css");
   	  ai.loadRemotJsCss("/{contextPath}/lib/multiselect/bootstrap-multiselect.js");	
   	  ai.loadRemotJsCss("/{contextPath}/lib/multiselect/prettify.js");
   	 
    	var self=this;
    	
    	var allOptions=this.getOptions(storesql,value);
    	
    	var optionsHtml = '';
    	for(var i=0;i<allOptions.length;i++){
    		var option=allOptions[i];
    		//$('<option value="' + option.id + '">' + option.name + '</option>').appendTo($("#example28"));
    		optionsHtml+='<option value="'+option.id+'">'+option.name+'</option>';
    	}
    	
		  var html= '<div class="form-group form-group-sm">'
			   +	'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>' 
			   +  '<div class="col-sm-'+(12-labelColSpan)+'">'
			   +      '<select id="'+elId+'" multiple="multiple"  style="width:'+(elmentcfg.width||220)+'px" '+readOnly+'>'
			   +         optionsHtml
			   +      '</select>'
			   + '</div>'
			   +'</div>';
		  
		  var $that = $(html).appendTo($("#"+elmentcfg.containerId));
    	
		  $that.find("#"+elId).multiselect({
	              includeSelectAllOption: true,
	              enableFiltering: true,
	              maxHeight:500
	      });
		  
		  var $checks = $that.find(":checkbox");
	      var self=this;
	      $checks.bind("click",function(){
	     	  self.triggerFieldChage(self.getMulitSelectValue($that));
	      });
		  
		  return  $that;	
 };
 
 
 AI.FormField.prototype.getMulitSelectValue = function(temlp){

   	   var newVal="",newValName="";
        var $inputField = temlp.find(":checkbox");
        
        for(var i=0;i<$inputField.length;i++){
        	  var item = $inputField[i];
        	  if($(item).is(':checked')){
        	     if(newVal){
        	     	 newVal+=","+$(item).attr('value');
        	     	 newValName+=","+$(item).attr("name");
        	     	}else {
        	     		newVal=$(item).attr('value');
        	     		newValName=$(item).attr("name");
        	     	};
        	  }
        };
        this.val=newVal;
        this.rawVal = newValName;
        return newVal;
};
 
AI.FormField.prototype.buildMulitselectElement=function(elmentcfg){
	var label=elmentcfg.label||elmentcfg.fieldLabel;
	var label =this.getLabel(elmentcfg);
	var value=elmentcfg.value;
	var tip = elmentcfg.tip;
	var fieldName=elmentcfg.fieldName||label;
	var elementType = elmentcfg.type || "text";
	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	var labelColSpan = elmentcfg.labelColSpan||2;

	var tipHtml="";
	if(tip) tipHtml='<span class="help-block text-warning">'+tip+'</span>'
	if(elmentcfg.parenttype=='form'){
    	var html= '<div class="form-group form-group-sm">'
			+	'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>' 
			+  '<div class="col-sm-'+(12-labelColSpan)+'">'
			+  '   <div   id="'+fieldName +'"></div>'
			+  tipHtml
			+ '</div>'
			+'</div>';
	}else if(elmentcfg.subtype && elmentcfg.subtype=='inline'){
   		var html= '<li style="margin-left:3px"> <input type="'+elementType+'" class="form-control" id="'+fieldName+'" style="width:'+(elmentcfg.width||220)+'px" type="text" value="'+(value||"")+'" placeholder="'+label+'" '+readOnly+'></li>'
	}else {
 		var html= '<li >'
			+'<label class="navbar-label">'+label+'</label>'
			+ '   <input type="'+elementType+'" class="form-control" id="'+fieldName+'" style="width:'+(elmentcfg.width||220)+'px" type="text" value="'+(value||"")+'" '+readOnly+'>'
			+'</li>'
	}
   var $that=$(html).appendTo($("#"+elmentcfg.containerId));
   ai.loadWidget("multiSelect");
	
	var field = new  AI.MultiSelect({
	   name : '程序名',
 		cls : 'form-element input-sm',
 		id : 'wrap'+fieldName,
 		
 		containerId :fieldName,///容器
 		sql : "select username as VALUE1, usecnname as VALUE2 from metauser",
 		placeholder : '请选择...',
 		style : 'width : 200px;',
 		text : '没找到相关数据！',	//警告内容
 		duplicates : true,	//允许重复值
 		required : false,	//允许为空
 		defaultValue :[{id:'sys',name:'王'}],//默认选中值
 		minlen:0,	//输入搜索字符的最小长度
 	});
    	
      return field;	
 };
AI.FormField.prototype.buildMulitselectElement1=function(elmentcfg){
     var label=elmentcfg.label||elmentcfg.fieldLabel;
     var label=this.getLabel(elmentcfg);
    	var value=elmentcfg.value;
    	var storesql=elmentcfg.storesql;
    	var fieldName=elmentcfg.fieldName;
    	var height=elmentcfg.height||180;
    	var width=elmentcfg.width||200;	 
    	var elementType = elmentcfg.type;
    	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
       //var label =this.getLabel(elmentcfg);
    	var self=this;
    	
    	var allOptions=this.getOptions(storesql,value)
      
      var optionsHtml='<option></option>';
    	for(var i=0;i<allOptions.length;i++){
    		 var option=allOptions[i];
    		 var isChecked="";
    		 if(option.selected) isChecked='checked';
    		 //var optionHtml =self.getOptionTip(elmentcfg,option.id,option.name);
    		  var option=allOptions[i];
    		 var isChecked="";
    		 if(option.selected) isChecked='checked=true'; 
				 optionsHtml+='<li ><a href="#"><input type="checkbox" name="'+option.name+'" value="'+option.id+'" '+isChecked+' '+readOnly+'/>'+option.name+'</a></li>';
			};
	 var containerId="container_"+(elmentcfg.id||elmentcfg.fieldName);
	 var elId = (elmentcfg.id||elmentcfg.fieldName);
	 var containerHtml='<li style="float:left;overflow:hidden;">&nbsp;&nbsp;</li>'
		 +'<div id="'+containerId+'" class="datepicker  dropdown-menu" style="top:130px;left:871px;width:'+(width+10)+'px;display: none;">'
     +'<li>'
     + '  <ul style="list-style:none;margin-left:1px;height:'+height+'px;overflow:scroll;">'
     +       optionsHtml       
     +'   </ul>'
    +'</li>'
    +'<li class="divider"></li>'
    +'<li style="display:inline; float:right; margin-right:8px; white-space:nowrap; line-height:25px; ">'
    +'    <span id="ok" class="btn btn-danger btn-small" href="#">OK</span>'
    +'    <span id="cancel" class="btn btn-small" href="#">Cancel</span>'
    +'</li>'
    +'</div>';
		$(containerHtml).appendTo("body");
		
		$("#"+containerId+" #ok").click(function () {
			 
          self.triggerFieldChage(self.getValue());
          $("#"+containerId).css({  display:"none" }); 
     });
     
		$("#"+containerId+" #cancel").click(function () {
          $("#"+containerId).css({  display:"none" });    
     });
     var $checks = $("#"+containerId).find(":checkbox");
     $checks.bind("click",function(){
     	  self.getValue();

     });
 
     var html='<li>'+label
              +'<input id="'+elId+'" type="text" placeholder="Type something…" value="'+(elmentcfg.value||'')+'" style="width:'+width+'px" '+readOnly+'/>'
              +'<span class="add-on" '+readOnly+'><i class="icon-glass"></i></span>' 
              +'</li>';
     var $that=$(html).appendTo($("#"+elmentcfg.containerId));
      
     $that.find("#"+elId).focus(function(){
     	   var offset = $(this).offset();
           $("#"+containerId).css({
               display:"block",
               top:offset.top + $(this).height() + 2,
               left:offset.left
           });
      });
     $triggers = $that.find(".icon-glass");
     $triggers.each(function () {
     	 $(this).click(function(){
     	 	   var offset = $(this).offset();
           $("#"+containerId).css({
               display:"block",
               top:offset.top + $(this).height() + 2,
               left:offset.left
           });
     	});
     });
    
	  return  $that;	
 };
AI.FormField.prototype.buildSelTagElement=function(elmentcfg){
	var label=elmentcfg.label;
	var storesql=elmentcfg.storesql;
	var value=elmentcfg.value;    
	var fieldName=elmentcfg.fieldName;
	var elementType = elmentcfg.type;
	var label =this.getLabel(elmentcfg);
	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	var labelColSpan = elmentcfg.labelColSpan||2;

	ai.loadRemotJsCss("/{contextPath}/lib/bootstrap.tags/bootstrap-tags.min.js");
	ai.loadRemotJsCss("/{contextPath}/lib/bootstrap.tags/bootstrap-tags.css");

	var html='<div class="form-group form-group-sm">'
		+'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>'
		+'<div class="col-sm-'+(12-labelColSpan)+'">'
		+'<div id="'+fieldName+'" class="tag-list"></div>'
		+'</div>';
	var self=this;
	var $that=$(html).appendTo($("#"+elmentcfg.containerId));
	var allOptions=this.getOptions(storesql,value);
	var tagEle = $("#"+fieldName+".tag-list").tags({
		tagData : []
	});
	var arrnames=[]; 

	for(var i=0;i<allOptions.length;i++){
		var option=allOptions[i];
		var suggestion=option.name;
		arrnames.push(suggestion);
	}

	tagEle.suggestions=arrnames;
	tagEle.allOptions=allOptions;
	$("#"+fieldName+" input").mouseout(function(){
		self.triggerFieldChage(tagEle.tagsArray1);
	});

	$("#"+fieldName+" input").blur(function(){
		self.triggerFieldChage(tagEle.tagsArray1);
	});
	return $that;
};
 
AI.FormField.prototype.buildDateElement=function(elmentcfg){
	    ai.loadWidget("datepicker");
      var label=elmentcfg.label;
    	var value=elmentcfg.value;
    	var fieldName=elmentcfg.fieldName;
    	var elementType = elmentcfg.type;
    		var tip = elmentcfg.tip;
      var label =this.getLabel(elmentcfg);
    	var elId = elmentcfg.id||elmentcfg.fieldName;
    	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
    	var labelColSpan = elmentcfg.labelColSpan||2;
    	var tipHtml="";
    	if(tip) tipHtml='<span class="help-block text-warning">'+tip+'</span>'
    	if(elmentcfg.parenttype=='form'){
    	var html= '<div class="form-group form-group-sm">'
   +	'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>' 
   +  '<div class="col-sm-'+(12-labelColSpan)+'">'
   +  '   <input type="'+elementType+'" class="form-control input-sm" id="'+fieldName+'" style="width:'+(elmentcfg.width||220)+'px" type="text" value="'+(value||"")+'" '+readOnly+'>'
   +  tipHtml
   + '</div>'
   +'</div>'
 };
    	var self=this;         
     var $that=$(html).appendTo($("#"+elmentcfg.containerId));
     $that.find("#"+elId).datepicker({
                format:'yyyy-mm-dd'
      }).on('changeDate',function(newDate){
      	 self.triggerFieldChage(newDate.date.format('yyyy-mm-dd'));
      }); 
    
    	$that.find(".icon-th").datepicker({
                format:'yyyy-mm-dd'
       }).on('changeDate',function(newDate){
      	 self.triggerFieldChage(fieldName,newDate.date.format('yyyy-mm-dd'));
      }); 
         
		  return $that;
    };
AI.FormField.prototype.buildDateRangeElement=function(elmentcfg){
	    ai.loadRemotJsCss("/{contextPath}/minder//lib/twitter/plugin/daterangepicke/daterangepicker.css"); 
	    ai.loadRemotJsCss("/{contextPath}/minder//lib/twitter/plugin/daterangepicke/date.js");
      ai.loadRemotJsCss("/{contextPath}/minder//lib/twitter/plugin/daterangepicke/daterangepicker.js");
      var label=elmentcfg.label;
    	var value=elmentcfg.value;
    	var fieldName=elmentcfg.fieldName;
    	var elementType = elmentcfg.type;
      //var label =this.getLabel(elmentcfg);
    	var elId = elmentcfg.id||elmentcfg.fieldName;
    	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
    	var html='<li style="float:left;overflow:hidden;">&nbsp;&nbsp;</li>'
        +'<li style="list-style: none;">'
        +'    <div class="controls">'
        +'        <div class="input-prepend">'
        +'          <span class="add-on" '+readOnly+'><i class="icon-calendar"></i>'+label+'</span>'
        +'          <span data-date-format="yyyy-mm-dd" data-date="2012-12-02" id="'+elId+'_date" class="input-append date" '+readOnly+'>'
        +'          <input id="'+elId+'" type="text" class="span2" placeholder="请选择时间段…" value="'+value+'" style="width:'+(elmentcfg.width||160)+'px"  '+readOnly+'/>'
       // +'           <span class="add-on"><i class="icon-th"></i></span>'
        +'    </div>'
        +'</li>';
     var self=this;   
     var $that=$(html).appendTo($("#"+elmentcfg.containerId));
     
     $that.find("#"+elId).daterangepicker({format:'yyyy-mm-dd', firstDay:2 })
		  return $that;
    };
AI.FormField.prototype.buildColorElement=function(elmentcfg){
	    ai.loadWidget("colorpicker");
      var label=elmentcfg.label;
    	var value=elmentcfg.value;
    	var fieldName=elmentcfg.fieldName;
    	var elementType = elmentcfg.type;
      var label =this.getLabel(elmentcfg);
    	var elId = elmentcfg.id||elmentcfg.fieldName;
    	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
    	var html="<li>"+label
    	         +'<input id="'+elId+'" type="text" placeholder="请选择颜色…" value="'+value+'" style="width:'+(elmentcfg.width||220)+'px" '+readOnly+'/>'
    	       //  +'<span class="add-on"><i class="icon-th"></i></span>'
    	         +"</li>"
     
     var $that=$(html);
     $that.appendTo($("#"+elmentcfg.containerId));
     var self=this;
     $that.find("#"+elId).colorpicker({
            format: 'hex'    
      }).on('hide', function(ev){
        self.triggerFieldChage(ev.color.toHex()); 
     }); 
 
		  return $that;
    };
AI.FormField.prototype.buildImgPicker=function(elmentcfg){
	var label=elmentcfg.label;
	var value=elmentcfg.value;
	var fieldName=elmentcfg.fieldName;
	var elementType = elmentcfg.type;
	var label =this.getLabel(elmentcfg);
	var elId = elmentcfg.id||elmentcfg.fieldName;
	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	var self=this;
	var dlgHtml ='<div id="_ImgPickerDialog" class="modal hide fade"  tabindex="-1" role="dialog" aria-labelledby="" aria-hidden="true" style="overflow:hidden;width:760px">'
        +'<div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button><h3>选择图片</h3></div>'
        +'<div class="modal-body">'
        +'<ul class="nav nav-tabs"> <li class="active"><a href="#smallgallery" data-toggle="tab">小图标</a></li> <li class=""><a href="#middlegallery" data-toggle="tab">中图标</a></li><li class=""><a href="#biggallery" data-toggle="tab">大图标</a></li> <li class=""><a href="#largegallery" data-toggle="tab">背景图</a></li></ul>'
        +'<div class="tab-content">'
        +'<div class="tab-pane fade active in" id="smallgallery"> <ul class="gallery small"> </ul></div>'
        +'<div class="tab-pane fade" id="middlegallery"> <ul class="gallery middle"></ul></div>'
        +'<div class="tab-pane fade" id="biggallery"> <ul class="gallery big"> </ul> </div>'
        +'<div class="tab-pane fade" id="largegallery"> <ul class="gallery large"> </ul> </div>'
        +'</div>'
        +'</div>'
        +'<div class="modal-footer"><button class="btn" data-dismiss="modal" aria-hidden="true">Close</button><button id="_ImgPickerDialog-ok" class="btn btn-primary" data-dismiss="modal" aria-hidden="true">确定</button></div>'
        +'</div>';
	if($("#_ImgPickerDialog").length==0){
        var $imgDlg = $(dlgHtml).appendTo("body");
        var imgStore = ai.getStoreData("select  '/core/minder/appicon/'||DEFAULTICON as img  from MINDER_WIDGET");
        $("#_ImgPickerDialog-ok").attr("selectval","");
        for(var i=0;i<imgStore.length;i++){
        	$('<li><img src="'+imgStore[i].IMG+'"></li>').appendTo("#smallgallery ul" ,$imgDlg);
        	$('<li><img src="'+imgStore[i].IMG+'"></li>').appendTo("#middlegallery ul" ,$imgDlg);
        	$('<li><img src="'+imgStore[i].IMG+'"></li>').appendTo("#biggallery ul" ,$imgDlg);
        	$('<li><img src="'+imgStore[i].IMG+'"></li>').appendTo("#largegallery ul" ,$imgDlg);
		} 
		$(".gallery img",$imgDlg).click(function(){
			$(".gallery li",$imgDlg).removeClass("select");
			$(this).parent().addClass("select");
			$("#_ImgPickerDialog-ok").attr("selectval",$(this).attr("src"));
		});
        $("#_ImgPickerDialog-ok").click(function(){
        	  var imgsrc=$("#_ImgPickerDialog-ok").attr("selectval");
        	  if(!imgsrc){alert("没有选择图片");return false;}
        	  $("#"+elId).val(imgsrc);
        	  self.triggerFieldChage(imgsrc);
        	  return true;
        });
	}
	var html="<li>"+label
		+'<input id="'+elId+'" type="text" placeholder="请选择图片…" value="'+value+'" style="width:'+(elmentcfg.width||220)+'px"  '+readOnly+'/>'
		+'<span class="add-on" '+readOnly+'><i class="icon-th"></i></span>'
		+"</li>";

	var $that=$(html);
	$that.appendTo($("#"+elmentcfg.containerId));
	$(".icon-th",$that).click(function(){
		$("#_ImgPickerDialog").modal().show();
	});
     
	var self=this;

	return $that;
};
AI.FormField.prototype.show = function(){
	this.control.show();
	
};
AI.FormField.prototype.hide = function(){
	this.control.hide();
};    
AI.FormField.prototype.buildButton=function(elmentcfg){
	var label=elmentcfg.label||elmentcfg.fieldName;
	var value=elmentcfg.value;
	var fieldName=elmentcfg.fieldName;
	var elementType = elmentcfg.type;
	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	var attr=elmentcfg.attr||'';
	var btnHtml='<li style="float:left;overflow:hidden;"><button id="'+elmentcfg.id+'" '+readOnly+" "+attr;
	var btnClass="btn ";
	var self=this;
	var labelColSpan = elmentcfg.labelColSpan||2;
	if(elmentcfg.elclass) btnClass+="  "+elmentcfg.elclass;
	if(elmentcfg.sizetype) btnClass+="  "+elmentcfg.sizetype;
	btnHtml+=' class="'+btnClass+'" ';
	if(elmentcfg.parenttype=="toolbar") btnHtml+=' style="margin-top:0px" '; 
	if(elmentcfg.style) btnHtml+=' style="'+elmentcfg.style+'" '; 
	if(elmentcfg["data-toggle"]) btnHtml+='data-toggle='+elmentcfg["data-toggle"];
	btnHtml+='>'+(elmentcfg.label||elmentcfg.fieldLabel)+'</button></li>';
	if(elmentcfg.parenttype=='form'){
	 var html= '<div class="form-group form-group-sm">'
		+	'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label"> </label>' 
		+	'<div class="col-sm-'+(12-labelColSpan)+'"><ul>'
		+	btnHtml
		+	'</ul></div>'
		+	'</div>';
	 }
	 else{
	 	html=btnHtml; 
	}
	var btn=$(html).appendTo($("#"+elmentcfg.containerId));

	if(elmentcfg.clickfun){
		if (typeof elmentcfg.clickfun === "string") {
			elmentcfg.clickfun = (new Function("return " + elmentcfg.clickfun))();
		}
		btn.find('button').bind('click',function(){
			var cmpId = $("button",$(this)).attr("id");
			if(typeof(minderGraph)!='undefined' && minderGraph && minderGraph.allWidget){
				var thisWidget = minderGraph.allWidget[cmpId];
				if(thisWidget) thisWidget.publish("click",this);
			};
			var result={};
			if(elmentcfg.parent && elmentcfg.parent.getAllFieldValue)result =  elmentcfg.parent.getAllFieldValue();
			if (typeof elmentcfg.clickfun == "function"){
				return elmentcfg.clickfun(result,self);
			}else{
				return AI.Action.actFun(elmentcfg.clickfun,elmentcfg.clickpara);
			}
		});
	}else{
		btn.bind('click',function(){
			var cmpId = $("button",$(this)).attr("id") ;
			if(minderGraph && minderGraph.allWidget){
				var thisWidget = minderGraph.allWidget[cmpId];
				if(thisWidget) thisWidget.publish("click",this);
			};
		});
	};
    	
      return btn;
 };
AI.FormField.prototype.buildButtonGroup=function(elmentcfg){
	if(!elmentcfg.buttons) return;
	var label=elmentcfg.label;
	var value=elmentcfg.value;
	var storesql=elmentcfg.storesql;
	var fieldName=elmentcfg.fieldName;
	var elementType = elmentcfg.type;
	var notNull = elmentcfg.notNull;
	var label =this.getLabel(elmentcfg); 
	var allOptions=this.getOptions(storesql,value);
	var onlyone = (elmentcfg.onlyone=='y'? true:false);
	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	var labelColSpan = elmentcfg.labelColSpan||2;
	var self=this;
	var buttons = (new Function("return "+elmentcfg.buttons))();
	
	var html= '<div class="form-group form-group-sm">'
		+	'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label"> </label>'
		+	'<div class="col-sm-'+(12-labelColSpan)+'" id="'+fieldName+'"><ul>'
		+	'</ul></div>'
		+	'</div>';
	//var html=  '<li style="float:left;overflow:hidden;white-space: nowrap;">' +label+'<span id="'+elmentcfg.id+'" class="btn-group" style="margin-top:10px">'+optionsHtml +'</span></li>';
	var $that =$(html).appendTo($("#"+elmentcfg.containerId));
	for(var i=0;i<buttons.length;i++){
		var btn=buttons[i];
		var $btn=$('<button id="btn-'+i+'" type="button" class="btn btn-small">'+btn.label+'</button>');
		$btn.on('click',btn.clickfun);
		var $li=$('<li style="float:left;overflow:hidden;white-space: nowrap;"> <span id="'+elmentcfg.id+'" class="btn-group" style="margin-top:10px"> </span></li>');
		$li.find('span').append($btn);
		$that.find('ul').append($li);
	}
	return $that;
};
AI.FormField.prototype.buildDropMenu=function(elmentcfg){
	var label=elmentcfg.label;
	var value=elmentcfg.value;
	var storesql=elmentcfg.storesql;
	var fieldName=elmentcfg.fieldName;
	var elementType = elmentcfg.type;
	var notNull = elmentcfg.notNull;
	var label =this.getLabel(elmentcfg); 
	var allOptions=this.getOptions(storesql,value)
	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	var self=this;
    	var optionsHtml='';
    	for(var i=0;i<allOptions.length;i++){
    		 var option=allOptions[i];
    		 
    		 if(option.selected) isChecked='btn-primary';
    		 //var optionHtml =self.getOptionTip(elmentcfg,option.id,option.name);
    		   
				 optionsHtml+='<li style="float:left;overflow:hidden;"><a id="'+option.id+'" '+readOnly+'>'+option.name+'</a></li>';
			};
			var html=  '<li class="dropdown">' +elmentcfg.label+"&nbsp;"+
			           '<a class="dropdown-toggle" id="'+fieldName+'" role="button" data-toggle="dropdown" href="#"><label>Dropdown</label> <b class="caret"></b></a>'+
                '<ul id="'+fieldName+'" class="dropdown-menu" role="menu" aria-labelledby="'+fieldName+'">'+
                  optionsHtml
                '</ul></li>';
			var $that =$(html).appendTo($("#"+elmentcfg.containerId));
 
			$('ul a',$that).click(function(){
				  var fieldName = $(this).parent().parent().attr("id");
//				  alert($(this).text()+","+fieldName);
				  $(".dropdown-toggle#"+fieldName+" label").text($(this).text())
				  self.triggerFieldChage($(this).attr('id'),$(this).text());
			});
			 
			return $that;
 };
AI.FormField.prototype.buildSelBoxElement=function(elmentcfg){
	var label=elmentcfg.label;
	var value=elmentcfg.value;
	var storesql=elmentcfg.storesql;
	var fieldName=elmentcfg.fieldName;
	var height=elmentcfg.height||180;
	var width=elmentcfg.width||200;	 
	var elementType = elmentcfg.type;
	var label =this.getLabel(elmentcfg);
	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	var labelColSpan = elmentcfg.labelColSpan||2;
	
	var denpend =elmentcfg.dependen || "";
	
      
	var self=this;
	var html= '<div class="form-group form-group-sm">'
		+	'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>' 
		+  '<div class="col-sm-'+(12-labelColSpan)+'">'
		+ '   <div class="input-group input-group-sm" style="width:'+(elmentcfg.width||320)+'px" >'
		+  '   <input type="text" class="form-control input-sm" id="'+fieldName+'" value="'+(value||"")+'" '+readOnly+'>'
		+  '   <span class="input-group-addon" '+readOnly+'><i href="#" class="glyphicon glyphicon-zoom-in"></i></span>'
		+ '  </div>'
		+ '</div>'
		+'</div>';
	 
	  //  var label =this.getLabel(elmentcfg);
    //	var html= '<li>' + label+'<div class="input-append"><input type="'+elementType+'" id="'+fieldName+'" style="width:'+(elmentcfg.width||220)+'px" type="text" value="'+value+'"><span class="add-on">选择</span></div></li>';
     
	var $that=$(html).appendTo($("#"+elmentcfg.containerId));
	function afterSelect(records){
		var val="";
		for(var i=0;i<records.length;i++){
			var valTmp = records[i].get('KEYFIELD')||records[i].get('VALUES1');
			val += ((i==0?"":",")+valTmp);
		};
		$("#"+fieldName,$that).val(val);
		self.triggerFieldChage(val);
	}; 
	  
	$(".input-group-addon",$that).click(function(){
		// $("#"+fieldName,$that).val(val);
		//self.triggerFieldChage(val,rawVal);
		var selectedValue = $("#"+fieldName,$that).val();//选中的值
		if(denpend){
			var dval = $("#"+denpend).val();
			var temp = "{"+denpend+"}";
			storesql = storesql.replace(temp,dval);
		}
		var selBox=new SelectBox({sql:storesql,callback:afterSelect,selectedValue:selectedValue});
		selBox.show();
		return true;
	 });
	if(elmentcfg.isReadOnly==='y') $that.find(".input-group-addon").unbind('click');
 
	return  $that;	
};
AI.FormField.prototype.buildMapBoxElement=function(elmentcfg){
	//键值对显示selbox值格式为key1,key2|value1,value2 sql语句：SELECT dataname VALUES1, datacnname VALUES2,XMLID VALUES4 FROM tablefile WHERE dbname='{val}'
	//VALUES1用于显示的值 VALUES4 用于展示的值
	var label=elmentcfg.label;
	var value=elmentcfg.value;
	var storesql=elmentcfg.storesql;
	var fieldName=elmentcfg.fieldName;
	var height=elmentcfg.height||180;
	var width=elmentcfg.width||200;	 
	var elementType = elmentcfg.type;
	var label =this.getLabel(elmentcfg);
	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	var labelColSpan = elmentcfg.labelColSpan||2;
  
  if(value&&value.indexOf("|")!=-1){
  	value = value.substring(value.indexOf("|")+1);
  }
	var self=this;
	var html= '<div class="form-group form-group-sm">'
		+	'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>' 
		+  '<div class="col-sm-'+(12-labelColSpan)+'">'
		+ '   <div class="input-group input-group-sm" style="width:'+(elmentcfg.width||320)+'px" >'
		+  '   <input type="text" class="form-control input-sm" id="'+fieldName+'" value="'+(value||"")+'" readOnly>'
		+  '   <span class="input-group-addon" '+readOnly+'><i href="#" class="glyphicon glyphicon-zoom-in"></i></span>'
		+ '  </div>'
		+ '</div>'
		+'</div>';
	 
	  //  var label =this.getLabel(elmentcfg);
    //	var html= '<li>' + label+'<div class="input-append"><input type="'+elementType+'" id="'+fieldName+'" style="width:'+(elmentcfg.width||220)+'px" type="text" value="'+value+'"><span class="add-on">选择</span></div></li>';
     
	var $that=$(html).appendTo($("#"+elmentcfg.containerId));
	function afterSelect(records){
		var keyval="";
		var valueval ="";
		for(var i=0;i<records.length;i++){
			var keyvalTmp = records[i].get('KEYFIELD')||records[i].get('VALUES4');
			keyval += ((i==0?"":",")+keyvalTmp);
			var valuevalTmp = records[i].get('VALUEFIELD')||records[i].get('VALUES1');
			valueval += ((i==0?"":",")+valuevalTmp);
		};
		var val = keyval+"|"+valueval;
		$("#"+fieldName,$that).val(valueval);
		self.triggerFieldChage(val);
	}; 
	  
	$(".input-group-addon",$that).click(function(){
		// $("#"+fieldName,$that).val(val);
		//self.triggerFieldChage(val,rawVal);
		var selectedValue = $("#"+fieldName,$that).val();//选中的值
		var selBox=new SelectBox({sql:storesql,callback:afterSelect,selectedValue:selectedValue});
		selBox.show();
		return true;
	 });
	if(elmentcfg.isReadOnly==='y') $that.find(".input-group-addon").unbind('click');
 
	return  $that;	
};
AI.FormField.prototype.buildMulitLevelElement=function(elmentcfg){
	if(!elmentcfg.levelSqls){
		alert("请配置选项！");return;
	}
	var _self = this;
	var label=elmentcfg.label;
	var value=elmentcfg.value||'';
	value=value.split("|");
	var editable=elmentcfg.editable||"Y";
	var levelSqls=elmentcfg.levelSqls;
	var label=this.getLabel(elmentcfg);
	var fieldName=elmentcfg.fieldName;
	var placeholder=elmentcfg.placeholder||'请选择';
	var readOnly=elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	var labelColSpan = elmentcfg.labelColSpan||2;
	var _buildSelect = function(level,sql){
		var changeVal = function(id,val){
			var inputVals = $inputField.val()||[];
			if(inputVals&&inputVals.length>0){inputVals = inputVals.split("|");}
			inputVals[id] = val;
			var valStr='';
			for(var i=0;i<inputVals.length;i++){
				valStr+=("|"+inputVals[i]);
			}
			$inputField.val(valStr.slice(1));
		};
		for(var i=$inputField.find('select').length-1;i>-1;i--){
			if(i>=level){
				$inputField.find('select#'+i).remove();
				changeVal(i,'');
			}
		}
		var optionsLvl=_self.getOptions(sql,value[level]);
		if(optionsLvl.length<1){return;}
		var optionsHtml='<option value="">'+placeholder+'</option>';
		var selVal='';
		for(var i=0;i<optionsLvl.length;i++){
			var option=optionsLvl[i];
			if(option.selected) selVal=option.id;
			optionsHtml+='<option '+readOnly+' value="'+option.id+'" >'+option.name+'</option>';
		};
		$sel = $('<select id="'+level+'" value="'+selVal+'" class="multi-level" '+readOnly+'>'+optionsHtml+'</select>');
		$sel.val(selVal);
		$sel.css('width',(elmentcfg.width||100)).on('change',function(){
			var val = $(this).val();var id = $(this).attr('id');
			changeVal(parseInt(id),val);
			if(levelSqls.length>parseInt(id)+1){
				_buildSelect(parseInt(id)+1,levelSqls[parseInt(id)+1].replaceAll('{parentcode}',val));
			}
		});
		
		$inputField.append($sel);
	};
	var readOnly = elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	//var tipHtml=tip&&tip.length>0?('<span class="help-block text-warning">'+tip+'</span>'):"";
	var tipHtml = '<input id="custom-input" type="text" class="form-control input-sm hide" style="float:left;width:220px;"/>';
	tipHtml += '<span id="edit-btn" class="glyphicon glyphicon-edit" style="cursor:pointer;padding:10px;" aria-hidden="true"></span>';
	tipHtml=readOnly=='disabled'?"":tipHtml;
	var html= '<div class="form-group form-group-sm">'
		+'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>'
		+'<div class="col-sm-'+(12-labelColSpan)+'">'
		+'<div class="input-group input-group-sm" id="'+fieldName+'" style="display:inline;">'
		+'</div>'
		+'<div style="display:inline;">'+tipHtml+'</div>'
		+'</div>'
		+'</div>';
	var $that=$(html).appendTo($("#"+elmentcfg.containerId));
	var $inputField=$that.find("#"+fieldName);
	for(var i=0;i<value.length;i++){
		_buildSelect(i,levelSqls[i].replaceAll('{parentcode}',value[(i==0?0:(i-1))]));
	}
	if(value.length==0){_buildSelect(0,levelSqls[0]);}

	$that.find('#edit-btn').on('click',function(){
		$that.find('#edit-btn').toggleClass('glyphicon-edit').toggleClass('glyphicon-check');
		$that.find('#custom-input').toggleClass('hide');
		$that.find("#"+fieldName).toggleClass('hide');
	});
	$that.find('#custom-input').on('change',function(){
		if($(this).val()){
			_buildSelect(0,levelSqls[0]+" union select '"+$(this).val()+"','"+$(this).val()+"'");
			$that.find("#"+fieldName+" #0").val($(this).val());
			$("#0").trigger("change");
		}else{
			_buildSelect(0,levelSqls[0]);
		}
	});	

	if(editable == "N") {
		$that.find('#edit-btn').hide();
	}

	return $that;
};
AI.FormField.prototype.buildSelectListElement=function(elmentcfg){
	var _self = this;
	var label=elmentcfg.label;
	var value=elmentcfg.value||'';
	var storesql=elmentcfg.storesql;
	var fieldName=elmentcfg.fieldName;
	var label=this.getLabel(elmentcfg);
	var placeholder=elmentcfg.placeholder||'请选择';
	var readOnly=elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	var allowRepeat = elmentcfg.allowRepeat||false;
	var showSelect = storesql&&storesql.length>0;
	var labelColSpan = elmentcfg.labelColSpan||2;

	var options=_self.getOptions(storesql,value);
	var selVal='';var optionsHtml="";
	for(var i=0;i<options.length;i++){
		var option=options[i];
		if(option.selected) selVal=option.id;
		optionsHtml+='<li><a id="'+option.id+'" name="'+option.name+'">'+option.name+'</a></li>'
	};
	var changeVal = function(val){
		var valStr='';
		for(var i=0;i<$that.find('.select-list-item').length;i++){
			var $item = $($that.find('.select-list-item')[i]);
			valStr += ((i==0?"":";")+(showSelect?($item.find(' button').attr('name')+'£'):'')+$item.find('input').val());
		}
		if(elmentcfg.addText){
			elmentcfg.addText(val,null,_self.control);
		}
		if(elmentcfg.resetVal){
			valStr = elmentcfg.resetVal(valStr);
		}
		$that.find('#'+fieldName).val(valStr);
		_self.triggerFieldChage(valStr);
	};

	var html= '<div class="form-group form-group-sm">'
		+'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>'
		+'<div class="col-sm-'+(12-labelColSpan)+'">'
		+'<span id="plus-btn" class="glyphicon glyphicon-plus" style="cursor:pointer;padding:10px;" aria-hidden="true"></span>'
		+'<div id="select-list-items"></div>'
		+'</div>'
		+'</div>';
	var $that=$(html).appendTo($("#"+elmentcfg.containerId));
	var shorten = function($el,text,val){
		$el.find('button').attr('title',text).attr('name',val);
		text = text.length>5?(text.slice(0,3)+'...'):text;
		$el.find('button').text(text);
	};
	var _buildItem = function(value){
		var val = value||'';
		var vals = val.split('£');
		var _ph=placeholder;
		for(var i=0;i<options.length;i++){
			if(vals[0]==options[i].id){
				_ph = options[i].name;
			}
		}
		var selectHtml = '';
		if(showSelect){
			selectHtml+='<div class="input-group-btn" style="min-width:28px;">'
			+'<button type="button" class="btn btn-default btn-sm dropdown-toggle" name="'+(vals[0]||'')+'" data-toggle="dropdown" aria-expanded="false" >'+_ph
			+'</button>'
			+'<ul class="dropdown-menu" role="menu">'
			+optionsHtml
			+'</ul>'
			+'</div>';
		}
		var $sel = $('<div class="select-list-item">'
			+'<div class="input-group" style="width:220px;float:left;">'
			+selectHtml
			+'<input type="text" class="form-control" '+readOnly+' value="'+(vals[1]||'')+'">'
			+'</div>'
			+'<span id="remove-btn" class="glyphicon glyphicon-trash" style="cursor:pointer;padding:10px;" aria-hidden="true"></span>'
			+'</div>');
		$sel.find('#remove-btn').on('click',function(){
			$sel.remove();
			changeVal(null);
		});
		$sel.find('a').off('click').on('click',function(){
			shorten($sel,$(this).text(),$(this).attr('id'));
			changeVal($(this).attr('id'));
		});
		$sel.find('input').off('change').on('change',function(){
			changeVal($(this).val());
		});
		$that.find('#select-list-items').append($sel);
	};
	$that.find('#plus-btn').on('click',function(){
		_buildItem();
	});
	if(value&&value.length>0){
		var valArray = value.split(';');
		for(var i=valArray.length-1;i>=0;i--){
			var valCell=valArray[i];
			_buildItem(valCell);
		};
	}
	return $that;
};
AI.FormField.prototype.buildSelectListElement1=function(elmentcfg){
	var _self = this;
	var label=elmentcfg.label;
	var value=elmentcfg.value||'';
	var storesql=elmentcfg.storesql;
	var fieldName=elmentcfg.fieldName;
	var label=this.getLabel(elmentcfg);
	var placeholder=elmentcfg.placeholder||'请选择';
	var readOnly=elmentcfg.isReadOnly&&elmentcfg.isReadOnly==='y' ? 'disabled' : '';
	var allowRepeat = elmentcfg.allowRepeat||false;
	var labelColSpan = elmentcfg.labelColSpan||2;

	var options=_self.getOptions(storesql,value);
	var optionsHtml='<option value="">'+placeholder+'</option>';
	var selVal='';
	for(var i=0;i<options.length;i++){
		var option=options[i];
		if(option.selected) selVal=option.id;
		optionsHtml+='<option id="'+option.id+'" '+readOnly+' value="'+option.id+'" name="'+option.name+'" num="'+i+'">'+option.name+'</option>';
	};

	$sel = $('<select id="'+fieldName+'-select" value="'+selVal+'" class="select-list form-control input-sm" style="width:220px">'+optionsHtml+'</select>');
	var html= '<div class="form-group form-group-sm">'
		+'<label for="'+fieldName+'" class="col-sm-'+labelColSpan+' control-label">'+label+'</label>'
		+'<div class="col-sm-'+(12-labelColSpan)+'">'
		+'<div class="input-group input-group-sm" id="'+fieldName+'">'
		+'</div>'
		+'<div id="select-list-items" style=" float: left;max-height:80px;width:220px;overflow-y:auto;"></div>'
		+'</div>'
		+'</div>';
	var $that=$(html).appendTo($("#"+elmentcfg.containerId));

	var changeVal = function(){
		var valStr='';
		for(var i=0;i<$that.find('.select-list-item').length;i++){
			var $item = $($that.find('.select-list-item')[i]);
			valStr += (';'+$item.find('input').val());
			/*valStr += (';'+$item.attr('id')+','+$item.find('input').val());*/
		}
		_self.triggerFieldChage(valStr.indexOf(';')==0?valStr.slice(1):valStr);
	};
	var _buildInput = function(id,value){
		value=value||'';
		var $textEl = $('<div id="'+id+'" class="input-group select-list-item" style="border:1px solid">'
			+'<input type="text" class="form-control input-sm" value="'+value+'" style="border:0 none;background:none;">'
			+'<span class="input-group-btn">'
			+'<button type="button" class="close remove-item"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>'
			+'</span>'
			+'</div>');
		$textEl.find('.remove-item').off('click').on('click',function(){
			$(this).parents('.select-list-item').remove();
			changeVal();
		})
		$textEl.find('input').off('change').on('change',function(){
			changeVal();
		});
		$that.find('#select-list-items').append($textEl);
		return $textEl;
	};

	if(value&&value.length>0){
		var valArray = value.split(';');
		for(var i=valArray.length-1;i>=0;i--){
			var valCell=valArray[i];
			/*if(valCell.indexOf(',')!=-1){
				var valCellArr = valCell.split(',');
				_buildInput(valCellArr[0],valCellArr[1]);
			}else{*/
				_buildInput(valCell,valCell);
			//}
		};
	}

	$sel.on('change',function(){
		var _val=$(this).val();
		if($that.find('#select-list-items #'+_val).length==0||allowRepeat){
			var $text = _buildInput(_val);
		}
		if(elmentcfg.addText&&$text){
			var num = $that.find('option#'+_val).attr('num');
			elmentcfg.addText(_val,options[parseInt(num)],$text,options);
		}
	});
	$that.find('#'+fieldName).append($sel);
	return $that;
};
AI.FormField.prototype.defaults = {//默认配置
	 type:'text',//字段类型,number,color,date,combox,checkbox,radio,file,
	 lable:'',
	 width:'',
	 labelPositon:'left',//top,
	 container:''//容器
}

//拖放程序
var SimpleDrag =Class.$extend({
	__init__ : function(config) {
		 config=config||{};
	    this.config=config;
	    this.init();
	},
  //拖放对象,触发对象
	init:function(){
	this.Drag=document.getElementById("idDrag");
	this._x = this._y = 0;
	this._fM = this.BindAsEventListener(this, this.Move);
	this._fS = this.Bind(this, this.Stop);
	this.addEventHandler(this.Drag, "mousedown", this.BindAsEventListener(this, this.Start));
  },
  //准备拖动
  Start: function(oEvent) {
	this._x = oEvent.clientX - this.Drag.offsetLeft;
	this._y = oEvent.clientY - this.Drag.offsetTop;
	this.addEventHandler(document, "mousemove", this._fM);
	this.addEventHandler(document, "mouseup", this._fS);
  },
  //拖动
  Move: function(oEvent) {
	this.Drag.style.left = oEvent.clientX - this._x + "px";
	this.Drag.style.top = oEvent.clientY - this._y + "px";
  },
  //停止拖动
  Stop: function() {
	this.removeEventHandler(document, "mousemove", this._fM);
	this.removeEventHandler(document, "mouseup", this._fS);
  },
  
  Bind: function(object, fun) {
		return function() {
			return fun.apply(object, arguments);
		}
	},

  BindAsEventListener: function(object, fun) {
		return function(event) {
			return fun.call(object, (event || window.event));
		}
	},

  addEventHandler: function(oTarget, sEventType, fnHandler) {
		if (oTarget.addEventListener) {
			oTarget.addEventListener(sEventType, fnHandler, false);
		} else if (oTarget.attachEvent) {
			oTarget.attachEvent("on" + sEventType, fnHandler);
		} else {
			oTarget["on" + sEventType] = fnHandler;
		}
	},

  removeEventHandler: function(oTarget, sEventType, fnHandler) {
	    if (oTarget.removeEventListener) {
	        oTarget.removeEventListener(sEventType, fnHandler, false);
	    } else if (oTarget.detachEvent) {
	        oTarget.detachEvent("on" + sEventType, fnHandler);
	    } else { 
	        oTarget["on" + sEventType] = null;
	    }
	}
});

var  SelectBox = Class.$extend({
    __init__ : function(config) {
	 config=config||{};
    this.config=config;
    this.id = "ai.selectbox";
    this.init();
  },
   
  init:function() {
  	console.log(this.config.sql);
  	var selectedValue = this.config.selectedValue;
  	this.config.resultsql ="select * from ("+this.config.sql+") resulttab where 1=2";
  	this.config.selectsql = this.config.sql;
  	if(selectedValue&&this.config.sql){
  		var valueArr = selectedValue.split(",");
  		var selectedcon = "";
  		var resultcon = "";
  		var hasKeyfield=/KEYFIELD/.test(this.config.selectsql);
  		for(var i = 0;i < valueArr.length;i++){
  			selectedcon += " AND VALUES1 <>'"+valueArr[i]+"'"+(hasKeyfield?(" and KEYFIELD <>'"+valueArr[i]+"'"):"");
  			if(i == 0){
  				resultcon += " VALUES1 = '"+valueArr[i]+"'"+(hasKeyfield?(" or KEYFIELD='"+valueArr[i]+"'"):"");
  			}else{
  				resultcon += " OR VALUES1 = '"+valueArr[i]+"'"+(hasKeyfield?(" or KEYFIELD='"+valueArr[i]+"'"):"");
  			}
  		}
  		this.config.resultsql = "select * from ("+this.config.sql+") selectedtab where 1=1 and  (" +resultcon+")";
  		this.config.selectsql = "select * from ("+this.config.sql+") selectedtab where 1=1 "+selectedcon;
  	}
  	this.config.selectsql=this.config.selectsql||"select MODELCODE VALUES1,MODELNAME VALUES2,'' VALUES3 from MINDER_MAP " ;
  	var self=this;
  	if($("#aiselectBox").length>0){
  		$("#aiselectBox").remove();
  	}
  	 
  	this.appendHtml();
   if(!this.config.sql) this.config.selectsql="select '' VALUES1,'' VALUES2,'' VALUES3 from (values(1))a";
	 this.selectStore= new AI.JsonStore({
	  	       id:'selectStore',
				 sql:this.config.selectsql,
				 dataSource:this.config.dataSource,
				 pageSize:9,
				 key:'VALUES1',
				 dataSource:this.config.dataSource||''
		});
    
	 
	 this.resultStore= new AI.JsonStore({
	  	   id:'resultStore',
		   sql:this.config.resultsql,
		   dataSource:this.config.dataSource,
			pageSize:9,
			key:'VALUES1' 
	 });
 
    var gridcfg={
    	id:'selectgrid',
    	title:'可选择对象',
    	containerId:'selectgrid',
    	store:this.selectStore,
    	rownumbers:'n',//y,n
    	pageSize:9,
    	multiselect: true,
    	//shrinkToFit:true,
    	//autowidth:true,
    	nowrap:true,
    	width:'98%',
    	height: 360,
      showcheck:true,
      columns:[
      {header:'名称',dataIndex:'VALUES1',key:true, width:60,align:"left", maxLength:21},
   		{header:'中文名',dataIndex:'VALUES2', width:90,align:"left", maxLength:10},
   		{header:'备注',dataIndex:'VALUES3', width:190,align:"left"}
      ]
    };
   var selectGrid= new    AI.Grid(gridcfg) ;
   
    var gridcfg={
    	id:'resultgrid',
    	containerId:'resultgrid',
    	 showcheck:true,
    	store:this.resultStore,
    	title:'已经选择对象',
    	rownumbers:'n',//y,n
    	pageSize:9,
    	multiselect: true,
    	width:'100%',
    	nowrap:true,
    	height: 260,
    	//shrinkToFit:true,
    	//autowidth:true,
      columns:[
      {header:'名称',dataIndex:'VALUES1',key:true,align:"left"},
   		{header:'中文名',dataIndex:'VALUES2', width:120,align:"left"}
   		//,{header:'备注',dataIndex:'VALUES3', width:120,align:"left"}
      ]
    };
   var resultGrid= new AI.Grid(gridcfg);
   
   	$("#btnSelecboxSearch").click(function(){
  		var keyword= ($("#aiselectboxKeywrod").val());
  	//	if(! keyword) alert('请输入关键字 ');
  		var newsql=self.config.sql;
  		var resultcon = "";
			for(var i=0;i<self.resultStore.getCount();i++){
	  	  var r=self.resultStore.getAt(i);
	  	  resultcon +=" and VALUES1<>'"+r.get("VALUES1")+"' ";
  		};
  		newsql="select * from ("+self.config.sql+") selecttab where (VALUES1 like '%"+keyword+"%' or VALUES2 like '%"+keyword+"%') "+ resultcon;
       self.selectStore.select(newsql);
  		return false;
  	});
   $('#movetoright').click(function(){
   	try{
   	  var recordSet=selectGrid.getCheckedRows();
   	  if(!recordSet ||recordSet.length==0) return;
   	  for(var i=0;i<recordSet.length;i++){
   	  		var r =recordSet[i];
   	  		var newRec=self.resultStore.getNewRecord();
   	  		for(var col in r.data){
   	  			newRec.set(col,r.get(col));
   	  		}

   	  		newRec.set('VALUES1',r.get('VALUES1'));
   	  		newRec.set('VALUES2',r.get('VALUES2'));
   	  		newRec.set('VALUES3',r.get('VALUES3'));
			newRec.set('VALUES4',r.get('VALUES4'));
   	    	self.resultStore.add(newRec);
   	     if(r) self.selectStore.remove(r);
   	  }
   	  selectGrid.resetCheckRowindex();
    // selectGrid.jqgrid.resetSelection();
    }catch(E){
    }   
   });
   $('#movetoleft').click(function(){
  	  var resultSet=resultGrid.getCheckedRows();
   	  if(!resultSet ||resultSet.length==0) return;
   	  try{
   	  for(var i=0;i<resultSet.length;i++){
   	  	var r=resultSet[i];
		var newRec=self.selectStore.getNewRecord();
		for(var col in r.data){
			newRec.set(col,r.get(col));
		}
		newRec.set('VALUES1',r.get('VALUES1'));
		newRec.set('VALUES2',r.get('VALUES2'));
		newRec.set('VALUES3',r.get('VALUES3'));
		self.selectStore.add(newRec);
		if(r)self.resultStore.remove(r);
   	  }
   	   resultGrid.resetCheckRowindex();
   	  }catch(E){
    } 
   });
  
  $("#selectOK").click(function(){
  	if(self.resultStore.getCount()==0){alert('没有选择记录');return false;};
  	var result=[];
  	for(var i=0;i<self.resultStore.getCount();i++){
  	  var r=self.resultStore.getAt(i);
  	  result.push(r);
  	};
  	if(self.config.callback){
  		if(self.config.callback(result)==false) return false;
  	};
  });
 
	},
	show:function(sql,callback){
		if(callback) this.config.callback=callback;
		if(sql){
			this.config.sql=sql;
			this.config.selectsql=sql
		};
		  this.selectStore.select(this.config.selectsql);
			this.resultStore.select(this.config.resultsql); 	 
		
		$("#aiselectBox").modal({                    // wire up the actual modal functionality and show the dialog
	        "backdrop"  : this.config.backdrop ||false,
	       "keyboard"  : true,
	        height:700,
	        "show"      : true                     // ensure the modal is shown immediately
	       }).css({
	       	"margin-left":0,
	       	"z-index":9999999999
       });
		
    	$('#body').on('click','#idDrag',function(){
    		new SimpleDrag();
    		
    	});
	},
	appendHtml:function(){
	
	var html='<div id="aiselectBox"  class="modal  fade">'
  +'<div class="modal-dialog modal-lg">'
      +' <div class="modal-content" id="idDrag" style="position:absolute;padding:0px;width:900px;height:470px;">'
      +'  <nav class="navbar navbar-default" role="navigation" style="min-height:30px;margin-bottom:5px"> <div class="container-fluid">   <div class="collapse navbar-collapse" > <form class="navbar-form navbar-left" > <div class="form-group"> <input id="aiselectboxKeywrod" type="text" class="form-control" placeholder="输入关键字"> </div> <button id="btnSelecboxSearch" class="btn btn-sm">查找</button> </form> </div> </div> </nav>'
      +'  <div class="modal-body" id="aiselectBoxbody" style="padding:0px;height:370px">'
      +'	   <div class="container-fluid" style="padding:0px">'
   
      +'      <div class="row-fluid" style="padding:0px ;" >'
      +'  	   <div id="selectgrid" class="col-md-6" style="height:370px;overflow:scroll ">'
         	   	  
      +'  	   	</div>'
      +'  	   <div class="col-md-1" >'
      +'  	   	   <br><br><br><br>'
      +'              <button id="movetoright" class="btn btn-large btn-primary" type="button">>></button>'
      +'           <br><br><br>'
      +'              <button id="movetoleft" class="btn btn-large" type="button"><<</button>'
      +'            </p>'
      +'  	   	</div>'
      +'  	   <div id="resultgrid" class="col-md-5" style="height:370px;overflow:scroll">'
      	   	   
      +'  	   	</div>'
      +'  </div>'
      +'</div>'
      +'</div>'
      +'<div class="modal-footer" style="padding: 5px 5px 5px">'
      +'  <button id="aiselectBox-cansel" class="btn" data-dismiss="modal" aria-hidden="true">关闭</button>'
      +'  <button id="selectOK" class="btn btn-primary" data-dismiss="modal" aria-hidden="true">确定</button>'
      +'</div>'
      +'</div> ';
    $(html).appendTo("body");
	}
});