% datanames Give a list of variables available in the database
%
% LIST = datanames(DATABASE_OBJ,[TYP])
% 
% Give a list of variables available in the database, ie the list of
% non-empty odata objects within transect.data 
%
% Inputs:
%	- DATABASE_OBJ is the database object
%	- TYP (optional): 
%		0 : Full list (default) -> union list
%		1 : Only variables available in all transects -> intersect list
%
% Output:
%	LIST is a cell array of string with variables names
%
% Created: 2009-11-10.
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


function vlist = datanames(varargin)

D = varargin{1};
typ = 0;
if nargin == 2
	typ = varargin{2};
end

switch typ
	case 0 %% Full list:
		vlist = {''};
		for it = 1 : length(D)
			vlist = union(vlist,datanames(D.transect{it}));
		end
		vlist = vlist(2:end);

	case 1 %% Only variables available in all transects:
		vlist = {''};
		for it = 1 : length(D)
			vlist = union(vlist,datanames(D.transect{it}));
		end
		vlist = vlist(2:end);
		for it = 1 : length(D)
			vlist = intersect(vlist,datanames(D.transect{it}));
		end


end%switch

end %functiondatanames







