
angular.module 'mnoEnterpriseAngular'
  .directive('mnoSelectAppWizard', ->
    return {
      restrict: 'EA'
      templateUrl: 'app/components/mno-select-app-wizard/mno-select-app-wizard.html',
      scope: {
        apps: '='
        isPanelShown: '='
      }

      controller: ($scope, $window, MnoeMarketplace, $sce, $uibModal, $attrs) ->
        $scope.selectedCategory = { category:'' }
        $scope.searchTerm = { name:'' }
        $scope.isLoading = true

        $scope.trustSrc = (src) ->
          $sce.trustAsResourceUrl(src)

        $scope.toggleApp = (app) ->
          $scope.appForDataSync(app)
          app.checked = !app.checked

        $scope.appsFilter = (app) ->
          if ($scope.searchTerm? && $scope.searchTerm.length > 0) || !$scope.selectedCategory.category
            return true
          else
            return _.contains(app.categories, $scope.selectedCategory.category)


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
          showConnectButtons = false
          modalInstance = $uibModal.open(
            templateUrl: 'app/views/onboarding/modals/mno-app-info.html'
            controller: 'MnoAppInfoCtrl'
            controllerAs: 'vm',
            size: 'lg'
            resolve:
              showConnectButtons: showConnectButtons
              app: app
          )
            

        # --------------------------------------------------
        # Control the apps in 'what data will be sync panel'
        # --------------------------------------------------
        $scope.appForDataSync = (app) ->
          if _.find($scope.apps, (m) -> m.id == app.id)
            indexOfApp = $scope.apps.indexOf(app)
            $scope.apps.splice(indexOfApp,1)
          else
            $scope.apps.push(app)
          $scope.isPanelShown = $scope.apps.length > 0


        MnoeMarketplace.getApps().then(
          (response) ->
            response = response.plain()
            $scope.categories = response.categories
            $scope.isLoading = false
            $scope.appsMarketplace = response.apps
        )

        return
    }
  )
