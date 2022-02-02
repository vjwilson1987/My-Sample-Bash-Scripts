#!/bin/bash

#########################################################
# Bandwidth checker for a RHEL7/Centos7                 #
# Nagios checker script                               #
# Requirements: `vnstat`,`bc`,`ethtool`                 #
# Output calculating in kilobits per second(Kbps)       #
# Written by Vipin John Wilson(-,-)                     #
#########################################################

BIN_ETHTOOL=$(which ethtool)
#IF=$(ip link show | grep 'enp\|eth' | grep "state UP\|inet" | awk -F: '{print $2}')
IF=$(ifconfig | head -1 | awk '{print $1}' | cut -d: -f1)
SPEED=$($BIN_ETHTOOL $IF | grep Speed | awk '{print $2}' | grep -o '[[:digit:]]*')

print_result()
{
##Bash supports only integer math and better dealing it inside (( ))
if (( $RBIT < 7000 )) && (( $TBIT < 7000 )); then
        echo "OK: $IF UP: Receive "$RBIT"Kbps and Transmit "$TBIT"Kbps";
        exit 0;
elif (( $RBIT >= 7000 && $RBIT <= 15000 )) || (( $TBIT >= 7000 && $TBIT <= 15000 )); then
        echo "Warning: $IF UP: Receive "$RBIT"Kbps and Transmit "$TBIT"Kbps";
        exit 1;
elif (( $RBIT > 15000 )) || (( $TBIT > 15000 )); then
        echo "Critical: $IF UP: Receive "$RBIT"Kbps and Transmit "$TBIT"Kbps";
        exit 2;
else
        echo "Unknown Error";
        exit 3;
fi;
}

cal_receive()
{
if [[ $RUNIT == "kB/s" ]]; then
        RBIT=$(printf "%.0f" $(echo "scale=2;$RRATE * 8"|bc -l));  ##Float to Integer
elif [[ $RUNIT == "Mbit/s" ]]; then
        RBIT=$(printf "%.0f" $(echo "scale=2;$RRATE * 1024"|bc -l)); ##Float to Integer
else
        RBIT=$(printf "%.0f" $RRATE); ##Float to Integer
fi;
}

cal_transmit()
{
if [[ $TUNIT == "kB/s" ]]; then
        TBIT=$(printf "%.0f" $(echo "scale=2;$TRATE * 8"|bc -l)); ##Float to Integer
elif [[ $TUNIT == "Mbit/s" ]]; then
        TBIT=$(printf "%.0f" $(echo "scale=2;$TRATE * 1024"|bc -l)); ##Float to Integer
else
        TBIT=$(printf "%.0f" $TRATE); ##Float to Integer
fi;
}

collect_values()
{
vnstat -tr -i $IF 2>/dev/null > /tmp/vnstat_check;
TX=$(grep -w tx /tmp/vnstat_check | awk '{print $2" "$3}');
RX=$(grep -w rx /tmp/vnstat_check | awk '{print $2" "$3}');
#TRATE=$(printf "%.0f" $(echo $TX | awk '{print $1}')); ##Float to Integer
#RRATE=$(printf "%.0f" $(echo $RX | awk '{print $1}')); ##Float to Integer
TRATE=$(echo $TX | awk '{print $1}');
RRATE=$(echo $RX | awk '{print $1}');
TUNIT=$(echo $TX | awk '{print $2}');
RUNIT=$(echo $RX | awk '{print $2}');
which bc >/dev/null 2>&1;
if [[ $? -eq 0 ]]; then
        max_val_bit=$(echo "$SPEED * 1024"|bc -l); #to Kilobits
else
        yum install bc -y;
        max_val_bit=$(echo "$SPEED * 1024"|bc -l); #to Kilobits
fi;
cal_receive;
cal_transmit;
print_result;
}

which vnstat >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
        collect_values;
else
        echo -e "\nInstalling epel-release repo\n";
        yum install epel-release -y;
        echo -e "\nNow installing vnstat\n";
        yum install vnstat -y;
        echo;
        collect_values;
fi;