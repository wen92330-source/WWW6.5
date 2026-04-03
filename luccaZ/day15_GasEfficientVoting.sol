//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
  //use uint8 for small numbers to save gas
  uint8 public proposalCount;

  //compact struct using minimal space types
  struct Proposal {
    bytes32 name;
    uint32 voteCount;
    uint32 startTime;
    uint32 endTime;
    bool executed;
  }

  //mapping of proposal ID to Proposal struct
  mapping(uint8 => Proposal) public proposals;
  //pack voting flags into a single uint256 to save storage space
  mapping(address => uint256) public voterRegistry;
  //count total voters for each proposal
  mapping(uint8 => uint32) public proposalVoterCount;

  //events
  event ProposalCreated(uint8 indexed proposalId, bytes32 name);
  event Voted(address indexed voter, uint8 indexed proposalId);
  event ProposalExecuted(uint8 indexed proposalId);

  function createProposal(bytes32 name, uint32 duration) external {
    require(duration > 0, "Duration must be greater than 0");

    //increment cuonter - cheaper than .push() on array
    uint8 proposalId = proposalCount++;

    //use a memory struct then assign to storage
    Proposal memory newProposal = Proposal({
      name: name,
      voteCount: 0,
      startTime: uint32(block.timestamp),
      endTime: uint32(block.timestamp + duration),
      executed: false
    });

    proposals[proposalId] = newProposal;
    emit ProposalCreated(proposalId, name);
  }

  function vote(uint8 proposalId) external {
    require(proposalId < proposalCount, "Invalid proposal ID");

    //check proposal voting period
    uint32 currentTime = uint32(block.timestamp);
    require(currentTime >= proposals[proposalId].startTime, "Voting has not started");
    require(currentTime <= proposals[proposalId].endTime, "Voting has ended");

    //check if already voted using bit manipulation
    uint256 voterData = voterRegistry[msg.sender];
    uint256 voteMask = 1 << proposalId;
    require((voterData & voteMask) == 0, "Already voted on this proposal.");

    //update voter registry using bitwise
    voterRegistry[msg.sender] = voterData | voteMask;

    //update proposal vote count
    proposals[proposalId].voteCount++;
    proposalVoterCount[proposalId]++;

    emit Voted(msg.sender, proposalId);
  }

  function executeProposal(uint8 proposalId) external {
    require(proposalId < proposalCount, "Invalid proposal.");
    require(block.timestamp > proposals[proposalId].endTime, "Voting not ended.");
    require(!proposals[proposalId].executed, "Proposal already executed.");

    proposals[proposalId].executed = true;
    emit ProposalExecuted(proposalId);
  }

  function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
    return (voterRegistry[voter] & (1 << proposalId)) != 0;
  }

  function getProposal(uint8 proposalId) external view returns (
    bytes32 name,
    uint32 voteCount,
    uint32 startTime,
    uint32 endTime,
    bool executed,
    bool active
  ) {
    require(proposalId < proposalCount, "Invalid proposal ID");
    Proposal storage proposal = proposals[proposalId]; //make a storage reference
    return (
      proposal.name,
      proposal.voteCount,
      proposal.startTime,
      proposal.endTime,
      proposal.executed,
      (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime)
    );
  }
}