% profile Plot a profile from one station
%
% [] = profile(D,[OPTIONS])
% 
% Plot a map of stations in D (using function tracks) and ask to
% select one of them with the mouse and plot a profile
%
% Inputs:
%
% Outputs:
%
%
% Created: 2010-05-06.
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
function varargout = profile(D,varargin)

% Options:
if nargin > 1
	VARN = varargin{1};
else
	VARN = {'TEMP'};
end
if ~isa(VARN,'cell')
	VARN = {VARN};
end

% Open new figure:
f0 = figure;
hold on

% Plot all stations locations:
st = tracks(D,1);

% Extract informations once and for all
LAT = extract(D,'LATITUDE');
LON = extract(D,'LONGITUDE');

% Ask to pick one :
done = 0;
while done ~= 1
	if ~exist('f0pos')
		f0pos = get(f0,'position');
	end
	[but iT iS p mlon mlat] = pickonestation(D,LAT,LON);
	if but ~= 1
		delete(p);
		done = 1;
	else
	
		% Plot the profile of VARN:
		T    = D.transect{iT};
		ztyp = 'DEPH';
		%ztyp = 'PRES';

		for iv = 1 : length(VARN)
			f(iv) = figure;
			od = subsref(T,substruct('.','data','.',VARN{iv}));
			z  = subsref(T,substruct('.','geo','.',ztyp,'()',{iS,':'}));
			p = plot(od.cont(iS,:),z);
			set(p,'marker','.');
			grid on,box on;
			title(sprintf('%s (%s)\n%s',od.name,od.long_name,stamp(T,5)),'fontweight','bold');
			set(gcf,'name',sprintf('%s (%s)',stamp(T,5),od.name));
			xlabel(sprintf('%s (%s)',od.unit,od.long_unit));
			ylabel(ztyp);
			l = legend(p,sprintf('LAT=%0.1f, LON=%0.1f\n%s\nStation #%i',mlat,mlon,datestr(T.geo.STATION_DATE(iS)),T.geo.STATION_NUMBER(iS)));
			set(l,'location','eastoutside');
		end

		builtin('figure',f0);
	end%if
end%swhile


end %functionprofile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [but iT iS p mlon mlat] = pickonestation(D,LAT,LON);

	[x y but] = ginput(1); % Pick one point with the mouse
	[mlon mlat] = m_xy2ll(x,y); % Convert point coords to lat/lon
	
	% Find the closest station of the point:
	for ip = 1 : length(LAT)
		d(ip)=m_lldist([mlon LON(ip)],[mlat LAT(ip)]);
	end
	[dmin ii] = min(d);
	p = m_plot(LON(ii),LAT(ii),'rs','tag','activestation');
	
	% Identify the transect/station
	for it = 1 : length(D)
		T = D.transect{it};
%		if find(T.geo.LATITUDE==LAT(ii)) & find(T.geo.LONGITUDE==LON(ii))
		if find( abs(T.geo.LATITUDE-LAT(ii)) < 50*eps ) & find( abs(T.geo.LONGITUDE-LON(ii)) < 50*eps )			
			iT = it;
			iS = find(abs(T.geo.LATITUDE-LAT(ii)) < 50*eps,1);			
			return
		end
	end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

















