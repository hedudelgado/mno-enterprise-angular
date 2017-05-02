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
        # Todo once what data is sync is added
        return
    }
  )
