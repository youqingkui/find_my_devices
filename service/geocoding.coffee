Devices = require('../models/devices')
async = require('async')
request = require('request')

class Geocoding
  constructor: (@devInfo) ->
    @url = 'http://api.map.baidu.com/geocoder/v2/?location=' +
        @devInfo.long + ',' + @devInfo.lat + '&output=json&pois=1&ak=' + process.env.baidu


#  findInfo:(cb) ->
#    self = @
#    Devices.findById self.id, (err, row) ->
#      return console.log err if err
#
#      if not row
#        return console.log "not find id", self.id
#
#      cb(null, row)


  getGeo:(cb) ->
    self = @
    request.get self.url, (err, res, body) ->
      return console.log err if err

      try
        data = JSON.parse(body)
      catch
        return console.log "JONS parse error:", body

      if data.status != 0
        return console.log "转换错误:", data

      cb(null, data)


  saveGeo:(cb) ->
    self = @
    async.waterfall [
      (callbacl) ->
        self.getGeo (err, data) ->
          return console.log err if err

          callbacl(null, data)

      (data, callback) ->
        @devInfo.geo_json = data
        @devInfo.formatted_address = data.result.formatted_address
    ]
















