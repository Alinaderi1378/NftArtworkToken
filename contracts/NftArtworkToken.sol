
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./openzeppelin/contracts/access/Ownable.sol";
contract NftArtworkToken is Ownable(msg.sender) {

    struct Artwork {
        string title;
        string description;
        string creator;
        uint256 timestamp;
        address owner;
    }

    // Mapping from unique ID to Artwork
    mapping(uint256 => Artwork) public artworks;
    uint256 public nextId;

    // Event to emit when a new artwork is registered
    event ArtworkRegistered(
        uint256 indexed id,
        string title,
        string description,
        string creator,
        address indexed owner
    );

    event OwnershipTransferred(
        uint256 indexed id,
        address indexed previousOwner,
        address indexed newOwner
    );

    // Constructor that initializes the Ownable contract with the sender as the owner
    constructor()  {
        // Optionally, additional initialization can be done here.
    }

    // Modifier to validate input strings
    modifier validInput(string memory _input) {
        require(bytes(_input).length > 0, "Invalid input");
        _;
    }

    // Modifier to check if an artwork exists
    modifier artworkExists(uint256 _id) {
        require(_id < nextId, "Artwork does not exist");
        _;
    }

    // Register a new artwork (with input validation)
    function registerArtwork(
        string memory _title,
        string memory _description,
        string memory _creator
    ) public validInput(_title) validInput(_description) validInput(_creator) {
        uint256 id = nextId++;
        artworks[id] = Artwork({
            title: _title,
            description: _description,
            creator: _creator,
            timestamp: block.timestamp,
            owner: msg.sender
        });

        emit ArtworkRegistered(id, _title, _description, _creator, msg.sender);
    }

    // Get details of an artwork by ID
    function getArtwork(uint256 _id) public view artworkExists(_id) returns (
        string memory title,
        string memory description,
        string memory creator,
        uint256 timestamp,
        address owner
    ) {
        Artwork memory art = artworks[_id];
        return (art.title, art.description, art.creator, art.timestamp, art.owner);
    }

    // Transfer ownership of the artwork (only by the current owner)
    function transferOwnership(uint256 _id, address _newOwner) public artworkExists(_id) {
        require(_newOwner != address(0), "Invalid address");
        Artwork storage art = artworks[_id];
        require(art.owner == msg.sender, "Caller is not the owner");

        address previousOwner = art.owner;
        art.owner = _newOwner;

        emit OwnershipTransferred(_id, previousOwner, _newOwner);
    }

    // Only the contract owner (deployer) can set a new contract owner
    function transferContractOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address for new owner");
        transferOwnership(newOwner);
    }
}