ETH_IF_OUT=$(ip route get 10.1.1.2 | grep -Eo "eth[0-9]")

# Drop all packets addressed to the gateway
sudo iptables -A INPUT -i $ETH_IF_OUT -j DROP

# Allow TCP packets addressed for port 80 coming from the three client machines only
sudo iptables -A FORWARD -i $ETH_IF_OUT -s 10.1.2.2 -d 10.1.5.2 -p tcp --dport 80 -j ACCEPT
sudo iptables -A FORWARD -i $ETH_IF_OUT -s 10.1.3.2 -d 10.1.5.2 -p tcp --dport 80 -j ACCEPT
sudo iptables -A FORWARD -i $ETH_IF_OUT -s 10.1.4.2 -d 10.1.5.2 -p tcp --dport 80 -j ACCEPT

# Accept packets coming from the router
sudo iptables -A FORWARD -i $ETH_IF_OUT -s 10.1.1.2 -d 10.1.5.2 -j ACCEPT

# Drop all other packets
sudo iptables -A FORWARD -i $ETH_IF_OUT -j DROP