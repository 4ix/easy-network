#simple-network
## 2020-07-31(금)
0. export PATH (환경변수 설정)
/home/bstudent/.nvm/versions/node/v12.7.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/local/go/bin:/home/bstudent/fabric-samples/bin

1. 디렉토리 생성(~dev/simple-network)
network
contract
application

2. 파일 복사(~/fabric-samples/basic-network)
cp .env configtx.yaml crypto-config.yaml generate.sh docker-compose.yml start.sh teardown.sh ~/dev/simple-network/network/

3. 파일 수정
crypto-config.yaml
configtx.yaml
generate.sh

4. ./generate.sh 실행

5. docker-compose.yml
ca : keyfile 수정
peer 수정 (1,2,3)
couchdb 수정 (1,2,3)
cli 수정 (working_dir, volumes)

6. start.sh 수정

7. CA1, CA2, CA3 생성

8. generate시 생성되는 키값 docker-compose로 들어가는 함수 작성(start.sh)

9. Anchor1, Anchor2, Anchor3 생성

10. ./start.sh 실행 (끝!) 

## 2020-08-03(월)
1. 개발환경 설정
- 리눅스 우분투 18.04 LTS
- docker, curl, node.js, vsc 등등
- images:1.4.7(fabric-ca, peer, orderer, tools, couchdb)
- fabric-samples, fabric-bin(cryptogen configtxgen) → 환경변수 설정

2. 체인코드 작성
- sacc.go
- temate.go

3. 컴파일(go build)

4. 체인코드 설치 및 배포
- cc.sh
- cc_teamate.sh

5. 기존 docker-compose-template.yml의 cli의 volumes의 경로 수정 chiancode → contract