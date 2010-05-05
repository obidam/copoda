% geoargo2database Create a database object from Argo multi-station netcdf files
%
% D = geoargo2database(GEOPATH,[OPTIONS,VALUE])
% 
% This function creates a database object from Argo profiles.
% Each transect object of the database corresponds to a unique Argo float.
%
% Inputs:
%	GEOPATH: the path to files (see below)
%	OPTIONS can be:
%		'PERIOD' a 2 doubles table with the starting and ending dates (as 
%			returned by datenum) for which you want the profiles.
%		'DOMAIN' a 4 doubles table with the box you want the profiles in.
%			like: [LON_min LON_max LAT_min LAT_max]
%		'DOXY' a logical value to indicate if you want only floats with 
%			oxygen datas.
%		'QC' a string test to indicate the Profile Quality Control Flag to select.
%				Eg: 'QC','QC >= A'
%				Eg: 'QC','QC==1 | QC==2'
%				Eg: 'QC','QC~=5'
%		'DMODE' a string (R or D) to indicate if you want to select Data Mode
%				to be R (Real time) or D (Delayed time).
%				
% Argo netcdf profiles must be located under the local directory GEOPATH such like:
%	Starting from GEOPATH:
% 		a directory per ocean
% 		a directory per year in the ocean
% 		a directory per month of the year
% 		a file per profile of the day
% This is exactly the folder structure as downloaded from the ftp websites:
%	ftp://ftp.ifremer.fr/ifremer/argo/geo/
%	ftp://usgodae.org/pub/outgoing/argo/geo/
% For example, we'll find file:
%	GEOPATH/atlantic_ocean/2008/08/20080821_prof.nc
%
% If GEOPATH is an empty string the function uses:
%	GEOPATH = '/Users/gmaze/data/ARGO/ftp.ifremer.fr/ifremer/argo/geo';
%
%
% Created: 2010-04-29.
% Copyright (c) 2010, Guillaume Maze (Laboratoire de Physique des Oceans).
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

function varargout = geoargo2database(varargin)

%%%%%%%%%%%%%%% Default options:
GEOPATH = varargin{1};
if isempty(GEOPATH)
	GEOPATH = '/Users/gmaze/data/ARGO/ftp.ifremer.fr/ifremer/argo/geo';
end
PERIOD = [datenum(2003,1,1,0,0,0) now];
DOMAIN = [0 360 0 90];
WITH_OXYGEN = false;
PROFQ = 'A';
DMODE = 'R';
%%%%%%%%%%%%%%% 

%%%%%%%%%%%%%%% User options:
[res out] = check_options(varargin{:}); % We assignin from overthere new options value here
if ~res,error(out);end
%%%%%%%%%%%%%%% 

%%%%%%%%%%%%%%% Get the list of Argo files:
disp(sprintf('Scanning folder GEOPATH for multi-stations profile Argo netcdf files:\n%s ...',GEOPATH));
file_list = get_list_of_ncfiles(GEOPATH);
Nf = length(file_list);
%%%%%%%%%%%%%%% 

%%%%%%%%%%%%%%% 1st apply the PERIOD selection
tokeep = zeros(1,Nf);
for ifil = 1 : Nf
	dat = getdatenum(file_list,ifil);
	if dat >= PERIOD(1) & dat <= PERIOD(2)
		tokeep(ifil) = 1;
	end
end%for ifil
file_list = file_list(tokeep==1);
Nf = length(file_list);
clear tokeep dat ifil

%OPTIONS(1,:) = {'PLATFORM_NUMBER','strcmp(X,''1900609'')'};
OPTIONS(1,:) = {'DATA_MODE','strcmp(X,''D'')'};
OPTIONS(2,:) = {'LATITUDE', 'X>=-90 && X<= 90'};
OPTIONS(3,:) = {'LONGITUDE','X>=-180 && X<= 0'};

%%%%%%%%%%%%%%% Now re-scan the list and apply options criteria
D = database;
openD = false;
PTFlist = {};

for ifil = 1 : Nf
	file = file_list(ifil).abspath{1};
	nojvmwaitbar(Nf,ifil,sprintf('Scanning file (%0.4d/%i):\n%s',ifil,Nf,file));
	
	% From each file we check if all options are verified.	
	d = argomultiprof2database(file,OPTIONS);
	if isa(d,'database')
		if ~openD
			D.transect = d.transect;			
			openD = true;
		else					
			D = updatedatabase(D,d);
		end
	end
end%for ifil
%%%%%%%%%%%%%%% 



end %functiongeoargo2database
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function Dnew = updatedatabase(Dold,Dnew)
	
	PTFlist_new = getPTFlist(Dold);
	PTFlist_old = getPTFlist(Dnew);
	[id tobeupdated] = intersect(PTFlist_new,PTFlist_old);
	[id tobeadded  ] = setdiff(PTFlist_new,PTFlist_old);
	
	% Add new ones:
	if ~isempty(tobeadded)
		Dold.transect = [Dold.transect Dnew.transect(tobeadded)];
	end
	
	% Update the others:
	for it = 1 : length(tobeupdated)
		
	end%for it
	
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function PTFlist = getPTFlist(D);
	for it = 1 : length(D.transect)
		PTFlist(it) = {D.transect{it}.cruise_info.NAME};
	end%for it
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function dat = getdatenum(file_list,ifil)
	
try 	
	year   = str2num(file_list(ifil).year{1});
	month  = str2num(file_list(ifil).month{1});
	ncfile = file_list(ifil).ncfile{1}; % YYYYMMDD_prof.nc
	if isempty(file_list(ifil).day{1})
		day = str2num(ncfile(7:8));
	elseif strcmp(file_list(ifil).day{1},ncfile(7:8))
		day = str2num(file_list(ifil).day{1});
	end
	dat = datenum(year,month,day,0,0,0);
catch
	dat = NaN;
end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Get the list of Argo netcdf files and all informations to access them
function file_list = get_list_of_ncfiles(pathd);
	if ispc, sla = '\'; else, sla = '/'; end
	
	oceans = dir(pathd);
	imp = 0;
	for iocean = 1 : length(oceans)
		if ~strcmp(oceans(iocean).name,'.') & ~strcmp(oceans(iocean).name,'..')
			ocean_name = oceans(iocean).name;

			years = dir(sprintf('%s%s%s',pathd,sla,ocean_name));
			for iyear = 1 : length(years)
				if ~strcmp(years(iyear).name,'.') & ~strcmp(years(iyear).name,'..')
					year_name = years(iyear).name;				

					month = dir(sprintf('%s%s%s%s%s',pathd,sla,ocean_name,sla,year_name));
					for imonth = 1 : length(month)
						if ~strcmp(month(imonth).name,'.') & ~strcmp(month(imonth).name,'..')
							month_name = month(imonth).name;

							day = dir(sprintf('%s%s%s%s%s%s%s',pathd,sla,ocean_name,sla,year_name,sla,month_name));

							for iday = 1 : length(day)
								if ~strcmp(day(iday).name,'.') & ~strcmp(day(iday).name,'..')
									day_name = day(iday).name;
									switch day(iday).isdir
										case 0 % We have daily profiles in the monthly directory
											if strfind(day_name,'_prof.nc')
												%disp(sprintf('%s%s%s%s%s%s%s%s%s',pathd,sla,ocean_name,sla,year_name,sla,month_name,sla,day_name))
												% day_name is supposed to be like: YYYYMMDD_prof.nc
												if ~strcmp(sprintf('%s%s',year_name,month_name),day_name(1:6))
													error(sprintf('Found a file (%s) with weired format !',day_name));
												else
													%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
													file = sprintf('%s%s%s%s%s%s%s%s%s',pathd,sla,ocean_name,sla,year_name,sla,month_name,sla,day_name);
													
													% One last test is to check if DATA_TYPE is 'Argo profile'
%													nc = netcdf(file);
%													if strcmp(strtrim(nc{'DATA_TYPE'}(:)),'Argo profile')																										
														imp = imp + 1; 
														file_list(imp).abspath = {file};
														file_list(imp).ocean   = {ocean_name};
														file_list(imp).year    = {year_name};
														file_list(imp).month   = {month_name};
														file_list(imp).day     = {''};
														file_list(imp).ncfile  = {day_name};			
%													end		
%													close(nc);								
													%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
												end%file ok
											end
										case 1 % We have daily profiles in daily folder (not supposed to be !)
											error('');
											fil = dir(sprintf('%s%s%s%s%s%s%s%s%s',pathd,sla,ocean_name,sla,year_name,sla,month_name,sla,day_name));
											for ifil = 1 : length(fil)
												if ~strcmp(fil(ifil).name,'.') & ~strcmp(fil(ifil).name,'..')
													if strfind(fil(ifil).name,'_prof.nc')														
														%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
														file = sprintf('%s%s%s%s%s%s%s%s%s%s%s',pathd,sla,ocean_name,sla,year_name,sla,month_name,sla,day_name,sla,fil(ifil).name);
														
														% One last test is to check if DATA_TYPE is 'Argo profile'
%														nc = netcdf(file);
%														if strcmp(strtrim(nc{'DATA_TYPE'}(:)),'Argo profile')
															imp = imp + 1; 
															file_list(imp).abspath = {file};
															file_list(imp).ocean   = {ocean_name};
															file_list(imp).year    = {year_name};
															file_list(imp).month   = {month_name};
															file_list(imp).day     = {day_name};
															file_list(imp).ncfile  = {fil(ifil).name};			
%														end
%														close(nc);
														%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
													end
												end
											end%for ifil
									end%switch

								end%if
							end%for iday

						end%if
					end%for imonth

				end%if
			end%for iyear
		end%if
	end%for iocean
	
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [res out] = check_options(varargin)

	if nargin > 1
		if mod(nargin-1,2) ~=0
			msg.message    = 'Options must come by pair with their values, see help geoargo2database';
			msg.identifier = 'geoargo2database:invalidOption';
		end
		for in = 2 : 2: nargin-1
			opt = varargin{in};
			val = varargin{in+1};
			switch lower(opt)

				case 'period'
					if length(val) ~= 2					
						msg.message = 'PERIOD option must be 2 doubles matrix';
						msg.identifier = 'geoargo2database:invalidOption';
					elseif ~isnumeric(val)					
						msg.message = 'PERIOD option must be 2 doubles matrix';
						msg.identifier = 'geoargo2database:invalidOption';
					else
						PERIOD = sort(val);
						assignin('caller','PERIOD',PERIOD);
					end

				case 'domain'
					if ~isnumeric(val) 
						msg.message = 'DOMAIN option must be a 4 double table';
						msg.identifier = 'geoargo2database:invalidOption';
					elseif isnumeric(val) 
						if length(val) ~= 4
							msg.message = 'DOMAIN option must be a 4 double table';
							msg.identifier = 'geoargo2database:invalidOption';
						else
							% Valid longitudes:
							X = val(1:2);
							if find(X)<0 
								if find(abs(X)>180)
									msg.message = 'Longitudes in DOMAIN option must be between -180 and 180';
									msg.identifier = 'geoargo2database:invalidOption';
								else
									X(X>=-180 & X<0) = 360 + X(X>=-180 & X<0); % Move to longitude from 0 to 360
								end
							else
								if find(X>360)
									msg.message = 'Longitudes in DOMAIN option must be between 0 and 360';
									msg.identifier = 'geoargo2database:invalidOption';
								else
									% nothing, we already have X
								end
							end
							% Valid latitudes:
							Y = val(3:4);
							if find(abs(Y)>90)
								msg.message = 'Latitudes in DOMAIN option must be between -90 and 90';
								msg.identifier = 'geoargo2database:invalidOption';
							end						
						end					
					else
						msg.message = 'DOMAIN must be a string or double value table';
						msg.identifier = 'geoargo2database:invalidOption';
					end

				case 'doxy'
					if length(val) ~=1 
						msg.message = 'DOXY option must be single logical value';	
						msg.identifier = 'geoargo2database:invalidOption';				
					elseif ischar(val)
						msg.message = 'DOXY option must be single logical value';
						msg.identifier = 'geoargo2database:invalidOption';
					else
						WITH_OXYGEN = logical(val);
						assignin('caller','WITH_OXYGEN',WITH_OXYGEN);
					end
			end

		end%for in
	end

	if exist('msg','var')
		res = false;
		out = msg;
	else
		res = true;
		out = '';
	end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 









