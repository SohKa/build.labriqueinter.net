#!/bin/bash
# ================================================================================================================================================================
# Setup switch, interfaces, VLANs and IP
# ================================================================================================================================================================

# Create VLAN 101 on interface eth0: eth0.101
ip link add link eth0 name eth0.101 type vlan id 101
ip link set eth0.101 up

# Create VLAN 102 on interface eth0: eth0.102
ip link add link eth0 name eth0.102 type vlan id 102
ip link set eth0.102 up

# Create bridge br0 with STP(0) on VLAN 101 with interfaces/tagged: lan1 untag lan2 untag lan3 untag lan4 untag wlan0 untag eth0.101 tag
ip link add br0 type bridge
ip link set dev br0 type bridge stp_state 0
ip link set lan1 master br0
bridge vlan add vid 101 dev lan1 pvid untagged
bridge vlan add vid 101 dev lan1 pvid untagged self
ip link set lan1 up
ip link set lan2 master br0
bridge vlan add vid 101 dev lan2 pvid untagged
bridge vlan add vid 101 dev lan2 pvid untagged self
ip link set lan2 up
ip link set lan3 master br0
bridge vlan add vid 101 dev lan3 pvid untagged
bridge vlan add vid 101 dev lan3 pvid untagged self
ip link set lan3 up
ip link set lan4 master br0
bridge vlan add vid 101 dev lan4 pvid untagged
bridge vlan add vid 101 dev lan4 pvid untagged self
ip link set lan4 up
ip link set wlan0 master br0
bridge vlan add vid 101 dev wlan0 pvid untagged
bridge vlan add vid 101 dev wlan0 pvid untagged self
ip link set wlan0 up
ip link set eth0.101 master br0
bridge vlan add vid 101 dev eth0.101 pvid untagged
bridge vlan add vid 101 dev eth0.101 pvid untagged self
ip link set eth0.101 up
ip link set br0 up

# Create bridge br1 with STP(0) on VLAN 102 with interfaces/tagged: wan untag eth0.102 tag
ip link add br1 type bridge
ip link set dev br1 type bridge stp_state 0
ip link set wan master br1
bridge vlan add vid 102 dev wan pvid untagged
bridge vlan add vid 102 dev wan pvid untagged self
ip link set wan up
ip link set eth0.102 master br1
bridge vlan add vid 102 dev eth0.102 pvid untagged
bridge vlan add vid 102 dev eth0.102 pvid untagged self
ip link set eth0.102 up
ip link set br1 up

# Delete VLANs 1 on interfaces: lan0 lan1 lan2 lan3 lan4 wan wlan0 eth0.1 eth0.2 eth0.101 eth0.102 br0 br1
bridge vlan del dev lan0 vid 1 self
bridge vlan del dev lan0 vid 1 master
bridge vlan del dev lan1 vid 1 self
bridge vlan del dev lan1 vid 1 master
bridge vlan del dev lan2 vid 1 self
bridge vlan del dev lan2 vid 1 master
bridge vlan del dev lan3 vid 1 self
bridge vlan del dev lan3 vid 1 master
bridge vlan del dev lan4 vid 1 self
bridge vlan del dev lan4 vid 1 master
bridge vlan del dev wan vid 1 self
bridge vlan del dev wan vid 1 master
bridge vlan del dev wlan0 vid 1 self
bridge vlan del dev wlan0 vid 1 master
bridge vlan del dev eth0.1 vid 1 self
bridge vlan del dev eth0.1 vid 1 master
bridge vlan del dev eth0.2 vid 1 self
bridge vlan del dev eth0.2 vid 1 master
bridge vlan del dev eth0.101 vid 1 self
bridge vlan del dev eth0.101 vid 1 master
bridge vlan del dev eth0.102 vid 1 self
bridge vlan del dev eth0.102 vid 1 master
bridge vlan del dev br0 vid 1 self
bridge vlan del dev br0 vid 1 master
bridge vlan del dev br1 vid 1 self
bridge vlan del dev br1 vid 1 master

# Setup IP addresses and routing
ip addr flush dev br0
ip addr add 192.168.1.36/24 dev br0
ip addr flush dev br1
ip addr add 192.168.0.1/24 dev br1
ip route add default via 192.168.1.1 dev br0
