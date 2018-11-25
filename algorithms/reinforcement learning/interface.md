`function [policy, time, (optional...)] = <algorithm>(domain, reward)`

* output
	* `policy` - a function which takes a state and returns an action
	* `time`   - a column vector whose sum equals the entire time it took for the algorithm to run
	* `(optional...)` - any number of additional return values desired for an algorithm

* input
	* `domain` - a character vector indicating which domain to reference
	* `reward` - a function which takes a state and returns a decimal