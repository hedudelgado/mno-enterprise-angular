angular.module 'mnoEnterpriseAngular'
  .directive('mnoSelectAppWizard', ->
    return {
      restrict: 'EA'
      templateUrl: 'app/components/mno-select-app-wizard/mno-select-app-wizard.html',
      scope: {
        apps: '='
        isPanelShown: '='
      }

      controller: ($scope, MnoeMarketplace, $sce, $uibModal) ->
        $scope.selectedCategory = { category:'' }
        $scope.searchTerm = { name:'' }
        $scope.isLoading = true

        $scope.trustSrc = (src) ->
          $sce.trustAsResourceUrl(src)

        $scope.toggleApp = (app) ->
          app.checked = !app.checked
          $scope.appForDataSync(app)

        $scope.appsFilter = (app) ->
          if ($scope.searchTerm? && $scope.searchTerm.length > 0) || !$scope.selectedCategory.category
            return true
          else
            return _.contains(app.categories, $scope.selectedCategory.category)

        # ======================
        # Info button management
        # ======================
        $scope.hoverIn = (app) ->
          app.isInfoButtonShown = true

        $scope.hoverOut = (app) ->
          app.isInfoButtonShown = false
        
        $scope.isInfoShown = (app) ->
          app.isInfoButtonShown

        # ====================================
        # Info modal
        # ====================================
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
        
        # ==================================================
        # Control the apps in 'what data will be sync panel'
        # ==================================================
        $scope.appForDataSync = (app) ->
          $scope.apps = _.map(_.filter($scope.appsMarketplace, {checked: true}))
          $scope.isPanelShown = $scope.apps.length > 0
          $scope.isRecommendationShown = $scope.apps.length > 4

        # ==================================
        # Retrieve apps for marketplace box
        # ==================================
        MnoeMarketplace.getApps().then(
          (response) ->
            response = response.plain()
            $scope.categories = response.categories
            $scope.appsMarketplace = response.apps
            $scope.isLoading = false
        )

        return
    }
  )
