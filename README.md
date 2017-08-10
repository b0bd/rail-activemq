rail_activemq
=============

- [Introduction](#introduction)
- [Quick Start](#Quick Start)
- [Subscribers](#National Rail Subscription)
  - [National Rail Enquiries (Darwin)](#National Rail Enquiries Subscriber)
  - [Network Rail](#Network Rail Subscriber)
- [Available Protocols](#Available Protocols)
- [Web Console](#Web Console)  
- [JMX](#JMX)
- [Security](#Security)
- [Final Notes](#Final Notes)
# Introduction

ActiveMQ configured with connectors to bridge Network Rail Enquiries or National Rail real-time data feeds as described by [Open Rail Data Wiki - Advanced Uses](http://nrodwiki.rockshore.net/index.php/Advanced_Uses) and provide those feeds locally. 

The container also supports connecting to both the NRE and Network Rail feeds simultaneously if both subcribers are configured.

# Quick Start

To bridge the National Rail Enquiries Darwin feed to a local topic named nationalrail, and expose it locally by STOMP on port 61613:
```bash
docker run -e NATIONALRAIL_QUEUE=<queue-id> -p 61613:61613 b0bd/rail_activemq
```

To bridge the TRAIN_MVT_ALL_TOC feed from Network Rail, and expose it locally by STOMP on port 61613:
```bash
docker run -e NETWORKRAIL_USERNAME=<networkrail-username> \
           -e NETWORKRAIL_PASSWORD=<networkrail-password> \
           -e NETWORKRAIL_TOPICS=TRAIN_MVT_ALL_TOC        \
           -p 61613:61613 b0bd/rail_activemq
```
# National Rail Enquiries Subscriber

To subscribe to the National Rail Darwin feeds, first create an account at [National Rail Enquiries](https://datafeeds.nationalrail.co.uk).

To configure the subscriber, set the environment variable `NATIONALRAIL_QUEUE` to the queue name shown on the the Real Time Feed section on the My Feeds tab.

This will create a local topic `nationalrail` in ActiveMQ that will bridge the remote queue.  Note that if you have existing code that connects to datafeeds.nationalrail.co.uk you will need to modify the code to subscribe to the nationalrail topic instead of a queue.

More information on the National Rail Darwin feeds is available at [Open Rail Data Feeds - NRE Feeds](http://nrodwiki.rockshore.net/index.php/About_the_NRE_Feeds)

# Network Rail Subscriber

To subscribe to the Network Rail data feeds, create an account at [Network Rail](https://datafeeds.networkrail.co.uk).

To configure the subscriber, set the environment variables `NETWORKRAIL_USERNAME` and `NETWORKRAIL_PASSWORD` to the information used to log into the Network Rail datafeeds site.

To select the topics to bridge from the Network Rail feed, set the environment varable `NETWORKRAIL_TOPICS` to a comma seperated list of the topics required. For example to subscribe to the Train Describer feeds for Scotland West and Sussex, set `NETWORKRAIL_TOPICS=TD_SW_SIG_AREA,TD_SUSSEX_SIG_AREA`

As a shortcut, setting `NETWORKRAIL_TOPICS=ALL` is equivalent to setting `NETWORKRAIL_TOPICS=TRAIN_MVT_ALL_TOC,RTPPM_ALL,TD_ALL_SIG_AREA,VSTP_ALL,TSR_ALL_ROUTE`

Be sure to select the feeds to mirror under the My Feeds tab in the Network Rail account.

More information on the Network Rail feeds is available at [Open Rail Data Feeds - Network Rail Feeds](http://nrodwiki.rockshore.net/index.php/About_the_feeds)

# Available Protocols

* 1883 - MQTT
* 5672 - AMQP
* 61613 - STOMP
* 61614 - WebSocket
* 61616 - Openwire

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
