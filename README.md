# KPIRL-KLA
KPIRL is a non-linear extension to Abbeel and Ng's linear [Projection IRL algorithm](https://dl.acm.org/citation.cfm?id=1015430).

KLA is an RL algorithm created specifically to be used with KPIRL in large state/action spaces.

## Installation

1. Clone the repository

## Requirements

1. Matlab
	1. Statistics and Machine Learning Toolbox (for the `pdist` in k_norm.m)
	2. Parallel Computing Toolbox (for `parfor` in kla.m )
	
## Project Structure

* algorithms -- contains the algorithm implementationsn included in this repository (many for comparison purposes)
	* Kernel projection inverse reinforcement learning (KPIRL)
	* Kernel Lookup Approximation (KLA)
	* Least Squares Policy Iteration (LSPI)
	* Kernel Least Squares Policy Iteration (KLSPI)
* domains -- specific problem domains that have been implemented to use the algorithms
	* data -- contains the raw data for the specific domain (no standardization here)
	* algos -- contains the necessary function implementations for the various algorithms
	* work -- catch all folder for domain specific work/research (no standardization here)
*shared -- a collection of utility functions that can be used across domains
	* kernel -- implementations of popular kernel methods that can be interchanged in KPIRL
	
## Quick Start

Two example files have been provided in the root directory for a "quick start". These files use the "huge" domain but could easily be used in new domains. The files should be executable out-of-the-box without any modification. Further documentation is provided in-line within the files.

* example_compare.m -- this file compares the performance of three different RL algorithms in the "huge" domain. To compare performance a number of random reward functions are generated, then a policy is learned for each of these functions using the RL algorithms. Using the learned policies a number of random episodes are generated. Each episode's value is calculated, and the expected value for each RL algorithm is output for comparison.

* example_inverse.m -- this files shows how to use kpirl to calculate the reward function for the "huge" domain.

* paths.m -- temporarily adds all required paths to Matlab (these persist only to the ned of the current session, so the Path space isn't polluted)

## Algorithm Functions

### KPIRL Functions

### KLA Functions

### LSPI Functions

### KLSPI Functions


