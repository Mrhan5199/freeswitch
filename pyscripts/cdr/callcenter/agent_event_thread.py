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
            if False:
                freeswitch.consoleLog("ERR","\nzswitch callcenter system expire!\n")
            else:
                ch = e.getHeader("Caller-Channel-Name")
			    ccs = e.getHeader("Channel-Call-State")
			    direction = e.getHeader("Caller-Direction")
			    urlparam = {}
			    answerts = 0
                msg = 0
                ORIGIN_TIME = "1970-01-01 08:00:00"
                post = False
                put = False
                able = False
            #-------呼出---------
            if re.match(callcenter_init.AgentSipIf,ch) and direction =="inbound":
                agent = e.getHeader("Caller-Caller-ID-Number")
			    uuid = e.getHeader("Caller-Unique-ID")
			    otherNumber = e.getHeader("Caller-Destination-Number")
			    bleguuid = e.getHeader("Other-Leg-Unique-ID")
                if re.match(callcenter_init.Agent_record,agent):
                    able = True
                if agent:
                    if ccs == "EARLY":
                        urlparam["action"] = "AgentCalloutRinging"
                        urlparam["agent"] = agent
                        urlparam["queue"] = ""
                        urlparam["UUID"]  = uuid
                        urlparam["startTime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Created-Time"))
                        urlparam["otherNumber"] = otherNumber
                        urlparam["blegUUID"] = bleguuid
                        post = True												
                    elif ccs == "ACTIVE":
                        urlparam["action"] = "AgentCalloutAndwered"
                        urlparam["agent"] = agent
                        urlparam["queue"] = ""			
                        urlparam["UUID"] = uuid		
                        urlparam["otherNumber"] = otherNumber
                        urlparam["blegUUID"] = bleguuid
                        urlparam["startTime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Created-Time"))
                        urlparam["answerTime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Answered-Time"))
                        answerts = function.format_unixtime_from_us(e.getHeader("Caller-Channel-Answered-Time"))
                        put = True					
                    elif ccs == "HANGUP":				    
                        urlparam["action"] = "AgentCalloutHangup"
                        urlparam["agent"] = agent
                        urlparam["queue"] = ""		
                        urlparam["UUID"] = uuid			
                        urlparam["otherNumber"] = otherNumber
                        urlparam["blegUUID"] = bleguuid	
                        urlparam["startTime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Created-Time"))
                        urlparam["answerTime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Answered-Time"))
                        urlparam["hangupTime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Hangup-Time"))
                        urlparam["hangupCase"] = e.getHeader("Hangup-Cause")
                        origin_time = function.format_unixtime_from_date(urlparam["answerTime"])
                        if str(origin_time) == ORIGIN_TIME:
                            urlparam["answerTime"] = urlparam["hangupTime"]
                        put = True
             #-------呼入---------
            if re.match(callcenter_init.AgentSipIf,ch) and direction =="outbound":
                agent = e.getHeader("Caller-Callee-ID-Number")
			    uuid = e.getHeader("Caller-Unique-ID")
			    otherNumber = e.getHeader("Caller-Caller-ID-Number")
			    bleguuid = e.getHeader("Other-Leg-Unique-ID")
                if re.match(callcenter_init.Agent_record,agent):
                    able = True
                if agent:
                    if ccs == "EARLY":
                        urlparam["action"] = "AgentCallinRinging"
                        urlparam["agent"] = agent
                        urlparam["queue"] = ""
                        urlparam["UUID"]  = uuid
                        urlparam["startTime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Created-Time"))
                        urlparam["otherNumber"] = otherNumber
                        urlparam["blegUUID"] = bleguuid
                        post = True											
                    elif ccs == "ACTIVE":
                        urlparam["action"] = "AgentCallinAndwered"
                        urlparam["agent"] = agent
                        urlparam["queue"] = ""			
                        urlparam["UUID"] = uuid		
                        urlparam["otherNumber"] = otherNumber
                        urlparam["blegUUID"] = bleguuid
                        urlparam["startTime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Created-Time"))
                        urlparam["answerTime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Answered-Time"))
                        answerts = function.format_unixtime_from_us(e.getHeader("Caller-Channel-Answered-Time"))
                        put = True	
                    elif ccs == "HANGUP":				    
                        urlparam["action"] = "AgentCallinHangup"
                        urlparam["agent"] = agent
                        urlparam["queue"] = ""		
                        urlparam["UUID"] = uuid			
                        urlparam["otherNumber"] = otherNumber
                        urlparam["blegUUID"] = bleguuid	
                        urlparam["startTime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Created-Time"))
                        urlparam["answerTime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Answered-Time"))
                        urlparam["hangupTime"] = function.format_unixtime_from_sec(e.getHeader("Caller-Channel-Hangup-Time"))
                        urlparam["hangupCase"] = e.getHeader("Hangup-Cause")
                        origin_time = function.format_unixtime_from_date(urlparam["answerTime"])
                        if str(origin_time) == ORIGIN_TIME:
                            urlparam["answerTime"] = urlparam["hangupTime"]
                        put = True

            if ccs == "ACTIVE" and callcenter_init.EnableRecord and able and 0 != answerts:
                path = rootdir+callcenter_init.RecoardPath+time.strftime("%Y-%m-%d",answerts)+"/"+urlparam["agent"]+"/"
                recfile = path+urlparam["UUID"]+"_"+urlparam["agent"]+"_"+urlparam["otherNumber"]+"_"+time.strftime("%Y%m%d%H%M%S",answerts)+".wav"
                api.execute("uuid_record",urlparam["UUID"]+" start "+recfile)
            if post and able:
                msg = function.request_post(callcenter_init.WebServiceURL, urlparam)
                if not msg:
                    freeswitch.consoleLog("ERR","\n"+msg+"\n")
            if put and msg == 0:
                freeswitch.consoleLog("INFO","\ninvalid call!\n")
            elif put and msg != 0 and able:
                result = function.request_put(callcenter_init.WebServiceURL, urlparam, msg)
                if result != "success":
                    freeswitch.consoleLog("ERR","\n"+msg+"\n")
            freeswitch.msleep(200)
    freeswitch.consoleLog("INFO","\nagent event thread exit!\n")

	
