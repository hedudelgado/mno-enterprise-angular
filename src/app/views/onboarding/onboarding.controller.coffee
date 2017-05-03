angular.module 'mnoEnterpriseAngular'
  .controller('OnboardingCtrl',(MnoeOrganizations, $state, MnoeCurrentUser) ->
    vm = this
    vm.appsSelected = []
    vm.areApps = false
    vm.numberOfAppsConnected = 0
    vm.areAppsConnected = false

    # This is a temporal solution for a conflict on the layout css with the onboarding
    angular.element( document.querySelector( '.myspace' ) ).addClass('onboarding-helper')
    
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

    vm.onboardingHelper = () ->
      angular.element( document.querySelector( '.myspace' ) ).removeClass('onboarding-helper')
    
    vm.finishedWizard = () ->
      $state.go('home.impac')
      # This will delete the css class added to fix the conflict on the layout css with the onboarding
      setTimeout vm.onboardingHelper, 3000

    return
  )
