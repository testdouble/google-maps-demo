module.exports = drawRoutes: (app) ->

  app.get '/api/work-orders', (req, res) ->
    res.json workOrders: [
      { description: "Cbus10", address: "10 W Broad ST", city: "Columbus", state: "OH"},
      { description: "Easton", address: "160 Easton Town Center", city: "Columbus", state: "OH"}
    ]
