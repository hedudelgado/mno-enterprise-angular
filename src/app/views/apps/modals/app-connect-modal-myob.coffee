angular.module 'mnoEnterpriseAngular'
.controller('DashboardAppConnectMyobModalCtrl', ($scope, $window, $httpParamSerializer, $uibModalInstance, app) ->

  $scope.app = app
  $scope.path = "/mnoe/webhook/oauth/" + app.uid + "/authorize?"
  $scope.form = {
    perform: true
    version: "essentials"
  }
  $scope.versions = [{name: "Account Right Live", value: "account_right"}, {name: "Essentials", value: "essentials"}]

  $scope.connect = (form) ->
    if ONBOARDING_WIZARD_CONFIG.enabled
      $window.open($scope.path + $httpParamSerializer(form))
    else
      $window.location.href = $scope.path + $httpParamSerializer(form)

  $scope.close = ->
    $uibModalInstance.close()

  return
)
