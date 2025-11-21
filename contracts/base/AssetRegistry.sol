// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title AssetRegistry
 * @notice Base contract for registering and tracking sovereign assets in the ScrollVerse Archive
 * @dev Provides immutable asset registration with full traceability and authenticity verification
 * 
 * بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
 * ALLĀHU AKBAR! VaultBook XL::SmartContract Framework
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract AssetRegistry is Ownable, ReentrancyGuard {
    using ECDSA for bytes32;

    // Asset structure
    struct Asset {
        string assetId;
        string contentHash; // SHA-256 hash
        string ipfsCid; // IPFS Content Identifier
        uint256 registrationTime;
        uint256 blockNumber;
        address registrar;
        string certificationLevel;
        bool isActive;
        string metadata; // JSON metadata URI
    }

    // Zakat Stream contribution structure
    struct ZakatContribution {
        uint256 amount;
        uint256 timestamp;
        address contributor;
        string purpose;
    }

    // State variables
    mapping(string => Asset) public assets;
    mapping(string => string[]) public assetVersions; // assetId => version hashes
    mapping(string => ZakatContribution[]) public zakatStreams;
    
    string[] public registeredAssetIds;
    uint256 public totalZakatContributed;
    
    // Events
    event AssetRegistered(
        string indexed assetId,
        string contentHash,
        string ipfsCid,
        address indexed registrar,
        uint256 timestamp
    );
    
    event AssetVersionAdded(
        string indexed assetId,
        string newVersionHash,
        uint256 timestamp
    );
    
    event ZakatContributed(
        string indexed assetId,
        uint256 amount,
        address indexed contributor,
        uint256 timestamp
    );
    
    event AssetDeactivated(
        string indexed assetId,
        uint256 timestamp
    );

    /**
     * @notice Register a new sovereign asset
     * @param _assetId Unique identifier for the asset
     * @param _contentHash SHA-256 hash of asset content
     * @param _ipfsCid IPFS Content Identifier
     * @param _certificationLevel Certification level (e.g., "SOVEREIGN_SUPREME")
     * @param _metadata URI to JSON metadata
     */
    function registerAsset(
        string memory _assetId,
        string memory _contentHash,
        string memory _ipfsCid,
        string memory _certificationLevel,
        string memory _metadata
    ) external onlyOwner {
        require(bytes(assets[_assetId].assetId).length == 0, "Asset already registered");
        require(bytes(_assetId).length > 0, "Asset ID cannot be empty");
        require(bytes(_contentHash).length > 0, "Content hash cannot be empty");

        Asset memory newAsset = Asset({
            assetId: _assetId,
            contentHash: _contentHash,
            ipfsCid: _ipfsCid,
            registrationTime: block.timestamp,
            blockNumber: block.number,
            registrar: msg.sender,
            certificationLevel: _certificationLevel,
            isActive: true,
            metadata: _metadata
        });

        assets[_assetId] = newAsset;
        registeredAssetIds.push(_assetId);
        assetVersions[_assetId].push(_contentHash);

        emit AssetRegistered(_assetId, _contentHash, _ipfsCid, msg.sender, block.timestamp);
    }

    /**
     * @notice Add a new version to an existing asset
     * @param _assetId Asset identifier
     * @param _newContentHash Hash of the new version
     */
    function addAssetVersion(
        string memory _assetId,
        string memory _newContentHash
    ) external onlyOwner {
        require(bytes(assets[_assetId].assetId).length > 0, "Asset not registered");
        require(assets[_assetId].isActive, "Asset is not active");
        require(bytes(_newContentHash).length > 0, "Content hash cannot be empty");

        assetVersions[_assetId].push(_newContentHash);
        
        emit AssetVersionAdded(_assetId, _newContentHash, block.timestamp);
    }

    /**
     * @notice Contribute to the Zakat Stream for perpetual reinvestment
     * @param _assetId Asset identifier to associate contribution with
     * @param _purpose Description of the contribution purpose
     */
    function contributeToZakatStream(
        string memory _assetId,
        string memory _purpose
    ) external payable nonReentrant {
        require(msg.value > 0, "Contribution must be greater than 0");
        require(bytes(assets[_assetId].assetId).length > 0, "Asset not registered");

        ZakatContribution memory contribution = ZakatContribution({
            amount: msg.value,
            timestamp: block.timestamp,
            contributor: msg.sender,
            purpose: _purpose
        });

        zakatStreams[_assetId].push(contribution);
        totalZakatContributed += msg.value;

        emit ZakatContributed(_assetId, msg.value, msg.sender, block.timestamp);
    }

    /**
     * @notice Get asset details by ID
     * @param _assetId Asset identifier
     * @return Asset structure
     */
    function getAsset(string memory _assetId) external view returns (Asset memory) {
        require(bytes(assets[_assetId].assetId).length > 0, "Asset not registered");
        return assets[_assetId];
    }

    /**
     * @notice Get all version hashes for an asset
     * @param _assetId Asset identifier
     * @return Array of version hashes
     */
    function getAssetVersions(string memory _assetId) external view returns (string[] memory) {
        return assetVersions[_assetId];
    }

    /**
     * @notice Get Zakat contributions for an asset
     * @param _assetId Asset identifier
     * @return Array of Zakat contributions
     */
    function getZakatContributions(string memory _assetId) external view returns (ZakatContribution[] memory) {
        return zakatStreams[_assetId];
    }

    /**
     * @notice Get total number of registered assets
     * @return Total count
     */
    function getTotalAssets() external view returns (uint256) {
        return registeredAssetIds.length;
    }

    /**
     * @notice Deactivate an asset (does not delete, maintains immutability)
     * @param _assetId Asset identifier
     */
    function deactivateAsset(string memory _assetId) external onlyOwner {
        require(bytes(assets[_assetId].assetId).length > 0, "Asset not registered");
        require(assets[_assetId].isActive, "Asset already deactivated");

        assets[_assetId].isActive = false;

        emit AssetDeactivated(_assetId, block.timestamp);
    }

    /**
     * @notice Verify asset authenticity using content hash
     * @param _assetId Asset identifier
     * @param _contentHash Hash to verify
     * @return True if hash matches any version
     */
    function verifyAssetAuthenticity(
        string memory _assetId,
        string memory _contentHash
    ) external view returns (bool) {
        string[] memory versions = assetVersions[_assetId];
        for (uint256 i = 0; i < versions.length; i++) {
            if (keccak256(abi.encodePacked(versions[i])) == keccak256(abi.encodePacked(_contentHash))) {
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Withdraw Zakat funds (only owner)
     * @param _amount Amount to withdraw
     * @param _recipient Recipient address
     */
    function withdrawZakat(uint256 _amount, address payable _recipient) external onlyOwner nonReentrant {
        require(_amount <= address(this).balance, "Insufficient balance");
        require(_recipient != address(0), "Invalid recipient");

        (bool success, ) = _recipient.call{value: _amount}("");
        require(success, "Transfer failed");
    }

    /**
     * @notice Get contract balance
     * @return Current balance
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
