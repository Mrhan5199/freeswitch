import freeswitch
import ConfigParser
from include import function

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
    api = freeswitch.API()
    params = {}
    params["action"] = "InitSystem"
    msg = function.request_get(WebServiceURL,params)
    if msg:
        api.execute("pyrun","callcenter.agent_event_thread")
        freeswitch.consoleLog("INFO","\ncallcenter initializ success!\n")
        return
    else:
        freeswitch.consoleLog("ERR","\nCallcenter initialize failed!\n")
        return
    