#!/usr/bin/env ash

HN=`hostname`

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


do_template() {
    src_system="$1"
    url="$2"
    username="$3"
    password="$4"
    topics="$5"

    if [ -z "${topics}" ]; then
        rm -f "/srv/activemq/conf/$src_system.xml"
    else
        sed -i 's#^</beans>$#    <import resource="'"$src_system.xml"'"/>\n</beans>#'  \
            /srv/activemq/conf/activemq.xml

        cp /srv/activemq/conf/topic.xml.template "/srv/activemq/conf/$src_system.xml"
        sed -i \
            -e "s#\[URL\]#${url}#" \
            -e "s#\[SOURCE-SYSTEM\]#${src_system}#" \
            -e "s#\[USERNAME\]#${username}#" \
            -e "s#\[PASSWORD\]#${password}#" \
            "/srv/activemq/conf/${src_system}.xml"

        echo "${topics}" \
            | tr ',' '\n' | while read TOPIC; do
              new_route="        <route>\n            <from uri=\"${src_system}:topic:${TOPIC}?clientId=${username}-${TOPIC}\\&amp;durableSubscriptionName=${username}-${HN}\" />\n            <to uri=\"amq:topic:${TOPIC}\" />\n        </route>\n"
              sed -i -e "s#^    </camelContext>\$#${new_route}\n    </camelContext>#" "/srv/activemq/conf/${src_system}.xml"
            done
    fi
}

# configure NetworkRail connector
if [ "${NETWORKRAIL_TOPICS}" = "ALL" ]; then
    NETWORKRAIL_TOPICS="TRAIN_MVT_ALL_TOC,RTPPM_ALL,TD_ALL_SIG_AREA,VSTP_ALL,TSR_ALL_ROUTE"
fi

do_template \
  "networkrail" \
  "tcp://datafeeds.networkrail.co.uk:61619" \
  "${NETWORKRAIL_USERNAME}" \
  "${NETWORKRAIL_PASSWORD}" \
  "$NETWORKRAIL_TOPICS"


# configure National Rail Darwin connector
if [ "${DARWIN_TOPICS}" = "ALL" ]; then
    DARWIN_TOPICS="darwin.pushport-v16,darwin.status"
fi

do_template \
  "darwin" \
  "tcp://${DARWIN_HOST}:61616" \
  "${DARWIN_USERNAME}" \
  "${DARWIN_PASSWORD}" \
  "$DARWIN_TOPICS"

# configure National Rail KnowledgeBase connector
if [ "${NR_KB_TOPICS}" = "ALL" ]; then
    NR_KB_TOPICS="kb.incidents"
fi

do_template \
  "nr-kb" \
  "tcp://${NR_KB_HOST}:61616" \
  "${NR_KB_USERNAME}" \
  "${NR_KB_PASSWORD}" \
  "$NR_KB_TOPICS"


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
export ACTIVEMQ_OPTS="-Djava.rmi.server.hostname=`grep $HN /etc/hosts | head -1 | cut -f1`"


ACTIVEMQ_BASE=/srv/activemq exec /srv/apache-activemq-*/bin/activemq console
