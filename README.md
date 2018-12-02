# KPIRL-KLA
KPIRL is a non-linear extension to Abbeel and Ng's linear [Projection IRL algorithm](https://dl.acm.org/citation.cfm?id=1015430).

KLA is an RL algorithm created specifically to be used with KPIRL in large state/action spaces.

## Installation

1. Clone the repository

## Requirements

* Matlab
	* Statistics and Machine Learning Toolbox (for `pdist` in k_norm.m)
	* Parallel Computing Toolbox (for `parfor` in kla.m )
	
## Directory Structure

* _algorithms_ - contains the algorithm implementationsn included in this repository (many for comparison purposes)
	* _inverse reinforcement learning_
		* _PIRL_ - Projection inverse reinforcemnt learning ([paper](https://dl.acm.org/citation.cfm?id=1015430))
		* _KPIRL_ - Kernel projection inverse reinforcement learning
	* _reinforcement learning_
		* _KLA_ - Kernel lookup approximation
		* _KLSPI_ - Kernel-based least squares policy iteration ([paper](https://ieeexplore.ieee.org/abstract/document/4267723))
		* _LSPI_ - Least-squares policy iteration ([paper](http://www.jmlr.org/papers/v4/lagoudakis03a.html))
* _domains_ - specific problem domain implementations
	* _\<domain name\>_ - folder name unique for each domain
		* _data_ - contains the raw data for the specific domain (no standardization here)
		* _algos_ - contains the necessary function implementations for the various algorithms
		* _work_ - catch all folder for domain specific work/research (no standardization here)
* _shared_ - a collection of utility functions that can be used across domains
	* _kernel_ - implementations of popular kernel methods that can be interchanged for KPIRL
	
## Quick Start

Two example files have been provided in the root directory for a "quick start". These files use the "huge" domain, but could easily be used with any domain. The files are executable "out-of-the-box". Further documentation is provided in-line within the files.

* _qs_compare.m_ - compares the performance of three different RL algorithms in the "huge" domain. To compare performance a number of random reward functions are generated, then a policy is learned for each of these functions using the RL algorithms. Using the learned policies a number of random episodes are generated. Each episode's value is calculated, and the expected value for each RL algorithm is output for comparison.

* _qs_inverse.m_ - uses kpirl on the "huge" domain to calculate the reward function.

* _qs_paths.m_ - adds all required paths to Matlab until the end of the current session

## Algorithm Functions

### KPIRL Functions

	* <domain>_expectations
		* Input:
			* reward -- a function which takes a state and returns a reward value (i.e. @(state) => reward value). The function should be able to take a set of states (represented by a matrix or cell array, [s_1, s_2, s_3 ...]) and return a row vector of rewards ([r_1, r_2, r_3]).
		* Output:
			* expectation -- a column vector whose size equals the number of distinct reward function basii sets for the proposed IRL reward function (this is not necessarily the number of states), and whose rows contain the percentage of time each row basii is visited when following the given reward. For example, if one is learning a reward function for tic-tac-toe, the number of states is 19,683. One set of basii would a dummy variable for every single state. In this case the returned column vector would have 19,683 elements representing the percentage of time in each state when optimally pursuing the passed in reward. Another potential set of basii might simply be the number of spaces filled with the agent's pieces. In this case there would be six basii representations (0-5 marks, or five if one wanted to exclude the zero basii), and the returned expectation column would approximately be 1/6 for each basii since each basii is visited determinstically each game (with some slight variation depending on how quickly games are won or lost and if one goes first or second).
	
	* <domain>_reward_basii
		* Output: 
			* r_i -- a function that takes a matrix or cell array of state(s) and returns a row vector containing the basii index for the state(s)
			* r_p -- a matrix whose columns contain all reward basii representations. 
		* Notes:
			* The basii representation for a given state can be retrieved by combining the returns (i.e. reward_basii_for_state = r_p(:,r_i(state)) ).
			
	* <domain>_trajectories
		* Output:
			* trajectories -- a cell array of expert trajectories. Trajectories can be represented as either a matrix, whose column vectors are states or as a cell array themselves. (i.e., trajectories = {trajectory_1, trajectory_2, ...} and trajectory_1 = <[s_1, s_2, ...] | {s_1, s_2, ...}>)
		
	* <domain>_paramaters
		* Input:
			* p_in -- an optional struct that will be used to change the existing paramaters. If not passed in the current settings are returned.
		* Output:
			* p_out -- a struct which contains the paramaters for the various algorithms. This function needs to persist the paramters from call to call in order to work properly. The example domains do this via matlab's `persistent` command though it could be done other ways if necessary.

### KLA Functions

	* \<domain\>_actions
	* \<domain\>_random
	* \<domain\>_transitions
	* \<domain\>_value_basii
	* \<domain\>_paramaters

### LSPI Functions

	* Look at the README file in the LSPI algorithm folder

### KLSPI Functions
	
	* All the standard LSPI functions (see above referenced README)
	* \<domain\>_value_basii_klspi