-- ivr callout.
--

local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
loadfile(rootdir.."/scripts/route/config.lua")();
local api =  freeswitch.API();

local number = nil
local ivr = nil
local vars = ""
if argv[1] == nil then
	freeswitch.consoleLog("ERROR","Number is empty! ");
	stream:write( "-ERR Number is empty.");
	return 
end	
number = argv[1]
if argv[2] == nil then
	freeswitch.consoleLog("ERROR","IVR name is empty! ");
	stream:write( "-ERR IVR name is empty.");
	return 
end	
ivr = argv[2]
if argv[3] ~= nil then
	vars  = "{"..argv[3].."}"
end

actx = ROUTE_CONFIG.IVRaCtx
bctx = ROUTE_CONFIG.IVRbCtx
caller = ROUTE_CONFIG.IVRCaller
timeout = ROUTE_CONFIG.IVRTimeout

local command = "bgapi originate %sloopback/%s/%s/xml %s xml %s %s %s %d"
command = string.format(command,vars,number,actx,ivr,bctx,caller,caller,timeout)
local result = api:executeString(command)
stream:write(result) 

	
