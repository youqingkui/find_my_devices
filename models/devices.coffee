T = require("toshihiko")
toshihiko = require("./toshihiko.js")

Devices = toshihiko.define 'devices',
  [
    {
      name: "id"
      type: T.Type.Integer
      primaryKey: true
    }
    {
      name: "long"
      type: T.Type.Float
      defaultValue: null
    }
    {
      name: "lat"
      type: T.Type.Float
      defaultValue: null
    }
    {
      name: "location_time"
      type: T.Type.Integer
      defaultValue: "0"
    }
    {
      name: "add_time"
      type: T.Type.Integer
      defaultValue: "0"
    }
    {
      name: "check_time"
      type: T.Type.Integer
      defaultValue: "0"
    }
    {
      name: "isOld"
      type: T.Type.Integer
      defaultValue: "0"
    }
    {
      name: "isInaccurate"
      type: T.Type.Integer
      defaultValue: "0"
    }
    {
      name: "horizontalAccuracy"
      type: T.Type.String
      defaultValue: "0.00"
    }
    {
      name: "positionType"
      type: T.Type.String
      defaultValue: ""
    }
    {
      name: "locationType"
      type: T.Type.String
      defaultValue: ""
    }
    {
      name: "devices_json"
      type: T.Type.Json
      defaultValue: null
    }
    {
      name: "res_json"
      type: T.Type.Json
      defaultValue: null
    }
    {
      name: "devices_type"
      type: T.Type.Integer
      defaultValue: "0"
    }
    {
      name: "locationFinished"
      type: T.Type.Integer
      defaultValue: "0"
    }
    {
      name: "formatted_address"
      type: T.Type.String
      defaultValue: ""
    }
    {
      name: "geo_json"
      type: T.Type.Json
      defaultValue: null
    }
    {
      name: "img_src"
      type: T.Type.String
      defaultValue: ""
    }
  ]

module.exports = Devices