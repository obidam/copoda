% profile Plot a variable profile
%
% [] = profile(T,OPTIONS)
% 
% Plot profiles from a transect object station
% One figure per variable and station.
%
% Inputs:
%	T: Transect object
%	OPTIONS:
%		'VARN': a cell of string with data field names to plot
%		'iS': Station number (not ID) to plot
%		'ztyp': One of geo transect properties name to use as a 
%			vertical axis (DEPH, PRES, etc ...)
%
% Created: 2010-05-25.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = profile(T,varargin)
	
% Default options:
ztyp = 'DEPH';  % Y axis
VARN = {'TEMP'}; % List of variables to plot in X axis
iS   = 1; % Which station ?

% User options:
for in = 2 : 2 : nargin-1
	eval(sprintf('%s=varargin{%i};',varargin{in-1},in));
end

% Plot profiles:

for iv = 1 : length(VARN)
	for is = 1 : length(iS)							
		figure('tag','profile_plot');copoda_figtoolbar(T);
		od = subsref(T,substruct('.','data','.',VARN{iv}));
		z  = subsref(T,substruct('.','geo','.',ztyp,'()',{iS(is),':'}));
		p = plot(od.cont(iS(is),:),z);
		set(p,'marker','.');
		grid on,box on;
		title(sprintf('%s (%s)\n%s',od.name,od.long_name,stamp(T,5)),'fontweight','bold','interpreter','none');
		set(gcf,'name',sprintf('%s (%s)',stamp(T,5),od.name));
		xlabel(sprintf('%s (%s)',od.unit,od.long_unit));
		ylabel(ztyp);
		l = legend(p,sprintf('LAT=%0.1f, LON=%0.1f\n%s\nStation #%i',T.geo.LATITUDE(iS(is)),T.geo.LONGITUDE(iS(is)),datestr(T.geo.STATION_DATE(iS(is))),T.geo.STATION_NUMBER(iS(is))));
		set(l,'location','eastoutside');
	end
end



end %functionprofile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
