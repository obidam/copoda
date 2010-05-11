% validate Try to validate a database object
%
% [TF Dfixed] = validate(D,[VERBOSE,FIX,TEST_LIST])
% 
% Try to validate the database object D through a
% list of different tests.
%
% Inputs:
%	D is a database object
%	VERBOSE is an optional parameter, it is set to 1 by 
%		default and determine if results are to be 
%		displayed on screen.
%	FIX is an optional parameter, it is set to 0 by
%		default and determine if the routine should try
%		to fix the error.
% Outputs:
%	TF is the boolean result of all tests (TRUE/FALSE)
%	Dfixed is the new database object with errors fixed
%	
% List of tests:
%	#1: validate each transects with the transect/validate method
%	#2: sort transects by date
%	#3: remove duplicate stations (same latitude, longitude and dates).
%
% See also:
%	transect/validate
%	
% List of tests:
%	type:  validate(D,'list') or validate(database,'list')
%
% Created: 2010-02-11.
% http://code.google.com/p/copoda
% Copyright (c)  2010, COPODA

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


function [result varargout] = validate(D,varargin)

% Default parameters and indices:
ierr      = 0;
itest 	  = 0;
ifixed    = 0;
verbose   = [1 0];
fixe      = 1;
test_list = [3 2 1]; 
ntest 	  = 3;

if nargin >= 2
	if ischar(varargin{1})
		%%% DISPLAY TEST LIST:
		list_all_tests
		result = false;
		return
	else
		verbose = varargin{1};
		if length(verbose==1)
			verbose = [verbose 0];
		end
	end
end
if nargin >= 3
	fixe = varargin{2};
	if fixe ~= 0 & fixe ~= 1
		error(sprintf('FIX parameter must be 0 or 1. For more informations type:\nhelp database/validate'));
	end
end
if nargin >= 4
	test_list = varargin{3};
	if find(test_list>ntest) | find(test_list<0)
		error('Specified test list is invalid');
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
			[ID(it) NAME(it).desc NAME(it).name]= eval(TEST(it).fct);
		end
	end
end

%%%%%%%%%% Run tests:
w = warning; warning on
done = 0; it = 0;
while done ~= 1
	it = it + 1;
	if it > length(test_list)
		done = 1;
	elseif find(ID==test_list(it))
		idt = find(ID==test_list(it));
		itest = itest + 1;
		disp(sprintf('Performing test #%i: %s',test_list(it),NAME(idt).name));
		if fixe
			[res fixed D msg] = feval(TEST(idt).fct,D,verbose,fixe);
			if ~res & ~fixed
				disp(sprintf('Warning: This is serious ! you should stop running the validation and try to look at this carefully !'));
%					done = 1; % Uncomment to stop the test list when the test is not passed and could not be fixed
			end
		else
			[res fixed] = feval(TEST(idt).fct,D,verbose,fixe);
		end
		RESULTS(itest) = res;
		FIXED(itest) = fixed;
	else
		disp(sprintf('Warning: Test #%i cannot be found, not performed',test_list(it)))
	end
end %while
warning(w(1).state)

%keyboard

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
			result = true; % This is cool, it means results is ok even if we didn't fixed all problems
		else
			result = false;
		end
end			


if nargout == 2
	if FIXED
		D.modified = now;
		varargout(1) = {D};
	else
		varargout(1) = {D};
	end
end

end %function



%%%%%%%%%%%%%%%%%%%
function list_all_tests()
	disp('List of tests to validate a database object:')
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
for it = 1 : length(ID)
	disp_res(sprintf('ID# %i',ID(it)),NAME(it).val{1},1)
	for il = 2 : length(NAME(it).val)
		disp_res('',NAME(it).val{il},1)
	end
end

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
