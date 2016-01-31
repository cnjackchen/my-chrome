# inet.py 3.2
# -*- coding: cp936 -*-

import random, os, sys, time
import configparser, re
import encodings.idna
from concurrent.futures import ThreadPoolExecutor
import threading
from ipaddress import IPv4Network
from dnslib.dns import DNSRecord, DNSQuestion, QTYPE
import socket, ssl

user_agent = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1) Chrome/48.0.2564.82'
max_ip_num = 5
max_threads = 20

domains = [
    'google.com', 'google.com.hk', 'google.lt', 'google.es', 'google.co.zm',
    'google.bs', 'google.sn', 'google.hu', 'google.com.kw',
    'google.com.tr', 'google.com.om', 'google.rs', 'google.sh',
    'google.co.ma', 'google.co.ve', 'google.be', 'google.co.zw',
    'google.com.mx', 'google.ag', 'google.bj', 'google.ca',
    'google.co.je', 'google.co.jp', 'google.co.uk', 'google.com.tw',
    'google.hn', 'google.ne.jp', 'google.jp', 'google.nl', 'gstatic.com',
    'google.com.mt', 'google.rw', 'google.com.br', 'google.com.et', 'google.mv'
]

dns_servers = '''\
8.8.8.8
8.8.4.4
58.97.113.158
183.178.82.205
211.12.35.97
85.132.32.41
187.94.192.28
92.241.103.54
81.149.82.229
59.48.71.206
83.97.65.45
211.233.62.35
59.124.35.231
81.95.128.218
112.124.29.117
217.28.98.62
213.193.123.146
81.196.170.20
62.167.15.53
165.228.233.175
217.72.1.2
123.203.115.14
195.162.8.154
188.94.136.201
91.237.143.195
114.114.114.119
212.14.60.230
195.147.8.110
122.129.84.174
211.144.32.87
79.136.15.130
212.109.178.14
124.107.135.126
58.253.87.45
194.24.178.10
133.18.5.80
213.248.181.20
118.119.9.174
203.172.141.52
46.105.55.84
216.66.80.90
185.63.12.8
195.22.192.252
62.7.81.178
216.66.80.98
89.140.58.188
91.189.0.2
80.254.174.205
61.218.112.24
216.185.64.10
163.20.52.80
193.33.63.168
202.63.64.57
14.23.85.166
222.139.153.250
178.156.45.211
80.78.162.2
122.1.34.234
212.175.177.34
91.109.3.92
202.72.217.74
125.206.246.218
85.14.174.252
91.207.40.2
212.33.190.215
63.218.44.186
203.29.87.164
117.79.226.5
183.233.81.222
85.14.174.253
89.235.9.9
46.16.178.214
78.31.96.2
213.186.192.198
12.205.44.4
201.62.72.177
194.140.184.5
122.218.39.242
194.132.32.32
189.203.25.171
118.119.9.232
77.79.197.45
202.124.97.26
37.187.151.16
62.3.32.17
31.211.59.132
210.56.153.2
202.148.202.3
203.140.150.48
186.74.153.60
89.140.58.207
194.209.60.10
218.161.94.54
14.199.36.97
77.85.169.227
37.233.9.129
211.87.4.65
220.135.62.252
218.28.88.249
61.91.33.6
35.8.2.41
103.20.188.35
61.63.0.66
147.235.251.3
94.188.42.135
173.198.36.2
72.52.104.74
82.141.136.2
123.203.36.39
209.217.50.196
194.209.60.8
212.248.72.232
78.47.34.12
95.78.184.9
82.96.65.2
218.219.147.190
60.248.34.143
212.51.16.1
114.179.83.175
208.67.222.220
122.117.223.54
90.182.167.154
14.23.168.155
202.232.255.233
203.198.7.66
202.66.54.67
112.219.149.28
203.189.89.35
59.125.53.129
222.225.2.118
125.244.89.45
202.180.161.1
210.180.98.69
194.186.243.206
12.172.9.45
83.228.65.52
122.117.223.32
77.37.249.161
193.43.17.4
193.226.61.1
119.247.217.182
182.18.160.30
80.74.253.18
88.151.176.11
178.33.23.125
210.142.182.130
218.102.23.228
212.77.178.83
212.181.124.8
62.38.107.152
192.99.195.133
80.76.244.93
94.74.220.142
82.113.37.218
114.130.11.66
212.9.28.233
125.227.175.78
80.242.44.36
114.114.115.119
61.92.102.131
83.96.188.4
79.136.23.137
210.71.68.1
193.26.6.130
60.164.164.7
115.125.115.199
216.198.139.69
87.106.65.141
14.136.166.153
200.164.174.2
193.151.32.40
91.189.0.5
203.89.226.26
77.120.224.86
180.250.205.77
2.118.128.9
118.163.146.235
77.85.169.140
111.40.194.26
194.169.235.2
120.194.132.38
77.85.169.21
89.65.28.7
213.248.191.30
188.235.4.55
221.143.41.140
218.53.53.200
212.41.194.233
202.30.143.11
121.97.28.177
58.137.10.211
220.255.4.18
120.236.72.18
46.36.20.23
175.45.16.134
178.210.45.54
213.129.111.171
93.73.221.235
203.45.215.206
202.180.160.1
178.254.129.65
103.16.140.77
59.151.12.33
203.59.9.223
193.41.59.151
165.21.83.88
61.253.150.42
195.182.192.10
212.200.71.162
112.117.220.164
162.213.37.239
212.116.76.76
118.216.187.205
194.132.119.151
111.69.20.199
82.96.86.20
220.128.216.47
89.83.103.166
103.15.62.210
77.241.112.24
188.114.194.2
88.199.85.42
211.63.16.5
115.186.18.22
62.37.228.20
210.233.117.1
212.243.121.20
61.56.211.185
65.97.249.101
111.118.190.234
61.218.161.155
121.254.224.212
64.250.243.71
211.8.5.115
213.251.133.164
217.18.206.12
180.222.155.233
176.104.15.74
211.21.108.189
193.16.209.2
197.80.196.21
82.204.186.250
91.197.164.11
94.181.95.199
114.114.114.114
123.103.142.7
217.22.161.24
61.205.61.72
212.248.63.40
217.114.71.155
1.242.148.194
79.134.54.190
195.46.239.58
79.98.216.231
87.106.65.49
194.116.170.66
217.32.105.66
46.14.254.27
113.196.149.205
176.9.150.218
77.85.169.19
41.134.182.73
211.237.13.199
114.114.115.115
203.18.88.10
83.172.85.202
77.85.169.4
212.93.136.2
61.66.215.9
211.115.68.26
212.186.249.177
88.255.141.38
61.92.4.68
91.151.199.34
203.198.198.67
79.140.64.2
212.110.122.132
66.165.183.87
210.225.175.66
118.163.87.105
89.165.170.30
112.2.9.60
220.109.224.25
62.82.196.138
220.233.0.2
173.241.199.172
218.219.148.6
216.143.135.11
120.150.196.32
217.144.144.211
213.251.196.76
77.240.15.14
122.255.177.106
195.67.15.73
89.28.151.239
168.154.160.5
213.248.45.60
118.163.184.97
122.128.107.153
176.10.128.171
159.226.8.25
120.195.134.48
109.252.241.74
84.232.182.20
195.147.8.178
123.215.198.209
202.136.162.11
124.178.237.98
123.203.65.3
61.208.115.242
61.206.183.135
195.209.96.19
193.109.160.177
163.23.104.65
78.31.0.113
194.247.23.189
80.239.207.176
61.99.77.199
120.202.58.250
109.236.123.130
122.152.138.177
62.36.225.150
124.47.92.71
211.237.65.31
62.20.82.18
212.243.46.140
202.248.37.74
2.229.13.232
168.1.90.196
195.206.96.47
77.42.250.78
94.101.93.3
212.118.241.1
188.32.6.16
212.19.149.226
85.132.48.35
60.249.5.131
221.31.35.6
82.216.111.121
212.73.65.40
85.88.19.10
66.163.0.173
74.55.251.82
37.123.168.224
203.211.134.143
195.20.193.11
201.33.201.254
202.75.100.251
213.42.52.79
91.121.34.67
202.79.18.116
'''

dns_servers = set(dns_servers.split())

inactive_servers = set()
good_servers = set()
default_servers = set()
ini_file = ''
config = configparser.ConfigParser()
#config.optionxform = str # 区分大小写
# {ip1:time1, ip2:time2, ...}
google_com = {}
# [host with wild card, host, [time,ip], [time,ip],...],
# ex: ['*.google.com.*', 'google.com', [0.1, '216.58.216.3']]
host_map = []
tested_ips = set()
good_ips = set()
ip_is_enough = False
start_time= time.time()
check_inifile = False
lock = threading.RLock()
ssl._create_default_https_context = ssl._create_unverified_context # ignore ssl certificate error

def groupip(ip):  ## ip = [time, ip, [domains]]
    global check_inifile, ini_file, config, host_map, google_com, max_ip_num
    configchanged = False
    if len(google_com) < max_ip_num and ip[1] not in google_com.keys():
        if 'www.google.com' in ip[2] or 'google.com' in ip[2] or '*.google.com' in ip[2]:
            google_com[ip[1]] = ip[0]
            if len(google_com) == 1 and check_inifile:
                config.set('IPLookup', 'google_com', ip[1])
                configchanged = True
    if check_inifile and len(host_map):
        for i in host_map:
            if (len(i)-2) >= 3: continue
            for dname in ip[2]:
                if i[0] in dname or i[1] in dname:
                    if len(i) < 3:
                        i.append(ip[0:2])
                        config.set('HostMap', i[0], ip[1])
                        configchanged = True
                    elif ip[1] not in [j[1] for j in i[2:]]:
                        i.append(ip[0:2])
                    break
    if check_inifile and configchanged:
        with open(ini_file, 'w') as f:
            config.write(f)

def nslookup(domain, nservers=['8.8.8.8', '114.114.114']):
    global tested_ips, ip_is_enough, inactive_servers, good_servers

    if ip_is_enough: return
    try:
        q = DNSRecord(q=DNSQuestion(domain, getattr(QTYPE,'A')))
        a_pkt = q.send(nservers[0], 53, tcp=False, timeout=3)
        a = DNSRecord.parse(a_pkt)
        if a.header.tc:
            # Truncated - retry in TCP mode
            a_pkt = q.send(nservers[0], 53, tcp=True, timeout=3)
            a = DNSRecord.parse(a_pkt)
        a = a.short()
        if not a:
            raise Exception('no response.')
    except Exception as e:
        with lock:
            if nservers[0] not in inactive_servers:
                inactive_servers.add(nservers[0])
                #print(inactive_servers)
            if nservers[0] in good_servers:
                good_servers.remove(nservers[0])
            print('dns error: ', domain, nservers[0], e)
        return
    a = a.split('\n')

    if nservers[0] in inactive_servers:
        inactive_servers.remove(nservers[0])
    for ip in a:
        if ip[-1] != '.':  ##  maybe CNAME
            with lock:
                if ip_is_enough:
                    break
                if ip in tested_ips:
                    continue
                tested_ips.add(ip)
            if checkip(ip, domain):
                with lock:
                    if nservers[0] not in good_servers:
                        good_servers.add(nservers[0])


def get_dnsserver_list():
    '''
    based on goagent

    '''
    import os
    if os.name == 'nt':
        import ctypes, ctypes.wintypes, struct, socket
        DNS_CONFIG_DNS_SERVER_LIST = 6
        buf = ctypes.create_string_buffer(2048)
        ctypes.windll.dnsapi.DnsQueryConfig(DNS_CONFIG_DNS_SERVER_LIST,
            0, None, None, ctypes.byref(buf), ctypes.byref(ctypes.wintypes.DWORD(len(buf))))
        ipcount = struct.unpack('I', buf[0:4])[0]
        iplist = [socket.inet_ntoa(buf[i:i+4]) for i in range(4, ipcount*4+4, 4)]
        return iplist
    elif os.path.isfile('/etc/resolv.conf'):
        with open('/etc/resolv.conf', 'rb') as fp:
            return re.findall(r'(?m)^nameserver\s+(\S+)', fp.read())
    else:
        print("get_dnsserver_list failed: unsupport platform '%s'", os.name)
        return []

def checkip(ip, domain):
    global ip_is_enough, tested_ips, good_ips, start_time
    with lock:
        if ip_is_enough:
            return False
        if ip not in tested_ips:
            tested_ips.add(ip)

    tempsocks = socket.socket
    for chance in range(2):
        result = []
        dnames = []
        port = 80
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            if chance == 1:
                context = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
                context.verify_mode = ssl.CERT_REQUIRED
                context.load_default_certs()
                sock = context.wrap_socket(sock)
                port = 443
            sock.settimeout(3)
            sock.connect((ip, port))
            st = time.time()
            sock.send(bytes("GET / HTTP/1.1\r\nUser Agent: %s\r\n\r\n" % user_agent, "utf-8"))
            data = sock.recv(128)
            en = time.time()
            data = data.decode('utf-8', 'ignore')
            code = data.split(maxsplit=2)
            if len(code) < 2 or int(code[1]) >= 400:
                break
            result = [round(en-st, 3), ip]
            if chance == 1:
                cert = sock.getpeercert()
                for i in cert['subject']:
                    if 'commonName' in i[0]:
                        dnames.append(i[0][1])
                for i in cert['subjectAltName']:
                    dnames.append(i[1])
        except:
            break
        finally:
            if sock: sock.close()
    if len(dnames):  ## check host
        result.append(dnames)
    socket.socket = tempsocks

    isgoodip = False
    with lock:
        if not ip_is_enough:
            if len(result) >= 3:  ## [response time, ip, [commonName + subjectAltName]]
                if domain in result[2]:
                    isgoodip = True
                good_ips.add(result[1])
                print(ip, domain, '## good ip, tested %d good %d elapsed %.1fs'
                    % (len(tested_ips), len(good_ips), time.time()-start_time))
                groupip(result)
            else:
                print(ip, domain, '## bad ip, tested %d good %d elapsed %.1fs'
                      % (len(tested_ips), len(good_ips), time.time()-start_time))
    return isgoodip

##  check if any threads is alive
def thread_alive(tasks):
    for task in tasks:
        if not task.done():
            return True
    return False

def checkini(threads_num):
    global ini_file, config, dns_servers, default_servers, inactive_servers, good_servers, tested_ips, good_ips
    global host_map, ip_is_enough, max_ip_num, google_com, max_threads, st

    start_time= time.time()

    config.read(ini_file)
    if not config.has_section('IPLookup'):
        config['IPLookup'] = {'google_com':'', 'Servers':'', 'InactiveServers':'', 'MapHost':1}
        with open(ini_file, 'w') as f:
            config.write(f)

    s = config.get('IPLookup', 'InactiveServers') if config.has_option('IPLookup', 'InactiveServers') else ''
    if s:
        inactive_servers_0 = set(s.split('|'))
        inactive_servers = set(s.split('|'))
    else:
        inactive_servers_0 = set()
        inactive_servers = set()
    s = config.get('IPLookup', 'Servers') if config.has_option('IPLookup', 'Servers') else ''
    if s:
        good_servers_0 = set(s.split('|'))
        good_servers = set(s.split('|'))
    else:
        good_servers_0 = set()
        good_servers = set()
    servers = good_servers|default_servers
    if len(servers) < 40:
        servers = servers|set(random.sample((dns_servers-inactive_servers-servers), 40-len(servers)))
    if len(servers) < 40:
        servers = servers|set(random.sample((dns_servers-servers), 40-len(servers)))

    map_host = config.getint('IPLookup', 'MapHost') if config.has_option('IPLookup', 'MapHost') else 0
    if map_host:
        try:
            for k, v in config.items('HostMap'):
                if re.match('^[\d\.\|]+$', v) or not v:
                    d = re.sub('^[\.*]+|[\.*]+$', '', k)  ##  remove leading trailing . and * if any
                    host_map.append([k, d])
        except:
            pass

    print('check google ips from inifile...')
    with ThreadPoolExecutor(max_workers=threads_num) as executor:
        v = config.get('IPLookup', 'google_com') if config.has_option('IPLookup', 'google_com') else ''
        if v:
            for ip in v.split('|'):
                if ip not in tested_ips:
                    executor.submit(checkip, ip, 'google.com')
        for hostpair in host_map:
            v = config.get('HostMap', hostpair[0])
            if v:
                for ip in v.split('|'):
                    if ip not in tested_ips:
                        executor.submit(checkip, ip, hostpair[1])

    templist = sorted(google_com.items(), key=lambda d:d[1])
    config.read(ini_file)
    config.set('IPLookup', 'google_com', '|'.join(i[0] for i in templist))
    if len(host_map):
        for hostpair in host_map:
            if len(hostpair) < 3:
                config.set('HostMap', hostpair[0], '')
            else:
                config.set('HostMap', hostpair[0], '|'.join(i[1] for i in sorted(hostpair[2:])))
    with open(ini_file, 'w') as f:
        config.write(f)

    if len(google_com) >= max_ip_num:
        ip_is_enough = True
    else:
        print('nslookup google.com via different servers...')
        for chance in range(2):
            sdomains = random.sample(domains, 4)  ## pick part domains randomly
            q = set()
            with ThreadPoolExecutor(max_workers=threads_num) as executor:
                for domain in sdomains:
                    for nameserver in servers:
                        q.add(executor.submit(nslookup, domain, [nameserver]))

                while thread_alive(q):
                    time.sleep(0.1)
                    if len(google_com) >= max_ip_num:
                        ip_is_enough = True
                        print('google ip is enough! wait until all threads complete...')
                        executor.shutdown()
                        break
            if ip_is_enough: break
            servers = set(random.sample(dns_servers, 40))  ##  another try with other servers

        inactive_servers = inactive_servers & dns_servers
        if inactive_servers != inactive_servers_0 or good_servers != good_servers_0:
            #print(good_servers)
            config.set('IPLookup', 'Servers', '|'.join(i for i in good_servers))
            config.set('IPLookup', 'InactiveServers', '|'.join(i for i in list(inactive_servers)[:49])) # 最多保存50个无效DNS server
            with open(ini_file, 'w') as f:
                config.write(f)

    if not ip_is_enough:
        print('extra search in some ranges...')
        iprange = []
        if len(good_ips):
            for i in good_ips:
                r = ".".join(i.split('.')[0:3])+'.0/24'
                if r not in iprange:
                    iprange.append(r)
        else:
             for i in tested_ips:
                r = ".".join(i.split('.')[0:3])+'.0/24'
                if r not in iprange:
                    iprange.append(r)
                    if len(iprange) >= 3:
                        break
        q = set()
        with ThreadPoolExecutor(max_workers=threads_num) as executor:
            for l in iprange:
                for ip in IPv4Network(l).hosts():
                    ip = str(ip)
                    if ip not in tested_ips:
                        q.add(executor.submit(checkip, ip, 'google.com'))
            while thread_alive(q):
                time.sleep(0.1)
                if len(google_com) >= max_ip_num:
                    ip_is_enough = True
                    print('google ip is enough! wait until all threads complete...')
                    executor.shutdown()
                    break

    print('save config...')
    templist = sorted(google_com.items(), key=lambda d:d[1])
    config.read(ini_file)
    config.set('IPLookup', 'google_com', '|'.join(i[0] for i in templist))
    if len(host_map):
        for hostpair in host_map:
            if len(hostpair) < 3:
                config.set('HostMap', hostpair[0], '')
            else:
                config.set('HostMap', hostpair[0], '|'.join(i[1] for i in sorted(hostpair[2:])))
    with open(ini_file, 'w') as f:
        config.write(f)

    print('check other domains for HostMap...')
    ip_is_enough = False
    q = set()
    with ThreadPoolExecutor(max_workers=threads_num) as executor:
        for hostpair in host_map:
            if len(hostpair) < 3:
                for nameserver in servers:
                    # try twice
                    q.add(executor.submit(nslookup, hostpair[0], [nameserver]))
                    q.add(executor.submit(nslookup, hostpair[1], [nameserver]))
        while thread_alive(q):
            time.sleep(0.1)
            enough = True
            for hostpair in host_map:
                if len(hostpair) < 3:
                    enough = False
                    break
            ip_is_enough = enough
            if ip_is_enough:
                print('ip is enough! wait until all threads complete...')
                executor.shutdown()
                break

    print('save config...')
    templist = sorted(google_com.items(), key=lambda d:d[1])
    config.read(ini_file)
    config.set('IPLookup', 'google_com', '|'.join(i[0] for i in templist))
    if len(host_map):
        for hostpair in host_map:
            if len(hostpair) < 3:
                config.set('HostMap', hostpair[0], '')
            else:
                config.set('HostMap', hostpair[0], '|'.join(i[1] for i in sorted(hostpair[2:])))
    with open(ini_file, 'w') as f:
        config.write(f)

if __name__ == "__main__":
    default_servers = set(get_dnsserver_list())

    #ini_file = "MyChrome_v3.5.1.ini"
    #check_inifile = True
    #checkini(max_threads)

    if len(sys.argv) == 2: # check ini_file
        ini_file = sys.argv[1]
        if os.path.isfile(ini_file):
            check_inifile = True
            checkini(max_threads)

    #input('press any key to quit')
