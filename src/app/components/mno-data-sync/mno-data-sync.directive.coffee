angular.module 'mnoEnterpriseAngular'
  .directive('mnoDataSync', ->
    return {
      restrict: 'EA'
      templateUrl: 'app/components/mno-data-sync/mno-data-sync.html',
      scope: {
        apps: '='
        isPanelShown: '='
      }

      controller: () ->

        return
    }
  )
