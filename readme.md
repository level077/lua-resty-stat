#Description
统计一段时间内各server_name的平均请求数，平均响应时间及平均发送的数据量。输出为json格式，方便其他程序分析。

#Usage
```
#nginx.conf
lua_package_path "/path/to/lua-resty-stat/lib/?.lua;;";
lua_shared_dict count_dict 1m;
lua_shared_dict time_dict 1m;
lua_shared_dict bytes_sent_dict 1m;
log_by_lua_file /path/to/lua-resty-stat/log/log.lua;

server {
	server_name stat.foo.bar;
	local = /stat {
		content_by_lua_file /path/to/lua-resty-stat/log/stat.lua;
	}
}
```

#Output
```
curl -H "host:stat.foo.bar" '127.0.0.1/stat'
[{"host":"stat.foo.bar:80","avg_request_time":0,"avg_count":1,"avg_bytes_sent":474,"interval":1}]
```
