var Global ={};
if(window.parent.parent)  Global = window.parent.parent.Global;
meta = function() {
	return {
		objtypes:[],///元数据类型
		metaStore:{},///元数据对象存储信息
	    ActionDef:null,///元数据对象的操作方法
		init:function(){
			var store = ai.getJsonStore("select OBJTYPE, OBJCODE, OBJNAME, ORDSEQ, REMARK, TABNAME,  RULETAB, KEYFIELD, NAMEFIELD, LOGTAB, TIMEFIELD, RUNTABNAME,  DETAILURL, RUNURL,OBJACT from DQOBJMODEL");
			for(var i=0;i<store.getCount();i++){
				var r=store.getAt(i);
				r.set('icon',r.get("OBJTYPE").toLowerCase()+".png");
				this.metaStore[r.get('OBJTYPE')]=r.data;
			}; 
			///增加额外的注册
			 
			 meta.metaStore['other']={OBJTYPE:'other',OBJNAME:'混合', OBJACT:'createApp'}	; 
		},
    initBase:function(objtype,objname,_prj){
      ///是否需要分项目组进行定制呢？
      //meta.store=Asiainfo.getStore("select * from DQOBJMODEL_DEF"+_prj+" where objcode='"+objtype+"'");
      meta.store=ai.getStore("select * from DQOBJMODEL_DEF  where objcode='"+objtype+"'");
      if(meta.store.count==0){alert('没有配置元数据的基本信息');return;};
      for(var i=0;i<meta.store.count;i++){
        var r=meta.store.root[i];
        var paracode=r['PARACODE'];
        var paratext=r['PARATEXT'];
        if(paracode=='metabase')
          Ext.apply(meta,Ext.decode(paratext));
        else if(paracode=='viewdetail')
           meta.viewdetail = paratext
      }; 
    },
		getMetaActionDef:function(){///获取对象的操作配置
			if(this.ActionDef) return this.ActionDef;
			
	 		this.ActionDef={};
	 		var actItmes=ai.getStoreData("select rowcode,rowname,type,remark from metaedimdef WHERE dimcode='DIM_ACTION'");
	 		if(actItmes.length==0){alert('没有配置对象操作方法，请在元模型配置中进行定义');return };
	 		for(var i=0;i<actItmes.length;i++){
	 			var item=actItmes[i];
	 			this.ActionDef[item.ROWCODE]= {name:item.ROWNAME,icon:item.TYPE||"info",accesskey:'i',url:item.REMARK};
	 		};
	 	   return this.ActionDef;
		},
		 
	 
		getRuleEditerCfg:function(){ //规则设置的配置模型,如果有，则加载配置，否则加载默认配置
			var rulefieldStr ="";
			var result={};
			for(var i=0;i<meta.store.count;i++){
				var r=meta.store.root[i];
				var paracode=r['PARACODE'];
				var paratext=r['PARATEXT'];
			  if(paracode=='rulefield') {
			  	rulefieldStr = paratext;
			  	break;
			  } 
			};
			 
			if(!rulefieldStr){////默认配置
				result.columns=[
				  {header: "规则名称",width: 250,dataIndex:"RULENAME",renderer:"ruleTitle",canEdit:false},
		      {header: "操作",width:160,dataIndex: "RULETYPE",renderer:"ruleAct",canEdit: false} ,
		      {header: "状态",width: 70,dataIndex: "RULELEVEL",canEdit: true,editertype:'combo',storesql:"select ROWCODE, ROWNAME  from METAEDIMDEF where dimcode='DIM_DQ_RULELEVEL'"},
		      {header: "告警级别",width: 70,dataIndex: "ALARM_LEVEL",canEdit: true,editertype:'combo',storesql:"select ROWCODE, ROWNAME  from METAEDIMDEF where dimcode='DIM_DQ_ALARMLEVEL'"},
		      {header: "规则维护模式",width: 70,canEdit: true,dataIndex: "CHKCYCLE" ,editertype:'combo',storesql:"select ROWCODE, ROWNAME  from METAEDIMDEF where dimcode='DIM_DQ_CHKCYCLE'" },
		      {header: "规则描述",width: 500, canEdit: false, dataIndex: "REMARK",renderer:function(v, metadata, record, rowIndex, columnIndex, store){
		      	 return v
		      }}
		    ]
			}
			else{
				try{
				   result.columns =Ext.decode(rulefieldStr);
				}catch(e){
							alert("对象模板中rulefield配置错误,"+e);
			  };
			};
			result.editers=[];
			if(!result.columns) return null;
			for(var i=0;i<result.columns.length;i++){
				var column=result.columns[i];
				if(column.renderer=="ruleAct" || column.dataIndex=='RULETYPE') column.renderer= ruleActFun;
				if(column.dataIndex=="RULENAME") column.renderer= ruleTitleRender;
				if(column.editertype=='combo' && column.storesql){
					var dimJson = meta.getDimArray(column.dataIndex,column.storesql);

					column.renderer= function(data, metadata, record, rowIndex, columnIndex, store){
						if(!data) return "";
						return meta.dim[metadata.id][data] || data;
		      };
		      if(column.canEdit){
		      	var editer ={dataIndex:column.dataIndex,xtype:'combo',storesql:column.storesql};
		      	result.editers.push(editer);
		      };
				};
			};
			return result; 
		},
		getDimArray:function(dimcode,sql){
			if(!meta.dim) meta.dim={};
			if(meta.dim[dimcode]) return meta.dim[dimcode];
			meta.dim[dimcode]={};
			var tmpStore = Asiainfo.getStore(sql);
			var vfield,dfield;
			if(tmpStore.recordFields.length==1) {vfield=tmpStore.recordFields[0].name;dfield=tmpStore.recordFields[0].name}
		  else{vfield=tmpStore.recordFields[0].name;dfield=tmpStore.recordFields[1].name;}
			for(var i=0;i<tmpStore.getCount();i++){
				var r = tmpStore.getAt(i);
				meta.dim[dimcode][r.get(vfield)]=r.get(dfield);
			};
			return meta.dim[dimcode];
		},
		checkObjExists:function(objtype, objname, _prj) {///检查对象是否存在
    		var metaInfo = this.metaStore[objtype];
            objname = objname||"";
   			 if(!metaInfo) {
       		 alert('未知对象类型:' + objtype);
       		 return false;
    		}  ;
    		switch(objtype){
                case 'INTER':_keyfield='FULLINTERCODE';break;
                case 'PROC':_keyfield='PROC_NAME';break;
                case 'TAB':_keyfield='DATANAME'; break;
                case 'DATAFLOW':_keyfield='FLOWCODE';break;
                case 'APP':_keyfield='APPCODE';break;
                default :_keyfield=metaInfo.KEYFIELD;break;
              }
    		var _tmpsql = "select 1 from " + metaInfo.TABNAME + " where " + _keyfield + "='" + objname.toUpperCase() + "' {condition}";
			if(_prj.trim()==''||_prj==null){
				_tmpsql=_tmpsql.replace("{condition}","");
			}else{
				_tmpsql=_tmpsql.replace("{condition}","and dbname='"+_prj+"'");//表名+库名确定唯一性，暂时使用备用参数，还不知道这个参数的作用。为避免多传一个参数导致别的地方引用错误
			}
    		var _ds = ai.getJsonStore(_tmpsql);
    		if(_ds.getCount() > 0) return true
    		else return false;
     	},
     	checkMetaProperty: function(objtype, rec, _prj) {
			function CheckProc(){////检查程序
		
			};
			function chekTab(){
			};
	
  			var result = true, remark = '';

    		var proPerty = metaProperties[objtype];

   			 if(!proPerty) return result;
    		for(key in proPerty) {

       	if(!rec.get(key)) {
            remark += proPerty[key] + ',';
            result = false;
        }

    	}
    	;
    		if(remark) alert(objtype + '关键属性检查:' + remark + '不允许为空,请输入');

    		return result;
		},
		showDetail: function(objtype, objname,metaprj,objcnname,topicname,topiccode,leve,cycle,opentype) {
    			var metaInfo = metaStore[objtype];
    			if(!metaInfo) {
    			    return false;
    			} ;
    			 
    			var _url = metaInfo.detailUrl.replace('{OBJNAME}', objname);
    			var opentype=opentype||metaInfo.opentype;
    			if(metaprj) _url+="&METAPRJ="+metaprj;
    			if(objcnname) _url+="&OBJCNNAME="+objcnname.trim();
    			if(topicname) _url+="&TOPICNAME="+topicname;
    			if(topiccode) _url+="&TOPICCODE="+topiccode;
    			if(leve) _url+="&LEVEL="+leve;
    			if(cycle) _url+="&CYCLE="+cycle;
    			_url = '/{contextPath}/' + _url  ;
    			if(opentype == 'newwin') window.open(_url.replace('{contextPath}',contextPath))
    			else if(opentype == 'openmodel') Asiainfo.ShowWin(objcnname,_url.replace('{contextPath}',contextPath))
    			else Asiainfo.addTabSheet(objname, objtype + ':' + objname, _url)
		} ,
	  transTabname : function(metaprj) {///根据传入项目，获取对象的存储的表
				    var aft = "_" + metaprj;
				    for(var key in metaStore) {
				    	   
				        if(metaStore[key].tabname) {
				            metaStore[key].tabname = metaStore[key].tabname + aft;
				        }
				
				        if(metaStore[key].histab) {
				            metaStore[key].histab = metaStore[key].histab + aft;
				        }
				    }
	  },
	  prettySql:function(sql){
	  	   var url ="/"+contextPath+"/meta/parser?cmd=PrettySql&dbtype=mysql&sqltext="+sql;
         var resultSql=ai.remoteData(url,false);
	      return resultSql;
	  },
	  parserProcMeta: function(procname, metaprj, dbtype) {///进行元数据对象解析
			    if(metaprj) metaprj = "_" + metaprj
			    else metaprj="";
			    if(!dbtype) dbtype = "mysql";
			    ai.executeSQL("delete from transdatamap_tmp");
			    ai.executeSQL("delete from transmap_tmp");
			
			    var objdefsql = "select proc_name as objname,sql_text as \"sql\",'' dbuser,step_seq from proc_step" + metaprj + " where proc_name='" + procname + "'";
			    var _url ='/'+contextPath+'/meta/parser?cmd=parserAct&dealtype=allmaptodb&procname=' + procname + '&metaprj=' + metaprj + '&dbtype=' + dbtype + '&objDefSql=' + objdefsql;
			    var str = ai.remoteData(_url, false);
			    
			    var _sql = "insert into TRANSDATAMAP" + metaprj + " (TRANSNAME,TARGET,SOURCE,STATE,TRANSTYPE,TAGGETTYPE,SOURCETYPE,seq) " +
			        "select transname, target, source,'DATA','ETL','DATA','DATA',max(seq) seq from transdatamap_tmp a " +
			        "where not exists (select 1 from  TRANSDATAMAP" + metaprj + " b where a.transname=b.transname and a.target=b.target and a.source=b.source) " +
			        "group by  transname,target,source";
			    ai.executeSQL(_sql);
			    var _sql = "insert into TRANSMAP" + metaprj + " (TRANSNAME,TARGETDATANAME,TARGETCOLNAME,SOURCEDATANAME,SOURCECOLNAME,TRANSSQL,STATE,SEQ,PARENUNICODE,UNICODE) " +
			        "select TRANSNAME,TARGETDATANAME,TARGETCOLNAME,SOURCEDATANAME,SOURCECOLNAME,max(transsql),'DATA',max(SEQ),concat(SOURCEDATANAME,'.',SOURCECOLNAME),concat(TARGETDATANAME,'.',TARGETCOLNAME) " +
			        "from TRANSMAP_TMP a " +
			        "where not exists(select 1 from TRANSMAP" + metaprj + " b where a.TRANSNAME=b.TRANSNAME and a.TARGETDATANAME=TARGETDATANAME " +
			        " and a.TARGETCOLNAME=b.TARGETCOLNAME and a.SOURCEDATANAME=b.SOURCEDATANAME and a.SOURCECOLNAME=b.SOURCECOLNAME)" +
			        "   group by TRANSNAME,TARGETDATANAME,TARGETCOLNAME,SOURCEDATANAME,SOURCECOLNAME";
			    ai.executeSQL(_sql);
     },
     metaOperate:function(objtype,edittype,objname,objcnname,metaprj,pathCode,fullPathName){
      
     	if(edittype.indexOf("create")>=0 && edittype!="create") {
     		objtype=edittype.replace("create","");
     		edittype="create";
     	};
     	var _url="";
     	var editName="";
       objtype = /ETL/i.test(objtype)?'PROC':objtype;
     	var metacfg = meta.metaStore[objtype];
     	if(!metacfg) {alert('unkonw:'+objtype);return false};
     	if(edittype=="view"){editName="查看";_url=metacfg.RUNURL||metacfg.DETAILURL} 
      if(edittype=="preview"){editName="预览";_url=pathCode}
     	else if(edittype=="create"){
     		editName="新建";
     		_url=metacfg.DETAILURL.replace("{KEYFIELD}","");
     		objtype=objtype.toUpperCase();
     		//控件原因先注释掉
     		//meta.registNewMetaObj(objtype  );
     		//return;
     	}
     	else if(edittype=="edit"){
     		editName="修改";
     		_url=metacfg.DETAILURL;
     	}
        
       	if(_url) {
       		 _url=_url.replace("{contextPath}",contextPath).replace("{KEYFIELD}",objname).replace("{OBJNAME}",(objname||""));
       		 if(_url.indexOf("opener=window")>0){
      	  	   	 window.open(_url);	
      	  	  } 
      	  	  else if(_url.indexOf("opener=")<0){
      	  	  	  var title = editName+metacfg.OBJNAME;
      	  	  	  if(_url.indexOf("?")>0  ) _url+="&opener=tabsheet"
      	  	     else _url+="?opener=tabsheet";
      	  	     ai.openDialog(_url,objname,title);	
      	  	  };
       	}
       	else this.metaAction(edittype,objtype,objname,objcnname,metaprj);
 
    },
     metaAction:function(actionkey,objtype,objname,objcnname,metaprj){
     	    var actItem =  this.ActionDef[actionkey];
     	    if(!actItem) {alert('未知的操作：'+actionkey+",请在DIM_ACTION增加操作配置");return;}
     	      var _url=actItem.url;
      	  	  _url=_url.replace("{contextPath}",contextPath);
      	  	  _url = _url.replace("{KEYFIELD}",objname);
      	  	  _url=_url.replace("{OBJNAME}",objname);
      	  	  _url=_url.replace("{OBJCNNAME}",objcnname);
      	  	   _url=_url.replace("{OBJTYPE}",objtype);
      	  	   if(_url.indexOf("opener=window")>0){
      	  	   	 window.open(_url);	
      	  	  } 
      	  	  else if(_url.indexOf("opener=")<0){
      	  	  	 var title=this.ActionDef[actionkey].name+(objname||"");
      	  	  	  if(_url.indexOf("?")>0  ) _url+="&opener=tabsheet"
      	  	     else _url+="?opener=tabsheet";
      	  	     ai.openDialog(_url,objname,title);	
      	  	  };
   	 
    },
    registNewMetaObj:function(objtype,beforeSave,aftSave){////新建元数据对象表单
    	  var metaInfo =  this.metaStore[objtype];
    	  var objAttrStore=ai.getStoreData("select OBJTYPE, ATTRGROUP, ATTRNAME, ATTRCNNAME, INPUTTYPE,INPUTPARA, ISNULL, SELVAL, SELMODEL, SEQ, REMARK from METAOBJCFG where objtype='" + objtype + "' and ATTRGROUP   order by ATTRGROUP,SEQ ");
         
         var  objStore = new AI.JsonStore({
                sql: "select * from " + metaInfo.TABNAME + " where 1=2 "  ,
                table: metaInfo.TABNAME,
                loadDataWhenInit: true,
                secondTable:"METAOBJ",
                key: metaInfo.KEYFIELD
            });
           objStore.on("beforecommit",function(){
       	     for(var i=0;i<objStore.getCount();i++){
              var _keyfield='';
              switch(objtype){
                case 'INTER':_keyfield='FULLINTERCODE';break;
                case 'PROC':_keyfield='PROC_NAME';break;
                case 'TAB':_keyfield='DATANAME';break;
                case 'DATAFLOW':_keyfield='FLOWCODE';break;
                default :_keyfield=metaInfo.KEYFIELD;break;
              }
       	       var r=objStore.getAt(i);
       	       r.set('XMLID', ai.guid());
       	       r.set('OBJTYPE', objtype);
       	       r.set('OBJNAME',r.get(_keyfield));
       	       r.set('OBJCNNAME',r.get(metaInfo.NAMEFIELD));
       	    };
       	     return true;
          });
            objrecord = null;
            if (objStore.getCount() == 0) {
              actType="add";
              objrecord = objStore.getNewRecord();
              for (var key in Global) {
              	   if(typeof  Global[key]!='object')   
              	       objrecord.set(key.toUpperCase(), Global[key]);
              };
              for (var key in paramMap) {
                objrecord.set(key.toUpperCase(), paramMap[key]);
              };
              objStore.add(objrecord);
              objrecord.set('CREATER', _UserInfo.usercnname);
              objrecord.set('EFF_DATE', new Date());
              objrecord.set('STATE', '新建');
              objrecord.set('STATE_DATE', new Date());
              objrecord.set('CURDUTYER', _UserInfo.usercnname);
              objrecord.set('VERSEQ', 1);
              if(objtype=='INTER'){
                var no = ai.remoteData("/"+contextPath+"/sequenceService").toString();
                for(var i=6-no.length;i>0;i--){
                  no = '0' + no;
                }
                objrecord.set('BASENO',no);
              }
            }else {
              objrecord = objStore.getAt(0);
              var ffcode = objrecord.get('FULLINTERCODE')||'';
              objrecord.set('BASENO',ffcode.length>8?ffcode.slice(1,7):'');
              var extend_cfg = objrecord.get('EXTEND_CFG');
              if (extend_cfg) {
                var cfg = JSON.parse(extend_cfg);
                $.each(cfg, function(key, value) {
                  objrecord.set('EXTEND_CFG--' + key, value);
                });
              }
            };
           
            var formItems = [];
            for (var i = 0; i < objAttrStore.length; i++) {
                var attrItem = objAttrStore[i];
                if(!attrItem.ATTRGROUP) continue;
                defaultwidth = 220;
                if (attrItem.INPUTTYPE == 'textarea') defaultwidth = 420;
                if (attrItem.INPUTTYPE == 'pick-grid') defaultwidth = 320;
                if (attrItem.INPUTTYPE == 'check') attrItem.INPUTTYPE = 'checkbox';
                if (attrItem.INPUTTYPE == 'combo') attrItem.INPUTTYPE = 'combox';
                if (attrItem.INPUTTYPE == 'label') continue; //attrItem.inputtype='html';
                if (!attrItem.INPUTTYPE) attrItem.INPUTTYPE = 'text';
                var readonly = attrItem.SELMODEL=='readOnly'?'y':'n';
                if(attrItem.ATTRNAME=='DBUSER') readonly='y';
                if(attrItem.ATTRNAME=='PROC_NAME' && actType=='edit'){
                    readonly='y';
                }else if(attrItem.ATTRNAME=='PROC_NAME' && attrItem.ATTRNAME=='add'){
                    readonly='n';
                }
                if(!Global||(!Global.team&&!Global.teamCode&&!Global.teamcode&&!Global.TEAMCODE)){
                  if(attrItem.ATTRNAME=='DBNAME'){
                    attrItem.INPUTPARA="select dbname,cnname from metadbcfg";
                  }else if(attrItem.ATTRNAME=='EXTEND_CFG.SOURCE_TAB'||attrItem.attrname=='EXTEND_CFG.TARGET_TAB'){
                    attrItem.INPUTPARA="select dataname values1,datacnname values2 FROM tablefile";
                  }
                }
             
                var formItem = {
                    type: attrItem.INPUTTYPE || 'text',
                    label: attrItem.ATTRCNNAME ||attrItem.ATTRNAME ,
                    notNull: attrItem.ISNULL || 'Y',
                    isReadOnly:readonly,
                    storesql: attrItem.INPUTPARA,
                    fieldName: attrItem.ATTRNAME,
                    width: defaultwidth,
                    tip: attrItem.REMARK,
                    dependencies: attrItem.DEPENDENCIES,
                    checkItems: attrItem.CHECKITEMS
                };
                if(attrItem.ATTRNAME=='SOURCEDIR'){
                    formItem.allowRepeat=true;
                    formItem.addText=function(val,option,$el){
                        $el.find('input').val(val+'请输入文件路径');
                    };
                }
                formItems.push(formItem);
            };

            var formcfg = ({
            	 title:'新建'+metaInfo.OBJNAME,
            	  lock:true,
                id: 'baseInfoForm',
                store: objStore,
                containerId: 'baseInfoForm',
                //fieldChange:fieldChange,
                fieldChange: function(fieldName, newVal) {
                     if(fieldName=='INTER_TYPE'||fieldName=='DATAREGION'||fieldName=='SOURCESYS'){
                        var intertype = objrecord.get('INTER_TYPE')||'';
                        var dataregion = objrecord.get('DATAREGION')||'';
                        var sourcesys = objrecord.get('SOURCESYS')||'';
                        var fullID = intertype+objrecord.get('BASENO')+dataregion+sourcesys;
                        objrecord.set('FULLINTERCODE',fullID);
                        $('#FULLINTERCODE').val(fullID);
                    }
                    if(fieldName=='SOURCEDIR'){
                        var valArr1=newVal.split(";");
                        var valStr = '';
                        for (var i = valArr1.length - 1; i >= 0; i--) {
                            valStr += (";"+valArr1[i].split(",")[1]);
                        };
                        objrecord.set(fieldName,valStr&&valStr.length>0?valStr.slice(1):valStr);
                    }
                },
                items: formItems
            });
        function checkInputForm(){
            var result =true;
            var r = objStore.curRecord;
            var extend_cfg={};
            var extend_cfgstr = objrecord.get('EXTEND_CFG');
            if (extend_cfgstr) {
              extend_cfg = JSON.parse(extend_cfgstr);
            }
            for(var i=0;i<objAttrStore.length;i++){
        	 	  var attr = objAttrStore[i];
        	 	  if(attr.ISNULL=='N' ){
                if(attr.ATTRNAME.indexOf("EXTEND_CFG.")>=0){
                  var attrKey = attr.ATTRNAME.split(".")[1];
                  if(!extend_cfg[attrKey]){
                    alert(attr.ATTRCNNAME+",扩展信息,不允许为空");
                    result=false;
                    break;
                  }else if(attr.length&&extend_cfg[attrKey].length>attr.length){
                    alert(attr.ATTRCNNAME+"长度超出！");
                    result=false;
                    break;
                  }
                }else if( !r.get(attr.ATTRNAME) ){
                   alert(attr.ATTRCNNAME+"不允许为空");
                   result=false;
                   break;
                }else if(attr.length&&r.get(attr.ATTRNAME).length>attr.length){
                  alert(attr.ATTRCNNAME+"长度超出！");
                  result=false;
                  break;
                }
        	 	  }
        	};
        	 return result;
        };
           function afterOK(fieldval){ 
               console.log(objrecord);
           	 objStore.commit();
           	 if(aftSave) return aftSave(fieldval,objStore);
          };
          function beforeOK(fieldval){//进行检验
          	   if(!checkInputForm()) return false;
          	   //if(beforeSave) return beforeSave(fieldval,objStore)
          };
           
          ai.showDialogForm(formcfg,beforeOK,afterOK);
    },
    viewMetaObj:function(objtype,objname){
    	var metaInfo =  this.metaStore[objtype];
    	var objAttrStore=ai.getStoreData("select OBJTYPE, ATTRGROUP, ATTRNAME, ATTRCNNAME, INPUTTYPE,INPUTPARA, ISNULL, SELVAL, SELMODEL, SEQ, REMARK from METAOBJCFG where objtype='" + objtype + "' and ATTRGROUP   order by ATTRGROUP,SEQ ");
      
      var  objStore = new AI.JsonStore({
                sql: "select * from " + metaInfo.TABNAME + " where  "+ metaInfo.KEYFIELD + "='" + objname + "'" ,
                table: metaInfo.TABNAME,
                loadDataWhenInit: true,
                secondTable:"METAOBJ",
                key: metaInfo.KEYFIELD
            });
       objrecord = null;
       if (objStore.getCount() == 0) {
      		objrecord = objStore.getNewRecord();
      	}else{
      		objrecord = objStore.getAt(0);
      	}     
        var viewMetaHtml ='<section class="panel panel-info"><header class="panel-heading"><i class="fa fa-comments text-muted"></i> <b>数据表信息</b></header>'
														+'<table id = "data_info" class="table table-striped m-b-none"><thead><tr><th>表字段</th><th>值</th></tr></thead><tbody>';
				
				var tipMetamodel='<tr><td>{attrcnname}</td><td id="{attrname}" class="num-in-table">{attrvalue}</td></tr>';
				for (var i = 0; i < objAttrStore.length; i++) {
					var attrItem = objAttrStore[i];
					switch(attrItem.INPUTTYPE){
						case 'text': viewMetaHtml += tipMetamodel.replace('{attrcnname}',attrItem.ATTRCNNAME).replace('{attrname}',attrItem.ATTRNAME).replace('{attrvalue}',objrecord.get(attrItem.ATTRNAME)||"");break;
						case 'combo':viewMetaHtml +=meta.getNotTextElemnt(attrItem);break;
						case 'radio':viewMetaHtml +=meta.getNotTextElemnt(attrItem);break;
						case 'selectList':viewMetaHtml +=meta.getNotTextElemnt(attrItem);break;
						default:
            	viewMetaHtml += tipMetamodel.replace('{attrcnname}',attrItem.ATTRCNNAME).replace('{attrname}',attrItem.ATTRNAME).replace('{attrvalue}',objrecord.get(attrItem.ATTRNAME)||"");break;
					}
				}											
				viewMetaHtml +='</tbody></table></section>';
				ai.showDialogview(viewMetaHtml);							       
    },
    getNotTextElemnt:function(attrItem){
    	var tipMetamodel='<tr><td>{attrcnname}</td><td id="{attrname}" class="num-in-table">{attrvalue}</td></tr>';
    	if(objrecord.get(attrItem.ATTRNAME)){
    		var selVal = objrecord.get(attrItem.ATTRNAME);
    		var valueArray=selVal?selVal.toString().split(","):[];
    		var tempAtrrValue ="";
    		var storesql = attrItem.INPUTPARA;
    		if(storesql){
    			if(storesql.toLowerCase().indexOf('select ')!=-1 &&
						storesql.toLowerCase().indexOf(' from ')!=-1){
						var store=ai.getStoreData(storesql);
						var attrNames=store.length>0?ai.getJsonAttrName(store[0]):'';
						for(var i=0;i<store.length;i++){
							var r=store[i];
							if(valueArray.indexOf(r[attrNames[0]])!=-1){
								tempAtrrValue+=r[attrNames.length==1?attrNames[0]:attrNames[1]]+",";
							}
						}
					}else if(storesql.indexOf("|")>=1){
						var tmpArray=storesql.split("|");
						for(var i=0;i<tmpArray.length;i++){
							var option=tmpArray[i];
							if(valueArray.indexOf(option.split(",")[0])!=-1){
								tempAtrrValue+=option.split(",")[0]+",";
							}
						}	
					}else if(storesql){
						var tmpArray=storesql.split(",");
						for(var i=0;i<tmpArray.length;i++){
							var option=tmpArray[i];
							if(valueArray.indexOf(option)!=-1){
								tempAtrrValue+=option+",";
							}
						}	
					}				
    		}
    		tipMetamodel = tipMetamodel.replace('{attrcnname}',attrItem.ATTRCNNAME).replace('{attrname}',attrItem.ATTRNAME).replace('{attrvalue}',tempAtrrValue.substring(0,tempAtrrValue.length-1));
    	}else{
    		tipMetamodel = tipMetamodel.replace('{attrcnname}',attrItem.ATTRCNNAME).replace('{attrname}',attrItem.ATTRNAME).replace('{attrvalue}','');
    	}
    	return tipMetamodel;
    },
    addMyFav:function(objinfo){///增加到我的关注
    	 var myfavstore=  new AI.JsonStore({
                sql:"select * from  MY_FAV  where username='"+_UserInfo.username+"' and xmlid='"+objinfo.XMLID+"'",
                table:"MY_FAV",
                key:"XMLID",
                pageSize:-1
          });
          
          if(myfavstore.getCount()>0) {return};
          var r=myfavstore.getNewRecord();
          r.set('XMLID',objinfo.XMLID);
          r.set('USERNAME',_UserInfo.username);
          r.set('OBJTYPE',objinfo.OBJTYPE);
          r.set('OBJNAME',objinfo.OBJNAME);
          r.set('OBJCNNAME',objinfo.OBJCNNAME);
          myfavstore.add(r);
          myfavstore.commit();
    },
     metaEffectAnaly:function(objtype,objname,metaprj){///影响分析
      var _url="/{contextPath}/asiainfo/gojs/pageFlow.html?objname=A01007";
     	window.open(_url);
     },
     metaRelaAnaly:function(objtype,objname,metaprj){///血缘分析
     		var _url="/{contextPath}/asiainfo/ProcGraph/rela.html?annyType=DATA&relaName=K10001&annyDirection=Up&granularity=ALL&level=4";
     	   	window.open(_url);
     },
     metaProcFieldMap:function(objtype,objname,metaprj){///程序，指标的字段映射图
      var _url="/"+contextPath+"/{contextPath}/asiainfo/ProcGraph/fieldMap.html?annyType=fieldmap&level=5&relaName="+objname;
      window.open(_url);
    },
    metaProcFieldRela:function(){///某个表的字段血缘关系图
      var _url="	/{contextPath}/asiainfo/ProcGraph/fieldMap.html?annyType=fieldmap&level=5&relaName=KPI_09_ZZ_00";
      window.open(_url);
    },
    grantTable:function(dbname,tabame,grantUser){
    	  if(dbname=='hive') {
    	  	//privileges(授权)/revoke(撤销授权)  privilege:select/insert/all 
    	    	var cmd = {key:"privileges",value:{table:tabame,database:'',action: privileges, privilege:"select" }}
            _url = "http://10.191.116.174:18080/security/hive/"+grantUser+"/"+'{key:"privileges",value:{table:tabame,database:"cqocdc",action: privileges, privilege:"select" }}';
            ai.remotData(_url);
    	   };
    },
    backUpVersion:function(chgCause) {
    	var _sql = "insert into PROC_HIS(PROC_NAME,INTERCODE,PROCCNNAME,INORFULL,CYCLETYPE,TOPICNAME,EFF_DATE,IF_CHILD,CREATER,STATE,STATE_DATE,STARTDATE,STARTTIME,ENDTIME,PARENTPROC,REMARK,PROCTYPE,PATH,RUNMODE,DBUSER,RUNPARA,RUNDURA,DEVELOPER,CURDUTYER,VERSEQ,LEVEL_VAL,XML,CAUSE) ";
   		 _sql += "select PROC_NAME,INTERCODE,PROCCNNAME,INORFULL,CYCLETYPE,TOPICNAME,EFF_DATE,IF_CHILD,CREATER,STATE,STATE_DATE,STARTDATE,STARTTIME,ENDTIME,PARENTPROC,REMARK,PROCTYPE,PATH,RUNMODE,DBUSER,RUNPARA,RUNDURA,DEVELOPER,CURDUTYER,VERSEQ,LEVEL_VAL,XML,'" + chgCause + "' as CAUSE   ";
    	_sql += "from " + metaStore['PROC'].tabname + " where PROC_NAME='" + procName + "'";
    	var result = Asiainfo.executeSQL(_sql, false);

    	var _sql = "insert into PROC_STEP_HIS(PROC_NAME,STEP_SEQ,S_STEP,F_STEP,N_STEP,STEP_NAME,STEP_TYPE,STEP_CODE,SQL_TEXT,DBNAME,REMARK,VERSEQ)";
   		 _sql += "select PROC_NAME,STEP_SEQ,S_STEP,F_STEP,N_STEP,STEP_NAME,STEP_TYPE,STEP_CODE,SQL_TEXT,DBNAME,REMARK," + procrec.get('VERSEQ') + " from " + metaStore['PROC_STEP'].tabname + " where PROC_NAME='" + procName + "'";
   		 var result = Asiainfo.executeSQL(_sql, false);
     },
     compareVersion:function(){///版本比较
     },
     compareObj:function(){///上线
     	var _url = "/{contextPath}/devmgr/ObjCompare.html?OBJTYPE=PROC&OBJNAME=newEtlDesign&TARDB=&SOURDB=METADB&ONLYDIFF=F&METAPRJ=SC";
     	
     },
	  getRightInfo : function(objtype, state, curdutyer) {///取得当前用户对当前对象的权限级别
	  	var stateControl=[
	  	    {state:'新建',actions:[{actowner:'creater',actname:'提交测试',actcode:'commit2test',aftstate:'测试'},
	  	    	{actowner:'creater',actname:'提交上线',actcode:'commit2upline',aftstate:'上线'}
	  	    ]},
	  	    
	  	];
    //state:新建->修改->发布->修改
    if(!state) state = '发布';
    if(!curdutyer) curdutyer = _UserInfo.usercnname;
    var autidtitle = '执行变更';

    if(state == '编辑') autidtitle = '执行发布'
    else if(state == '修改') autidtitle = '执行发布'
    else if(state == '新建') autidtitle = '执行发布'
    else if(state == '发布') autidtitle = '执行变更';

    var candedit = false;
    if(curdutyer == _UserInfo.usercnname || curdutyer == _UserInfo.username) candedit = true;
    if(_UserInfo.username=='sys') cansave = true;
    if(state == '发布') candedit = true;

    var cansave = false;
    
    if((curdutyer == _UserInfo.usercnname || curdutyer == _UserInfo.username ) && state != '发布') cansave = true;
    if(_UserInfo.username=='sys') cansave = true;
    candedit =  cansave;
    
    return {"autidtitle":autidtitle, "candedit":candedit, "cansave":cansave};

	  },
	  execProc :function(procname, startSeq, taskid, metaprj, cfgdb, exedb) {////执行元数据对象-程序
			    if(!startSeq) startSeq = 1;
			    var _url = "../../Dsp?cmd=execStep&cmdtext=-f " + procname + " -t " + taskid + " -i " + startSeq;
			
			    if(cfgdb) _url += " -cfgdb " + cfgdb;
			    if(exedb) _url += " -exedb " + exedb;
			    if(metaprj) _url += " -prj " + metaprj;
			    alert(_url);
			    var str = Asiainfo.remoteData(_url, false);
			    alert(str);
	  },
      usePriority:function(level, objEl){
        var el = objEl||$('body');
        if(level===-1){
            console.log("-------------该用户赋权失败！-------------");
            return;
        }
        for(var i=10;i>level;i--){
            el.find(".lv-"+i).remove();
        }
      },
      usePriorityByRole:function(role, objEl){
        var lv=-1;
        if(!role) role="";
        role = role.indexOf('%')!=-1?decodeURI(role):role;
        if(role==='团队管理员'){
            lv = 2;
        }else if(role==='开发人员'){
            lv = 1;
        }else{
            console.log("-------------开启管理员权限！-------------");
        }
        this.usePriority(lv, objEl);
      }
	} 
}();

meta.init();

////工作流
AI.FlowDriverTbar= Event.$extend({
	actionContainId:"",
  __init__: function(options) {
    this.actionContainId = options.actionContainId;
    this.containEl=$("#"+this.actionContainId);
    this.init(options);
  },
  init:function(options){
  	// this.containEl.empty();
    this.buildBtnGroup(options);
  },
  getMenu:function(){
    return this.menuEl||this.containEl;
  },
	addButton:function(btncfg){
		var btn = $('<li><a id="'+btncfg.id+'" href="#">'+btncfg.text+'</a></li> ').appendTo(this.getMenu());
		if(btncfg.handler){
      btn.click(function(){
       btncfg.handler({id:$(this).find("a").id,text:$(this).find("a").text()}," ");
      });
    } 
	},
	addSeparator:function(){
		$('<li class="divider"></li>').appendTo(this.getMenu());
	},
  buildBtnGroup:function(options){
    this.containEl.empty().append('<div class="btn-group" style="'+options.style+'">'+
      '<button aria-expanded="false" type="button" class="btn dropdown-toggle" data-toggle="dropdown"> 流程操作 <span class="caret"></span>'+
      '</button>'+
      '<ul role="menu" class="dropdown-menu"></ul>'+
      '</div>');
    this.menuEl=this.containEl.find('ul');
  }
}); 

AI.FlowDriver= Event.$extend({
	modelcode:null,
	taskname:null,
	store:null,
	substore: null,
	tbar:null,
	showDefaultFun:true,
	
	 __init__: function(options) {
         this.init(options);
     },
     
    init:function(options){
     _self = this;

    this.modelcode = options.modelcode;
    this.taskname = '';
    this._store = options.store;
    this._substore = options.substore;
    this._rec = this._store.getAt(0)||{};
    this.tbar = new AI.FlowDriverTbar({actionContainId:options.actionContainId,style:options.style});//options.tbar;
    this.showDefaultFun = true;	
    if (this.showDefaultFun == false) this.showDefaultFun = false;

    var _sql = "select FLOWCODE,MASTERTABLE,MASTERTABLEKEY,MASTERTABLETITLE,SUBTABLE,NEWFORM,DEFAULTFORM from DEVWKFLOW where FLOWCODE ='" + this.modelcode + "'";
    var _t_select = new AI.JsonStore({
        sql: _sql,
        loadDataWhenInit: true
    });
    if (_t_select.getCount() == 0) {
        alert('工作流错误,没有配置:' + this.modelcode);
        return
    };
    this._keyfield = _t_select.getAt(0).get('MASTERTABLEKEY');
    this._titlefield = _t_select.getAt(0).get('MASTERTABLETITLE');

    this._flowcode =options.flowcode||this._rec.get(this._keyfield)||undefined;
    console.log(this._flowcode+","+this._keyfield);
    this.taskname = this._rec.get(this._titlefield);
    this.NEWFORM = _t_select.getAt(0).get('NEWFORM') ? _t_select.getAt(0).get('NEWFORM') : '';
    this.DEFAULTFORM = _t_select.getAt(0).get('DEFAULTFORM') ? _t_select.getAt(0).get('DEFAULTFORM') : '';
    console.log(this.DEFAULTFORM);
    this.MASTERTABLE = _t_select.getAt(0).get('MASTERTABLE');
    this.SUBTABLE = _t_select.getAt(0).get('SUBTABLE');
    var _sql = "select  ROLENAME, ROLEUSERNAME, ROLEFIELD,ROLEINDITYPE,TASKTO from DEVWKFLOW_ROLE where FLOWCODE ='" + this.modelcode + "'";
    var _t_select = new AI.JsonStore({
        sql: _sql,
        root: 'root',
        loadDataWhenInit: true
    });

    if (_t_select.getCount() == 0) alert('未知的需求模板:' + this.modelcode);
    for (var i = 0; i < _t_select.getCount(); i += 1) {
        var _r = _t_select.getAt(i);
        if (i == 0) {
            this._rolenames = _r.get('ROLENAME');
            this._roleusers = _r.get('ROLEUSERNAME');
            this._rolefields = _r.get('ROLEFIELD');
            this._roleIndiTypes = _r.get('ROLEINDITYPE');
            this.taskto = _r.get('TASKTO');
        } else {
            this._rolenames = this._rolenames + '#' + _r.get('ROLENAME');
            this._roleusers = this._roleusers + '#' + _r.get('ROLEUSERNAME');
            this._rolefields = this._rolefields + '#' + _r.get('ROLEFIELD');
            this._roleIndiTypes = this._roleIndiTypes + '#' + _r.get('ROLEINDITYPE');
            this.taskto += "#" + _r.get('TASKTO');
        }
    };
},
 Dealrule : function(instr) {
    var outstr = instr;
    for (var i = 0; i < this._store.columnModel.config.length; i += 1) {
        outstr = outstr.replace('{' + this._store.columnModel.config[i].dataIndex + '}', this._rec.get(this._store.columnModel.config[i].dataIndex));
    };
    outstr = outstr.replace('IsFromIT', CheckUserIsITService(_UserInfo.usercnname) + ' ');
    return outstr;
},
CheckReqForm : function(ActName, ActType) { ///审批操作提交前处理
    return true;
},
 CheckReqFormAft : function(ActName, ActType, AuditInfo) { ///审批操作提交后处理
    return true;
},
 reload : function() { //重新加载页面

    if (_self.NEWFORM == '' && _self.DEFAULTFORM == '') { //在需求管理中新建时没有绑定工作流，考虑外部用户的链接
        var url = window.location + "";
        if (url.indexOf(this._keyfield) == -1 && url.indexOf('&') == -1)
            window.location = url + '?' + this._keyfield + '=' + this._flowcode
        else window.location = window.location;
    } else if (_self._rec.get('STATE') == '新建')
        window.location = '../devmgr/' + _self.NEWFORM + '?OBJNAME='+_self._rec.get('XMLID')+'&USERTYPE=' + _UserInfo.USERTYPE + '&USERNAME=' + _UserInfo.username + '&USERCNNAME=' + _UserInfo.usercnname + '&REQCODE=' + _self._flowcode
    else
        window.location = '../devmgr/' + _self.DEFAULTFORM + '?OBJNAME='+_self._rec.get('XMLID')+'&USERTYPE=' + _UserInfo.USERTYPE + '&USERNAME=' + _UserInfo.username + '&USERCNNAME=' + _UserInfo.usercnname + '&REQCODE=' + _self._flowcode;
},

ShowAuditAct : function(ActName) {
    if (!_self.CheckReqForm(ActName)) return; ///调用检查表单

    var hasWhere = false,
        onceNoWhere = false,
        proceType = '普通'; //条件;并行
    var tmpsql = "select a.FLOWCODE,ACTNAME,ACTOWNER,PROMPT,a.STATENAME,a.AFTSTATENAME,b.DUTYER as aftdutyer " +
        "from DEVWKFLOW_ACT a,DEVWKFLOW_STATE b where a.flowcode = '" + this.modelcode + "' and a.flowcode=b.flowcode " +
        "and a.aftstate=b.STATE and a.statename='" + this._rec.get('STATE') + "' and a.actname='" + ActName + "'";
    
    var ds_tmp = new AI.JsonStore({
        sql: tmpsql,
        initUrl: '/' + contextPath + '/newrecordService',
        url: '/' + contextPath + '/newrecordService',
        root: 'root',
        loadDataWhenInit: true
    });
    var fitRowIndex = 0;
    for (var i = 0; i < ds_tmp.getCount(); i++) {
        var r = ds_tmp.getAt(i);
        if (r.get('PROMPT')) {
            hasWhere = true;
            var rule = this.Dealrule(r.get('PROMPT'));
            var bResult = eval(rule);
            if (bResult) fitRowIndex = i;
        } else onceNoWhere = true;
    };
    if (ds_tmp.getCount() == 1) proceType = '普通'
    else if (hasWhere && !onceNoWhere) proceType = '条件'
    else if (!hasWhere) proceType = '并行';
    else proceType = 'unkown';
    if (proceType == '并行' || proceType == 'unkown') {
        alert('错误,不支持:' + proceType);
        return
    };
    var r = ds_tmp.getAt(fitRowIndex);
    var aftdutyerRole = r.get('AFTDUTYER');
    var aftDutyerName = '',
        vfield = 'ID',
        dfield = 'VALUE';
    var ds_fd_aftDutyer;
    var rolefield = '';
    
    ///节点指定了特殊负责人
    var aftDutyerStr =""; 
    if (aftdutyerRole == '上一节点负责人') {
        aftDutyerName = _self._rec.get('CURDUTYER');
        aftDutyerStr =aftDutyerName;
        
    } else if (aftdutyerRole == '上一负责人指定') {
        aftDutyerStr ="select username from metauser";
        
    } else { ///节点指定了流程角色的
        var rolenames = _self._rolenames.split('#');
        var roleusers = _self._roleusers.split('#');
        var rolefields = _self._rolefields.split('#');
        var roleIndiTypes = _self._roleIndiTypes.split('#');
        var i = rolenames.indexOf(aftdutyerRole);

        if (i == -1) {
            alert('错误,没有流程角色:' + aftdutyerRole);
            return;
        };
        rolefield = rolefields[i];

        if (rolefields[i]) { ///有跟表单字段绑定的
            aftDutyerName = _self._rec.get(rolefields[i]);
            aftDutyerStr = aftDutyerName;
        };
        if (roleIndiTypes[i] == '常量') {
            aftDutyerName = roleusers[i];
            if (rolefields[i] && _self._rec.get(rolefields[i]))  aftDutyerStr=_self._rec.get(rolefields[i])+","+_self._rec.get(rolefields[i]);
             
            else
               aftDutyerStr = aftDutyerName;

        } else { ///条件选择  运行时指定,选择变量,条件变量
            //aftDutyerName=roleusers[i];
            if (roleusers[i] && roleusers[i].indexOf('select') != -1) { ///sql语句选择
                var _tmpsql = _self.Dealrule(roleusers[i]);
                 aftDutyerStr = _tmpsql;
            } else if (roleusers[i]) {
                var canSelusers = roleusers[i].split(',');
                var selUser = [];
                for (var i = 0; i < canSelusers.length; i++)
                    selUser.push(canSelusers[i]);
                aftDutyerStr=selUser.join(",");
            }
        }
    };

    function onOKSave(fieldVals) {
    	 console.log(fieldVals)
        var AuditInfo = {};
        AuditInfo.roleField = rolefield;
        AuditInfo.aftState = fieldVals.aftstate;
        AuditInfo.aftDutyer = fieldVals.aftdutyer;
        AuditInfo.advice = fieldVals.advice||"";
        if ((AuditInfo.aftState == '不通过' || AuditInfo.aftState == '拒绝') && !AuditInfo.advice) {
            alert('请填写原因!');
            return false;
        }
        if (!AuditInfo.aftDutyer) {
            alert('请先指定下一环节负责人');
            return false;
        };
        AuditInfo.ActName = ActName;
        AuditInfo.aftdutyerRole = r.get('AFTDUTYER');
        if (!_self.CheckReqFormAft('Audit', ActName, AuditInfo)) return false;
       
        _self.AuditActProcess(AuditInfo);
        return true;
    };
    var strInfo = '当前状态:<b><font color=red>' + this._rec.get('STATE') + '</font></b>,您的操作:<b><font color=red>' + ActName + '</font></b></h5>';
   var  items=[ {type:'html',label:'<h5>提示:',fieldName:'remark', width:420,html:strInfo},
                    {type:'text',label:'<b>下一环节</b>', fieldName:'aftstate',value:r.get('AFTSTATENAME'),width:220,isReadOnly:"y"},
                    {type:'combox',label:'<b>负责人</b>('+aftdutyerRole+')',fieldName:'aftdutyer',storesql:aftDutyerStr,width:220 },
                    {type:'textarea',label:'<b>您的建议</b>',fieldName:'advice', width:320}
            
                  ];
    ai.openFormDialog('节点操作',items,onOKSave);
    return;
 
},
AuditAct : function(button, e) {
    _self._store.commit(false);
    _self.ShowAuditAct(button.text);
},
AuditActProcess : function(AuditInfo) {
    this.taskname = this._rec.get(this._titlefield);
    if (_self._rec.get('STATE') == '新建') _self.AddFlowLog(_UserInfo.usercnname, '新建', '新建', '新建');
    ///是否存在代理人设置 

    var agent = _self.getAgent(AuditInfo.aftdutyerRole);


    var curState = _self._rec.get('STATE');
    _self._rec.set('STATE', AuditInfo.aftState);
    
    _self._rec.set('STATE_DATE', new Date());
    _self._rec.set('CURDUTYER', agent ? agent : AuditInfo.aftDutyer);
    if (agent) {
        _self._rec.set('CURAGENT', AuditInfo.aftDutyer);
    }
    if (AuditInfo.roleField) {
        _self._rec.set(AuditInfo.roleField, agent ? agent : AuditInfo.aftDutyer);
        _self._rec.set('CURAGENT', AuditInfo.aftDutyer);
    }
    _self._store.commit(false);

    ///记录日志
    _self.AddFlowLog(_UserInfo.usercnname, AuditInfo.ActName, curState, AuditInfo.aftState, AuditInfo.advice);
    ///如果有代理，给被代理者发短信
    if (agent) {
        //alert('即将发短信人：'+AuditInfo.aftDutyer);
        _self.SendSmsByUserName(AuditInfo.aftDutyer, this.taskname + ',当前状态:' + AuditInfo.aftState + ',已经提交给您的代理人:' + agent + '处理,请关注!');
    }
    ///发送短信给下一环节的人
    _self.SendSmsByUserName(AuditInfo.aftDutyer, this.taskname + ',当前状态:' + AuditInfo.aftState + ',负责人:' + (agent == '' ? agent : AuditInfo.aftDutyer) + ',请关注!');
    ///发送短信给需求登记人

    if (_self._rec.get('CREATER') != AuditInfo.aftDutyer)
        _self.SendSmsByUserName(_self._rec.get('CREATER'), '您登记的:' + this.taskname + ',当前状态:' + AuditInfo.aftState + ',负责人:' + AuditInfo.aftDutyer + ',请关注!');
    ///发送短信给需求负责人
    if (!agent)
        alert('提交到下一环节:' + AuditInfo.aftState + '\n下一环节处理人:' + AuditInfo.aftdutyerRole + '(' + AuditInfo.aftDutyer + ')')
    else
        alert('提交到下一环节:' + AuditInfo.aftState + '\n下一环节处理人:' + AuditInfo.aftdutyerRole + '(' + agent + '[代:' + AuditInfo.aftDutyer + '])')
    _self.reload();
},
getAgent : function(dutyerRole) { ///检查是否有代理设置
    var agent = '';
    var roleNames = this._rolenames.split('#');
    var roleAgents = this.taskto.split('#');
    var roleIndex = roleNames.indexOf(dutyerRole);
    if (roleIndex != -1) agent = roleAgents[roleIndex];
    return agent;
},
FuncsAct : function(button, e) { //功能操作

    if (_self.CheckReqForm) _self.CheckReqForm(button.text, 'FUNACT');
},

SetStateInfo : function(addFunList) {
    var state = this._rec.get('STATE');
    var _sql = "select a.FLOWCODE, a.STATE, a.ACTNAME, a.ACTOWNER, a.AFTSTATE, b.FUNC,b.DUTYER, a.PROMPT, a.SUBSTATE, a.AFTERSUBSTATE, a.ACT, a.STATENAME, a.AFTSTATENAME from DEVWKFLOW_ACT a,DEVWKFLOW_STATE b  " +
        "where a.flowcode=b.flowcode and a.STATENAME=b.STATENAME and a.flowcode='" + this.modelcode + "' and a.STATENAME='" + state + "'";
    
    var _t_select = new AI.JsonStore({
        sql: _sql,
        initUrl: '/' + contextPath + '/newrecordService',
        url: '/' + contextPath + '/newrecordService',
        root: 'root',
        loadDataWhenInit: true
    });

    ///功能操作
    if (this.showDefaultFun) {
        var btn_save = ({
            text: '保存',
            cls: 'x-btn-text-icon',
            icon: '/' + contextPath + '/public/images/save.gif',
            disabled: (_self._store.getAt(0).get('CURDUTYER') == _UserInfo.usercnname) ? false : true,
            handler: function(button, event) {
                if (!_self.CheckReqForm()) return;
                _self._store.commit();
                if (_self._substore) _self._substore.commit();
            }
        });
        this.tbar.addButton(btn_save);
        var btnRefresh = ({
            text: '刷新',
            id: 'Refresh',
            cls: 'x-btn-text-icon',
            icon: '/' + contextPath + '/sysmgr/asiainfo/images/datasyn.gif',
            handler: function() {

                history.go(0);
            }
        });
        this.tbar.addButton(btnRefresh);
        var btn_log =  ({
            text: '查看日志',
            id: 'VIEWLOG',
            cls: 'x-btn-text-icon',
            icon: '/' + contextPath + '/public/images/yonghu.gif',
            handler: function(){
             window.open('/'+contextPath+ '/sysmgr/asiainfo/ProcGraph/workflowlog.html?FLOWCODE=' + _self.modelcode + '&REQCODE=' + _self._flowcode);
            }
        });
        this.tbar.addButton(btn_log);
        this.tbar.addSeparator();
        var btn_rolbak =({
            text: '回退',
            id: 'rolbak',
            tooltip: '可使用的人:sys 或者流程管理员',
            disabled: (_UserInfo.username == 'sys' || _UserInfo.usercnname == '张韬') ? false : true,
            cls: 'x-btn-text-icon',
            icon: '/' + contextPath + '/sysmgr/asiainfo/ext/examples/shared/icons/fam/application_go.png',
            handler: function() {
                var ds_hisState = new AI.JsonStore({
                    sql: "select distinct USERNAME,STATE||'('||USERNAME||')' VSTATE,STATE from DEVLOG where FLOWCODE='" + _self._flowcode + "'",
                    root: 'root',
                    loadDataWhenInit: true
                });
                var fd_hisState = new Ext.form.ComboBox({
                    fieldLabel: '历史状态',
                    name: '',
                    width: 100,
                    height: 21,

                    mode: 'remote',
                    disabled: false,
                    allowDomMove: false,
                    editable: true,
                    triggerAction: 'all',
                    store: ds_hisState,
                    valueField: 'STATE',
                    displayField: 'VSTATE',
                    allowBlank: false
                });
                var win = new Ext.Window({
                    title: "选择历史状态",
                    width: 300,
                    height: 200,
                    minWidth: 200,
                    minHeight: 200,
                    layout: 'fit',
                    plain: true,
                    modal: true,
                    bodyStyle: 'padding:1px;',
                    buttonAlign: 'center',
                    items: [fd_hisState],
                    buttons: [{
                        text: "确定",
                        handler: onOKSave,
                        scope: this
                    }, {
                        text: "退出",
                        handler: closeWin,
                        scope: this
                    }]
                });

                function onOKSave() {
                    if (_self._rec.get('STATE') == fd_hisState.getValue()) {
                        alert('您选择的回退状态跟当前状态一样,请重新选择');
                        return
                    };
                    _self.AddFlowLog(_UserInfo.usercnname, '回退', _self._rec.get('STATE'), fd_hisState.getValue(), tb_advice.getValue());
                    _self._rec.set('STATE', fd_hisState.getValue());
                    for (var i = 0; i < ds_hisState.getCount(); i++) {
                        if (ds_hisState.getAt(i).get('STATE') == fd_hisState.getValue())
                            _self._rec.set('CURDUTYER', ds_hisState.getAt(i).get('USERNAME'));
                    }
                    _self.SendSmsByUserName(_self._rec.get('CURDUTYER'), '需求:' + _self._rec.get('REQNAME') + ',状态回退到:' + fd_hisState.getValue() + ',由您负责,请关注!');
                    _self._store.commit();
                    _self.reload();
                };

                function closeWin() {
                    if (win) win.hide();
                };
                win.show();
            }
        });
        this.tbar.addButton(btn_rolbak);
    };

    ///工作流程中配置的操作
    var _r = _t_select.getAt(0);
    if (_r) {
        var funnum = 0;
        var bAddtion = false;
        if ( _UserInfo.username =='sys' || this._rec.get('CURDUTYER') == _UserInfo.usercnname || this._rec.get('CURDUTYER') == _UserInfo.username) bAddtion = true; //如果是当前负责人
        var agent = this.getAgent(_r.get('DUTYER'));
        if (agent == _UserInfo.usercnname || agent == _UserInfo.username) bAddtion = true;

        if (_r.get('FUNC')) {
            this.tbar.addSeparator();
            var _funcs = _r.get('FUNC').split(',');
            funnum = _funcs.length;
        };
        if (this._rec.get('CURDUTYER') == _UserInfo.usercnname) bAddtion = true;
        for (var i = 0; i < funnum; i += 1) {
            var btn =  ({
                text: _funcs[i],
                id: _funcs[i],
                cls: 'x-btn-text-icon',
                tooltip: '可使用的人:' + (_r.get('ACTOWNER') ? _r.get('ACTOWNER') : '当前负责人') + '(' + this._rec.get('CURDUTYER') + ')',
                disabled: !bAddtion,
                icon: '/' + contextPath + '/images/icon_manage.gif',
                handler: this.FuncsAct
            });
            this.tbar.addButton(btn);
        };
    };
    //审批操作
    this.tbar.addSeparator();
    var actStr = '';
    for (var i = 0; i < _t_select.getCount(); i += 1) { //对某个操作有操作权限条件:当前节点的负责人,如果连续操作有指定了负责人呢，则采用连续的负责人
        var _r = _t_select.getAt(i);
        if (actStr.indexOf('&&&' + _r.get('ACTNAME') + '&&&') != -1) continue;
        actStr += '&&&' + _r.get('ACTNAME') + '&&&';

        var tooltip = '可使用的人:' + (_r.get('ACTOWNER') ? _r.get('ACTOWNER') : '当前负责人') + '(' + this._rec.get('CURDUTYER') + ')';
        var bAddtion = false;

        if (this._rec.get('CURDUTYER') == _UserInfo.usercnname || this._rec.get('CURDUTYER') == _UserInfo.username) { //如果是当前负责人
            bAddtion = true;
        };

        var agent = this.getAgent(_r.get('DUTYER'));
        if (agent) tooltip += ',及其代理人(' + agent + ')';

        if (agent == _UserInfo.usercnname || agent == _UserInfo.username) bAddtion = true;
        if (_r.get('ACTOWNER') && _r.get('ACTOWNER').toUpperCase() == 'ALL') {
            bAddtion = true;
            tooltip = '允许所有人操作'
        };


        if (_r.get('ACTNAME') == '确认工作量' || _r.get('ACTNAME') == '系统部评估' || _r.get('ACTNAME') == '需求发起人评估' || _r.get('ACTNAME') == '提交评估' || _r.get('ACTNAME') == '评估确定' || _r.get('ACTNAME') == '确认考核' || _r.get('ACTNAME') == '确认完成') bAddtion = false;
        var btn = ({
            text: _r.get('ACTNAME'),
            disabled: !bAddtion,
            id: _r.get('ACT'),
            tooltip: tooltip,
            cls: 'x-btn-text-icon',
            icon: '/' + contextPath + '/public/images/query.gif',
            handler: this.AuditAct
        });
        this.tbar.addButton(btn);
    }
},
AddFlowLog : function(username, actname, curstate, aftstate, remark) {
    var ds_flowlog = new AI.JsonStore({
        table: 'DEVLOG',
        root: 'root',
        sql: "select FLOWCODE, USERNAME, ACTNAME, STATE, AFTSTATE,ADVICE from DEVLOG where 1>2",
        initUrl: '/' + contextPath + '/newrecordService',
        url: '/' + contextPath + '/newrecordService',
        key: 'FLOWCODE',
        loadDataWhenInit: true
    });
    var _t_rec = ds_flowlog.getNewRecord();
    _t_rec.set('FLOWCODE', this._rec.get(this._keyfield)); ///wqs
    _t_rec.set('USERNAME', username);
    _t_rec.set('ACTNAME', actname);
    _t_rec.set('STATE', curstate);
    _t_rec.set('AFTSTATE', aftstate);
    _t_rec.set('ADVICE', remark);

    ds_flowlog.add(_t_rec);
    ds_flowlog.commit(false);
},
SendSmsByUserName : function(username, msg) {
  console.log("SendSmsByname:"+username+","+ msg);
  //  SendSmsByname(username, msg);

}
});





 
 
