<!DOCTYPE html>
<html lang="zh" class="app">
<head> 
  <meta charset="utf-8" /> 
  <title>DACP数据云图</title> 
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
  <link href="${mvcPath}/dacp-view/aijs/css/ai.css" type="text/css" rel="stylesheet"  />

  <script type="text/javascript" src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js"></script>
	<script type="text/javascript" src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>
	<!-- 使用ai.core.js需要将下面两个加到页面 -->
	<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
	<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>
	
	<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
	<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>

	<script src="${mvcPath}/dacp-view/task/scheduleManual.js"></script> 
 </head>
 <body>
  <nav class="navbar navbar-default" role="navigation" style="margin-bottom: 1px"> 
   <div class="container-fluid"> 
    <div class="navbar-header"> 
     <a class="navbar-brand bg-light " style="width: 200px">汇总列表</a> 
    </div> 
    <form class="navbar-form navbar-left" role="search" style="padding-top: 5px"> 
     <div class="form-group"> 
      <input id="searchContent" type="text" size="60" class="form-control" placeholder="任务名" /> 
     </div> 
     <button id="searchBtn" type="button" class="btn btn-success btn-xs">查找</button> 
     <button id="insertBtn" type="button" class="btn btn-primary btn-xs">增加</button> 
    </form> 
    <ul class="nav navbar-nav navbar-right"> 
     <li> 
      <ul id="mypagination" class="nav navbar-nav pagination-letter"></ul> </li>
     <li> </li>
    </ul> 
   </div> 
   <!-- /.container-fluid --> 
  </nav> 
  <section class="vbox"> 
   <section> 
    <section class="hbox stretch"> 
     <section id="content"> 
      <section class="vbox"> 
       <section> 
        <section class="hbox stretch"> 
         <!-- side content --> 
         <aside class="aside bg-light dk" id="sidebar"> 
          <section class="vbox animated fadeInUp"> 
           <section class="scrollable hover"> 
            <div class="list-group no-radius no-border no-bg m-t-n-xxs m-b-none auto" id="gridsumList"></div> 
           </section> 
          </section> 
         </aside> 
         <!-- / side content --> 
         <section> 
          <section class="vbox"> 
           <section class="scrollable padder-lg" style="overflow: hidden"> 
            <div class="table-responsive" id="datagrid" style="width: 100%; overflow: auto;"></div> 
           </section> 
          </section> 
         </section> 
        </section> 
       </section> 
      </section> 
     </section> 
    </section> 
   </section> 
  </section> 
  <!-- Bootstrap --> 
  <!-- App --> 
  <div id="myModal" class="modal fade"> 
   <div class="modal-dialog" style="height: 400px"> 
    <div class="modal-content"> 
     <div class="modal-header"> 
      <button type="button" class="close close-modal" > <span aria-hidden="true">&times;</span><span class="sr-only">Close</span> </button> 
      <h4 class="modal-title">手工任务</h4> 
     </div> 
     <div class="modal-body" id="upsertForm"></div> 
     <div class="modal-footer"> 
      <button type="button" class="btn btn-default close-modal" >取消</button> 
      <button id="dialog-ok" type="button" class="btn btn-primary">确认</button> 
     </div> 
    </div> 
    <!-- /.modal-content --> 
   </div> 
   <!-- /.modal-dialog --> 
  </div> 
  <!-- /.modal -->  
  
   <div id="logModal" class="modal fade">
  <div class="modal-dialog" style="height:500px;width:800px">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
        <h4 class="modal-title">手工运行日志</h4>
      </div>
      <div class="modal-body" id="openForm">
      <pre id="log_content"></pre>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
        <button id="dialog-ok" type="button" class="btn btn-primary">确认</button>
      </div>
    </div><!-- /.modal-content -->
  </div><!-- /.modal-dialog -->
 </div><!-- /.modal -->
 </body>
</html>