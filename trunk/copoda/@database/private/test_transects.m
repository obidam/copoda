% test_transects 1: Individual transect validation
%
% [] = test_transects()
% 
% HELPTEXT
%
% Created: 2010-02-11.
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


function varargout = test_transects(varargin)

test_name = 'Individual transect validation';
test_desc = {'Perform the transect/validate method on each transect of the database'};
res   = false;
fixed = false;
switch nargin
	case 0
		varargout(1) = {1}; % ID of the test
		varargout(2) = {test_desc};
		varargout(3) = {test_name};
		return
	otherwise
		D		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end	
msg(1).test_name   = test_name;

res = false;
nt  = length(D);
for it = 1 : nt
	T = D.transect{it};
	disp_res(sprintf('%10s %i >> %s',' ',it,T.cruise_info.NAME),'Validating ...',verbose(1));
	[resT(it) Tfixed{it}] = validate(D.transect{it},verbose(2),fixe);
	if ~resT(it), 
		if fixe == 1
			disp_res('Result','... Echec',verbose(1))
			fixed = true;
		else	
			disp_res('Result','... Echec (it may be fixed !)',verbose(1))
		end
	else		
		disp_res('Result','... OK',verbose(1))
	end	
end
if resT, res = true; end
if fixe, D.transect = Tfixed; end



if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {fixed};
	varargout(3) = {D};
	varargout(4) = {msg};
end	




end %functiontest_transects

