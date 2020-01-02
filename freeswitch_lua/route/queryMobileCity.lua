--Query phone number belonging to the city 
--

ROUTE_CONFIG = {
--query mobile H Code url
queryHCodeURL = "http://112.74.96.208/zsidms/webservices/queryHCode.php"

}


local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
--loadfile(rootdir.."/scripts/route/config.lua")();
local api =  freeswitch.API();

if argv[1] == nil then
	freeswitch.consoleLog("ERR","Query mobile city: need to specify a number of mobile phone number.\n");
	return;
end

local omobile = argv[1];
local _,_,hcode,nb = string.find(omobile,"^0*(1%d%d%d%d%d%d)(%d%d%d%d)$");
local mobile = omobile;
local qmc_area_code = nil;

if hcode ~= nil and nb ~= nil then
    
	qmc_area_code = api:executeString("db select/hcode/"..hcode);
	
	if qmc_area_code == nil or string.len(qmc_area_code) == 0 then	
		data = {};
		data["mobile"] = omobile;
		
		local code,msg,data = request_http(ROUTE_CONFIG.queryHCodeURL,data);
		if code ~= 0 then
			freeswitch.consoleLog("WARNING","Query mobile city: "..omobile.." can't find city!\n");
			stream:write(omobile);
			return;
		end
		_,_,qmc_mobile,qmc_area_code = string.find(msg,"(%d+),(%d+)");
		
        if qmc_area_code ~= nil and  string.len(qmc_area_code) > 0  then
			api:executeString("db insert/hcode/"..hcode.."/"..qmc_area_code);
		end
		
	end
		
	
end

if qmc_area_code ~= nil and string.len(qmc_area_code) >= 0 then
	if argv[2] ~=nil then
		if argv[2] == qmc_area_code then
			mobile = hcode..nb;
		else
			mobile = "0"..hcode..nb;
		end	

		if session ~= nil  then
			session:setVariable("qmc_mobile",mobile);
			session:setVariable("qmc_area_code",qmc_area_code);
		end	
		
		freeswitch.consoleLog("NOTICE","Query mobile city: "..omobile.."=>"..qmc_area_code.."\n");		
	end
else
	freeswitch.consoleLog("WARNING","Query mobile city: "..omobile.." can't find city!\n");
end
stream:write( mobile);
	
