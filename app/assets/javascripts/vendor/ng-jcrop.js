/* global angular:true */
(function(angular){
    'use strict';

    angular.module('ngJcrop', [])

    .constant('ngJcroptDefaultConfig', {
        widthLimit: 1000,
        heightLimit: 1000,
        previewImgStyle: {'width': '100px', 'height': '100px', 'overflow': 'hidden', 'margin-left': '5px'},
        jcrop: {
            aspectRatio: 1,
            maxWidth: 300,
            maxHeight: 300
        }
    })

    .constant('ngJcropTemplate',
        '<div class="ng-jcrop">' +
        '    <div class="ng-jcrop-image-wrapper">' +
        '        <img class="ng-jcrop-image" />' +
        '   </div>' +
        '   <div class="ng-jcrop-thumbnail-wrapper" ng-style="previewImgStyle">' +
        '       <img class="ng-jcrop-thumbnail" />' +
        '   </div>' +
        '</div>'
    )

    .provider('ngJcropConfig', ['ngJcroptDefaultConfig', 'ngJcropTemplate', function(ngJcroptDefaultConfig, ngJcropTemplate){
        var config = angular.copy(ngJcroptDefaultConfig);
        config.template = ngJcropTemplate;

        return {
            setConfig: function(objConfig){
                angular.extend(config, objConfig);
            },
            setJcropConfig: function(objConfig){
                angular.extend(config.jcrop, objConfig);
            },
            setPreviewStyle: function(styleObject){
                angular.extend(config.previewImgStyle, styleObject);
            },
            $get: function(){
                return config;
            }
        };

    }])

    .run(['$window', function($window){
        if( !$window.jQuery ){
            throw new Error("jQuery isn't included");
        }

        if( !$window.jQuery.Jcrop ){
            throw new Error("Jcrop isn't included");
        }
    }])

    .directive('ngJcrop', ['ngJcropConfig', function(ngJcropConfig){

        return {
            restrict: 'A',
            scope: { ngJcrop: '=', thumbnail: '=', selection: '=' },
            template: ngJcropConfig.template,
            controller: 'JcropController'
        };

    }])

    .directive('ngJcropInput', function(){

        return {
            restrict: 'A',
            controller: 'JcropInputController'
        };

    })

    .controller('JcropInputController', ['$rootScope', '$element', '$scope',
    function($rootScope, $element, $scope){

        if( $element[0].type !== 'file' ){
            throw new Error('ngJcropInput directive must be placed with an input[type="file"]');
        }

        $scope.setImage = function(image){
            var reader = new FileReader();

            reader.onload = function(ev){
                $rootScope.$broadcast('JcropChangeSrc', ev.target.result);
                $element[0].value = '';
            };

            reader.readAsDataURL(image);
        };

        $element.on('change', function(ev){
            var image = ev.currentTarget.files[0];
            $scope.setImage(image);
        });

    }])

    .controller('JcropController', ['$scope', '$element', 'ngJcropConfig',
    function($scope, $element, ngJcropConfig){

        /* Checking the mandatory attributes */
        if( angular.isUndefined($scope.selection) ){
            throw new Error('ngJcrop: attribute `selection` is mandatory');
        } else if( !angular.isArray($scope.selection) && !($scope.selection === null)){
            throw new Error('ngJcrop: attribute `selection` must be an array');
        }

        /**
         * jquery element storing the main img tag
         * @type {jQuery}
         */
        $scope.mainImg = null;
        $scope.imgStyle = {'width': ngJcropConfig.jcrop.maxWidth, 'height': ngJcropConfig.jcrop.maxHeight};

        /**
         * jquery element storing the preview img tag
         * @type {jQuery}
         */
        $scope.previewImg = null;
        $scope.previewImgStyle = ngJcropConfig.previewImgStyle;

        /**
         * Stores the jcrop instance
         * @type {jCrop}
         */
        $scope.jcrop = null;

        /**
         * The coords of current selection
         * @type {Array}
         */
        $scope.coords = $scope.selection;

        /**
         * Updates the `imgStyle` with width and height
         * @param  {Image} img
         */
        $scope.updateCurrentSizes = function(img){
            var widthShrinkRatio = img.width / ngJcropConfig.jcrop.maxWidth,
                heightShrinkRatio = img.height / ngJcropConfig.jcrop.maxHeight,
                widthConstraining = img.width > ngJcropConfig.jcrop.maxWidth && widthShrinkRatio > heightShrinkRatio,
                heightConstraining = img.height > ngJcropConfig.jcrop.maxHeight && heightShrinkRatio > widthShrinkRatio;

            if (widthConstraining) {
                $scope.imgStyle.width = ngJcropConfig.jcrop.maxWidth;
                $scope.imgStyle.height = img.height / widthShrinkRatio;
            } else if (heightConstraining) {
                $scope.imgStyle.height = ngJcropConfig.jcrop.maxHeight;
                $scope.imgStyle.width = img.width / heightShrinkRatio;
            } else {
                $scope.imgStyle.height = img.height;
                $scope.imgStyle.width = img.width;
            }
        };

        /**
         * get the current shirnk ratio
         * @type {}
         */
        $scope.getShrinkRatio = function(){
            var img = $('<img>').attr('src', $scope.mainImg[0].src)[0];

            if(ngJcropConfig.jcrop.maxWidth > img.width || ngJcropConfig.jcrop.maxHeight > img.height){
                return 1;
            }

            var widthShrinkRatio = img.width / ngJcropConfig.jcrop.maxWidth,
                heightShrinkRatio = img.height / ngJcropConfig.jcrop.maxHeight,
                widthConstraining = img.width > ngJcropConfig.jcrop.maxWidth && widthShrinkRatio > heightShrinkRatio;

            if(widthConstraining) {
                return widthShrinkRatio;
            } else {
                return heightShrinkRatio;
            }
        };

        /**
         * set the `$scope.selection` and `$scope.originalSelection` variables
         * @param {object} coords An object like this: {x: 1, y: 1, x2: 1, y2: 1, w: 1, h: 1}
         * @param  {Image} img
         */
        $scope.setSelection = function(coords){
            if( !angular.isArray($scope.coords) ){
                $scope.coords = [];
            }

            if( !angular.isArray($scope.selection) ){
                $scope.selection = [];
            }

            $scope.coords[0] = coords.x;
            $scope.coords[1] = coords.y;
            $scope.coords[2] = coords.x2;
            $scope.coords[3] = coords.y2;
            $scope.coords[4] = coords.w;
            $scope.coords[5] = coords.h;

            var shrinkRatio = $scope.getShrinkRatio();
            $scope.selection[0] = Math.round(coords.x * shrinkRatio);
            $scope.selection[1] = Math.round(coords.y * shrinkRatio);
            $scope.selection[2] = Math.round(coords.x2 * shrinkRatio);
            $scope.selection[3] = Math.round(coords.y2 * shrinkRatio);
            $scope.selection[4] = Math.round(coords.w * shrinkRatio);
            $scope.selection[5] = Math.round(coords.h * shrinkRatio);
        };

        /**
         * Updates the preview regarding the coords form jCrop
         */
        $scope.showPreview = function(coords){
            if( !$scope.selectionWatcher ){
                $scope.$apply(function(){
                    $scope.setSelection(coords);
                });
            }

            if( !$scope.thumbnail ){
                return;
            }

            var rx = parseInt($scope.previewImgStyle.width) / coords.w;
            var ry = parseInt($scope.previewImgStyle.height) / coords.h;

            $scope.previewImg.css({
                width: Math.round(rx * $scope.imgStyle.width) + 'px',
                maxWidth: Math.round(rx * $scope.imgStyle.width) + 'px',
                height: Math.round(ry * $scope.imgStyle.height) + 'px',
                maxHeight: Math.round(ry * $scope.imgStyle.height) + 'px',
                marginLeft: '-' + Math.round(rx * coords.x) + 'px',
                marginTop: '-' + Math.round(ry * coords.y) + 'px'
            });
        };

        /**
         * @event
         */
        $scope.onMainImageLoad = function(){
            $scope.mainImg.off('load', $scope.onMainImageLoad);
            $scope.updateCurrentSizes($('<img>').attr('src', $scope.mainImg[0].src)[0]);

            var config = angular.extend({
                onChange: $scope.showPreview,
                onSelect: $scope.showPreview
            }, ngJcropConfig.jcrop);

            if( $scope.selection && $scope.selection.length === 6 ){
                config.setSelect = $scope.selection;
            }

            $scope.jcrop = jQuery.Jcrop($scope.mainImg, config);
        };

        /**
         * Destroys the current jcrop instance
         */
        $scope.destroy = function(){
            if( $scope.jcrop ){
                if( $scope.mainImg ){ $scope.mainImg.off('load'); }
                $scope.jcrop.destroy();
                $scope.jcrop = null;
            }
        };


        /**
         * @init main image
         */
        $scope.initMainImage = function(src){
            $scope.mainImg = $('<img>').addClass('ng-jcrop-image');
            $scope.mainImg.on('load', $scope.onMainImageLoad);
            $scope.mainImg.css({ maxWidth: ngJcropConfig.jcrop.maxWidth, maxHeight: ngJcropConfig.jcrop.maxHeight });
            $scope.mainImg.attr('src', src);
        };

        /**
         * @init
         */
        $scope.init = function(src){
            $scope.destroy();

            $scope.initMainImage(src);

            $scope.imageWrapper = $element.find('.ng-jcrop-image-wrapper');
            $scope.imageWrapper.empty().append($scope.mainImg);

            $scope.previewImg = $element.find('.ng-jcrop-thumbnail');
            $scope.previewImg.attr('src', src);
        };

        $scope.$on('$destroy', $scope.destroy);

        $scope.$on('JcropChangeSrc', function(ev, src){

            $scope.$apply(function(){
                $scope.setSelection({
                    x: 0,
                    y: 0,
                    x2: ngJcropConfig.widthLimit,
                    y2: ngJcropConfig.heightLimit,
                    w: ngJcropConfig.widthLimit,
                    h: ngJcropConfig.heightLimit
                });

                $scope.ngJcrop = src;
            });
        });

        $scope.$watch('ngJcrop', function(newValue, oldValue, scope){
            scope.init(newValue);
        });

        $scope.$watch('thumbnail', function(newValue, oldValue, scope){
            if( scope.thumbnail ){
                $scope.previewImg.show();
            } else {
                $scope.previewImg.hide();
            }
        });

    }]);


})(angular);
