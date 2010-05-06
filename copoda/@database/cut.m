% cut Extract a subset of a database based on a regional selection
%
% D = cut(D,POLYGON)
% 
% Extract from the database D, stations inside POLYGON.
%
% Inputs:
%	D: database object
%	POLYGON = [LONGITUDE ; LATITUDE] the coordinates of points
%		the drawing the region defined by a polygon
%
% Outputs:
%	D: the subset of database D
%
% Note:
% If no stations are found, the function returns NaN
%
% Eg:
%	% D is you database
%	Dnh = cut(D,[0 360 360 0 0 ; 0 0 90 90 0]);
%	% will extract the Northern Hemisphere stations
%
% Created: 2010-05-05.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = cut(D,varargin)
	
if nargin-1 == 1	
	POLYGON = varargin{1};
	% Ensure the polygon is closed:
	POLYGON = cat(2,POLYGON,POLYGON(:,1));
else
	figure;
	tracks(D);
	[POLYGON(1,:) POLYGON(2,:)] = drawmpoly;
end
	
for it = 1 : length(D)
	T = subsref(D,substruct('()',{it}));
	stlon = T.geo.LONGITUDE;
	stlat = T.geo.LATITUDE;
	tokeep = inpolygon(stlon,stlat,POLYGON(1,:),POLYGON(2,:));
	ii = find(tokeep==1);
	if ~isempty(ii)
		T  = reorder(T,1,ii);
		D.transect(it) = {T};
		torem(it) = false;
	else
		torem(it) = true;
	end%if empty
end%for it
if ~isempty(find(torem==true))
	D = reorder(D,find(torem==false));
else
	D = NaN;
end

end %functioncut
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%










