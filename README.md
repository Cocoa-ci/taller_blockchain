# Taller Blockchain
Este repositorio contiene los scripts y demas archivos necesarios a ser utilizados durante el taller.

# SW necesario
Las siguientes instrucciones permiten instalar el software a utilizar para desplegar blockchains utilizando Hyperledger Fabric

* **tree**
* **git**
* **curl**
* **docker** 17.06.2-ce en adelante
* **docker-compose** 1.14 en adelante
* **go** 1.13 en adelante
* **Hyperledger Fabric** 2.0 en adelante

## Instalación de SW básico

**tree**

    sudo apt install tree -y

**git**

    sudo apt install git -y

**curl**
    
    sudo apt install curl -y

## Docker

Instalar requerimientos para agregar un repositorio usanto HTTPS

    sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

Agregar la llave GPG del repositorio oficial

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

Agregar el repositorio

    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

Actualizar la base de datos local de repositorios

    sudo apt update -y

Instalar la última versión de los binarios necesarios

    sudo apt install docker-ce docker-ce-cli containerd.io -y


**docker-compose**

    sudo apt install docker-compose -y

**Alistando Docker**

    sudo groupadd docker
    sudo usermod -aG docker ${USER}
    su - ${USER}

**Probar Docker**

    docker ps -a

## Go

Actualizar la base de datos local de repositorios

    sudo apt update -y

Descargar la versión adecuada (1.13.15 en este caso)

    curl -O https://dl.google.com/go/go1.13.15.linux-amd64.tar.gz

Descomprimir el el contenido del archivo. Se creará el directorio *go/*

    tar -xzvf go1.13.15.linux-amd64.tar.gz

Mover el directorio *go/* a un directorio del sistema (*/usr/local/* en este caso)

    sudo mv go /usr/local/

Abrir archivo ~./profile
    
    gedit ~./profile
    
Agregar el siguiente contenido

    export PATH=$PATH:/usr/local/go/bin

Probar Go

    go version
    
## Hyperledger Fabric

Descargar la última versión de Hyperdedger Fabric en el directorio donde se quiera instalar. Este comando crea el directorio *fabric-samples/*

    curl -sSL https://bit.ly/2ysbOFE | bash -s
    
## Pruebas finales
Si todo ha ido bien, podremos verificar que las imagenes de Hyperledger Fabric están descargadas

    docker images
