# IRL Interface

The IRL interface is defined as follows:

	function [reward, time, (optional...)] = <algorithm name>(domain)
	
Where the input and output paramaters are as follows:

		* output parameters
			* reward - a function which takes a state and returns a decimal
			* time - a column vector whose sum equals the entire time it took for the algorithm to run
			* (optional...) - any number of additional return values desired for an algorithm

		* input parameters
			* domain - a character string indicating which domain is being solved