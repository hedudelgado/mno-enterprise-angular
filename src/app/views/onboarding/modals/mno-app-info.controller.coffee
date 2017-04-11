angular.module 'mnoEnterpriseAngular'
.controller('MnoAppInfoCtrl', (app, showConnectButtons) ->
  vm = this
  vm.app = app
  vm.showConnectButtons = showConnectButtons
  vm.activeApp = null

  vm.isLaunchHidden = (app) ->
    app.status == 'terminating' ||
    app.status == 'terminated' ||
    vm.isOauthConnectBtnShown(app) ||
    vm.isNewOfficeApp(app)

  vm.isOauthConnectBtnShown = (instance) ->
    instance.app_nid != 'office-365' &&
    instance.stack == 'connector' &&
    !instance.oauth_keys_valid

  vm.isNewOfficeApp = (instance) ->
    instance.stack == 'connector' && instance.appNid == 'office-365' && (moment(instance.createdAt) > moment().subtract({minutes:5}))

  vm.launchAction = (app, event) ->
    vm.setActiveApp(event, app.id)
    if app.customInfoRequired
      return false
    else
      $window.open("/mnoe/launch/#{app.uid}", '_blank')
      return true

  vm.setActiveApp = (event, app) ->
    if vm.isActiveApp(app)
      vm.activeApp = null
    else
      angular.element(event.target).off('mouseout')
      vm.activeApp = app

  vm.isActiveApp = (app) ->
    vm.activeApp == app

  return
)
