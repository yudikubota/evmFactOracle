import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { NumberToFactor } from "./utils";
import { Contract } from "ethers";

describe("Open Oracle", function () {
  const _privateAddress = "0x0123456789012345678901234567890123456789012345678901234567890123";
  const walletSigner = new ethers.Wallet(_privateAddress);  
  const _apiPubKeySigner= walletSigner.address;

  const _nodeId = 123;
  const _seed=1568
  let _license=1;  // openracle

  const _feedId = 123;
  const _decimal = 8;
  const _price = 10864251000000000n; // Wei for U$30
  const _lastupdate = Math.floor(Date.now() / 1000);
  const _value = NumberToFactor(98, _decimal);
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
    const controllerAddress = await controllerContract.getAddress();    
    return { controllerContract, controllerAddress };
  }

  async function deployDataNode() {
    const { controllerContract, controllerAddress  } = await loadFixture(deployController);
    const [owner] = await ethers.getSigners();
    const factor = await ethers.getContractFactory("FODataNode", { signer: owner });
    const dataNodeContract = await factor.deploy(controllerAddress);
    return { controllerContract,controllerAddress , dataNodeContract , owner};
  }

  async function deployOpenOracle() {
    const { controllerContract, controllerAddress, dataNodeContract  } = await loadFixture(deployDataNode);
    const [owner] = await ethers.getSigners();
    const factor = await ethers.getContractFactory("OpenOracle", { signer: owner });
    const oracleContract = await factor.deploy(controllerAddress,_license);
    return {controllerContract,controllerAddress , dataNodeContract, oracleContract, owner };
  }




  async function WarmupDataService(ctrlsc:any,dataNodeContract:any, oracleContract:any) {    
    const dnaddress=await dataNodeContract.getAddress();
    await ctrlsc.addNode(_nodeId,dnaddress);    
    await ctrlsc.assignFeedNode(_feedId,_nodeId);    
    await ctrlsc.addLicense(_feedId,_license,_price);    
    await dataNodeContract.store(_datafeed);    
    await dataNodeContract.storePack(_packdatafeed);    
    await ctrlsc.addOracle(await oracleContract.getAddress());
  }

  it("Create data note, controller, license and onboard feed  ", async function () {    
    const { controllerContract: ctrlsc,controllerAddress , dataNodeContract, oracleContract, owner } = await loadFixture(deployOpenOracle);
    await WarmupDataService(ctrlsc ,dataNodeContract, oracleContract);
  });

  it("Try feed available and make requests for int and binary types.", async function () {
    
    const { controllerContract: ctrlsc,controllerAddress , dataNodeContract, oracleContract, owner } = await loadFixture(deployOpenOracle);
    await WarmupDataService(ctrlsc ,dataNodeContract, oracleContract);
    expect(await oracleContract.isFeedAvailable(_feedId)).to.be.true;    
    expect(await oracleContract.getValue(_feedId)).to.be.equal(_value);
    const response = await oracleContract.getFeed(_feedId);    
    expect(response[1]).to.be.equal(_value);

    expect(await oracleContract.isPackFeedAvailable(_feedId)).to.be.true;        
    const responsePack = await oracleContract.getPackFeed(_feedId);    
    const binval=  ethers.getBytes(responsePack[1]);
    const recoverValue=abi.decode(["int256"],binval);    
    expect(Number(recoverValue)).to.be.equal(_value);    
  });

  it("Check signature with verify int and pack values", async function () {    
    const { controllerContract: ctrlsc,controllerAddress , dataNodeContract, oracleContract, owner } = await loadFixture(deployOpenOracle);    
    await WarmupDataService(ctrlsc ,dataNodeContract, oracleContract);
    const _hash = await walletSigner.signMessage(_msg);

    const _datafeed = {
      feedId: _feedId,
      signerId: _signerId,
      lastUpdate: _lastupdate,
      value: _value,
      decimal: _decimal,
      msgHash: _hash,
    };

    const _packdatafeed = {
      feedId: _feedId,
      signerId: _signerId,
      lastUpdate: _lastupdate,
      value: _packvalue,
      decimal: _decimal,
      msgHash: _hash,
    };
    
    expect(await oracleContract.verify(_datafeed)).to.be.true;
    
    expect(await oracleContract.verifyPack(_packdatafeed)).to.be.true;
  });

  

});
