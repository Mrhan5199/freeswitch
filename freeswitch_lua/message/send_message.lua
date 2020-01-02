local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
local cf = DecryptFile(rootdir.."/scripts/callcenter/reg.sn");
if cf == nil then
	freeswitch.consoleLog("ERR","\nsystem not register ,please call qq:674822668!\n");
	return;
end

--freeswitch.consoleLog("ERR",cf);
loadstring(cf)();
--load(cf)();
loadfile(rootdir.."/scripts/message/config.lua")();

if os.difftime(os.time(ValidDate),os.time()) <0 then
	freeswitch.consoleLog("ERR","\nsystem expire!\n");
	return;
end		



freeswitch.consoleLog("info", "send MESSAGE \n")   
local event = freeswitch.Event("CUSTOM", "SMS::SEND_MESSAGE");
event:addHeader("dest_proto", "sip");
event:addHeader("from", "1003@192.168.0.50");
event:addHeader("to", "1000@192.168.0.50");
event:addHeader("sip_profile", "internal");
event:addBody("Hello from Seven Du! Have fun!");
event:fire();
