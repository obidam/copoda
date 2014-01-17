% validate Validate a transect object
%
% [OUTCOME T] = validate(T,[VERBOSE,FIX,TEST_IDS])
%
% This method is used to validate the transect object T. Within COPODA, 
% the action of validation means:
% 	"Check if expected rules and schemas are respected and
% 	try to fix the object if not".
% In practice, the method performs a serie of tests on transect T.
% A test could be to verify if the depth axis has negative values
% and is sorted from the surface to the bottom. Another test would be
% to check if all data have the same dimension, yet another would be
% to be sure that potential density is defined and available.
% 
% INPUTS:
%	T is a transect object
%	VERBOSE is an optional parameter, it is set to 1 by 
%		default and determines if results are to be 
%		displayed on screen or not.
%	FIX is an optional parameter, it is set to 0 by
%		default and determines if the routine should try
%		to fix the object if a test fails.
%	TEST_IDS indicates which test IDs to perform.
%		By default the method use the list of IDs defined by the configuration
% 		file parameter "transect_validate_default_list_of_tests"
% 
% OUTPUTS:
%	OUTCOME (boolean) is the result of the validation call.
%		The function returns FALSE if any of the tests is an echec.
%	T is the fixed transect object if the option FIX was set to TRUE. It returns
% 		the original transect if FIX is set to FALSE.
%
% TIPS:	
%	validate(transect,'list') % display all available tests
% 	l = validate(transect,'list') % Return a structure with information on tests
%
% Rev. by Guillaume Maze on 2014-01-17: Updated help section. No outputs if not required.
% Rev. by Guillaume Maze on 2013-02-19: Fixed a bug in the identification of invalid test list specified by user
% Rev. by Guillaume Maze on 2011-05-31: Added tests list output when called with 'list' option
% Rev. by Guillaume Maze on 2010-04-26: Now read the test_list from the configuration file
%		property: transect_validate_default_list_of_tests
%		And decide what to return as a result when fixing failed from the configuration file
%		property: transect_validate_result_to_failed_fix
% Created: 2009-07-29.
% http://copoda.googlecode.com
% Copyright 2010, COPODA

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.


function varargout = validate(T,varargin)

% Default parameters and indices:
ierr      = 0;
itest 	  = 0;
ifixed    = 0;
verbose   = 1;
fixe      = 0;
%test_list = [1 3 4 11 9 5 6 7 8 10]; % These are test IDs
test_list = copoda_readconfig('transect_validate_default_list_of_tests');
ntest 	  = 15;

if nargin >= 2
	if ischar(varargin{1})
		switch lower(varargin{1})
			case 'list'
				if nargout == 1
					l = list_all_tests;
					varargout(1) = {l};
					return
				else
					%%% DISPLAY TEST LIST:
					list_all_tests
					return
				end% if 
			case 'default'
				result = copoda_readconfig('transect_validate_default_list_of_tests');
			otherwise
				error('Unknown option')
		end% switch 		
	else
		verbose = varargin{1};
	end
end
if nargin >= 3
	fixe = varargin{2};
	if fixe ~= 0 & fixe ~= 1
		error(sprintf('FIX parameter must be 0 or 1. For more informations type:\nhelp transect/validate'));
	end
end

%%%%%%%%%% Get list of tests with their IDs:
p  = class_home;
di = dir(strcat(p,'private'));
it = 0;
for ii = 1 : length(di)
	if ~di(ii).isdir
		if strfind(di(ii).name,'.m') & strfind(di(ii).name,'test_')
			it = it + 1;
			TEST(it).fct = strrep(di(ii).name,'.m','');
			ID(it) = eval(TEST(it).fct);
		end
	end
end% for ii

if nargin >= 4
	test_list = varargin{3};
	[IDs ids itl] = isin(ID,test_list);
	if length(itl) ~= length(test_list)
		error('Specified test list is invalid');
	end% if 
end% if 

%%%%%%%%%% Run tests:
w = warning; warning on
done = 0; it = 0;
while done ~= 1
	it = it + 1;
	if it > length(test_list)
		done = 1;
	elseif find(ID==test_list(it))
		itest = itest + 1;
		if fixe
			[res msg fixed T] = feval(TEST(find(ID==test_list(it))).fct,T,verbose,fixe);
			if ~res & ~fixed
				disp(sprintf('Warning: This is serious ! you should stop running the validation and try to look at this carefully !\n\tTest: %s\n\tError: %s',msg.test_name,msg.test_result));
%					done = 1; % Uncomment to stop the test list when the test is not passed and could not be fixed
			end
		else
			[res msg fixed] = feval(TEST(find(ID==test_list(it))).fct,T,verbose,fixe);
		end
		RESULTS(itest) = res;
		FIXED(itest) = fixed;
	else
		disp(sprintf('Warning: Test #%i cannot be found, not performed',test_list(it)))
	end
end %while
warning(w(1).state)

%%%%%%%%%% OUTPUTS:
switch fixe
	case 0
		if RESULTS
			result = true;
		else
			result = false;
		end
	case 1
		if RESULTS & FIXED
			result = true;
		elseif RESULTS
%			result = true; % This is cool, it means results is ok even if we didn't fixed all problems
%			result = false; % This ensure an echec if we couldn't fixe the Transect
			result = copoda_readconfig('transect_validate_result_to_failed_fix');
		else
			result = false;
		end
end% switch 
		

switch nargout
	case 1
		varargout(1) = {result};		
		
	case 2
		varargout(1) = {result};		
		if FIXED
			T.modified = now;
			varargout(2) = {T};
		else
			varargout(2) = {T};
		end% if 
end% switch 

end %function



%%%%%%%%%%%%%%%%%%%
function varargout = list_all_tests()

if nargout == 0
	disp('List of tests to validate a transect object:')
end% if 
p  = class_home;
di = dir(strcat(p,'private'));
it = 0;
for ii = 1 : length(di)
	if ~di(ii).isdir
		if strfind(di(ii).name,'.m') & strfind(di(ii).name,'test_')
			it = it + 1;
			TEST(it).fct = strrep(di(ii).name,'.m','');
			[ID(it) NAME(it).val] = eval(TEST(it).fct);
		end
	end
end
[ID ii] = sort(ID);
NAME = NAME(ii);
if nargout == 0
	for it = 1 : length(ID)
		disp_res(sprintf('ID# %i',ID(it)),NAME(it).val{1},1)
		for il = 2 : length(NAME(it).val)
			disp(sprintf('%3s %6s %s',' ',' ',NAME(it).val{il}));
		end
	end
else
	TESTSLIST.description = NAME;
	TESTSLIST.file = TEST;
	TESTSLIST.ID = ID;
	varargout(1) = {TESTSLIST};
end% if 

end%function


%%%%%%%%%%%%%%%%%%%
function varargout = disp_res(name,value,verbose)
	blk = ' ';	
	if verbose == 1
		disp(sprintf('%2s %6s: %s',blk,name,value));	
	else
	end
end %function

%%%%%%%%%%%%%%%%%%%
function p = class_home()
	p = strrep([mfilename('fullpath') '.m'],[mfilename '.m'],'');
end
