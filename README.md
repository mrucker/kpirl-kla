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
		* _KPIRL_ - Kernel projection inverse reinforcement learning
	* _reinforcement learning_
		* _KLA_ - Kernel lookup approximation
		* _KLSPI_ - Kernel-based least squares policy iteration
		* _LSPI_ - Least-squares policy iteration	
* _domains_ - specific problem domain implementations
	* _\<domain name\>_ - folder name unique for each domain
		* _data_ - contains the raw data for the specific domain (no standardization here)
		* _algos_ - contains the necessary function implementations for the various algorithms
		* _work_ - catch all folder for domain specific work/research (no standardization here)
* _shared_ - a collection of utility functions that can be used across domains
	* _kernel_ - implementations of popular kernel methods that can be interchanged for KPIRL
	
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


