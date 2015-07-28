#!/usr/bin/env python
#coding=utf-8
import logging
from logging.handlers import RotatingFileHandler
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import  Column, Integer, String, Float, Text
from pyicloud import PyiCloudService
import time
import requests
import os, json

# 日志
Rthandler = RotatingFileHandler('log/app.log', maxBytes=10*1024*1024,backupCount=10)
Rthandler.setLevel(logging.WARN)
formatter = logging.Formatter('%(asctime)s|%(name)s|%(threadName)s|%(levelname)s > %(message)s')
Rthandler.setFormatter(formatter)
logging.getLogger('').addHandler(Rthandler)

DB_CONNECT_STRING = 'mysql://root:@127.0.0.1/find_my'
Base = declarative_base()

class Devices(Base):
    __tablename__ = 'devices'

    id = Column(Integer, primary_key=True)
    long = Column(Float, default=None)
    lat = Column(Float, default=None)
    location_time = Column(Integer, default=0)
    add_time = Column(Integer, default=0)
    check_time = Column(Integer, default=0)
    isOld = Column(Integer, default=0)
    locationFinished = Column(Integer, default=0)
    isInaccurate = Column(Integer, default=0)
    horizontalAccuracy = Column(Float, default=0.00)
    positionType = Column(String(12), default='')
    locationType = Column(String(12), default='')
    devices_json = Column(Text, default=None)
    res_json = Column(Text, default=None)
    devices_type = Column(Integer, default=0)
    formatted_address = Column(String(64), default='')
    geo_json = Column(Text, default=None)

    def __str__(self):
        return "Devices => { \
id:%d, long:%0.2f, lat:%0.2f, location_time:%d, add_time:%d,  \
check_time:%d, isOld:%d, isInaccurate:%d, horizontalAccuracy:%0.2f, positionType:'%s',  \
locationType:'%s', devices_json:'%s', res_json:'%s', devices_type:%d," \
               " locationFinished:%d,formatted_address:%s,geo_json:%s}" % (
self.id, self.long, self.lat, self.location_time, self.add_time,
self.check_time, self.isOld, self.isInaccurate, self.horizontalAccuracy, self.positionType,
self.locationType, self.devices_json, self.res_json, self.devices_type, self.locationFinished,self.formatted_address, self.geo_json)

    __repr__ = __str__


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
    if data['status'] == 0:
        return data['result'][0]['x'], data['result'][0]['y']
    else:
        return 0, 0

def Geocoding(long, lat):
    """
    经纬度获取街道信息
    :param long: 经度
    :param lat: 维度
    :return: 地址，json信息
    """
    baidu_key = os.environ.get('baidu', '')
    url = "http://api.map.baidu.com/geocoder/v2/?location=%s,%s&output=json&pois=1&ak=%s"\
        %(lat, long, baidu_key)

    r = requests.get(url)
    print("Geocoding url ==> %s" % r.url)
    print("Geocoding text ==> %s" % r.text)
    data = r.json()
    if data['status'] == 0:
        return data['result']['formatted_address'], json.dumps(data)
    else:
        return "", json.dumps(data)




def devices_info_save():
    """
    保存获取到的设备信息
    :return:
    """
    print("开始执行获取设备信息任务")
    logging.warn("开始执行获取设备信息任务")

    engine      = create_engine(DB_CONNECT_STRING, echo=False)
    DB_Session  = sessionmaker(bind=engine)
    session     = None

    try:
        name = os.environ.get('icloud_name', '')
        password = os.environ.get('icloud_password', '')
        api = PyiCloudService(name, password)
        devices_res = api.devices[0].status()
        location_res = api.devices[0].location()
        print(location_res)

    except Exception, e:
        logging.warn(e)
        print(e)
        print("链接icloud错误")
        return ""


    device = Devices()
    device.long, device.lat = changeposition(location_res['longitude'], location_res['latitude'])
    device.formatted_address, device.geo_json = Geocoding(device.long, device.lat)
    device.horizontalAccuracy = location_res['horizontalAccuracy']
    device.location_time = int(location_res['timeStamp'] / 1000)
    device.res_json = json.dumps(location_res)
    device.devices_json = json.dumps(devices_res)
    device.check_time = int(time.time())
    device.add_time = int(time.time())

    if location_res['locationFinished']:
        device.locationFinished = 1
    else:
        # 如果定位没有结束则休息90秒
        pass
        # time.sleep(90)
        # return devices_info_save()

    if location_res['isOld']:
        device.isOld = 1
    if location_res['isInaccurate']:
        device.isInaccurate = 1
    if location_res['positionType'] is not None:
        device.positionType = location_res['positionType']
    if location_res['locationType'] is not None:
        device.locationType = location_res['locationType']

    try:
        session = DB_Session()
        session.add(device)
        session.commit()
    except Exception, e:
        logging.warn(e)
        print e

    finally:
        if session:
            session.close()

    print("保存设备信息完成")
    logging.warn("保存设备信息完成")




devices_info_save()





