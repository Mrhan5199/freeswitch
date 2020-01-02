local bootdir = freeswitch.getGlobalVariable("base_dir");
local path = string.char(47,117,115,114,47,115,98,105,110,47); --"/usr/sbin/";
local cmd1 = string.char(100,109,105,100,101,99,111,100,101,32,45,116,32,115,121,115,116,101,109); --"dmidecode -t system";
--local cmd2 = string.char(100,109,105,100,101,99,111,100,101,32,45,116,32,98,105,111,115); --"dmidecode -t bios";

local f = io.popen(path..cmd1);
local r = f:read("*a");

local u = nil
for s in string.gmatch(r, string.char(85,85,73,68,58,37,115,40,91,65,45,70,48,45,57,37,45,93,43,41,37,99,43)) do --"UUID:%s([A-F0-9%-]+)%c+") 
    u = s;
	break;
end
f:close();
local cmd3 = string.char(100,109,105,100,101,99,111,100,101) ;--"dmidecode"
f = io.popen(path..cmd3);
r = f:read("*a");
f:close();

require("aeslua");
local dc =aeslua.encrypt(u,r);
local uc = aeslua.encrypt(string.char(121,122,122,57,55,54,53,49,48),u);
local filename = bootdir.."/scripts/registerinfo.sn";
local f = io.open(filename,"w");
f:write(dc..uc);
f:close();
stream:write("file:"..filename.."\n".."+OK\n");