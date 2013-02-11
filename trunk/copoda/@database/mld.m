% mld Compute mixed layer depth for profiles in the database
%
% [D] = mld(D,[OPTION,VALUE])
% 
% Compute the mixed layer depth for profiles in the database.
% See the transect/mld method for more details.
% Inputs:
% 	[OPTION,VALUE] pairs are sent to the transect/mld method.
% One can also show a progress bar using:
% 	[OPTION,VALUE] = ['showprogress',true]
%	
% Eg:
% D = mld(D,'crit','dt02');
% D = mld(D,'showprogress',true,'crit','dt02');
%
% Rq:
% The progress bar is made with function 'nojvmwaitbar'
% 
% Created: 2011-05-23.
% Rev. by Guillaume Maze on 2013-01-30: Added progress bar.
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
function D = mld(D,varargin)

%- Defaults options:
showprogress = false;

%- User options:
if nargin-1 > 0
	if mod(nargin-1,2) ~=0
		error('Arguments must come in pairs: ARG,VAL')
	end% if 
	for in = 1 : 2 : nargin-1
		eval(sprintf('%s = varargin{in+1};',varargin{in}));		
	end% for in	
end% if

%- Diag:
Nt = length(D);
keep = zeros(1,Nt);
for it = 1 : Nt
	if showprogress
		nojvmwaitbar(Nt,it,'Computing mixed layer depth ...');
	end% if
	try
		T = D.transect{it};
		T = mld(T,varargin{:});
		D.transect{it} = T;
		keep(it) = 1;
	catch
		keep(it) = 0;
	end
end% for it

%- Output:
if length(find(keep==1))>=1
	D = squeeze(D,find(keep==1));
else
	error('Can''t compute any mixed layer depth from this database !')
end% if 

end %functionmld
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
