var directives = angular.module('suvi.directive', []);
directives.directive('suviInputTag', ['$timeout', function ($timeout) {
    return {
        restrict: 'AE',
        scope: {
            model: "=ngModel"
        },
        link: function (scope, element, attrs) {
            var ele = element.context;
            var onTagChange = function () {
                console.log("input changed");
                scope.$apply(function () {
                    scope.model = $(ele).val();
                });
            };
            $timeout(function () {
                $(ele).tagsInput({
                    width: 'auto',
                    height: 'auto',
                    onChange: onTagChange
                });
            }, 1);
        }
    }
}]);
directives.directive('suviJcrop', ['$timeout', function ($timeout) {
    return {
        restrict: 'AE',
        scope: {
            image: "=ngfThumbnail"
        },
        link: {
            post: function (scope, element, attrs) {
                var ele = element.context;
                var image = scope.image;
                scope.$watch("image", function (value, oldValue) {
                    $(ele).load(function () {
                        $timeout(function () {
                            var h = $(ele).height();
                            var w = $(ele).width();
                            var size = h > w ? w : h;
                            $(ele).Jcrop({
                                aspectRatio: 1,
                                bgColor: 'black',
                                bgOpacity: .4,
                                setSelect: [ 0, 0, size, size ]
                            });
                        }, 10);
                    });
                });
            }
        }
    }
}]);