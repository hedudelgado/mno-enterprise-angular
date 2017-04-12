angular.module 'mnoEnterpriseAngular'
.controller('MnoAppInfoCtrl', (app, showConnectButtons) ->
  vm = this
  vm.app = app
  vm.showConnectButtons = showConnectButtons

  return
)
