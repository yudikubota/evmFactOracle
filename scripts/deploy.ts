import { ethers } from "hardhat";


const _privateAddress = "0x0123456789012345678901234567890123456789012345678901234567890123";
  const walletSigner = new ethers.Wallet(_privateAddress);  
  const _apiPubKeySigner= walletSigner.address;

  const _nodeId = 123;
  const _seed=1568
  let _license=0;  //  1 openracle  2 subscription 3 pay per use

  const _feedId = 123;
  const _decimal = 8;
  const _price = 10864251000000000n; // Wei for U$30
  const _lastupdate = Math.floor(Date.now() / 1000);
  const _value = 0;
  const _msg = ethers.getBytes(ethers.solidityPackedKeccak256(["uint32","int256","uint256","uint16"],[_feedId, _value, _lastupdate,_seed]));  

  const abi=ethers.AbiCoder.defaultAbiCoder();
  //const _binvalue=abi.encode(["uint256","string"],[98,"teste"]);
  const _packvalue=abi.encode(["int256"],[_value]);
  const _packmsg = ethers.getBytes(ethers.solidityPackedKeccak256(["uint32","bytes","uint256","uint16"],[_feedId, _packvalue, _lastupdate,_seed]));
  
  const _signerId=100;  
  
  const _datafeed = {
    feedId: _feedId,
    signerId: _signerId,
    lastUpdate: _lastupdate,
    value: _value,
    decimal: _decimal,    
    msgHash: new Uint8Array(0),
  };

  const _packdatafeed = {
    feedId: _feedId,
    signerId: _signerId,
    lastUpdate: _lastupdate,
    value: _packvalue,
    decimal: _decimal,
    msgHash: new Uint8Array(0),
  };

  async function deployController() {    
    const [owner] = await ethers.getSigners();
    const factor = await ethers.getContractFactory("FOController", { signer: owner });
    const controllerContract = await factor.deploy(owner.address, _seed, _apiPubKeySigner);
    await controllerContract.deploymentTransaction;
    const controllerAddress = await controllerContract.getAddress();    
    console.log(`Controller deployed to: ${controllerAddress}`);
    return { controllerContract, controllerAddress };
  }
  
  async function deployDataNode(controllerContract: any, controllerAddress: any) {
    const [owner] = await ethers.getSigners();
    const factor = await ethers.getContractFactory("FODataNode", { signer: owner });
    const dataNodeContract = await factor.deploy(controllerAddress);
    await dataNodeContract.deploymentTransaction;
    console.log(`DataNode deployed to: ${await dataNodeContract.getAddress()}`);
    return { controllerContract, controllerAddress, dataNodeContract, owner };
  }
  
  async function deployOpenOracle(controllerContract: any, controllerAddress: any, dataNodeContract: any) {
    const license = 1;
    const [owner] = await ethers.getSigners();
    const factor = await ethers.getContractFactory("OpenOracle", { signer: owner });
    const OpenOracleContract = await factor.deploy(controllerAddress, license);
    await OpenOracleContract.deploymentTransaction;
    console.log(`OpenOracle deployed to: ${await OpenOracleContract.getAddress()}`);
    return { OpenOracleContract };
  }

  async function deploySubscriptionOracle(controllerContract: any, controllerAddress: any, dataNodeContract: any) {
    const license = 2;
    const [owner] = await ethers.getSigners();
    const factor = await ethers.getContractFactory("SubscriptionOracle", { signer: owner });
    const SubscriptionOracleContract = await factor.deploy(controllerAddress, license);
    await SubscriptionOracleContract.deploymentTransaction;
    console.log(`SubscriptionOracle deployed to: ${await SubscriptionOracleContract.getAddress()}`);
    return { SubscriptionOracleContract };
  }


  async function deployPayPerUseOracle(controllerContract: any, controllerAddress: any, dataNodeContract: any) {
    const license = 3;
    const [owner] = await ethers.getSigners();
    const factor = await ethers.getContractFactory("PayPerUseOracle", { signer: owner });
    const PayPerUseOracleContract = await factor.deploy(controllerAddress, license);
    await PayPerUseOracleContract.deploymentTransaction;
    console.log(`PayPerUseOracle deployed to: ${await PayPerUseOracleContract.getAddress()}`);
    return {  PayPerUseOracleContract };
  }
  
  async function warmupDataService(ctrlsc: any, dataNodeContract: any) {    
    const dnaddress =await  dataNodeContract.getAddress();
    await ctrlsc.addNode(_nodeId, dnaddress);    
    await ctrlsc.assignFeedNode(_feedId, _nodeId);    
    await ctrlsc.addLicense(_feedId, _license, _price);    
    await dataNodeContract.store(_datafeed);    
    await dataNodeContract.storePack(_packdatafeed);        
  }
  
  async function main() {
    const { controllerContract, controllerAddress } = await deployController();
    const { dataNodeContract, owner } = await deployDataNode(controllerContract, controllerAddress);
    const { OpenOracleContract } = await deployOpenOracle(controllerContract, controllerAddress, dataNodeContract);
    const { SubscriptionOracleContract } = await deploySubscriptionOracle(controllerContract, controllerAddress, dataNodeContract);
    const { PayPerUseOracleContract } = await deployPayPerUseOracle(controllerContract, controllerAddress, dataNodeContract);
    await controllerContract.addOracle(await OpenOracleContract.getAddress());
    await controllerContract.addOracle(await SubscriptionOracleContract.getAddress());
    await controllerContract.addOracle(await PayPerUseOracleContract.getAddress());
    await warmupDataService(controllerContract, dataNodeContract);
    console.log("Deployment and setup complete.");
  }
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  