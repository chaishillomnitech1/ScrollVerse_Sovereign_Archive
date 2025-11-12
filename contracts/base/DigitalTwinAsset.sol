// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DigitalTwinAsset
 * @notice Smart contract for linking digital NFTs with physical assets
 * @dev Enables digital-physical asset synchronization with validation and status tracking
 * 
 * بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
 * VaultBook XL::Digital Twin Framework
 */

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DigitalTwinAsset is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    // Physical asset status enum
    enum PhysicalStatus {
        PRISTINE,
        EXCELLENT,
        GOOD,
        FAIR,
        NEEDS_MAINTENANCE,
        UNDER_RESTORATION
    }

    // Digital Twin structure
    struct DigitalTwin {
        uint256 tokenId;
        string physicalAssetId;
        string digitalMetadataUri;
        string physicalLocation;
        PhysicalStatus status;
        uint256 lastValidation;
        address validator;
        bool isLinked;
        string[] validationHistory;
    }

    // State mappings
    mapping(uint256 => DigitalTwin) public digitalTwins;
    mapping(string => uint256) public physicalAssetToToken;
    mapping(uint256 => uint256) public zakatAllocation; // tokenId => zakat amount allocated

    // Events
    event DigitalTwinCreated(
        uint256 indexed tokenId,
        string physicalAssetId,
        address indexed owner,
        uint256 timestamp
    );

    event PhysicalAssetLinked(
        uint256 indexed tokenId,
        string physicalAssetId,
        string location,
        uint256 timestamp
    );

    event StatusUpdated(
        uint256 indexed tokenId,
        PhysicalStatus oldStatus,
        PhysicalStatus newStatus,
        address indexed validator,
        uint256 timestamp
    );

    event ValidationPerformed(
        uint256 indexed tokenId,
        address indexed validator,
        string validationReport,
        uint256 timestamp
    );

    event ZakatAllocated(
        uint256 indexed tokenId,
        uint256 amount,
        uint256 timestamp
    );

    constructor() ERC721("ScrollVerse Digital Twin", "SVDT") {}

    /**
     * @notice Create a new digital twin NFT
     * @param _to Owner address
     * @param _physicalAssetId Physical asset identifier
     * @param _digitalMetadataUri URI to digital metadata
     * @param _physicalLocation Location of physical asset
     * @return tokenId The newly minted token ID
     */
    function createDigitalTwin(
        address _to,
        string memory _physicalAssetId,
        string memory _digitalMetadataUri,
        string memory _physicalLocation
    ) external onlyOwner returns (uint256) {
        require(_to != address(0), "Invalid recipient address");
        require(bytes(_physicalAssetId).length > 0, "Physical asset ID required");
        require(physicalAssetToToken[_physicalAssetId] == 0, "Physical asset already linked");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(_to, tokenId);

        DigitalTwin storage twin = digitalTwins[tokenId];
        twin.tokenId = tokenId;
        twin.physicalAssetId = _physicalAssetId;
        twin.digitalMetadataUri = _digitalMetadataUri;
        twin.physicalLocation = _physicalLocation;
        twin.status = PhysicalStatus.PRISTINE;
        twin.lastValidation = block.timestamp;
        twin.validator = msg.sender;
        twin.isLinked = true;

        physicalAssetToToken[_physicalAssetId] = tokenId;

        emit DigitalTwinCreated(tokenId, _physicalAssetId, _to, block.timestamp);
        emit PhysicalAssetLinked(tokenId, _physicalAssetId, _physicalLocation, block.timestamp);

        return tokenId;
    }

    /**
     * @notice Update the physical status of an asset
     * @param _tokenId Token ID of the digital twin
     * @param _newStatus New physical status
     * @param _validationReport Report from validation
     */
    function updatePhysicalStatus(
        uint256 _tokenId,
        PhysicalStatus _newStatus,
        string memory _validationReport
    ) external onlyOwner {
        require(_exists(_tokenId), "Token does not exist");
        
        DigitalTwin storage twin = digitalTwins[_tokenId];
        PhysicalStatus oldStatus = twin.status;
        
        twin.status = _newStatus;
        twin.lastValidation = block.timestamp;
        twin.validator = msg.sender;
        twin.validationHistory.push(_validationReport);

        emit StatusUpdated(_tokenId, oldStatus, _newStatus, msg.sender, block.timestamp);
        emit ValidationPerformed(_tokenId, msg.sender, _validationReport, block.timestamp);
    }

    /**
     * @notice Validate and sync physical asset condition
     * @param _tokenId Token ID
     * @param _validationReport Validation report URI or data
     */
    function validatePhysicalAsset(
        uint256 _tokenId,
        string memory _validationReport
    ) external onlyOwner {
        require(_exists(_tokenId), "Token does not exist");
        
        DigitalTwin storage twin = digitalTwins[_tokenId];
        twin.lastValidation = block.timestamp;
        twin.validator = msg.sender;
        twin.validationHistory.push(_validationReport);

        emit ValidationPerformed(_tokenId, msg.sender, _validationReport, block.timestamp);
    }

    /**
     * @notice Allocate Zakat funds to a specific digital twin
     * @param _tokenId Token ID
     */
    function allocateZakat(uint256 _tokenId) external payable {
        require(_exists(_tokenId), "Token does not exist");
        require(msg.value > 0, "Must send value");

        zakatAllocation[_tokenId] += msg.value;

        emit ZakatAllocated(_tokenId, msg.value, block.timestamp);
    }

    /**
     * @notice Get digital twin details
     * @param _tokenId Token ID
     * @return Digital twin structure
     */
    function getDigitalTwin(uint256 _tokenId) external view returns (DigitalTwin memory) {
        require(_exists(_tokenId), "Token does not exist");
        return digitalTwins[_tokenId];
    }

    /**
     * @notice Get validation history for a digital twin
     * @param _tokenId Token ID
     * @return Array of validation reports
     */
    function getValidationHistory(uint256 _tokenId) external view returns (string[] memory) {
        require(_exists(_tokenId), "Token does not exist");
        return digitalTwins[_tokenId].validationHistory;
    }

    /**
     * @notice Check if physical asset is linked
     * @param _physicalAssetId Physical asset identifier
     * @return True if linked, false otherwise
     */
    function isPhysicalAssetLinked(string memory _physicalAssetId) external view returns (bool) {
        return physicalAssetToToken[_physicalAssetId] != 0;
    }

    /**
     * @notice Get token ID by physical asset ID
     * @param _physicalAssetId Physical asset identifier
     * @return Token ID
     */
    function getTokenByPhysicalAsset(string memory _physicalAssetId) external view returns (uint256) {
        uint256 tokenId = physicalAssetToToken[_physicalAssetId];
        require(tokenId != 0, "Physical asset not linked");
        return tokenId;
    }

    /**
     * @notice Get Zakat allocation for a token
     * @param _tokenId Token ID
     * @return Allocated amount
     */
    function getZakatAllocation(uint256 _tokenId) external view returns (uint256) {
        return zakatAllocation[_tokenId];
    }

    /**
     * @notice Get total supply of digital twins
     * @return Total count
     */
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter.current();
    }

    /**
     * @notice Update metadata URI for digital twin
     * @param _tokenId Token ID
     * @param _newMetadataUri New metadata URI
     */
    function updateMetadataUri(uint256 _tokenId, string memory _newMetadataUri) external onlyOwner {
        require(_exists(_tokenId), "Token does not exist");
        digitalTwins[_tokenId].digitalMetadataUri = _newMetadataUri;
    }

    /**
     * @notice Update physical location
     * @param _tokenId Token ID
     * @param _newLocation New physical location
     */
    function updatePhysicalLocation(uint256 _tokenId, string memory _newLocation) external onlyOwner {
        require(_exists(_tokenId), "Token does not exist");
        digitalTwins[_tokenId].physicalLocation = _newLocation;
    }

    /**
     * @dev Override tokenURI to return custom metadata
     */
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "Token does not exist");
        return digitalTwins[_tokenId].digitalMetadataUri;
    }
}
