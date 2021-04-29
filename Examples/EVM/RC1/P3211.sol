pragma solidity ^0.5.2;
import "./IP3211.sol";

/**
 * @title IEEE P3211
 *
 * @dev IEEE C/BDL P3211: Standard for blockchain-based Electronic Evidence interface specification.
 * https://standards.ieee.org/project/3211.html
 * Kovan network (chainId 42): 0x9e718828991970113A50081DF865AbA0E6F6dd44
 */

contract P3211 is IP3211 {

    /**
     * @dev Evidence Struct
     * @param hash           电子证据信息hash，如文件hash
     * @param account        存储者
     * @param signature      存储者签名
     * @param preEid         证据链上一环证据的 eid
     * @param resources      电子证据资源，如URI、DID等，可更新
     * @param data           业务内容，json格式
     * @param provider       服务提供者
     * @param extraCount     附加操作计数
     */
    struct Evidence {
        bytes32 hash;
        bytes account;
        bytes signature;
        bytes32 preEid;
        string resources;
        string data;
        address provider;
        uint256 extraCount;
    }

    /**
     * @dev ExtraInfo Struct
     * @param eid            电子证据eid
     * @param account        操作者
     * @param signature      操作者的签名
     * @param hash           附加操作信息hash
     * @param data           业务内容，json格式
     * @param provider       服务提供者
     */
    struct ExtraInfo {
        bytes32 eid;
        bytes account;
        bytes signature;
        bytes32 hash;
        string data;
        address provider;
    }

    uint256 constant CHAINID = 42;
    address private _admin_;
    uint256 private _evidenceCount_;
    string private _version_ = "P3211.0.1";

    mapping(bytes32 => Evidence) private evidences;
    mapping(bytes32 => ExtraInfo) private extraInfos;

    constructor() public {
      _admin_ = msg.sender;
    }

    // Events

    event LogSetEvidence(
        bytes32 indexed eid, 
        bytes32 indexed hash, 
        bytes indexed account, 
        bytes signature, 
        address provider
    );
    event LogSetResources(
        bytes32 indexed eid, 
        bytes indexed account, 
        bytes signature, 
        address provider
    );
    event LogSetExtraInfo(
        bytes32 indexed exid, 
        bytes32 indexed eid,
        bytes indexed account, 
        bytes signature, 
        address provider
    );

    // Functions

    /// @dev getVersion
    function getVersion() view external returns (string memory version) {
        return _version_;
    }

    /**
     * @dev setEvidence      提交电子证据
     * @param hash           电子证据信息hash，如文件hash
     * @param account        存储者
     * @param signature      存储者签名
     * @param preEid         证据链上一环证据的 eid
     * @param resources      电子证据资源，如URI、DID等，可更新
     * @param data           业务内容，json格式
     * @return eid           返回生成的电子证据eid=sha256(abi.encodePacked(CHAINID, hash, account, _evidenceCount_))
     */
    function setEvidence(
        bytes32 hash, 
        bytes calldata account,
        bytes calldata signature, 
        bytes32 preEid, 
        string calldata resources, 
        string calldata data
    ) 
        external
        returns (bytes32 eid) 
    {
        require(hash != bytes32(0), "Empty Evidence Hash");
        // generate unique evidence id
        _evidenceCount_++;
        eid = sha256(abi.encodePacked(CHAINID, hash, account, _evidenceCount_));
        Evidence storage evidence = evidences[eid];
        evidence.hash = hash;
        evidence.account = account;
        evidence.signature = signature;
        evidence.preEid = preEid;  
        evidence.resources = resources;
        evidence.data = data;
        evidence.provider = msg.sender;
        emit LogSetEvidence(eid, hash, account, signature, msg.sender);
        return eid;
    }

    /**
     * @dev setResources      更新电子证据信息资源描述
     * @param eid             电子证据eid
     * @param resources       电子证据资源，如URI、DID等
     * @param account         操作者
     * @param signature       操作者签名
     */
    function setResources(
        bytes32 eid,
        string calldata resources,
        bytes calldata account,
        bytes calldata signature
    )
        external
    {
        require(evidences[eid].provider == msg.sender, "Unauthorized Provider");
        evidences[eid].resources = resources;
        address provider = evidences[eid].provider;
        emit LogSetResources(eid, account, signature, provider);
    }

    /**
     * @dev getEvidence       根据eid查询电子证据信息
     * @param eid             电子证据eid
     * @return hash           电子证据信息hash，如文件hash
     * @return account        存储者
     * @return signature      存储者签名
     * @return preEid         证据链上一环证据的 eid
     * @return resources      电子证据资源，如URI、DID等，可更新
     * @return data           业务内容，json格式
     * @return provider       服务提供者账户地址
     * @return extraCount     附加操作计数
     */
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
        )
    {
        Evidence memory evidence =  evidences[eid];      
        return (
            evidence.hash, 
            evidence.account, 
            evidence.signature, 
            evidence.preEid, 
            evidence.resources, 
            evidence.data, 
            evidence.provider, 
            evidence.extraCount
        );
    }

    /**
     * @dev setExtraInfo     提交电子证据的附加操作信息
     * @param eid            电子证据eid
     * @param account        操作者
     * @param signature      操作签名
     * @param hash           附加信息Hash
     * @param data           业务内容，json格式
     * @return exid          附加操作信息exid=sha256(abi.encodePacked(eid, extraCount))
     */
    function setExtraInfo(
        bytes32 eid,
        bytes calldata account, 
        bytes calldata signature, 
        bytes32 hash,
        string calldata data
    )
        external
        returns (bytes32 exid) 
    {
        evidences[eid].extraCount++;
        exid = sha256(abi.encodePacked(eid, evidences[eid].extraCount));
        ExtraInfo storage extraInfo = extraInfos[exid];
        extraInfo.eid = eid;
        extraInfo.account = account;
        extraInfo.signature = signature;
        extraInfo.hash = hash;
        extraInfo.data = data;
        extraInfo.provider = msg.sender;
        emit LogSetExtraInfo(exid, eid, account, signature, extraInfo.provider);
    }

    /**
     * @dev getExtraInfo      根据exid查询电子证据附加操作信息
     * @param exid            附加操作信息eid
     * @return eid            电子证据eid
     * @return account        操作者
     * @return signature      操作者签名
     * @return hash           附加操作信息Hash
     * @return data           业务内容，json格式
     * @return provider       服务提供者账户地址
     */
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
        ) 
    {
        ExtraInfo storage extraInfo =  extraInfos[exid];
        return (
            extraInfo.eid,
            extraInfo.account, 
            extraInfo.signature, 
            extraInfo.hash,
            extraInfo.data, 
            extraInfo.provider
        );
    }

}
