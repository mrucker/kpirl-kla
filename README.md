## KPIRL-KLA

This repository implements several RL and IRL algorithm via a consistent interface. 

Three example problem "domains" utilizing the algorithms are included in the project.

The "huge" domain corresponds to the experiments and models described in the original KPIRL ([paper](https://arxiv.org/abs/2002.10904))

## Installation

1. Clone the repository

## Requirements

* Matlab
	* Statistics and Machine Learning Toolbox (for `pdist2` in k_gauss.m)
	* Parallel Computing Toolbox (for `parfor` throughout the repository)

## Quick Start

Two files have been provided in the root for a "quick start". The files should be executable "out-of-the-box". These files use the "huge" domain, but could easily be used with any domain. Further documentation is provided in-line within the files.

* **qs_compare.m** - compares RL algorithms in the "huge" domain using the benchmarking API described below
* **qs_inverse.m** - solves for the reward function using KPIRL in the "huge" domain

## Architecture Principles/Tradeoffs

This repository was designed primarily for understandability and extensibility. Towards this end, the code leans heavily on MATLAB's closure functionality to preserve state while reducing dependencies. One consequence of this decision is a reduction in vectorization and an increase in function calls. Taken together this means there is room for considerable compute improvement with a different implementation.

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
|       └---kernels  - contains custom made kernels for the specific problem domain
|       └–––work - catch all folder for domain specific work/research (no standardization here)
└–––shared - a collection of utility functions that can be used across domains
        └–––kernels - implementations of popular kernel methods
        └–––features - utility methods to create indexed features
        └–––analysis - utility methods to benchmark algorithm performance
        └–––utilities - utility methods
```

## Algorithms

This repository contains five algorithm implementations:

1. KLA - kernel lookup approximation (This is similar to [Neural Episodic Control](http://proceedings.mlr.press/v70/pritzel17a.html)))
2. LSPI - least-squares policy iteration ([paper](http://www.jmlr.org/papers/v4/lagoudakis03a.html))
3. KLSPI - kernel-based least squares policy iteration ([paper](http://www.jmlr.org/papers/v4/lagoudakis03a.html))
4. PIRL - projection inverse reinforcemnt learning ([paper](https://dl.acm.org/citation.cfm?id=1015430))
5. KPIRL - kernel projection inverse reinforcemnt learning ([paper](https://arxiv.org/abs/2002.10904))
	
Most of the algorithm implementations have two versions: 

1. a memory efficient version (`_mem`) that runs slower but only loads features into memory as needed
2. a compute efficient version (`_spd`) that runs faster but loads all features into memory upfront

Additionally, a high-level interface is defined for both [IRL](https://github.com/mrucker/kpirl-kla/blob/master/algorithms/inverse%20reinforcement%20learning/) and [RL](https://github.com/mrucker/kpirl-kla/blob/master/algorithms/reinforcement%20learning/) algorithms for seamless benchmarking. The interfaces are documented in the respective `/algorithms/inverse reinforcement learning/interface.md` and `/algorithms/reinforcement learning/interface.md` files.
	
## Algorithm Methods

The algorithm implementations expect the following domain specific method implementations

	* lspi and klspi
		* \<domain\>_actions
		* \<domain\>_transitions
		* \<domain\>_features
		* \<domain\>_parameters

	* kla
		* \<domain\>_actions
		* \<domain\>_transitions
		* \<domain\>_features
		* \<domain\>_discrete
		* \<domain\>_parameters
			
	* kpirl and pirl
		* \<domain\>_episodes
		* \<domain\>_features
		* \<domain\>_discrete
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
			* s2s = a function with the following behavior:
				* given nothing return a random state (used to initialize new episodes for statistical sampling)
				* given a collection of post-decision states return a random pre-decision state for each post-decision state according the transition probabilities of the MDP.
				* given a state and a collection of actions return a random pre-decision state for each action according the transition probabilities of the MDP.
			* s2p = a function with the following behavior:
				* given a state and a collection of actions return a post-decision state for each action. (If one wants traditional Q-Learning the post-decision state should be (s,a))

	* \<domain\>_features
		* Input:
			* a string indicating whether the features are being used to approximate a reward or value function 
		* Output:
			* a function that accepts a collection of either pre-decision or post-decision states and returns a feature vector for each state
			
	* \<domain\>_discrete
		* Input:
			* a string indicating whether the features are being used to approximate a reward function or value function
		* Output:
			* edges = a cell array of edges used to discretize state features (discretization is necessary for kla and kpirl only)
			* partitions = a cell array of edge indexes which define partitions. By default all edges belong to one partition.
			
	* \<domain\>_episodes
		* Input:
			* there is no input for this function
		* Output:
			* r2e = a function with the following behavior:
				* given nothing return a cell array of observed expert trajectories for IRL
				* given a reward return sample trajectories that are approximately optimal

	* \<domain\>_parameters
		* Input:
			* p_in -- a struct that will be used to change the current parameters. This input is optional. Without it the current parameter struct will be returned unchanged.
		* Output:
			* p_out -- a struct containing the parameters for the current domain. This function should persist the paramters from call to call in order to work properly. The example domains do this via matlab's `persistent` command though it could be done other ways if necessary.

## Algorithm Parameters

Each of the above algorithms expects the following parameters to be defined

	* kla
		* N -- the number of policy iterations to perform
		* M -- the number of episodes per policy iteration for policy evaluation
		* T -- the number of steps per episode-observation for policy evaluation
		* W -- the number of episode-observations per episode for policy evalution
		* gamma -- the amount of reward discount to use when calculating value functions
		* v_kernel -- the kernel method to use when approximating the value function (e.g., kernel = `@(x,y) x'*y`)

	* lspi
		* N -- the number of policy iterations to perform
		* M -- the number of episodes per policy iteration for policy evaluation
		* T -- the number of steps per episode for policy evaluation
		* gamma -- the amount of reward discount to use when calculating value functions
		* resample -- determines if the sarsa samples are recreated on each policy iteration or simply updated

	* klspi
		* all of lspi
		* mu -- pruning level in the approximate linear dependence analysis. The higher the value the more is pruned.
		* v_kernel -- the kernel method to use when approximating the value function (e.g., kernel = `@(x,y) x'*y`)
		

	* pirl
		* epsilon -- the termination condition for the pirl reward iterations
		* gamma -- the amount of discount to use when calculating feature expectations

	* kpirl
		* all of pirl
		* r_kernel -- the kernel method to use when approximating the reward function (e.g., kernel = `@(x,y) x'*y`)
	
	
## Benchmarking/Analysis API

The repository also contains a custom made benchmarking API. This API follows a pipeline architecture with pseudo-code:

	* (random-rewards | to-policies | to-attributes) | group-by 'algorithm', 'policy-iteration' | to-statistics | to-output

Implemented examples can be seen in `qs_compare.m`, `huge_policy_compare.m` or `huge_policies_compare.m`
	
To start the pipline the API has two root methods, one of which needs to be called with appropriate parameters

	* analyze_policy -- processes the pipeline and creates outputs for only the final policy iteration
	* analyze_policies -- processes the pipeline and creates outputs for all policy iterations

The following `to-policies` are implemented:
	
	*KLA, KLSPI, LSPI (any RL algorithm is usable as long as it conforms to the RL interface described above)
	
The following `to-attributes` are implemented:

	* policy_iteration_index -- the index of the policy iteration (this is only relevant for policy iteration algorithms)
	* policy_iteration_time -- the amount of time spent on the current iteration of policy iteration
	* policy_time -- the amount of time spent in total to generate a policy (i.e., including time spent on all previous iterations)
	* policy_value -- uses monte carlo methods to estimate the expected value of a policy
	* reward_index -- the index of the random reward (used to compare policies directly across algorithms)

The following `to-statistics` are implemented:

	* avg -- the average of all attributes grouped by algorithm and policy iteration (meaningless for index attributes)
	* med -- the average of all attributes grouped by algorithm and policy iteration (meaningless for index attributes)
	* SEM -- the standard error of the mean (i.e., sqrt([Var of attribute]/[reward count])) (meaningless for index attributes)

The following `to-output` are implemented:

	* attributes_to_file -- writes a flat CSV file with all selected attributes, ignoring any desired statistics
	* statistics_to_screen -- writes a flat CSV with all selected statistics of the selected attributes
