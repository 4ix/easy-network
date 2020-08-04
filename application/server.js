//웹서버 모듈 포함
const express = require("express");
const app = express();
var bodyParser = require("body-parser");

//웹서버 설정
//0.1 fabric 연결정보 설정
const { FileSystemWallet, Gateway } = require("fabric-network");
const fs = require("fs");
const path = require("path");
const ccpPath = path.resolve(__dirname, "..", "network", "connection.json");
const ccpJSON = fs.readFileSync(ccpPath, "utf8");
const ccp = JSON.parse(ccpJSON);
//0.2 express 설정
const PORT = 8080;
const HOST = "0.0.0.0";

app.use(express.static(path.join(__dirname, "views")));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

//페이지라우팅
//1.1. index.html
app.get("/", (req, res) => {
  res.sendFile(__dirname + "/index.html");
});

//REST 라우팅
//2.1 mate 추가 arg: name /mate POST
app.post("/mate", async (req, res) => {
  //웹 클라이언트 요청에서 파라미터 가져오기
  const name = req.body.name;

  //인증서 가져오기
  const walletPath = path.join(process.cwd(), "wallet");
  const wallet = new FileSystemWallet(walletPath);
  console.log(`Wallet path: ${walletPath}`);

  const userExists = await wallet.exists("user1");
  if (!userExists) {
    console.log(
      'An identity for the user "user1" does not exist in the wallet'
    );
    console.log("Run the registerUser.js application before retrying");
    return;
  }

  //체인코드 수행
  const gateway = new Gateway();
  await gateway.connect(ccp, {
    wallet,
    identity: "user1",
    discovery: { enabled: false },
  });
  const network = await gateway.getNetwork("mychannel");
  const contract = network.getContract("teamate");
  await contract.submitTransaction("addUser", name);
  console.log("transaction1 has been submitted");
  await gateway.disconnect();

  //결과 반환 to 웹 클라이언트
  res.status(200).send("transaction1 has been submitted");
});

//2.2 mate 조회 arg: name /mate GET
app.get("/mate/:name", async (req, res) => {
  console.log(req.params.name);
  //웹 클라이언트 요청에서 파라미터 가져오기
  const name = req.params.name;

  //인증서 가져오기
  const walletPath = path.join(process.cwd(), "wallet");
  const wallet = new FileSystemWallet(walletPath);
  console.log(`Wallet path: ${walletPath}`);

  const userExists = await wallet.exists("user1");
  if (!userExists) {
    console.log(
      'An identity for the user "user1" does not exist in the wallet'
    );
    console.log("Run the registerUser.js application before retrying");
    return;
  }

  //체인코드 수행
  const gateway = new Gateway();
  await gateway.connect(ccp, {
    wallet,
    identity: "user1",
    discovery: { enabled: false },
  });
  const network = await gateway.getNetwork("mychannel");
  const contract = network.getContract("teamate");
  const result = await contract.submitTransaction("readRating", name);
  const myobj = JSON.parse(result);
  await gateway.disconnect();

  //결과 반환 to 웹 클라이언트
  res.status(200).json(myobj);
});

//2.3 mate project 추가 arg: name, project, score /score POST
app.post("/score", async (req, res) => {
  //웹 클라이언트 요청에서 파라미터 가져오기
  const name = req.body.name;
  const project = req.body.project;
  const score = req.body.score;

  //인증서 가져오기
  const walletPath = path.join(process.cwd(), "wallet");
  const wallet = new FileSystemWallet(walletPath);
  console.log(`Wallet path: ${walletPath}`);

  const userExists = await wallet.exists("user1");
  if (!userExists) {
    console.log(
      'An identity for the user "user1" does not exist in the wallet'
    );
    console.log("Run the registerUser.js application before retrying");
    return;
  }

  //체인코드 수행
  const gateway = new Gateway();
  await gateway.connect(ccp, {
    wallet,
    identity: "user1",
    discovery: { enabled: false },
  });
  const network = await gateway.getNetwork("mychannel");
  const contract = network.getContract("teamate");
  await contract.submitTransaction("addRating", name, project, score);
  console.log("transaction3 has been submitted");
  await gateway.disconnect();

  //결과 반환 to 웹 클라이언트
  res.status(200).send("transaction3 has been submitted");
});

//서버시작
app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
