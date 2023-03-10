// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

contract Vote {

    //state variables are declared
    address public owner;

    string private name;

    string private symbol;

    uint256 private decimal;

    uint private totalSupply;

    mapping (address => uint256) private balanceOf;

    // 2D mapping: mapping the owner => spender =>  amount
    mapping (address =>mapping(address => uint)) public allowance;

    //Declare an Event for transfer and mint function
    event transfer_(address indexed from, address to, uint amount);
    event _mint(address indexed from, address to, uint amount);

    struct Candidates {
        address candid; //name of each proposal
        string name;
        uint voteCount; //number of accumulated votes
        bool status;
    }

    mapping (address => Candidates) public votee;
    Candidates[] public candidates;
    address[] public _candidateKey;

    //voters: voted, access to vote, vote index
    struct Voter {
        bool isVoted;        // if true, that person already voted
        uint accessToVote;   // weight is accumulated by delegation
        uint voteIndex;      // index of the voted proposal
        address _voter;    
    }

    mapping(address => Voter) public voters; //voter's address mapped to voter detail
    mapping(address => uint256) public total;

    address public Admin = msg.sender;


    constructor(string memory _name, string memory _symbol){
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimal = 1e18;
    }

    function name_() public view returns(string memory){
        return name;
    }

    function symbol_() public view returns(string memory){
        return symbol;
    }

    function _decimal() public view returns(uint256){
        return decimal;
    }

    function _totalSupply() public view returns(uint256){
        return totalSupply;
    }

    function _balanceOf(address who) public view returns(uint256){
        return balanceOf[who];
    }

    function transfer(address _to, uint amount)public {
        _transfer(msg.sender, _to, amount);
        emit transfer_(msg.sender, _to, amount);    //Emit a transfer event

    }

    function _transfer(address from, address to, uint amount) internal {
        require(balanceOf[from] >= amount, "insufficient fund");
        require(to != address(0), "transferr to address(0)");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
    }

    function _allowance(address _owner, address spender) public view returns(uint amount){
        amount = allowance[_owner][spender];
    }

    function transferFrom(address from, address to, uint amount) public returns(bool success){
        uint value = _allowance(from, msg.sender);
        require( amount <= value, "insufficient allowance");
        allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        success =true;

        emit transfer_(from, to, amount);   //Emit a transfer event
    }

    function Approve(address spender, uint amount) public  {
        allowance[msg.sender][spender] += amount;

    }


    function mint(address to, uint amount) public {
        require(msg.sender == owner, "Access Denied");
        require(to != address(0), "transferr to address(0)");
        totalSupply += amount;
        balanceOf[to] += amount * _decimal();
        emit _mint(address(0), to, amount);     //Emit a mint event


    }


    function _burn(address from, address to, uint _amount) internal {
        require(to == address(0), "transfer to address(0)");
        balanceOf[from] -= _amount;
        balanceOf[to] += _amount;
        totalSupply -= _amount;
    }
//////voteeee

    function assignAdmin() public view {
       Admin;
    }

    modifier onlyOwner(){
        require(msg.sender == Admin, "Not Admin");
        _;

    }

    /*function addCandidate(address _candid, string calldata _name, address _votee) external onlyOwner{
        Candidates storage _candidates = candidates[_votee];
        require(_candidates.status == false, "Candidate already existed");
        _candidates.candid = _candid;
        _candidates.name = _name;
        _candidates.voteCount = 0;
        _candidates.status = true;
        _candidateKey.push(_votee);
    }*/

    function getAccessToVote(address voter) public {
        require(msg.sender == Admin, "Only Admin can give access to vote");
        //require that voter has not voted yet
        require(voters[voter].isVoted == false, "Has voted before");
        require(voters[voter].accessToVote == 0);
        transfer(voters[voter]._voter, 10);
        voters[voter].accessToVote = 10;
        totalSupply -= 10;

    }


    function vote (address _candidateA, address _candidateB, address _candidateC) internal {
        Voter storage sender = voters[msg.sender];
        require(sender.accessToVote != 0, "Cannot vote");
        require(!sender.isVoted, "Already voted.");
        sender.isVoted = true;
        total[_candidateA] += 3;
        total[_candidateB] += 2;
        total[_candidateC] += 1;
    }


    function vote(uint _candidate) public {
        Voter storage sender = voters[msg.sender];
        require(sender.accessToVote != 0, "Cannot vote");
        require(!sender.isVoted, "Already voted.");
        sender.isVoted = true;
        sender.voteIndex = _candidate;

        candidates[_candidate].voteCount += sender.accessToVote;
    }

    function winnerCandid() public view returns (uint _winnerCandid) {

    }

    function winnerAddress() public view returns (address _winnerAddress) {
        _winnerAddress = candidates[winnerCandid()].candid;
    }
    
}