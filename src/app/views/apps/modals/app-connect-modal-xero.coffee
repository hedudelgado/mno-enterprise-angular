angular.module 'mnoEnterpriseAngular'
.controller('DashboardAppConnectXeroModalCtrl', ($scope, $window, $httpParamSerializer, $uibModalInstance, app, MnoeCurrentUser, ONBOARDING_WIZARD_CONFIG) ->

  $scope.app = app
  $scope.path = "/mnoe/webhook/oauth/" + app.uid + "/authorize?"
  $scope.form = {
    perform: true
    xero_country: "AU"
  }
  $scope.countries = [{name: "Australia", value: "AU"}, {name: "USA", value: "US"}]

  $scope.connect = (form) ->
    form['extra_params[]'] = "payroll" if $scope.payroll
    # If Xero is being connected from the wizard and the user has not finished the onboarding wizard,
    # it will open a new page in the browser, otherwise it will be in the same page
    if ONBOARDING_WIZARD_CONFIG.enabled
      MnoeCurrentUser.get().then( ->
        isWizardFinished = MnoeCurrentUser.user.wizard_finished
        if !isWizardFinished
          $window.open($scope.path + $httpParamSerializer(form))
        else
          $window.location.href = $scope.path + $httpParamSerializer(form)
      )
    else
      $window.location.href = $scope.path + $httpParamSerializer(form)

  $scope.close = ->
    $uibModalInstance.close()

  return
)
