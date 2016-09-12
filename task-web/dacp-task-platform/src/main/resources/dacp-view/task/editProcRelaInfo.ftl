<!DOCTYPE html>
<html lang="en" class="app">
	<head>
	<meta charset="utf-8" /> 
	<title>DACP数据云图</title>   
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"  />  
		<link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet" media="screen"/>
		<link href="${mvcPath}/dacp-lib/bootstrap-table/bootstrap-table.min.css" type="text/css" rel="stylesheet" media="screen"/>
		<script type="text/javascript" src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js"></script>
		<script type="text/javascript" src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>
		<script type="text/javascript" src="${mvcPath}/dacp-lib/bootstrap-table/bootstrap-table.min.js"></script>
		<script src="${mvcPath}/dacp-lib/underscore/underscore.js" type="text/javascript"></script>
		<script src="${mvcPath}/dacp-lib/backbone/backbone.js" type="text/javascript"></script>
		<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
		<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>
		<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
		<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
		<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
		<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>
		<script src="${mvcPath}/dacp-lib/bootstrap-jquery-plugin/src/jquery.datagrid.js"></script>
	</head>
<style type="text/css">
    .myInput{
    	display: block;
    	border-style:none;
    	height:30px;
    	background-color:#fff;
    	font-size:11px;
    }
    .settings {
        background-color: #fff;
        border: 1px solid #ddd;
        border-radius: 4px 4px 4px 4px;
        padding: 20px 10px 0px 10px;
        margin-top: 8px;
        position: relative;
    }
    
    .settings:before{
        background-color: #fcfcfc;
        border-right: 1px solid #ddd;
        border-bottom: 1px solid #ddd;
        color: #9DA0A4;
        font-weight: bold;
        font-size: 12px;
        border-radius:0 0px 4px 0;
        position: absolute;
        top: 0;
        left: 0;
        padding: 3px 7px;
    }
    .settings.dependTable:before{
        content: "输入表";
    }

    .settings.dependProc:before{
        content: "前置程序";
    }

    .settings.outputTable:before{
        content: "输出表";
    }
</style>
    
<script>
var transName= paramMap['xmlid'];
var runFreq='${proc.cycletype!""}';//从proc表中获取
var delRow = -1;

function delTableRow(obj){
	if(confirm("确定要删除吗？")){
		var $table = $(obj).parent().parent().parent().parent();
		var xmlid = $(obj).attr("xmlid");
		$table.datagrid().find("tr td").find("input[id='xmlid'][value='"+xmlid+"']").parent().parent().remove();
	}
}

function getDelBtn(xmlid){
	var delbtn = '<button type="button" class="btn btn-danger btn-xs" name="modal new delete" xmlid="'+xmlid+'" onclick="delTableRow(this)"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span></button>';	
	return delbtn;
}
function attrReadOnlyRender(group,runFreq,selval) {
	var _ops= [['D','天'],['M','月'],['Y','年'],['ML','月末'],['H','小时'],['MI','分钟'],['N','无']];
	var _input_y= [['Y','年']['M','月'],['N','无']];
	var _input_m= [['M','月'],['ML','月末'],['N','无']];
	var _input_d = [['D','天'],['M','月'],['ML','月末'],['DL','23点'],['N','无']];
	var _input_h= [['H','小时'],['N','无']];
	var _input_mi= [['MI','分钟'],['N','无']];
	var _output_y= [['Y','年']];
	var _output_m= [['M','月']];
	var _output_d = [['D','天']];
	var _output_h = [['H','小时']];
	var _output_mi = [['MI','分钟']];
	if(group=="1.输入表"){
		if(runFreq=="year") _ops = _input_y;
		else if(runFreq=="month")_ops = _input_m;
		else if(runFreq=="day")_ops = _input_d;
		else if(runFreq=="hour")_ops = _input_h;
		else if(runFreq=="minute")_ops = _input_mi;
		else _ops = _ops;
	}
	else if(group=="2.输出表"){
		if(runFreq=="year") _ops = _output_y;
		else if(runFreq=="month")_ops = _output_m;
		else if(runFreq=="day")_ops = _output_d;
		else if(runFreq=="hour")_ops = _output_h;
		else if(runFreq=="minute")_ops = _output_mi;
		else _ops = _ops;
	}
	else if (group=="3.依赖程序"){
		if(runFreq=="year") _ops = _input_y;
		else if(runFreq=="month")_ops = _input_m;
		else if(runFreq=="day")_ops = _input_d;
		else if(runFreq=="hour")_ops = _input_h;
		else if(runFreq=="minute")_ops = _input_mi;
		else _ops = _ops;
	}
	var _rs = '';
	_rs+='<select id="freq" name="freq" style="width:80px;height:30px;background-color: #fff;" class="form-control">';
	
	for(var i=0;i<_ops.length;i++){
		 var isChecked="";
		 if(_ops[i][0]==selval) isChecked='selected=true'; 
    		_rs += ('<option value="'+_ops[i][0]+'" '+isChecked+'>'+_ops[i][1]+'</option>');
    }
	_rs+='</select>';
	return _rs;
};

function initTable(tableList,type){
	var myList=[];
	$.each(tableList, function (i, item){
		 var para = item.freq.split("-");
		 para[1] = para[1]||"";
		 console.log(para);
		 var freq=attrReadOnlyRender("1.输入表",runFreq,para[0]);
		 var row;
		 if(type=="DATA"){
			 row={
				  xmlid:  '<input id="xmlid" class="form-control myInput" value="'+item.xmlid+'" type="hidden" />'
				 ,tableName: '<input id="tableName" class="form-control myInput" value="'+item.dataname+'" disabled>'
				 ,tableCnName: '<input id="tableCnName" class="form-control myInput" value="'+item.datacnname+'" disabled>'
				 ,dbName: '<input id="dbName" class="form-control myInput" value="'+item.dbname+'" disabled>'
				 ,freq:   freq
				 ,run_freq_offset:'<input id="run_freq_offset" style="display: block;width:50px;height:30px;background-color: #fff;" class="form-control" value="'+para[1]+'">'
				 ,delbtn: getDelBtn(item.xmlid)
		        };
		 }else{
			 row={
					  xmlid:  '<input id="xmlid" class="form-control myInput" value="'+item.xmlid+'"  type="hidden" />'
					 ,proc_name: '<input id="proc_name" class="form-control myInput" value="'+item.proc_name+'" disabled>'
					 ,proccnname: '<input id="proccnname" class="form-control myInput" value="'+item.proccnname+'" disabled>'
					 ,freq:   freq
					 ,run_freq_offset:'<input id="run_freq_offset" style="display: block;width:50px;height:30px;background-color: #fff;" class="form-control" value="'+para[1]+'">'
					 ,delbtn: getDelBtn(item.xmlid)
			        };			 
		 }
		 myList.push(row);
		console.log(item.xmlid);
	});
	return myList;
};
$(function() {
    var $table = $('#dependTable');
    var dependTableList=${dependTableList};
    var initProcParamsArray=initTable(dependTableList,"DATA");
    $table.empty().datagrid({
      columns:[[
          {title: "", field: "xmlid"},
          {title: "表名", field: "tableName"},
          {title: "中文名", field: "tableCnName"},
          {title: "数据库", field: "dbName"},
          {title: "周期", field: "freq"},
          {title: "依赖周期", field: "run_freq_offset"},
          {title: "操作", field: "delbtn"}
        //{title: "触发标识", field: "run_freq_offset"}
      ]]
        , singleSelect:  true //false allow multi select
        , selectedClass: 'danger' //default: 'success'
        , selectChange: function(selected, rowIndex, rowData, $row) {
            //allow multi-select
            console.log(selected, rowIndex, rowData, $row);
            delRow=rowIndex;
          }
    }).datagrid("loadData", {rows: initProcParamsArray});
    
    var $table = $('#dependProc');
    var initProcParamsArray=[];
    var dependProcList=${dependProcList};
    var initProcParamsArray=initTable(dependProcList,"PROC");
    $table.empty().datagrid({
      columns:[[
		  {title: "", field: "xmlid"},
          {title: "程序名", field: "proc_name"},
          {title: "中文名", field: "proccnname"},
          {title: "周期", field: "freq"},
          {title: "依赖周期", field: "run_freq_offset"},
          //{title: "触发标识", field: "triggerflag"} ,
          {title: "操作", field: "delbtn"}
      ]]
        , singleSelect:  true //false allow multi select
        , selectedClass: 'danger' //default: 'success'
        , selectChange: function(selected, rowIndex, rowData, $row) {
            //allow multi-select
            console.log(selected, rowIndex, rowData, $row);
            delRow=rowIndex;
          }
    }).datagrid("loadData", {rows: initProcParamsArray});
    
    
    var $table = $('#outputTable');
    var initProcParamsArray=[];
    var outTableList=${outTableList};
    var initProcParamsArray=initTable(outTableList,"DATA");    
    $table.empty().datagrid({
      columns:[[
          {title: "", field: "xmlid"},
          {title: "表名", field: "tableName"},
          {title: "中文名", field: "tableCnName"},
          {title: "数据库", field: "dbName"},
          {title: "周期", field: "freq"},
          {title: "依赖周期", field: "run_freq_offset"},
          {title: "操作", field: "delbtn"}
      ]]
        , singleSelect:  true //false allow multi select
        , selectedClass: 'danger' //default: 'success'
        , selectChange: function(selected, rowIndex, rowData, $row) {
            //allow multi-select
            console.log(selected, rowIndex, rowData, $row);
            delRow=rowIndex;
          }
    }).datagrid("loadData", {rows: initProcParamsArray});

    $('#editDependTable').bind("click",
    	function(){
    		function afterSelect(rs){
    			$("#dependTable tbody").empty();
    			for(var i=0;i<rs.length;i++){
    			 	var r=rs[i];
    			 	InsertTableRows('dependTable',r.get('KEYFIELD'),r.get('VALUES1'),r.get('VALUES2'),r.get('VALUES3'),"1.输入表","DATA");
    			};
    		};
            var input_data_sql = ""+
            " SELECT DISTINCT a.XMLID AS KEYFIELD,a.DATANAME AS VALUES1,a.DATACNNAME AS VALUES2,a.DBNAME AS VALUES3 FROM tablefile a ";
            selSql =  input_data_sql.replace("{}",transName);
            var selectValue = "";
            $.each($("#dependTable").find("input#xmlid"),function(i,item){
            	selectValue+=item.value+",";
           	})
           	if(selectValue.length>0)selectValue=selectValue.substr(0,selectValue.length-1);
    	    var selBox = new SelectBox({sql: selSql,selectedValue: selectValue,callback: afterSelect});
    	    selBox.show();
    	    $("#selectgrid .sortable:lt(2)").prop("width","200px"); 
    	    $("#resultgrid .sortable:lt(2)").prop("width","200px");
    	}
    );
    
    $('#editDependProc').bind("click",
        	function(){
        		function afterSelect(rs){
        			$("#dependProc tbody").empty();
        			for(var i=0;i<rs.length;i++){
        			 	var r=rs[i];
        			 	InsertTableRows('dependProc',r.get('KEYFIELD'),r.get('VALUES1'),r.get('VALUES2'),"","3.依赖程序","PROC");
        			};
        		};
        	 	
                var proc_sql=""+
                " SELECT DISTINCT a.xmlid AS KEYFIELD,b.proc_name AS VALUES1,b.proccnname AS VALUES2"+
                " FROM proc_schedule_info a "+
                " INNER JOIN proc b ON a.xmlid=b.xmlid";
                selSql =  proc_sql.replace(/{}/g,transName);
                var selectValue = "";
                $.each($("#dependProc").find("input#xmlid"),function(i,item){
                	selectValue+=item.value+",";
               	})
               	if(selectValue.length>0)selectValue=selectValue.substr(0,selectValue.length-1);
        	    var selBox=new SelectBox({sql: selSql,selectedValue: selectValue,callback: afterSelect});
        	    selBox.show();
        	    $("#selectgrid .sortable:lt(2)").prop("width","200px");
        	    $("#resultgrid .sortable:lt(2)").prop("width","200px");
        	}
        );
    
    $('#editOutputTable').bind("click",
        	function(){
        		function afterSelect(rs){
        			$("#outputTable tbody").empty();
        			for(var i=0;i<rs.length;i++){
        			 	var r=rs[i];
        			 	InsertTableRows('outputTable',r.get('KEYFIELD'),r.get('VALUES1'),r.get('VALUES2'),r.get('VALUES3'),"2.输出表","DATA");
        			};
        		};
                var output_data_sql = ""+
                " SELECT DISTINCT a.XMLID AS KEYFIELD,a.DATANAME AS VALUES1,a.DATACNNAME AS VALUES2,a.DBNAME AS VALUES3  FROM tablefile a ";
                selSql =  output_data_sql.replace(/{}/g,transName);
                var selectValue = "";
                $.each($("#outputTable").find("input#xmlid"),function(i,item){
                	selectValue+=item.value+",";
               	})
               	if(selectValue.length>0)selectValue=selectValue.substr(0,selectValue.length-1);
        	    var selBox=new SelectBox({sql: selSql,selectedValue: selectValue,callback: afterSelect});
        	    selBox.show();
        	    $("#selectgrid .sortable:lt(2)").prop("width","200px");
        	    $("#resultgrid .sortable:lt(2)").prop("width","200px");
        	}
        );
    function collectVal(paraTrList){
    	var tmprows=[];
        var paraTrList=$(paraTrList).find("tr");
 		for(var i=1 ;i<paraTrList.length;i++){
 			var row={};
	    	var input = $(paraTrList[i]).find("input[type!=radio], select, textarea, input[type='radio']:checked");
			input.each(function(i, item){
				row[$(item).attr("id")] = $(item).val();		 	
			});
			tmprows.push(row);
 		}
 		return tmprows;
    }
    $('#saveRela').bind("click",
        	function(){
        var ralaParams=new Array();

        var tmprows=collectVal('#dependTable');
        if(runFreq == null || runFreq.length == 0){
        	alert("未设置程序信息运行周期")
        	return false;
        }
        var freq = runFreq.substr(0,1).toUpperCase() + "-0";
        
        $.each(tmprows,function(i, tmprow){
 			 var rows={};
 			 rows["xmlid"]=ai.guid();
  			 rows["transname"]=transName;
  			 rows["source"]=tmprow["xmlid"];
  			 rows["sourcetype"]="DATA";
  			 if(tmprow["freq"]=='N'){
  				 rows["sourcefreq"]=tmprow["freq"]
  			 }else{
  				 rows["sourcefreq"]=tmprow["freq"]+'-'+(tmprow["run_freq_offset"]==""?'0':tmprow["run_freq_offset"]);
  			 }
  			
  			 rows["target"]=transName;
  			 rows["targettype"]='PROC';
  			 rows["targetfreq"] = freq;//'D-0';//此处需要从proc_schedual_info取
  			 ralaParams.push(rows);
        });
        
        tmprows=collectVal('#outputTable');
        $.each(tmprows,function(i, tmprow){
 			 var rows={};
 			 rows["xmlid"]=ai.guid();
  			 rows["transname"]=transName;
  			 rows["source"]=transName;
  			 rows["sourcetype"]="PROC";
  			 rows["sourcefreq"] = freq;//'D-0';//此处需要从proc_schedual_info取
  			 
  			 rows["target"]=tmprow["xmlid"];
  			 rows["targettype"]='DATA';
  			 if(tmprow["freq"]=='N'){
  				 rows["targetfreq"]=tmprow["freq"]
  			 }else{
  				 rows["targetfreq"]=tmprow["freq"]+'-'+(tmprow["run_freq_offset"]==""?'0':tmprow["run_freq_offset"]);
  			 }
  			 ralaParams.push(rows);
        });

        tmprows=collectVal('#dependProc');
        $.each(tmprows,function(i, tmprow){
 			 var rows={};
 			 rows["xmlid"]=ai.guid();
  			 rows["transname"]=transName;
  			 rows["source"]=tmprow["xmlid"];
  			 rows["sourcetype"]="PROC";
  			 if(tmprow["freq"]=='N'){
  				 rows["sourcefreq"]=tmprow["freq"]
  			 }else{
  				 rows["sourcefreq"]=tmprow["freq"]+'-'+(tmprow["run_freq_offset"]==""?'0':tmprow["run_freq_offset"]);
  			 }
  			
  			 rows["target"]=transName;
  			 rows["targettype"]='PROC';
  			 rows["targetfreq"]=freq;//'D-0';//此处需要从proc_schedual_info取
  			 ralaParams.push(rows);
        });
        var Params={};
        Params["transname"]=transName;
        Params["procrala"]=ralaParams;
        var procModel = Backbone.Model.extend({
            url:"${mvcPath}/task/saveProcRela"
        });
        var model = new procModel(Params);

        model.save({}, {
            type: "POST",
            success: function (response) {
            	alert('调度关系保存成功');
				var xmlid=paramMap["xmlid"]||"";
				if(xmlid.length>0){
					//修改开发库proc和metaobj状态
					ai.executeSQL("update proc set state = 'CHANGE' where xmlid='"+xmlid+"'",false,"METADB");
					ai.executeSQL("update metaobj set state = 'CHANGE' where xmlid='"+xmlid+"'",false,"METADB");
				}
            },
	        error: function (response) {
	        	alert('调度关系保存失败');
	        }
        });
        
    });
    

    
});

function InsertTableRows(tableId,xmlid,name,cnname,dbname,group,type){
	 var freq=attrReadOnlyRender(group,runFreq);
	 var $table = $('#'+tableId);
	 var row;
	 if(type=="DATA"){
	   row={  
		  xmlid:  '<input id="xmlid" class="form-control myInput" value="'+xmlid+'" type="hidden" />',
		  tableName: '<input id="tableName" class="form-control myInput" value="'+name+'" disabled>',
		  tableCnName: '<input id="tableCnName" class="form-control myInput" value="'+cnname+'" disabled>',
		  dbName: '<input id="dbName" class="form-control myInput" value="'+dbname+'" disabled>',
		  freq:   freq,
		  run_freq_offset:'<input id="run_freq_offset" style="display: block;width:50px;height:30px;background-color: #fff;" class="form-control" value="'+0+'">',
		  delbtn: getDelBtn(xmlid)
		 };
	 }else{

	   row={
			  xmlid:  '<input id="xmlid" class="form-control myInput" value="'+xmlid+'" type="hidden" />' ,
			  proc_name:  '<input id="proc_name" class="form-control myInput" value="'+name+'" disabled>',
			  proccnname:  '<input id="proccnname" class="form-control myInput" value="'+cnname+'" disabled>',
			  freq:   freq,
			  run_freq_offset:'<input id="run_freq_offset" style="display: block;width:50px;height:30px;background-color: #fff;" class="form-control" value="'+0+'">',
			 //,triggerflag:'触发'
			  delbtn: getDelBtn(xmlid)
	        };	 
	 }
	 $table.datagrid("insertRow", {row: row});	
}

</script>    
<body>

<div class="container-fluid">
<div class="row">
<div class="btn-group btn-group-sm" role="group" aria-label="...">
  <button type="button" class="btn btn-primary btn-xs" id="editDependTable"> <span class="glyphicon glyphicon-plus" aria-hidden="true"></span>依赖表</button>
  <button type="button" class="btn btn-primary btn-xs" id="editOutputTable"><span class="glyphicon glyphicon-plus" aria-hidden="true"></span>输出表</button>
  <button type="button" class="btn btn-primary btn-xs" id="editDependProc"><span class="glyphicon glyphicon-plus" aria-hidden="true"></span>前置程序</button>
  <!-- 
  <button type="button" class="btn btn-default">Middle</button>
  <button type="button" class="btn btn-default">Right</button>
</div>    -->
    <button type="button" class="btn btn-info" id="saveRela">
        保存
    </button>


</div>
</div>
<div class="settings dependTable">
<div class="row">
	<div class="col-md-8">
		<table id="dependTable" class="table table-condensed"></table>
	</div>
</div>
</div>

<div class="settings outputTable">
<div class="row">
	<div class="col-md-8">
		<table id="outputTable" class="table table-condensed"></table>
	</div>
</div>
</div>

<div class="settings dependProc">
<div class="row">
	<div class="col-md-8">
		<table id="dependProc" class="table table-condensed"></table>
	</div>
</div>
</div>

</div>

</body>
</html>    