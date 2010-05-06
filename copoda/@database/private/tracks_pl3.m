% tracks_pl3 Plot all stations positions without color
%
% [] = tracks_pl3(D)
%
% Inputs:
%
% Outputs:
%
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
function p = tracks_pl3(D)

	y=extract(D,'LATITUDE');
	x=extract(D,'LONGITUDE');
	%x(x>=-180 & x<0) = 360 + x(x>=-180 & x<0); % Move to longitude from 0 to 360
	dx = 5; dy = 2;
	DOMAIN = [max([min(x)-dx 0]) min([360 max(x)+dx]) max([min(y)-dy -90]) min([max(y)+dy 90])];
	if DOMAIN(2) == 360
		DOMAIN(2) = 359.5;
	end
	DOMAIN;
	
	hold on

	m_proj('equid','lon',DOMAIN(1:2),'lat',DOMAIN(3:4));
	m_elev('contour',[-3:-1]*1e3,'edgecolor',[1 1 1]*.5);
	m_coast('patch',[1 1 1]*.5);
	m_grid('xtick',[0:10:360],'ytick',[-90:10:90]);
	p = m_plot(x,y,'k+');
	
end %functiontracks_pl3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
