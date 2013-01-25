% thd Compute main Thermocline properties for profiles in the database
%
% [D] = thd(D,[OPTION,VALUE])
% 
% Compute main Thermocline properties for profiles in the database.
% See the transect/thd method for more details.
%
% Created: 2011-05-26.
% http://code.google.com/p/copoda
% Copyright 2011, COPODA

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
function D = thd(D,varargin)

%- Options:
showprogress = false;
if nargin-1 > 0
	if mod(nargin-1,2) ~=0
		error('Arguments must come in pairs: ARG,VAL')
	end% if 
	for in = 1 : 2 : nargin-1
		eval(sprintf('%s = varargin{in+1};',varargin{in}));		
	end% for in	
end% if

%- Process:
N = length(D);
keep = zeros(1,N);
for it = 1 : N
	if showprogress
		nojvmwaitbar(N,it,'Computing thermocline properties ...');
	end% if 
	try
		T = D.transect{it};
		T = thd(T,varargin{:});
		D.transect{it} = T;
		keep(it) = 1;
	catch
		keep(it) = 0;
	end
end% for it

if length(find(keep==1))>=1
	D = squeeze(D,find(keep==1));
else
	error('Can''t compute any thermocline properties from this database !')
end% if 

end %functionthd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
