# KPIRL-KLA
KPIRL is a non-linear extension to Abbeel and Ng's linear [Projection IRL algorithm](https://dl.acm.org/citation.cfm?id=1015430).

KLA is an RL algorithm created specifically to be used with KPIRL in large state/action spaces.

## Installation

1. Clone the repository

## Requirements

* Matlab
	* Statistics and Machine Learning Toolbox (for `pdist` in k_norm.m)
	* Parallel Computing Toolbox (for `parfor` in kla.m and trajectories_from_simulations.m)
	
## Directory Structure

* _algorithms_ - contains all algorithm implementations (many of the implemented algorithms are for comparison purposes only)
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
	* _kernel_ - implementations of popular kernel methods that can be used with KPIRL
	* _basis_ - utility functions to turn features into the basis forms required by the algorithms
	
## Quick Start

Two example files have been provided in the root directory for a "quick start". These files use the "huge" domain, but could easily be used with any domain. The files should be executable "out-of-the-box". Further documentation is provided in-line within the files.

* _qs_compare.m_ - compares the performance of three different RL algorithms in the "huge" domain. To compare performance a number of random reward functions are generated, then a policy is learned for each of these functions using the RL algorithms. Using the learned policies a number of random episodes are generated. Each episode's value is calculated, and the expected value for each RL algorithm is output for comparison.

* _qs_inverse.m_ - uses kpirl on the "huge" domain to calculate the reward function.

* _qs_paths.m_ - adds all required paths to Matlab for the duration of the current session

## Algorithm Functions

### KPIRL Functions
	
	* <domain>_reward_basis
		* Input:
			* there is no input for this function
		* Output:
			* r_i -- a function that can:
				* take no input and return the number of basis combinations
				* take a matrix of states and return a row vector of the basis index for each state
				* take a cell array of states and return a row vector of the basis index for each state
			* r_p -- a function that can:
				* take no input and return the number of basis features
				* take a matrix of states or basis indexes and return a matrix of basis features
				* take a cell array of states or basis indexes and return a matrix of basis features
		* examples:
			* given a state _s_ the following predicate is always true `r_p(_s_) == r_p(r_i(_s_))`
			* to get all potential basis permutations one can do `r_p(1:r_i())`
			* to get a random basis permutation one can do `r_p(randi(r_i()))`
			* to pre-allocate a basis matrix for _n_ states one could do `zeros(r_p(), _n_)`

			
	* <domain>_reward_trajectories
		* Input:
			* reward -- a function which takes a state and returns a reward value (i.e. @(state) => reward value). The function should be able to take a set of states (represented by a matrix or cell array, [s_1, s_2, s_3 ...]) and return a row vector of rewards ([r_1, r_2, r_3]).
		* Output:
			* trajectories -- a cell array of optimal trajectories when following the given reward function. Trajectories can be represented as either a matrix, whose column vectors are states or as a cell array themselves. (i.e., trajectories = {trajectory_1, trajectory_2, ...} and trajectory_1 = <[s_1, s_2, ...] | {s_1, s_2, ...}>). In order to get an accurate understanding of how the reward function effects behavior the trajectories should be generated using randomly selected initial state within the MDP.

	* <domain>_expert_trajectories
		* Output:
			* trajectories -- a cell array of observed expert trajectories. Trajectories can be represented as either a matrix, whose column vectors are states or as a cell array themselves. (i.e., trajectories = {trajectory_1, trajectory_2, ...} and trajectory_1 = <[s_1, s_2, ...] | {s_1, s_2, ...}>)
		
	* <domain>_parameters
		* Input:
			* p_in -- an optional struct that will be used to change the existing parameters. If not passed in the current settings are returned.
		* Output:
			* p_out -- a struct which contains the parameters for the various algorithms. This function needs to persist the paramters from call to call in order to work properly. The example domains do this via matlab's `persistent` command though it could be done other ways if necessary.

### KLA Functions

	* \<domain\>_actions
	* \<domain\>_random
	* \<domain\>_transitions
	* \<domain\>_value_basis
	* \<domain\>_parameters

### LSPI Functions

	* Look at the README file in the LSPI algorithm folder

### KLSPI Functions
	
	* All the standard LSPI functions (see above referenced README)
	* \<domain\>_value_basis_klspi