#!/bin/bash


CYAN_BOLD=$'\033[1;36m'
PURPLE_BOLD=$'\033[1;35m'
GREEN_BOLD=$'\033[1;32m'
YELLOW_BOLD=$'\033[1;33m'
RED_BOLD=$'\033[1;31m'
BLUE_BOLD=$'\033[1;34m'
ORANGE_BOLD=$'\033[1;38;5;208m'
PINK_BOLD=$'\033[1;38;5;200m'
RESET_FORMAT=$'\033[0m'


echo
echo "${PURPLE_BOLD}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${PURPLE_BOLD}          Welcome to Cloud Wale Jija Ji's Cloud Lab           ${RESET_FORMAT}"
echo "${PURPLE_BOLD}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo


echo "${CYAN_BOLD}⚡ Initiating Prime Number Cloud Deployment...${RESET_FORMAT}"
echo

# User input with new colors
echo -e "${ORANGE_BOLD}✏️  Enter ZONE:${RESET_FORMAT} \c"
read ZONE
echo -e "${ORANGE_BOLD}✏️  Enter the Static IP:${RESET_FORMAT} \c"
read STATIC_IP

# Export and configure values
export ZONE
export STATIC_IP
export REGION="${ZONE%-*}"

gcloud config set compute/region "$REGION"
gcloud config set compute/zone "$ZONE"

# Configuration display
echo -e "\n${YELLOW_BOLD}⚙️  Configuration Set:${RESET_FORMAT}"
echo "${BLUE_BOLD}• Zone:${RESET_FORMAT} $ZONE"
echo "${BLUE_BOLD}• Region:${RESET_FORMAT} $REGION"
echo "${BLUE_BOLD}• Static IP:${RESET_FORMAT} $STATIC_IP"
echo

# Installation and setup
echo "${GREEN_BOLD}🔧 Setting up Python virtual environment...${RESET_FORMAT}"
sudo apt-get install -y virtualenv
python3 -m venv venv
source venv/bin/activate

# Backend setup
echo "${PINK_BOLD}🚀 Configuring Prime Calculation Backend...${RESET_FORMAT}"
cat > backend.sh <<'EOF'
#!/bin/bash
sudo chmod -R 777 /usr/local/sbin/
cat << PYTHON_SCRIPT > /usr/local/sbin/serveprimes.py
import http.server
def is_prime(a): return a!=1 and all(a % i for i in range(2,int(a**0.5)+1))
class myHandler(http.server.BaseHTTPRequestHandler):
  def do_GET(s):
    s.send_response(200)
    s.send_header("Content-type", "text/plain")
    s.end_headers()
    s.wfile.write(bytes(str(is_prime(int(s.path[1:]))).encode("utf-8")))
http.server.HTTPServer(("",80),myHandler).serve_forever()
PYTHON_SCRIPT
nohup python3 /usr/local/sbin/serveprimes.py >/dev/null 2>&1 &
EOF

gcloud compute instance-templates create primecalc \
--metadata-from-file startup-script=backend.sh \
--no-address --tags backend --machine-type=e2-medium

gcloud compute firewall-rules create http --network default --allow=tcp:80 \
--source-ranges 10.142.0.0/20 --target-tags backend

gcloud compute instance-groups managed create backend \
--size 3 \
--template primecalc \
--zone $ZONE

gcloud compute instance-groups managed set-autoscaling backend \
--target-cpu-utilization 0.8 --min-num-replicas 3 \
--max-num-replicas 10 --zone $ZONE

# Load balancer setup
echo "${PINK_BOLD}⚖️  Configuring Load Balancer...${RESET_FORMAT}"
gcloud compute health-checks create http ilb-health --request-path /2

gcloud compute backend-services create prime-service \
--load-balancing-scheme internal --region=$REGION \
--protocol tcp --health-checks ilb-health

gcloud compute backend-services add-backend prime-service \
--instance-group backend --instance-group-zone=$ZONE \
--region=$REGION

gcloud compute forwarding-rules create prime-lb \
--load-balancing-scheme internal \
--ports 80 --network default \
--region=$REGION --address $STATIC_IP \
--backend-service prime-service

# Frontend setup
echo "${PINK_BOLD}🖥️  Configuring Frontend Service...${RESET_FORMAT}"
cat > frontend.sh <<'EOF'
#!/bin/bash
sudo chmod -R 777 /usr/local/sbin/
cat << PYTHON_SCRIPT > /usr/local/sbin/getprimes.py
import urllib.request
from multiprocessing.dummy import Pool as ThreadPool
import http.server
PREFIX="http://10.128.10.10/" #HTTP Load Balancer
def get_url(number):
    return urllib.request.urlopen(PREFIX+str(number)).read()
class myHandler(http.server.BaseHTTPRequestHandler):
  def do_GET(s):
    s.send_response(200)
    s.send_header("Content-type", "text/html")
    s.end_headers()
    i = int(s.path[1:]) if (len(s.path)>1) else 1
    s.wfile.write("<html><body><table>".encode('utf-8'))
    pool = ThreadPool(10)
    results = pool.map(get_url,range(i,i+100))
    for x in range(0,100):
      if not (x % 10): s.wfile.write("<tr>".encode('utf-8'))
      if results[x]=="True":
        s.wfile.write("<td bgcolor='#00ff00'>".encode('utf-8'))
      else:
        s.wfile.write("<td bgcolor='#ff0000'>".encode('utf-8'))
      s.wfile.write(str(x+i).encode('utf-8')+"</td> ".encode('utf-8'))
      if not ((x+1) % 10): s.wfile.write("</tr>".encode('utf-8'))
    s.wfile.write("</table></body></html>".encode('utf-8'))
http.server.HTTPServer(("",80),myHandler).serve_forever()
PYTHON_SCRIPT
nohup python3 /usr/local/sbin/getprimes.py >/dev/null 2>&1 &
EOF

gcloud compute instances create frontend --zone=$ZONE \
--metadata-from-file startup-script=frontend.sh \
--tags frontend --machine-type=e2-standard-2

gcloud compute firewall-rules create http2 --network default --allow=tcp:80 \
--source-ranges 0.0.0.0/0 --target-tags frontend

echo
echo "${GREEN_BOLD}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_BOLD}          🎉 Now Subscribe to the channel!    ${RESET_FORMAT}"
echo "${GREEN_BOLD}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo -e "${YELLOW_BOLD}📺 Subscribe our Channel:${RESET_FORMAT} ${BLUE_BOLD}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo -e "${PURPLE_BOLD}📷 Follow on Instagram:${RESET_FORMAT} ${PINK_BOLD}https://www.instagram.com/@cloudwalejijaji/${RESET_FORMAT}"
echo
