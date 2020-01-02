--Check blanklist
--

local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
loadfile(rootdir.."/scripts/route/config.lua")();
local api =  freeswitch.API();

local number = nil
if argv[1] == nil then
	if session ~= nil  then
		number = session:getVariable("destination_number");
	end 
else
	number = argv[1]
end	
if number == nil then
	freeswitch.consoleLog("WARNING","Check blanklist number is empty! ");
	return 
end

local putdata = {};
putdata["number"] = number
local code,msg,data = request_http(ROUTE_CONFIG.checkBlocklistURL,putdata);

if code ~= 0 then
	freeswitch.consoleLog("WARNING","Check blanklist failure!");
	return
end

if msg == "true" then
	if session ~= nil then
		session:hangup("CALL_REJECTED");
	end
	freeswitch.consoleLog("WARNING",number.." on the black list, no call!\n");
else
	freeswitch.consoleLog("INFO",number.." not on the black list.\n");
end

	
