local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
loadfile(rootdir.."/scripts/callcenter/config.lua")();

freeswitch.consoleLog("INFO","\nCallcenter initializing!\n");
local api = freeswitch.API();
api:execute("lua",rootdir.."/scripts/callcenter/agent_event_thread.lua stop");
freeswitch.msleep(2000);

local params = {};
params["action"] = "InitSystem";
local code = request_http(WebServiceURL,params);
if code then
    api:execute("luarun",rootdir.."/scripts/callcenter/agent_event_thread.lua");
else
    freeswitch.consoleLog("ERR","\ncallcenter initializ failed!\n");
    return;
end
freeswitch.consoleLog("INFO","\ncallcenter initializ success!\n");
