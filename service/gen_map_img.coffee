request = require('request')
async = require('async')
fs = require('fs')
getLocalTime = require('../help').getLocalTime

MIME_TO_EXTESION_MAPPING = {
  'image/png': '.png',
  'image/jpg': '.jpg',
  'image/jpeg': '.jpg',
  'image/gif': '.gif'
}

class GenMapImg

  constructor:(@deviceInfo) ->

    baidu = process.env.baidu
    longLat = @deviceInfo.long + ',' + @deviceInfo.lat
    @url = "http://api.map.baidu.com/staticimage?width=800&height=700&zoom=16&dpiType=ph" +
            "&center=" + longLat + '&markers=' + longLat + '&ak=' + baidu



  getImg:(cb) ->
    self = @

    async.waterfall [


      (callback) ->
        op = {
          url:self.url
          encoding:'binary'
        }
        request.get op, (err, res, body) ->
          return console.log err if err

          mimeType = res.headers['content-type']
          mimeType = mimeType.split(';')[0]
          image = new Buffer(body, 'binary')
          callback(null, image, mimeType)

      (image, mimeType, callback) ->
        baseDir = __dirname + '/static'
        checkTime = getLocalTime(self.deviceInfo.check_time)
        locationTime = getLocalTime(self.deviceInfo.location_time)
        fileRes = baseDir + '/' + checkTime + '/' + locationTime + MIME_TO_EXTESION_MAPPING[mimeType]
        dir = baseDir + '/' + checkTime
        if !fs.existsSync(dir)
          fs.mkdirSync(dir)

        fs.writeFileSync fileRes, image
        console.log "write ok"

    ]





gmi = new GenMapImg({long:114.0296431124400, lat:22.6402391251580, check_time:1438094699, location_time:1438094631})
console.log __dirname
console.log process.cwd()
gmi.getImg()






