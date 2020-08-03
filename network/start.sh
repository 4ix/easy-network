#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -ev

# don't rewrite paths for Windows Git Bash users
function replacePrivateKey() {
    echo "ca key file exchange"
    cp docker-compose-template.yml docker-compose.yml
    PRIV1_KEY=$(ls crypto-config/peerOrganizations/org1.example.com/ca/ | grep _sk)
    sed -i "s/CA1_PRIVATE_KEY/${PRIV1_KEY}/g" docker-compose.yml
    PRIV2_KEY=$(ls crypto-config/peerOrganizations/org2.example.com/ca/ | grep _sk)
    sed -i "s/CA2_PRIVATE_KEY/${PRIV2_KEY}/g" docker-compose.yml
    PRIV3_KEY=$(ls crypto-config/peerOrganizations/org3.example.com/ca/ | grep _sk)
    sed -i "s/CA3_PRIVATE_KEY/${PRIV3_KEY}/g" docker-compose.yml
}

function checkPrereqs() {
    #check config dir
    if [ ! -d "crypto-config" ]; then
        echo "crypto-config dir missing"
        exit 1
    fi
    #check crypto-config dir
    if [ ! -d "config" ]; then
        echo "config dir missing"
        exit 1
    fi
}

checkPrereqs
replacePrivateKey

export MSYS_NO_PATHCONV=1

docker-compose -f docker-compose.yml down

docker-compose -f docker-compose.yml up -d ca.org1.example.com ca.org2.example.com ca.org3.example.com orderer.example.com couchdb1 couchdb2 couchdb3 peer0.org1.example.com peer0.org2.example.com peer0.org3.example.com cli
docker ps -a

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
docker exec cli peer channel create -o orderer.example.com:7050 -c mychannel -f /etc/hyperledger/configtx/channel.tx
# Join peer0.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b /etc/hyperledger/configtx/mychannel.block
sleep 3
# Join peer0.org2.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.example.com/msp" peer0.org2.example.com peer channel join -b /etc/hyperledger/configtx/mychannel.block
sleep 3
# Join peer0.org3.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org3.example.com/msp" peer0.org3.example.com peer channel join -b /etc/hyperledger/configtx/mychannel.block
sleep 3

#Anchor peer1
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel update -o orderer.example.com:7050 -c mychannel -f /etc/hyperledger/configtx/Org1MSPanchors.tx
sleep 3

#Anchor peer2
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.example.com/msp" peer0.org2.example.com peer channel update -o orderer.example.com:7050 -c mychannel -f /etc/hyperledger/configtx/Org2MSPanchors.tx
sleep 3

#Anchor peer3
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org3.example.com/msp" peer0.org3.example.com peer channel update -o orderer.example.com:7050 -c mychannel -f /etc/hyperledger/configtx/Org3MSPanchors.tx
sleep 3
