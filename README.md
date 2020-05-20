# IaC
Scripts for Infrastructure as Code (Or other automations)




### Usando S3 para redirecionar tráfego

Supondo que se quer redirecionar as chamadas do endereço ```origin.domain.com``` para ```destination.domain.com.br```.

- Crie um S3 com o nome ```origin.domain.com```;

- Em *propriedades* do bucket habilite a *Hospedagem de site estático* e defina o redirecionamento para ```destination.domain.com.br```;

- No Route53 crie uma entrada ```origin``` do tipo ```A``` para o Alias do bucket criado acima.