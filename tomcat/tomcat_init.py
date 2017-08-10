# !/bin/bash
# Description:  start or stop the tomcat
# Usage:        tomcat [start|stop|reload|restart]

    case "$1" in
    start)
    #startup the tomcat
       echo -n "tomcat test start: "
       su tomcat -c -l /data/app/tomcat_test_6410/bin/startup.sh
       su tomcat -c -l /data/app/tomcat_test_6411/bin/startup.sh
       su tomcat -c -l /data/app/tomcat_test_6412/bin/startup.sh
       su tomcat -c -l /data/app/tomcat_test_6413/bin/startup.sh
       su tomcat -c -l /data/app/tomcat_test_6414/bin/startup.sh
       su tomcat -c -l /data/app/tomcat_test_6415/bin/startup.sh
       echo "finished"
    ;;
    stop)
    # stop tomcat
       echo -n "tomcat test stop:"
       ps -ef | grep "tomcat_test" | grep -v grep | sed 's/ [ ]*/:/g'|cut -d: -f2| kill -9 `cat`
       su tomcat -c -l "rm -rf /data/app/tomcat_test_6410/work/Catalina/localhost"
       su tomcat -c -l "rm -rf /data/app/tomcat_test_6411/work/Catalina/localhost"
       su tomcat -c -l "rm -rf /data/app/tomcat_test_6412/work/Catalina/localhost"
       su tomcat -c -l "rm -rf /data/app/tomcat_test_6413/work/Catalina/localhost"
       su tomcat -c -l "rm -rf /data/app/tomcat_test_6414/work/Catalina/localhost"
       su tomcat -c -l "rm -rf /data/app/tomcat_test_6415/work/Catalina/localhost"
       echo "finished"
    ;;
    reload|restart)
        $0 stop
        sleep 3
        $0 start
    ;;
    *)
       echo "Usage: tomcat [start|stop|reload|restart]"
       exit 1

    esac
    exit 0
