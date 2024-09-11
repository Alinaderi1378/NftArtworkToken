const Mycontract=artifacts.require("NftArtworkToken");
module.exports=function (deployer){
    deployer.deploy(Mycontract)
}
