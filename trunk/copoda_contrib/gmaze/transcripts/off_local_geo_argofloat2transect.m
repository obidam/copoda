% local_geo_argofloat2transect Load all Argo profiles from 1 float as a transect object
%
% T = local_geo_argofloat2transect(PATHD,FLOATid,[PERIOD,DOMAIN,QC])
% 
% Load all local profiles from 1 float and return them as a transect object.
%
% This function assumes netcdf Argo files are organized with the Argo ftp site view GEO:
%	Starting from PATHD:
% 		a directory per ocean
% 		a directory per year in the ocean
% 		a directory per month of the year
% 		a directory per day of the month
% 		a file per profile of the day
%
% Then your data path PATHD should be as from the ftp DAC website structure 
% starting after:
% 	ftp://ftp.ifremer.fr/ifremer/argo/geo/
% or
% 	ftp://usgodae.org/pub/outgoing/argo/geo/
% PATHD is the path to replace the previous online ftp urls.
%
% Inputs:
%	PATHD: a string to indicate where the netcdf Argo files are
%	FLOATid: the ID of the float
%	PERIOD: a time serie of days (as return by datenum) you want the data for
%	DOMAIN: [LONmin LONmax LATmin LATmax] a 4 double values to indicates the
%		box coordinates you want the data for
%	QC: 
% 
% Outputs:
%	T: the transect object
%
% Example:
%	pathd   = '~/data/ARGO/ftp.ifremer.fr/ifremer/argo/geo/atlantic_ocean';
%	floatid = 
%	T       = local_geo_argofloat2transect(pathd,floatid);
%	
% Created: 2009-11-25.
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


function T = local_geo_argofloat2transect(varargin)
	
data_path = varargin{1};
%data_path = '~/data/ARGO/ftp.ifremer.fr/ifremer/argo/geo/atlantic_ocean';
data_path = abspath(data_path);

floatID = varargin{2};

if nargin >= 3
	per = varargin{3};
else
	per = datenum(2003,1,1,0,0,0) : now;
end
if nargin >= 4
	domain = varargin{4};
else
	domain = [0 360 -90 90];
end
if nargin >= 5
	qc_level = varargin{5};
else
	qc_level = 1;
end

global sla

%%%%%%%%%%%%%%%%%%%%%%%
ii = 0; iter = 0;
blk = ' ';
h = waitbar(0,'Please wait...');drawnow

for id = 1 : length(per);
	waitbar(id/length(per),h,sprintf('Scanning %s',datestr(per(id))));drawnow
	year  = str2num(datestr(per(id),'yyyy'));
	month = str2num(datestr(per(id),'mm'));
	day   = str2num(datestr(per(id),'dd'));
	file  = sprintf('%0.4i%s%0.2i%s%0.4i%0.2i%0.2i_prof.nc',year,sla,month,sla,year,month,day);
	file  = sprintf('%s%s%s',data_path,sla,file);
	if exist(file,'file')
		ii = ii + 1;
		% Open the netcdf file with all the profiles of that day:
		nc   = netcdf(file,'nowrite');
		LIST = get_idlist(nc); % Get the list of platforms within this file
		if ~isempty(intersect(LIST,floatID)) % Is the float we want in it ?
			% If yes, we identify the profiles of this float:
			ip = get_plist(nc,floatID);
			% then we select only those in the domain we want:
			[ip x y] = argo_selectD(nc,domain,ip);
			
			% If we found at least one profile, we load it:
			if ~isnan(ip)
				d = argo_data(nc,ip,qc_level);
				if isa(d,'struct')
					for ik = 1 : length(d) % Just in case we do have more than 1 profil the same day !
						iter = iter + 1;
						data(iter) = d(ik);
						X(iter) = x(ik);
						Y(iter) = y(ik);
						tim(iter) = per(id);
					end
				end
%				if ~exist('X','var'),X = x; Y = y;else,X = [X ;x]; Y = [Y ;y];end
			end
		end%if ID ok
		close(nc);
	end%if
end%forid
close(h);	

try 
	%%%% Check if the temperature is defined everywhere:
	for id = 1 : length(data)
		if ~isempty(data(id).TEMP)
			if ~isnan(data(id).TEMP(1))
				ikeep(id) = 1;
			else
				ikeep(id) = 0;
			end
		else
			ikeep(id) = 0;
		end
	end
	data = data(ikeep==1);
	X = X(ikeep==1);
	Y = Y(ikeep==1);
	tim = tim(ikeep==1);

	%%%% Now we create the transect object:
	T = transect;
	T.file = sprintf('%s/*',data_path);
	% CRUISE INFORMATIONS :
	T.cruise_info = cruise_info(...
						'NAME',sprintf('%s',floatID),...
						'PI_NAME',check_single(data,'PI_NAME'),...
						'PI_ORGANISM','?',...
						'SHIP_NAME',argo_table8(data(1).WMO_INST_TYPE),...
						'SHIP_WMO_ID',check_single(data,'WMO_INST_TYPE'),...
						'DATE',[min(tim) max(tim)],...
						'N_STATION',length(tim)...
						...
						);

	% AXIS:					
	geo.STATION_DATE = tim';
	geo.STATION_NUMBER = [1:length(tim)]';
	geo.LATITUDE = Y';
	geo.LONGITUDE = X';
	geo.POSITIONING_SYSTEM = check_single(data,'POSITIONING_SYSTEM');
	PRES = struct2table(data,'PRES');
	geo.PRES = PRES;
	geo.MAX_PRESSURE = max(PRES,[],2);
	geo.DEPH = -abs(sw_dpth(PRES,Y'));
	T.geo = geo;

	% DATAS:
	if ~strcmp(data(1).TEMP_unit,'degree_Celsius')
		warning(sprintf('This float has a weird temperature unit: %s',data(1).TEMP_unit));
	end
	od.TEMP = odata(...
		'long_name','Temperature',...
		'long_unit','degreeC',...
		'unit','degC',...
		'cont',struct2table(data,'TEMP'),...
		'prec',NaN,...
		'name','TEMP');
	if ~strcmp(data(1).PSAL_unit,'psu')
		warning(sprintf('This float has a weird salinity unit: %s',data(1).TEMP_unit));
	end
	od.PSAL = odata(...
		'long_name','Salinity',...
		'long_unit','PSU',...
		'unit','PSU',...
		'cont',struct2table(data,'PSAL'),...
		'prec',NaN,...
		'name','PSAL');	
	
	if ~strcmp(data(1).DOXY_unit,'micromole/kg')
		warning(sprintf('This float has a weird oxygen unit: %s',data(1).TEMP_unit));
	end	
	if length(find(isnan(struct2table(data,'DOXY'))==1)) == numel(struct2table(data,'DOXY'))
		% We're not adding oxygen because it is full of NaN !
	else
		od.OXYK = odata(...
			'long_name','Oxygen',...
			'long_unit','mumol/kg',...
			'unit','mumol/kg',...
			'cont',struct2table(data,'DOXY'),...
			'prec',NaN,...
			'name','OXYK');
	end
	od = orderfields(od);
	T.data = od;
catch
	warning('Couldn''t load datas');
	T = NaN;
end
		
end %functionargo_load1float

%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%
% Fill a matrix from data structure content of field Cname
function C = struct2table(data,Cname)
	for ii = 1 : length(data)
		n(ii) = length(getfield(data,{ii},Cname));
	end
	n = max(n);
	C = zeros(length(data),n).*NaN;
	for ii = 1 : length(data)
		c = getfield(data,{ii},Cname);
		C(ii,1:length(c)) = c;
	end
end
%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%


%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%
% Load profiles from netcdf files
function PI = check_single(data,name)
	for ii = 1 : length(data)
		PI = {getfield(data,{ii},name)};
	end
	PI = unique(PI);
	if length(PI) > 1
		warning(sprintf('I found more than 1 %s associated with this float',name));
		pin = PI{1};
		for ii = 2 : length(PI)
			pin = sprintf('%s, %s',pin,PI{ii});
		end		
	else
		PI = PI{1};
	end
end

%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%
% Load profiles from netcdf files
function data = argo_data(cdf,ip,qc_level);
	ipok = 0;
	for ii = 1 : length(ip)
		iprof   = ip(ii);
		temp    = cdf{'TEMP'}(iprof,:);
		nlevels = size(temp,2);clear temp
		
		% Quality control:
		icok = argo_qc(cdf,iprof,nlevels,qc_level);

		% Load fields ok:
		if ~isempty(icok)
			ipok = ipok + 1;
			if 1
				
				data(ipok).PRES = load_fromnc(cdf,'PRES',iprof,icok);
				data(ipok).TEMP = load_fromnc(cdf,'TEMP',iprof,icok);
				data(ipok).PSAL = load_fromnc(cdf,'PSAL',iprof,icok);
				data(ipok).DOXY = load_fromnc(cdf,'DOXY',iprof,icok);
				
				% Pressure:
%				data(ipok).PRES      = cdf{'PRES'}(iprof,icok);
				data(ipok).PRES_unit = cdf{'PRES'}.units(:);
				% Temperature:
%				data(ipok).TEMP      = cdf{'TEMP'}(iprof,icok);
				data(ipok).TEMP_unit = cdf{'TEMP'}.units(:);
				% Salinity:
%				data(ipok).PSAL      = cdf{'PSAL'}(iprof,icok);
				data(ipok).PSAL_unit = cdf{'PSAL'}.units(:);
				% Oxygen:
%				data(ipok).DOXY      = cdf{'DOXY'}(iprof,icok);
				data(ipok).DOXY_unit = cdf{'DOXY'}.units(:);				
				
			else
				% Pressure:
				data(ipok).PRES    = cdf{'PRES_ADJUSTED'}(iprof,icok);
				% Temperature:
				data(ipok).TEMP    = cdf{'TEMP_ADJUSTED'}(iprof,icok);
				% Salinity:
				data(ipok).PSAL    = cdf{'PSAL_ADJUSTED'}(iprof,icok);
				% Oxygen:
				data(ipok).DOXY    = cdf{'DOXY_ADJUSTED'}(iprof,icok);
			end
			% Meta informations:
			data(ipok).PI_NAME = strrep(cdf{'PI_NAME'}(iprof,:)','  ','');
			data(ipok).DATA_CENTRE = strrep(cdf{'DATA_CENTRE'}(iprof,:)','  ','');
			data(ipok).WMO_INST_TYPE = strrep(cdf{'WMO_INST_TYPE'}(iprof,:)',' ','');
			data(ipok).POSITIONING_SYSTEM = strrep(cdf{'POSITIONING_SYSTEM'}(iprof,:)',' ','');
		end%if QC passed 		
	end%for iprof
	if ~exist('data','var')
		data = NaN;
	end	
end%function
%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%


%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%
% Wrapper to read unregular indices from nc fields
function C = load_fromnc(cdf,Cname,iprof,icok);

%% This should be as simple as:
%%	C = cdf{Cname}(iprof,icok);
%% but when iprof or icok are not regular, we do have a warning:
%%	## Indexing strides must be positive and constant.
%% So we load inside a loop if this is the case

if ~isempty(intersect(Cname,ncvarname(cdf))) % Check if variable is available the file:
	if      any(diff(diff(iprof))) &  any(diff(diff(icok)))
		for ip = 1 : length(iprof)
			for ic = 1 : length(icok)
				C(ip,ic) = cdf{Cname}(iprof(ip),icok(ic));
			end%for ic
		end%for ip
		return
	elseif  any(diff(diff(iprof))) & ~any(diff(diff(icok)))
		for ip = 1 : length(iprof)
			C(ip,:) = cdf{Cname}(iprof(ip),icok);
		end%for ip
			return
	elseif ~any(diff(diff(iprof))) &  any(diff(diff(icok)))
		for ic = 1 : length(icok)
			C(:,ic) = cdf{Cname}(iprof,icok(ic));
		end%for ic
			return
	elseif ~any(diff(diff(iprof))) & ~any(diff(diff(icok)))
		C = cdf{Cname}(iprof,icok);
		return
	else
		warning('weird we''re here !')
		C = NaN;
		return
	end
else
	disp(sprintf('Warning: %s not available in %s',Cname,name(cdf)))
	C = NaN;
	return
end%if
	
end%function

%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%
% Quality control of each profiles
function icok = argo_qc(cdf,iprof,nlevels,qc_level);
	cok      = zeros(1,nlevels);		
	v1=double('1');
	v2=double('2');
	v5=double('5');
	PRES_QC  = double(cdf{'PRES_QC'}(iprof,1:nlevels));
	TEMP_QC  = double(cdf{'TEMP_QC'}(iprof,1:nlevels));
	PSAL_QC  = double(cdf{'PSAL_QC'}(iprof,1:nlevels));
	
%	qc_level = 1;
	switch qc_level
		case 1
			cok(   (TEMP_QC == v1 | TEMP_QC == v2 | TEMP_QC == v5) & ...
			       (PSAL_QC == v1 | PSAL_QC == v2 | PSAL_QC == v5) & ...
			 	   (PRES_QC == v1 | PRES_QC == v2 | PRES_QC == v5)) = 1;
		case 2
			cok(   (TEMP_QC == v1 | TEMP_QC == v2) & ...
			       (PSAL_QC == v1 | PSAL_QC == v2) & ...
			 	   (PRES_QC == v1 | PRES_QC == v2)) = 1;
		case 3
			cok(   (TEMP_QC == v1) & ...
			       (PSAL_QC == v1) & ...
			 	   (PRES_QC == v1)) = 1;
	end%switch
	icok = find(cok==1);
end%function
%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%

%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%
% Select profiles within the domain required
function [ip x y] = argo_selectD(cdf,domain,ip2);
	x = cdf{'LONGITUDE'}(:); 				   % Longitude from -180 to 180
	x(x>=-180 & x<0) = 360 + x(x>=-180 & x<0); % Move to longitude from 0 to 360
	y   = cdf{'LATITUDE'}(:);
	ip = find(x>=domain(1) & x<=domain(2) & y>=domain(3) & y<=domain(4));
	ip = intersect(ip,ip2);
	if ~isempty(ip) % is longitude/latitude into the domain ?
		x = x(ip);
		y = y(ip);
	else
		ip = NaN;
		x  = NaN;
		y  = NaN;
	end%if long/lat ok
end%function
%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%

%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%
% Get indices of the platform we're looking for
function ip = get_plist(nc,floatID);
	PLATFORM_NUMBER = nc{'PLATFORM_NUMBER'}(:);
	for ii = 1 : size(PLATFORM_NUMBER,1)
		if strcmp(deblank(floatID),deblank(PLATFORM_NUMBER(ii,:)))
			if ~exist('ip','var')
				ip = ii;
			else
				ip = [ip ii];
			end
		end
	end%for ii
end
%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%

%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%
% Get platform number list (as a cell)
function LIST = get_idlist(nc)
	PLATFORM_NUMBER = nc{'PLATFORM_NUMBER'}(:);
	for ii = 1 : size(PLATFORM_NUMBER,1)
		LIST(ii,:) = {deblank(PLATFORM_NUMBER(ii,:))};
	end
	LIST = unique(LIST);
end
%%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%














