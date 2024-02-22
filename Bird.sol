//SPDX-License-Identifier: UNLICENSED
pragma solidity <=0.8.20;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface IBird {
    function mint(address to, uint256 bird_type) external returns (uint256);
}

contract Bird is ERC721Enumerable, Ownable, AccessControl, IBird {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    string private _url;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event Mint(address to, uint256 hero_type, uint256 tokenid);

    constructor(address initialOwner)
        ERC721("Floppy Bird", "Bird")
        Ownable(initialOwner)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
    }

    function _baseURI()
        internal
        view
        override
        returns (string memory _newBaseURI)
    {
        return _url;
    }

    function mint(address to, uint256 hero_type)
        external
        override
        returns (uint256)
    {
        require(
            owner() == _msgSender() || hasRole(MINTER_ROLE, _msgSender()),
            "Caller is not a minter"
        );
        _tokenIdTracker.increment();
        uint256 token_id = _tokenIdTracker.current();
        _safeMint(to, token_id);

        emit Mint(to, hero_type, token_id);
        return token_id;
    }

    function listTokenIds(address owner)
        external
        view
        returns (uint256[] memory tokenIds)
    {
        uint256 balance = balanceOf(owner);
        uint256[] memory ids = new uint256[](balance);

        for (uint256 i = 0; i < balance; i++) {
            ids[i] = tokenOfOwnerByIndex(owner, i);
        }
        return (ids);
    }

    function setBaseUrl(string memory _newUrl) public onlyOwner {
        _url = _newUrl;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
