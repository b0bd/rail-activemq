FROM eclipse-temurin:8-jre-alpine

ENV 	V=5.16.5	\
	HAWTIO=1.5.11

RUN apk --no-cache add openssl

RUN wget -O apache-activemq-${V}-bin.tar.gz  											\
	 "http://www.apache.org/dyn/closer.cgi?filename=/activemq/${V}/apache-activemq-${V}-bin.tar.gz&action=download" &&  	\
    tar xvp -C /srv -f  apache-activemq-${V}-bin.tar.gz && \
    rm apache-activemq-${V}-bin.tar.gz

RUN mkdir -p /srv/activemq && \
    mv /srv/apache-activemq-*/conf /srv/activemq && \
    mv /srv/apache-activemq-*/data /srv/activemq

RUN mkdir /srv/hawtio						\
 && wget -O /srv/hawtio/hawtio-default-offline-${HAWTIO}.war	\
	"https://oss.sonatype.org/content/repositories/public/io/hawt/hawtio-default-offline/${HAWTIO}/hawtio-default-offline-${HAWTIO}.war"	\
 && ln -s hawtio-default-offline-${HAWTIO}.war /srv/hawtio/hawtio-default-offline.war

RUN echo "" >> "/srv/apache-activemq-${V}/bin/env"	\
 && echo 'ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS -Dhawtio.authenticationEnabled=false"'	\
	>> "/srv/apache-activemq-${V}/bin/env"

RUN echo 'ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS -javaagent:/srv/jmx-prom/agent.jar=9191:/srv/jmx-prom/config.yaml -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"'	>> "/srv/apache-activemq-${V}/bin/env"

COPY topic_template.xml /srv/activemq/conf/topic.xml.template
COPY streamcache.xml    /srv/activemq/conf/streamcache.xml
COPY localbroker.xml    /srv/activemq/conf/localbroker.xml

RUN mkdir /srv/jmx-prom
COPY prom-agent.yaml  /srv/jmx-prom/config.yaml
RUN wget -O /srv/jmx-prom/agent.jar \
  https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.17.2/jmx_prometheus_javaagent-0.17.2.jar
COPY init.sh /
RUN chmod +x /init.sh

ENV NETWORKRAIL_USERNAME= NETWORKRAIL_PASSWORD= NETWORKRAIL_TOPICS=
ENV DARWIN_USERNAME= DARWIN_PASSWORD= DARWIN_HOST= DARWIN_TOPICS=
ENV NR_KB_USERNAME= NR_KB_PASSWORD= NR_KB_HOST= NR_KB_TOPICS=

VOLUME /srv/activemq/data

EXPOSE 1099 1883 5672 8161 9191 61613 61614 61616

CMD ["/init.sh"]

