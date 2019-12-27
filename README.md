# KPIRL-KLA

* KPIRL is a non-linear extension to Abbeel and Ng's linear [Projection IRL algorithm](https://dl.acm.org/citation.cfm?id=1015430).
* KLA is an RL algorithm created specifically to be used with KPIRL in large state/action spaces.

In addition to the above two algorithms PIRL, LSPI and KLSPI have also been implemented for comparison purposes.

## Installation

1. Clone the repository

## Requirements

* Matlab
	* Statistics and Machine Learning Toolbox (for `pdist` in k_norm.m)
	* Parallel Computing Toolbox (for `parfor` throughout the repository)
	
## Directory Structure

```
algorithms - contains all algorithm implementations (many algorithms are for comparison purposes only)
└---inverse reinforcement learning
|   └---pirl - Projection inverse reinforcemnt learning ([paper](https://dl.acm.org/citation.cfm?id=1015430))
|   └---kpirl - Kernel projection inverse reinforcement learning
|           kpirl_spd - an implementation of the KPIRL algorithm that has been optimized for speed but loads all reward feature vectors into memory
|           kpirl_mem - an implementation of the KPIRL algorithm that has been optimized for memory by only loading reward feature vectors into memory when needed.
└---reinforcement learning
    └---kla - Kernel lookup approximation
    |       kla_spd - an implementation of the KLA algorithm that has been optimized for speed but loads all value feature vectors into memory
    |       kla_mem - an implementation of the KLA algorithm that has been optimized for memory by only loading value feature vectors into memory when needed.
    └---lspi - Least-squares policy iteration ([paper](http://www.jmlr.org/papers/v4/lagoudakis03a.html))
    └---klspi - Kernel-based least squares policy iteration ([paper](https://ieeexplore.ieee.org/abstract/document/4267723))
* _domains_ - specific problem domain implementations
	* _\<domain name\>_ - folder name unique for each domain
		* _data_ - contains the raw data for the specific domain (no standardization here)
		* _algos_ - contains the necessary function implementations for the various algorithms
		* _work_ - catch all folder for domain specific work/research (no standardization here)
* _shared_ - a collection of utility functions that can be used across domains
	* _kernel_ - implementations of popular kernel methods that can be used with KPIRL
	* _features_ - utility functions to create indexed features for algorithm implementations
	* _analysis_ - utility methods written to benchmark the performance of RL algorithms
	* _utilities_ - general purpose utility methods
```
	
## Quick Start

Two example files have been provided in the root directory for a "quick start". These files use the "huge" domain, but could easily be used with any domain. The files should be executable "out-of-the-box". Further documentation is provided in-line within the files.

* _qs_compare.m_ - compares the performance of three different RL algorithms in the "huge" domain. To compare performance a number of random reward functions are generated, then a policy is learned for each of these functions using the RL algorithms. Using the learned policies a number of random episodes are generated. Each episode's value is calculated, and the expected value for each RL algorithm is output for comparison.
* _qs_inverse.m_ - uses kpirl on the "huge" domain to determine a reward function.


## Algorithm Functions

These methods need to be implemented in order to use any of this repository's algorithms on a new domain.

### KPIRL Functions
	
	* <domain>_reward_features
		* Input:
			* there is no input for this function
		* Output:
			* r_i -- a function with the following behavior:
				* given nothing return the count of feature vectors
				* given states return a row vector containing the feature index for each state
			* r_p -- a function with the following behavior:
				* given nothing return the count of features
				* given states return a matrix whose columns are the feature vectors for each state
				* given indexes return a matrix whose columns are the feature vectors for the indexes
		* examples:
			* given a state _s_ the following predicate should always true `r_p(_s_) == r_p(r_i(_s_))`
			* to get all feature vectors one can do `r_p(1:r_i())`
			* to get a random feature vector one can do `r_p(randi(r_i()))`
			* to pre-allocate a matrix for _n_ feature vectors one could do `zeros(r_p(), _n_)`
			
	* <domain>_reward_episodes
		* Input:
			* reward -- a function which takes a state and returns a reward value (i.e. @(state) => reward value). The function should be able to take a set of states (represented by a matrix or cell array, [s_1, s_2, s_3 ...]) and return a row vector of rewards ([r_1, r_2, r_3]).
		* Output:
			* episodes -- a cell array of near-optimal episodes for the given reward function. Individual episodes can be represented as either a matrix, whose column vectors are states, or as a cell array (i.e., episodes = {episode_1, episode_2, ...} and episode_1 = <[s_1, s_2, ...] | {s_1, s_2, ...}>).

	* <domain>_expert_episodes
		* Input:
			* there is no input for this function
		* Output:
			* episodes -- a cell array of observed expert episodes. Individual episodes can be represented as either a matrix, whose column vectors are states, or as a cell array (i.e., episodes = {episode_1, episode_2, ...} and episode_1 = <[s_1, s_2, ...] | {s_1, s_2, ...}>). 
		
	* <domain>_parameters
		* Input:
			* p_in -- a struct that will be used to change the current parameters. This input is optional. Without it the current parameter struct will be returned unchanged.
		* Output:
			* p_out -- a struct containing the parameters for the current domain. This function needs to persist the paramters from call to call in order to work properly. The example domains do this via matlab's `persistent` command though it could be done other ways if necessary.
		* Parameters
			* kernel -- the kernel function to use when learning the KPIRL reward function (e.g., kernel = @(x,y) x'*y)
			* gamma -- the discount amount to use when calculating the state visitation expectation
			* epsilon -- the amount of convergence that needs to be observed before exiting the algorithm

### KLA Functions

	* \<domain\>_actions()
		* Input:
			* there is no input for this function
		* Output:
			* a_f -- a function which accepts a single state and returns the collection of valid actions for that state.

	* \<domain\>_initiator()
		* Input:
			* there is no input for this function
		* Output:
			* s_1 -- a function which accepts no inputs and returns a random state (used to begin new episodes during policy iteration).

	* \<domain\>_transitions
		* Input:
			* there is no input for this function
		* Output:
			* t_p -- a function with the following behavior:
				* given a state and collection of actions (e.g., `t_p(s, a_f(s))`) return a collection of post decision states. In traditional Q-Learning the post decision state would be (s,a) though it can be more compact.
			* t_s -- a function that can:
				* given a collection of post-decision states return a collection of random pre-decision states according the transition probabilities of the MDP.
				* given a state and a collection of actions return a collection of random pre-decision states according the transition probabilities of the MDP.
	* \<domain\>_value_features
		* Input:
			* there is no input for this function
		* Output:
			* v_i -- a function with the following behavior:
				* given nothing return the count of feature vectors
				* given states return a row vector containing the feature index for each state
			* v_p -- a function with the following behavior:
				* given nothing return the count of features
				* given states return a matrix whose columns are the feature vectors for each state
				* given indexes return a matrix whose columns are the feature vectors for the indexes
		* examples:
			* given a state _s_ the following predicate should always true `v_p(_s_) == v_p(v_i(_s_))`
			* to get all feature vectors one can do `v_p(1:v_i())`
			* to get a random feature vector one can do `v_p(randi(v_i()))`
			* to pre-allocate a matrix for _n_ feature vectors one could do `zeros(r_p(), _n_)`

	* \<domain\>_parameters
		* Input:
			* p_in -- a struct that will be used to change the current parameters. This input is optional. Without it the current parameter struct will be returned unchanged.
		* Output:
			* p_out -- a struct containing the parameters for the current domain. This function needs to persist the paramters from call to call in order to work properly. The example domains do this via matlab's `persistent` command though it could be done other ways if necessary.
		* Parameters
			* N -- the number of policy iterations to perform
			* M -- the number of episodes to generate during policy evaluation
			* W -- the number of observations per episode to make during policy evalution
			* T -- the number of steps to use when making an observation during policy evaluation			
			* gamma -- the amount of reward discount to use when learning an optimal value function

### LSPI Functions

	* Look at the README file in the LSPI algorithm folder

### KLSPI Functions
	
	* All the standard LSPI functions (see above referenced README)
	* \<domain\>_value_basis_klspi