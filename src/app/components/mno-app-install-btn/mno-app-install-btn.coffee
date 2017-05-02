angular.module 'mnoEnterpriseAngular'
  .component('mnoAppInstallBtn', {
    bindings: {
      app: '='
    },
    templateUrl: 'app/components/mno-app-install-btn/mno-app-install-btn.html',
    controller: ($q, $state, $window, $uibModal, toastr, MnoeMarketplace, MnoeCurrentUser, MnoeOrganizations, MnoeAppInstances, ONBOARDING_WIZARD_CONFIG) ->
      vm = this

      # Return the different status of the app regarding its installation
      # - INSTALLABLE:                        The app may be installed
      # - INSTALLED_CONNECT/INSTALLED_LAUNCH: The app is already installed, and cannot be multi instantiated
      # - CONFLICT:                           Another app, with a common subcategory that is not multi-instantiable has already been installed
      vm.appInstallationStatus = ->
        if vm.appInstance
          if vm.app.multi_instantiable
            "INSTALLABLE"
          else
            if vm.app.app_nid != 'office-365' && vm.app.stack == 'connector' && !vm.app.oauth_keys_valid
              "INSTALLED_CONNECT"
            else
              "INSTALLED_LAUNCH"
        else
          if vm.conflictingApp
            "CONFLICT"
          else
            "INSTALLABLE"

      vm.canProvisionApp = false

      vm.provisionApp = () ->
        return if !vm.canProvisionApp
        vm.isLoadingButton = true
        MnoeAppInstances.clearCache()
        # Get the authorization status for the current organization
        if MnoeOrganizations.role.atLeastAdmin(vm.user_role)
          purchasePromise = MnoeOrganizations.purchaseApp(vm.app, MnoeOrganizations.selectedId)
        else  # Open a modal to change the organization
          purchasePromise = openChooseOrgaModal().result

        purchasePromise.then(
          ->
            # If the wizard is enabled and has not been completed it will not redirect to impac
            # for the wizard to be completed.
            unless ONBOARDING_WIZARD_CONFIG.enabled
              $state.go('home.impac')

            switch vm.app.stack
              when 'cloud' then displayLaunchToastr(vm.app)
              when 'cube' then displayLaunchToastr(vm.app)
              when 'connector'
                if vm.app.nid == 'office-365'  # Office 365 must display 'Launch'
                  displayLaunchToastr(vm.app)
                else
                  displayConnectToastr(vm.app)
        ).finally(->
          vm.isLoadingButton = false
          # If the wizard is enabled
          if ONBOARDING_WIZARD_CONFIG.enabled
            openConnectAppModal()
        )

      displayLaunchToastr = (app) ->
        toastr.success(
          'mno_enterprise.templates.components.app_install_btn.success_launch_notification_body',
          'mno_enterprise.templates.components.app_install_btn.success_notification_title',
          {extraData: {name: app.name}, timeout: 10000}
        )

      displayConnectToastr = (app) ->
        toastr.success(
          'mno_enterprise.templates.components.app_install_btn.success_connect_notification_body',
          'mno_enterprise.templates.components.app_install_btn.success_notification_title',
          {extraData: {name: app.name}, timeout: 10000}
        )

      openConnectAppModal = () ->
        vm.showConnectButtons = true
        $uibModal.open(
          templateUrl: 'app/views/onboarding/modals/mno-app-info.html'
          controller: 'MnoAppInfoCtrl'
          controllerAs: 'vm',
          size: 'lg'
          resolve:
            showConnectButtons: vm.showConnectButtons
            app: vm.app
        )

      openChooseOrgaModal = () ->
        $uibModal.open(
          backdrop: 'static'
          templateUrl: 'app/views/marketplace/modals/choose-orga-modal.html'
          controller: 'MarketplaceChooseOrgaModalCtrl'
          resolve:
            app: vm.app
        )

      #====================================
      # App Launch
      #====================================
      vm.launchAppInstance = ->
        $window.open("/mnoe/launch/#{vm.appInstance.uid}", '_blank')
        return true

      #====================================
      # App Connect modal
      #====================================
      vm.connectAppInstance = ->
        switch vm.appInstance.app_nid
          when "xero" then modalInfo = {
            template: "app/views/apps/modals/app-connect-modal-xero.html",
            controller: 'DashboardAppConnectXeroModalCtrl'
          }
          when "myob" then modalInfo = {
            template: "app/views/apps/modals/app-connect-modal-myob.html",
            controller: 'DashboardAppConnectMyobModalCtrl'
          }
          else vm.launchAppInstance()

        $uibModal.open(
          templateUrl: modalInfo.template
          controller: modalInfo.controller
          resolve:
            app: vm.appInstance
        )

      #====================================
      # Initialize
      #====================================
      vm.init = ->
        # Retrieve the apps and the app instances in order to retrieve the current app, and its conflicting status
        # with the current installed app instances
        $q.all(
          marketplace: MnoeMarketplace.getApps(),
          appInstances: MnoeAppInstances.getAppInstances(),
          currentUser: MnoeCurrentUser.get()
        ).then(
          (response) ->
            apps = response.marketplace.apps
            appInstances = response.appInstances
            currentUser = response.currentUser

            # Get number of organizations with at least an admin role
            authorizedOrganizations = _.filter(currentUser.organizations, (org) ->
              MnoeOrganizations.role.atLeastAdmin(org.current_user_role)
            )
            vm.canProvisionApp = !_.isEmpty(authorizedOrganizations)

            # Find if the user already have an instance of it
            vm.appInstance = _.find(appInstances, {app_nid: vm.app.nid})

            # Get the list of installed apps from the list of instances
            nids = _.compact(_.map(appInstances, (a) -> a.app_nid))
            installedApps = _.filter(apps, (a) -> a.nid in nids)

            # Find a conflicting app with the current app based on the subcategories
            # If there is already an installed app, with a common subcategory with the app that is not multi_instantiable
            # We keep that app, as a conflictingApp, to explain why the app cannot be installed.
            if vm.app.subcategories
              # retrieve the subcategories names
              names = _.map(vm.app.subcategories, 'name')

              vm.conflictingApp = _.find(installedApps, (app) ->
                _.find(app.subcategories, (subCategory) ->
                  not subCategory.multi_instantiable and subCategory.name in names
                )
              )
        )

      vm.init()

      return
  }
)
