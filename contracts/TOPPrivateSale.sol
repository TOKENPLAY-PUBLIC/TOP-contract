pragma solidity 0.8.3;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TOPPrivateSale is Ownable {
    uint256 public price; // 3 decimals
    IBEP20 public tokenplay;
    IBEP20 public currency; //BUSD
    uint256 public minAmount;
    uint256 public dexListingTime;
    mapping (address=>bool) private whilelists;

    enum LockType {DEX_VESTING, MONTH_VESTING}

    struct Vesting{
        uint256 id;
        address user;
        uint256 buyAmount;
        uint256 tokenAmount;
        uint256 time;
        LockType vestingType;
        bool isClaimed;
    }

    Vesting[] private vestings;
    
    constructor(address _tokenplay, address _currency, uint256 _price, uint256 _minAmount) {
        tokenplay=IBEP20(_tokenplay);
        currency=IBEP20(_currency);
        price=_price;
        minAmount=_minAmount;
    }

    function setDexListingTime(uint256 _dexListingTime) public onlyOwner {
        dexListingTime=_dexListingTime;
    }

    modifier onlyWhilelist(address user){
        require(whilelists[user],"Not in whilelist");
        _;
    }

    //update maximun 100 users each time
    function updateWhileList(address[] calldata users, bool[] calldata isWhilelists) public onlyOwner {
        require(users.length==isWhilelists.length,"Invalid input data");
        for(uint8 i=0; i<users.length; i++){
            whilelists[users[i]]=isWhilelists[i];
        }
    }

    function buy(uint256 amount) public onlyWhilelist(_msgSender()) {
        require(amount>=minAmount,"Amount too small");
        //calculate tokenplay
        uint256 tokenplayAmount=amount*1000/5;
        require(tokenplay.balanceOf(address(this))>=tokenplayAmount,"Token insufficient");

        //transfer BUSD
        require(
            currency.transferFrom(msg.sender, address(this), amount),
            "Token transfer fail"
        );

        //create vesting
        uint id=vestings.length;
        Vesting memory dexVesting=Vesting(
            id,
            _msgSender(),
            amount,
            tokenplayAmount*2/10,
            0,
            LockType.DEX_VESTING,
            false
        );
        vestings.push(dexVesting);

        for(uint8 i=1;i<=8;i++){
            Vesting memory vesting=Vesting(
                id+i,
                _msgSender(),
                amount,
                tokenplayAmount/10,
                block.timestamp+i*3*30*86400,
                LockType.MONTH_VESTING,
                false
            );
            vestings.push(vesting);
        }

        
    }

    function claim(uint256 vestingId) public onlyWhilelist(_msgSender()){
        Vesting storage vesting=vestings[vestingId];
        require(vesting.user==_msgSender(),"User not own the vesting");
        require(!vesting.isClaimed,"Vesting claim already");

        if(vesting.vestingType==LockType.DEX_VESTING){
            require(block.timestamp>=dexListingTime,"Wait for listing time");
        }else{
            require(block.timestamp>=vesting.time,"Wait for listing time");
        }

        //transfer tokenplay for user
        require(tokenplay.approve(_msgSender(), vesting.tokenAmount), "Approve failed!");
        require(tokenplay.transfer(_msgSender(), vesting.tokenAmount), "Transfer fail");

        vesting.isClaimed=true;
    }
}
