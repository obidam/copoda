% DMQCargoCTD2database H1LINE
%
% [] = DMQCargoCTD2database()
% 
% HELP TEXT
%
% Inputs:
%
% Outputs:
%
%
% Created: 2010-06-08.
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
function varargout = DMQCargoCTD2database(varargin)

% To be provided by user:
pathi = '~/data/ARGO/ref_database/CTD_for_DMQC';

% List Matlab mat files
l = dir(fullfile(pathi,'ctd_*.mat'));
if isempty(l)
	error('Not CTD profiles here');
end

% we will create one transec object per file (box)

% init the database:
D = database;
D.source = pathi;
D.name = 'CTD datas for Argo DMQC';
D.description = 'Argo reference database, CTD profiles version 2010V1';

% 
for it = 1 : length(l)
%for it = 1 : 100
	fil = l(it).name;
	nojvmwaitbar(length(l),it,sprintf('Processing %s ...',fil));
	try
		ibox = strrep(strrep(fil,'ctd_',''),'.mat','');
	catch
		error('Cannot identify box name');
	end
	dat = load(fullfile(pathi,fil));
%	stophere

	% Fill in transect object:
	T = transect;
	N_STATIONS = length(dat.dates(:));
	T.geo.LATITUDE  = dat.lat(:);
	T.geo.LONGITUDE = dat.long(:);
	T.geo.STATION_DATE = datenum(num2str(dat.dates'),'yyyymmddHHMMSS');
	T.geo.STATION_NUMBER = ones(N_STATIONS,1);
	% switch size(dat.pres,1)
	% 	case N_STATIONS
	% 		T.geo.PRES = dat.pres;			
	% 	otherwise
	% 		T.geo.PRES = dat.pres';
	% end
	% N_LEVELS = size(T.geo.PRES,2);
	%T.geo.DEPH = sw_dpth(T.geo.PRES,T.geo.LATITUDE);
	
	if 0
		od = getfield(T,'data','TEMP');
		switch size(dat.temp,1)
			case N_STATIONS, od.cont = dat.temp;			
			case N_LEVELS,   od.cont = dat.temp';
			otherwise,error('Weird dimensions');
		end
		T = setodata(T,'TEMP',od);
	
		od = getfield(T,'data','TPOT');
		switch size(dat.temp,1)
			case N_STATIONS, od.cont = dat.ptmp;			
			case N_LEVELS,   od.cont = dat.ptmp';
			otherwise,error('Weird dimensions');
		end
		T = setodata(T,'TPOT',od);
	
		od = getfield(T,'data','PSAL');
		switch size(dat.temp,1)
			case N_STATIONS, od.cont = dat.sal;			
			case N_LEVELS,   od.cont = dat.sal';
			otherwise,error('Weird dimensions');
		end
		T = setodata(T,'PSAL',od);
	end%if 0/1
	
	%
	T.cruise_info = cruise_info('NAME',sprintf('CTD Argo DMQC box #%s',ibox),...
		'DATE',[min(T.geo.STATION_DATE) max(T.geo.STATION_DATE)],...
		'N_STATION',N_STATIONS);
	
	T = clean_empty_variables(T);
	%check(T);	
	D.transect{it} = T;
%	stophere
end%for it

stophere
wssave('D');
end %functionDMQCargoCTD2database
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%












