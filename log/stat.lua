local logging = require "logging"
local cjson = require "cjson"
local count_dict = ngx.shared.count_dict
local time_dict = ngx.shared.time_dict
local bytes_dict = ngx.shared.bytes_sent_dict
local opts = {
	count_dict = count_dict,
	time_dict = time_dict,
	bytes_dict = bytes_dict,	
}
local res, err = logging.status(opts)
if not res then
	ngx.log(ngx.ERR,err)
else
	ngx.say(cjson.encode(res))
end
