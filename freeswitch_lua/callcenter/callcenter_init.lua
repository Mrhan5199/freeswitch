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
--	freeswitch.consoleLog("ERR","\nsystem expire!\n");
--	return;
--end

freeswitch.consoleLog("INFO","\nCallcenter initializing!\n");
local api = freeswitch.API();
api:execute("lua",rootdir.."/scripts/callcenter/callcenter_event_thread.lua stop");
api:execute("lua",rootdir.."/scripts/callcenter/agent_event_thread.lua stop");
freeswitch.msleep(2000);

local params = {};
params["action"] = "InitSystem";
local code,msg,data = request_http(WebServiceURL,params);

if(code == nil or code ~= 0 ) then 
	freeswitch.consoleLog("ERR","\nCallcenter initialize fail,"..msg.."\n");
	return;
else
	local result = api:executeString("callcenter_config queue list");
	local queues = parser_cmd_res(result);	
	for k, v in ipairs(queues) do	
	    if true then		
		--if in_array(v.name,QueueList) then		
			local params = {};
			params["action"]="AddQueue";
			params["name"]=v.name;
			params["state"]="ON";
			local code,msg,data = request_http(WebServiceURL,params);	
			if(code == nil or code~= 0)	then
				freeswitch.consoleLog("ERR","\nAdd queue fail,"..v.name.."."..msg.."\n");
			end
		end	
	end
	
	result = api:executeString("callcenter_config agent list");
	local agents = parser_cmd_res(result);
	for k, v in ipairs(agents) do
	    if true then	
		--if in_array(v.name,AgentList) then	
			local params = {};
			params["action"]="AddAgent";
			params["name"]=v.name;
			params["state"]=v.state;
			params["status"]=v.status;
			params["contact"]=v.contact;
			local code,msg,data = request_http(WebServiceURL,params);	
			if(code == nil or code~= 0)	then
				freeswitch.consoleLog("ERR","\nAdd agent fail,"..v.name.."."..msg.."\n");
			end
		end	
	end
	
	api:execute("luarun",rootdir.."/scripts/callcenter/callcenter_event_thread.lua");
	api:execute("luarun",rootdir.."/scripts/callcenter/agent_event_thread.lua");
end
freeswitch.consoleLog("INFO","\ncallcenter initializ success!\n");
