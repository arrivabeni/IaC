echo -e "\e[1;33m
===========================================================================================================
Preparando ambiente
===========================================================================================================\e[0m"
echo -e "\e[1;33mAtualiza pacotes no sistema...\e[0m"
sudo yum update -y

echo -e "\e[1;33mInstala e configura AWS CLI...\e[0m"
sudo yum install -y aws-cli

echo -e "\e[1;33mInstala interpretador JSON - JQ JSON Client...\e[0m"
sudo yum install -y jq

echo -e "\e[1;33m
===========================================================================================================
Cria script para auto registro DNS
===========================================================================================================\e[0m"
cat > auto-register-dns.sh << EOScript
#!/bin/bash
echo -e "\e[1;33m
===========================================================================================================
Configurando auto registro DNS
===========================================================================================================\e[0m"
echo -e "\e[1;33mUsuário logado:\e[0m"
whoami

echo -e "\e[1;33mObtém no user data da instância as variáveis...\e[0m"
DNS=\$(curl 'http://instance-data/latest/user-data' | jq -r '.dns')
SUFFIX=\$(curl 'http://instance-data/latest/user-data' | jq -r '.suffix')
SUFFIX_BR=\$(curl 'http://instance-data/latest/user-data' | jq -r '.suffix_br')
ZONE=\$(curl 'http://instance-data/latest/user-data' | jq -r '.zone')
ZONE_BR=\$(curl 'http://instance-data/latest/user-data' | jq -r '.zone_br')
AWS_ACCESS_KEY_ID=\$(curl 'http://instance-data/latest/user-data' | jq -r '.i')
AWS_SECRET_ACCESS_KEY=\$(curl 'http://instance-data/latest/user-data' | jq -r '.k')
AWS_DEFAULT_REGION=\$(curl 'http://instance-data/latest/user-data' | jq -r '.r')

echo -e "\e[1;33mObtém o IP público da instância...\e[0m"
IPV4=\$(curl http://instance-data/latest/meta-data/public-ipv4)
echo \$IPV4

echo -e "\e[1;33mRegistra DNS no Route53...\e[0m"

if [ "\$SUFFIX" != "" ]
then

echo -e "\e[1;33mRegistrando \$DNS\$SUFFIX...\e[0m"
cat > auto-register-dns << EOF
{
"Comment": "EC2 Auto Registro",
"Changes": [{
"Action": "UPSERT",
"ResourceRecordSet": {
"Name": "\$DNS\$SUFFIX",
"Type": "A",
"TTL": 60,
"ResourceRecords": [{
"Value": "\$IPV4"
}]}}]}
EOF
aws route53 change-resource-record-sets --hosted-zone-id \$ZONE --change-batch file://auto-register-dns
rm auto-register-dns

fi

if [ "\$SUFFIX_BR" != "" ]
then
echo -e "\e[1;33mRegistrando \$DNS\$SUFFIX_BR...\e[0m"
cat > auto-register-dns-br << EOF
{
"Comment": "EC2 Auto Registro",
"Changes": [{
"Action": "UPSERT",
"ResourceRecordSet": {
"Name": "\$DNS\$SUFFIX_BR",
"Type": "A",
"TTL": 60,
"ResourceRecords": [{
"Value": "\$IPV4"
}]}}]}
EOF
aws route53 change-resource-record-sets --hosted-zone-id \$ZONE_BR --change-batch file://auto-register-dns-br
rm auto-register-dns-br

fi

echo -e "\e[1;33mProcesso finalizado!\e[0m"
EOScript

echo -e "\e[1;33mConfigura script para execução no Startup...\e[0m"
sudo mkdir /etc/route53
sudo mv auto-register-dns.sh /etc/route53/auto-register-dns.sh
sudo chmod +x /etc/route53/auto-register-dns.sh

sudo cp /etc/rc.d/rc.local /etc/rc.d/rc.local.bkp
cp /etc/rc.d/rc.local rc.local

echo "/etc/route53/auto-register-dns.sh" >> rc.local

sudo mv rc.local /etc/rc.d/rc.local

sudo chmod u+x /etc/rc.d/rc.local
sudo systemctl start rc-local
sudo systemctl enable rc-local

echo -e "\e[1;33mProcesso finalizado!\e[0m"