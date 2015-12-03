local find = string.find
local sub = string.sub
local len = string.len

local _M = {
	_VERSION = "0.0.1",
}

local function split(szFullString, szSeparator)
        local nFindStartIndex = 1
        local nSplitIndex = 1
        local nSplitArray = {}
        while true do
                local nFindLastIndex = find(szFullString, szSeparator, nFindStartIndex)
                if not nFindLastIndex then
                        nSplitArray[nSplitIndex] = sub(szFullString, nFindStartIndex, len(szFullString))
                        break
                end
                nSplitArray[nSplitIndex] = sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
                nFindStartIndex = nFindLastIndex + len(szSeparator)
                nSplitIndex = nSplitIndex + 1
        end
        return nSplitArray
end

function _M.set(opts)
	local count_dict = opts.count_dict
	if not count_dict then
		return nil, "\"count_dict\" option required"
	end
	local time_dict = opts.time_dict
	if not time_dict then
		return nil,"\"time_dict\" option required"
	end
	local bytes_dict = opts.bytes_dict
	if not bytes_dict then
		return nil, "\"byte_dict\" option required"
	end
	local host = opts.host
	if not host then
		return nil, "\"host\" option required"
	end
	local port = opts.port
	if not port then
		return nil, "\"port\" option required"
	end
	local request_time = tonumber(opts.request_time)
	if not request_time then
		return nil, "\"request_time\" option required"
	end
	local bytes_sent = tonumber(opts.bytes_sent)
	if not bytes_sent then
		return nil, "\"bytes_sent\" option required"
	end	
	local key_suffix = host .. ":" .. port
	local count_key = "count/" .. key_suffix
	local time_key = "time/" .. key_suffix
	local byte_key = "byte/" .. key_suffix

	local newval, err = count_dict:incr(count_key,1)
	if not newval then
		if err  == "not found" then
			local success, err, forcible = count_dict:add(count_key,1)
			if not success then
				return nil, err
			end
		end
	end

	newval, err = time_dict:incr(time_key,request_time)
	if not newval then
		if err == "not found" then
                	local success, err, forcible = time_dict:add(time_key, request_time)
                	if not success then
				return nil, err
                	end
        	end
	end 

	newval, err = bytes_dict:incr(byte_key,bytes_sent)
	if not newval then
                if err == "not found" then
                        local success, err, forcible = bytes_dict:add(byte_key, bytes_sent)
                        if not success then
                                return nil, err
                        end
                end
        end

	return 1
end

function _M.status(opts)
	local count_dict = opts.count_dict
        if not count_dict then
                return nil, "\"count_dict\" option required"
        end
        local time_dict = opts.time_dict
        if not time_dict then
                return nil,"\"time_dict\" option required"
        end
        local bytes_dict = opts.bytes_dict
        if not bytes_dict then
                return nil, "\"bytes_dict\" option required"
        end	
	ngx.update_time()
	local now =  ngx.time()
	local bp = time_dict:get("breakpoint")
	if not bp then
		count_dict:flush_all()
		time_dict:flush_all()
		bytes_dict:flush_all()
		local succ, err, forcible = time_dict:set("breakpoint",now)
		if not succ then
			return nil, err
		end
		return nil
	end
	local interval = now - bp
	if interval <= 0 then
		return nil,"getting status too quick"
	end
	local keys = count_dict:get_keys()
	local res = {}
	for _,v in ipairs(keys) do
		local tmp = split(v,"/")
        	local time_key = "time/" .. tmp[2]
        	local byte_key = "byte/" .. tmp[2]
        	local count = count_dict:get(v) / interval
        	local time = time_dict:get(time_key)
        	local bytes = bytes_dict:get(byte_key) / interval
        	local time_avg = time / count
        	local t = {}
        	t.host = tmp[2]
        	t.avg_count = count
        	t.avg_request_time = time_avg
        	t.avg_bytes_sent = bytes
		t.interval = interval
        	table.insert(res,t)
	end
	count_dict:flush_all()
        time_dict:flush_all()
        bytes_dict:flush_all()
        local succ, err, forcible = time_dict:set("breakpoint",now)
        if not succ then
            	return nil, err
       	end
	return res
end

return _M
