// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title LevelCompleteBadge
/// @notice A minimal, dependency-free ERC-721 badge minted on Arc Testnet
///         when a player finishes a level of "Byte Quest". One badge per
///         wallet. No external imports — paste this straight into Remix.
contract LevelCompleteBadge {
    string public constant name = "Byte Quest Badge";
    string public constant symbol = "BQBADGE";

    uint256 private _nextId = 1;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(address => bool) public hasMinted;
    mapping(address => uint256) public badgeOf;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event BadgeMinted(address indexed player, uint256 indexed tokenId);

    // ---------- Minting ----------

    /// @notice Mint your one-per-wallet "Level Complete" badge.
    function mint() external returns (uint256) {
        require(!hasMinted[msg.sender], "Badge already minted for this wallet");

        uint256 tokenId = _nextId++;
        hasMinted[msg.sender] = true;
        badgeOf[msg.sender] = tokenId;

        _balances[msg.sender] += 1;
        _owners[tokenId] = msg.sender;

        emit Transfer(address(0), msg.sender, tokenId);
        emit BadgeMinted(msg.sender, tokenId);
        return tokenId;
    }

    function totalSupply() external view returns (uint256) {
        return _nextId - 1;
    }

    // ---------- ERC-721 metadata ----------

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_owners[tokenId] != address(0), "Nonexistent token");
        // Fully on-chain, no external hosting required.
        return
            string(
                abi.encodePacked(
                    "data:application/json;utf8,",
                    '{"name":"Byte Quest Badge #',
                    _toString(tokenId),
                    '","description":"Awarded for completing Byte Quest on Arc Testnet.",',
                    '"attributes":[{"trait_type":"Game","value":"Byte Quest"},{"trait_type":"Network","value":"Arc Testnet"}]}'
                )
            );
    }

    // ---------- ERC-721 core ----------

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Nonexistent token");
        return owner;
    }

    function approve(address to, uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        require(to != owner, "Approve to owner");
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "Not authorized"
        );
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_owners[tokenId] != address(0), "Nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {
        require(operator != msg.sender, "Approve to self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isAuthorized(msg.sender, tokenId), "Not authorized");
        require(ownerOf(tokenId) == from, "Wrong owner");
        require(to != address(0), "Zero address");

        _tokenApprovals[tokenId] = address(0);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "Unsafe recipient");
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165
            interfaceId == 0x80ac58cd || // ERC721
            interfaceId == 0x5b5e139f;   // ERC721Metadata
    }

    // ---------- Internal helpers ----------

    function _isAuthorized(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.code.length == 0) return true;
        (bool success, bytes memory returndata) = to.call(
            abi.encodeWithSelector(
                0x150b7a02, // IERC721Receiver.onERC721Received.selector
                msg.sender,
                from,
                tokenId,
                data
            )
        );
        if (!success) return false;
        bytes4 retval = abi.decode(returndata, (bytes4));
        return retval == 0x150b7a02;
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
