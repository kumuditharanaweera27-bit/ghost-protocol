from scapy.all import IP, UDP, TCP, DNS, DNSQR, DNSRR, Raw, wrpcap, Ether, ARP, ICMP

packets = []

#Background ARP and ICMP Traffic
for i, host in enumerate(["10.10.20.40", "10.10.20.60", "10.10.20.30"]):
	arp = Ether(
		src=f"02:00:00:00:00:{40+i:02x}",
		dst="ff:ff:ff:ff:ff:ff"
	) / ARP(
		op=1,
		hwsrc=f"02:00:00:00:00:{40+i:02x}",
		psrc=host,
		pdst="10.10.20.20"
		)
	arp.time = 7.0 + i * 0.2
	packets.append(arp)

for i, host in enumerate(["10.10.20.40", "10.10.20.60"]):
	ping = IP(src=host, dst="10.10.20.20") / ICMP(type=8, id=100+i, seq=1)
	reply = IP(src="10.10.20.20", dst=host) / ICMP(type=0, id=100+i, seq=1)

	ping.time = 8.0 + i * 0.5
	reply.time = ping.time + 0.03

	packets.extend([ping, reply])

def add_dns(client, name, answer, start): 
	query = (
		IP(src=client, dst="10.10.20.10") /
		UDP(sport=53000, dport=53) /
		DNS(id=int(start * 100), rd=1, qd=DNSQR(qname=name))
	)
	reply = (
		IP(src="10.10.20.10", dst=client) /
		UDP(sport=53, dport=53000) /
		DNS(
			id=int(start * 100), qr=1, aa=1,
			qd=DNSQR(qname=name),
			an=DNSRR(rrname=name, ttl=300, rdata=answer)
		)
	)
	query.time = start
	reply.time = start + 0.04
	packets.extend([query, reply])

def add_tcp_flow(src, dst, sport, dport, request, response, start):
	client_isn = 10000 + sport
	server_isn = 20000 + dport

	syn = IP(src=src, dst=dst) / TCP(
		sport=sport, dport=dport, flags="S", seq=client_isn
	)
	synack = IP(src=dst, dst=src) /TCP(
		sport=dport, dport=sport, flags="SA",
		seq=server_isn, ack=client_isn + 1
	)
	ack = IP(src=src, dst=dst) /TCP(
		sport=sport, dport=dport, flags="A",
		seq=client_isn + 1, ack=server_isn + 1
	)
	req = IP(src=src, dst=dst) /TCP(
		sport=sport, dport=dport, flags="PA",
		seq=client_isn + 1, ack=server_isn + 1
	) / Raw(load=request.encode())

	resp = IP(src=dst, dst=src) /TCP(
		sport=dport, dport=sport, flags="PA",
		seq=server_isn + 1,
		ack=client_isn + 1 + len(request.encode()),
	) / Raw(load=response.encode())

	final_ack = IP(src=src, dst=dst) /TCP(
		sport=sport, dport=dport, flags="A",
		seq=client_isn + 1 + len(request.encode()),
		ack=server_isn + 1 + len(response.encode())
	)

	for packet, offset in zip(
		[syn, synack, ack, req, resp, final_ack],
		[0, 0.01, 0.02, 0.05, 0.09, 0.10]
	):
		packet.time = start + offset
		packets.append(packet)

#Normal DNS activity
add_dns("10.10.20.40", "intranet.nexora.local", "10.10.20.20", 1.0)
add_dns("10.10.20.60", "intranet.nexora.local", "10.10.20.20", 2.0)
add_dns("10.10.20.30", "updates.nexora.local", "10.10.20.20", 3.0)

#Normal web and application traffic
add_tcp_flow(
	"10.10.20.40", "10.10.20.20", 50100, 80,
	"GET /dashboard HTTP/1.1\r\nHost: intranet.nexora.local\r\n\r\n",
	"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nEmployee portal",
	4.0
)
add_tcp_flow(
	"10.10.20.60", "10.10.20.20", 50101, 80,
	"GET /help HTTP/1.1\r\nHost: intranet.nexora.local\r\n\r\n",
	"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nHelp centre",
	5.0
)
add_tcp_flow(
	"10.10.20.25", "10.10.20.30", 50102, 8080,
	"GET /health HTTP/1.1\r\nHost: app.nexora.local\r\n\r\n",
	"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nOK",
	6.0
)
#Suspicious activity: repeated requests from one workstation to an internal host not seen in the noramal besline
target = "10.10.20.15"
workstation = "10.10.20.50"

add_tcp_flow(
	workstation, target, 51211, 80,
	"GET /status HTTP/1.1\r\nHost: 10.10.20.15\r\nUser-Agent: Nexora-Monitor/2.1\r\n\r\n",
	"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nService status: normal",
	10.0
)
add_tcp_flow(
	workstation, target, 51212, 80,
	"GET /backup/index HTTP/1.1\r\nHost: 10.10.20.15\r\nUser-Agent: Nexpra-Monitor/2.1\r\n\r\n",
	"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nArchive reference: nightingale-15",
	10.5
)
add_tcp_flow(
	workstation, target, 51213, 80,
	"GET /records HTTP/1.1\r\nHost: 10.10.20.15\r\nUser-Agent: Nexora-Monitor/2.1\r\n\r\n",
	"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nRequest completed",
	11.0
)
add_tcp_flow(
	"10.10.20.40", "10.10.20.15", 41040, 80,
	"GET /status HTTP/1.1\r\nHost: 10.10.20.15\r\nUser-Agent: Mozilla/5.0\r\n\r\n",
	"HTTP/1.1 200 OK\r\nContent-Type: test/plain\r\n\r\nArchive reference: OLD-7",
	12.0
)
add_tcp_flow(
	"10.10.20.60", "10.10.20.15", 41060, 80,
	"GET /backup/index HTTP/1.1\r\nHost: 10.10.20.15\r\nUser-Agent: Mozilla/5.0\r\n\r\n",
	"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nArchive reference: CASE-3",
	13.0
)

for i, packet in enumerate(packets):
	if Ether not in packet:
		packets[i] = Ether() / packet

packets.sort(key=lambda packet: packet.time)
wrpcap("traffic_capture.pcap", packets)

print(f"Created traffic_capture.pcap with {len(packets)} packets.")
