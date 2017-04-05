
angular.module 'mnoEnterpriseAngular'
  .directive('mnoWelcomeWizard', ->
    return {
      restrict: 'EA'
      templateUrl: 'app/components/mno-welcome-wizard/mno-welcome-wizard.html'

      controller: ($scope, $window) ->
    }
  )
