
angular.module 'mnoEnterpriseAngular'
  .directive('mnoSelectAppWizard', ->
    return {
      restrict: 'EA'
      templateUrl: 'app/components/mno-select-app-wizard/mno-select-app-wizard.html',
      scope: {
        appsData: '='
        isPanelShown: '='
      }

      controller: ($scope, $window, MnoeMarketplace, $sce, $uibModal) ->
        $scope.selectedCategory = ''
        $scope.searchTerm = ''

        $scope.trustSrc = (src) ->
          $sce.trustAsResourceUrl(src)
      
        $scope.toggleApp = (app) ->
          $scope.appForDataSync(app)
          app.checked = !app.checked

        $scope.appsFilter = (app) ->
          if ($scope.searchTerm? && $scope.searchTerm.length > 0) || !$scope.selectedCategory
            return true
          else
            return _.contains(app.categories, $scope.selectedCategory)


        # ----------------------
        # Info button management
        # ----------------------
        $scope.hoverIn = (app) ->
          app.isInfoButtonShown = true

        $scope.hoverOut = (app) ->
          app.isInfoButtonShown = false
        
        $scope.isInfoShown = (app) ->
          app.isInfoButtonShown && !app.checked


        #====================================
        # Info modal
        #====================================
        $scope.openInfoModal = (app) ->
          modalInstance = $uibModal.open(
            templateUrl: 'app/components/mno-app-info/mno-app-info.html'
            controller: 'MnoAppInfoCtrl'
            controllerAs: 'vm',
            size: 'lg'
            windowClass: 'inverse'
            backdrop: 'static'
            resolve:
              app: app
          )
          modalInstance.result.then(
            (response) ->
          )

        # --------------------------------------------------
        # Control the apps in 'what data will be sync panel'
        # --------------------------------------------------
        $scope.appForDataSync = (app) ->
          if _.find($scope.appsData, (m) -> m.id == app.id)
            indexOfApp = $scope.appsData.indexOf(app)
            $scope.appsData.splice(indexOfApp,1)
          else
            $scope.appsData.push(app)
          $scope.isPanelShown = $scope.appsData.length > 0


        MnoeMarketplace.getApps().then(
          (response) ->
            response = response.plain()
            $scope.categories = response.categories
            $scope.apps = response.apps
        )

        return
    }
  )
