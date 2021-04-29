pragma solidity ^0.5.2;
import "./IP3211.sol";

/**
 * @title IEEE P3211 RC2
 *
 * @dev IEEE C/BDL P3211: Standard for blockchain-based Electronic Evidence interface specification.
 * https://standards.ieee.org/project/3211.html
 * Kovan network (chainId 42): 0xB5f484a02448100800DD909569228291dA4B8703
 */

contract P3211 is IP3211 {

    /**
     * @dev Evidence Struct
     * @param header        头信息，json格式 {"providerUri":""}, 需遵循标准规范
     * @param mainEid       主证据eid，如果填写则表示本证据是附加证据
     * @param preEids       本证据前的相关证据集，可应用于证据链关联
     * @param provider      服务提供者
     * @param extraCount    本证据的附加证据数量，每添加一个附加证据，extraCount+1
     * @param hash          证据Hash
     * @param account       存储者
     * @param signature     存储者签名
     * @param data          自定义数据，json格式, 需遵循标准规范
     */
    struct Evidence{
        string header;
        bytes32 mainEid;
        bytes32[] preEids;
        address provider;
        uint256 extraCount;
        bytes32 hash;
        bytes account;
        bytes signature;
        string data;
    }

    uint256 constant private CHAINID = 42;
    uint256 private _evidenceCount_;
    string constant private _version_ = "P3211.0.1 RC2";

    mapping(bytes32 => Evidence) private evidences;  //eid=>Evidence

    constructor() public {
    }

    // Events

    event SetEvidence(
        bytes32 indexed eid,
        bytes32 indexed mainEid,
        bytes32 indexed hash,
        bytes account,
        bytes signature, 
        address provider
    );

    // Functions

    /// @dev get version
    function version() view external returns (string memory) {
        return _version_;
    }

    /**
     * @dev setMainEvidence 提交主证据
     * @param header        头信息，json格式 {"providerUri":""}, 需遵循标准规范
     * @param mainEid       主证据eid，如果填写则表示本证据是附加证据
     * @param preEids       本证据前的相关证据集，可应用于证据链关联
     * @param hash          电子证据信息hash，如文件hash
     * @param account       存储者
     * @param signature     存储者签名
     * @param data          自定义内容，json格式, 需遵循标准规范
     * @return eid          返回生成证据eid，
     *                      如果是主证据eid=sha256(abi.encodePacked(CHAINID, hash, account, _evidenceCount_))
     *                      如果是附加证据eid=sha256(abi.encodePacked(eid, mainEvidence.extraCount))
     */
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
        returns (bytes32 eid) 
    {
        require(hash != bytes32(0), "Empty Evidence Hash!");
        // generate unique evidence id
        if (mainEid != bytes32(0)){  //mainEvidence
            eid = sha256(abi.encodePacked(CHAINID, hash, account, ++_evidenceCount_));
        } else {  //extraEvidence
            eid = sha256(abi.encodePacked(mainEid, ++evidences[mainEid].extraCount));
        }
        Evidence storage evidence = evidences[eid];
        evidence.header = header;
        evidence.mainEid = mainEid;
        evidence.preEids = preEids;
        evidence.provider = msg.sender;
        evidence.hash = hash;
        evidence.account = account;
        evidence.signature = signature;
        evidence.data = data;
        emit SetEvidence(eid, mainEid, hash, account, signature, msg.sender);
        return eid;
    }

    /**
     * @dev getEvidence       根据eid查询电子证据信息, 返回 Evidence Struct
     * @param eid             电子证据eid
     */
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
        )
    {
        Evidence memory evidence =  evidences[eid];      
        return (
            evidence.header,
            evidence.mainEid,
            evidence.preEids,
            evidence.provider,
            evidence.extraCount,
            evidence.hash,
            evidence.account,
            evidence.signature,
            evidence.data
        );
    }

}
