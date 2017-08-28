#!/bin/bash

# ================================================================================================================================================================
# Cleanup existing setup
# ================================================================================================================================================================

# Delete link list: lan0 lan1 lan2 lan3 lan4 wan wlan0 eth0.1 eth0.2 eth0.101 eth0.102 br0 br1
ip link del lan0
ip link del lan0 type bridge
ip link del lan1
ip link del lan1 type bridge
ip link del lan2
ip link del lan2 type bridge
ip link del lan3
ip link del lan3 type bridge
ip link del lan4
ip link del lan4 type bridge
ip link del wan
ip link del wan type bridge
ip link del wlan0
ip link del wlan0 type bridge
ip link del eth0.1
ip link del eth0.1 type bridge
ip link del eth0.2
ip link del eth0.2 type bridge
ip link del eth0.101
ip link del eth0.101 type bridge
ip link del eth0.102
ip link del eth0.102 type bridge
ip link del br0
ip link del br0 type bridge
ip link del br1
ip link del br1 type bridge

# Delete VLAN 1 on: lan0 lan1 lan2 lan3 lan4 wan wlan0 eth0.1 eth0.2 eth0.101 eth0.102 br0 br1
bridge vlan del vid 1 dev lan0
bridge vlan del vid 1 dev lan1
bridge vlan del vid 1 dev lan2
bridge vlan del vid 1 dev lan3
bridge vlan del vid 1 dev lan4
bridge vlan del vid 1 dev wan
bridge vlan del vid 1 dev wlan0
bridge vlan del vid 1 dev eth0.1
bridge vlan del vid 1 dev eth0.2
bridge vlan del vid 1 dev eth0.101
bridge vlan del vid 1 dev eth0.102
bridge vlan del vid 1 dev br0
bridge vlan del vid 1 dev br1

# Delete VLAN 101 on: lan0 lan1 lan2 lan3 lan4 wan wlan0 eth0.1 eth0.2 eth0.101 eth0.102 br0 br1
bridge vlan del vid 101 dev lan0
bridge vlan del vid 101 dev lan1
bridge vlan del vid 101 dev lan2
bridge vlan del vid 101 dev lan3
bridge vlan del vid 101 dev lan4
bridge vlan del vid 101 dev wan
bridge vlan del vid 101 dev wlan0
bridge vlan del vid 101 dev eth0.1
bridge vlan del vid 101 dev eth0.2
bridge vlan del vid 101 dev eth0.101
bridge vlan del vid 101 dev eth0.102
bridge vlan del vid 101 dev br0
bridge vlan del vid 101 dev br1

# Delete VLAN 102 on: lan0 lan1 lan2 lan3 lan4 wan wlan0 eth0.1 eth0.2 eth0.101 eth0.102 br0 br1
bridge vlan del vid 102 dev lan0
bridge vlan del vid 102 dev lan1
bridge vlan del vid 102 dev lan2
bridge vlan del vid 102 dev lan3
bridge vlan del vid 102 dev lan4
bridge vlan del vid 102 dev wan
bridge vlan del vid 102 dev wlan0
bridge vlan del vid 102 dev eth0.1
bridge vlan del vid 102 dev eth0.2
bridge vlan del vid 102 dev eth0.101
bridge vlan del vid 102 dev eth0.102
bridge vlan del vid 102 dev br0
bridge vlan del vid 102 dev br1
