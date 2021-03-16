pragma solidity ^0.6.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UtilizationRewards {
    using SafeMath for uint256;
    address public bO = 0x0000000000000000000000000000000000000000;//binary options
    address payable dao = 0x0000000000000000000000000000000000000000;
    uint256 public lEnd;//launch end
    uint256 public epoch = 0; //rewards epoch 
    uint256 public eS;//end of current epoch
    uint256 public perE;//rewards per epoch (650000000000000000000000000000 total)
    uint256 public tTE;//claims left this epoch
    uint256 maxEpoch;
    ERC20 token;
                                      

    /** 
     * @dev init the contract
     * @param bo_ the the binary options contract address
     * @param token_ the BIOP token address
     * @param total the BIOP tokens to transfer into this contract from multisig
     * @param maxEpoch_ total number of reward epochs
     * @param launchTime the length of the launch bonus multiplier (in seconds)
     */
    constructor(address bo_, address token_, uint256 total, uint256 maxEpoch_, uint256 launchTime) public {
      dao = msg.sender;
      lEnd = block.timestamp + launchTime;
      eS = block.timestamp + 30 days;
      tTE = 92857142857142850000000000000;
      maxEpoch = maxEpoch_;//7 was old default
      perE = total.div(maxEpoch_); //amount per epoch
      tTE = total.div(maxEpoch_); 

      token = ERC20(token_);
      token.transferFrom(msg.sender, address(this), total);
    }


    
    modifier onlyBinaryOptions() {
        require(bO == msg.sender, "Ownable: caller is not the Binary Options Contract");
        _;
    }
    modifier onlyDAO() {
        require(dao == msg.sender, "Ownable: caller is not the dao");
        _;
    }

    /** 
     * @dev transfer ownership of this contract
     * @param g_ the new governance address
     */
    function transferGovernance(address payable g_) external onlyDAO {
        require(g_ != 0x0000000000000000000000000000000000000000);
        dao = g_;
    }

    
   


    /**
     * @dev called by the binary options contract to claim Reward for user
     * @param amount the amount in BIOP to add to transfer to this user
     **/
    function updateEarlyClaim(uint256 amount) external onlyBinaryOptions {
        if (lEnd < block.timestamp) {
            require(token.balanceOf(address(this)) >= amount.mul(8), "insufficent balance remaining");
            updateEpoch(amount.mul(8));
            token.transfer(tx.origin, amount.mul(8));
        } else {
            require(token.balanceOf(address(this)) >= amount, "insufficent balance remaining");
            updateEpoch(amount);
            token.transfer(tx.origin, amount);
        }
    }

    //epochs run 30 days. except the final epoch that goes on until rewards run out.
    // unused rewards are rolled over into the next epoch.
    function updateEpoch(uint256 amount) internal {
            require(tTE.sub(amount) >= 0, "insufficent claims avail");
            tTE = tTE.sub(amount);
            if (block.timestamp > eS && epoch < maxEpoch) {
                //every 30 days the next epoch can begin
                epoch = epoch.add(1);
                eS = block.timestamp + 30 days;
                tTE = perE.add(tTE);
            }
    }
     /**
     * @notice one time function used at deployment to configure the connected binary options contract
     * @param options_ the address of the binary options contract
     */
    function setupBinaryOptions(address payable options_) external onlyDAO {
        bO = options_;
    }
}
