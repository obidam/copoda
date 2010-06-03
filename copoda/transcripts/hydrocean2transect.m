% hydrocean2transect Create a transect object from a HYDROCEAN netcdf file
%
% T = hydrocean2transect(netcdf_file,[BIO])
% 
% This function creates a transect object from a HYDROCEAN netcdf file.
%
% HYDROCEAN is the database collecting hydrographic (CTD) datas at LPO, Ifremer, Brest.
% Intranet webpage: 
%	http://w3.ifremer.fr/lpo/base_hydro/hydrocean.htm
%
% Inputs:
%	netcdf_file: the absolute path to the netcdf file with datas (multistation format).
%		Tip: you can use the direct url from the intranet, like:
%			T = hydrocean2transect('http://w3.ifremer.fr/lpo/base_hydro/mlt/<NETCDFFILE>')
%			In this case, using the system command 'wget', the function downloads the file
%			
%	BIO (0/1): try to fil in with biogeochemical tracers the transect object (default=0).
%
% Examples:
%	T = hydrocean2transect('~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A01E/A01E91_dep.nc')
%
% You can also use a remote netcdf file from the intranet:
%	T = hydrocean2transect('http://w3.ifremer.fr/lpo/base_hydro/mlt/A20_97_dep.nc')
% In this case, the function download the netcdf file with the system command 'wget'
% and put it in the current directory as: 'hydrocean_A20_97_dep.nc'
%
%
% Created: 2010-04-30.
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

function T = hydrocean2transect(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Automatic retrieval of scaled variable with NaNs in place of the fill value
global nctbx_options;
nctbx_options.theAutoNaN = 1;
nctbx_options.theAutoscale = 1;

% Init transect object:
nc_file = varargin{1};
nc_file = abspath(nc_file);
nc_file0 = nc_file; % We keep the initial file name

% Do we load biogeochemical tracers ?
if nargin == 2
	do_biogeo = varargin{2};
else	
	do_biogeo = 0;
end

% Here we insert the possibility to download the datas from the intranet
% if we find 'http' in nc_file
%if strfind(nc_file,'http://w3.ifremer.fr/lpo/base_hydro/mlt/')
if strfind(nc_file,'ftp://') | strfind(nc_file,'http://')	
	try
%		local_ncfile = strrep(nc_file,'http://w3.ifremer.fr/lpo/base_hydro/mlt/',sprintf('%s/hydrocean_',pwd));
		local_ncfile = sprintf('%s/hydrocean_tempo_file.nc',pwd);
		%keyboard
		system(sprintf('wget -O %s ''%s''',local_ncfile,nc_file));
		% If we made it through here, we can change the nc_file value:
		nc_file = local_ncfile;
	catch
		error('You asked for an online netcdf file I couldn''t download !');
	end
end


% Open netcdf file
nc = netcdf(nc_file,'nowrite');
[ndims, nvars, ngatts, theRecdimid, status] = ncmex('inquire',ncid(nc));
if status == -1
	error('Badly open netcdf file, please double check it ...')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Init transect object and fill in header properties:
T          = transect;
T.file     = nc_file;
T.creator  = sprintf('%s (login)',getenv('USER'));
T.source   = sprintf('%s (%s)',copoda_readconfig('transect_constructor_default_source'),nc_file0);
T.created  = datenum(now);
T.modified = datenum(1900,1,1,0,0,0);
finfo = dir(nc_file);
T.file_date = finfo.datenum;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fill in Cruise informations:
if ~isempty(nc{'STATION_DATE_BEGIN'}(:))
	T.cruise_info = cruise_info(...
						'NAME',deblank(nc{'CRUISE_NAME'}(1,:)'),...
						'PI_NAME',deblank(nc{'PI_NAME'}(1,:)'),...
						'PI_ORGANISM',deblank(nc{'PI_ORGANISM'}(1,:)'),...
						'SHIP_NAME',deblank(nc{'SHIP_NAME'}(1,:)'),...
						'SHIP_WMO_ID',deblank(nc{'SHIP_WMO_ID'}(1,:)'),...
						'DATE',[min(datenum(nc{'STATION_DATE_BEGIN'}(:),'yyyymmddHHMMSS')) ...
								max(datenum(nc{'STATION_DATE_END'}(:),'yyyymmddHHMMSS'))],...
						'N_STATION',length(nc{'STATION_NUMBER'}(:))...
						...
						);
						
else % This is more likely an Argo file, just a trick to be able to 
%		handle argo data with transect class
	REFERENCE_DATE_TIME = nc{'REFERENCE_DATE_TIME'};
	ref = datenum(str2num(REFERENCE_DATE_TIME(1:4)),...
			str2num(REFERENCE_DATE_TIME(5:6)),...
			str2num(REFERENCE_DATE_TIME(7:8)),...
			str2num(REFERENCE_DATE_TIME(9:10)),...
			str2num(REFERENCE_DATE_TIME(11:12)),...
			str2num(REFERENCE_DATE_TIME(13:14)));
	tim = nc{'JULD_LOCATION'} + ref;
	T.cruise_info = cruise_info(...
						'NAME',deblank(nc{'CRUISE_NAME'}(1,:)'),...
						'PI_NAME',deblank(nc{'PI_NAME'}(1,:)'),...
						'PI_ORGANISM',deblank(nc{'PI_ORGANISM'}(1,:)'),...
						'SHIP_NAME',deblank(nc{'SHIP_NAME'}(1,:)'),...
						'SHIP_WMO_ID',deblank(nc{'SHIP_WMO_ID'}(1,:)'),...
						'DATE',[min(tim) max(tim)],...
						'N_STATION',length(nc{'STATION_NUMBER'}(:))...
						...
						);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fill in Axes informations:
T.geo = fill_axes(...
			'STATION_DATE',get_date(nc),...
			'STATION_NUMBER',nc{'STATION_NUMBER'}(:),...
			'LATITUDE',get_latitude(nc),...
			'LONGITUDE',get_longitude(nc),...
			'POSITIONING_SYSTEM',nc{'POSITIONING_SYSTEM'}(:,:),...
			'PRES',get_pres(nc),...
			'MAX_PRESSURE',nc{'MAX_PRESSURE'}(:),...
			'DEPH',-nc{'DEPH'}(:,:)...
			...
			);			

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fill in Data informations:
switch do_biogeo
	case 1
		T.data = fill_data(...
				'TEMP',fill_odata('TEMP',nc),...
				'PSAL',fill_odata('PSAL',nc),...
				'OXYL',fill_odata('OXYL',nc),...
				'OXYK',fill_odata('OXYK',nc),...
				'BRV2',fill_odata('BRV2',nc),...
				'SIGI',fill_odata('SIGI',nc),...
				'SIG0',fill_odata('SIG0',nc),...
				'PHOS',fill_odata('PHOS',nc),...
				'NITR',fill_odata('NITR',nc),...
				'ALKT',fill_odata('ALKT',nc),...
				'SIO2',fill_odata('SIO2',nc),...
				'CANT',fill_odata('CANT',nc),...
				'CTOT',fill_odata('CTOT',nc)...
				...
				);
	otherwise
		T.data = fill_data(...
				'TEMP',fill_odata('TEMP',nc),...
				'PSAL',fill_odata('PSAL',nc),...
				'OXYL',fill_odata('OXYL',nc),...
				'OXYK',fill_odata('OXYK',nc),...
				'BRV2',fill_odata('BRV2',nc),...
				'SIGI',fill_odata('SIGI',nc),...
				'SIG0',fill_odata('SIG0',nc)...
				...
				);
end

close(nc);clear nc

T = clean_empty_variables(T);

switch nargout
	case 1
		varargout(1) = {T};
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = fill_odata(varn,nc)
	
	if ~isempty(nc{varn}(:,:))
		c = nc{varn}(:,:);
		try % Try to get sure we're not doing crap:
			p = par_code(varn);
			c(c<p{1}.valid_min | c > p{1}.valid_max) = NaN;
		end
			
		D = odata(...
			'long_name',clean_spc(nc{varn}.long_name(:)),...
			'long_unit',clean_spc(nc{varn}.units(:)),...
			'unit',shorten_unit(strtrim(nc{varn}.units(:))),...
			'cont',c,...
			'prec',nc{sprintf('PROFILE_%s_PREC',varn)}(:),...
			'name',varn...
			...
			);
	else	
		D = NaN;
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = fill_data(varargin)
	
	% INIT:
	D.dummy = '';
		
	% THEN MODIFY OBJECT USING SPECIFIED VALUES:
	n = nargin;
	if mod(n,2) ~= 0,
		error('Invalid number of input arguments');
	else
		for iprop = 1 : 2 : n
			prop_nam = varargin{iprop};
			prop_val = varargin{iprop+1};
			if isa(prop_val,'odata') | strcmp(prop_nam,'STATION_PARAMETERS') | strcmp(prop_nam,'PARAMETERS_STATUS')
				D = setfield(D,prop_nam,prop_val);
			end
		end
	end
	
	% FINISH 
	D = rmfield(D,'dummy');	
	
end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function A = fill_axes(varargin)
	
	% Init
	A.dummy = '';
	if 0
		% Stations:	
		A.STATION_NUMBER = 0;
		A.STATION_DATE = 0;
		% Lat/Lon:
		A.LATITUDE = 0;
%		A.LATITUDE_BEGIN = 0;
%		A.LATITUDE_END = 0;
		A.LONGITUDE = 0;
%		A.LONGITUDE_BEGIN = 0;
%		A.LONGITUDE_END = 0;
		A.POSITIONING_SYSTEM = '';
		% Vertical axis:
		A.PRES = 0;
		A.MAX_PRESSURE = 0;
		A.DEPH = 0;
	end
	% then modify object using specified values:
		n = nargin;
		if mod(n,2) ~= 0,
			error('Invalid number of input arguments');
		else
			for iprop = 1 : 2 : n
				prop_nam = varargin{iprop};
				prop_val = varargin{iprop+1};
				if check_prop(prop_nam)
					A = setfield(A,prop_nam,prop_val);
				else
					error('Invalid propertie name for axes structure');
				end
			end
		end
	A = rmfield(A,'dummy');
	
	%
	function OK = check_prop(P)
		if 		strcmp(P,'STATION_NUMBER'), OK = true;
		elseif	strcmp(P,'STATION_DATE'), OK = true;
%		elseif	strcmp(P,'STATION_DATE_BEGIN'), OK = true;
%		elseif	strcmp(P,'STATION_DATE_END'), OK = true;
		elseif	strcmp(P,'LATITUDE'), OK = true;
%		elseif	strcmp(P,'LATITUDE_BEGIN'), OK = true;
%		elseif	strcmp(P,'LATITUDE_END'), OK = true;
		elseif	strcmp(P,'LONGITUDE'), OK = true;
%		elseif	strcmp(P,'LONGITUDE_BEGIN'), OK = true;
%		elseif	strcmp(P,'LONGITUDE_END'), OK = true;
		elseif	strcmp(P,'POSITIONING_SYSTEM'), OK = true;
		elseif	strcmp(P,'PRES'), OK = true;
		elseif	strcmp(P,'MAX_PRESSURE'), OK = true;
		elseif	strcmp(P,'DEPH'), OK = true;
		else, OK = false;
		end
	end

end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cp0 = get_date(nc)
	if ~isempty(nc{'STATION_DATE_BEGIN'}(:))	
		c1 = datenum(nc{'STATION_DATE_BEGIN'}(:),'yyyymmddHHMMSS');
		c2 = datenum(nc{'STATION_DATE_END'}(:),'yyyymmddHHMMSS');
		if length(find(c1-c2~=0)) >= 1
			cp0 = (c1+c2)/2;
		else
			cp0 = datenum(nc{'STATION_DATE_BEGIN'}(:),'yyyymmddHHMMSS');
		end
	else
		REFERENCE_DATE_TIME = nc{'REFERENCE_DATE_TIME'};
		ref = datenum(str2num(REFERENCE_DATE_TIME(1:4)),...
				str2num(REFERENCE_DATE_TIME(5:6)),...
				str2num(REFERENCE_DATE_TIME(7:8)),...
				str2num(REFERENCE_DATE_TIME(9:10)),...
				str2num(REFERENCE_DATE_TIME(11:12)),...
				str2num(REFERENCE_DATE_TIME(13:14)));
		tim = nc{'JULD_LOCATION'} + ref;
		cp0 = tim;
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cp0 = get_pres(nc)
	cp0 = nc{'PRES'}(:,:);
	
	try % Try to get sure we're not doing crap:
		p = par_code('PRES');
		cp0(cp0<p{1}.valid_min | cp0 > p{1}.valid_max) = NaN;
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cp0 = get_latitude(nc)
	
	if ~isempty(intersect(ncvarname(nc),'LATITUDE_BEGIN'))
		c1 = nc{'LATITUDE_BEGIN'}(:);
		c2 = nc{'LATITUDE_END'}(:);
		if length(find(isnan(c2)==1)==length(c2))
			cp0 = c1;
		else
			cp0 = (c1+c2)/2;
		end
		
	elseif ~isempty(intersect(ncvarname(nc),'LATITUDE'))
		cp0 = nc{'LATITUDE'}(:);		
	else
		error('I don''t know how to find the latitude in this netcdf file');
	end	
		
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cp0 = get_longitude(nc)
	
	if ~isempty(intersect(ncvarname(nc),'LONGITUDE_BEGIN'))
		c1 = nc{'LONGITUDE_BEGIN'}(:);
		c2 = nc{'LONGITUDE_END'}(:);
		if length(find(isnan(c2)==1)==length(c2))
			cp0 = c1;
		else
			cp0 = (c1+c2)/2;
		end
	elseif ~isempty(intersect(ncvarname(nc),'LATITUDE'))
		cp0 = nc{'LONGITUDE'}(:);	
	else
		error('I don''t know how to find the longigutde in this netcdf file');	
	end

	% Move to longitude east from 0 to 360	
	cp0(cp0>=-180 & cp0<0) = 360 + cp0(cp0>=-180 & cp0<0);
	
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = clean_spc(s)
	for ii=1:10
		s = strrep(s,'  ',' ');
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = ncvarname(varargin)

nc = varargin{1};
if ~isa(nc,'netcdf')
	error('ncvarname only take as argument a netcdf object')
end

v = var(nc);
for iv = 1 : length(v)
	namelist(iv) = {name(v{iv})};
end
namelist = sort(namelist);

if nargout == 0
	for iv=1:length(namelist)
		disp(namelist{iv})
	end
else
	varargout(1) = {namelist};
end



end %functionncvarname
