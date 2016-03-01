window.App ||= {}
App.initMap = ->
  map = new google.maps.Map $('#map')[0],
    center:
      lat: 40
      lng: -83
    zoom: 11

  geocoder = new google.maps.Geocoder()

  $.get '/api/work-orders', (data) ->
    $('#list').empty()
    _.each data.workOrders, (order) ->
      renderItem(order)
      address = "#{order.address}, #{order.city}. #{order.state}"
      console.log address
      geocoder.geocode {address}, (results, status) ->
        return console.log('failed to find', status) unless status == google.maps.GeocoderStatus.OK
        _(new google.maps.Marker
          map: map
          position: results[0].geometry.location).tap (marker) ->
            marker.addListener 'click', ->
              new google.maps.InfoWindow
                content: JST['app/templates/info-window.us'](order)
              .open(map, marker)

renderItem = (order) ->
  $('#list').append(JST['app/templates/item.us'](order))
