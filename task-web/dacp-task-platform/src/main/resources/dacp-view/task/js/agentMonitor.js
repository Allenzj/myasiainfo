//获取模板
var createTemplate=function(data){
	var agent=data["AGENT_NAME"];
	var ips = data["IPS"];
	var curips =   data["CURIPS"];
	var nodeStatus = data["NODE_STATUS"];
	var color = data["NODE_STATUS"]=="0"?"color:red":"";
	var ips = ips==undefined||ips==null?0:ips;
	var curips = curips==undefined||curips==null?0:curips;
	var finishRate = (curips*100/(ips==0?1:ips)).toFixed(1);
	var _tmp=''+
		 '<div style="width:180px; height:160px; float:left; margin:10px 10px;" >'+ 
		    '<div class="widget-content">'+
		      '<div class="file-upload">'+
				'<div class="thumbnail" >'+
                    '<div class="chart" title="'+agent+'" style="margin:0px auto" data-percent="' + finishRate + '%>">'+ finishRate +'%</div>'+
                    '<div class="chart-bottom-heading" title="'+agent+'" style="padding:0px auto;"><span class="label label-info" style="text-align:center;display:block;' + color + '">' + agent + '</span>'+
                    '</div>'+
        		    '<div style="text-align:center;" ><a href="javascript:void(0)" style="color:blue;" id="' + agent + '" onclick="StartAndStop(this.id,'+ nodeStatus +')">' + (nodeStatus=="1"?"停止":"启动") +'</a></div>'+
                '</div>'+
		      '</div>'+		     
		    '</div>'+
	    '</div>';
  return _.template(_tmp,{"agent":agent,"ips":ips,"curips":curips,"finishRate":finishRate});
};