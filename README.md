# Gerador de container Geoserver

Esse script foi criado para gerar um container Docker com o [Geoserver](https://geoserver.org/)  
usando a imagem disponibilizada pela [Kartoza](https://kartoza.com/en/). O difierencial é que já vem com o cors definido por padrão para uso.  
E cria uma pasta no diretório corrente para receber os dados do geoserver.

As opções padrões do script são:

- Nome do container = meu-geoserver;  
- Porta do host = 8600;  
- Usuário Administrativo = admin;  
- Senha do Usuário Administrativo = geoserver;  
- Recria a pasta data_dir: não;  
- Remove o container caso exista: não;  
- Pasta data_dir será criada no diretório atual desse script;  

Esses padrões podem ser configurados conforme as opções que estarão no [help](README.md#help)

## Modo de uso

```shel
./create_geoserver.sh [opções]
```

É necessário rodar o script como super user para fazer algumas modificações.

## Help

As seguinte opções podem ser passadas:

- `--clear-data` > Remove a pasta data existente no diretório atual e cria uma nova.
- `--rm-container` > Remove o container de mesmo nome caso já exista.

> Essas opções anteriores não precisam de parâmetros.

- `-c | --container string` > Nome do container a ser criado.  
- `-D | --data-dir path` > Caminho para o diretório onde a pasta data_dir será criada (caso não exista) e mapeada para o contaner.  
- `-g | --gis-version string` > Tag da versão do container do geoserver a ser usada.  
- `-p | --port number` > Número da porta do host que irá receber a interna do banco.  
- `-P | --password string` > Senha do usuário Administrativo.  
- `-U | --user string` > Nome do usuário Administrativo.  

## Executando o arquivo de qualquer diretório

Basta adicionar um link na pasta usr/bin que estará disponível para rodar do terminal.
