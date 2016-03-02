window.App ||= {}

App.google =
  map: null
  infoWindow: null
  lowZIndex: 0

class App.List
  constructor: (items = []) ->
    @items = items

  toArray: -> @items

  each: (predicate) ->
    _(@items).each(predicate)

  append: (items...) ->
    @items = _(@items.concat(items)).uniq (i) -> i.id

  reset: ->
    @items = []

  remove: (item) ->
    @items = _(@items).reject (i) -> item.id == i.id

  include: (item) ->
    @find(item)?

  find: (item) ->
    _(@items).find (i) -> item.id == i.id

  findById: (id) ->
    _(@items).find (i) -> id == i.id

  sortBy: (property) ->
    @items = _(@items).sortBy (item) ->
      _(item).result(property)

  # Create a new list without the items in the other list
  without: (otherItems) ->
    others = if _(otherItems).isArray() then otherItems else otherItems.toArray()
    new App.List _(@items).reject (i) ->
      _(others).find (o) -> o.id == i.id


class App.Item
  constructor: (attrs) ->
    _.extend this,
      marker: null
    , attrs

  distance: ->
    google.maps.geometry.spherical.computeDistanceBetween(
      App.google.map.getCenter(),
      @marker.getPosition()
    )

  createMarker: (position) ->
    @marker = new App.Marker this, =>
      JST['app/templates/info-window.us'](this)

class App.Marker
  constructor: (position, infoWindowContentCreator) ->
    @marker = new google.maps.Marker
      map: App.google.map
      position: position

    @marker.addListener 'click', =>
      @marker.setZIndex(App.google.lowZIndex--)
      App.google.infoWindow.setContent(infoWindowContentCreator())
      App.google.infoWindow.open(App.google.map, @marker)

  remove: ->
    @marker.setMap(null)

  add: ->
    @marker.setMap(App.google.map)

  getPosition: ->
    @marker.getPosition()

App.listFor = (array) ->
  new App.List(_(array).map (attrs) ->
    new App.Item(attrs)
  )

App.initMap = ->
  App.google.map = new google.maps.Map $('#map')[0],
    center:
      lat: 40
      lng: -83
    zoom: 11
  App.google.infoWindow = new google.maps.InfoWindow()

  selectedWorkOrders = new App.List()

  $.get '/api/work-orders', (data) ->
    workOrders = App.listFor(data.workOrders)

    $('#lists').on 'click', 'button.reset', ->
      selectedWorkOrders.reset()
      renderMarkers(workOrders)
      renderLists(selectedWorkOrders, workOrders)

    $('#app').on 'click', 'button.add-to-route', (e) ->
      workOrder = workOrders.findById($(e.target).data('id'))
      selectedWorkOrders.append(workOrder)
      App.google.infoWindow.close()
      workOrder.marker.remove()
      renderLists(selectedWorkOrders, workOrders)

    $('#lists').on 'click', 'button.remove-from-route', (e) ->
      workOrder = workOrders.findById($(e.target).data('id'))
      selectedWorkOrders.remove(workOrder)
      workOrder.marker.add()
      renderLists(selectedWorkOrders, workOrders)

    $('#lists').on 'click', '#not-selected-orders .sort button', (e) ->
      workOrders.sortBy($(e.target).data('sortBy'))
      renderLists(selectedWorkOrders, workOrders)

    renderMarkers(workOrders)
    renderLists(selectedWorkOrders, workOrders)

  renderMarkers = (workOrders) ->
    workOrders.each (order) ->
      order.createMarker()

  renderLists = (selectedWorkOrders, workOrders) ->
    unselectedWorkOrders = workOrders.without(selectedWorkOrders)
    $('#lists').html(JST['app/templates/lists.us']
      selected: selectedWorkOrders
      notSelected: unselectedWorkOrders
    )
