% length Give back the number of transects within a database object
%
% N = length(D,[OPT])
% 
% Return the number N of transects within the database object D which are
% not empty (for which isempty(D.transect{i}) returns false)
%
% Inputs:
%	D: a database object
%	OPT:
%		0 (default): returns the number of non-empty transects
%		1: returns the total number of transects
%
% Created: 2009-07-30.
% Rev. by Guillaume Maze on 2010-04-22: now returns only nb of transects, 
%		because we implemented the function 'size'.
% http://code.google.com/p/copoda
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


function varargout = length(D,varargin)
		
nt = length(D.transect);

switch nargin
	case 2
		if varargin{1} == 0
			nt_empty = 0;
			for it = 1 : nt
				if isempty(D.transect{it})
					nt_empty = nt_empty + 1;
				end
			end
			NT = nt - nt_empty;
		elseif varargin{1} == 1
			NT = nt;
		else
			error('database.length option must 0 or 1')
		end
	otherwise
		nt_empty = 0;
		for it = 1 : nt
			if isempty(D.transect{it})
				nt_empty = nt_empty + 1;
			end
		end
		NT = nt - nt_empty;
end%switch

varargout(1) = {NT}; % By default, we return the number of non-empty transects

end %function








