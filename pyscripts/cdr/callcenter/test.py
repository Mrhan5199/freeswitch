#!/usr/bin/python
##Polling file
import time
import freeswitch
import re
import random

rootdir = freeswitch.getGlobalVariable("base_dir");
api = freeswitch.API();
file_path = rootdir+"/scripts/strategy/number"

def file_list(filename):
    num_list = []
    file = open(filename,"r")
    for line in file.readlines():
        line = line.strip('\n')
        num_list.append(line)
    file.close()
    return num_list

def check_gateway_limits(key, limits, upgw):
    total_number = 0
    last_day = 0
    today = time.strftime("%Y%m%d", time.localtime())
    if api.executeString("db exists/call_limit_last_count_of_day/data_time") == "false":
        api.executeString("db insert/call_limit_last_count_of_day/data_time/"+str(today))
    else:
        last_day = api.executeString("db select/call_limit_last_count_of_day/data_time")
    if api.executeString("db exists/call_limit_value_count_of_day/"+str(key)) == "false":
        api.executeString("db insert/call_limit_value_count_of_day/"+str(key)+"/0")
    else:
        count = api.executeString("db select/call_limit_value_count_of_day/"+str(key))
        total_number = int(count)
    if today != last_day:
        total_number = 0
        api.executeString("db delete/call_limit_value_count_of_day/data_time")
        for k in range(len(upgw)):
            api.executeString("db delete/call_limit_value_count_of_day/"+str(upgw[k]))
        api.executeString("db insert/call_limit_last_count_of_day/data_time/"+str(today))
    if total_number < int(limits):
        total_number = total_number + 1
        api.executeString("db insert/call_limit_value_count_of_day/"+str(key)+"/"+str(total_number))
        return True
    else:
        return False

def handler(session, args):
    pass

def fsapi(session, stream, env, args):
    count, fullgw, current_pos, new_pos, idx = 0, 0, 0, 0, 0
    upgw = []
    if args:
        string = re.split('\s+', args)
    else:
        freeswitch.consoleLog('ERR', 'must argv1 profile %s\n')
    argv1 = string[0]
    upgw_list = file_list(file_path)
    for gw in range(len(upgw_list)):
        if re.search(r"State\s+REGED\s+",api.executeString("sofia status gateway "+upgw_list[gw])):
            upgw.append(upgw_list[gw])
            count = count + 1
    if api.executeString("db exists/gateway_route/current_pos") == "false":
        api.executeString("db insert/gateway_route/current_pos/0")
    current_pos = api.executeString("db select/gateway_route/current_pos")
    if int(current_pos) >= count:
        current_pos = 0
    new_pos = int(current_pos) + 1
    idx = int(current_pos)
    api.executeString("db insert/gateway_route/current_pos/"+str(new_pos))
    info = api.executeString("show channels")
    while True:
        if not re.search("sofia/gateway/"+upgw[idx],info):
            if check_gateway_limits(upgw[idx],argv1,upgw):
                stream.write(str(upgw[idx]))
                freeswitch.consoleLog("info", "Discovery of available gateway: %s\n" % upgw[idx])
                break
            else:
                idx = idx + 1
                fullgw = fullgw + 1
                if idx >= count:
                    idx = 0
                if fullgw == count:
                    freeswitch.consoleLog("err", "The number limit has been reached: %s\n" % argv1)
                    break
        else:
            idx = idx + 1
            fullgw = fullgw + 1
            if idx >= count:
                idx = 0
            if fullgw == count:
                freeswitch.consoleLog("err", "The number limit has been reached: %s\n" % argv1)
                break