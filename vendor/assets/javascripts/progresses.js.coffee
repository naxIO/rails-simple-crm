myApp = angular.module('progress', [ 
  'ui.bootstrap'
  'ui.grid'
  'ui.grid.resizeColumns'
  'ui.grid.edit'
])

myApp.filter 'mapTeacher', ->
  return (input) ->
    return  "OK"


myApp.factory 'teacherListService', ($http)->
  return {
    search:  (params) ->
      return $http.get('/teachers.json',{cache: true}).success (response) ->
        return response.data
  }



myApp.controller 'CourseCtrl', ($scope, $http, $modal) ->
  $scope.period_open = (id) ->
    modal = $modal.open {
      templateUrl: 'periodModal.html',
      controller: 'PeriodCtrl',
      size: 'lg',
      resolve: {
        id: ->
          return id
      }
    }

  $scope.showId = (grid, row) ->
    console.log grid
    return row.entity.id
  $scope.gridOptions =
    enableSorting: true
    enableFiltering: true
    maxVisibleRowCount: 20
  $scope.gridOptions.columnDefs = [
    {
      name: 'id'
      width: 50
      enableColumnResizing: false
      enableCellEdit: false
      cellTemplate: '<input type="button" value="{{row.entity.id}}" ng-click="grid.appScope.period_open(row.entity.id)" />'
    }, {
      name: 'name'
      displayName: 'コース名'
    },{
      name: 'company'
      enableCellEdit: false
    }, {
      name: 'responsible'
      enableCellEdit: true
    }, { 
      name: 'start_date'
      field: 'getStartDate()'
      enableCellEdit: false
    }, { 
      name: 'end_date'
      field: 'getEndDate()'
      enableCellEdit: false
    }, { 
      name: 'memo'
      enableCellEdit: true
    }
  ]


  $http.get('/progresses/data.json').success((data) ->
    $scope.gridOptions.data = data
    angular.forEach data, (value,key) ->
      $scope.gridOptions.data[key]["getStartDate"] = ->
        return this.periods[0].day
      $scope.gridOptions.data[key]["getEndDate"] = ->
        return this.periods[this.periods.length - 1].day
  ).error (data) ->
    alert 'エラーが発生しました。' + data

  $scope.gridOptions.onRegisterApi = (gridApi) ->
    $scope.gridApi = gridApi
    gridApi.edit.on.afterCellEdit $scope, (rowEntity, colDef, newValue, oldValue) ->
      colDef.id = rowEntity.id
      colDef.new_value = newValue
      $http.post('/progresses/update',colDef).success((data,status,headers) ->
        console.log data
      ).error (data) ->
        alert data
      $scope.$apply()

myApp.controller 'PeriodCtrl',  ($scope, $http,teacherListService, id) ->
  $scope.periodGrid =
    enableSorting: true
    enableFiltering: true
    maxVisibleRowCount: 20
  $scope.periodGrid.columnDefs = [
    {
      name: 'id'
      width: 50
      enableColumnResizing: false
      enableCellEdit: false
    } , {
      name:  "day"
      type: "date"
      displayName: '日付'
    } , {
      name:  "teacher"
      displayName: '講師'
      editableCellTemplate: 'ui-grid/dropdownEditor'
      editDropdownValueLabel: 'name'
      editDropdownIdLabel: 'id'
      cellFilter: "mapTeacher"
    } , {
      name:  "start_time"
      displayName: '開始時刻'
    } , {
      name:  "end_time"
      displayName: '終了時刻'
    } , {
      name:  "break_start"
      displayName: '休憩開始'
    } , {
      name:  "break_end"
      displayName: '休憩終了'
    } , {
      name:  "memo"
      displayName: 'メモ'
    }
  ]
  $http.get('/progresses/' + id  + '/period.json').success((data) ->
    $scope.periodGrid.data = data
  ).error((data) ->
    alert 'エラーが発生しました。' + data
  )

  teacherListService.search().then (res) ->
    $scope.periodGrid.columnDefs[2].editDropdownOptionsArray = res.data

  $scope.periodGrid.onRegisterApi = (gridApi) ->
    $scope.gridApi = gridApi
    gridApi.edit.on.afterCellEdit $scope, (rowEntity, colDef, newValue, oldValue) ->
      colDef.id = rowEntity.id
      colDef.new_value = newValue
      $http.post('/progresses/update_period',colDef).success((data,status,headers) ->
        console.log data
      ).error (data) ->
        alert data
      $scope.$apply()
