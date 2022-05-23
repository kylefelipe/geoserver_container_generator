#!/bin/bash

# Author: Kyle Felipe
# E-mail: kylefelipe at gmail.com
# data: 23/05/2022
# Ùltima atualização: 23/05/2022
# Script feito para criar um container com geoserver e com a pasta data em um
# local específico, a princípio é uma pasta data no diretório atual
# É intenção futura poder escolher via opções onde colocar a pasta data.
# Vide README

REPOLINK="https://github.com/kylefelipe/geoserver_container_generator"
version='0.1.0'
hostname="localhost"
container_name="meu-geoserver"
host_port="8600"
admin_password="geoserver"
admin_user="admin"
remove_data="n"
remove_container="n"
data_dir="$(pwd -P)"
geoserver_version="2.20.4"
container_link="https://hub.docker.com/r/kartoza/geoserver"

usage() {
    echo "Uso:  sudo create_postgis.sh [OPÇÃO]

    Essas opções possuem argumentos obrigatórios:

        [ -c | --container container name ]
        [ -D | --data-dir path to folder data to map to container ]
        [ -g | --gis-version string geoserver container version tag to use, link in the end of this help ]
        [ -p | --port geoserver port ]
        [ -P | --password geoserver admin password ]
        [ -U | --user geoserver admin user ]
    
    Essas opções abaixo não precisam de argumentos:

        [ --clear-data erases data folder ]
        [ --rm-container remove container before create ]
        [ --help exibe esse help ]
        [ --version informa a versão e sai ]"
    echo ""
    echo "Cheque as tags que podem ser utilizadas no Geoserver em <$container_link/tags>"
    echo "Página do repositório desse script: <$REPOLINK>"
    echo "Envie os erros e sugestões para <$REPOLINK/issues>"
    echo "Se foi útil, deixe uma estrelinha"
    echo "LLP _\\\\//"
    echo "<www.kylefelipe.com>"
    exit 2
}

version() {
    echo $version
    exit 2
}

PARSED_ARGUMENTS=$(getopt -a -n argument -o h:c:D:f:p:P:U:v: \
                    --long container-name:,data-dir:,hostname:,port:,password:,user:,clear-data,rm_container,help,version -- "$@")

VALID_ARGUMENTS=$?

if [ "$VALID_ARGUMENTS" != "0" ]; then
    usage
fi

eval set -- "$PARSED_ARGUMENTS"

while :
do
    case "$1" in
    -c | --container)
        container_name="$2"
        shift 2
    ;;
    -D | --data-dir)
        data_dir="$2"
        shift 2
    ;;
    -g | --gis-version)
        geoserver_version="$2"
        shift 2
    ;;
    -h | --hostname)
        hostname="$2"
        shift 2
    ;;
    -p | --port)
        host-port="$2"
        shift 2
    ;;
    -P | --password)
        password="$2"
        shift 2
    ;;
    -U | --user)
        admin_user="$2"
        shift 2
    ;;
    --clear-data)
        remove_data="s"
        shift
    ;;
    --rm-container)
        remove_container="s"
        shift
    ;;
    --help)
        usage
        shift 2
    ;;
    -v | --version)
        version
        shift 2
    ;;
    --)
        shift
        break
        ;;
    *)
        echo "Opção $1 não reconhecida."
        usage
        ;;
    esac
done

echo "  _\\\\//"
echo "Criando um container docker com geoserver usando imagem disponibilizada pela Kartoza"
echo "$container_link"
echo "Lá encontram-se mais informações sobre o container."
echo "De acordo com a documentação o container já possui cors configurado por padrão"

if [ "$remove_data" = "s" ] && [ -d "$data_dir/data_dir" ]; then
    echo "Removendo a pasta data."
    rm -rf "$data_dir/data_dir"
else
    echo "Pasta $data_dir/data_dir inexistente!"
fi

if [ "$remove_container" = "s" ]; then
    echo "Removendo container $container_name"
    docker container rm -f "$container_name"
fi

if [ ! -d "$data_dir/data_dir" ]; then
    echo "Criando a pasta /data_dir dentro do diretório $data_dir"
    mkdir -p "$data_dir/data_dir"
    echo "Pronto!"

fi

if [ -d "$data_dir/data_dir" ] && [ ! -w "$data_dir/data_dir" ] && [ ! -x "$data_dir/data_dir" ]; then
    echo "Usuário não tem permissão para alterar a pasta $data_dir/data_dir"
    echo "Considere executar como super usuário!"
    exit 1
fi


if [ "$VALID_ARGUMENTS" = "0" ]
then
    existing_container="$(docker ps -q -f name=$container_name)"
    if [ -n "$existing_container" ] && [ "$remove_container" = "n" ]; then
        echo "Já existe um container com o nome $container_name."
        echo "Por favor, especifique um novo nome de container ou remova o já exstente"
        echo "ou use a opção --rm_container, para remover um container pré existente de mesmo nome"
        usage
    fi

    echo ""
    echo "Criando o container $container_name em modo daemon."
    echo ""
    echo "Imagem Geoserver utilizada: kartoza/geoserver:$geoserver_version"
    echo "$container_link"

    sudo docker run -d \
        --restart unless-stopped --name "$container_name" \
        -p 0.0.0.0:"$host_port":8080 \
        -e GEOSERVER_ADMIN_PASSWORD="$admin_password" \
        -e GEOSERVER_ADMIN_USER="$admin_user" \
        -v "$data_dir/data_dir":/opt/geoserver/data_dir \
        kartoza/geoserver:"$geoserver_version"
    
    echo ""
    if [ "$(docker ps -q -f name=$container_name -f status=running)"  == "" ]; then
        echo -n "Aguardando container iniciar"
        while [ "$(docker ps -q -f name=$container_name -f status=running)"  == "" ]; do
            echo -n "."
            sleep 1
        done
    fi

    sleep 10

    echo ""
    echo "Container criado com sucesso!"
    echo "Para acessar basta acessar:"
    echo "http://${hostname}:$host_port/geoserver"
    echo ""
    echo "Para parar o container:"
    echo "docker container stop $container_name"
    echo ""
    echo "Para iniciar o container (reutilizar):"
    echo "docker container start $container_name"
    echo "Para acessar o shell do container:"
    echo "docker container exec -it $container_name bash"
    echo ""
    echo "Be Happy!"
    echo "LLP _\\\\//"
    echo "Cheque as tags que podem ser utilizadas no Geoserver em <$container_link/tags>"
    echo "Página do repositório desse script: <$REPOLINK>"
    echo "Envie os erros e sugestões para <$REPOLINK/issues>"
    echo "Se foi útil, deixe uma estrelinha"
    echo "LLP _\\\\//"
    echo "<www.kylefelipe.com>"
fi
