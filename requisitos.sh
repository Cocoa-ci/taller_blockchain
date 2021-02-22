#!/bin/bash

#
# Script automatizado
#
#Utils
echo "####################################################### "
echo "# INSTALANDO COMPONENTES BÁSICOS # "
echo "####################################################### "

#Tree
sudo apt install tree -y

# GIT
sudo apt install git -y

#CURL
sudo apt install curl -y

#DOCKER
echo "        ####################################################### "
echo "        #                   INSTALANDO DOCKER                 # "
echo "        ####################################################### "
# Instalar requerimientos para agregar un repositorio usanto HTTPS
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-commonsudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

# Agregar la llave GPG del repositorio oficial
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Agregar repositorio
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Actualizar la base de datos local de repositorios
sudo apt-get update -y

# Instalar la última versión de los binarios necesarios
sudo apt install docker-ce docker-ce-cli containerd.io -y

# Docker compose
sudo apt install docker-compose -y

#GO
echo "        ####################################################### "
echo "        #                   INSTALANDO GOLANG                 # "
echo "        ####################################################### "
sudo apt update -y
curl -O https://dl.google.com/go/go1.13.15.linux-amd64.tar.gz
tar -xzvf go1.13.15.linux-amd64.tar.gz
sudo mv go /usr/local
export PATH=$PATH:/usr/local/go/bin
echo "GOLANG version ..."
go version

#FABRIC
# Ejecuta el setup inicial de las maquinas , creación de directorios y descarga de imagenes de Hyperledger Fabric
echo "        ####################################################### "
echo "        #                   INSTALANDO HYPERLEDGER FABRIC     # "
echo "        ####################################################### "
curl -sSL http://bit.ly/2ysbOFE | bash -s

# Eclipse, Java y Maven deben instalarse en la maquina donde se hara el desarrollo de las API REST
# 
################################## FIN
