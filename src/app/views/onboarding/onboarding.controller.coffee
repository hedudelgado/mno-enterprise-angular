
angular.module 'mnoEnterpriseAngular'
  .controller('OnboardingCtrl', ->

    vm = this

    vm.appsSelected = []
    vm.areApps = false
    
    vm.canGoToNextStep = ()->
      vm.appsSelected.length == 3
    return

  )
