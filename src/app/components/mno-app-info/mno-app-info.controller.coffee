angular.module 'mnoEnterpriseAngular'
.controller('MnoAppInfoCtrl', (app) ->
  vm = this
  vm.app = app

  vm.modal = {model: {}}
  return
)
