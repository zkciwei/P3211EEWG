pragma solidity ^0.5.2;

/**
 * @title IEEE P3211 interface
 *
 * @dev IEEE C/BDL P3211: Standard for blockchain-based Electronic Evidence interface specification.
 * https://standards.ieee.org/project/3211.html
 */

interface IP3211 {

    function getVersion() view external returns (string memory version);

    function setEvidence(
        bytes32 hash,
        bytes calldata account,
        bytes calldata signature,
        bytes32 preEid,
        string calldata resources,
        string calldata data
        )
        external
        returns (bytes32 eid);

    function setResources(
        bytes32 eid,
        string calldata resources,
        bytes calldata account,
        bytes calldata signature)
        external;

    function getEvidence(bytes32 eid)  
        view 
        external 
        returns (
            bytes32 hash, 
            bytes memory account, 
            bytes memory signature, 
            bytes32 preEid, 
            string memory resources, 
            string memory data, 
            address provider, 
            uint256 extraCount
        );

    function setExtraInfo(
        bytes32 eid,
        bytes calldata account, 
        bytes calldata signature, 
        bytes32 hash,
        string calldata data)
        external 
        returns (bytes32 exid);

    function getExtraInfo(bytes32 exid) 
        view 
        external 
        returns (
            bytes32 eid,
            bytes memory account,
            bytes memory signature,
            bytes32 hash,
            string memory data,
            address provider
        );

}
