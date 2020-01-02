local rootdir = freeswitch.getGlobalVariable("base_dir");
if argv[1] == nil or argv[2] == nil or argv[3] == nil or argv[4] == nil then
	stream:write("-ERR\n USAGE:lua batch_create_user.lua <cidr> <userids> <pwds> <count>\n");	
end

local xml =     '<include>                                                            \n';
	  xml =xml..'<user id="%s"  %s       >                                            \n';
	  xml =xml..'	<params>                                                          \n';
	  xml =xml..'	<param name="password" value="%s"/>                               \n';
	  xml =xml..'	<param name="vm-password" value="%s"/>                            \n';
	  xml =xml..'	</params>                                                         \n';
	  xml =xml..'	<variables>                                                       \n';
	  xml =xml..'	<variable name="accountcode" value="%s"/>                         \n';
	  xml =xml..'	<variable name="user_context" value="internal_ctx"/>              \n';
	  xml =xml..'	<variable name="effective_caller_id_name" value="%s"/>            \n';
	  xml =xml..'	<variable name="effective_caller_id_number" value="%s"/>          \n';
	  xml =xml..'	<variable name="outbound_caller_id_name" value="%s"/>             \n';
	  xml =xml..'	<variable name="outbound_caller_id_number" value="%s"/>           \n';
	  xml =xml..'	</variables>                                                      \n';
	  xml =xml..'</user>                                                              \n';
	  xml =xml..'</include>                                                           \n';
		   
local cidr = argv[1];
if argv[1] == "none" then
	cidr = "";
end
local user_s = tonumber(argv[2]);
local pwd_s = tonumber(argv[3]);
local count = tonumber(argv[4]);
local total = count;
while true do	
	if count<=0 then break end;
	count = count -1;
	local u  = user_s + count;
	local p  = pwd_s + count;
	local x = string.format(xml,u,cidr,p,p,u,u,u,u,u);
	local f = io.open(rootdir.."/conf/directory/default/"..u..".xml","w");
	if f == nil then
		stream:write("-ERR create file failure!\n");		
	end
	if not f:write(x) then
		stream:write("-ERR write file failure!\n");		
	end	
	if f then 	f:close(); end
end
if count <=0 then
	stream:write("+OK user config file create end?total:"..total.."\n");
else
	stream:write("-ERR user config file create end?total:"..total-count.."\n");
end	