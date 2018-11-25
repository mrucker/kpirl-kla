# KPIRL-KLA
KPIRL is a non-linear extension to Abbeel and Ng's linear [Projection IRL algorithm](https://dl.acm.org/citation.cfm?id=1015430).

KLA is an RL algorithm created specifically to be used with KPIRL in large state/action spaces.

## Installation

1. Clone the repository

## Requirements

1. Matlab
	1. Statistics and Machine Learning Toolbox (for `pdist` in k_norm.m)
	2. Parallel Computing Toolbox (for `parfor` in kla.m )
	
## Directory Structure

* __algorithms__ - contains the algorithm implementationsn included in this repository (many for comparison purposes)
	* __inverse reinforcement learning__
		* __KPIRL__ - Kernel projection inverse reinforcement learning
	* __reinforcement learning__
		* __KLA__ - Kernel lookup approximation
		* __KLSPI__ - Kernel-based least squares policy iteration
		* __ LSPI__ - Least-squares policy iteration	
* __domains__ - specific problem domains that have been implemented to use the algorithms
	* __<domain name>__ - unique for each domain
		* __data__ - contains the raw data for the specific domain (no standardization here)
		* __algos__ - contains the necessary function implementations for the various algorithms
		* __work__ - catch all folder for domain specific work/research (no standardization here)
* __shared__ - a collection of utility functions that can be used across domains
	* __kernel__ - implementations of popular kernel methods that can be interchanged for KPIRL
	
## Quick Start

Two example files have been provided in the root directory for a "quick start". These files use the "huge" domain but could easily be used in new domains. The files should be executable out-of-the-box without any modification. Further documentation is provided in-line within the files.

* example_compare.m -- this file compares the performance of three different RL algorithms in the "huge" domain. To compare performance a number of random reward functions are generated, then a policy is learned for each of these functions using the RL algorithms. Using the learned policies a number of random episodes are generated. Each episode's value is calculated, and the expected value for each RL algorithm is output for comparison.

* example_inverse.m -- this files shows how to use kpirl to calculate the reward function for the "huge" domain.

* paths.m -- temporarily adds all required paths to Matlab (these persist only to the ned of the current session, so the Path space isn't polluted)

## Algorithm Functions

### KPIRL Functions

	* 

### KLA Functions

### LSPI Functions

### KLSPI Functions


