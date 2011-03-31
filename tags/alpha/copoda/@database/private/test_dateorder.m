% test_dateorder 2: Sort transects by dates
%
% [] = test_dateorder()
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


function varargout = test_dateorder(varargin)

test_name = 'Sort transects by dates';
test_desc = {'Sort transects by increasing dates (doesn''t modify order into each transect)'};
res   = false;
fixed = false;
switch nargin
	case 0
		varargout(1) = {2}; % ID of the test
		varargout(2) = {test_desc};
		return
	otherwise
		D		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end	

nt  = length(D);
for it = 1 : nt
	dat(it) = D.transect{it}.cruise_info.DATE(1);
end
if ~issorted(dat)
	if fixe
		[a is] = sort(dat);
		D = reorder(D,is);
		disp_res('Result','Echec, but fixed',verbose(1))		
		res = true;
		fixed = true;
	else
		disp_res('Result','Echec, not sorted (but it could be fixed !)',verbose(1))
	end
else	
	disp_res('Result','OK',verbose(1))
	res = true;
end


if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {fixed};
	varargout(3) = {D};
end



end %functiontest_dateorder