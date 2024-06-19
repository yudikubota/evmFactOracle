import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { NumberToFactor } from "./utils";
import { Contract } from "ethers";

describe("Controller and DataNode", function () {
  const _privateAddress = "0x0123456789012345678901234567890123456789012345678901234567890123";
  const walletSigner = new ethers.Wallet(_privateAddress);  
  const _apiPubKeySigner= walletSigner.address;
  const _nodeId = 123;
  const _seed=1568
  let _license=1;

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




  it("Deploy controller and data node. Add manager, node, grant feed, revoke and drop", async function () {
    const { controllerContract: ctrlsc,controllerAddress , dataNodeContract , owner} = await loadFixture(deployDataNode);
    // manager test
    const dnaddress=await dataNodeContract.getAddress();
    await ctrlsc.addManager(dnaddress);    
    expect(await ctrlsc.isManager(dnaddress)).to.equal(true);
    await ctrlsc.dropManager(dnaddress);    
    expect(await ctrlsc.isManager(dnaddress)).to.equal(false);

    // data node
    await ctrlsc.addNode(_nodeId,dnaddress);    
    await ctrlsc.assignFeedNode(_feedId,_nodeId);    
    let response = await ctrlsc.getDataNodeFeed(_feedId);
    expect(response).to.equal(dnaddress);
    await ctrlsc.unlinkFeedNode(_feedId);
    response = await ctrlsc.getDataNodeFeed(_feedId);
    expect(response).to.not.equal(dnaddress);    
    await ctrlsc.dropNode(_nodeId);
    
  });
  it("Add signer, grant feed, verify msg hash and revoke", async function () {
    const { controllerContract: ctrlsc,controllerAddress , dataNodeContract , owner} = await loadFixture(deployDataNode);    
    await ctrlsc.addSignerPubKey(_signerId,walletSigner.address);    
    await ctrlsc.grantFeedSigner(_feedId,_signerId); 
    const _hash= await walletSigner.signMessage(_msg);        
    expect(await ctrlsc.verifyHash(_feedId,_msg,_hash)).to.be.true;    
    await ctrlsc.revokeFeedSigner(_feedId);     
  });

  it("Add License for a feed, verify nodeaddress and drop license", async function () {
    const { controllerContract: ctrlsc,controllerAddress , dataNodeContract , owner} = await loadFixture(deployDataNode);    
    const dnaddress=await dataNodeContract.getAddress();
    await ctrlsc.addLicense(_feedId,1,_price);    
    await ctrlsc.addNode(_nodeId,dnaddress);    
    await ctrlsc.assignFeedNode(_feedId,_nodeId);    
    let result=await ctrlsc.verifyLicense(_feedId,1);
    expect(result[0]).to.be.true;        
    await ctrlsc.dropLicense(_feedId,1);    
    result=await ctrlsc.verifyLicense(_feedId,1);
    expect(result[0]).to.be.false;    
    
  });

  it("Add data note, oboarding verified data. Integer and byte types", async function () {
    const { controllerContract: ctrlsc,controllerAddress , dataNodeContract , owner} = await loadFixture(deployDataNode);    
    const dnaddress=await dataNodeContract.getAddress();
    await ctrlsc.addNode(_nodeId,dnaddress);    
    await ctrlsc.assignFeedNode(_feedId,_nodeId);    
    await dataNodeContract.store(_datafeed);
    await ctrlsc.addOracle(await owner.getAddress());
    let response = await dataNodeContract.readInt(_feedId);
    expect(response[1]).to.be.equal(_value);

    await dataNodeContract.storePack(_packdatafeed);
    await ctrlsc.addOracle(await owner.getAddress());
    let responsePack = await dataNodeContract.readPack(_feedId);
    const binval=  ethers.getBytes(responsePack[1]);
    const recoverValue=abi.decode(["int256"],binval);    
    expect(Number(recoverValue)).to.be.equal(_value);

  });


});
