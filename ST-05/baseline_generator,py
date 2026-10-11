from scapy.all import IP, UDP, TCP, DNS, DNSQR, DNSRR, Raw, wrpcap
import random

packets = []
random.seed(42)

#Create a normal DNS query and response
def add_dns(client, name, answer, start):
	query_id = random.randint(1, 65535)
	sport = random.randint(40000, 60000)

	query = (
		IP(src=client, dst="10.10.20.10") /
		UDP(sport=sport, dport=53) /
		DNS(
			id=query_id,
			rd=1,
			qd=DNSQR(qname=name)
		)
	)

	response = (
		IP(src="10.10.20.10", dst=client) /
		UDP(sport=53, dport=sport) /
		DNS(
			id=query_id,
			qr=1,
			aa=1,
			rd=1,
			ra=1,
			qd=DNSQR(qname=name),
			an=DNSRR(rrname=name, type="A", ttl=300, rdata=answer)
		)
	)

	query.time = start
	response.time = start + 0.03
	packets.extend([query, response])

#Create a TCP conversation with a handshake
def add_tcp_flow(src, dst, sport, dport, request, response, start):
	client_seq = random.randint(10000, 50000)
	server_seq = random.randint(50000, 90000)

	syn = IP(src=src, dst=dst) / TCP(
		sport=sport, dport=dport,
		flags="S", seq=client_seq
	)

	synack = IP(src=dst, dst=src) / TCP(
		sport=dport, dport=sport,
		flags="SA", seq=server_seq, ack=client_seq + 1
	)

	ack = IP(src=src, dst=dst) / TCP(
		sport=sport, dport=dport,
		flags="A", seq=client_seq + 1, ack=server_seq + 1
	)

	req = IP(src=src, dst=dst) / TCP(
		sport=sport, dport=dport,
		flags="PA", seq=client_seq + 1, ack=server_seq + 1
	) / Raw(load=request)

	req_ack = IP(src=dst, dst=src) / TCP(
		sport=dport, dport=sport,
		flags="A", seq=server_seq + 1,
		ack=client_seq + 1 + len(request)
	)

	resp = IP(src=dst, dst=src) / TCP(
		sport=dport, dport=sport,
		flags="PA", seq=server_seq + 1,
		ack = client_seq + 1 + len(request)
	) / Raw(load=response)

	resp_ack = IP(src=src, dst=dst) / TCP(
		sport=sport, dport=dport,
		flags="A",
		seq=client_seq + 1 + len(request),
		ack=server_seq + 1 + len(response)
	)

	flow = [syn, synack, ack, req, req_ack, resp, resp_ack]

	for index, packet in enumerate(flow):
		packet.timee = start + index * 0.01

	packets.extend(flow)

#Normal DNS activity
add_dns(
	"10.10.20.40",
	"intranet,nexora.local",
	"10.10.20.20",
	1.0
)

add_dns(
	"10.10.20.60",
	"intranet.nexora.local",
	"10.10.20.20",
	2.0
)

add_dns(
	"10.10.20.30",
	"update.nexora.local",
	"10.10.20.20",
	3.0
)

#Normal employee web browsing
add_tcp_flow(
	"10.10.20.40", "10.10.20.20",
	50100, 80,
	b"GET /dashboard HTTP/1.1\r\nHost: intranet.nexora.local\r\nConnection: keep-alive\r\n\r\n",
	b"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 16\r\n\r\nEmployee portal",
	4.0
)

add_tcp_flow(
	"10.10.20.60", "10.10.20.20",
	50101, 80,
	b"GET /help HTTP/1.1\r\nHost: intranet.nexora.local\r\nConnection: keep-alive\r\n\r\n",
	b"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 12\r\n\r\nHelp centre",
	5.0
)

#Normal internal application request
add_tcp_flow(
	"10.10.20.25", "10.10.20.30",
	50102, 8080,
	b"GET /health HTTP/1.1\r\nHost: app.nexora.local\r\n\r\n",
	b"HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK",
	6.0
)

#Save baseline only: no suspicious session yet
packets.sort(key=lambda packet: float(packet.time))
wrpcap("baseline_test.pcap", packets)

print("Baseline PCAP created: baseline_test.pcap")
print(f"Total packets: {len(packets)}")
print("Suspicious session: not added yet")
