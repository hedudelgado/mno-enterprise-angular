
angular.module 'mnoEnterpriseAngular'
  .directive('connectApplicationsWizard',->
    return {
      restrict: 'EA'
      templateUrl: 'app/components/connect-applications-wizard/connect-applications-wizard.html',
      scope: {
        apps: '='
      }

      controller: ($scope, MnoeAppInstances, $timeout) ->

        $scope.fetchAppInstancesStatus = () ->
          MnoeAppInstances.fetchAppInstancesSync().then(
            (response) ->
              console.log(response.connectors)
              console.log($scope.apps)
              $scope.appInstances = response.connectors
              $timeout($scope.fetchAppInstancesStatus(), 10000)
          )
        $scope.fetchAppInstancesStatus()

        $scope.isAppConnected = (app) ->
          if _.find($scope.appInstances, (m) -> (m.name == app.name) && (m.status == "SUCCESS"))
            true
          else
            false

        return
    }
  )
