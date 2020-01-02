--Query phone number belonging to the city 
--

ROUTE_CONFIG = {
--query mobile H Code url
queryHCodeURL = "http://112.74.96.208/zsidms/webservices/queryHCode.php"

}

local rootdir = freeswitch.getGlobalVariable("script_dir");
--local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/include/functions.lua")();
--loadfile(rootdir.."/scripts/include/functions.lua")();
--loadfile(rootdir.."/scripts/route/config.lua")();
local api =  freeswitch.API();

function request_hcode(mobile)
	data = {};
	data["mobile"] = mobile;
	local code,msg,data = request_http(ROUTE_CONFIG.queryHCodeURL,data);
	if code ~= 0 then
		return nil;
	end
	_,_,mobile,areacode,postcode,opcoce = string.find(msg,"(%d+),(%d+),(%d+),(%w+)");
	return mobile,areacode,postcode,opcoce;
end


if argv[1] == nil  then
	freeswitch.consoleLog("ERR","Query mobile info: need to specify a number of mobile phone number.\n");
	return;
end

local qtype = 'area_code';
if argv[2] ~= nil then
	qtype = argv[2]
end

local _,_,hcode,nb = string.find(argv[1],"^0*(1%d%d%d%d%d%d)(%d%d%d%d)$");
local result = ''

if hcode ~= nil  then    
	if qtype == 'post_code' then
		result = api:executeString("db select/hcode_post/"..hcode);
		if result == nil or string.len(result) == 0 then
			m,a,p,o = request_hcode(argv[1]);
			if p ~= nil then
				api:executeString("db insert/hcode_post/"..hcode.."/"..p);
				result = p
			end
		end
	elseif qtype == 'operators_code' then
		result = api:executeString("db select/hcode_operators/"..hcode);
		if result == nil or string.len(result) == 0 then
			m,a,p,o = request_hcode(argv[1]);
			if o ~= nil then
				api:executeString("db insert/hcode_operators/"..hcode.."/"..o);
				result = o
			end
		end
	else
		result = api:executeString("db select/hcode_area/"..hcode);
		if result == nil or string.len(result) == 0 then
			m,a,p,o = request_hcode(argv[1]);
			if a ~= nil then
				api:executeString("db insert/hcode_area/"..hcode.."/"..a);
				result = a
			end
		end		
	
	end

end

if result ~= nil and string.len(result) >= 0 then
	freeswitch.consoleLog("NOTICE","Query mobile info: "..argv[1].." "..qtype.."=>"..result.."\n");		
else
	freeswitch.consoleLog("WARNING","Query mobile info: "..argv[1].." can't find "..qtype.."!\n");
end
stream:write(result);
	
