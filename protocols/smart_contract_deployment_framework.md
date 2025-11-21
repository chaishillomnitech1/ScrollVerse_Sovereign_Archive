# Smart Contract Deployment Framework

**بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ**

## I. Framework Overview

The Smart Contract Deployment Framework provides the foundational infrastructure for deploying, managing, and maintaining smart contracts that ensure traceability, authenticity, and perpetual reinvestment through the Zakat Stream mechanism.

## II. Core Smart Contracts

### A. AssetRegistry.sol

**Purpose**: Immutable registration and tracking of sovereign assets

**Key Features**:
- Permanent asset registration with cryptographic verification
- Version control for asset updates
- IPFS integration for distributed storage
- Zakat Stream contribution mechanism
- Full traceability and authenticity verification

**Functions**:
- `registerAsset()`: Register new sovereign assets
- `addAssetVersion()`: Add new versions while maintaining history
- `contributeToZakatStream()`: Perpetual reinvestment contributions
- `verifyAssetAuthenticity()`: Cryptographic verification
- `getAsset()`: Retrieve asset details

### B. DigitalTwinAsset.sol

**Purpose**: Link digital NFTs with physical assets

**Key Features**:
- ERC-721 compliant NFT implementation
- Physical-digital asset synchronization
- Status tracking and validation
- Condition monitoring and reporting
- Zakat allocation per asset

**Functions**:
- `createDigitalTwin()`: Mint new digital twin NFT
- `updatePhysicalStatus()`: Sync physical asset condition
- `validatePhysicalAsset()`: Perform validation checks
- `allocateZakat()`: Allocate Zakat funds to specific assets
- `getValidationHistory()`: Retrieve validation history

## III. Zakat Stream Integration

### A. Perpetual Reinvestment Mechanism

The Zakat Stream represents a commitment to continuous reinvestment and value distribution:

```
Zakat Flow:
1. Contributors send funds to asset-specific streams
2. Funds accumulate in smart contract
3. Sovereign Command Oversight allocates funds
4. Distributions support ecosystem growth
5. Cycle continues perpetually
```

### B. Contribution Structure

```solidity
struct ZakatContribution {
    uint256 amount;           // Contribution amount in wei
    uint256 timestamp;        // Block timestamp
    address contributor;      // Contributor address
    string purpose;          // Contribution purpose/designation
}
```

### C. Allocation Guidelines

| Priority | Use Case | Allocation % |
|----------|----------|--------------|
| **1** | Archive Maintenance | 25% |
| **2** | Protocol Development | 25% |
| **3** | Community Building | 20% |
| **4** | Security Audits | 15% |
| **5** | Emergency Reserve | 15% |

## IV. Deployment Procedures

### A. Pre-Deployment Checklist

- [ ] Smart contract code reviewed and audited
- [ ] OpenZeppelin dependencies verified (v4.9.0+)
- [ ] Network configuration confirmed (FlameChain/Ethereum)
- [ ] Deployment wallet funded with gas
- [ ] Contract parameters prepared
- [ ] Multi-sig wallet configured (if applicable)

### B. Deployment Script Template

```javascript
// deploy.js
const { ethers } = require("hardhat");

async function main() {
    console.log("Deploying AssetRegistry...");
    
    const AssetRegistry = await ethers.getContractFactory("AssetRegistry");
    const assetRegistry = await AssetRegistry.deploy();
    await assetRegistry.deployed();
    
    console.log("AssetRegistry deployed to:", assetRegistry.address);
    
    console.log("Deploying DigitalTwinAsset...");
    
    const DigitalTwinAsset = await ethers.getContractFactory("DigitalTwinAsset");
    const digitalTwin = await DigitalTwinAsset.deploy();
    await digitalTwin.deployed();
    
    console.log("DigitalTwinAsset deployed to:", digitalTwin.address);
    
    // Log deployment info
    const deploymentInfo = {
        network: network.name,
        timestamp: new Date().toISOString(),
        contracts: {
            AssetRegistry: assetRegistry.address,
            DigitalTwinAsset: digitalTwin.address
        }
    };
    
    console.log("Deployment Info:", JSON.stringify(deploymentInfo, null, 2));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
```

### C. Hardhat Configuration

```javascript
// hardhat.config.js
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
    solidity: {
        version: "0.8.20",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
    networks: {
        flamechain: {
            url: process.env.FLAMECHAIN_RPC_URL,
            accounts: [process.env.DEPLOYER_PRIVATE_KEY],
            chainId: parseInt(process.env.FLAMECHAIN_CHAIN_ID)
        },
        ethereum: {
            url: process.env.ETHEREUM_RPC_URL,
            accounts: [process.env.DEPLOYER_PRIVATE_KEY],
            chainId: 1
        },
        sepolia: {
            url: process.env.SEPOLIA_RPC_URL,
            accounts: [process.env.DEPLOYER_PRIVATE_KEY],
            chainId: 11155111
        }
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY
    }
};
```

### D. Environment Variables Template

```bash
# .env.example
DEPLOYER_PRIVATE_KEY=your_private_key_here
FLAMECHAIN_RPC_URL=https://rpc.flamechain.network
FLAMECHAIN_CHAIN_ID=1337
ETHEREUM_RPC_URL=https://mainnet.infura.io/v3/your_project_id
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your_project_id
ETHERSCAN_API_KEY=your_etherscan_api_key
```

## V. Post-Deployment Verification

### A. Contract Verification Steps

1. **Verify on Block Explorer**:
```bash
npx hardhat verify --network flamechain DEPLOYED_CONTRACT_ADDRESS
```

2. **Test Core Functions**:
```javascript
// Test asset registration
await assetRegistry.registerAsset(
    "AST-001",
    "contentHash123",
    "QmIPFSCID",
    "SOVEREIGN_SUPREME",
    "ipfs://metadata"
);

// Verify registration
const asset = await assetRegistry.getAsset("AST-001");
console.log("Asset registered:", asset);
```

3. **Validate Zakat Stream**:
```javascript
// Contribute to Zakat Stream
await assetRegistry.contributeToZakatStream(
    "AST-001",
    "Initial contribution",
    { value: ethers.utils.parseEther("1.0") }
);

// Check contribution
const contributions = await assetRegistry.getZakatContributions("AST-001");
console.log("Contributions:", contributions);
```

### B. Security Verification

- [ ] Owner address confirmed
- [ ] Access controls tested
- [ ] Reentrancy protection verified
- [ ] Gas limits acceptable
- [ ] Events emitting correctly

## VI. Integration Guidelines

### A. Frontend Integration

```javascript
// web3-integration.js
import { ethers } from "ethers";
import AssetRegistryABI from "./abis/AssetRegistry.json";

async function connectToAssetRegistry() {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();
    
    const contractAddress = "DEPLOYED_CONTRACT_ADDRESS";
    const contract = new ethers.Contract(
        contractAddress,
        AssetRegistryABI,
        signer
    );
    
    return contract;
}

async function registerNewAsset(assetData) {
    const contract = await connectToAssetRegistry();
    const tx = await contract.registerAsset(
        assetData.assetId,
        assetData.contentHash,
        assetData.ipfsCid,
        assetData.certificationLevel,
        assetData.metadata
    );
    await tx.wait();
    console.log("Asset registered:", tx.hash);
}
```

### B. Backend Integration

```python
# web3_client.py
from web3 import Web3
import json

def connect_to_contract(contract_address, abi_path, rpc_url):
    w3 = Web3(Web3.HTTPProvider(rpc_url))
    
    with open(abi_path, 'r') as f:
        contract_abi = json.load(f)
    
    contract = w3.eth.contract(
        address=contract_address,
        abi=contract_abi
    )
    
    return w3, contract

def verify_asset_authenticity(contract, asset_id, content_hash):
    is_authentic = contract.functions.verifyAssetAuthenticity(
        asset_id,
        content_hash
    ).call()
    
    return is_authentic
```

## VII. Maintenance and Upgrades

### A. Upgrade Strategy

The contracts use the Ownable pattern for administrative functions. For upgradability:

1. **Proxy Pattern**: Deploy using OpenZeppelin's UUPS or Transparent Proxy
2. **Version Migration**: Deploy new version and migrate state
3. **Multi-Sig Control**: Use Gnosis Safe for critical operations

### B. Monitoring

```javascript
// monitoring.js
async function monitorContractEvents() {
    const contract = await connectToAssetRegistry();
    
    // Listen for AssetRegistered events
    contract.on("AssetRegistered", (assetId, contentHash, ipfsCid, registrar, timestamp) => {
        console.log("New asset registered:", {
            assetId,
            contentHash,
            registrar,
            timestamp: new Date(timestamp * 1000)
        });
        
        // Log to monitoring system
        logToMonitoring("AssetRegistered", { assetId, registrar });
    });
    
    // Listen for ZakatContributed events
    contract.on("ZakatContributed", (assetId, amount, contributor, timestamp) => {
        console.log("Zakat contribution:", {
            assetId,
            amount: ethers.utils.formatEther(amount),
            contributor,
            timestamp: new Date(timestamp * 1000)
        });
    });
}
```

## VIII. Best Practices

### A. Gas Optimization

- Batch operations when possible
- Use events instead of storage for historical data
- Optimize struct packing
- Minimize external calls

### B. Security

- Always use latest OpenZeppelin contracts
- Conduct regular security audits
- Implement emergency pause functionality
- Use multi-signature for critical operations
- Test thoroughly on testnets before mainnet

### C. Documentation

- Maintain comprehensive NatSpec comments
- Document all state changes
- Keep deployment records
- Version control ABIs

## IX. Dependencies

```json
{
  "dependencies": {
    "@openzeppelin/contracts": "^4.9.0",
    "@nomicfoundation/hardhat-toolbox": "^3.0.0",
    "hardhat": "^2.17.0",
    "ethers": "^6.7.0",
    "dotenv": "^16.3.0"
  }
}
```

## X. Support and Resources

- **Documentation**: See `/docs/smart-contracts/`
- **Examples**: See `/contracts/templates/`
- **Testing**: See `/test/contracts/`
- **Audits**: See `/audits/`

**BARAKALLAHU FEEK.** The Smart Contract Framework is deployed.
**وَالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ**
