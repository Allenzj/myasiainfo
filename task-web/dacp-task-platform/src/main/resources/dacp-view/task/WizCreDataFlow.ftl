<!DOCTYPE html>
<html lang="en" class="app">
<head>
<meta charset="utf-8" />
<title>DACP程序列表</title>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
<link href="${mvcPath}/dacp-lib/fuelux/fuelux.min.css" type="text/css" rel="stylesheet"/>
<link href="${mvcPath}/dacp-view/aijs/css/ai.css" type="text/css" rel="stylesheet"/>
<link rel="shortcut icon" href="${mvcPath}/dacp-res/task/images/favicon.ico"/>
<link rel="bookmark" href="${mvcPath}/dacp-res/task/images/favicon.ico"/>

<script type="text/javascript" src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js"></script>
<script type="text/javascript" src="${mvcPath}/dacp-lib/bootstrap/js/bootstrap.min.js"></script>
<script src="${mvcPath}/dacp-lib/fuelux/fuelux.min.js"></script>

<!-- 使用ai.core.js需要将下面两个加到页面 -->
<script src="${mvcPath}/dacp-lib/cryptojs/aes.js" type="text/javascript"></script>
<script src="${mvcPath}/crypto/crypto-context.js" type="text/javascript"></script>

<script src="${mvcPath}/dacp-view/aijs/js/ai.core.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.field.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.jsonstore.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.grid.js"></script>

<script src="${mvcPath}/dacp-res/task/js/metaStore.v1.js"></script>
<script src="${mvcPath}/dacp-lib/ext/ext-base.js"></script>
<script src="${mvcPath}/dacp-lib/ext/ext-all.js"></script>
<script src="${mvcPath}/dacp-lib/jquery-plugins/jquery-artDialog.js"></script>
<script src="${mvcPath}/dacp-view/aijs/js/ai.wizard.js"></script>
<script src="${mvcPath}/dacp-lib/jquery-plugins/jquery-contextMenu.js"></script>
<script src="${mvcPath}/dacp-lib/ztree/jquery.ztree.all-3.5.min.js"></script> 
<script src="${mvcPath}/dacp-res/task/js/metaAction.js"></script>
    <style>
    .form-group {
        margin-bottom: 5px;
    }
    .help-block {
        display: block;
        margin-top: 5px;
        margin-bottom: 1px;
        color: #737373;
    }
    html,
    body {
        margin: 0px;
        height: 100%;
    }
    .step-pane {
        height: 100%;
    }
    .fuelux .wizard .step-content {
        border-top: 1px solid #D4D4D4;
        padding: 0px !important;
        float: left;
        width: 100%;
    }
    .table {
        font-size: 12px;
    }
    </style>
    <script>
    $(document).ready(function() {
        /*添加html元素和绑定事件*/
        metaActionController.addDataEvent();
        /*初始化页面信息*/
        metaActionController.editDataMeatInfoFun().init();
    });
    </script>
</head>

<body class="">
    <div id="test" class="fuelux" style="height:100%;">
    </div>
</body>

</html>