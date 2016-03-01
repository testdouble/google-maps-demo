module.exports = drawRoutes: (app) ->

  app.get '/api/work-orders', (req, res) ->
    res.json workOrders: [
      { id: 1, description: "Cbus10", address: "10 W Broad ST", city: "Columbus", state: "OH", lat: 39.9625079, lng: -83.00121009999998},
      { id: 4, description: "Cbus10 #2", address: "10 W Broad ST", city: "Columbus", state: "OH", lat: 39.9625079, lng: -83.00121009999998},
      { id: 5, description: "Cbus10 #3", address: "10 W Broad ST", city: "Columbus", state: "OH", lat: 39.9625079, lng: -83.00121009999998},
      { id: 2, description: "Easton", address: "160 Easton Town Center", city: "Columbus", state: "OH", lat: 40.04985670000001, lng: -82.9156888}
      { id: 3, description: "Starbucks", address: "6470 Sawmill Rd", city: "Columbus", state: "OH", lat: 40.1005337, lng: -83.09104589999998}
    ]
