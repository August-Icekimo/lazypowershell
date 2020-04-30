
#!/bin/sh
acmePath="/home/icekimo/.acme.sh"
certFQDN="jenkins.icekimo.idv.tw"
service nginx stop
echo " Nginx Stoped, now update ssl cert: $certFQDN"
$acmePath/acme.sh --config-home /etc/acme --force --debug --issue --standalone  -d $certFQDN
service nginx start
echo "Done."