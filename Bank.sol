pragma solidity ^0.4.25;

contract Bank {
	// 此合約的擁有者
    address private owner;

	// 儲存所有會員的ether餘額
    mapping (address => uint256) private balance;

	// 儲存所有會員的coin餘額
    mapping (address => uint256) private coinBalance;

	// 事件們，用於通知前端 web3.js
    event DepositEvent(address indexed from, uint256 value, uint256 timestamp);
    event WithdrawEvent(address indexed from, uint256 value, uint256 timestamp);
    event TransferEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);

    event MintEvent(address indexed from, uint256 value, uint256 timestamp);
    event BuyCoinEvent(address indexed from, uint256 value, uint256 timestamp);
    event TransferCoinEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);
    event TransferOwnerEvent(address indexed oldOwner, address indexed newOwner, uint256 timestamp);

    modifier isOwner() {
        require(owner == msg.sender, "you are not owner");
        _;
    }

	// 建構子
    constructor() public payable {
        owner = msg.sender;
    }

	// 存錢
    function deposit() public payable {
        balance[msg.sender] += msg.value;

        // emit DepositEvent
        emit DepositEvent(msg.sender, msg.value, block.timestamp);
    }

	// 提錢
    function withdraw(uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        msg.sender.transfer(weiValue);

        balance[msg.sender] -= weiValue;

        // emit WithdrawEvent
        emit WithdrawEvent(msg.sender, etherValue, block.timestamp);
    }

	// 轉帳
    function transfer(address to, uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        balance[msg.sender] -= weiValue;
        balance[to] += weiValue;

        // emit TransferEvent
        emit TransferEvent(msg.sender, to, etherValue, block.timestamp);
    }

	// mint coin
    function mint(uint256 coinValue) public isOwner {
        
        uint256 value = coinValue * 1 ether;
        
        coinBalance[msg.sender] += value;        
        
        emit MintEvent(msg.sender, value, block.timestamp);
    }

	// 使用 bank 中的 ether 向 owner 購買 coin
    function buy(uint256 coinValue) public {
        uint256 value = coinValue * 1 ether;
        
        require(coinBalance[owner] >= value, "not enough");
        require(balance[msg.sender] >= value, "no eth");

        balance[msg.sender] -= value;
        balance[owner] += value;
        coinBalance[msg.sender] += value;
        coinBalance[owner] -= value;

        emit BuyCoinEvent(msg.sender, value, block.timestamp);
    }

	// 轉移 coin
    function transferCoin(address to, uint256 coinValue) public {
        uint256 value = coinValue * 1 ether;
        require(coinBalance[msg.sender] >= value, "Not enough");

        coinBalance[msg.sender] -= value;

        coinBalance[to] += value;

        emit TransferCoinEvent(msg.sender, to, value, block.timestamp);
    }

	// 檢查銀行帳戶餘額
    function getBankBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

    // 檢查coin餘額
    function getCoinBalance() public view returns (uint256) {
        return coinBalance[msg.sender];
    }

    // get owner
    function getOwner() public view returns (address)  {
        return owner;
    }

    // 轉移owner
    function transferOwner(address newOwner) public isOwner {
        owner = newOwner;
    
        emit TransferOwnerEvent(msg.sender, newOwner, block.timestamp);
    }
    function kill() public isOwner {
        selfdestruct(owner);
    }
}