% tracks_pl5 Plot any single value on a map
%
% [] = tracks_pl5(D,'VARNAME')
% 
% HELP TEXT
%
% Inputs:
%
% Outputs:
%
%
% Created: 2012-01-29.
% http://code.google.com/p/copoda
% Copyright 2012, COPODA

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
function [p tt] = tracks_pl5(D,varargin)

%- 
iz = 1;
switch nargin
	case 2
		varname = varargin{1};
	case 3
		varname = varargin{1};
		iz = varargin{2};
	otherwise
		varname = 'STATION_DATE';
end% switch 

%- Load variable to map:	
[x y V unit] = get_vars(D,varname,iz);

%- Make the copoda toolbar faster:
station_locations.LON = x;station_locations.LAT = y;
setappdata(gcf,'station_locations',station_locations);

%- Plot
optimap(D);hold on
p = m_scatter(x,y,10,V,'o','filled');
set(p,'tag','station_location');

tt = title(varname,'interpreter','none');
set(tt,'fontweight','bold','fontsize',14)

tt = xlabel(sprintf('%s\n%s (%s)',D.name,D.source,D.creator));
set(tt,'fontweight','bold','fontsize',14)

tt(2) = colorbar;
tt(3) = ctitle(tt(2),unit);

		
end %functiontracks_pl5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X Y V unit] = get_vars(D,varname,iz)
	% This is not a very efficient routine for large database !
	% TODO Improve efficiency !
	X = [];
	Y = [];
	V = [];
	unit = '';
	for iT = 1 : length(D)	
		X = [X ; D.transect{iT}.geo.LONGITUDE];
		Y = [Y ; D.transect{iT}.geo.LATITUDE];
		if iT == 1
			isadata = isdata(D.transect{iT},varname);
		end% if 
		switch isadata
			case 1
				c = getfield(D.transect{iT},'data',varname);
				if iT == 1, unit = c.unit; end% if 
				c = c.cont;
			case 0
				c = getfield(D.transect{iT},'geo',varname);
		end% switch 		
		switch size(c,2) 
			case 1				
				V = [V ; c];
			otherwise
				try
					V = [V ; c(:,iz)];
				catch
					V = [V ; ones(size(X),1)*Inf];					
				end% if 
		end% switch 
	end% for iT
end%function



