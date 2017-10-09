#!/bin/bash
# date 2017-10-06

cd /app/ysths/app

for servlet in $(/bin/ls -d tomcat*)
do
    \cp -f "$servlet"/conf/server.xml "$servlet"/conf/server.xml.bak
    \cp -f "$servlet"/conf/web.xml "$servlet"/conf/web.xml.bak
    sed -i -r 's/(connectionTimeout)=\"20000\"/\1=\"7000\"/g' "$servlet"/conf/server.xml

    grep -q "security-constraint" "$servlet"/conf/web.xml || sed -i -r '/<\/web-app>/i \
    <security-constraint> \
    <web-resource-collection> \
    <url-pattern>\/\*<\/url-pattern> \
    <http-method>DELETE<\/http-method> \
    <http-method>PUT<\/http-method> \
    <http-method>TRACE<\/http-method> \
    <http-method>OPTIONS<\/http-method> \
    <\/web-resource-collection> \
    <auth-constraint> \
    <\/auth-constraint> \
    <\/security-constraint> \
    <login-config> \
    <auth-method>BASIC<\/auth-method> \
    <\/login-config>\n' "$servlet"/conf/web.xml
    
    grep -q "error-code>404" "$servlet"/conf/web.xml || sed -i -r '/<\/web-app>/i \
    <error-page> \
    <error-code>404<\/error-code> \
    <location>\/error.html<\/location> \
    <\/error-page>\n' "$servlet"/conf/web.xml

    grep -q "error-code>500" "$servlet"/conf/web.xml || sed -i -r '/<\/web-app>/i \
    <error-page> \
    <error-code>500<\/error-code> \
    <location>\/error.html<\/location> \
    <\/error-page>\n' "$servlet"/conf/web.xml

    touch "$servlet"/webapps/error.html

done
