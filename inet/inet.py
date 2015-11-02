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
import socks # https://pypi.python.org/pypi/PySocks/ or https://github.com/Anorov/PySocks
import urllib.request
import winreg, win32api
import win32api

max_ip_num = 5
max_threads = 10

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
208.67.222.222
208.67.220.220
80.71.54.18
220.87.177.141
109.236.123.130
210.113.60.121
61.220.40.118
209.191.129.1
200.49.160.35
118.35.78.70
212.73.69.6
95.66.182.191
202.29.94.172
190.128.242.206
190.152.89.229
101.255.16.226
197.92.10.9
190.26.104.209
121.163.48.231
61.93.207.178
94.255.122.42
221.163.86.113
188.168.157.108
122.154.151.59
195.177.122.222
121.176.120.78
84.245.216.180
208.67.220.220
200.25.221.29
211.224.66.119
178.168.19.55
61.253.150.42
216.185.192.1
112.168.221.215
78.29.14.127
176.97.40.78
37.98.241.171
92.105.208.118
115.125.115.199
195.78.239.35
94.230.183.229
181.143.153.30
63.238.52.1
135.0.79.214
173.193.245.53
82.114.92.226
193.180.20.142
193.238.223.91
91.122.208.159
173.237.124.156
113.61.145.10
188.235.4.55
216.143.135.11
96.231.165.226
219.92.48.41
77.53.69.242
111.68.25.254
58.176.213.242
191.243.36.41
124.193.117.18
201.57.131.42
123.202.5.158
79.165.61.24
121.173.30.111
218.154.106.132
81.28.174.32
159.233.156.10
24.61.252.234
202.74.165.10
162.13.11.127
27.0.12.26
84.253.19.21
114.146.24.121
81.5.119.47
206.161.124.226
107.199.98.142
66.135.40.83
62.168.69.202
108.210.186.22
58.176.194.23
176.197.103.230
108.47.214.11
91.222.216.98
121.177.30.151
77.68.68.11
112.145.164.201
113.43.31.234
58.125.195.39
183.109.217.6
86.123.68.152
82.147.130.3
85.126.186.225
122.129.105.86
1.34.27.247
121.162.219.246
194.215.227.4
61.91.33.6
41.138.67.234
190.12.58.215
220.86.55.153
173.12.189.185
50.97.176.194
176.35.211.172
58.126.74.60
220.124.55.112
182.129.150.70
14.199.144.36
80.255.150.14
46.164.150.230
59.48.71.206
64.83.236.42
124.10.221.74
196.15.192.81
175.213.16.111
41.138.67.254
203.236.232.23
112.165.85.206
60.250.141.28
123.203.31.102
82.153.92.178
203.45.8.226
204.13.112.79
41.162.9.37
76.79.201.2
203.172.141.52
60.249.10.15
173.167.136.146
91.234.103.91
58.176.194.180
12.172.9.45
177.220.147.10
193.253.219.216
219.86.166.31
41.228.66.65
123.100.73.185
119.246.203.19
121.119.192.157
58.177.100.10
222.139.153.250
68.170.213.27
95.84.141.83
213.165.176.156
14.41.107.22
122.128.173.118
202.58.240.51
123.203.108.44
219.136.151.66
14.199.146.169
149.126.29.65
220.246.31.156
46.14.254.27
218.44.142.186
114.130.11.66
37.187.151.16
119.202.226.25
116.40.195.227
119.247.127.217
203.140.150.48
220.9.132.39
5.40.118.195
203.35.8.162
74.95.14.33
14.33.106.160
211.144.32.87
121.136.176.157
180.189.65.213
112.117.220.164
121.161.115.180
212.14.63.230
121.181.219.7
202.63.64.57
208.67.222.222
119.246.88.148
212.58.12.245
193.200.173.126
93.159.189.105
125.139.238.45
212.17.86.49
188.32.182.75
218.21.248.226
80.78.68.203
61.63.47.68
91.148.117.243
175.195.6.225
118.218.221.157
64.71.17.162
14.198.146.45
202.212.162.155
175.199.75.204
58.253.87.45
80.254.174.205
125.214.202.67
121.164.119.30
41.138.68.28
60.32.100.122
188.95.72.193
165.228.233.175
85.204.57.156
203.71.9.14
111.113.6.138
212.25.44.52
188.162.32.146
212.194.169.94
220.87.131.217
68.67.68.83
210.201.108.159
124.244.8.35
59.148.128.221
61.238.7.24
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

proxy = None # None - SYSTEM PROXY, [PROTOCOL, SERVER, PORT]
orig_socket = socket.socket
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
    socket.socket = orig_socket
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
            sock.send(bytes("GET / HTTP/1.1\r\n\r\n", "utf-8"))
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

import win32gui, ctypes
# from win32con
WM_SETTEXT = 12
WM_GETTEXT = 13
WM_GETTEXTLENGTH = 14
hgui = None

def ctrl_exists(h):
    try: return win32gui.GetParent(h)
    except: return 0

def setvar(vname, v=''):
    global hgui
    vname = str(vname)
    v = str(v)
    buf_size = win32gui.SendMessage(hgui, WM_GETTEXTLENGTH, 0, 0) + 1
    buf = ctypes.create_unicode_buffer(buf_size)
    win32gui.SendMessage(hgui, WM_GETTEXT, buf_size, buf) # 获取buffer
    lines = buf[:-1].split('\r\n')
    added = 0
    for i in range(len(lines)):
        if lines[i].startswith('%s=' % vname):
            lines[i] = '%s=%s' % (vname, v)
            added = 1
            break
    if not added:
        lines.append('%s=%s' % (vname, v))
    text = '\r\n'.join(lines)
    win32gui.SendMessage(hgui, WM_SETTEXT, None, text)

def getvar(vname):
    global hgui
    buf_size = win32gui.SendMessage(hgui, WM_GETTEXTLENGTH, 0, 0) + 1
    buf = ctypes.create_unicode_buffer(buf_size)
    win32gui.SendMessage(hgui, WM_GETTEXT, buf_size, buf) # 获取buffer
    lines = buf[:-1].split('\r\n')
    for line in lines:
        if line.startswith('%s=' % vname):
            return line[len(vname)+1:]

def send_timestr(): # send time string to tell main thread:"I'm alive".
    global resp_timer
    setvar("ResponseTimer", time.strftime('%Y/%m/%d %H:%M:%S', time.localtime()))
    resp_timer = threading.Timer(3, send_timestr)
    resp_timer.start()

def set_proxy(prx=None):
    global orig_socket

    if not prx:
        socket.socket = orig_socket
        #socks.set_default_proxy()
        #socket.socket = socks.socksocket
        proxy_support = urllib.request.ProxyHandler(None)
        opener = urllib.request.build_opener(proxy_support)
        urllib.request.install_opener(opener)

    elif len(prx) >= 3:
        p_type = prx[0].upper()
        if p_type.startswith('SOCKS'):
            if p_type == 'SOCKS4':
                p_type = socks.SOCKS4
            else: # p_type == 'SOCKS5'
                p_type = socks.SOCKS5
            socks.set_default_proxy(p_type, prx[1], int(prx[2]))
            socket.socket = socks.socksocket # 必须在urllib之前执行
        else: # p_type == 'HTTP'
            p_server = prx[1].lower()
            if p_server == 'google.com':
                setvar("DLInfo", u"|||||查找 Google 可用 IP ...")
                p_server = get_google_ip()
                if not p_server:
                    setvar('DLInfo', u'||1||1|找不到可用的 Google IP')
                    return False
            p = {'http': '%s:%d' % (p_server, int(prx[2])), 'https': '%s:%d' % (p_server, int(prx[2]))}
            proxy_support = urllib.request.ProxyHandler(p)
            opener = urllib.request.build_opener(proxy_support)
            urllib.request.install_opener(opener)

    return True

GIP = []
def check_google_ip(ip):
    global GIP
    tempsocks = socket.socket
    socket.socket = orig_socket
    isgoodip = False
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(3)
        sock.connect((ip, 80))
        sock.send(bytes("GET / HTTP/1.1\r\n\r\n", "utf-8"))
        data = sock.recv(1024)
        data = data.decode('utf-8', 'ignore')
        #print(data)
        if re.match('(?is)HTTP/\d+\.\d+ +[123]\d\d +.*Server: *gws', data):
            isgoodip = True
    except Exception as e:
        pass
    finally:
        if sock: sock.close()
    socket.socket = tempsocks
    with lock:
        if isgoodip:
            ip_is_enough = True
            GIP.remove(ip)
            GIP = [ip] + GIP
        else:
            GIP.remove(ip)

def valid_google_ip(ips):
    global GIP, ip_is_enough
    GIP = ips[:]
    q = set()
    with ThreadPoolExecutor(max_workers=5) as executor:
        for ip in ips:
            q.add(executor.submit(check_google_ip, ip))
        while thread_alive(q):
            time.sleep(0.1)
            if ip_is_enough:
                executor.shutdown()
                break
    return GIP

def get_google_ip():
    global ini_file, config, default_servers, inactive_servers, domains, google_com
    global ip_is_enough

    config.read(ini_file)
    if not config.has_section('IPLookup'):
        config['IPLookup'] = {'google_com':'', 'InactiveServers':'', 'MapHost':1, 'GIP':''}
        with open(ini_file, 'w') as f:
            config.write(f)

    ips = config.get('IPLookup', 'google_com') if config.has_option('IPLookup', 'google_com') else ''
    validip = []
    googleip = []
    if ips:
        googleip = ips.split('|')
        validip = valid_google_ip(googleip)
        if validip != googleip:
            config.set('IPLookup', 'google_com', '|'.join(ip for ip in validip))
            with open(ini_file, 'w') as f:
                config.write(f)

    if not len(validip):
        ips = config.get('IPLookup', 'GIP') if config.has_option('IPLookup', 'GIP') else ''
        if ips:
            googleip = ips.split('|')
            validip = valid_google_ip(googleip)
            if validip != googleip:
                config.set('IPLookup', 'GIP', '|'.join(ip for ip in validip))
                with open(ini_file, 'w') as f:
                    config.write(f)

##    if not len(validip):
##        # print('nslookup google ip ...')
##        s = config.get('IPLookup', 'InactiveServers') if config.has_option('IPLookup', 'InactiveServers') else ''
##        if s:
##            inactive_servers_0 = set(s.split('|'))
##            inactive_servers = set(s.split('|'))
##        else:
##            inactive_servers_0 = set()
##            inactive_servers = set()
##        servers = dns_servers - inactive_servers
##        if len(servers) < 20:
##            servers = set(random.sample(dns_servers, 40))
##        servers = servers|default_servers
##        for chance in range(2):
##            sdomains = random.sample(domains, 4)  ## pick domains randomly
##            q = set()
##            ip_is_enough = False
##            google_com = {}
##            with ThreadPoolExecutor(max_workers=10) as executor:
##                for domain in sdomains:
##                    for nameserver in servers:
##                        q.add(executor.submit(nslookup, domain, [nameserver]))
##
##                while thread_alive(q):
##                    time.sleep(0.1)
##                    if len(google_com):
##                        ip_is_enough = True
##                        #print('got a valid google ip, wait until all threads end ...')
##                        executor.shutdown()
##                        break
##            if ip_is_enough: break
##        if len(google_com):
##            validip = list(google_com.keys())
##            config.set('IPLookup', 'google_com', '|'.join(ip for ip in validip))
##            with open(ini_file, 'w') as f:
##                config.write(f)

##        if inactive_servers != inactive_servers_0:
##            config.set('IPLookup', 'InactiveServers', '|'.join(i for i in inactive_servers))
##            with open(ini_file, 'w') as f:
##                config.write(f)

    if not len(validip):
        validip = get_google_ip_ex()
        if len(validip):
            config.set('IPLookup', 'GIP', '|'.join(ip for ip in validip))
            with open(ini_file, 'w') as f:
                config.write(f)
                
    if len(validip):
        return validip[0]

def read_from_url(url, b=1024):
    global user_agent
    s = ''
    f = None
    try:
        req = urllib.request.Request(url, headers={'User-Agent':user_agent})
        f = urllib.request.urlopen(req, timeout=3)
        if f.status == 200:
            s = f.read(b).decode('utf-8', 'ignore')
    except:
        pass
    if f:
        f.close()
    return s

def get_google_ip_ex():
    sources = ['1', '2', '3', '4']
    gip_source = config.get('IPLookup', 'GIPSource') if config.has_option('IPLookup', 'GIPSource') else ''
    source = gip_source
    if not source in sources:
        source = sources[0]
    while 1:
        ips = []
        if source == '1':
            url = r'http://www.xiexingwen.com/google/tts.php?query=*'
            s = read_from_url(url, 1024)
            if s:
                m = re.search(r'(?is)var +hs\s*=\s*\[\s*([\d\." ,]+)\s*\]', s)
                if m:
                    s = m.group(1)
                    ips = re.findall(r'"(\d+\.\d+\.\d+\.\d+)"', s)

        elif source == '2':
            url = r'https://raw.githubusercontent.com/txthinking/google-hosts/master/hosts'
            s = read_from_url(url, 512)
            if s:
                ips = re.findall(r'(?im)^(\d+\.\d+\.\d+\.\d+) +.*\.google', s)
                ips = list(set(ips))

        elif source == '3':
            url = r'http://www.go2121.com/google/splus.php?query=*'
            s = read_from_url(url, 1024)
            if s:
                m = re.search(r'(?is)var +hs\s*=\s*\[\s*([\d\." ,]+)\s*\]', s)
                if m:
                    s = m.group(1)
                    ips = re.findall(r'"(\d+\.\d+\.\d+\.\d+)"', s)

        else:
            url = r'http://anotherhome.net/easygoagent/proxy.ini'
            s = read_from_url(url, 4*1024)
            if s:
                m = re.search(r'(?i)google_hk\s*=\s*([\d\.\|]+)', s)
                if m:
                    ips = m.group(1).split('|', 20)
        
        if len(ips):
            ips = valid_google_ip(ips)
            if len(ips):
                if source != gip_source:
                    config.set('IPLookup', 'GIPSource', source)
                    with open(ini_file, 'w') as f:
                        config.write(f)               
                break

        sources.remove(source)
        if not len(sources):
            break
        else:
            source = sources[0]
        
    if len(ips) > 20:
        ips = ips[:19]
    return ips


# DLInfo chrome version|chrome urls|complete|success|error|info
def get_latest_chrome_ver(plist=[]):
    global ini_file, proxy

    channel = 'stable'
    x86 = 0
    strproxy = ''
    try:
        channel = plist[0].lower()
        x86 = int(plist[1])
        ini_file = plist[2]
        strproxy = plist[3]
    except:
        pass

    if ':' in strproxy:
        proxy = strproxy.split(':')
    else:
        proxy = None
    if not set_proxy(proxy):
        return

    try:
        aReg = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE,
                              'SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion')
        os_arch = 'x64'
    except:
        os_arch = 'x86'

    latest_chrome = {}
    errinfo = ''
    if channel.startswith('chromium'):
        # https://storage.googleapis.com/chromium-browser-continuous/index.html?path=Win/
        # https://storage.googleapis.com/chromium-browser-continuous/index.html?path=Win_x64/
        host = 'http://storage.googleapis.com'
        if channel == 'chromium-continuous':
            if x86 or os_arch == 'x86':
                urlbase = 'chromium-browser-continuous/Win'
            else:
                urlbase = 'chromium-browser-continuous/Win_x64'
        else:
            urlbase = 'chromium-browser-snapshots/Win'
        for i in range(4):
            if i >= 2 and (not proxy or (len(proxy) >= 3 and proxy[1] != 'google.com')):
                host = 'https://storage.googleapis.com'
            setvar('DLInfo', u'|||||从服务器获取 Chromium 更新信息... 第 %d 次尝试' % (i+1))
            try:
                req = urllib.request.Request(host + '/' + urlbase + '/LAST_CHANGE')
                req.add_header('User-Agent', 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1) Chrome/41.0.2272.101')
                f = urllib.request.urlopen(req, timeout=5)
                s = f.read().decode('utf-8', 'ignore').strip()
                f.close()
                if s.isdigit():
                    latest_chrome = {
                        'channel': channel,
                        'version': s,
                        'urls': '%s/%s/%s/mini_installer.exe' % (host, urlbase, s),
                        'size': 0}
                    break
            except Exception as e:
                errinfo = str(e)
        if len(latest_chrome):
            setvar('DLInfo', u'%s|%s|1|1||已成功获取 Chromium 更新信息' % (latest_chrome['version'], latest_chrome['urls']))
        else:
            setvar('DLInfo', u'||1||1|%s' % errinfo)
        return

    # get latest chrome info according to omaha protocol v3
    # http://code.google.com/p/omaha/wiki/ServerProtocol
    win_ver = '6.1'
    win_sp = 'Service Pack 1'
    try:
        s = sys.getwindowsversion()
        win_ver = '%d.%d' % (s.major, s.minor)
        win_sp = s.service_pack
    except:
        pass

    dict_ap = {
        'stable_x86': '-multi-chrome',
        'stable': 'x64-stable-multi-chrome',
        'beta_x86': '1.1-beta',
        'beta': 'x64-beta-multi-chrome',
        'dev_x86': '2.0-dev',
        'dev': 'x64-dev-multi-chrome',
        'canary_x86': '',
        'canary': 'x64-canary'
        }
    if channel not in dict_ap:
        channel = 'stable'
    if channel == 'canary':
        appid = '4EA16AC7-FD5A-47C3-875B-DBF4A2008C20'
    else:
        appid = '4DC8B4CA-1BDA-483E-B5FA-D3C12E15B62D'
    s = ''
    if x86 or os_arch == 'x86' or win_ver < '6.1':
        os_arch = 'x86'
        s = '_x86'
    ap = dict_ap[channel + s]
    data = '<?xml version="1.0" encoding="UTF-8"?><request protocol="3.0" version="1.3.23.9" ismachine="0">'
    data += '<os platform="win" version="%s" sp="%s" arch="%s"/>' % (win_ver, win_sp, os_arch)
    data += '<app appid="{%s}" version="" nextversion="" ap="%s"><updatecheck/></app></request>' % (appid, ap)
    data = bytes(data, 'utf-8')
    #print(data)
    host = 'http://tools.google.com/service/update2'

    for i in range(4):
        if i >= 2 and (not proxy or (len(proxy) >= 3 and proxy[1] != 'google.com')):
            host = 'https://tools.google.com/service/update2'
        setvar('DLInfo', u'|||||从服务器获取 Chrome 更新信息... 第 %d 次尝试' % (i+1))
        try:
            req = urllib.request.Request(host, method='POST', data=data)
            req.add_header('Content-Type','application/x-www-form-urlencoded;charset=utf-8')
            req.add_header('User-Agent','Google Update/1.3.23.9;winhttp')
            f = urllib.request.urlopen(req, timeout=5)
            s = f.read().decode('utf-8', 'ignore')
            #print(s)
            f.close()
            m = re.search(r'(?i)<manifest +version="(.+?)".* name="(.+?)".* size="(\d+)"', s)
            if m:
                urls = re.findall(r'(?i)<url +codebase="(.+?)"', s)
                if len(urls):
                    latest_chrome = {
                        'channel': channel,
                        'version': m.group(1),
                        'urls': ' '.join([x + m.group(2) for x in urls]),
                        'size': int(m.group(3))}
                    break
        except Exception as e:
            errinfo = str(e)
            #print(errinfo)

    if len(latest_chrome):
        setvar('DLInfo', u'%s|%s|1|1||已成功获取 Chrome 更新信息' % (latest_chrome['version'], latest_chrome['urls']))
    else:
        setvar('DLInfo', u'||1||1|%s' % errinfo)


user_agent = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1) Chrome/41.0.2272.101'
# download_info [[start_pos, pointer, end_pos, complete, success], [...]]
download_info = []
# download_status [size, total_size, complete, success, error, info]
download_status = [0,0,'','','','']
def downloader(block_id, url, fobj, buffer=16384):
    global lock, user_agent, download_info, download_status

    chance = 0
    while chance < 3:
        chance += 1
        time.sleep(0.1)
        req = urllib.request.Request(url, headers={'User-Agent':user_agent})
        req.headers['Range'] = 'bytes=%d-%d' % (download_info[block_id][1], download_info[block_id][2])  # set HTTP Header(RANGE)
        try:
            response = urllib.request.urlopen(req, timeout=10)
        except:
            continue

        while True:
            try:
                block = response.read(buffer)
                if not block:
                    break
            except:
                break
            with lock:
                try:
                    fobj.seek(download_info[block_id][1])  # seek offset
                    fobj.write(block)
                    chance = 0
                except:
                    download_info[block_id][3] = 1  # complete
                    download_status[2] = 1
                    download_status[4] = 3
                    download_status[5] = u'无法保存已下载的数据'
                    return
                block_len = len(block)
                if block_len >= download_info[block_id][2] - download_info[block_id][1] + 1:
                    block_len = download_info[block_id][2] - download_info[block_id][1] + 1
                    download_info[block_id][4] = 1  # success
                download_info[block_id][1] += block_len
                download_status[0] += block_len  # downloaded_size
                if download_info[block_id][4]:
                    break

        if block_len >= download_info[block_id][2] - download_info[block_id][1] + 1:
            download_info[block_id][4] = 1  # success
        if download_info[block_id][4]:
            break
    if response: response.close()
    with lock:
        download_info[block_id][3] = 1  # complete

def download2file(url, save_file, threads=5, resume=False):
    global user_agent, download_info, download_status, lock

    buffer=16384
    if resume:
        download_status[2] = ''
        download_status[4] = ''
        download_status[5] = u'尝试断点续传 ...'
    else:
        download_status = [0,0,'','','','']
        # get file size
        total_size = 0
        for i in range(2):
            error = ''
            req = urllib.request.Request(url, headers={'User-Agent':user_agent})
            req.headers['Range'] = 'bytes=16-128'
            try:
                response = urllib.request.urlopen(req, timeout=5)
                if response.status == 200:  # 不支持断点续传，改单线程
                    total_size = int(response.getheader('Content-Length'))
                    threads = 1
                elif response.status == 206:
                    total_size = int(response.getheader('Content-Range').split('/')[1])
                else:
                    raise Exception(u'获取远程文件信息失败')
                if total_size: break
            except Exception as e:
                error = e
            finally:
                if response:
                    response.close()
        if not total_size:
            download_status[2] = 1
            download_status[4] = 1
            download_status[5] = error
            return
        download_status[1] = total_size

        # assign range for every thread
        # download_info [[start_pos, pointer, end_pos, complete, success], [...]]
        # download_status [size, total_size, complete, success, error, info]
        block_size = int(total_size / threads)
        download_info = []
        for i in range(threads-1):
            download_info.append([i*block_size, i*block_size, i*block_size+block_size-1, 0, 0])
        download_info.append([block_size*(threads-1), block_size * (threads-1), total_size-1, 0, 0])

    try:
        if resume:
            fobj = open(save_file, 'r+b')
        else:
            fobj = open(save_file, 'wb')
    except Exception as e:
        download_status[2] = 1
        download_status[4] = 2
        download_status[5] = u'无法保存文件 ' + e
        return

    t = []
    s = [time.time(), download_status[0]]
    q = [] # queue for download speed calculation
    for i in range(50):
        q.append(s)
    with ThreadPoolExecutor(max_workers=threads) as executor:
        for i in range(len(download_info)):
            if not download_info[i][4]:
                download_info[i][3] = 0
                t.append(executor.submit(downloader, i, url, fobj, buffer))

        while thread_alive(t):
            time.sleep(0.2)
            q.remove(q[0])
            q.append([time.time(), download_status[0]])
            pst = download_status[0]/download_status[1]*100
            speed = (q[-1][1]-q[0][1])/(q[-1][0]-q[0][0])/1024
            if download_status[1]/1024/1024 > 1:
                progress = u'下载进度：  %.1f %%  -  %.1f MB / %.1f MB  -  %.1f KB/s' % (
                    pst, download_status[0]/1024/1024, download_status[1]/1024/1024, speed)
            else:
                progress = u'下载进度：  %.1f %%  -  %.1f KB / %.1f KB  -  %.1f KB/s' % (
                    pst, download_status[0]/1024, download_status[1]/1024, speed)

            with lock:
                download_status[5] = progress

    download_status[2] = 1
    if download_status[0] < download_status[1]:
        download_status[4] = 10  # 未下载完整，可续传
        download_status[5] = u'文件未下载完整'
    elif download_successful():
        download_status[3] = 1 # Success
        download_status[4] = ''
        download_status[5] = u'文件下载完成'
    fobj.flush()
    fobj.close()
    return

def download_successful():
    global download_info
    if not len(download_info):
        return False
    for i in download_info:
        if not i[4]:
            return False
    return True


valid_urls = []
def test_url(url):
    global lock, valid_urls
    req = urllib.request.Request(url, headers={'User-Agent':user_agent})
    try:
        response = urllib.request.urlopen(req, timeout=5)
        if response.status == 200:
            with lock:
                valid_urls.append(url)
    except:
        pass


def download_chrome(plist=[]):
    # download_status [size, total_size, complete, success, error, info]
    global proxy, valid_urls, download_status, ini_file

    urls = ''
    localfile = ''
    version = ''
    threads = 3
    strproxy = ''
    try:
        urls = plist[0].split()
        localfile = plist[1]
        threads = int(plist[2])
        ini_file = plist[3]
        strproxy = plist[4]
    except:
        pass

    if ':' in strproxy:
        proxy = strproxy.split(':')
    else:
        proxy = None
    if not set_proxy(proxy):
        return

    valid_urls = []
    setvar('DLInfo', u'|||||尝试连接 url ...')
    for chance in range(2):
        t = []
        with ThreadPoolExecutor(max_workers=5) as executor:
            for url in urls:
                t.append(executor.submit(test_url, url))

            while thread_alive(t):
                time.sleep(1)
                if len(valid_urls):
                    executor.shutdown()

        if len(valid_urls):
            break
        if proxy and proxy[1] != 'google.com':
            break
        if not set_proxy():
            break


    if not len(valid_urls):
        setvar('DLInfo', u'||1||1|已获取的 url 无法连接')
        return

    end = False
    resume = False
    while not end:
        with ThreadPoolExecutor(max_workers=1) as executor:
            t = executor.submit(download2file, valid_urls[0], localfile, threads, resume)

            while thread_alive([t]):
                time.sleep(1)
                with lock:
                    setvar('DLInfo', u'|'.join([str(x) for x in download_status]))

        if download_status[4] != 10:
            break
        while True:
            time.sleep(0.1)
            rsm = getvar('ResumeDownload')
            if rsm == '1':
                resume = True
                setvar('ResumeDownload', 0)
                break
            if not ctrl_exists(hgui):
                end = True
                break


def main():
    global ini_file, ip_is_enough, tested_ips, good_ips, default_servers
    global max_threads, check_inifile
    global hgui

    default_servers = set(get_dnsserver_list())
    if len(sys.argv) == 2: # check ini_file
        ini_file = sys.argv[1]
        if os.path.isfile(ini_file):
            check_inifile = True
            checkini(max_threads)
    elif len(sys.argv) >= 4 and sys.argv[1] == 'child_thread_by':
        # child thread to run a function:
        # child_thread_by 0xhwnd function arg1 arg2 ...
        hgui = win32gui.FindWindowEx(int(sys.argv[2], 16), None, 'Edit', None)
        #print(int(sys.argv[2], win32gui.GetParent(hgui), hgui)
        ini_file = 'Mychrome.ini'
        func = globals()[sys.argv[3]]
        v = None
        if len(sys.argv) > 4:
            v = sys.argv[4:]
        global resp_timer
        resp_timer = threading.Timer(3, send_timestr)
        resp_timer.start()
        #print(hgui, func, v)
        func(v) # start a func
        resp_timer.cancel()


if __name__ == "__main__":
    default_servers = set(get_dnsserver_list())
    if len(sys.argv) == 2: # check ini_file
        ini_file = sys.argv[1]
        if os.path.isfile(ini_file):
            check_inifile = True
            checkini(max_threads)
    elif len(sys.argv) >= 4 and sys.argv[1] == 'child_thread_by':
        # child thread to run a function:
        # child_thread_by 0xhwnd function arg1 arg2 ...
        hgui = win32gui.FindWindowEx(int(sys.argv[2], 16), None, 'Edit', None)
        #print(int(sys.argv[2], win32gui.GetParent(hgui), hgui)
        ini_file = 'Mychrome.ini'
        func = globals()[sys.argv[3]]
        v = None
        if len(sys.argv) > 4:
            v = sys.argv[4:]
        global resp_timer
        resp_timer = threading.Timer(3, send_timestr)
        resp_timer.start()
        #print(hgui, func, v)
        func(v) # start a func
        resp_timer.cancel()

    #input('press any key to quit')
