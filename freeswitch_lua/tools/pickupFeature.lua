local bootdir = freeswitch.getGlobalVariable("base_dir");
require("aeslua");
if argv[1] == nil then
	stream:write("-ERR please input file name!\n");
	
else
	local f = io.open(argv[1]);
	if f ~= nil then
		local ec = f:read("*a");
		local p = string.sub(ec,-48);
		local u = aeslua.decrypt("yzz976510",p);
		local ei = string.sub(ec,1,string.len(ec)-48);
		local dc = aeslua.decrypt(u,ei);
		stream:write(dc);

	else
		stream:write("-ERR open file error!\n");
	end
end
