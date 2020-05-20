
function in_array(str,arr)
	if str == nil  or arr == nil or type(arr) ~= "table" then
		return false;
	end
	local ret = false;
	for k, v in ipairs(arr) do
		if v == str then
			ret = true;
			break;
		end
	end
	return ret;
end

function string_spilt(str,sep)
	if str == nil or sep == nil then 
		return {};
	end
	local s = 1;
	local arr = {};
	local c = 1;
	while true do
		local s1 = string.find(str,sep,s);		
		if s1 == nil then
			arr[c] = string.sub(str,s,-1);
			break;
		end
		if s == s1 then
			arr[c] = "";
		else
			arr[c] = string.sub(str,s,s1-1); 
		end		
		s = s1 + 1;
		c = c+1;
	end
	return arr;
end

function parser_cmd_res(result)
	if nil ==  result then return {}; end
	local lines = {};
	local linecount = 0;
	for v in string.gmatch(result, "([^%c]+)") do

		lines[linecount] = v;
		linecount = linecount+1;		
	end
	local res = {};
	local c = 1;

	if linecount>=1 and lines[linecount-1] == "+OK" then	
		local names = string_spilt(lines[0],"|");
		linecount = linecount-2;
		while linecount>0 do
			local values = string_spilt(lines[linecount],"|");
			local row = {};
			for k, v in ipairs(values) do
				row[names[k]] = v;
			end
			res[c] = row;
			linecount = linecount -1;
			c = c+1;
		end	
	end
	return res;
end

function respone_decode(txt)
	local _,_,code,msg,data = string.find(txt,"(%d+)%|([%a%d%p]+)%c+(.+)");
	return code,msg,data;
end

function request_http(url,params)
	local par = {};
	for     k , v in pairs(params) do
			if v~=nil then
					par[k] = v;
			end
	end
	local api = freeswitch.API();
	local urlparam = urlParamEncode(params);
	local result = api:execute("curl",url.."?"..urlparam);
	local k = string.match(result, "%a+")
	if k == "success" then
		return true;
	end
	return false;
end

function post_http(url,params)
	local par = {};
	for     k , v in pairs(params) do
			if v~=nil then
					par[k] = v;
			end
	end
	local api = freeswitch.API();
	local urlparam = urlParamEncode(params);
	local result = api:execute("curl",url.." content-type application/x-www-form-urlencoded ".." post "..urlparam);
	return result;
end

function put_http(url,params)
	local par = {};
	for     k , v in pairs(params) do
			if v~=nil then
					par[k] = v;
			end
	end
	local api = freeswitch.API();
	local urlparam = urlParamEncode(params);
	local result = api:execute("curl",url.."update-data".."/".." content-type application/x-www-form-urlencoded ".." put "..urlparam);
	local k = string.match(result, "%a+")
	if k == "success" then
			msg = "success"
	else
			msg = "failed"
	end
	return msg;
end

function md5(str)
	local api = freeswitch.API();
	return api:execute("md5",str);
end

function urlParamEncode(paramsT)
	function escape (s)
	    s = string.gsub(s,'([^%a%d])', 
			function (c)							
				return '%'..string.format("%02X", string.byte(c))
			end);
		return s;
	end

	function encode (t)
		local s = ""
		for k , v in pairs(t) do
			s = s .. "&" .. escape(k) .. "=" .. escape(v)
		end
		return string.sub(s, 2)     -- remove first `&'
	end
	
	if type(paramsT) == 'table' then
		return encode(paramsT)
	else		
		local at  = 1 ;
		local len = string.len(paramsT);
		local tmp = {};
		while true do
			local p = string.find(paramsT,"&",at);
			if p == nil then	
				if at < len then
					table.insert(tmp,string.sub(paramsT,at,len));
					
				end
				break;	
			end
			
			table.insert(tmp,string.sub(paramsT,at,p-1));
			at = p+1;
		end
		local myParamsT = {};
		for k, v in pairs(tmp) do
			local pos = 0
			pos = string.find(v, '=')
			if not pos then return '' end
			myParamsT[string.sub(v, 1, pos-1 )] = string.sub(v, pos+1 )
		end
		return encode(myParamsT)
	end
end

function urlParamUncode(params)
	local s = string.gsub(params,"%%([%x][%x])",function(c)
					local ss = string.lower(c);
					local a = string.byte(ss);
					local b = string.byte(ss,2);
					if a > 47 and a< 58 then
						a = a-48;
					elseif a > 96 and a<103 then
						a = a-87;
					end	
					if b > 47 and b< 58 then
						b = b-48;
					elseif b > 96 and b<103 then
						b = b-87;
					end	
					return string.char(a*16+b);	
	           end);
		local at  = 1 ;
		local len = string.len(s);
		local tmp = {};
		while true do
			local p = string.find(s,"&",at);
			if p == nil then	
				if at < len then
					table.insert(tmp,string.sub(s,at,len));
					
				end
				break;	
			end
			
			table.insert(tmp,string.sub(s,at,p-1));
			at = p+1;
		end
		local myParamsT = {};
		for k, v in pairs(tmp) do
			local pos = 0
			pos = string.find(v, '=')
			if not pos then return '' end
			myParamsT[string.sub(v, 1, pos-1 )] = string.sub(v, pos+1 )
		end			   
	return myParamsT;		   
end

function getDePw()
	for ifno = 0,9,1 do
	
		--local cmd = string.char(105,102,99,111,110,102,105,103,32,101,116,104)..ifno; --"ifconfig eth0"
		local cmd = "ifconfig em1"; --string.char("ifconfig eth0"); 
		local f = io.popen(cmd);
		if nil ~= f then	
			local r = f:read("*a");
			f:close();
			if r~=nil then
				--stream:write(r);				
				--local _,_,u = string.find(r, string.char(37,115,43,72,87,97,100,100,114,37,115,43,40,91,48,45,57,65,45,70,37,58,93,43,41));
				local _,_,u = string.find(r,"%s+(%x%x%:%x%x%:%x%x%:%x%x%:%x%x%:%x%x)%s+")
				if u ~= nil and u~='00:00:00:00:00:00' then
					return md5(u);
				end	
			end
		end
	end
	return false;	
end

function DecryptFile(file)
	if nil == file then
		return nil;
	end
	require("aeslua");
	local p = getDePw();
	if p then
		local f = io.open(file,"r");
		if nil ~= f then
			local s = f:read("*a");
			f:close();
			local lu = aeslua.decrypt(p,s);
			return lu;
		end
	end
	return nil;	
end

function formatUNIXTimeFromSEC(timestamp)
	if  nil == timestamp then
		return "0000-00-00 00:00:00";
	end
	local tm = tonumber(timestamp);
	if nil == tm or 0 == tm then
		return "0000-00-00 00:00:00";
	end
	local ftime = os.date("%Y-%m-%d %H:%M:%S",timestamp);
	if nil == ftime then
		return "0000-00-00 00:00:00";
	end
	return ftime;
end

function formatUNIXTimeFromMS(timestamp)
	if  nil == timestamp then
		return "0000-00-00 00:00:00";
	end
	return formatUNIXTimeFromSEC(timestamp/1000);
end

function formatUNIXTimeFromUS(timestamp)
	if  nil == timestamp then
		return "0000-00-00 00:00:00";
	end
	return formatUNIXTimeFromSEC(timestamp/1000000);
end

