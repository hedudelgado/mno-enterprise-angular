angular.module 'mnoEnterpriseAngular'
.controller('MnoAppInfoCtrl', (app, showConnectButtons, $uibModalInstance) ->
  vm = this
  vm.app = app
  vm.showConnectButtons = showConnectButtons

  vm.close = ->
    $uibModalInstance.close()

  return
)
