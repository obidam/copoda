% cut Extract a subset of a database based on a regional selection
%
% D = cut(D,[POLYGON])
% 
% Extract from the database D, stations inside POLYGON.
% POLYGON is optional, if you don't specify it, a map of the database
% stations is plotted and you can draw a polygon with mouse clicks.
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
%	% D is your database
%	Dnh = cut(D,[0 360 360 0 0 ; 0 0 90 90 0]);
%	% will extract the Northern Hemisphere stations
%
% Created: 2010-05-05.
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
function D = cut(D,varargin)
	
if nargin-1 == 1	
	POLYGON = varargin{1};
	% Ensure the polygon is closed:
	POLYGON = cat(2,POLYGON,POLYGON(:,1));
else
	figure;
	optimap(D);
	x = extract(D,'LONGITUDE');
	y = extract(D,'LATITUDE');
	p = m_plot(x,y,'k+');
	title(sprintf('<left click> to valide a point\n<right click> to remove the last one\n<middle click> to close the polygon, clear it from the map and return coordinates\n<return> to close the polygon, leave it on the map and return coordinates'));	
	[POLYGON(1,:) POLYGON(2,:) HL BUT] = drawmpoly;
	if isempty(BUT)
		set(p,'color',[1 1 1]/2);
		ii = inpolygon(x,y,POLYGON(1,:),POLYGON(2,:));
		p2 = m_plot(x(ii==1),y(ii==1),'r+');
	end
end
	
for it = 1 : length(D)
	T = subsref(D,substruct('()',{it}));
	stlon  = T.geo.LONGITUDE;
	stlat  = T.geo.LATITUDE;
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
if length(find(torem==true)) == length(D)
	D = NaN;
else
	D = reorder(D,find(torem==false));
end

end %functioncut
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%










