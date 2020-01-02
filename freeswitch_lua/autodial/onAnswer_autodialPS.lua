session:setAutoHangup(false);
local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
local cf = DecryptFile(rootdir.."/scripts/autodial/reg.sn");
if cf == nil then
	freeswitch.consoleLog("ERR","\nautodial system not register ,please call qq:674822668!\n");
	return;
end
--lua 5.1
--loadstring(cf)();
--lua 5.2
load(cf)();
if os.difftime(os.time(ValidDate),os.time()) <0 then
	freeswitch.consoleLog("ERR","autodial system expire!\n");
	return;
end	

if argv[1] == nil or argv[2] == nil  then
	freeswitch.consoleLog("ERR","autodial on answer params error!\n");
	return ;
end
loadfile(rootdir.."/scripts/autodial/config.lua")();
local userid = argv[1];
local aleguuid = argv[2];
local api = freeswitch.API();
freeswitch.consoleLog("INFO","Autodial number answer!\n");
api:executeString("uuid_setvar "..aleguuid.." autodialps_callee_answered true"); 
urlparam = {};
urlparam["action"] = "answered";
urlparam["userid"] = userid;
request_http(Autodial_WebServiceURL,urlparam);			
