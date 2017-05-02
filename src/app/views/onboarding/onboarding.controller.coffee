angular.module 'mnoEnterpriseAngular'
  .controller('OnboardingCtrl',(MnoeOrganizations, $state, MnoeCurrentUser) ->
    vm = this
    vm.appsSelected = []
    vm.areApps = false
    vm.numberOfAppsConnected = 0
    vm.areAppsConnected = false
    
    vm.canGoToNextStep = ()->
      (vm.appsSelected.length > 0 ) && (vm.appsSelected.length <= 4)

    # This loop will create the app instances into the organization base on the apps selected
    vm.purchaseApps = () ->
      for app in vm.appsSelected
        MnoeOrganizations.purchaseApp(app, MnoeOrganizations.selectedId).then( ->
          vm.numberOfAppsConnected = vm.numberOfAppsConnected + 1
          if vm.numberOfAppsConnected ==  vm.appsSelected.length
            vm.areAppsConnected = true
          )

    vm.finishedWizard = () ->
      $state.go('home.impac')

    return
  )
