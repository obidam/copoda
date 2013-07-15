% stamp List of transects stamps
%
% [] = stamp(D,TYPE)
% 
% List of transects stamps
%
% Inputs:
%	D: database
%	TYPE: stamp type (see transect/stamp)
%
% Outputs:
%
% See also
%	transect/stamp
%
% Created: 2010-06-15.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = stamp(D,varargin)

%%%%%%%%%%%%%%%%%%%% OPTIONs
if nargin ~=1 & nargin ~=2 & nargin ~=3 
	error('Bad number of arguments');
end

it = 1 : length(D);
typ = [];

switch nargin
	case 2
		a = varargin{1};
		switch class(a)
			case 'cell'
				it  = a;
			case 'double'			
				typ = a;
		end
	case 3		
		for ii = 1 : 2
			a = varargin{ii};
			switch class(a)
				case 'cell'
					it  = a;
				case 'double'			
					typ = a;
			end
		end%for ii
		clear ii
end%switch

%%%%%%%%%%%%%%%%%%%% STAMPS:
for ii = 1 : length(it)
	if ~isempty(typ)
		str = stamp(D.transect{it(ii)},typ);
	else
		str = stamp(D.transect{it(ii)});
	end
	OUT(ii,1) = {str};
end

%%%%%%%%%%%%%%%%%%%% 
varargout(1) = {OUT};

end %functionstamp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
