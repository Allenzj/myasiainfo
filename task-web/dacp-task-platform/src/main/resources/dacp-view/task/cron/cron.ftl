<!DOCTYPE html>
<html>
<head>
  <title>Cron表达式生成器</title>
    <link href="${mvcPath}/dacp-lib/easyui/themes/bootstrap/easyui.css" rel="stylesheet" type="text/css" />
    <link href="${mvcPath}/dacp-lib/easyui/themes/icon.css" rel="stylesheet" type="text/css" />
    <link href="${mvcPath}/dacp-lib/easyui/icon.css" rel="stylesheet" type="text/css" />
    <script src="${mvcPath}/dacp-lib/jquery/jquery-1.10.2.min.js" type="text/javascript" ></script>
    <script src="${mvcPath}/dacp-lib/easyui/jquery.easyui.min.js" type="text/javascript"></script>
    <script src="${mvcPath}/dacp-view/task/cron/js/cron.js" type="text/javascript"></script>
    <style type="text/css">
        .line
        {
            height: 25px;
            line-height: 25px;
            margin: 3px;
        }
		.line_time
        {
            height: 25px;
            line-height: 25px;
            margin: 7px;
        }
        .imp
        {
            padding-left: 25px;
        }
        .col
        {
            width: 70px;
        }
    </style>
</head>
<body>
<center>
	<div class="easyui-layout" style="width:620px;height:320px; border: 1px rgb(202, 196, 196) solid; border-radius: 5px;">
		<div id="tab_content" class="easyui-tabs" data-options="fit:true,border:false">
			<div id="_minute" title="分钟" name="分钟">
				<div class="line">
					<input type="radio" name="min" onclick="startOn(this)">从
					<input class="numberspinner" style="width: 60px;" data-options="min:0,max:59" value="0" id="minStart_1"> 分钟开始,每
					<input class="numberspinner" style="width: 60px;" data-options="min:1,max:59" value="1" id="minEnd_1">分钟执行一次
				</div>
			</div>
			<div id="_hour" title="时" name="时">
				<div class="line">
					<input type="radio" name="hour" onclick="startOn(this)">从
					<input class="numberspinner" style="width: 60px;" data-options="min:0,max:23" value="0" id="hourStart_1">小时开始,每
					<input class="numberspinner" style="width: 60px;" data-options="min:1,max:23" value="1" id="hourEnd_1">小时执行一次
				</div>
				<div class="line">
					<input type="radio" name="hour" id="hour_appoint">指定
				</div>
				<div class="imp hourList">
					AM:
					<input type="checkbox" value="0">00
					<input type="checkbox" value="1">01
					<input type="checkbox" value="2">02
					<input type="checkbox" value="3">03
					<input type="checkbox" value="4">04
					<input type="checkbox" value="5">05
					<input type="checkbox" value="6">06
					<input type="checkbox" value="7">07
					<input type="checkbox" value="8">08
					<input type="checkbox" value="9">09
					<input type="checkbox" value="10">10
					<input type="checkbox" value="11">11
				</div>
				<div class="imp hourList">
					PM:
					<input type="checkbox" value="12">12
					<input type="checkbox" value="13">13
					<input type="checkbox" value="14">14
					<input type="checkbox" value="15">15
					<input type="checkbox" value="16">16
					<input type="checkbox" value="17">17
					<input type="checkbox" value="18">18
					<input type="checkbox" value="19">19
					<input type="checkbox" value="20">20
					<input type="checkbox" value="21">21
					<input type="checkbox" value="22">22
					<input type="checkbox" value="23">23
				</div>
				<br/>
				<div class="line_time_hour">开始执行时间：
					<input class="numberspinner" style="width: 60px;" data-options="min:0,max:59" value="00" id="minute_begin" name="minute_begin" >分
				</div>
			</div>
			<div id="_day" title="天" name="天">
				<div class="line">
					<input type="radio"  id="day_interval" name="day" onclick="startOn(this)"> 从
					<input class="numberspinner" style="width: 60px;" data-options="min:1,max:31" value="1" id="dayStart_1"> 日开始,每
					<input class="numberspinner" style="width: 60px;" data-options="min:1,max:31" value="1" id="dayEnd_1"> 天执行一次
				</div>
				<div class="line_time_day">
					开始执行时间：
					<input class="numberspinner" style="width: 60px;" data-options="min:0,max:23" value="0" id="hour_begin" name="hour_begin" >点
					<input class="numberspinner" style="width: 60px;" data-options="min:0,max:59" value="0" id="minute_begin" name="minute_begin">分
				 </div>
			</div>
			<div id="_month" title="月"  name="月">
				<div class="line">
					<input type="radio" id="month_interval" name="month" onclick="startOn(this)"> 从
					<input class="numberspinner" style="width: 60px;" data-options="min:1,max:12" value="1" id="monthStart_1">月开始,每
					<input class="numberspinner" style="width: 60px;" data-options="min:1,max:12" value="1" id="monthEnd_1"> 月执行一次
				</div>
				<div class="line_time_month">开始执行时间：
					<input class="numberspinner" style="width: 50px;" data-options="min:1,max:31" value="01" id="day_begin" name="day_begin" />日
					<input class="numberspinner" style="width: 50px;" data-options="min:0,max:23" value="00" id="hour_begin" name="hour_begin" >点
					<input class="numberspinner" style="width: 50px;" data-options="min:0,max:59" value="00" id="minute_begin" name="minute_begin" >分
				</div>
			</div>
			<div id="_year" title="年" name="年">
				<div class="line">
					<input type="radio" name="year" id="every_year" onclick="everyTime(this)" checked="checked">每年
				</div>
				<div class="line">
					<input type="radio" name="year" id="year_interval" onclick="startOn(this)">周期 从
					<input class="numberspinner" style="width: 90px;" data-options="min:2014,max:3000" id="yearStart_0" value="2014">-
					<input class="numberspinner" style="width: 90px;" data-options="min:2015,max:3000" id="yearEnd_0" value="2015">,每
					<input class="numberspinner" style="width: 60px;" data-options="min:1,max:100" value="1" id="yearInterval">年执行一次
				</div>
				<div class="line_time_year">
					开始执行时间：
					<input class="numberspinner" style="width: 50px;" data-options="min:1,max:12" value="01" id="month_begin" name="month_begin" />月
					<input class="numberspinner" style="width: 50px;" data-options="min:1,max:31" value="01" id="day_begin" name="day_begin" />日
					<input class="numberspinner" style="width: 50px;" data-options="min:0,max:23" value="00" id="hour_begin" name="hour_begin" />点
					<input class="numberspinner" style="width: 50px;" data-options="min:0,max:59" value="00" id="minute_begin" name="minute_begin" />分
				</div>
			</div>
			<div id="_week" title="周" name="周">
	            <div class="line">
	                <input type="radio" name="week" id="week_appoint"  />指定
                </div>
	            <div class="imp weekList">
	                <input type="checkbox" value="1">星期天
	                <input type="checkbox" value="2">星期一
	                <input type="checkbox" value="3">星期二
	                <input type="checkbox" value="4">星期三
	                <input type="checkbox" value="5">星期四
	                <input type="checkbox" value="6">星期五
	                <input type="checkbox" value="7">星期六
	            </div>
	            <div class="line_time_week">开始执行时间：
					<input class="numberspinner" style="width: 60px;" data-options="min:0,max:23" value="00" id="hour_begin" name="hour_begin" >点
					<input class="numberspinner" style="width: 60px;" data-options="min:0,max:59" value="00" id="minute_begin" name="minute_begin" >分
				</div>
	        </div>
		</div>
		
		<div data-options="region:'south',border:false" style="height:150px">
			<fieldset style="border-radius: 3px; height: 116px;">
				<legend>表达式</legend>
				<table style="height: 100px;">
					<tbody>
						<tr>
							<td></td>
							<td align="center">分钟</td>
							<td align="center">小时</td>
							<td align="center">日</td>
							<td align="center">月</td>  
							<td align="center">周</td> 
							<td align="center">年</td> 
						</tr>
						<tr>
							<td>表达式字段:</td>
							<td>
								<input type="hidden" name="v_second"  value="*"  />
								<input id="v_min" type="text" name="v_min" class="col" value="*" readonly="readonly" />
							</td>
							<td><input id="v_hour" type="text" name="v_hour" class="col" value="*" readonly="readonly" /></td>
							<td><input id="v_day" type="text" name="v_day" class="col" value="*" readonly="readonly" /></td>
							<td><input id="v_month" type="text" name="v_month" class="col" value="*" readonly="readonly" /></td>
							<td><input id="v_week" type="text" name="v_week" class="col" value="?" readonly="readonly" /></td>
							<td><input id="v_year" type="text" name="v_year" class="col" value="*" readonly="readonly" /></td>
						</tr>
						<tr>
				  			<td>Cron表达式:</td>
							<td colspan="5"><input type="text" name="cron" style="width:100%;" value="* * * * * ?" id="cron" readonly="readonly"/></td>		 
							<!--<td><input type="button" value="反解析到UI " id="btnFan" onclick="btnFan()"/></td>-->
						</tr>
						<tr>
				    		<td></td>
							<td></td>
							<td><input type="button" value="确定" id="btnFan" onclick="ret()"/></td>
							<td><input type="button" value="清空" id="btnFan" onclick="_reset()"/></td>
							<td><input type="button" value="取消" id="btnFan" onclick="_close()"/></td>
							<td></td>
						</tr>
					</tbody>
				</table>
			</fieldset>

			<div style="text-align: center; margin-top: 5px;">
				<script type="text/javascript">
					$.parser.parse($("body"));
				</script> 
			</div>
        </div>
	</div>
</center>
</body>
</html>
