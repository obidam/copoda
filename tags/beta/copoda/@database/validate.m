% validate Try to validate a database object
%
% [TF Dfixed] = validate(D,[VERBOSE,FIX])
% 
% Try to validate the database object D through a
% list of different tests.
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
%	#1: validate each transects
%	#2: sort transects by date
%
% See also:
%	transect/validate
%
% Created: 2009-07-30.
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


function [result varargout] = validate(varargin)

switch nargin
	case 1
		D = varargin{1};
		VERB = [1 0];
		FIXE = 0;
	case 2
		D    = varargin{1};
		VERB = varargin{2};
		if ischar(VERB),error('VERBOSE must be either 0 or 1');end
		if length(VERB) == 1, VERB(2) = 0; end
		FIXE = 0;
	case 3
		D = varargin{1};
		VERB = varargin{2};
		if length(VERB) == 1, VERB(2) = 0; end
		FIXE = varargin{3};
	case 4
		D = varargin{1};
		VERB = varargin{2};
		if length(VERB) == 1, VERB(2) = 0; end
		FIXE = varargin{3};
		TTESTLIST = varargin{4};
	otherwise	
		error('Bad nb of arguments')
end

if VERB(1),disp(sprintf('==> Start validation of database object named %s',D.name)),end
itest  = 0;
ifixed = 0;
ierr   = 0;
fixed  = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TESTS:

%%%%%%%%%% Validate each transects:
itest = itest + 1;
res = false;
test_name = sprintf('Validation of each transect(s)');
if VERB(1),disp(sprintf('Test #%i: %s',itest,test_name));end
nt = length(D);
for it = 1:nt
	T = D.transect{it};
	disp_res(sprintf('%10s %i >> %s',' ',it,T.cruise_info.NAME),'Validating ...',VERB(1));
	if exist('TTESTLIST','var')
		[resT(it) Tfixed{it}] = validate(D.transect{it},VERB(2),FIXE,TTESTLIST);
	else
		[resT(it) Tfixed{it}] = validate(D.transect{it},VERB(2),FIXE);
	end
	if ~resT(it), 
		if FIXE == 1
			disp_res('Result','... Echec',VERB(1))
			fixed = true;
		else	
			disp_res('Result','... Echec (it may be fixed !)',VERB(1))
		end
	else		
		disp_res('Result','... OK',VERB(1))
	end	
end
if resT,RESULTS(itest)=true;end
if FIXE, D.transect = Tfixed; end


%%%%%%%%%% Sort transects by dates
itest = itest + 1;
res = false;
test_name = 'Sort transects by date';
if VERB(1),disp(sprintf('Test #%i: %s',itest,test_name));end
nt = length(D);
for it = 1 : nt
	dat(it) = D.transect{it}.cruise_info.DATE(1);
end
if ~issorted(dat)
	if FIXE
		[a is] = sort(dat);
		D = reorder(D,is);
		disp_res('Result','Echec, but fixed',VERB(1))		
		res = true;
		fixed = true;
	else
		disp_res('Result','Echec, not sorted (but it could be fixed !)',VERB(1))
	end
else	
	disp_res('Result','OK',VERB(1))
	res = true;
end
RESULTS(itest) = res;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
if VERB(1),disp(sprintf('==> End validation of database object named %s',D.name));end
if FIXE
	if fixed
		D.modified = now;
	end
end

if RESULTS
	result = true;
else
	result = false;
end

switch nargout
	case 2
		varargout(1) = {D};
end

end %function



%%%%%%%%%%%%%%%%%%%
function varargout = disp_res(name,value,verbose)
	blk = ' ';	
	if verbose == 1
		disp(sprintf('%5s %30s: %s',blk,name,value));	
	else
	end
end %function




