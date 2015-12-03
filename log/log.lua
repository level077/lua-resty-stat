local logging = require "logging"
local log = ngx.log
local ERR = ngx.ERR
local count_dict = ngx.shared.count_dict
local time_dict = ngx.shared.time_dict
local bytes_dict = ngx.shared.bytes_sent_dict
local host = ngx.var.host
local port = ngx.var.server_port
local request_time = ngx.var.request_time
local bytes_sent = ngx.var.bytes_sent
local opts = {
	count_dict = count_dict,
	time_dict = time_dict,
	bytes_dict = bytes_dict,
	host = host,
	port = port,
	request_time = request_time,
	bytes_sent = bytes_sent,
}
local res, err = logging.set(opts)
if not res then
	log(ERR,err)
end
