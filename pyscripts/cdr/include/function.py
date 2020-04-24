import freeswitch
import json
import time



def request_get(url,params):
    api = freeswitch.API()
    for k,v in params.items():
        sting = k+"="+v
    result = api.execute("curl",url+"?"+sting)
    if result and json.loads(result)['result'] == "success":
        return True
    else:
        return False
    
def request_post(url, params):
    api = freeswitch.API()
    urlparams = json.dumps(params).replace(': ',':').replace(', ',',')
    result = api.execute("curl",url+" content-type application/json "+" post "+urlparams)
    return result

def request_put(url, params, pid):
    api = freeswitch.API()
    urlparams = json.dumps(params).replace(': ',':').replace(', ',',')
    result = api.execute("curl",url+pid+"/"+" content-type application/json "+" put "+urlparams)
    if not result:
        msg = "failed!"
    else:
        msg = "success"
    return msg

def format_unixtime_from_sec(timestamp):
    time_local = time.localtime(int(timestamp)/1000000)
    return time.strftime("%Y-%m-%d' '%H:%M:%S", time_local)

def format_unixtime_from_us(timestamp):
    time_local = time.localtime(int(timestamp)/1000000)
    return time_local

def format_unixtime_from_date(timestamp):
        tm = timestamp.replace("' '",' ')
        return datetime.datetime.strptime(tm, '%Y-%m-%d %H:%M:%S')
