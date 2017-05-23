var surveyApp = angular.module("SurveyApp", ['ui.sortable', 'ui.select', 'ngSanitize', 'suvi.directive', 'ui.bootstrap', 'ngFileUpload']);

surveyApp.run(["$rootScope", "questionTypes", "questionOptions", function ($rootScope, questionTypes, questionOptions) {
    $rootScope.QUESTION_TYPES = questionTypes;
    $rootScope.QUESTION_OPTIONS = questionOptions;
    $("#question_type").change(function () {
        var question_type = $(this);
        var scope = angular.element(question_type).scope();
        scope.$apply(function () {
            scope.questionType = question_type.val();
        })
    });
}]);
surveyApp.factory("customUrl", ["$http", "$q", function ($http, $q) {
    var isCustomUrlAvailable = function (customUrl, currentSurveyId) {
        var req = {
            method: 'POST',
            url: '/dashboard/check_custom_url',
            headers: {
                'Content-Type': 'application/json'
            },
            data: { url: customUrl, survey_index: currentSurveyId }
        }
        var deferred = $q.defer();
        $http(req).success(function (value) {
            deferred.resolve(value === "true");
        });
        return deferred.promise;
    };
    return {
        isCustomUrlAvailable: isCustomUrlAvailable
    };
}]);

surveyApp.factory("surveyService", ["$http", "$q", function ($http, $q) {
    var getAllQuestionsForSurvey = function (surveyId) {
        var req = {
            method: 'GET',
            url: '/dashboard/survey/' + surveyId + '/questions',
            headers: {
                'Content-Type': 'application/json'
            },
            data: {survey_id: surveyId }
        }
        var deferred = $q.defer();
        $http(req).success(function (value) {
            deferred.resolve(value);
        });
        return deferred.promise;
    };

    var updateQuestion = function (updateRequest) {
        var req = {
            method: 'POST',
            url: '/dashboard/survey/' + updateRequest.surveyId + '/question/' + updateRequest.question.questionIndex + '/edit',
            headers: {
                'Content-Type': 'application/json'
            },
            data: updateRequest
        }
        var deferred = $q.defer();
        $http(req).success(function (value) {
            deferred.resolve(value);
        });
        return deferred.promise;
    };

    var deleteQuestion = function (deleteRequest) {
        var req = {
            method: 'GET',
            url: '/dashboard/survey/' + deleteRequest.surveyId + '/question/' + deleteRequest.questionIndex + '/delete',
            headers: {
                'Content-Type': 'application/json'
            },
            data: deleteRequest
        }
        var deferred = $q.defer();
        $http(req).success(function (value) {
            deferred.resolve(value);
        });
        return deferred.promise;
    }

    var updateQuestionOrder = function (updateQuestionIndexRequest) {
        var req = {
            method: 'POST',
            url: '/dashboard/survey/' + updateQuestionIndexRequest.surveyId + '/updateOrder',
            headers: {
                'Content-Type': 'application/json'
            },
            data: updateQuestionIndexRequest
        }
        var deferred = $q.defer();
        $http(req).success(function (value) {
            deferred.resolve(value);
        });
        return deferred.promise;
    };
    return {
        getAllQuestionsForSurvey: getAllQuestionsForSurvey,
        updateQuestion: updateQuestion,
        deleteQuestion: deleteQuestion,
        updateQuestionOrder: updateQuestionOrder
    };
}]);


surveyApp.controller("SurveyCreateController", ['$scope', '$window', 'customUrl', function ($scope, $window, customUrl) {
    $scope.autoRepeat = true;
    $scope.autoRepeatInterval = 10;
    $scope.fullScreenOnOpen = false;
    $scope.isCustomUrlAvailable = null;
    $scope.customUrl = null;

    $scope.checkCustomUrlAvailability = function () {
        customUrl.isCustomUrlAvailable($scope.customUrl).then(function (value) {
            $scope.isCustomUrlAvailable = value;
            console.log("success");
        });
    };
}]);
surveyApp.controller("SurveyEditController", ['$scope', '$window', 'customUrl', function ($scope, $window, customUrl) {
    $scope.edit_survey_name = $("#survey_name").val();
    $scope.edit_survey_description = $("#survey_description").val();
    $scope.survey_custom_url = $("#survey_custom_url").val();
    $scope.survey_index = $("#survey_index").val();
    $scope.isCustomUrlAvailable = null;
    $scope.autoRepeat = $("#autoRepeat").val() === 'true' ? true : false;
    $scope.autoRepeatInterval = $("#autoRepeatInterval").val();
    $scope.checkCustomUrlAvailability = function () {
        customUrl.isCustomUrlAvailable($scope.customUrl, $scope.survey_index).then(function (value) {
            $scope.isCustomUrlAvailable = value;
            console.log("success");
        });
    };
}]);

surveyApp.controller('QuestionCreateController', ['$scope', function ($scope) {
    $scope.questionType = undefined;
    $scope.multipleSelection = undefined;
}]);
surveyApp.controller('ImageQuestionCreateController', ['$scope', '$timeout', 'Upload', '$modal', function ($scope, $timeout, Upload, $modal) {
    function ImageInfo() {
        var self = this;
        self.label = null;
        self.file = null;
        self.cacheId = null;
    }

    $scope.images = [];
    $scope.displayLabel = true;
    $scope.allowMultipleSelection = false;
    $scope.fileToUpload = null;
    $scope.sortableOptions = {
        update: function (e, ui) {
            console.log("Move from " + ui.item.sortable.index + " to" + ui.item.sortable.dropindex)
        }
    };
    $scope.$watch('fileToUpload', function () {
        console.log('Change');
        if ($scope.fileToUpload && $scope.fileToUpload.length && $scope.fileToUpload[0]) {
            var newImage = new ImageInfo();
            newImage.file = $scope.fileToUpload;
            $scope.images.push(newImage)
            $scope.upload(newImage);
            $timeout(function () {
                $scope.fileToUpload = null;
            }, 0, false);
        }
    });
    $scope.upload = function (imageInfo) {
        Upload.upload({
                url: '/dashboard/uploadOptionImage',
                file: imageInfo.file
            }).progress(function (evt) {

            }).success(function (data, status, headers, config) {
                imageInfo.cacheId = data;
            });
    }
    $scope.addNewImage = function () {
        $scope.images.push(new ImageInfo())
    };
    $scope.deleteImage = function () {
        console.log("delete image");
    }
    $scope.editImage = function(image){
        var modalInstance = $modal.open({
            templateUrl: 'editImageModal.html',
            controller: "EditImageController",
            resolve: {
                image: function(){
                    return image;
                }
            }
        });
        modalInstance.result.then(function (question) {
        });
    }
}]);
surveyApp.constant('questionTypes', {
    STAR_RATING: 1,
    MULTIPLE_CHOICES: 2,
    TEXT_INPUT: 3,
    SMILE_FACE: 4,
    IMAGE: 5,
    INFO: 6
});

surveyApp.constant('questionOptions', [
    {
        id: 1,
        description: 'Star Rating'
    },
    {
        id: 2,
        description: 'Multiple choices questions'
    },
    {
        id: 3,
        description: 'Text input question'
    },
    {
        id: 4,
        description: 'Smiley faces'
    },
    {
        id: 6,
        description: 'Information page'
    }
]);
surveyApp.controller('DeleteQuestionController', ['$scope', '$modalInstance', 'question', function ($scope, $modalInstance, question) {
    $scope.question = question;
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
    $scope.ok = function () {
        $modalInstance.close($scope.question);
    };
}]);

surveyApp.controller('EditImageController', ['$scope', '$modalInstance', 'image', function ($scope, $modalInstance, image) {
    $scope.image = image;
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
    $scope.ok = function () {
        $modalInstance.close($scope.image);
    };
}]);

surveyApp.controller('QuestionListController', ['$scope', '$window', 'surveyService', '$modal', function ($scope, $window, surveyService, $modal) {
    $scope.surveyId = $window.surveyId;
    surveyService.getAllQuestionsForSurvey($scope.surveyId).then(function (response) {
        $scope.questions = response;
    });
    $scope.delete = function (question) {
        var modalInstance = $modal.open({
            templateUrl: 'deleteQuestionModal.html',
            controller: "DeleteQuestionController",
            resolve: {
                question: function () {
                    return question;
                }
            }
        });
        modalInstance.result.then(function (question) {
            var questionIndex = question.questionIndex
            console.log("Good already " + questionIndex);
            surveyService.deleteQuestion({surveyId: $scope.surveyId, questionIndex: questionIndex}).then(function (value) {
                $scope.questions.splice(questionIndex - 1, 1)
                toastr.success(i18n.t("questionDeleted"));
            });
        });
    };

    $scope.sortableOptions = {
        update: function (e, ui) {
            console.log("Move from " + ui.item.sortable.index + " to" + ui.item.sortable.dropindex)
            var movingQuestion = $scope.questions[ui.item.sortable.index];

            movingQuestion.ordering = true;

            surveyService.updateQuestionOrder({
                surveyId: $scope.surveyId,
                currentIndex: ui.item.sortable.index + 1,
                targetIndex: ui.item.sortable.dropindex + 1
            }).then(function () {
                    movingQuestion.ordering = false;
                });
        }
    };
}]);
surveyApp.controller('QuestionEditController', ['$scope', '$window', 'surveyService', function ($scope, $window, surveyService) {
    $scope.updateQuestion = function () {
        console.log("Updating question: " + $scope.question.questionId);
        surveyService.updateQuestion({
            surveyId: $scope.surveyId,
            question: $scope.question
        }).then(function (response) {
                console.log(response);
                if (response.status == 0) {
                    toastr.success(i18n.t("updateQuestionSuccess"))
                }
                else {
                    toastr.error(response.message);
                }
            });
    }
    $scope.question.ordering = false;
}]);

function readURL(input, preview) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();

        reader.onload = function (e) {
            preview.attr('src', e.target.result);
        }

        reader.readAsDataURL(input.files[0]);
    }
}