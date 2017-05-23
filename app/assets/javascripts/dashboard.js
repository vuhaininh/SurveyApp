i18n.init({ lng: window.lang, resGetPath: '/locale/__lng__/__ns__.json' });
$(function () {
if (window.location.pathname.indexOf("questions") > 0)
	FormsValidation.init();
    Chart.defaults.global.animationSteps = 20;
    // Chart.defaults.global.animationEasing = "easeInOut";
    // Chart.defaults.global.animation = false;
    Chart.defaults.global.responsive = true;
    Chart.defaults.global.scaleFontColor = "#999";
    Chart.defaults.global.scaleFontFamily = "'Exo 2', 'Ubuntu', 'Segoe UI', 'Droid Sans', Tahoma, san-serif";
    $('.pie-canvas').each(function (index) {
        $this = $(this);
        var ctx = this.getContext("2d");

        var data = $this.data('chart');

        var chart = new Chart(ctx).Pie(data);

        var desc = $('.pie-description[data-question="' + $this.data('question') + '"]');
        var a = $this.closest(".question").find('.pie-legend');
        legend(a, data);
    });
    $('.bar-canvas').each(function (index) {
        $this = $(this);

        var ctx = this.getContext("2d");

        var chart = new Chart(ctx).Bar($this.data('chart'));
    });
	
	$('.step-menu').click(function() {
		$(this).addClass('active').siblings().removeClass('active');
	});

    function legend(parent, data) {
        $parent = $(parent);
        $parent.addClass("legend");
        var datas = data.hasOwnProperty('datasets') ? data.datasets : data;

        $parent.empty();

        datas.forEach(function (d) {
            var title = document.createElement('span');
            title.className = 'title';

            var colorSample = document.createElement('div');
            colorSample.className = 'color-sample';
            colorSample.style.backgroundColor = d.hasOwnProperty('strokeColor') ? d.strokeColor : d.color;
            colorSample.style.borderColor = d.hasOwnProperty('fillColor') ? d.fillColor : d.color;
            title.appendChild(colorSample);

            var text = document.createTextNode(d.label);
            title.appendChild(text);

            var valueHolder = document.createElement('span');
            valueHolder.className = 'value-holder';
            var val = document.createTextNode("  " + d.value);
            valueHolder.appendChild(val);
            title.appendChild(valueHolder);

            $parent.append(title);
        });
    }
	
	$(".survey-reset").click(function(e){
		e.preventDefault();
        e.stopPropagation();
		var form = $(this).siblings( ".reset-form" );
		bootbox.confirm(i18n.t("resetSurveyMessage"), function(result) {
			if (result)
				form.submit();
		}); 	
	});
	$(".survey-delete").click(function(e){
		e.preventDefault();
        e.stopPropagation();
		var form = $(this).siblings( ".delete-form" );
		bootbox.confirm(i18n.t("removeSurveyMessage"), function(result) {
			if (result)
				form.submit();
		}); 	
	});
	
	$(".survey-stop").click(function(e){
		e.preventDefault();
        e.stopPropagation();
		var form = $(this).siblings( ".stop-form" );
		bootbox.confirm(i18n.t("closeSurveyMessage"), function(result) {
			if (result)
				form.submit();
		}); 	
	});
	$(".survey-enable").click(function(e){
		e.preventDefault();
        e.stopPropagation();
		var form = $(this).siblings( ".enable-form" );
		bootbox.confirm(i18n.t("reactiveSurveyMessage"), function(result) {
			if (result)
				form.submit();
		}); 	
	});

    $('.input-datepicker-close').datepicker({weekStart: 1}).on('changeDate', function(e){ $(this).datepicker('hide'); });
    $('.select-chosen').chosen({width: "100%"});
    $(document).on('click', '[data-toggle="link"]', function(){
        var $this = $(this);
        var link = $this.attr('data-link');
        window.location = link;
    });

    Dropzone.options.uploadForm = {
        paramName: "file", // The name that will be used to transfer the file
        maxFilesize: 2,
        previewsContainer: '.dropzone-previews',
        addedfile: function(file) {
            file.previewElement = Dropzone.createElement(this.options.previewTemplate);
            $(this.options.previewsContainer).append(file.previewElement);
        }
    };
});