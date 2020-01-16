# pwm-formula
Salt formula to install PWM

## General Notes
This formula does not build the application. It assumes that you have the WAR file and configuration files stored in an AWS S3 Bucket.

The formula will look for the following files in the bucket:
* pwm18.war
* PwmConfiguration.xml
* PwmConfiguration.xml.sha1

## Available States
### pwm.iptables
Setup iptables firewall rules

### pwm.hostname
Configure the hostname. This is meant to address ec2 hosts that come with names like ip-10-10-0-123 for a hostname

### pwm.install
Install PWM

### pwm.configure
Setup all of the configuration files

### pwm.customize
Customize the welcome page for your environment

### pwm.ost_integration
Setup scripts to watch for new users being added and send a ticket to OSTicket via its API