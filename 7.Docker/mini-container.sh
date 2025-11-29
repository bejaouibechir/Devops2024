#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Script : mini_container.sh
# But    : Créer un conteneur isolé à la main à l'aide des namespaces Linux
# -----------------------------------------------------------------------------

set -e

ROOTFS="/var/containers/rootfs"
HOSTNAME="labcontainer"
NETNS="net1"

# Créer le namespace réseau s'il n'existe pas
ip netns add $NETNS 2>/dev/null || true
ip link add veth-host type veth peer name veth-cont
ip link set veth-cont netns $NETNS

# Config réseau
ip addr add 10.10.10.1/24 dev veth-host
ip link set veth-host up
ip netns exec $NETNS ip addr add 10.10.10.2/24 dev veth-cont
ip netns exec $NETNS ip link set veth-cont up

# Entrer dans le conteneur
unshare --uts --ipc --pid --mount --fork --net=$NETNS chroot $ROOTFS /bin/bash
