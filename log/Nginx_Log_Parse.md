##Ysten Nginx Log Parse

### Log Format
	log_format ystenlog '$remote_addr - $remote_user [$time_iso8601] "$request" '
                    	' "$status" $body_bytes_sent "$http_range" "$http_referer" '
                    	' "$http_user_agent" $http_x_forwarded_for "$request_time" '
                    	' "$host" "$server_port" "$sent_http_location" "$upstream_cache_status"';

- - -
### 字段详解

- remote_addr  

	>客户端IP Nginx前一层的IP

- remote_user
	>已经经过Auth Basic Module验证的用户名
	
- time_iso8601
	>ISO 8601标准格式的时间
	
- request
	>请求的URL和HTTP协议
	
- status
	>HTTP状态码
	
- body\_bytes_sent
	>返回给客户端的字节数，不包括Header部分
	
- http_range
	>与Nginx断点续传有关，可能显示的发送的字节范围
	
- http_referer
	>从哪个链接发起的请求
	
- http\_user_agent
	>User-Agent
	
- http\_x\_forwarded_for
	>用户真实的IP
	
- request_time
	>请求处理的时间         

- host
	>请求的主机名
	
- server_port
	>请求的端口
	
- sent\_http_location
	>未知
	
- upstream\_cache_status
	>缓存的状态（　HIT，MISS 。。。）
	
- - -

### Scripts
#### nginxlog-parse.sh

	#!/bin/bash

	clear

	LogFile="/tmp/log"

	awk 'BEGIN{size=0}{if ($8 ~ /[0-9][0-9][0-9]/) status[$8]++;size+=$9} \
		 END{printf "\nPV:\n\n\t %s Count\n\n",NR; \
		 printf "HTTP code percentage:\n\n"; \
		 for(i in status)printf "\t%s  %s line  %f%\n",substr(i,2,3),status[i],status[i]/NR*100; \
		 printf "\nflow sent to client: \n\n\t %s MB\n\n",size/1024/1024}' $LogFile
		 
- - -

### Demonstrate

	sh nginxlog-parse.sh
	
	PV:

		31476601 Count

	HTTP code percentage:

		304  626408 line  1.990075%
		206  6 line  0.000019%
		404  552 line  0.001754%
		200  30849611 line  98.008076%
		301  12 line  0.000038%

	flow sent to client:

		480688 MB
	
	