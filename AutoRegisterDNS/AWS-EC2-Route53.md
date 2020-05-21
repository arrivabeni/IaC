# Registro automatizado no DNS (Route53)
Script para registro automático na inicialização de instância EC2 na AWS com Linux AWS AMI 2 para registro no DNS (Route53).

## Instalação
Alguns passos são omitidos, pois suponho que a pessoa que executará estes passos já utiliza AWS.

1. Criação do usuário:
    
    Para execução será necessário criar um usuário na AWS.

    a. Crie uma política conforme o JSON abaixo (substitua os IDs das zonas Route53 "XXXXXX" e "YYYYYY" ):
    **Importante**: *Lembre-se de adicionar todas as zonas que serão registradas com o script*

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

    b. Associe esta política à um grupo, por exemplo "Route53_AutoRegister_DNS".

    c. Crie um usuário e associe-o ao grupo recém criado e ao grupo "AmazonEC2ReadOnlyAccess".

    d. Gere a chave de acesso do usuário para utilizar no script.

2. Insira o JSON com os dados no "User Data" da instância EC2:

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

3. Rode o script de instalação:
```
wget https://raw.githubusercontent.com/arrivabeni/InfrastructureTips/master/AutoRegisterDNS/auto-register-dns-install.sh
sudo chmod +x auto-register-dns-install.sh
sudo ./auto-register-dns-install.sh
```

4. Pronto, ao reinializar a instância ela se auto registrará no Route53.