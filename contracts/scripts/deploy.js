const hre = require("hardhat");

async function main() {
  console.log("🚀 Starting ScrollVerse Smart Contract Deployment");
  console.log("=" .repeat(60));
  
  const [deployer] = await hre.ethers.getSigners();
  console.log("📍 Deploying contracts with account:", deployer.address);
  
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("💰 Account balance:", hre.ethers.formatEther(balance), "ETH");
  console.log("=" .repeat(60));
  
  // Deploy AssetRegistry
  console.log("\n📜 Deploying AssetRegistry...");
  const AssetRegistry = await hre.ethers.getContractFactory("AssetRegistry");
  const assetRegistry = await AssetRegistry.deploy();
  await assetRegistry.waitForDeployment();
  const assetRegistryAddress = await assetRegistry.getAddress();
  
  console.log("✅ AssetRegistry deployed to:", assetRegistryAddress);
  
  // Deploy DigitalTwinAsset
  console.log("\n🔗 Deploying DigitalTwinAsset...");
  const DigitalTwinAsset = await hre.ethers.getContractFactory("DigitalTwinAsset");
  const digitalTwinAsset = await DigitalTwinAsset.deploy();
  await digitalTwinAsset.waitForDeployment();
  const digitalTwinAddress = await digitalTwinAsset.getAddress();
  
  console.log("✅ DigitalTwinAsset deployed to:", digitalTwinAddress);
  
  // Generate deployment info
  const deploymentInfo = {
    network: hre.network.name,
    timestamp: new Date().toISOString(),
    deployer: deployer.address,
    contracts: {
      AssetRegistry: assetRegistryAddress,
      DigitalTwinAsset: digitalTwinAddress
    },
    blockNumber: await hre.ethers.provider.getBlockNumber(),
    chainId: (await hre.ethers.provider.getNetwork()).chainId.toString()
  };
  
  console.log("\n" + "=" .repeat(60));
  console.log("📋 Deployment Summary:");
  console.log("=" .repeat(60));
  console.log(JSON.stringify(deploymentInfo, null, 2));
  
  // Save deployment info
  const fs = require('fs');
  const path = require('path');
  
  const deploymentsDir = path.join(__dirname, '../deployments');
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir, { recursive: true });
  }
  
  const filename = `deployment-${hre.network.name}-${Date.now()}.json`;
  const filepath = path.join(deploymentsDir, filename);
  
  fs.writeFileSync(filepath, JSON.stringify(deploymentInfo, null, 2));
  console.log(`\n💾 Deployment info saved to: ${filepath}`);
  
  // Verify contracts (if not on localhost)
  if (hre.network.name !== "localhost" && hre.network.name !== "hardhat") {
    console.log("\n🔍 Waiting for block confirmations before verification...");
    await assetRegistry.deploymentTransaction().wait(6);
    await digitalTwinAsset.deploymentTransaction().wait(6);
    
    console.log("\n🔐 Verifying contracts on block explorer...");
    
    try {
      await hre.run("verify:verify", {
        address: assetRegistryAddress,
        constructorArguments: [],
      });
      console.log("✅ AssetRegistry verified");
    } catch (error) {
      console.log("⚠️  AssetRegistry verification failed:", error.message);
    }
    
    try {
      await hre.run("verify:verify", {
        address: digitalTwinAddress,
        constructorArguments: [],
      });
      console.log("✅ DigitalTwinAsset verified");
    } catch (error) {
      console.log("⚠️  DigitalTwinAsset verification failed:", error.message);
    }
  }
  
  console.log("\n" + "=" .repeat(60));
  console.log("🎉 Deployment completed successfully!");
  console.log("=" .repeat(60));
  console.log("\n📖 Next steps:");
  console.log("1. Save the contract addresses");
  console.log("2. Update frontend configuration");
  console.log("3. Test contract interactions");
  console.log("4. Begin asset registration");
  console.log("\n🔒 BARAKALLAHU FEEK. Contracts deployed under VaultBook XL.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
