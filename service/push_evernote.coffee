noteStore = require('./noteStore')
Devices = require('../models/devices')
makeNote = require('./makeNote')
async = require('async')
request = require('request')
Evernote = require('evernote').Evernote
crypto = require('crypto')


class PushEvernote
  constructor:(@deviceInfoArr) ->
    @resourceArr = []


  pushNote:(cb) ->
    self = @
    async.waterfall [
      (callback) ->
        self.getImgRes (err) ->
          return console.log err if err

          callback()

      (callback) ->
        html = self.genPushContent()
        makeNote noteStore, 'hi', html, {resources:self.resourceArr}, (err, note) ->
          return console.log err if err

          console.log note

    ]



  genPushContent:() ->
    self = @
    html = ""
    for d in self.deviceInfoArr
      md5 = crypto.createHash('md5')
      md5.update(d.resource.image)
      hexHash = md5.digest('hex')
      imgTag = "<en-media type='#{d.resource.mime}' hash='#{hexHash}' />"
      html += "<h3>经纬度:" + d.long  + ", " + d.lat  + "地址:" + d.formatted_address + "</h3> "
      html += imgTag + "<hr/><br/>"
      self.resourceArr.push d.resource
    console.log html
    return html


  getImgRes:(cb) ->
    self = @
    async.eachSeries self.deviceInfoArr, (item, callback) ->
      self.readImgRes item.img_src, (err, res) ->
        return console.log err if err

        item.resource = res
        callback()

    ,() ->
      cb()

  readImgRes: (imgUrl, cb) ->
    self = @
    op = self.reqOp(imgUrl)
    op.encoding = 'binary'
    async.auto
      readImg:(callback) ->
        request.get op, (err, res, body) ->
          return cb(err) if err
          mimeType = res.headers['content-type']
          mimeType = mimeType.split(';')[0]
          callback(null, body, mimeType)

      enImg:['readImg', (callback, result) ->
        mimeType = result.readImg[1]
        image = new Buffer(result.readImg[0], 'binary')
        hash = image.toString('base64')

        data = new Evernote.Data()
        data.size = image.length
        data.bodyHash = hash
        data.body = image

        resource = new Evernote.Resource()
        resource.mime = mimeType
        resource.data = data
        resource.image = image
        cb(null, resource)
      ]


  reqOp:(getUrl) ->
    options =
      url:getUrl
      headers:
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36'

    return options



deviceArr = Devices.where({img_src:{$neq: ''}}).find (err, rows) ->
  return console.log err if err

  p = new PushEvernote(rows)
  p.pushNote()

