--string>>byte
if  argv[1] == nil then
	stream:write("\ninput string\n");
else
	local len = string.len(argv[1]);
	stream:write("\n");
	for i=1,len,1 do
		stream:write(string.byte(argv[1],i));
		stream:write(",");
	end
	stream:write("\n");
end