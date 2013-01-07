#!/bin/bash

SENSOR=sensor1
SERVER=10.10.10.1
INTERFACES="eth0 eth1 eth2"
BY2PORT=8000
DEBUG="1"
LOG="/var/log/securityonionsetup.log"

for INTERFACE in $INTERFACES
do
	SENSORNAME="$SENSOR-$INTERFACE"
        [ $DEBUG -eq 1 ] && echo "DEBUG: Adding Sensor $SENSORNAME."

	# Add the sensor
        /usr/local/sbin/nsm_sensor_add --sensor-name="$SENSORNAME" --sensor-interface="$INTERFACE" --sensor-interface-auto=no \
                                        --sensor-server-host=$SERVER --sensor-server-port=7736 \
                                        --sensor-barnyard2-port=$BY2PORT --sensor-auto=yes --sensor-utc=yes \
                                        --sensor-vlan-tagging=no --sensor-net-group="$SENSORNAME" --force-yes | tee -a $LOG

	# Increment the Barnyard2 port number
        ((BY2PORT++))

        # Copy our customized snort.conf (and associated files) into place
        cp /etc/snort/* /etc/nsm/"$SENSORNAME"/ | tee -a $LOG
        cp /etc/suricata/suricata.yaml /etc/nsm/"$SENSORNAME"/ | tee -a $LOG

        # Create symbolic links for sid-msg.map, gen-msg.map, and sensor rules directory
        rm -f /etc/nsm/"$SENSORNAME"/sid-msg.map | tee -a $LOG
        ln -s /etc/nsm/sid-msg.map /etc/nsm/"$SENSORNAME"/sid-msg.map | tee -a $LOG
        rm -f /etc/nsm/"$SENSORNAME"/gen-msg.map | tee -a $LOG
        ln -s /etc/nsm/gen-msg.map /etc/nsm/"$SENSORNAME"/gen-msg.map | tee -a $LOG
        #ln -s /etc/nsm/rules /nsm/server_data/"$SGUIL_SERVER_NAME"/rules/"$SENSORNAME" | tee -a $LOG

        # Configure snort.conf to log statistics to /nsm/sensor_data/"$SENSORNAME"/snort.stats
        sed -i "s|# preprocessor perfmonitor: time 300 file /var/snort/snort.stats pktcnt 10000|preprocessor perfmonitor: time 300 file /nsm/sensor_data/"$SENSORNAME"/snort.stats pktcnt 10000|" /etc/nsm/"$SENSORNAME"/snort.conf | tee -a $LOG
done

