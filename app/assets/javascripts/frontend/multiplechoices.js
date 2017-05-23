/**
 * Created with JetBrains RubyMine.
 * User: datnt
 * Date: 3/13/15
 * Time: 1:01 AM
 * To change this template use File | Settings | File Templates.
 */

//TODO: this need to be optimized more for speed
(function () {
    var attachEvent = document.attachEvent;
    var isIE = navigator.userAgent.match(/Trident/);
    var requestFrame = (function () {
        var raf = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame ||
            function (fn) {
                return window.setTimeout(fn, 20);
            };
        return function (fn) {
            return raf(fn);
        };
    })();

    var cancelFrame = (function () {
        var cancel = window.cancelAnimationFrame || window.mozCancelAnimationFrame || window.webkitCancelAnimationFrame ||
            window.clearTimeout;
        return function (id) {
            return cancel(id);
        };
    })();

    function resizeListener(e) {
        var win = e.target || e.srcElement;
        if (win.__resizeRAF__) cancelFrame(win.__resizeRAF__);
        win.__resizeRAF__ = requestFrame(function () {
            var trigger = win.__resizeTrigger__;
            trigger.__resizeListeners__.forEach(function (fn) {
                fn.call(trigger, e);
            });
        });
    }

    function objectLoad(e) {
        this.contentDocument.defaultView.__resizeTrigger__ = this.__resizeElement__;
        this.contentDocument.defaultView.addEventListener('resize', resizeListener);
    }

    window.addResizeListener = function (element, fn) {
        if (!element.__resizeListeners__) {
            element.__resizeListeners__ = [];
            if (attachEvent) {
                element.__resizeTrigger__ = element;
                element.attachEvent('onresize', resizeListener);
            }
            else {
                if (getComputedStyle(element).position == 'static') element.style.position = 'relative';
                var obj = element.__resizeTrigger__ = document.createElement('object');
                obj.setAttribute('style', 'display: block; position: absolute; top: 0; left: 0; height: 100%; width: 100%; overflow: hidden; pointer-events: none; z-index: -1;');
                obj.__resizeElement__ = element;
                obj.onload = objectLoad;
                obj.type = 'text/html';
                if (isIE) element.appendChild(obj);
                obj.data = 'about:blank';
                if (!isIE) element.appendChild(obj);
            }
        }
        element.__resizeListeners__.push(fn);
    };

    window.removeResizeListener = function (element, fn) {
        element.__resizeListeners__.splice(element.__resizeListeners__.indexOf(fn), 1);
        if (!element.__resizeListeners__.length) {
            if (attachEvent) element.detachEvent('onresize', resizeListener);
            else {
                element.__resizeTrigger__.contentDocument.defaultView.removeEventListener('resize', resizeListener);
                element.__resizeTrigger__ = !element.removeChild(element.__resizeTrigger__);
            }
        }
    }
})();

$(document).ready(function () {
    var isOverflow = function (element) {
        return element.offsetHeight < element.scrollHeight || element.offsetWidth < element.scrollWidth;
    }
    var adjustColumn = function (choice) {
        var context = $(choice).closest(".question-choices");
        var noOfChoices = $(context).data("choices");
        var maxNoOfColumns = 3;
        if(noOfChoices < 6)  {
            maxNoOfColumns = 2;
        }
        var lastWidth = $(context).data("lastWidth")
        var currentWidth = $(context).width();
        $(context).data("lastWidth", currentWidth);

        if ($(context).data('col')) {
            var col = parseInt($(context).data('col'));
            var overflow = isOverflow(choice);

            if (lastWidth) {
                if (currentWidth > lastWidth) {
                    $(context).attr('data-col', maxNoOfColumns);
                    $(context).data('col', maxNoOfColumns);
                }
                else {
                    if (col == 1) {
                        return;
                    }
                    else {
                        if (overflow) {
                            $(context).attr('data-col', col - 1);
                            $(context).data('col', col - 1);
                        }
                    }
                }
            }
        }
        else {
            $(context).attr('data-col', maxNoOfColumns);
            $(context).data('col', maxNoOfColumns);
        }
    }
//    var sensor = new ResizeSensor($('.pages'), function () {
//        console.log("resize");
//        adjustColumn();
//    });
    $(".question-choices .question-choice").each(function () {
        addResizeListener($(this)[0], function () {
            console.log("resize question");
            adjustColumn(this);
        });
    });

    //adjustColumn();
});