import time
import hashlib
import requests
import json


timestamp = int(time.time()*1000)
def get_sign(caller, called, timestamp):
    token = 'e10adc3949ba59abbe56e057f20f883e'
    arr = [
        "appkey=chengduqidian",
        "method=callback",
        "format=json",
        "server=robot",
    ]
    arr.append("time="+str(timestamp))
    arr.append("caller="+str(caller))
    arr.append("called="+str(called))
    arr.sort()
    md5 = hashlib.md5()
    str1 = "".join(arr)+token
    md5.update(str1.encode('utf-8'))
    return md5.hexdigest()



def request_post(caller, called, timestamp):
    data = {
        "caller":caller,
        "called":called
    }
    sign = get_sign(data['caller'], data['called'], timestamp)
    headers = {
        "sign":sign,
        "server":"robot",
        "time":str(timestamp),
        "format":"json",
        "method":"callback",
        "appkey":"chengduqidian"
    }
    url = 'http://call.51bxt.cn/api/api.ashx'
    req = requests.post(url=url, data=data, headers=headers)
    print(json.loads(req.content))
request_post("16602807823", "17602870878", timestamp)




# def fsapi(session, stream, env, args):
#     if args:
#         string = re.split('\s+', args)
#     else:
#         freeswitch.consoleLog('ERR', 'must argv1 profile %s\n')
#     caller = string[0]
#     called = string[1]
#     request_post(caller, called, timestamp)


