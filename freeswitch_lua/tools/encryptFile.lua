local lfs = require "lfs"
local crypto = require("crypto")
local bootdir = lfs.currentdir().."/..";
package.path = package.path..";./lib/?.lua;./lib/?.so;./include/?.lua" 
local scriptdir = bootdir.."/scripts/";

if arg[1] == nil or arg[2] == nil or arg[3] == nil then
	stream:write("-ERR\n USAGE:encryptFile.lua <encrypefile> <hwaddr> <outfile>\n");	
	return;
end

local pw = crypto.digest("md5",arg[2]);	
require("aeslua");
f = io.open(scriptdir..arg[1]);
if  f == nil then
	stream:write("-ERR encryptFile can'n open!\n");
	return ;
end

local fc = f:read("*a");
f:close();
--stream:write(pw);
local ec = aeslua.encrypt(pw,fc);
f = io.open(scriptdir..arg[3],"w");
f:write(ec);
f:close();
stream:write("+OK\n");