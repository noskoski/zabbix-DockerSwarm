PREFIX = /etc/zabbix/
ZABBIXCONFDIR = /etc/zabbix/zabbix_agent2.d/
install: docker.sh
                install -m 755 docker.sh  $(PREFIX)/
                install -m 755 docker.conf $(ZABBIXCONFDIR)/
                adduser zabbix docker 
uninstall: docker.sh
          rm -f $(PREFIX)/docker.sh
          rm -f $(ZABBIXCONFDIR)/docker.conf
          
