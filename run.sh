#!/bin/bash

# Patch Config to enable Event Handler
# CFG_EVENT='/root/janus/etc/janus/janus.eventhandler.sampleevh.cfg'
# sed 's/enabled = no/enabled = yes/1' -i $CFG_EVENT
# echo 'backend = http://localhost:7777' >> $CFG_EVENT

CFG_JANUS='/usr/local/etc/janus/janus.jcfg'
sed 's/#token_auth = true/token_auth = true/1' -i $CFG_JANUS
sed 's/#daemonize = true/daemonize = true/1' -i $CFG_JANUS
sed 's/#log_to_file = "\/path\/to\/janus.log"/log_to_file = "\/var\/log\/janus"/1' -i $CFG_JANUS
sed 's/admin_secret = "janusoverlord"/admin_secret = "moshjserver"/1' -i $CFG_JANUS
sed 's/#server_name = "MyJanusInstance"/server_name = "wrtcmserv"/1' -i $CFG_JANUS
CFG_HTTPS='/usr/local/etc/janus/janus.transport.http.jcfg'
sed 's/base_path = "\/janus"/base_path = "\/wrtcmserv"/1' -i $CFG_HTTPS
sed 's/https = false/https = true/1' -i $CFG_HTTPS
sed 's/#secure_port = 8089/secure_port = 8089/1' -i $CFG_HTTPS
sed 's/admin_http = false/admin_http = true/1' -i $CFG_HTTPS
sed 's/#admin_port = 7088/admin_port = 7088/1' -i $CFG_HTTPS
sed 's/admin_https = false/admin_https = true/1' -i $CFG_HTTPS
sed 's/#admin_secure_port = 7889/admin_secure_port = 7089/1' -i $CFG_HTTPS
sed 's/#cert_pem = "\/path\/to\/cert.pem"/cert_pem = "\/usr\/local\/etc\/keys\/janus\/cert.pem"/1' -i $CFG_HTTPS
sed 's/#cert_key = "\/path\/to\/key.pem"/cert_key = "\/usr\/local\/etc\/keys\/janus\/key.pem"/1' -i $CFG_HTTPS

# Generate Certs
openssl req -x509 -newkey rsa:4086 \
  -subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=localhost" \
  -keyout "/usr/local/etc/keys/janus/key.pem" \
  -out "/usr/local/etc/keys/janus/cert.pem" \
  -days 3650 -nodes -sha256

# Start admin server
/usr/local/nvm/versions/node/v10.16.0/bin/node  /usr/local/etc/admin/src/index.js >> /var/log/janus &

# Start Janus Gateway in forever mode
CMD="janus --stun-server=stun.l.google.com:19302 -L /var/log/janus --rtp-port-range=10000-10200"

until $CMD
do
    :
done

tail -f /var/log/janus
