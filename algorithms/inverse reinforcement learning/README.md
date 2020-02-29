# IRL Interface

The IRL interface is defined as follows:

	function [reward, time, (optional...)] = <algorithm>(domain)`
		* output
			* `reward` - a function which takes a state and returns a decimal
			* `time`   - a column vector whose sum equals the entire time it took for the algorithm to run
			* `(optional...)` - any number of additional return values desired for an algorithm

		* input
			* `domain` - a character string indicating which domain to reference