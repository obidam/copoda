% test_fields test #4
%
% [] = test_fields()
% 
% Check if all transects have similar fields (data)
%
% Created: 2012-06-04.
% http://code.google.com/p/copoda
% Copyright 2012, COPODA

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

% Category for documentation:
%CAT 
% Method's type for documentation:
%TYP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = test_fields(varargin)
	
test_name = 'Check data definitions consistency among transects';
test_desc = {'Check if all transects have similar defined data'};
res   = false;
fixed = false;
switch nargin
	case 0
		varargout(1) = {4}; % ID of the test
		varargout(2) = {test_desc};
		varargout(3) = {test_name};
		return
	otherwise
		D		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end	
msg(1).test_name   = test_name;
domore = true;

%
nT  = length(D);
if nT == 1
	disp_res('Result','OK, because only one transect in the database !',verbose(1))
	res = true;
	fixed = true;
	domore = false;
end% if 

switch domore
	case false
	case true
		res = true;
		fixed = true;
		T = subsref(D,substruct('()',{1})); 
		dat0 = datanames(T);
		geo0 = fieldnames(T.geo);
		for iT = 2 : nT
			T = subsref(D,substruct('()',{iT})); 
			dati = datanames(T);					
			geoi = fieldnames(T.geo);

			id = setdiff(dat0,dati);
			if ~isempty(id)
				res = false;
				if verbose(1)
					disp(sprintf('The following transect is not defined as the others:\n%i: %s',iT,stamp(T)));					
				end% if 
			end% if 
			id = setdiff(geo0,geoi);
			if ~isempty(id)
				res = false;
				if verbose(1)
					disp(sprintf('The following transect is not defined as the others:\n%i: %s',iT,stamp(T)));					
				end% if
			end% if
		end% for iT
end% switch 


if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {fixed};
	varargout(3) = {D};
	varargout(4) = {msg};
end


end %functiontest_fields
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
