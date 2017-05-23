var App = function() {

    /* Helper variables - set in uiInit() */
    var page, pageContent, header, footer, sidebar, sScroll, sidebarAlt, sScrollAlt;

    /* Initialization UI Code */
    var uiInit = function() {

        // Set variables - Cache some often used Jquery objects in variables */
        page            = $('#page-container');
        pageContent     = $('#page-content');
        header          = $('header');
        footer          = $('#page-content + footer');

        sidebar         = $('#sidebar');
        sScroll         = $('#sidebar-scroll');

        sidebarAlt      = $('#sidebar-alt');
        sScrollAlt      = $('#sidebar-alt-scroll');

        // Resize #page-content to fill empty space if exists (also add it to resize and orientationchange events)
        resizePageContent();
        $(window).resize(function(){ resizePageContent(); });
        $(window).bind('orientationchange', resizePageContent);  
    };

    /* Resize #page-content to fill empty space if exists */
    var resizePageContent = function() {
        var windowH         = $(window).height();
        var sidebarH        = sidebar.outerHeight();
        var sidebarAltH     = sidebarAlt.outerHeight();
        var headerH         = header.outerHeight();
        var footerH         = footer.outerHeight();

        // If we have a fixed sidebar/header layout or each sidebars’ height < window height
        if (header.hasClass('navbar-fixed-top') || header.hasClass('navbar-fixed-bottom') || ((sidebarH < windowH) && (sidebarAltH < windowH))) {
            if (page.hasClass('footer-fixed')) { // if footer is fixed don't remove its height
                pageContent.css('min-height', windowH - headerH + 'px');
            } else { // else if footer is static, remove its height
                pageContent.css('min-height', windowH - (headerH + footerH) + 'px');
            }
        }  else { // In any other case set #page-content height the same as biggest sidebar's height
            if (page.hasClass('footer-fixed')) { // if footer is fixed don't remove its height
                pageContent.css('min-height', ((sidebarH > sidebarAltH) ? sidebarH : sidebarAltH) - headerH + 'px');
            } else { // else if footer is static, remove its height
                pageContent.css('min-height', ((sidebarH > sidebarAltH) ? sidebarH : sidebarAltH) - (headerH + footerH) + 'px');
            }
        }
    };

    return {
        init: function() {
            uiInit(); // Initialize UI Code

        },
        sidebar: function(mode, extra) {
       
        },
        datatables: function() {
            
        }
    };
}();

/* Initialize app when page loads */
$(function(){ App.init(); });