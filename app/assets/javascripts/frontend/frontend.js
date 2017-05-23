/*! Normalized address bar hiding for iOS & Android (c) @scottjehl MIT License */
(function (win) {
    var doc = win.document;

    // If there's a hash, or addEventListener is undefined, stop here
    if (!win.navigator.standalone && !location.hash && win.addEventListener) {

        //scroll to 1
        win.scrollTo(0, 1);
        var scrollTop = 1,
            getScrollTop = function () {
                return win.pageYOffset || doc.compatMode === "CSS1Compat" && doc.documentElement.scrollTop || doc.body.scrollTop || 0;
            },

        //reset to 0 on bodyready, if needed
            bodycheck = setInterval(function () {
                if (doc.body) {
                    clearInterval(bodycheck);
                    scrollTop = getScrollTop();
                    win.scrollTo(0, scrollTop === 1 ? 0 : 1);
                }
            }, 15);

        win.addEventListener("load", function () {
            setTimeout(function () {
                //at load, if user hasn't scrolled more than 20 or so...
                if (getScrollTop() < 20) {
                    //reset to hide addr bar at onload
                    win.scrollTo(0, scrollTop === 1 ? 0 : 1);
                }
            }, 0);
        }, false);
    }
})(this);

$(document).ready(function () {
    var autoRepeat = window.autoRepeat;
    var autoRepeatInterval = window.autoRepeatInterval * 60;
    var redirectUrl = window.redirectUrl;
    var mySwipe = document.body;

    // create a simple instance
    // by default, it only adds horizontal recognizers
    var mc = new Hammer(mySwipe);

    var $pages = $('.pages');
    var total = $('.page').length;
    var current = parseInt($pages.data('index'));
    var isStart = function () {
        return current == 1;
    };
    $('#order').empty();
    var sub_total = total - 1;
    $('#order').text("#" + current + "/" + sub_total);

    function scrollPage(target, isNext) {
        $element = $('.pages .page[data-index="' + target + '"]');
        $currentElement = $('.pages .page.active')
        $currentElement.removeClass('active').addClass('inactive');
        if (isNext) {
            $element.removeClass('animation-fadeInRight').addClass('animation-fadeInLeft');
        }
        else
            $element.removeClass('animation-fadeInLeft').addClass('animation-fadeInRight');
        $element.removeClass('inactive').addClass('active');
        $element.addClass("resize");
        setTimeout(function () {
            $element.removeClass("resize");
        }, 100);
        current = target;
        $('#order').text(current + "/" + sub_total);
        $('.svipk-progress').css('width', current * 100.0 / total + '%');
    }

    scrollPage($pages.data('index'), true);

    function scrollBack() {
        if (current != 1 && current != total)
            scrollPage(current - 1, false);
    }

    function scrollNext() {
        if (current + 1 < total) {
            scrollPage(current + 1, true);
        }
        else {
            $('.btn-submit').click();
        }
    }

    function initClock() {
        return new FlipClock($('.clock'), autoRepeatInterval, {
            clockFace: 'Counter',
            callbacks: {
                interval: function () {
                    var time = this.factory.getTime();
                    //console.log("interval - time: " + time);
                    if (!isStart() && time == 0) {
                        $('.btn-submit').click();
                    }

                },
                stop: function () {
                    //console.log("Stop timer");
                    this.factory.setTime(autoRepeatInterval);
                    this.factory.setCountdown(true);
                    this.factory.start();
                },
                reset: function () {
                    //console.log("reset");
                    this.factory.setCountdown(true);
                }
            },
            autoStart: true,
            countdown: true
        });
    };
    function resetClock() {
        if(autoRepeat){
            clock.reset();
        }
    }
    if (autoRepeat) {
        var clock = initClock();

        $('input[type="text"], textarea').on('keydown', function () {
            //console.log("Text changed");
            resetClock();
        });
        $(document).on('click', '.js-back, .js-next, .btn-recheck, .js-home, js-submit', function () {
            resetClock();
            console.log("reset");
        })
    }
//    $(':radio').mousedown(function(e){
//        var $self = $(this);
//        if( $self.is(':checked') ){
//            var uncheck = function(){
//                setTimeout(function(){$self.removeAttr('checked');},0);
//            };
//            var unbind = function(){
//                $self.unbind('mouseup',up);
//            };
//            var up = function(){
//                uncheck();
//                unbind();
//            };
//            $self.bind('mouseup',up);
//            $self.one('mouseout', unbind);
//        }
//    });

    $('.input-radio, .star-radio, .smiley-radio').on('click', function (e) {
        var time = 500;
        if(autoRepeat){
            resetClock();
        }
        setTimeout(scrollNext, time);
    });

    $('.js-back').on('click', function (e) {
        scrollBack();
    });

    $('.js-next').on('click', function (e) {
        scrollNext();
    });

    $('.btn-recheck').on('click', function (e) {
        scrollPage(1, false);
    });

    $('.js-home').on('click', function (e) {
        scrollPage(0, false);
    });

    mc.on("swiperight", function (ev) {
        scrollBack();
    });
    mc.on("swipeleft", function (ev) {
        scrollNext();
    });

    function reload() {
        $("input:reset").click();
        if(autoRepeat) {
        scrollPage(1, false);
        }
    }

    $('.btn-submit').click(function (e) {
        e.preventDefault();
        scrollPage(total, true);
        $form = $('#feedback-form');

        $.post($form.attr('href'), $form.serialize(),function (data) {
            $('#order').empty();
            setTimeout(function () {
                if(redirectUrl){
                    window.location.replace(redirectUrl);
                }
                else{
                    reload();
                }
            }, 3000);
        }).error(function (e) {
            });
    });
    function toggleFullScreen(elem) {
        // ## The below if statement seems to work better ## if ((document.fullScreenElement && document.fullScreenElement !== null) || (document.msfullscreenElement && document.msfullscreenElement !== null) || (!document.mozFullScreen && !document.webkitIsFullScreen)) {
        if ((document.fullScreenElement !== undefined && document.fullScreenElement === null) || (document.msFullscreenElement !== undefined && document.msFullscreenElement === null) || (document.mozFullScreen !== undefined && !document.mozFullScreen) || (document.webkitIsFullScreen !== undefined && !document.webkitIsFullScreen)) {
            if (elem.requestFullScreen) {
                elem.requestFullScreen();
            } else if (elem.mozRequestFullScreen) {
                elem.mozRequestFullScreen();
            } else if (elem.webkitRequestFullScreen) {
                elem.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT);
            } else if (elem.msRequestFullscreen) {
                elem.msRequestFullscreen();
            }
        } else {
            if (document.cancelFullScreen) {
                document.cancelFullScreen();
            } else if (document.mozCancelFullScreen) {
                document.mozCancelFullScreen();
            } else if (document.webkitCancelFullScreen) {
                document.webkitCancelFullScreen();
            } else if (document.msExitFullscreen) {
                document.msExitFullscreen();
            }
        }
    }
    $('.btn-full-screen').click(function(){
        toggleFullScreen(document.body);
    });
    toggleFullScreen(document.body)
});
$(window).load(function () {
    $('.spinner').hide();
});