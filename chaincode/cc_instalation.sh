######### Preparación
# Hacer copia de carpeta chaincode/fabcar/go
# Eliminar fabcar 
# Eliminar .sum

# Preparar variables necesarias
export CHANNEL_NAME=channel1
export CHAINCODE_NAME=fabcar
export CHAINCODE_VERSION=1
export CC_RUNTIME_LANGUAGE=golang
export CC_SRC_PATH="../../fabric-samples/chaincode/$CHAINCODE_NAME/go"
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ciencia.edu/orderers/orderer.ciencia.edu/msp/tlscacerts/tlsca.ciencia.edu-cert.pem

######### Paso 1 - Empaquetar el chaincode
peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION} >&log.txt

######### Paso 2 - Instalar en los peers que quiera
### Instalar en el peer0 de la primera organizaciòn
peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz 

# Consultar si se instalo correctamente
peer lifecycle chaincode queryinstalled

# Installed chaincodes on peer:
# Package ID: mycc_1:87657bee804570d2050ea11897c915a8f4e58b55b44b581d70593542b4082c8b, Label: mycc_1
# Package ID: fabcar_1:632304e08c405194067d340681c0883304242271f6346c8cefe6de35c8f8cfc9, Label: fabcar_1
# Cambiar ID por el generado a cada uno

export CC_PACKAGEID=632304e08c405194067d340681c0883304242271f6346c8cefe6de35c8f8cfc9

# Peer 0 Org2
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/department2.university2.edu/users/Admin@department2.university2.edu/msp/
CORE_PEER_ADDRESS=peer0.department2.university2.edu:6051 
CORE_PEER_LOCALMSPID="Org2MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/department2.university2.edu/peers/peer0.department2.university2.edu/tls/ca.crt 
peer lifecycle chaincode install  ${CHAINCODE_NAME}.tar.gz

peer lifecycle chaincode queryinstalled

# Peer 0 Org3
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/department3.university3.edu/users/Admin@department3.university3.edu/msp/
CORE_PEER_ADDRESS=peer0.department3.university3.edu:7051 
CORE_PEER_LOCALMSPID="Org3MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/department3.university3.edu/peers/peer0.department3.university3.edu/tls/ca.crt
peer lifecycle chaincode install  ${CHAINCODE_NAME}.tar.gz

peer lifecycle chaincode queryinstalled

######### Paso 3 - Aprobar para las organizaciones

### Aprobar para Org 3
peer lifecycle chaincode approveformyorg --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --waitForEvent --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')" --package-id fabcar_1:$CC_PACKAGEID

peer lifecycle chaincode queryapproved --channelID channel1 --name fabcar

peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')" --output json

### Aprobar para Org 1
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/department1.university1.edu/users/Admin@department1.university1.edu/msp/
CORE_PEER_ADDRESS=peer0.department1.university1.edu:5051 
CORE_PEER_LOCALMSPID="Org1MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/department1.university1.edu/peers/peer0.department1.university1.edu/tls/ca.crt

peer lifecycle chaincode approveformyorg --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --waitForEvent --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')" --package-id fabcar_1:$CC_PACKAGEID

peer lifecycle chaincode queryapproved --channelID channel1 --name fabcar

peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')" --output json

######### Paso 4 - Commit 
# Una vez que se cumpla la politica de quienes han aprobado el chaincode, un peer puede hacer commit del chaincode
# Ver querycommitted para mycc
peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name mycc --output json

peer lifecycle chaincode commit -o orderer.ciencia.edu:7050 --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version $CHAINCODE_VERSION --sequence 1 --peerAddresses peer0.department1.university1.edu:5051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer0.department3.university3.edu:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/department3.university3.edu/peers/peer0.department3.university3.edu/tls/ca.crt --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')"

peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name fabcar --output json

############## FIN
