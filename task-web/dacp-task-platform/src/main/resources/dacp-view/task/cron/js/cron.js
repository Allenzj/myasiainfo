
function ret()
{
	var st_day = "";
	var st_time = "";
	var cycle = $.getUrlParam("freq");
	switch(cycle){
		case "year":
			break;
		case "month":
			st_day = $("#v_day").val();
			st_time = ($("#v_hour").val()<10?"0"+$("#v_hour").val():$("#v_hour").val()) + ":" + ($("#v_min").val()<10?"0"+$("#v_min").val():$("#v_min").val())+":00";
			break;
		case "day":
			st_time = ($("#v_hour").val()<10?"0"+$("#v_hour").val():$("#v_hour").val()) + ":" + ($("#v_min").val()<10?"0"+$("#v_min").val():$("#v_min").val())+":00";
			break;
		case "hour":
			break;
		case "minute":
			break;
		case "second":
			break;
		default:
			break;
	}
	
	mycron=	$("#cron").val();
	//window.returnValue = mycron;
	if(mycron&&mycron.length>0){
		if(st_day) window.opener.document.getElementById("st_day").value=st_day;
		if(st_time) window.opener.document.getElementById("st_time").value=st_time;
		if(cycle) window.opener.document.getElementById("curFreq").value=cycle;
	}
	window.opener.document.getElementById(_cron_id).value=mycron;
	window.opener = null;//为了不出现提示框 
	window.close();//关闭窗口
}
function _close()
{
	window.close(); 
}

function _reset()
{
	$("#cron").val("");
}

function initObj(strVal, strid) {
    var ary = null;
    var objRadio = $("input[name='" + strid + "'");
    if (strVal.split('/').length > 1) {
        ary = strVal.split('/');
        objRadio.eq(0).attr("checked", "checked");
        $("#" + strid + "Start_1").numberspinner('setValue', ary[0]);
        $("#" + strid + "End_1").numberspinner('setValue', ary[1]);
    } else {
        objRadio.eq(1).attr("checked", "checked");
        if (strVal != "?") {
            ary = strVal.split(",");
            for (var i = 0; i < ary.length; i++) {
                $("." + strid + "List input[value='" + ary[i] + "']").attr("checked", "checked");
            }
        }
    }
}

function initDay(strVal) {
    var ary = null;
    if (strVal == "*") {
        $("#day_every").attr("checked", "checked");
    } else if (strVal.split('/').length > 1) {
        ary = strVal.split('/');
        $("#day_interval").attr("checked", "checked");
        $("#dayStart_1").numberspinner('setValue', ary[0]);
        $("#dayEnd_1").numberspinner('setValue', ary[1]);
    } 
}
function initMonth(strVal) {
    var ary = null;
    if (strVal == "*") {
        $("#mouth_every").attr("checked", "checked");
    }else if (strVal.split('/').length > 1) {
        ary = strVal.split('/');
        $("#mouth_interval").attr("checked", "checked");
        $("#mouthStart_1").numberspinner('setValue', ary[0]);
        $("#mouthEnd_1").numberspinner('setValue', ary[1]);
    }
}

function initWeek(strVal) {
    var ary = null;
    var objRadio = $("input[name='week'");
    if (strVal == "*") {
        objRadio.eq(0).attr("checked", "checked");
    } else if (strVal == "?") {
        objRadio.eq(1).attr("checked", "checked");
    } else if (strVal.split('/').length > 1) {
        ary = strVal.split('/');
        objRadio.eq(2).attr("checked", "checked");
        $("#weekStart_0").numberspinner('setValue', ary[0]);
        $("#weekEnd_0").numberspinner('setValue', ary[1]);
    } else if (strVal.split('-').length > 1) {
        ary = strVal.split('-');
        objRadio.eq(3).attr("checked", "checked");
        $("#weekStart_1").numberspinner('setValue', ary[0]);
        $("#weekEnd_1").numberspinner('setValue', ary[1]);
    } else if (strVal.split('L').length > 1) {
        ary = strVal.split('L');
        objRadio.eq(4).attr("checked", "checked");
        $("#weekStart_2").numberspinner('setValue', ary[0]);
    } else {
        objRadio.eq(5).attr("checked", "checked");
        ary = strVal.split(",");
        for (var i = 0; i < ary.length; i++) {
            $(".weekList input[value='" + ary[i] + "']").attr("checked", "checked");
        }
    }
}

function initYear(strVal) {
    var ary = null;
    var ary2 = null;
    var objRadio = $("input[name='year'");
    if (strVal == "*") {
        objRadio.eq(0).attr("checked", "checked");
    } else if (strVal.split('/').length > 1) {
        ary = strVal.split('/');
        objRadio.eq(1).attr("checked", "checked");
        $("#yearInterval").numberspinner('setValue', ary[1]);
        if(ary[0].split("/").length>1){
        	ary2 = ary[0].split("/");
        	$("#yearStart_0").numberspinner('setValue', ary2[0]);
            $("#yearEnd_0").numberspinner('setValue', ary2[1]);
        }
    }   
}

function btnFan(_type) {
    //获取参数中表达式的值
    var txt = $("#cron").val();
    if (txt) {
        var regs = txt.split(' ');
        if(regs.length<6 ){
        	regs="0 0 0 * * ?";
        }
        $("input[name=v_second]").val(0);
        $("input[name=v_min]").val(regs[1]);
        $("input[name=v_hour]").val(regs[2]);
        $("input[name=v_day]").val(regs[3]);
        $("input[name=v_month]").val(regs[4]);
        $("input[name=v_week]").val(regs[5]);
        if(_type=="year"){
       	 	$(".line_time_year #minute_begin").val(regs[1]);
            $(".line_time_year #hour_begin").val(regs[2]);
            $(".line_time_year #day_begin").val(regs[3]);
            $(".line_time_year #month_begin").val(regs[4]);
        }else if(_type=="month"){
        	 $(".line_time_month #minute_begin").val(regs[1]);
             $(".line_time_month #hour_begin").val(regs[2]);
             $(".line_time_month #day_begin").val(regs[3]);
        }else if(_type=="day"){
             $(".line_time_day #minute_begin").val(regs[1]);
             $(".line_time_day #hour_begin").val(regs[2]);
        }else if(_type=="week"){
            $(".line_time_week #minute_begin").val(regs[1]);
            $(".line_time_week #hour_begin").val(regs[2]);
        }else if(_type=="hour"){
            $(".line_time_hour #minute_begin").val(regs[1]);
        }
       
        initObj(regs[0], "second");
        initObj(regs[1], "min");
        initObj(regs[2], "hour");
        initDay(regs[3]);
        initMonth(regs[4]);
        initWeek(regs[5]);

        if (regs.length > 6) {
            $("input[name=v_year]").val(regs[6]);
            initYear(regs[6]);
        }
        
    }
}

function updateVal(objs,vals){
    var item = "";
    $.each(objs,function(n,obj) {	
		item=$("input[name="+obj+"]");
		item.val(vals[n]);
		item.change();
     });  
}
function updateItem(dom){
	var _parent= $(dom).parent().parent().attr("id");
	var items=["v_min","v_hour","v_day","v_month","v_year"],vals=[];
	if(_parent=="_hour"){
		vals=[$(".line_time_hour #minute_begin").val(),"*","*","*"];
	}else if(_parent=="_day"){
		vals=[$(".line_time_day #minute_begin").val(),$(".line_time_day #hour_begin").val(),"*","*"];
	}else if(_parent=="_month"){
		vals = [$(".line_time_month #minute_begin").val(),$(".line_time_month #hour_begin").val(),$(".line_time_month #day_begin").val(),$("#monthStart_1").val()];
	}else if(_parent=="_minute"){
		vals = ["*","*","*","*"];
	}else if(_parent=="_year"){
		vals = [$(".line_time_year #minute_begin").val(),$(".line_time_year #hour_begin").val(),$(".line_time_year #day_begin").val(),$(".line_time_year #month_begin").val(),$("#mouthStart_1").val()];
	}
	updateVal(items,vals);
}
/**
 * 每周期
 */
function everyTime(dom) {
	updateItem(dom);
	var item = $("input[name=v_" + dom.name + "]");
	item.val("*");
	item.change();
}
/**
 * 从开始
 */
function startOn(dom) {
	updateItem(dom);
	var name = dom.name;
	var ns = $(dom).parent().find(".numberspinner");
	var start = ns.eq(0).numberspinner("getValue");
	var end = ns.eq(1).numberspinner("getValue");
	var result = start + "/" + end;
	
	if(name == "year"){
		var interval = ns.eq(2).numberspinner("getValue");
		result = start + "-" + end + "/" + interval;
	}
	var item = $("input[name=v_" + name + "]");
	
	item.val(result);
	item.change();
	
}
/**
 * 不指定
 */
function unAppoint(dom) {
	var name = dom.name;
	var val = "?";
	if (name == "year")
		val = "";
	var item = $("input[name=v_" + name + "]");
	item.val(val);
	item.change();
}

function appoint(dom) {
	var items=["v_min","v_hour","v_day","v_mouth"],vals=["*","*","*","*"];
	updateVal(items,vals);
}

/**
 * 周期
 */
function cycle(dom) {
	var name = dom.name;
	var ns = $(dom).parent().find(".numberspinner");
	var start = ns.eq(0).numberspinner("getValue");
	var end = ns.eq(1).numberspinner("getValue");
	var item = $("input[name=v_" + name + "]");
	item.val(start + "-" + end);
	item.change();
}



function lastDay(dom){
	var item = $("input[name=v_day]");
	item.val("L");
	item.change();
}

function weekOfDay(dom){
	var name = dom.name;
	var ns = $(dom).parent().find(".numberspinner");
	var start = ns.eq(0).numberspinner("getValue");
	var end = ns.eq(1).numberspinner("getValue");
	var item = $("input[name=v_" + name + "]");
	item.val(start + "#" + end);
	item.change();
}

function lastWeek(dom){
	var item = $("input[name=v_" + dom.name + "]");
	var ns = $(dom).parent().find(".numberspinner");
	var start = ns.eq(0).numberspinner("getValue");
	item.val(start+"L");
	item.change();
}

function workDay(dom) {
	var name = dom.name;
	var ns = $(dom).parent().find(".numberspinner");
	var start = ns.eq(0).numberspinner("getValue");
	var item = $("input[name=v_" + name + "]");
	item.val(start + "W");
	item.change();
}
function setTime(dom){
	var _val = $(dom).numberspinner("getValue");
	var item="";
	if($(dom).attr("id")==="month_begin"){
	  item = $("input[name=v_month]");
	}else if($(dom).attr("id")==="day_begin"){
	  item = $("input[name=v_day]");
	}else if($(dom).attr("id")==="hour_begin"){
	  item = $("input[name=v_hour]");
	}else{
	  item = $("input[name=v_min]");
	}
	item.val(_val);
	item.change();
}
$(function() {
	$(".numberspinner").numberspinner({
		onChange:function(){
			$(this).closest("div.line").children().eq(0).click();
			var obj = $(this).parent().parent();
			if(obj.attr("class")==="line_time_hour"||obj.attr("class")==="line_time_day"||obj.attr("class")==="line_time_month"||obj.attr("class")==="line_time_year"||obj.attr("class")==="line_time_week"){
				setTime($(this));
			}
		}
	});
	var vals = $("input[name^='v_']");
	var cron = $("#cron");
	vals.change(function() {
		var item = [];
		vals.each(function() {
			item.push(this.value);
		});
		cron.val(item.join(" "));
	});
	
	var secondList = $(".secondList").children();
	$("#sencond_appoint").click(function(){
		if(this.checked){
			secondList.eq(0).change();
		}
	});

	secondList.change(function() {
		var sencond_appoint = $("#sencond_appoint").prop("checked");
		if (sencond_appoint) {
			var vals = [];
			secondList.each(function() {
				if (this.checked) {
					vals.push(this.value);
				}
			});
			var val = "?";
			if (vals.length > 0 && vals.length < 59) {
				val = vals.join(","); 
			}else if(vals.length == 59){
				val = "*";
			}
			var item = $("input[name=v_second]");
			item.val(val);
			item.change();
		}
	});
	
	var minList = $(".minList").children();
	$("#min_appoint").click(function(){
		if(this.checked){
			minList.eq(0).change();
		}
	});
	
	minList.change(function() {
		var min_appoint = $("#min_appoint").prop("checked");
		if (min_appoint) {
			var vals = [];
			minList.each(function() {
				if (this.checked) {
					vals.push(this.value);
				}
			});
			var val = "?";
			if (vals.length > 0 && vals.length < 59) {
				val = vals.join(",");
			}else if(vals.length == 59){
				val = "*";
			}
			var item = $("input[name=v_min]");
			item.val(val);
			item.change();
		}
	});
	
	var hourList = $(".hourList").children();
	$("#hour_appoint").click(function(){
		if(this.checked){
			hourList.eq(0).change();
		}
	});
	
	hourList.change(function() {
		var hour_appoint = $("#hour_appoint").prop("checked","checked");
		if (hour_appoint) {
			var vals = [];
			hourList.each(function() {
				if (this.checked) {
					vals.push(this.value);
				}
			});
			var val = "?";
			if (vals.length > 0 && vals.length < 24) {
				val = vals.join(",");
			}else if(vals.length == 24){
				val = "*";
			}
			var item = $("input[name=v_hour]");
			item.val(val);
			item.change();
		}
	});
	
	var dayList = $(".dayList").children();
	$("#day_appoint").click(function(){
		if(this.checked){
			dayList.eq(0).change();
		}
	});
	
	dayList.change(function() {
		var day_appoint = $("#day_appoint").prop("checked");
		if (day_appoint) {
			var vals = [];
			dayList.each(function() {
				if (this.checked) {
					vals.push(this.value);
				}
			});
			var val = "?";
			if (vals.length > 0 && vals.length < 31) {
				val = vals.join(",");
			}else if(vals.length == 31){
				val = "*";
			}
			var item = $("input[name=v_day]");
			item.val(val);
			item.change();
		}
	});
	
	var mouthList = $(".mouthList").children();
	$("#month_appoint").click(function(){
		if(this.checked){
			mouthList.eq(0).change();
		}
	});
	
	mouthList.change(function() {
		var month_appoint = $("#month_appoint").prop("checked");
		if (month_appoint) {
			var vals = [];
			mouthList.each(function() {
				if (this.checked) {
					vals.push(this.value);
				}
			});
			var val = "?";
			if (vals.length > 0 && vals.length < 12) {
				val = vals.join(",");
			}else if(vals.length == 12){
				val = "*";
			}
			var item = $("input[name=v_mouth]");
			item.val(val);
			item.change();
		}
	});
	
	var weekList = $(".weekList").children();
	$("#week_appoint").click(function(){
		if(this.checked){
			weekList.eq(0).change();
		}
	});
	
	weekList.change(function() {
		var week_appoint = $("#week_appoint").prop("checked","checked");
		if (week_appoint) {
			var vals = [];
			weekList.each(function() {
				if (this.checked) {
					vals.push(this.value);
				}
			});
			var val = "?";
			if (vals.length > 0 && vals.length < 7) {
				val = vals.join(",");
			}else if(vals.length == 7){
				val = "*";
			}
			var item = $("input[name=v_week]");
			item.val(val);
			item.change();
		}
	});
});
(function($){
	$.getUrlParam = function(name){
		var reg = new RegExp("(^|&)"+name +"=([^&]*)(&|$)");
		var r= window.location.search.substr(1).match(reg);
		if (r!=null) return unescape(r[2]); 
		return null;
	}
})(jQuery);
var _cron_id = "";
$(document).ready(function(){
    var _freq=$.getUrlParam('freq');
	var _cron=$.getUrlParam('cron');
	var _current_freq = $.getUrlParam('current_freq');
	var _open=$.getUrlParam('open');
	_cron_id=$.getUrlParam('cron_id');
	if(!_freq||_freq.length<1){
	  _freq="day";
	}
	var content = $("#_"+_freq).html();
	var title = $("#_"+_freq).attr("name");
	$('#tab_content').tabs('select', title);
	var _tabs = $('#tab_content').tabs('tabs'); 
	if(_open!="open"){
		$.each(_tabs,function(n,_tab) {
		   var _tit = _tab.panel('options').title;
		   if(_tit!=title){
		      $('#tab_content').tabs('disableTab', n)
		   }
		});
	}
	if(!_cron||_cron.length<6||_cron=="undefined"){
		if(_freq == 'year'){
	    	_cron="0 0 0 1 1 ? *";
	    }else if(_freq == 'week'){
	    	_cron="0 0 0 ? * 1" ;
	    }else if(_freq == 'month'){
	    	_cron="0 0 0 1 1/1 ?";
	    }else if(_freq == 'day'){
	    	_cron="0 0 0 1/1 * ?";
	    }else if(_freq == 'hour'){
	    	_cron="0 0 0/1 * * ?" ;
	    }else{
	    	_cron="0 0 * * * ?" ;
	    }
	}else{
		if(_freq != _current_freq){
			if(_freq == 'year'){
		    	_cron="0 0 0 1 1 ? *";
		    }else if(_freq == 'week'){
		    	_cron="0 0 0 ? * 1" ;
		    }else if(_freq == 'month'){
		    	_cron="0 0 0 1 1/1 ?";
		    }else if(_freq == 'day'){
		    	_cron="0 0 0 1/1 * ?";
		    }else if(_freq == 'hour'){
		    	_cron="0 0 0/1 * * ?" ;
		    }else{
		    	_cron="0 0 * * * ?" ;
		    }
		}
	}
	
	$("#cron").val(_cron);
	btnFan(_freq);	
});