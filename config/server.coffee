module.exports = drawRoutes: (app) ->

  app.get '/api/work-orders', (req, res) ->
    res.json workOrders: [
      { id: 1, description: "Cbus10", address: "10 W Broad ST", city: "Columbus", state: "OH"},
      { id: 2, description: "Easton", address: "160 Easton Town Center", city: "Columbus", state: "OH"}
      { id: 3, description: "Starbucks", address: "6470 Sawmill Rd", city: "Columbus", state: "OH"}
    ]
