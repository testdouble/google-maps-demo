window.App ||= {}
App.initMap = ->
  new google.maps.Map $('#map')[0],
    center:
      lat: 40
      lng: -83
    zoom: 11
