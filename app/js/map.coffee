window.App ||= {}

App.google =
  map: null
  infowWindow: null

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

  createMarker: (position) ->
    marker = new App.Marker position, =>
      JST['app/templates/info-window.us'](this)

class App.Marker
  constructor: (position, infoWindowContentCreator) ->
    @marker = new google.maps.Marker
      map: App.google.map
      position: position

    @marker.addListener 'click', =>
      App.google.infoWindow.setContent(infoWindowContentCreator())
      App.google.infoWindow.open(App.google.map, @marker)

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
      renderLists(workOrders)

    $('#map').on 'click', 'button.add-to-route', (e) ->
      selectedWorkOrders.append(workOrders.findById($(e.target).data('id')))
      App.google.infoWindow.close()
      renderLists(workOrders)

    renderLists(workOrders)

    workOrders.each (order) ->
      address = "#{order.address}, #{order.city}, #{order.state}"
      order.createMarker(new google.maps.LatLng(order.lat, order.lng))

  renderLists = (orders) ->
    $('#lists').html(JST['app/templates/lists.us']
      selected: selectedWorkOrders
      notSelected: orders.without(selectedWorkOrders)
    )
