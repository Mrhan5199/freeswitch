if argv[1] == nil or argv[2] == nil then
	freeswitch.consoleLog("ERR","uuid or workno not find!\n");
	return;
end
local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
--local cf = DecryptFile(rootdir.."/scripts/callcenter/reg.sn");
--if cf == nil then
--	freeswitch.consoleLog("ERR","\nsystem not register ,please call qq:674822668!\n");
--	return;
--end
--loadstring(cf)();
loadfile(rootdir.."/scripts/callcenter/config.lua")();

--if os.difftime(os.time(ValidDate),os.time()) <0 then
--	stream:write("-ERR system expire!\n");
--	return;
--end	
local api = freeswitch.API();
freeswitch.msleep(500);
for n in string.gmatch(argv[2],"([0-9])") do
	api:execute("uuid_broadcast",argv[1].." "..rootdir.."/sounds/number/"..n..".wav both"); 
end
--api:execute("uuid_broadcast",argv[1].." "..rootdir.."/sounds/number/hao.wav both");
api:execute("uuid_broadcast",argv[1].." "..rootdir.."/sounds/cc_hao_wei_ni_fu_wu.wav both");



