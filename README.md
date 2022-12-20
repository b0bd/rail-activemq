rail-activemq
=============

- [Introduction](#introduction)
- [Quick Start](#quick-start)
- [Subscribers](#national-rail-subscription)
  - [National Rail](#national-rail-subcriber)
  - [Network Rail](#network-rail-subscriber)
- [Available Protocols](#available-protocols)
- [Web Console](#web-console)  
- [JMX](#jmx)
- [Security](#security)
- [Final Notes](#final-notes)


# Introduction

ActiveMQ configured with connectors to bridge Network Rail Enquiries or National Rail real-time data feeds as described by [Open Rail Data Wiki - Advanced Uses](http://nrodwiki.rockshore.net/index.php/Advanced_Uses) and provide those feeds locally. 

The container also supports connecting to both the NRE and Network Rail feeds simultaneously if both subcribers are configured.

# Quick Start

To bridge the National Rail Enquiries Darwin feed to a local topic named nationalrail, and expose it locally by STOMP on port 61613:
```bash
docker run -e NATIONALRAIL_QUEUE=<queue-id> -p 61613:61613 b0bd/rail-activemq
```

To bridge the TRAIN_MVT_ALL_TOC feed from Network Rail, and expose it locally by STOMP on port 61613:
```bash
docker run -e NETWORKRAIL_USERNAME=<networkrail-username> \
           -e NETWORKRAIL_PASSWORD=<networkrail-password> \
           -e NETWORKRAIL_TOPICS=TRAIN_MVT_ALL_TOC        \
           -p 61613:61613 b0bd/rail-activemq
```
# National Rail Subscriber

To subscribe to the National Rail feeds, first create an account at [National Rail Enquiries](https://opendata.nationalrail.co.uk).

More information on the National Rail Darwin feeds is available at [Open Rail Data Feeds - NRE Feeds](https://wiki.openraildata.com/index.php?title=About_the_National_Rail_Feeds)

## Darwin
To configure the Darwin subscriber, set the environment variables `DARWIN_USERNAME` and `DARWIN_PASSWORD` to the information
showing for Darwin Topic information shown on the "My Feeds" tab.

To select the topics to bridge from Darwin, set the the environment variable `DARWIN_TOPICS` to a comma seperated list of the 
required topics. 

As a shortcut, setting `DARWIN_TOPICS=ALL` is equivalent to setting `DARWIN_TOPICS="darwin.pushport-v16,darwin.status"`

## Knowledgebase Real Time
To configure the Knowledgebase subscriber, set the environment variables `NR_KB_USERNAME` and `NR_KB_PASSWORD` to the
information showing for Knowledgebase Topic information shown on the "My Feeds" tab.

To select the topics to bridge from Knowledgebase, set the the environment variable `NR_KB_TOPICS` to a comma seperated list of the required topics. 

As a shortcut, setting `NR_KB_TOPICS=ALL` is equivalent to setting `NR_KB_TOPICS="kb.incidents"`


# Network Rail Subscriber

To subscribe to the Network Rail data feeds, create an account at [Network Rail](https://datafeeds.networkrail.co.uk).

To configure the subscriber, set the environment variables `NETWORKRAIL_USERNAME` and `NETWORKRAIL_PASSWORD` to the information used to log into the Network Rail datafeeds site.

To select the topics to bridge from the Network Rail feed, set the environment varable `NETWORKRAIL_TOPICS` to a comma seperated list of the topics required. For example to subscribe to the Train Describer feeds for Scotland West and Sussex, set `NETWORKRAIL_TOPICS=TD_SW_SIG_AREA,TD_SUSSEX_SIG_AREA`

As a shortcut, setting `NETWORKRAIL_TOPICS=ALL` is equivalent to setting `NETWORKRAIL_TOPICS=TRAIN_MVT_ALL_TOC,RTPPM_ALL,TD_ALL_SIG_AREA,VSTP_ALL,TSR_ALL_ROUTE`

Be sure to select the feeds to mirror under the My Feeds tab in the Network Rail account.

More information on the Network Rail feeds is available at [Open Rail Data Feeds - Network Rail Feeds](https://wiki.openraildata.com/index.php?title=About_the_Network_Rail_feeds)

# Available Protocols

* 1883 - MQTT
* 5672 - AMQP
* 61613 - STOMP
* 61614 - WebSocket
* 61616 - Openwire

# Prometheus Exporter

* Prometheus metrics are available on port 9191 and url `/metrics`

# Web Console

* The ActiveMQ console is available on port 8161
* Hawt.io console is available on port 8161 and url `/hawtio`

# JMX

* JMX is available on port 1099.

# Security

This ActiveMQ instance is configured with the default ActiveMQ accounts and exposes all ports. Be extremely careful not to expose this container to the Internet.

# Final Notes

Please do not use this container to re-publish the NRE or National Rail data feeds to other people or organisations. Please see [Open Rail Data Wiki - Advanced Uses](http://nrodwiki.rockshore.net/index.php/Advanced_Uses) for further information.

This container and ActiveMQ configuration is community supported only. Please do not contact NRE or Network Rail about any questions or issues. 
