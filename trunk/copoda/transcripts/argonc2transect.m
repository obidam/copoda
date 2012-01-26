% argonc2transect Create a COPODA transect object from an Argo netcdf file
%
% T = argonc2transect(OPT,VAL)
% 
% Create a COPODA transect object from an Argo netcdf file.
% Works for both multi and single profile file.
%
% Measurements loaded: Pressure, Temperature and Salinity.
% Depth is also computed.
% Transect ship name is from the Argo DM User manual Reference Table 8: instrument types
%
% OPTIONS:
%	FILE: Netcdf file name
%	I_PROF (optional): Profile index to load (for multiprofile files)
%		By default load all profiles.
%	VAR_QC (optional): Measurement flag scale to load. Any number or a list of,
%		between 0 and 9 (See Argo DM User manual reference table 2). 
%		By default, all measurements are loaded.
%		Note that the profile quality flag considers [1,2,5,8] as GOOD data
%
% Argo DM User manual Reference table 2 : measurement flag scale:
%	0 | No QC was performed 
%	1 | Good data           
%	2 | Probably good data 
%	3 | Bad data that are potentially correctable 
%	4 | Bad data 
%	5 | Value changed
%	6 | Not used 
%	7 | Not used 
%	8 | Interpolated value 
%	9 | Missing value 
%
% Rq: Use the Matlab version > 7.1 (2010a) netcdf toolbox
%
% Example:
%	T = argonc2transect('file','~/data/ARGO/floats/5900325/5900325_prof.nc');
%	T = argonc2transect('file','~/data/ARGO/floats/5900325/5900325_prof.nc','i_prof',[1:5],'VAR_QC',1);
%
% Rev. by Guillaume Maze on 2011-11-09: Added 'Measurement flag' selection option.
% Created: 2011-05-12.
% Copyright (c) 2011, Guillaume Maze (Laboratoire de Physique des Oceans).
% All rights reserved.
% http://codes.guillaumemaze.org

% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 	* Redistributions of source code must retain the above copyright notice, this list of 
% 	conditions and the following disclaimer.
% 	* Redistributions in binary form must reproduce the above copyright notice, this list 
% 	of conditions and the following disclaimer in the documentation and/or other materials 
% 	provided with the distribution.
% 	* Neither the name of the Laboratoire de Physique des Oceans nor the names of its contributors may be used 
%	to endorse or promote products derived from this software without specific prior 
%	written permission.
%
% THIS SOFTWARE IS PROVIDED BY Guillaume Maze ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, 
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Guillaume Maze BE LIABLE FOR ANY 
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%

function T = argonc2transect(varargin)

%- Load parameters
if nargin ~=0
	if mod(nargin,2) ~=0
		error('Parameters must come in pairs: PAR,VAL')
	end% if 
	for in = 1 : 2 : nargin
		eval(sprintf('%s = varargin{in+1};',lower(varargin{in})));
	end% for in	
	clear in
else
	error('Please provide at least a FILE name !')
end% if

%- Validate parameters:

%-- FILE name:
if ~exist('file','var')
	error('Please provide at least a FILE name !')
elseif ~exist(file,'file')
	error(sprintf('File %s doesn''t exist !',file));
else 
	FILE = file; clear file;
end% if

%--- Check if this is a correct netcdf Argo profile FILE:
ncid  = netcdf.open(FILE,'NC_NOWRITE');
varid = netcdf.inqVarID(ncid,'DATA_TYPE');  DATA_TYPE = netcdf.getVar(ncid,varid)'; 
netcdf.close(ncid);
switch DATA_TYPE(1:16)
	case 'Argo profile    '
		% Ok !
		[N_PROF, N_LEVELS] = getN(FILE);		
	otherwise
		error('This function is only for Argo profile netcdf files !');
end% switch 

%-- Profile index to load (I_PROF):
if ~exist('i_prof','var')
	I_PROF = 1 : N_PROF;	
else
	I_PROF = sort(i_prof); clear i_prof
	if find(I_PROF<0) | find(I_PROF>N_PROF)
		error(sprintf('ProFILEs index must be positive and not higher than the nb of profiles (%i for this FILE)!',N_PROF));
	end% if
end% if 

%-- Variable QC to load (VAR_QC):
if ~exist('var_qc','var')
	VAR_QC = 0:9;
%	VAR_QC = [1,2,5,8];
elseif find(var_qc<0 | var_qc>9)
	error('Variables QC flag must be between 0 and 9 ! (see Argo DM manual table 2)')	
else
	VAR_QC = sort(var_qc); clear var_qc
end% if 

%- Identify profiles/measurements from I_PROF list with correct VAR_QC:
% Variables to be tested:
% POSITION_QC, JULD_QC, (PRES_QC, TEMP_QC, PSAL_QC) or (PRES_ADJUSTED_QC, TEMP_ADJUSTED_QC, PSAL_ADJUSTED_QC)
[N_PROF N_LEVELS] = getN(FILE);
	
%-- Open netcdf FILE:
ncid  = netcdf.open(FILE,'NC_NOWRITE');

%--- Time axis QC:
varid   = netcdf.inqVarID(ncid,'JULD_QC'); 
JULD_QC = netcdf.getVar(ncid,varid)';
JULD_QC = str2num(JULD_QC')';
JULD_QC = JULD_QC(I_PROF);
[a iQC] = isin(JULD_QC,VAR_QC); clear a
if (isempty(iQC))
	warning('No profiles matching required VAR_QC (no valid JULD)')
	T = [];
	return;
else
	I_PROF = I_PROF(iQC);
	N_PROF = length(I_PROF);
end% if 

%--- Position QC:
varid   = netcdf.inqVarID(ncid,'POSITION_QC');
POS_QC  = netcdf.getVar(ncid,varid)';
POS_QC  = str2num(POS_QC(I_PROF)')';
[a iQC] = isin(POS_QC,VAR_QC); clear a
if (isempty(iQC))
	warning('No profiles matching required VAR_QC (no valid POSITION)')
	T = [];
	return;
else
	I_PROF = I_PROF(iQC);
	N_PROF = length(I_PROF);
end% if

%-- Check variables QC and load PRES/TEMP/PSAL:

%--- What is the DATA_MODE:
% R : real time data 
% D : delayed mode data
% A : real time data with adjusted values
varid = netcdf.inqVarID(ncid,'DATA_MODE'); 
DATA_MODE = netcdf.getVar(ncid,varid); 
DATA_MODE = DATA_MODE(I_PROF)';

%--- Check and load:
TEMP = zeros(N_PROF,N_LEVELS)*NaN;
PSAL = zeros(N_PROF,N_LEVELS)*NaN;
PRES = zeros(N_PROF,N_LEVELS)*NaN;
keep = zeros(1,N_PROF);

for ip = 1 : length(I_PROF)
	switch DATA_MODE(ip)
		case 'R' 
		%---- Real time data 
						
			[pres I_LEVELS_PRES] = readnc(FILE,'PRES',I_PROF(ip),VAR_QC);
			if isempty(I_LEVELS_PRES)
				warning(sprintf('No levels matching required QC for %s','PRES'));
				T = [];
				return;
			end% if
		
			[temp I_LEVELS_TEMP] = readnc(FILE,'TEMP',I_PROF(ip),VAR_QC);
			if isempty(I_LEVELS_TEMP)
				warning(sprintf('No levels matching required QC for %s','TEMP'));
				T = [];
				return;
			end% if	
				
			[psal I_LEVELS_PSAL] = readnc(FILE,'PSAL',I_PROF(ip),VAR_QC);
			if isempty(I_LEVELS_PSAL)
				warning(sprintf('No levels matching required QC for %s','PSAL'));
				T = [];
				return;
			end% if
			
		case {'D','A'} 
		%---- Delayed mode or Real time data with adjusted values
						
			[pres I_LEVELS_PRES] = readnc(FILE,'PRES_ADJUSTED',I_PROF(ip),VAR_QC);	
			if isempty(I_LEVELS_PRES)
				warning(sprintf('No levels matching required QC for %s','PRES_ADJUSTED'));
				T = [];
				return;
			elseif prod(size(pres)) == length(find(isnan(pres)==1))
				warning('This is a delayed mode profile but PRES_ADJUSTED is not filled !');
				T = [];
				return;
			end% if
		
			[temp I_LEVELS_TEMP] = readnc(FILE,'TEMP_ADJUSTED',I_PROF(ip),VAR_QC);
			if isempty(I_LEVELS_TEMP)
				warning(sprintf('No levels matching required QC for %s','TEMP_ADJUSTED'));
				T = [];
				return;
			elseif prod(size(temp)) == length(find(isnan(temp)==1))
				warning('This is a delayed mode profile but TEMP_ADJUSTED is not filled !');
				T = [];
				return;
			end% if
				
			[psal I_LEVELS_PSAL] = readnc(FILE,'PSAL_ADJUSTED',I_PROF(ip),VAR_QC);
			if isempty(I_LEVELS_PSAL)
				warning(sprintf('No levels matching required QC for %s','PSAL_ADJUSTED'));
				T = [];
				return;
			elseif prod(size(psal)) == length(find(isnan(psal)==1))
				warning('This is a delayed mode profile but PSAL_ADJUSTED is not filled !');
				T = [];
				return;
			end% if			
	end% switch
	
	% We load only levels with valid QC for PRES, TEMP and PSAL:
%				I_LEVELS_PRES = [1 2 3   5 6 7];           pres = pres(I_LEVELS_PRES);
%				I_LEVELS_TEMP = [  2 3 4 5 6 7   9 10 11]; temp = temp(I_LEVELS_TEMP);
%				I_LEVELS_PSAL = [1 2   4 5 6 7 8];         psal = psal(I_LEVELS_PSAL);

	ikeep_p = zeros(1,length(I_LEVELS_PRES));
	ikeep_t = zeros(1,length(I_LEVELS_TEMP));
	ikeep_s = zeros(1,length(I_LEVELS_PSAL));
	for ii = 1 : length(I_LEVELS_PRES)
		iz = I_LEVELS_PRES(ii);
		if ~isempty(find(I_LEVELS_TEMP==iz)) & ~isempty(find(I_LEVELS_PSAL==iz))
			ikeep_p(ii) = 1;
			ikeep_t(find(I_LEVELS_TEMP==iz)) = 1;
			ikeep_s(find(I_LEVELS_PSAL==iz)) = 1;
		end% if 
	end% for iz
	clear ii iz
	
	if isempty(find(ikeep_p==1))
		% Skip this profile
		keep(ip) = 0;
	else
		keep(ip) = 1;
		pres = pres(find(ikeep_p==1));
		temp = temp(find(ikeep_t==1));
		psal = psal(find(ikeep_s==1));
		nz   = length(pres);
		PRES(ip,1:nz) = pres;
		TEMP(ip,1:nz) = temp;
		PSAL(ip,1:nz) = psal;
	end% if 
									
	clear pres temp psal nz I_LEVELS*
	
end% for ip

if isempty(find(keep==1))
	warning('No profiles matching required VAR_QC (no valid PRES/TEMP/PSAL)')
	T = [];
	return;
else
	I_PROF = I_PROF(find(keep==1));
	N_PROF = length(I_PROF);
	PRES = PRES(find(keep==1),:);
	TEMP = TEMP(find(keep==1),:);
	PSAL = PSAL(find(keep==1),:);
end% if 

%- Finaly create transect object:

%-- Init transect instance
T = transect;

%-- Add basic properties
T.source = 'Ifremer/Coriolis';
di = dir(FILE);
T.file      = FILE;
T.file_date = di.datenum;

%-- Add cruise_info:
T = add2T_metainfo(T,FILE,I_PROF);

%-- Add axis informations to the geo property:
T = add2T_geo(T,FILE,I_PROF);

%--- Add PRES/MAX_PRESSURE:
T.geo.PRES = PRES;
for ip = 1 : length(I_PROF)
	MAX_PRESSURE(ip,1) = nanmax(T.geo.PRES(ip,:));
end% for ip
T.geo.MAX_PRESSURE = MAX_PRESSURE; clear MAX_PRESSURE;

%--- Add DEPTH:
% Compute depth from pressure and latitude:
% Eqn 25, p26.  Unesco 1983.
	DEG2RAD = pi/180;
	c1 = +9.72659;
	c2 = -2.2512E-5;
	c3 = +2.279E-10;
	c4 = -1.82E-15;
	gam_dash = 2.184e-6;
	LAT = abs(T.geo.LATITUDE);
	LAT = meshgrid(LAT,1:N_LEVELS)';
	X   = sin(LAT*DEG2RAD);  % convert to radians
	X   = X.*X;
	bot_line = 9.780318*(1.0+(5.2788E-3+2.36E-5*X).*X) + gam_dash*0.5*PRES;
	top_line = (((c4*PRES+c3).*PRES+c2).*PRES+c1).*PRES;
	DEPH = top_line./bot_line;
T.geo.DEPH = -abs(DEPH);

%-- Add odata objects:

%--- Create odata objects:
varidT = netcdf.inqVarID(ncid,'TEMP');
varidS = netcdf.inqVarID(ncid,'PSAL');

odT = odata('name','TEMP',...
		   'long_name',strtrim(netcdf.getAtt(ncid,varidT,'long_name')),...
		   'unit',     shorten_unit(strtrim(netcdf.getAtt(ncid,varidT,'units'))),...
		   'long_unit',strtrim(netcdf.getAtt(ncid,varidT,'units')),...
	       'cont',TEMP);
	
odS = odata('name','PSAL',...
		   'long_name',strtrim(netcdf.getAtt(ncid,varidS,'long_name')),...
		   'unit',     shorten_unit(strtrim(netcdf.getAtt(ncid,varidS,'units'))),...
		   'long_unit',strtrim(netcdf.getAtt(ncid,varidS,'units')),...
	       'cont',PSAL);
				
%--- Update transect object:
T = setodata(T,'TEMP',odT);
T = setodata(T,'PSAL',odS);

%- Clean up the transect:
T = clean_empty_variables(T);

%- Close netcdf:
netcdf.close(ncid);

end %functionargonc2transect




% Add axis informations to the geo property;
function T = add2T_geo(T,file,I_PROF)
	
	%-- Open netcdf
	ncid  = netcdf.open(file,'NC_NOWRITE');
	
	%-- STATION_DATE:
	geo.STATION_DATE = getTIME(file,I_PROF)';
	
	%-- LATITUDE, LONGITUDE:
	varid = netcdf.inqVarID(ncid,'LATITUDE');  LATITUDE  = netcdf.getVar(ncid,varid); LATITUDE  = LATITUDE(I_PROF);
	varid = netcdf.inqVarID(ncid,'LONGITUDE'); LONGITUDE = netcdf.getVar(ncid,varid); LONGITUDE = LONGITUDE(I_PROF);
	geo.LATITUDE  = LATITUDE;
	geo.LONGITUDE = LONGITUDE;

	%-- STATION_NUMBER/STATION_CYCLE:
	% STATION_CYCLE is the station cycle number from Argo profile:
	varid = netcdf.inqVarID(ncid,'CYCLE_NUMBER');  CYCLE_NUMBER  = netcdf.getVar(ncid,varid,'double'); CYCLE_NUMBER  = CYCLE_NUMBER(I_PROF);
	geo.STATION_NUMBER = [1:length(I_PROF)]';
	geo.STATION_CYCLE  = CYCLE_NUMBER;
	
	%-- DATA_MODE:
	varid = netcdf.inqVarID(ncid,'DATA_MODE'); 
	DATA_MODE  = netcdf.getVar(ncid,varid); DATA_MODE = DATA_MODE(I_PROF)';
	geo.DATA_MODE = DATA_MODE';

	%-- Update transect object:
	T.geo = geo;
	
	%-- Close netcdf
	netcdf.close(ncid);
		
end% function

% Add cruise_info properties to a transect instance
function T = add2T_metainfo(T,file,I_PROF)
	
	% TODO: We should check if the all parameters are similar for all profiles	
	% as of now only the 1st profile informations are used.
	
	% Open ncfile and metainfo container (cruise_info object)
	C = cruise_info; % (no arguments) creates a default cruise_info object
	ncid = netcdf.open(file,'NC_NOWRITE');
		
	% Load time axis according to VAR_QC, and eventually modify I_PROF
	t = getTIME(file,I_PROF);
	C.DATE = [min(t) max(t)];
	
	% convention:  "WMO float identifier : A9IIIII" 
	varid = netcdf.inqVarID(ncid,'PLATFORM_NUMBER'); PLATFORM_NUMBER = netcdf.getVar(ncid,varid)'; 
	C.NAME = sprintf('Argo float WMO: %s',PLATFORM_NUMBER(I_PROF(1),:));
	C.SHIP_WMO_ID = PLATFORM_NUMBER(I_PROF(1),:); 
	
	% 
	varid = netcdf.inqVarID(ncid,'PI_NAME'); PI_NAME = netcdf.getVar(ncid,varid)'; 
	C.PI_NAME = PI_NAME(I_PROF(1),:); 
	C.PI_ORGANISM = ''; % Can we do something about this ?
	
	%
	varid = netcdf.inqVarID(ncid,'WMO_INST_TYPE'); WMO_INST_TYPE = netcdf.getVar(ncid,varid)'; 
	str = deblank(WMO_INST_TYPE(I_PROF(1),:));
	if (str(1)=='0'), str = str(2:end); end
	C.SHIP_NAME = argo_tables(8,str);
	
	%
	C.N_STATION = length(I_PROF);
	
	% Update transect object:
	T.cruise_info = C;
	
	% Close netcdf
	netcdf.close(ncid);

end% function

% Get profiles dates
function t = getTIME(file,I_PROF)
	
	ncid  = netcdf.open(file,'NC_NOWRITE');
	
	% Reference:
	varid = netcdf.inqVarID(ncid,'REFERENCE_DATE_TIME'); 
	REFERENCE_DATE_TIME = netcdf.getVar(ncid,varid)'; 
	
	ref = datenum(str2num(REFERENCE_DATE_TIME(1:4)),...
			str2num(REFERENCE_DATE_TIME(5:6)),...
			str2num(REFERENCE_DATE_TIME(7:8)),...
			str2num(REFERENCE_DATE_TIME(9:10)),...
			str2num(REFERENCE_DATE_TIME(11:12)),...
			str2num(REFERENCE_DATE_TIME(13:14)));			
	
	% Relative time axis:
	varid = netcdf.inqVarID(ncid,'JULD'); 
	JULD  = netcdf.getVar(ncid,varid)';
	JULD  = JULD(I_PROF);
	
	% Absolute time axis:
	t = ref + JULD;
	
	netcdf.close(ncid);	
end%function

% Read a PARAM with a given QC
function [out I_LEVELS] = readnc(FILE,PARAM,I_PROF,PARAM_QC)
	
	ncid  = netcdf.open(FILE,'NC_NOWRITE');
	[N_PROF N_LEVELS] = getN(FILE); % Interesting dimensions
	
	% Read QC values:
	varid = netcdf.inqVarID(ncid,sprintf('%s_QC',PARAM));
	QC = netcdf.getVar(ncid,varid);
	% Rq: out should be (N_PROF,N_LEVELS) but, I don't know why, here the output is (N_LEVELS,N_PROF) !
	switch size(QC,1)
		case N_PROF % Ok
		case N_LEVELS % Flip it:
			QC = QC';
	end% switch
	QC = QC(I_PROF,:);
	I_MISSING = 1:N_LEVELS;
	I_MISSING = I_MISSING(strfind(QC,' '));

	I_DEFINED = 1:N_LEVELS;
	I_DEFINED(I_MISSING) = NaN;
	I_DEFINED = I_DEFINED(~isnan(I_DEFINED));
	N_LEVELS_DEFINED = length(I_DEFINED);
	
	% Select only allowed QC:
	QC  = str2num(QC')';
	[a iz] = isin(QC,PARAM_QC); clear a
	if (isempty(iz))
%		warning(sprintf('No levels matching required QC for %s',PARAM));
		out = [];
		I_LEVELS = [];
		return;
	end
	I_LEVELS = I_DEFINED(iz);
	
	% Now load parameter:
	varid = netcdf.inqVarID(ncid,PARAM);
	fillV = netcdf.getAtt(ncid,varid,'_FillValue');
	out   = netcdf.getVar(ncid,varid,'double'); 
	out(out==fillV) = NaN;
	% Rq: out should be (N_PROF,N_LEVELS) but, I don't know why, here the output is (N_LEVELS,N_PROF) !
	switch size(out,1)
		case N_PROF % Ok
		case N_LEVELS % Flip it:
			out = out';
	end% switch 
	out  = out(I_PROF,I_LEVELS);
	netcdf.close(ncid);
end% function

% Read dimensions of a netcdf FILE
function [np nl] = getN(FILE);
	ncid  = netcdf.open(FILE,'NC_NOWRITE');
	dimid = netcdf.inqDimID(ncid,'N_PROF');  
	[dimname, np] = netcdf.inqDim(ncid,dimid);
	dimid = netcdf.inqDimID(ncid,'N_LEVELS');  
	[dimname, nl] = netcdf.inqDim(ncid,dimid);
	netcdf.close(ncid);
end% function

% Argo Reference table
function output = argo_tables(idT,code_figure)

switch idT
	case 1 % Table 1: Data type
		il = 0;
		il = il + 1; table1(il,:) = 'Argo profile                    ';
		il = il + 1; table1(il,:) = 'Argo trajectory                 ';
		il = il + 1; table1(il,:) = 'Argo meta-data                  ';
		il = il + 1; table1(il,:) = 'Argo technical data             ';
		
		output = table1;

		
	case 8 % Table 8: instrument types
		if isnumeric(code_figure)
			code_figure = num2str(code_figure);
		end

		il=0;
		il=il+1;table8(il,:) = {'831' ,'P-Alace float'};
		il=il+1;table8(il,:) = {'840' ,'Provor, no conductivity'};
		il=il+1;table8(il,:) = {'841' ,'Provor, Seabird conductivity sensor'};
		il=il+1;table8(il,:) = {'842' ,'Provor, FSI conductivity sensor'};
		il=il+1;table8(il,:) = {'845' ,'Webb Research, no conductivity'};
		il=il+1;table8(il,:) = {'846' ,'Webb Research, Seabird sensor'};
		il=il+1;table8(il,:) = {'847' ,'Webb Research, FSI sensor'};
		il=il+1;table8(il,:) = {'850' ,'Solo, no conductivity'};
		il=il+1;table8(il,:) = {'851' ,'Solo,  Seabird conductivity sensor'};
		il=il+1;table8(il,:) = {'852' ,'Solo, FSI conductivity sensor'};
		il=il+1;table8(il,:) = {'855' ,'Ninja, no conductivity sensor'};
		il=il+1;table8(il,:) = {'856' ,'Ninja, SBE conductivity sensor'};
		il=il+1;table8(il,:) = {'857' ,'Ninja, FSI conductivity sensor'};
		il=il+1;table8(il,:) = {'858' ,'Ninja, TSK conductivity sensor'};

		[a ia] = intersect(table8,code_figure);
		if ~isempty(ia)
			a = table8(ia,:);
			instrument = a{2};
		else
			instrument = NaN;
		end
		output = instrument;
end% switch 

end %functionargo_table











