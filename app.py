#!/usr/bin/env python
#coding=utf-8
import logging
from logging.handlers import RotatingFileHandler
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Table, Column, Integer, String, Float, Text
from mongoengine import *
from pyicloud import PyiCloudService
import time
import requests
import os

# 日志
Rthandler = RotatingFileHandler('log/app.log', maxBytes=10*1024*1024,backupCount=10)
Rthandler.setLevel(logging.WARN)
formatter = logging.Formatter('%(asctime)s|%(name)s|%(threadName)s|%(levelname)s > %(message)s')
Rthandler.setFormatter(formatter)
logging.getLogger('').addHandler(Rthandler)

# 链接数据库
connect('find_my')



class Devices(Document):
    res = DictField()
    check_time = IntField()
    add_time = IntField()
    c_long = FloatField()
    long = FloatField()
    c_lat = FloatField()
    lat = FloatField()
    location_time = IntField()
    positionType = StringField()
    horizontalAccuracy = FloatField()
    devices_dict = DictField()

def changeposition(long, lat):
    """
    将得到的坐标转换为百度坐标
    :param lat: 维度
    :param long: 经度
    :return: long, lat
    """
    baidu_key = os.environ.get('baidu', '')

    url = 'http://api.map.baidu.com/geoconv/v1/?from=1&to=5&coords=%s,%s&ak=%s'\
            %(long, lat, baidu_key)

    r = requests.get(url)
    print(r.url)
    print(r.text)
    data = r.json()
    if data.status == 0:
        return data.result[0].x, data.result[0].y
    else:
        return 0, 0




# api = PyiCloudService('', '')
# info = api.devices[0].location()
#
#
# devices = Devices()
# devices.devices_dict = api.devices
# devices.res = info
# devices.add_time = int(time.time())
# devices.check_time = int(time.time())
# devices.lat = info['longitude']
# devices.c_lat = info['longitude']
# devices.long = info['latitude']
# devices.c_long = info['latitude']
# devices.positionType = info['positionType']
# devices.horizontalAccuracy = info['horizontalAccuracy']
#
#
# print(info['horizontalAccuracy'])
# print(devices.devices_dict)
# devices.save()

find = Devices.objects(check_time=1437653316)
for f in find:
    print(f._id)



