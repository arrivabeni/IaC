# Registro automatizado no DNS (Route53)
Script para registro automático na inicialização de instância EC2 na AWS com Linux AWS AMI 2 para registro no DNS (Route53).

## Instalação
- Crie um usuário:
    
    Para execução será necessário criar um usuário na AWS.

    - Crie uma política conforme o JSON abaixo (substitua os IDs das zonas Route53 "XXXXXX" e "YYYYYY" ):

    ```
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "route53:GetHostedZone",
                "route53:ChangeResourceRecordSets",
                "route53:ListResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/XXXXXX",
                "arn:aws:route53:::hostedzone/YYYYYY"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "route53:ListHostedZones",
            "Resource": "*"
        }
    ]
    }
    ```

    - Associe esta política à um grupo, por exemplo "Route53_AutoRegister_DNS".

    - Crie um usuário e associe-o ao grupo recém criado e ao grupo "AmazonEC2ReadOnlyAccess".

    - Gere a chave de acesso do usuário para utilizar no script.


- Insira o JSON com os dados no "User Data" da instância EC2:

    - ```name```: o nome DNS.
    - ```suffix```: o domínio (deve coincidir com o domínio da zona).
    - ```zone```: ID da zona do primeiro domínio.
    - ```i```: ID da chave de acesso da AWS.
    - ```i```: Chave de acesso AWS.
    - ```i```: Região da AWS.
```
{
	"dns": [{
		"name": "host01",
		"suffix": ".mydomain.com",
		"zone": "XPTO12345"
	}, {
		"name": "host02",
		"suffix": ".mydomain.com.br",
		"zone": "XPTO12345A"
	}],
	"i": "XXXXXXXXXXXXXXXX",
	"k": "yyyyyyyyyyyyyyyyyyyy",
	"r": "us-east-2"
}
```

- Rode o script de instalação:
```
wget https://raw.githubusercontent.com/arrivabeni/IaC/master/AWS/EC2/ROUTE53_DNS_Auto_Register/install.sh
sudo chmod +x install.sh
sudo ./install.sh
```

- Pronto, ao reinializar a instância ela se auto registrará no Route53.