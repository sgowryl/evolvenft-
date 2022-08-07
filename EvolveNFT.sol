// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract EvolveNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct levelId {
        uint256 tokenId;
        uint256 level;
    }
    mapping(bytes32 => string) public levelImages;

    mapping(uint256 => uint256) public levels;
    mapping(uint256 => uint256) public stakedTime;
    uint256 levelUp = 10;
    uint256 MAX_LEVEL = 3;

    constructor() ERC721("EvolveNFT", "EVO") {}

    function awardItem(address player) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        levels[newItemId] = 1;

        bytes32 level_id = keccak256(abi.encode(levelId(newItemId, 1)));
        string memory tokenURI = levelImages[level_id];

        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _tokenIds.increment();
        return newItemId;
    }

    function getLevel(uint256 tokenId) public view returns (uint256) {
        return levels[tokenId];
    }

    function stake(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "not owner");
        stakedTime[tokenId] = block.timestamp;
    }

    function unstake(uint256 tokenId) public returns (uint256 newLevel) {
        require(ownerOf(tokenId) == msg.sender, "not owner");
        uint256 timeDiff = block.timestamp - stakedTime[tokenId];
        stakedTime[tokenId] = 0;
        uint256 levelMultiplier = timeDiff % levelUp;
        uint256 newLevel = _increaseLevel(tokenId, levelMultiplier);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a <= b ? a : b;
    }

    function _increaseLevel(uint256 tokenId, uint256 levelMultiplier)
        private
        returns (uint256 newLevel)
    {
        uint256 currentLevel = levels[tokenId];
        uint256 newLevel = min(MAX_LEVEL, currentLevel + levelMultiplier);

        // get the new levels image and update it.
        bytes32 level_id = keccak256(abi.encode(levelId(tokenId, newLevel)));
        _setTokenURI(tokenId, levelImages[level_id]);

        levels[tokenId] = newLevel;
    }

    function setLevelImages(
        uint256 tokenId,
        uint256 level,
        string memory tokenURI
    ) public {
        bytes32 level_id = keccak256(abi.encode(levelId(tokenId, level)));
        levelImages[level_id] = tokenURI;
    }

    function getLevelImages(uint256 tokenId, uint256 level)
        public
        view
        returns (string memory)
    {
        bytes32 level_id = keccak256(abi.encode(levelId(tokenId, level)));
        return levelImages[level_id];
    }
}
