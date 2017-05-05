angular.module 'mnoEnterpriseAngular'
  .controller('OnboardingCtrl',(MnoeOrganizations, $state, MnoeCurrentUser, WizardHandler) ->
    vm = this
    vm.appsSelected = []
    vm.areApps = false
    vm.numberOfAppsConnected = 0
    vm.areAppsConnected = false
    vm.goToDashboard = false
    vm.isWizardShown = true
    # TODO
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
    
    vm.setGoToDashboard = () ->
      vm.goToDashboard = true
      vm.finishedWizard()

    vm.waitForEmail = () ->
      vm.finishedWizard()

    vm.onboardingHelper = () ->
      angular.element( document.querySelector( '.myspace' ) ).removeClass('onboarding-helper')
    
    vm.finishedWizard = () ->
      vm.isWizardShown = false
      if vm.goToDashboard
        WizardHandler.wizard().finish()
        $state.go('home.impac')
      else
        WizardHandler.wizard().finish()
        $state.go('onboarding.email-me')
      # This will delete the css class added to fix the conflict on the layout css with the onboarding
      setTimeout vm.onboardingHelper, 3000

    return
  )
