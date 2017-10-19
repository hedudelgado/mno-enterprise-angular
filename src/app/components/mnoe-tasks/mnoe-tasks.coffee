angular.module('mnoEnterpriseAngular').component('mnoeTasks', {
  bindings: {
  },
  templateUrl: 'app/components/mnoe-tasks/mnoe-tasks.html',
  controller: ($filter, $uibModal, $log, $translate, $timeout, $q, toastr, MnoeTasks, MnoeCurrentUser)->
    ctrl = this
    ctrl.$onInit = ->
      ctrl.tasks = {
        list: []
        sort: 'send_at.desc'
        nbItems: 10
        offset: 0
        page: 1
        loading: false
        pageChangedCb: (nbItems, page) ->
          ctrl.tasks.nbItems = nbItems
          ctrl.tasks.page = page
          ctrl.tasks.offset = (page  - 1) * nbItems
          fetchTasks(limit: nbItems, offset: ctrl.tasks.offset)
      }
      ctrl.menus = [
        { label: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.menus.inbox'), name: 'inbox', selected: true }
        { label: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.menus.sent'), name: 'sent', query: { outbox: true } }
        { label: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.menus.draft'), name: 'draft', query: { 'where[status][]': 'draft', outbox: true } }
      ]
      ctrl.tasksFilters = [
        { name: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks_filters.all_tasks_and_msgs') }
        { name: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks_filters.all_tasks'), query: { 'where[due_date.ne]': '' } }
        { name: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks_filters.all_messages'), query: { 'where[due_date.eq]': '' } }
        { name: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks_filters.due_tasks'), query: { 'where[due_date.lt]': moment().toISOString() } }
        { name: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks_filters.completed_tasks'), query: { 'where[completed_at.ne]': '' } }
      ]
      ctrl.selectedTasksFilter = ctrl.tasksFilters[0]
      ctrl.selectedMenu = _.find(ctrl.menus, (m)-> m.selected)
      fetchTasks()

    ctrl.onSelectFilter = ({filter})->
      return if filter == ctrl.selectedTasksFilter
      ctrl.selectedTasksFilter = filter
      fetchTasks()

    ctrl.onSelectMenu = ({menu})->
      return if menu == ctrl.selectedMenu
      ctrl.selectedMenu = menu
      params = { order_by: 'updated_at.desc' } if menu.name == 'draft'
      fetchTasks(params)

    ctrl.onRefreshTasks = ->
      fetchTasks()

    ctrl.openCreateTaskModal = ->
      $uibModal.open({
        component: 'mnoCreateTaskModal'
        resolve:
          recipients: MnoeTasks.getRecipients()
          createTaskCb: ->
            (newTask) ->
              createTask(newTask)
      })

    ctrl.openShowTaskModal = ({rowItem})->
      task = rowItem
      $uibModal.open({
        component: 'mnoShowTaskModal'
        resolve:
          task: -> angular.copy(task)
          dueDateFormat: -> 'MMMM d'
          currentUser: MnoeCurrentUser.get()
          setReminderCb: ->
            (reminderDate)->
              updateTask(task, reminder_date: reminderDate)
          onReadTaskCb: ->
            (hasBeenRead)->
              # Only mark inbox items that have no already been read as read.
              return $q.resolve() if hasBeenRead || ctrl.selectedMenu.name != 'inbox'
              updateTask(task, read_at: moment().toDate())
          markAsDoneCb: ->
            (isDone)->
              task.markedDone = isDone
              updateTaskStatus(task)
          sendReplyCb: ->
            (reply)->
              ctrl.sendReply(reply, task)
      })

    ctrl.sendReply = (reply, task) ->
      angular.merge(reply, { title: "RE: #{task.title}", orga_relation_id: task.owner_id, status: 'sent' })
      createTask(reply)

    # Manage sorting for mnoSortableTable with angular-smart-table st-pipe.
    ctrl.sortableTableServerPipe = (tableState)->
      ctrl.tasks.sort = updateTableSort(tableState.sort)
      fetchTasks(limit: ctrl.tasks.nbItems, offset: ctrl.tasks.offset, order_by: ctrl.tasks.sort)

    # Private

    # Update angular-smart-table sorting parameters
    updateTableSort = (sortState = {}) ->
      sort = ctrl.tasks.sort
      if sortState.predicate
        sort = sortState.predicate
        if sortState.reverse
          sort += ".desc"
        else
          sort += ".asc"
      return sort

    fetchTasks = (params = {})->
      ctrl.tasks.loading = true
      ctrl.mnoSortableTableFields = buildMnoSortableTable()
      baseParams = { limit: ctrl.tasks.nbItems, offset: ctrl.tasks.offset, order_by: ctrl.tasks.sort }
      params = angular.merge({}, baseParams, params, ctrl.selectedMenu.query, ctrl.selectedTasksFilter.query)
      MnoeTasks.get(params).then(
        (response)->
          ctrl.tasks.list = response.data.plain()
          ctrl.tasks.totalItems = response.headers('x-total-count')
          ctrl.tasks.list
        (errors)->
          $log.error(errors)
          toastr.error('mno_enterprise.templates.components.mnoe-tasks.toastr_error.get_tasks')
          return
      ).finally(->
        # Add delay to improve UI the rendering appearance while new data is bound.
        $timeout(->
          ctrl.tasks.loading = false
        , 250)
      )

    createTask = (task)->
      MnoeTasks.create(task).then(
        ->
          fetchTasks()
        (errors)->
          $log.error(errors)
          toastr.error('mno_enterprise.templates.components.mnoe-tasks.toastr_error.create_task')
          return
      )

    updateTask = (task, params = {})->
      MnoeTasks.update(task.id, params).then(
        (updatedTask)->
          angular.extend(task, updatedTask)
        (errors)->
          $log.error(errors)
          toastr.error('mno_enterprise.templates.components.mnoe-tasks.toastr_error.update_task')
          return
      )

    # Determine Task status from markedDone attribute (linked to checkbox ngModel)
    updateTaskStatus = (task)->
      status = if task.markedDone then 'done' else 'sent'
      updateTask(task, status: status)

    # Creates mnoSortableTable cmp config API, building the tasks table columns
    buildMnoSortableTable = ->
      toColumn = { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.to'), attr: 'task_recipients[0].user.name' }
      fromColumn = { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.from'), attr: 'owner.user.name' }
      titleColumn = { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.title'), attr: 'title', class: 'ellipsis' }
      messageColumn = { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.message'), attr: 'message', class: 'ellipsis' }
      receivedAtColumn = { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.received'), attr: 'send_at', filter: expandingDateFormat }
      sentAtColumn = { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.sent'), attr: 'send_at', filter: expandingDateFormat }
      readAtColumn = { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.read'), attr: 'task_recipients[0].read_at', filter: expandingDateFormat }
      updatedAtColumn = { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.updated_at'), attr: 'updated_at', filter: expandingDateFormat }
      dueDateAtColumn = { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.due_date'), attr: 'due_date', filter: simpleDateFormat }
      doneColumn = { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.done'), attr: 'status', render: taskDoneCustomField, stopPropagation: true }
      switch ctrl.selectedMenu.name
        when 'inbox'
          [fromColumn, titleColumn, messageColumn, receivedAtColumn, dueDateAtColumn, doneColumn]
        when 'sent'
          [toColumn, titleColumn, messageColumn, sentAtColumn, readAtColumn, dueDateAtColumn, doneColumn]
        when 'draft'
          [toColumn, titleColumn, messageColumn, updatedAtColumn, dueDateAtColumn]

    # Formats dates yesterday & beyond differently from today
    expandingDateFormat = (value)->
      dateFormat = if moment(value) < moment().startOf('day') then 'MMMM d' else 'h:mma'
      $filter('date')(value, dateFormat)

    # A format used across multiple tasks columns
    simpleDateFormat = (value)->
      $filter('date')(value, 'MMMM d')

    # Callback for building a custom "done" checkbox field in the mnoSortableTable component.
    taskDoneCustomField = (rowItem)->
      # If a :completed_at timestamp exist, initialise frontend switch model for checkbox.
      rowItem.markedDone = rowItem.completed_at?
      switch ctrl.selectedMenu.name
        when 'inbox'
          htmlTemplate = """
            <input type="checkbox" class="toggle-task-done" ng-if="rowItem.due_date" ng-model="rowItem.markedDone" ng-change="markDone(rowItem)">
            <span ng-if="!rowItem.due_date">-</span>
          """
        when 'sent'
          label = if rowItem.markedDone then 'completed' else 'open'
          htmlTemplate = "<span>#{label}</span>"
      {
        scope:
          markDone: updateTaskStatus
        template: htmlTemplate
      }

    ctrl
})
