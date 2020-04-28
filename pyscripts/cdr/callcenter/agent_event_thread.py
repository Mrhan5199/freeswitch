# -*- coding: UTF-8 -*-
import freeswitch
import sys
import re
import time
import callcenter_init
from include import function

def fsapi(session, stream, env, args):
    if args:
        string = re.split('\s+', args)
        argv1 = string[0]
        if argv1 == "stop":
            event = freeswitch.Event("CUSTOM","ZSWITCH:AGENT-EVENT-THREAD")
            event.addHeader("Action", "stop")
            event.fire()
    else:
        freeswitch.consoleLog('ERR', 'must argv1 profile %s\n'  % args)
    return

def runtime(args):
    event = freeswitch.Event("CUSTOM","ZSWITCH:AGENT-EVENT-THREAD")
    event.addHeader("Action", "stop")
    event.fire()
    rootdir = freeswitch.getGlobalVariable("base_dir")
    CtrlEvent = freeswitch.EventConsumer("CUSTOM","ZSWITCH:AGENT-EVENT-THREAD")
    AgentEvent = freeswitch.EventConsumer("CHANNEL_CALLSTATE")
    if  not CtrlEvent and not AgentEvent:
        freeswitch.consoleLog("ERR","\nblind event failure ! agent event thread start failure!\n")
    freeswitch.consoleLog("INFO","\nagent event thread start!\n")
    api = freeswitch.API()
    while True:
        ce = CtrlEvent.pop()
        if ce and "stop" == ce.getHeader("action"):
            break
        while True:
            e = AgentEvent.pop()
            if not e:
                break
            else:
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
            if re.match(callcenter_init.AgentSipIf,ch) and direction =="inbound":
                #freeswitch.consoleLog("info",e.serialize("text"))
                agent = e.getHeader("Caller-Caller-ID-Number")
                uuid = e.getHeader("Caller-Unique-ID")
                other_number = e.getHeader("Caller-Destination-Number")
                bleg_uuid = e.getHeader("Other-Leg-Unique-ID")
                if re.match(callcenter_init.Agent_record,agent):
                    able = True
                if agent:
                    if ccs == "EARLY":
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
                    elif ccs == "HANGUP" and occs != "RINGING":				    
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
            elif re.match(callcenter_init.AgentSipIf,ch) and direction =="outbound":
                #freeswitch.consoleLog("info",e.serialize("text"))
                agent = e.getHeader("Caller-Callee-ID-Number")
                uuid = e.getHeader("Caller-Unique-ID")
                other_number = e.getHeader("Caller-Caller-ID-Number")
                bleg_uuid = e.getHeader("Other-Leg-Unique-ID")
                if re.match(callcenter_init.Agent_record,agent):
                    able = True
                if agent:
                    if ccs == "EARLY":
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
                    elif ccs == "HANGUP" and occs != "RINGING":				    
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
            if ccs == "ACTIVE" and callcenter_init.EnableRecord and able and 0 != answerts:
                path = rootdir+callcenter_init.RecoardPath+time.strftime("%Y-%m-%d",answerts)+"/"+urlparam["agent_name"]+"/"
                recfile = path+urlparam["uuid"]+"_"+urlparam["agent_name"]+"_"+urlparam["other_number"]+"_"+time.strftime("%Y%m%d%H%M%S",answerts)+".wav"
                api.execute("uuid_record",urlparam["uuid"]+" start "+recfile)
            if post and able:
                msg = function.request_post(callcenter_init.WebServiceURL, urlparam)
                if not msg:
                    freeswitch.consoleLog("ERR","\n"+msg+"\n")
            elif put and able:
                result = function.request_put(callcenter_init.WebServiceURL, urlparam)
                if result != "success":
                    freeswitch.consoleLog("ERR","\n"+result+"\n")
        freeswitch.msleep(200)
    freeswitch.consoleLog("INFO","\nagent event thread exit!\n")

	
