window.App ||= {}

App.initMap = ->
  map = new google.maps.Map $('#map')[0],
    center:
      lat: 40
      lng: -83
    zoom: 11
  geocoder = new google.maps.Geocoder()
  infoWindow = new google.maps.InfoWindow

  selectedWorkOrders = []

  $.get '/api/work-orders', (data) ->
    workOrders = data.workOrders

    $('#lists').on 'click', 'button.reset', ->
      selectedWorkOrders = []
      renderLists(workOrders)

    $('#map').on 'click', 'button.add-to-route', (e) ->
      selectedWorkOrders.push($(e.target).data('id'))
      infoWindow.close()
      renderLists(workOrders)

    renderLists(workOrders)

    _.each workOrders, (order) ->
      address = "#{order.address}, #{order.city}. #{order.state}"
      geocoder.geocode {address}, (results, status) ->
        return console.log('failed to find', status) unless status == google.maps.GeocoderStatus.OK
        _(new google.maps.Marker
          map: map
          position: results[0].geometry.location).tap (marker) ->
            marker.addListener 'click', ->
              infoWindow.setContent(JST['app/templates/info-window.us'](order))
              infoWindow.open(map, marker)

  renderLists = (orders) ->
    $('#lists').html(JST['app/templates/lists.us']
      selected: _(orders).chain().select (o) ->
          _(selectedWorkOrders).include(o.id)
        .sortBy (o) ->
          selectedWorkOrders.indexOf(o.id)
        .value()
      notSelected: _(orders).reject (o) -> _(selectedWorkOrders).include(o.id)
    )
