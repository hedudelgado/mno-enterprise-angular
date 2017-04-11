
angular.module 'mnoEnterpriseAngular'
  .directive('connectApplicationsWizard',->
    return {
      restrict: 'EA'
      templateUrl: 'app/components/connect-applications-wizard/connect-applications-wizard.html',
      scope: {
        apps: '='
      }

      controller: () ->

        return
    }
  )
