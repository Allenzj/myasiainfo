<!DOCTYPE html>
<html lang="zh" class="app">
<head> 
  <meta charset="utf-8" /> 
  <title>DACP数据云图</title> 
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
  <link href="${mvcPath}/dacp-lib/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet" media="screen"/>
  <script type="text/javascript" src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js"></script>
	<script type="text/javascript" src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>
	<!-- 使用ai.core.js需要将下面两个加到页面 -->
	<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
	<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>
	
	<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>
	
	
    <style type="text/css">
    body {
        padding-top: 5px;
        padding-bottom: 5px;
    }

    .navbar-default {
        background-color: #d1d1d1;
        border-color: #b1b1b1;
    }

    #res_folder_id, #tag_id {
        background-color:white;
        cursor: default
    }

    #tagDiv{width:270px;border:1px solid #d5d5d5;padding:10px;background-color: #FFF;position:absolute;display:none;}
    #tagDiv .textBox{margin: 0px 0 10px 0;float: left;}
    #tagDiv .input_text,#tagDiv .search_btn{border-color:#d5d5d5;border-width: 1px 0 1px 1px;border-style:solid;}
    #tagDiv .search_btn{border-width: 1px 1px 1px 0px;height:26px;background-position: 8px -26px;}
    #tagDiv .toolbar{margin:0 auto 0 ;text-align:center;padding-top:10px;}
    #folderDiv{width:270px;border:1px solid #d5d5d5;padding:10px;background-color: #FFF;position:absolute;display:none;}
    #folderDiv .textBox{margin: 0px 0 10px 0;float: left;}
    #folderDiv .input_text,#folderDiv .search_btn{border-color:#d5d5d5;border-width: 1px 0 1px 1px;border-style:solid;}
    #folderDiv .search_btn{border-width: 1px 1px 1px 0px;height:26px;background-position: 8px -26px;}
    #folderDiv .toolbar{margin:0 auto 0 ;text-align:center;padding-top:10px;}


    .settings:after{
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

    .settings.request-area:after{
        content: "需求信息";
    }

    .settings.base-area:after{
        content: "基础信息";
    }

    .settings.dev-area:after{
        content: "开发信息";
    }

    .dl-horizontal dt{
        width:80px
    }
    .dl-horizontal dd{
        margin-left:100px
    }

    .form-group {
        margin-bottom: 5px;
    }
    .navbar{
        margin-bottom: 5px;
        min-height: 30px;
        height: 30px
    }
    .navbar-brand {
        padding: 4px 15px;
        font-size: 15px;
    }
    .navbar-text {
        margin-top: 4px;
    }

    .settings {
        background-color: #fff;
        border: 1px solid #ddd;
        border-radius: 4px 4px 4px 4px;
        padding: 20px 10px 0px 10px;
        margin-top: 8px;
        position: relative;
    }
    .row {
        margin-right: 0px;
        margin-left: 0px;
    }

    .required{
        color: red;
    }
</style>	
 </head>
<script type="text/javascript">
$(document)
	.ready(function() { 
	
	$("#add").click(function(){
		
		$.confrim({
			title: 'Confirm!',
			content: 'Confirm! Confirm! Confirm!',
			confirm: function(){
				alert('the user clicked confirm');
			},
			cancel: function(){
				alert('the user clicked cancel')
			}
			});
	});
	
	$('#myModal').modal().css({
	    width: 'auto',
	    'margin-left': function () {
	       return -($(this).width() / 2);
	   }
	});
	
	console.log(${dacpuser});
});

</script>
<body>
	<div class="btn-group">
	  <button type="button" class="btn btn-default" id="add">Left</button>
	  <button type="button" class="btn btn-default">Middle</button>
	  <button type="button" class="btn btn-default">Right</button>
	</div>
	
	    <button class="btn-xs btn-primary btn-lg" data-toggle="modal" data-target="#myModal">
        Launch demo modal
    </button>

    <!-- Modal -->
    <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content" style="width:1000px;">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title" id="myModalLabel">Modal title</h4>
                </div>
                <div class="modal-body" style="width:1000px;">
        			        <div class="container" style="max-width: 900px;padding-top: 0px">
            <nav class="navbar navbar-default">
                <div class="container-fluid">
                    <div class="navbar-header">
                        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
                            <span class="sr-only">Toggle navigation</span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                        </button>
                        <a class="navbar-brand" href="#"><span class="text-primary">报表信息录入</span></a>
                    </div>
                    <div class="collapse navbar-collapse">
                        <ul class="navbar navbar-nav navbar-right">
                            <p class="navbar-text"><span class="text-success"><i class="glyphicon glyphicon-tags"></i>&nbsp; xxx <span class="text-muted">|</span> 0001</span></p>
                            <p class="navbar-text"><a href="javascript:void(0)" data-toggle="modal" data-target="#helper"><i class="glyphicon glyphicon-question-sign"></i> 说明</a></p>
                        </ul>
                    </div>
                </div>
            </nav>

            <div class="settings request-area">
            <div class="row" >

                <form class="form-horizontal">
                    <div class="form-group form-group-sm">
                        <label for="request_name" class="col-md-2 control-label"><span class="required">*</span> 需求名称 </label>
                        <div class="col-md-4">
                            <input id="request_name" class="form-control" value="xxx">
                        </div>

                            <label for="request_person" class="col-md-2 control-label"><span class="required">*</span> 需求提出人 </label>
                            <div class="col-md-4">
                                <input id="request_person" class="form-control" value="${fengwen}">
                            </div>
                    </div>

                    <div class="form-group form-group-sm">
                        <label for="request_dept" class="col-md-2 control-label"><span class="required">*</span> 需求部门 </label>
                        <div class="col-md-4">
                        	<input id="request_dept" class="form-control" value="${report.name}">
                        </div>

                        <label for="request_manager" class="col-md-2 control-label"> 需求管理员 </label>
                        <div class="col-md-4">
                    		<input id="request_manager" class="form-control" value="xxx">
                    	</div>
                    </div>

                    <div class="form-group">

                        <label for="request_desc" class="col-md-2 control-label">需求描述 </label>
                        <div class="col-md-10">
                            <textarea id="request_desc" class="form-control" rows="2">xxxx</textarea>
                        </div>

                    </div>
                </form>
            </div>
        </div>
            <div class="settings base-area">
            <div class="row">

                <form class="form-horizontal">
                    <div class="form-group form-group-sm">
                        <label for="name" class="col-md-2 control-label"><span class="required">*</span> 报表名称  </label>
                        <div class="col-md-4">
                            <input id="name" name="name" class="form-control input-sm" value="xxx">
                        </div>

                        <#--报表周期-->
                        <label for="rpt_cycle" class="col-md-2 control-label"><span class="required">*</span> 报表周期 </label>
                        <div class="col-md-4">
                            <select id="rpt_cycle" name="rpt_cycle" class="form-control">
                                <option value="1" selected>日报</option>
                                <option value="2" >月报</option>
                                <option value="5" >周报</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="descr" class="col-md-2 control-label">报表描述 </label>
                        <div class="col-md-10">
                            <textarea id="descr" name="descr" class="form-control" rows="2">xxx</textarea>
                        </div>
                    </div>
                </form>
        </div>
                </div>


            <div class="settings dev-area">
            <div class="row">
                <form class="form-horizontal">
                    <div class="form-group form-group-sm">
                  
                        <label for="report_type" class="col-md-2 control-label">报表类型 </label>
                        <div class="col-md-4">
                            <select id="report_type" name="report_type" class="form-control">
                                <option value="sql报表" >SQL报表</option>
                                <option value="指标报表" >指标报表</option>
                                <option value="综合报表" >综合报表</option>
                            </select>
                        </div>

                        <label for="category" class="col-md-2 control-label">报表风格 </label>
                        <div class="col-md-4">
                            <select id="category" name="category" class="form-control">
                                <option value="ve-default" >经分报表</option>
                                <option value="ve-channel" >渠道报表</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group form-group-sm">
         
                        <label for="table_public_flag" class="col-md-2 control-label"> 授权方式 </label>
                        <div class="col-md-4">
                            <label class="radio-inline">
                                <input type="radio" id="table_public_flag" name="table_public_flag" value="1" > 公有
                            </label>
                            <label class="radio-inline">
                                <input type="radio" id="table_public_flag" name="table_public_flag" value="2"> 私有
                            </label>
                        </div>

  
                        <label for="table_use_type" class="col-md-2 control-label"> 展现方式 </label>
                        <div class="col-md-4">
                            <label class="radio-inline">
                                <input type="radio" id="table_use_type" name="table_use_type" value="2"> 报表
                            </label>
                            <label class="radio-inline">
                                <input type="radio" id="table_use_type" name="table_use_type" value="1"> 角色视图
                            </label>

                        </div>
                    </div>

                    <div class="form-group form-group-sm">

                        <label for="data_gran_max" class="col-md-2 control-label"> 最大粒度 </label>
                        <div class="col-md-4">
                            <select id="data_gran_max" name="data_gran_max" class="form-control">
                                <option value="0">全国</option>
                                <option value="1" >省</option>
                                <option value="2" >地市</option>
                                <option value="3" >县市</option>
                                <option value="4" >片区</option>
                                <option value="5" >渠道</option>
                                <option value="6" >操作员</option>
                            </select>
                        </div>

                                         <label for="data_gran_min" class="col-md-2 control-label"> 最小粒度 </label>
                        <div class="col-md-4">
                            <select id="data_gran_min" name="data_gran_min" class="form-control">
                                <option value="0" >全国</option>
                                <option value="1" >省</option>
                                <option value="2" >地市</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group form-group-sm">
                        <label for="end_time" class="col-md-2 control-label"> 停用时间 </label>
                        <div class="col-md-4">
                            <input id="end_time" name="end_time" class="form-control" value="xxxxxx">
                        </div>

                        <label for="db_name" class="col-md-2 control-label">开发库 </label>
                        <div class="col-md-4">
                            <input id="db_name" name="db_name" class="form-control" value="xxx">
                        </div>

                    </div>

                    <div class="form-group form-group-sm">
  
                        <label for="table_name" class="col-md-2 control-label">表名 </label>
                        <div class="col-md-4">
                            <input id="table_name" name="table_name" class="form-control" value="xxx">
                        </div>

                        <label for="rpt_item" class="col-md-2 control-label">汇总项 </label>
                        <div class="col-md-4">
                            <input id="rpt_item" name="rpt_item" class="form-control" value="xxx">
                        </div>
                    </div>
                </form>
            </div>
                </div>

            <div class="row" style="padding-top: 5px;">
                <button type="button" class="btn btn-default pull-right btn-sm" id="returnBtn" >返回</button>

                    <button type="button" class="btn btn-primary pull-right btn-sm" id="saveBtn" style="margin-right: 5px"><i class="glyphicon glyphicon-floppy-disk"></i> 保存信息</button>

                    <button type="button" class="btn btn-primary pull-right btn-sm" id="saveBtn" style="margin-right: 5px"><i class="glyphicon glyphicon-plus"></i> 创建报表</button>

                <button type="file" class="btn btn-success btn-sm" id="import" ><i class="glyphicon glyphicon-upload"></i> 导入需求模板</button>
                <form><input style="display: none" id="importFile" name="importFile" type="file" /></form>
            </div>

        </div>

    <div id="tagDiv">
        <ul id="tagTree" style="height:300px;overflow:auto;border:1px solid #d5d5d5;"></ul>
        <div class="clear"></div>
        <div class="toolbar btn-move">
            <a href="javascript:tag_ok()" class="btn btn-default btn-sm sure-dian">确定</a>
            <a href="javascript: div_hide('tagDiv')" class="btn btn-default btn-sm off-dian">取消</a>
        </div>
    </div>
    <div id="folderDiv">
        <ul id="folderTree" style="height:300px;overflow:auto;border:1px solid #d5d5d5;"></ul>
        <div class="clear"></div>
        <div class="toolbar">
            <a href="javascript:folder_ok()" class="btn btn-default btn-sm sure-dian">确定</a>
            <a href="javascript: div_hide('folderDiv')" class="btn btn-default btn-sm off-dian">取消</a>
        </div>
    </div>

    
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary">Save changes</button>
                </div>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->
    	
    	
    	
    	<div class="modal fade" id="helper" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" data-backdrop="false">
        <div class="modal-dialog" role="document">
            <div class="modal-content" >
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="myModalLabel">输入项说明文档</h4>
                </div>
                <div class="modal-body" style="max-height: 400px; overflow: auto">
                    <dl class="dl-horizontal">
                        <dt>需求名称</dt><dd>设置报表需求的名称.</dd>
                        <dt>需求提出人</dt><dd>设置报表需求的提出人姓名.</dd>
                        <dt>需求部门</dt><dd>选择报表需求的所属部门.</dd>
                        <dt>需求管理员</dt><dd>选择报表需求的管理员.如果业务人员对报表存在疑问，可向其进行咨询.</dd>
                        <dt style="margin-bottom: 20px">需求描述</dt><dd>设置报表需求的详细描述信息.</dd>

                        <dt>报表名称</dt><dd>设置报表的标题.</dd>
                        <dt>报表周期</dt><dd>设置报表的周期. 订阅该报表时, 将按此周期进行推送.</dd>
                        <dt>资源分类</dt><dd>选择报表所属的资源分类. 只有被授权该资源权限的用户才能在黄金眼中查看到此报表. 另,报表发布后生成的业务编码将与资源分类有关, 若修改资源分类后重新发布报表, 业务编码不会改变.</dd>
                        <dt>业务标签</dt><dd>设置报表的业务标签. 用于在黄金眼展示.</dd>
                        <dt style="margin-bottom: 20px">报表描述</dt><dd>设置报表的详细描述信息.</dd>

                        <dt>报表类型</dt><dd>标明报表的数据源类型, 用于黄金眼展示. 『综合报表』指包含多种数据源的报表.</dd>
                        <dt>报表风格</dt><dd>选择报表的样式主题. 『经分报表』为默认样式. 『渠道报表』是专门为渠道报表制作的样式.</dd>
                        <dt>授权方式</dt><dd>选择报表的授权方式. 『公有』报表含有常规的查看权限. 『私有』报表必须在黄金眼系统管理-报表管理中对特定的用户授权.</dd>
                        <dt>展现方式</dt><dd>选择报表的展现方式. 『报表』以常规报表的方式对外展示. 『角色视图』以角色视图方式对外展示. 角色视图发布后需要在黄金眼系统管理中进行角色适配才能查看.</dd>
                        <dt>最大粒度</dt><dd>选择报表的最大数据粒度</dd>
                        <dt>最小粒度</dt><dd>选择报表的最大数据粒度</dd>

                    </dl>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">关闭</button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>