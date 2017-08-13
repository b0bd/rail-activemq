#!/usr/bin/env sh

# restore original activemq
if [ -f /srv/activemq/conf/activemq.xml_orig ]; then
  cp /srv/activemq/conf/activemq.xml_orig \
  /srv/activemq/conf/activemq.xml
else
  cp /srv/activemq/conf/activemq.xml \
  /srv/activemq/conf/activemq.xml_orig
fi

# configure stream cache
sed -i 's#^</beans>$#    <import resource="streamcache.xml"/>\n</beans>#'  \
        /srv/activemq/conf/activemq.xml

# configure local broker
    sed -i 's#^</beans>$#    <import resource="localbroker.xml"/>\n</beans>#'  \
        /srv/activemq/conf/activemq.xml


# configure NetworkRail connector
if [ -z "${NETWORKRAIL_TOPICS}" ]; then
    rm -f /srv/activemq/conf/networkrail.xml
else
    if [ "${NETWORKRAIL_TOPICS}" == "ALL" ]; then
        NETWORKRAIL_TOPICS="TRAIN_MVT_ALL_TOC,RTPPM_ALL,TD_ALL_SIG_AREA,VSTP_ALL,TSR_ALL_ROUTE"
    fi


    sed -i 's#^</beans>$#    <import resource="networkrail.xml"/>\n</beans>#'  \
        /srv/activemq/conf/activemq.xml

    cp /srv/activemq/conf/networkrail.xml.template /srv/activemq/conf/networkrail.xml
    sed -i \
        -e "s#\[USERNAME\]#${NETWORKRAIL_USERNAME}#" \
        -e "s#\[PASSWORD\]#${NETWORKRAIL_PASSWORD}#" \
        /srv/activemq/conf/networkrail.xml

    echo "${NETWORKRAIL_TOPICS}" \
        | tr ',' '\n' | while read TOPIC; do
          new_route="        <route>\n            <from uri=\"networkrail:topic:${TOPIC}?clientId=${NETWORKRAIL_USERNAME}-${TOPIC}\\&amp;durableSubscriptionName=${NETWORKRAIL_USERNAME}-${HOSTNAME}\" />\n            <to uri=\"amq:topic:${TOPIC}\" />\n        </route>\n"
          sed -i -e "s#^    </camelContext>\$#${new_route}\n    </camelContext>#" /srv/activemq/conf/networkrail.xml
        done
fi

# configure National Rail (Darwin) connector
if [ -z "${NATIONALRAIL_QUEUE}" ]; then
  rm -f /srv/activemq/conf/nationalrail.xml
else
    sed -i 's#^</beans>$#    <import resource="nationalrail.xml"/>\n</beans>#'  \
        /srv/activemq/conf/activemq.xml

    cp /srv/activemq/conf/nationalrail.xml.template /srv/activemq/conf/nationalrail.xml
    sed -i \
        -e "s#\[USERNAME\]#${NATIONALRAIL_USERNAME}#"   \
        -e "s#\[PASSWORD\]#${NATIONALRAIL_PASSWORD}#"   \
        -e "s#\[QUEUE\]#${NATIONALRAIL_QUEUE}#"         \
        /srv/activemq/conf/nationalrail.xml
fi

# configure HAWTIO
  sed -i 's#<ref bean="rewriteHandler"/>#<ref bean="rewriteHandler"/>\n                        <bean class="org.eclipse.jetty.webapp.WebAppContext"> <property name="contextPath" value="/hawtio" /> <property name="war" value="/srv/hawtio/hawtio-default-offline.war" /> <property name="logUrlOnStart" value="true" /> </bean>#' \
    /srv/activemq/conf/jetty.xml

# configure JMX broker
  sed -i \
      -e s'#<broker xmlns="http://activemq.apache.org/schema/core"#<broker xmlns="http://activemq.apache.org/schema/core" useJmx="true"'# \
      -e s#"localhost"#"`hostname`"# \
    /srv/activemq/conf/activemq.xml


# add RMI host info
HN=`hostname`
export ACTIVEMQ_OPTS="-Djava.rmi.server.hostname=`grep $HN /etc/hosts | cut -f1`"


ACTIVEMQ_BASE=/srv/activemq exec /srv/apache-activemq-*/bin/activemq console
