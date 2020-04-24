import time, datetime
import freeswitch
import re

STM_1 = "09:00:00"
STM_2 = "12:00:00"
STM_3 = "14:00:00"
STM_4 = "18:00:00"
current_hours = time.strftime("%H:%M:%S", time.localtime())
today = time.strftime("%Y-%m-%d", time.localtime())
rootdir = freeswitch.getGlobalVariable("base_dir")
api = freeswitch.API()
file_path = rootdir+"/scripts/pyscripts/sipnumber/number"

def file_list(filename):
    num_list = []
    file = open(filename,"r")
    for line in file.readlines():
        line = line.strip('\n')
        num_list.append(line)
    file.close()
    return num_list

def get_date_time_now():
    today = time.strftime("%Y-%m-%d", time.localtime())
    if api.executeString("db exists/call_limit_last_count_of_day/data_time") == "false":
        api.executeString("db insert/call_limit_last_count_of_day/data_time/"+str(today))
    return api.executeString("db select/call_limit_last_count_of_day/data_time")

def set_data_time_now():
    today = time.strftime("%Y-%m-%d", time.localtime())
    api.executeString("db insert/call_limit_last_count_of_day/data_time/"+str(today))
    return False

def check_gateway_limits_per_hours(key, limit, upgw):
    start_table = []
    new_table = []
    count = 0
    current_hours = time.strftime("%H:%M:%S", time.localtime())
    last_day = get_date_time_now()
    hours_ago = (datetime.datetime.now()+datetime.timedelta(hours=-1)).strftime("%H:%M:%S")
    start_table.append(current_hours)
    if today != last_day:
        for k in range(len(upgw)):
            api.executeString("db delete/call_limit_value_per_hours/"+str(upgw[k]))
    if api.executeString("db exists/call_limit_value_per_hours/"+str(key)) == "false":
        api.executeString("db insert/call_limit_value_per_hours/"+str(key)+"/"+str(start_table))
    else:
        string = api.executeString("db select/call_limit_value_per_hours/"+str(key))
        new_str = string.replace('[','').replace(']','').replace(",","")
        table_list = new_str.split()
        if len(table_list) < int(limit):
            for i in range(len(table_list)):
                if table_list[i] > hours_ago:
                    new_table.append(table_list[i])
            new_table.append(current_hours)
            api.executeString("db insert/call_limit_value_per_hours/"+str(key)+"/"+str(new_table))
        else:
            if len(table_list) == int(limit):
                for i in range(len(table_list)):
                    if table_list[i] > hours_ago:
                        new_table.append(table_list[i])
                if len(new_table) == int(limit):
                    return False
                else:
                    new_table.append(current_hours)
                    api.executeString("db insert/call_limit_value_per_hours/"+str(key)+"/"+str(new_table))
                    return True
    return True
   
def check_dst_number_onece(caller, dst, upgw):
    table = []
    gateway = "gw_"+str(caller)
    table.append(str(dst))
    last_day = get_date_time_now()
    if api.executeString("db exists/call_limit_value_diffnum_onece/"+gateway) == "false":
        api.executeString("db insert/call_limit_value_diffnum_onece/"+gateway+"/"+str(table))
    else:
        if last_day != today:
            for k in range(len(upgw)):
                set_data_time_now()
                api.executeString("db delete/call_limit_value_diffnum_onece/"+"gw_"+str(upgw[k]))
        string = api.executeString("db select/call_limit_value_diffnum_onece/"+gateway)
        new_str = string.replace('[','').replace(']','').replace(",","")
        table_list = new_str.split()
        for i in range(len(table_list)):
            if str(table_list[i]) == str(dst):
                return False
        table_list.append(str(dst))
        api.executeString("db insert/call_limit_value_diffnum_onece/"+gateway+"/"+str(table_list))
    return True

def check_gateway_limits_per_day(key, limits, upgw):
    last_day = get_date_time_now()
    if today != last_day:
        for k in range(len(upgw)):
            api.executeString("db delete/call_limit_value_count_of_day/"+str(upgw[k]))
    if api.executeString("db exists/call_limit_value_count_of_day/"+str(key)) == "false":
        api.executeString("db insert/call_limit_value_count_of_day/"+str(key)+"/1")
    else:
        count = api.executeString("db select/call_limit_value_count_of_day/"+str(key))
        if int(count) < int(limits):
            total = int(count) + 1
            api.executeString("db insert/call_limit_value_count_of_day/"+str(key)+"/"+str(total))
            return True
        else:
            return False
    return True

def db_insert(current_pos):
     api.executeString("db insert/gateway_route/current_pos/"+str(current_pos))

def db_select():
    return api.executeString("db select/gateway_route/current_pos")

def db_exists():
    if api.executeString("db exists/gateway_route/current_pos") == "false":
        api.executeString("db insert/gateway_route/current_pos/0")


def fsapi(session, stream, env, args):
    count, fullgw, current_pos, new_pos, idx, caller, dstnumber = 0, 0, 0, 0, 0, 0, 0
    upgw = []
    if args:
        string = re.split('\s+', args)
    else:
        freeswitch.consoleLog('info', 'must argv profile %s\n' % args)
    argv1 = string[0]
    argv2 = string[1]
    caller = session.getVariable("caller_id_number")
    dstnumber = session.getVariable("destination_number")
    if STM_1 < current_hours < STM_2 or STM_3 < current_hours < STM_4:
        upgw_list = file_list(file_path)
        for gw in range(len(upgw_list)):
            if re.search(r"State\s+REGED\s+",api.executeString("sofia status gateway "+upgw_list[gw])):
                upgw.append(upgw_list[gw])
                count = count + 1
        db_exists()
        current_pos = db_select()
        if int(current_pos) >= count:
            current_pos = 0
        new_pos = int(current_pos) + 1
        idx = int(current_pos)
        db_insert(new_pos)
        info = api.executeString("show channels")
        while True:
            if re.search("sofia/gateway/"+upgw[idx],info) is None:
                if check_gateway_limits_per_day(upgw[idx],argv1,upgw) and check_gateway_limits_per_hours(upgw[idx],argv2) and check_dst_number_onece(upgw[idx],dstnumber):
                    stream.write(str(upgw[idx]))
                    freeswitch.consoleLog("info", "Discovery of available gateway: %s\n" % upgw[idx])
                    break
            if idx == int(current_pos) - 1:
                freeswitch.consoleLog("ERR", "unavailable gateway\n")
                break
            idx = idx + 1
            if int(current_pos) >= count:
                idx = 0
            if idx >= count:
                freeswitch.consoleLog("ERR", "unavailable gateway\n")
                break
    else:
        freeswitch.consoleLog("ERR", "Not in callup time\n")
