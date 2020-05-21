# -*- coding: UTF-8 -*-
import freeswitch
import ConfigParser
import sys
import re
import time
from include import function
from ESL import *

#config.ini
rootdir = freeswitch.getGlobalVariable("base_dir")
config = ConfigParser.SafeConfigParser()
config.read(rootdir+"/scripts/callcenter/config.ini")
WebServiceURL = config.get('webservice', 'WebServiceURL')
AgentSipIf = config.get('webservice', 'AgentSipIf')
EnableRecord = config.getboolean('webservice', 'EnableRecord')
RecoardPath = config.get('webservice', 'RecoardPath')
Agent_record = config.get('webservice','Agent_record')

def runtime(args):
    freeswitch.msleep(2000)
    freeswitch.consoleLog("INFO","\nCallcenter initializing!\n")
    params = {}
    params["action"] = "InitSystem"
    msg = function.request_get(WebServiceURL,params)
    if msg:
        freeswitch.consoleLog("INFO","\nCallcenter initializ success!\n")
    else:
        freeswitch.consoleLog("ERR","\nCallcenter initializ  failed!\n")
        return
    api = freeswitch.API()
    con = ESLconnection("127.0.0.1","8024","Clue1234")
    con.events("plain", "CHANNEL_CALLSTATE")
    if con.connected:
        while True:
            e = con.recvEvent()
            ch = e.getHeader("Caller-Channel-Name")
            ccs = e.getHeader("Channel-Call-State")
            occs = e.getHeader("Original-Channel-Call-State")
            direction = e.getHeader("Caller-Direction")
            cna = e.getHeader("Caller-Network-Addr")
            olna = e.getHeader("Other-Leg-Network-Addr")
            urlparam = {}
            answerts = 0
            ORIGIN_TIME = "1970-01-01 08:00:00"
            post = False
            put = False
            able = False
              #-------呼出---------
            if ch != None and re.match(AgentSipIf,ch) and direction =="inbound":
                #freeswitch.consoleLog("info",e.serialize("text"))
                agent = e.getHeader("Caller-Caller-ID-Number")
                uuid = e.getHeader("Caller-Unique-ID")
                other_number = e.getHeader("Caller-Destination-Number")
                bleg_uuid = e.getHeader("Other-Leg-Unique-ID")
                if re.match(Agent_record,agent):
                    able = True
                if agent:
                    if ccs == "RINGING":
                        urlparam["action"] = "AgentCalloutRinging"
                        urlparam["agent_name"] = agent
                        urlparam["uuid"]  = uuid
                        urlparam["created_datetime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Created-Time"))
                        urlparam["other_number"] = other_number
                        urlparam["bleg_uuid"] = bleg_uuid
                        urlparam["calling_ip"] = cna
                        post = True												
                    elif ccs == "ACTIVE":
                        urlparam["action"] = "AgentCalloutAndwered"
                        urlparam["agent_name"] = agent			
                        urlparam["uuid"] = uuid		
                        urlparam["other_number"] = other_number
                        urlparam["bleg_uuid"] = bleg_uuid
                        urlparam["calling_ip"] = cna
                        urlparam["called_ip"] = olna
                        urlparam["created_datetime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Created-Time"))
                        urlparam["answered_datetime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Answered-Time"))
                        answerts = function.format_unixtime_from_us(e.getHeader("Caller-Channel-Answered-Time"))
                        put = True					
                    elif ccs == "HANGUP":				    
                        urlparam["action"] = "AgentCalloutHangup"
                        urlparam["agent_name"] = agent		
                        urlparam["uuid"] = uuid			
                        urlparam["other_number"] = other_number
                        urlparam["bleg_uuid"] = bleg_uuid
                        urlparam["calling_ip"] = cna
                        urlparam["called_ip"] = olna	
                        urlparam["created_datetime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Created-Time"))
                        urlparam["answered_datetime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Answered-Time"))
                        urlparam["hangup_datetime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Hangup-Time"))
                        urlparam["hangup_cause"] = e.getHeader("Hangup-Cause")
                        origin_time = function.format_unixtime_from_date(urlparam["answered_datetime"])
                        if str(origin_time) == ORIGIN_TIME:
                            urlparam["answered_datetime"] = urlparam["hangup_datetime"]
                        put = True
             #-------呼入---------
            elif ch != None and re.match(AgentSipIf,ch) and direction =="outbound":
                #freeswitch.consoleLog("info",e.serialize("text"))
                agent = e.getHeader("Caller-Callee-ID-Number")
                uuid = e.getHeader("Caller-Unique-ID")
                other_number = e.getHeader("Caller-Caller-ID-Number")
                bleg_uuid = e.getHeader("Other-Leg-Unique-ID")
                if re.match(Agent_record,agent):
                    able = True
                if agent:
                    if ccs == "RINGING":
                        urlparam["action"] = "AgentCallinRinging"
                        urlparam["agent_name"] = agent
                        urlparam["uuid"]  = uuid
                        urlparam["calling_ip"] = cna
                        urlparam["created_datetime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Created-Time"))
                        urlparam["other_number"] = other_number
                        urlparam["bleg_uuid"] = bleg_uuid
                        post = True											
                    elif ccs == "ACTIVE":
                        urlparam["action"] = "AgentCallinAndwered"
                        urlparam["agent_name"] = agent		
                        urlparam["uuid"] = uuid		
                        urlparam["other_number"] = other_number
                        urlparam["bleg_uuid"] = bleg_uuid
                        urlparam["calling_ip"] = cna
                        urlparam["called_ip"] = olna
                        urlparam["created_datetime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Created-Time"))
                        urlparam["answered_datetime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Answered-Time"))
                        answerts = function.format_unixtime_from_us(e.getHeader("Caller-Channel-Answered-Time"))
                        put = True	
                    elif ccs == "HANGUP":				    
                        urlparam["action"] = "AgentCallinHangup"
                        urlparam["agent_name"] = agent		
                        urlparam["uuid"] = uuid			
                        urlparam["other_number"] = other_number
                        urlparam["bleg_uuid"] = bleg_uuid	
                        urlparam["calling_ip"] = cna
                        urlparam["called_ip"] = olna
                        urlparam["created_datetime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Created-Time"))
                        urlparam["answered_datetime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Answered-Time"))
                        urlparam["hangup_datetime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Hangup-Time"))
                        urlparam["hangup_cause"] = e.getHeader("Hangup-Cause")
                        origin_time = function.format_unixtime_from_date(urlparam["answered_datetime"])
                        if str(origin_time) == ORIGIN_TIME:
                            urlparam["answered_datetime"] = urlparam["hangup_datetime"]
                        put = True
            if ccs == "ACTIVE" and EnableRecord and able and 0 != answerts:
                path = rootdir+RecoardPath+time.strftime("%Y-%m-%d",answerts)+"/"+urlparam["agent_name"]+"/"
                recfile = path+urlparam["uuid"]+"_"+urlparam["agent_name"]+"_"+urlparam["other_number"]+"_"+time.strftime("%Y%m%d%H%M%S",answerts)+".wav"
                api.execute("uuid_record",urlparam["uuid"]+" start "+recfile)
            if post and able:
                msg = function.request_post(WebServiceURL, urlparam)
                if not msg:
                    freeswitch.consoleLog("ERR","\n"+msg+"\n")
            elif put and able:
                result = function.request_put(WebServiceURL, urlparam)
                if result != "success":
                    freeswitch.consoleLog("ERR","\n"+result+"\n")
        freeswitch.msleep(200)
    freeswitch.consoleLog("INFO","\nagent event thread exit!\n")