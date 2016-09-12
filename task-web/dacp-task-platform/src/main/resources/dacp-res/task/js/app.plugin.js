+function ($) { 
	"use strict";
	
	$(function(){		
 	$(document).on('click', '[data-ride="collapse"] a',
		function(e) {
			var $this = $(e.target),
			$active;
			$this.is('a') || ($this = $this.closest('a'));
			$active = $this.parent().siblings(".active");
			$active && $active.toggleClass('active').find('> ul:visible').slideUp(200); ($this.parent().hasClass('active') && $this.next().slideUp(200)) || $this.next().slideDown(200);
			$this.parent().toggleClass('active');
			$this.next().is('ul') && e.preventDefault();
			setTimeout(function() {
				$(document).trigger('updateNav');
			},
			300);
		});
 $("#searchbtn").click(function(){
 	   var keyword = $("#searchkeyword").val();
  	  if(!keyword) return false;
  	  var newhref='asiainfo/gojs/search.html?keyword='+keyword;
        if(!$("#framecontent")){///��iframe
   	  		$("#content .vbox").empty() 
   	   	   $('<iframe id="framecontent" src="about:blank" width="100%" height="100%" frameborder="0" border="0" marginwidth="0" marginheight="0" ></iframe>').appendTo($("#content .vbox"));
   	   	 
   	   	} 
         if($("#framecontent")){
         	
         	$("#framecontent").attr("src",newhref);
          
        };
   	  	return false; 
});
  $("#searchkeyword").keydown(function(e){
  	  if (e.keyCode == 13) {
  	  	 e.preventDefault();  
  	  	 var keyword = $("#searchkeyword").val();
  	  	
         if(!keyword) return false;
         var newhref='asiainfo/gojs/search.html?keyword='+keyword;
         
         if($("#framecontent")){
         	
         	$("#framecontent").attr("src",newhref);
         	alert(newhref);
        };
   	  	return false; 
      }
     
  });
  
  
	// sparkline
	var sr, sparkline = function($re){
		$(".sparkline").each(function(){
			var $data = $(this).data();
			if($re && !$data.resize) return;
			($data.type == 'pie') && $data.sliceColors && ($data.sliceColors = eval($data.sliceColors));
			($data.type == 'bar') && $data.stackedBarColor && ($data.stackedBarColor = eval($data.stackedBarColor));
			$data.valueSpots = {'0:': $data.spotColor};
			$(this).sparkline('html', $data);
		});
	};
	$(window).resize(function(e) {
		clearTimeout(sr);
		sr = setTimeout(function(){sparkline(true)}, 500);
	});
	sparkline(false);

	// easypie
	var easypie = function(){
	$('.easypiechart').each(function(){
		var $this = $(this), 
		$data = $this.data(), 
		$step = $this.find('.step'), 
		$target_value = parseInt($($data.target).text()),
		$value = 0;
		$data.barColor || ( $data.barColor = function($percent) {
	        $percent /= 100;
	        return "rgb(" + Math.round(200 * $percent) + ", 200, " + Math.round(200 * (1 - $percent)) + ")";
	    });
		$data.onStep =  function(value){
			$value = value;
			$step.text(parseInt(value));
			$data.target && $($data.target).text(parseInt(value) + $target_value);
		}
		$data.onStop =  function(){
			$target_value = parseInt($($data.target).text());
			$data.update && setTimeout(function() {
		        $this.data('easyPieChart').update(100 - $value);
		    }, $data.update);
		}
			$(this).easyPieChart($data);
		});
	};
	easypie();
  
	// datepicker
	$(".datepicker-input").each(function(){ $(this).datepicker();});

	// dropfile
	$('.dropfile').each(function(){
		var $dropbox = $(this);
		if (typeof window.FileReader === 'undefined') {
		  $('small',this).html('File API & FileReader API not supported').addClass('text-danger');
		  return;
		}

		this.ondragover = function () {$dropbox.addClass('hover'); return false; };
		this.ondragend = function () {$dropbox.removeClass('hover'); return false; };
		this.ondrop = function (e) {
		  e.preventDefault();
		  $dropbox.removeClass('hover').html('');
		  var file = e.dataTransfer.files[0],
		      reader = new FileReader();
		  reader.onload = function (event) {
		  	$dropbox.append($('<img>').attr('src', event.target.result));
		  };
		  reader.readAsDataURL(file);
		  return false;
		};
	});

	// slider
	$('.slider').each(function(){
		$(this).slider();
	});

	// sortable
	if ($.fn.sortable) {
	  $('.sortable').sortable();
	}

	// slim-scroll
	$('.no-touch .slim-scroll').each(function(){
		var $self = $(this), $data = $self.data(), $slimResize;
		$self.slimScroll($data);
		$(window).resize(function(e) {
			clearTimeout($slimResize);
			$slimResize = setTimeout(function(){$self.slimScroll($data);}, 500);
		});
    $(document).on('updateNav', function(){
      $self.slimScroll($data);
    });
	});	

	// portlet
	$('.portlet').each(function(){
		$(".portlet").sortable({
	        connectWith: '.portlet',
            iframeFix: false,
            items: '.portlet-item',
            opacity: 0.8,
            helper: 'original',
            revert: true,
            forceHelperSize: true,
            placeholder: 'sortable-box-placeholder round-all',
            forcePlaceholderSize: true,
            tolerance: 'pointer'
	    });
    });

	// docs
  $('#docs pre code').each(function(){
	    var $this = $(this);
	    var t = $this.html();
	    $this.html(t.replace(/</g, '&lt;').replace(/>/g, '&gt;'));
	});

	// table select/deselect all
	$(document).on('change', 'table thead [type="checkbox"]', function(e){
		e && e.preventDefault();
		var $table = $(e.target).closest('table'), $checked = $(e.target).is(':checked');
		$('tbody [type="checkbox"]',$table).prop('checked', $checked);
	});

	// random progress
	$(document).on('click', '[data-toggle^="progress"]', function(e){
		e && e.preventDefault();

		var $el = $(e.target),
		$target = $($el.data('target'));
		$('.progress', $target).each(
			function(){
				var $max = 50, $data, $ps = $('.progress-bar',this).last();
				($(this).hasClass('progress-xs') || $(this).hasClass('progress-sm')) && ($max = 100);
				$data = Math.floor(Math.random()*$max)+'%';
				$ps.css('width', $data).attr('data-original-title', $data);
			}
		);
	});
	
	// add notes
	function addMsg($msg){
		var $el = $('.nav-user'), $n = $('.count:first', $el), $v = parseInt($n.text());
		$('.count', $el).fadeOut().fadeIn().text($v+1);
		$($msg).hide().prependTo($el.find('.list-group')).slideDown().css('display','block');
	}
	var $msg = '<a href="#" class="media list-group-item">'+
                  '<span class="pull-left thumb-sm text-center">'+
                    '<i class="fa fa-envelope-o fa-2x text-success"></i>'+
                  '</span>'+
                  '<span class="media-body block m-b-none">'+
                    'Sophi sent you a email<br>'+
                    '<small class="text-muted">1 minutes ago</small>'+
                  '</span>'+
                '</a>';	
  setTimeout(function(){addMsg($msg);}, 1500);

	//chosen
	$(".chosen-select").length && $(".chosen-select").chosen();
	
    $(document).on('click', '[data-toggle="ajaxModal"]',
        function(e) {
            $('#ajaxModal').remove();
            e.preventDefault();
            var $this = $(this),
            $remote = $this.data('remote') || $this.attr('href'),
            $modal = $('<div class="modal fade" id="ajaxModal"><div class="modal-body"></div></div>');
            $('body').append($modal);
            $modal.modal();
            $modal.load($remote);
        });
        
     var Bjax = function(element, options) {
        this.options = options;
        this.targetId=this.options.target;
        this.$element = $(this.options.target || 'html');
        this.start()
    }
    Bjax.DEFAULTS = {
        backdrop: true,
        url: ''
    }
    Bjax.prototype.start = function() {
        var that = this;
        this.backdrop();
        $.ajax(this.options.url).done(function(r) {
        	 $(that.targetId).empty();
        	//console.log(r);
        	 $(that.targetId).append(r);
           // that.$element = r;
            //that.complete();
        });

    }
    Bjax.prototype.complete = function() {
        /*var that = this;
        if (this.$element.is('html') || (this.options.replace)) {
            try {
                window.history.pushState({},
                '', this.options.url);
            } catch(e) {
                window.location.replace(this.options.url)
            }
        }*/
        this.updateBar(100);
    }
    Bjax.prototype.backdrop = function() {
        this.$element.css('position', 'relative') ;
        this.$backdrop = $('<div class="backdrop fade bg-white"></div>').appendTo(this.$element);
        if (!this.options.backdrop) this.$backdrop.css('height', '2');
        this.$backdrop[0].offsetWidth;
        this.$backdrop.addClass('in');
        this.$bar = $('<div class="bar b-t b-2x b-info"></div>').width(0).appendTo(this.$backdrop);
    }
    Bjax.prototype.update = function() {
        $(this.$element).css('position', '');
        if (!$(this.$element).is('html')) {
            if (this.options.el) {
                this.$content = $(this.$content).find(this.options.el);
            }
           $( this.$element).html(this.$content);
        }
        if ($(this.$element).is('html')) {
            if ($('.ie').length) {
                location.reload();
                return;
            }
            document.open();
            document.write(this.$content);
            document.close();
        }
    }
    Bjax.prototype.updateBar = function(per) {
        var that = this;
        this.$bar.stop().animate({
            width: per + '%'
        },
        500, 'linear',
        function() {
            if (per == 100) that.update();
        });
    }
    Bjax.prototype.enable = function(e) {
        var link = e.currentTarget;
        if (location.protocol !== link.protocol || location.hostname !== link.hostname) return false
        if (link.hash && link.href.replace(link.hash, '') === location.href.replace(location.hash, '')) return false
        if (link.href === location.href + '#' || link.href === location.href) return false
        if (link.protocol.indexOf('http') == -1) return false
        return true;
    }
    $.fn.bjax = function(option) {
        return this.each(function() {
            var $this = $(this);
            var data = $this.data('app.bjax');
            var options = $.extend({},
            Bjax.DEFAULTS, $this.data(), typeof option == 'object' && option);
             if (!data) $this.data('app.bjax', (data = new Bjax(this, options))) ;
             if (data) data['start']();
             if (typeof option == 'string') data[option]();
        })
    }
    $.fn.bjax.Constructor = Bjax;
     $(window).on("popstate",
    function(e) {
        if (e.originalEvent.state !== null) {
            window.location.reload(true);
        }
        e.preventDefault();
    });
     $(document).on('click.app.bjax.data-api', '[data-bjax], .nav-primary a',
    function(e) {
        if (!Bjax.prototype.enable(e)) return;
        $(this).bjax({
            url: $(this).attr('href') || $(this).attr('data-url'),
            target:$(this).attr('data-target')
        });
        e.preventDefault();
    })
  });
}(window.jQuery);