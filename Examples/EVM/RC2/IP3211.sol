pragma solidity ^0.5.2;

/**
 * @title IEEE P3211 interface
 *
 * @dev IEEE C/BDL P3211: Standard for blockchain-based Electronic Evidence interface specification.
 * https://standards.ieee.org/project/3211.html
 */

interface IP3211 {

    function version() view external returns (string memory);

    function setEvidence(
        string calldata header,
        bytes32 mainEid,
        bytes32[] calldata preEids,
        bytes32 hash,
        bytes calldata account,
        bytes calldata signature,
        string calldata data
    )
        external
        returns (bytes32 eid);

    function getEvidence(bytes32 eid)
        view
        external
        returns (
            string memory header,
            bytes32 mainEid,
            bytes32[] memory preEids,
            address provider,
            uint256 extraCount,
            bytes32 hash,
            bytes memory account,
            bytes memory signature,
            string memory data
        );

}
