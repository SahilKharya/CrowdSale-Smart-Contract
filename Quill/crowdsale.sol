pragma solidity >=0.5.0 <0.7.0;

import './SafeMath.sol';
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Crowdsale is IERC20{
    using SafeMath for uint256;
    IERC20 public token;

    
    uint256 private _totalSupply = 5000000000000000000000000;
    string private _name = "QUILL";
    string private _symbol = "QUILL";
    uint8 private _decimals = 18;
    
    /*
        Taking 1Eth price approx = 400 USD 
        Token price is 0.001 USD, So rate will be for 1 wei = 400000 bits of QUILL Token.
        Price of 1 QUILL token = 2,500,000,000,000 wei or 0.0000025 Eth
    */
    uint256 public rate = 400000;
    address payable _owner;
    uint256 private weiRaised = 0;
    address payable wallet;

    mapping (address => uint256) private balances;

    mapping (address => mapping (address => uint256)) public allowances;
   
    // emit the events for transfer and transferFrom
    event Transfer(address _from, address _to, uint256 _value);
    // emit from approve event
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);


    constructor (address payable _wallet) public {
    _owner = msg.sender;
    balances[_owner] = _totalSupply;
    approve(address(this), _totalSupply);
    require(_wallet != address(0));

    wallet = _wallet;
    }
    function totalSupply() public override view returns (uint256){
            return _totalSupply;
    }
    
    function contractAddress() public view returns (address) {
        return address(this);
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }
    
    function transfer(address _to, uint256 _value) public override returns (bool) {
    // Return false if specified value is less than the balance available
    if(_value > 0  && balances[_owner] < _value) {
      return false;
    }
    
    // Reduce the balance by _value
    balances[msg.sender] = balances[msg.sender].sub(_value);
    // Increase the balance of the receiever that is account with address _to
    balances[_to] = balances[_to].add(_value);
    // Declare & Emit the transfer event
    emit Transfer(msg.sender, _to, _value);
    
    return true;
    }
  // How many tokens can spender spend from owner's account
    function allowance(address owner, address spender) public override view returns (uint256){
    //1. Declare a mapping to manage allowances
    //2. Return the allowance for _spender approved by _owner
    return allowances[owner][spender];
  }

  // Approval - sets the allowance
  function approve(address _spender, uint256 _value) public override returns (bool) {
    if(_value <= 0) return false;

    allowances[msg.sender][_spender] = _value;
    //  Declare the Approval event and emit it
    emit Approval(msg.sender, _spender, _value);

    return true;
  }
  // Transfer from
  function transferFrom(address owner, address buyer, uint numTokens) public override returns (bool) {
    require(numTokens <= balances[owner]);
    require(numTokens <= allowances[owner][msg.sender]);
    balances[owner] = balances[owner].sub(numTokens);
    allowances[owner][msg.sender] = allowances[owner][msg.sender].sub(numTokens);
    balances[buyer] = balances[buyer].add(numTokens);
    emit Transfer(owner, buyer, numTokens);
    return true;
  }



  
  function buyTokens(address beneficiary)  payable public{
     require(beneficiary != address(0));
    require(msg.value != 0);

    uint256 tokens = msg.value.mul(rate);
    weiRaised = weiRaised.add(msg.value);

    token.transfer(beneficiary, tokens);
    wallet.transfer(msg.value);
  }

}

