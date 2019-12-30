## KPIRL-KLA

This repository implements two new RL/IRL algorithms and compares them to existing RL/IRL algorithms across three different problem domains.

## Installation

1. Clone the repository

## Requirements

* Matlab
	* Statistics and Machine Learning Toolbox (for `pdist` in k_norm.m)
	* Parallel Computing Toolbox (for `parfor` throughout the repository)

## Quick Start

Two files have been provided in the root for a "quick start". The files should be executable "out-of-the-box". These files use the "huge" domain, but could easily be used with any domain. Further documentation is provided in-line within the files.

* **qs_compare.m** - compares the performance of five RL algorithms in the "huge" domain. To compare performance a number of random reward functions are generated, then a policy is learned for each of these functions using the RL algorithms. Using the learned policies a number of random episodes are generated. Each episode's value is calculated, and the expected value for each RL algorithm is output for comparison.
* **qs_inverse.m** - uses kpirl on the "huge" domain to determine a reward function.

## Architecture Principles/Tradeoffs

This repository was designed primarily for understandability and extensibility. Because of this the code leans heavily on MATLAB's closure functionality to preserve state while reducing dependencies. A consequence of this decision is less vectorization and more function calls. This means there is room for considerable compute improvement with a different implementation.

## Directory Structure

```
root
└–––algorithms - contains all algorithm implementations
|   └–––inverse reinforcement learning
|   |   └–––kpirl (pirl)
|   └–––reinforcement learning
|       └–––kla
|       └–––klspi (lspi)
└–––domains_- specific problem domain implementations
|   └–––\<domain\> - a separate folder for each domain
|       └–––algos - contains the domain specific methods for the various algorithms
|       └–––data - contains the raw data for the specific domain (no standardization here)
|       └–––work - catch all folder for domain specific work/research (no standardization here)
└–––shared - a collection of utility functions that can be used across domains
        └–––kernel - implementations of popular kernel methods
        └–––features - utility methods to create indexed features
        └–––analysis - utility methods to benchmark algorithm performance
        └–––utilities - utility methods
```

## Algorithms

This repository contains five algorithm implementations:

1. KLA - kernel lookup approximation
2. LSPI - least-squares policy iteration ([paper](http://www.jmlr.org/papers/v4/lagoudakis03a.html))
3. KLSPI - kernel-based least squares policy iteration ([paper](http://www.jmlr.org/papers/v4/lagoudakis03a.html))
4. PIRL - projection inverse reinforcemnt learning ([paper](https://dl.acm.org/citation.cfm?id=1015430))
5. KPIRL - kernel projection inverse reinforcemnt learning
	
Most of the algorithm implementations have two versions: 

1. a memory efficient version (`_mem`) that runs slower but only loads features into memory as needed
2. a compute efficient version (`_spd`) that runs faster but loads all features into memory upfront
	
## Algorithm Methods

The algorithm implementations expect the following domain specific method implementations

	* kla, lspi and klspi
		* \<domain\>_actions
		* \<domain\>_transitions
		* \<domain\>_features
		* \<domain\>_parameters
			
	* kpirl and pirl
		* \<domain\>_features
		* \<domain\>_episodes
		* \<domain\>_parameters
	
Where the above methods are defined as

	* \<domain\>_actions
		* Input:
			* there is no input for this function
		* Output:
			* a function which accepts a single state and returns the collection of valid actions for that state

	* \<domain\>_transitions
		* Input:
			* there is no input for this function
		* Output:
			* t_s = a function with the following behavior:
				* given nothing return a random state (used to initialize new episodes for statistical sampling)
				* given a collection of post-decision states return one random pre-decision state for each post-decision state according the transition probabilities of the MDP.
				* given a state and a collection of actions return one random pre-decision state for each action according the transition probabilities of the MDP.
			* t_p = a function that is given a state and a collection of actions and that returns a post-decision state for each given action. (In traditional Q-Learning the post-decision state would be (s,a) though it can be more compact.)

	* \<domain\>_features
		* Input:
			* a string indicating whether the features are being used to approximate a reward function or value function
		* Output:
			* v_p = a function with the following behavior:
				* given nothing return the count of features
				* given states return a matrix whose columns are the feature vectors for each state
				* given indexes return a matrix whose columns are the feature vectors for the indexes
			* v_i = a function with the following behavior:
				* given nothing return the count of feature vectors
				* given states return a row vector containing the feature index for each state
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

## Algorithm Parameters

Each of the above algorithms expects the following parameters to be defined

	* kla
		* N -- the number of policy iterations to perform
		* M -- the number of episodes to generate during policy evaluation
		* T -- the number of steps to use when making an observation during policy evaluation
		* W -- the number of observations per episode to make during policy evalution
		* gamma -- the amount of reward discount to use when calculating value functions

	* lspi
		* N -- the number of policy iterations to perform
		* M -- the number of episodes to generate during policy evaluation
		* T -- the number of steps to use when making an observation during policy evaluation
		* gamma -- the amount of reward discount to use when calculating value functions
		* resample -- determines if the sarsa samples are recreated on each policy iteration or simply updated
	* klspi
		* all of lspi
		* kernel -- the kernel method to use when approximating the value function (e.g., kernel = `@(x,y) x'*y`)
		* mu -- pruning level in the approximate linear dependence analysis. The higher the value the more is pruned.
	* pirl
		* epsilon -- the termination condition for the pirl reward iterations
		* gamma -- the amount of reward discount to use when calculating value functions
	* kpirl
		* all of pirl
		* kernel -- the kernel method to use when approximating the reward function (e.g., kernel = `@(x,y) x'*y`)
	