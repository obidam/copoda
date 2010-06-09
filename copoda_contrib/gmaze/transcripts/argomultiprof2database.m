% argomultiprof2database Create a database object from a multi-station Argo netcdf file
%
% D = argomultiprof2database(NCFILE,[OPTIONS])
% 
% Create a database object from a multi-station Argo netcdf file
%
% Inputs:
%	NCFILE: absolute path to the netcdf Argo file
%	OPTIONS: this is a cell with a list of test to apply with success
%
% Outputs:
%	D: the database object where each transect object corresponds to a unique
%		Argo platform number.
%
% Help:
% OPTIONS is formed as follow:
%	OPTIONS(1,:) = {'PROFILE_TEMP_QC';'strcmp(X,''A'')'};
%	OPTIONS(1,:) = {'TEMP_QC';'strcmp(X,''A'')'};
%	OPTIONS(2,:) = {'DATA_MODE','strcmp(X,''R'')'};
%	OPTIONS(3,:) = {'LATITUDE','X >= 0 & X <= 45'};
%	OPTIONS(1,:) = {'PLATFORM_NUMBER','strcmp(X,''1900609'')'}
%
%
% Created: 2010-04-29.
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
function D = argomultiprof2database(varargin)

ncfile = varargin{1};
if ~exist(ncfile,'file')
	error('Cannot find netcdf file')
end

% List of tests:
if nargin == 2
	OPTIONS = varargin{2};
	% To do: a test to validate OPTIONS
else
	OPTIONS(1,:) = {'DATA_TYPE','X == ''Argo profile'''};
end

% Automatic retrieval of scaled variable with NaNs in place of the fill value
global nctbx_options;
nctbx_options.theAutoNaN = 1;
nctbx_options.theAutoscale = 1;

% Open file
nc = netcdf(ncfile,'nowrite');
[ndims, nvars, ngatts, theRecdimid, status] = ncmex('inquire',ncid(nc));
if status == -1
	error('Badly open netcdf file, please double check it ...')
end

% Parameters we need before starting:
[N_PROF N_LEVELS] = getsize(nc);
varlist = ncvarname(nc);

% Let's go
profiles_tokeep = 1:N_PROF;
done = 0;
ip = 0;
while done ~= 1
	
	% We iterate through OPTIONS and reduce profiles_tokeep accordingly
	ip = ip + 1;
	vartotest = OPTIONS{ip,1};
	if isempty(intersect(vartotest,varlist))
		error(sprintf('Variable %s is not in the netcdf file !',vartotest));
	end
	
	% Perform the test on profiles in profiles_tokeep:
	ncv  = nc{vartotest};			
	dims = getdim_list(ncv);
	[a idir] = intersect(dims,'N_PROF');
	if ~isempty(idir)			
		cont = load_theseprofiles(nc,vartotest,profiles_tokeep);
							
		switch length(dims)
			case 1
				expr = strrep(OPTIONS{ip,2},'X','cont(ic)');
			case 2
				if strfind(dims{2},'STRING')
					expr = strrep(OPTIONS{ip,2},'X','strtrim(cont(ic,:))');
				elseif strfind(dims{2},'N_LEVELS')
					expr = strrep(OPTIONS{ip,2},'X','cont(ic,1)');
				end
			otherwise
				error('I don''t know how to do with more than 2 dimensions !')
		end%switch
		clear res
		for ic = 1 : length(profiles_tokeep)
			res(ic) = eval(expr);			
		end
		profiles_tokeep = profiles_tokeep(find(res==true));
	
	else
		if strfind(dims{1},'STRING')
			cont = nc{vartotest}(:);
			expr = strrep(OPTIONS{ip,2},'X','strtrim(cont)');
			res  = eval(expr);
			if ~res
				profiles_tokeep = [];
			end
		else
			error('I don''t know how to do that');
		end
	end
		
	if isempty(profiles_tokeep)
		done = 1;
	else
		if ip == size(OPTIONS,1)
			done = 1;
		end
	end
	
end%while
if isempty(profiles_tokeep)
	close(nc);
	D = NaN;
	return
else
	Nfloats = length(profiles_tokeep);
end	
	

% Otherwise we Initiate the database:
D = database;
D.name = 'Argo profiles';
D.description = {ncfile};

% Loop over Float IDs and create transects with what we need
for ifloat = 1 : Nfloats
	T = thisnc2transect(nc,profiles_tokeep(ifloat));
	trans_list(ifloat) = {T};
end
D.transect = trans_list;
close(nc);

end %functionargomultiprof2database
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load specific profiles for a given variable in the netcdf
% file. It should be as simple as:
% C = cdf{Cname}(iprof,:);
% but when iprof is not regular, we do have a warning:
% ## Indexing strides must be positive and constant.
% So we load inside a loop if this is the case
function cont = load_theseprofiles(nc,vartotest,profiles_tokeep);
		
	N        = length(profiles_tokeep);
	ncv      = nc{vartotest};
	dims     = getdim_list(ncv);
	[a idir] = intersect(dims,'N_PROF');
	
	switch length(dims)
		case 1
			switch idir
				case 1, 
					for ip = 1 : N
						cont(ip) = nc{vartotest}(profiles_tokeep(ip));
					end%for ip
			end
		case 2
			switch idir
				case 1, 
					for ip = 1 : N
						cont(ip,:) = nc{vartotest}(profiles_tokeep(ip),:);
					end%for ip
				case 2, 
					for ip = 1 : N
						cont(:,ip) = nc{vartotest}(:,profiles_tokeep(ip));
					end%for ip
			end
		case 3
			switch idir
				case 1, 
					for ip = 1 : N
						cont(ip,:,:) = nc{vartotest}(profiles_tokeep(ip),:,:);
					end%for ip
				case 2, 
					for ip = 1 : N
						cont(:,ip,:) = nc{vartotest}(:,profiles_tokeep(ip),:);
					end%for ip
				case 3,
					for ip = 1 : N
						cont(:,:,ip) = nc{vartotest}(:,:,profiles_tokeep(ip));
					end%for ip
			end
		otherwise
			error('I don''t know how to do with more than 3 dimensions !')
	end%switch

end%function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a transect object for one float from one nc file
function T = thisnc2transect(nc,iprof)
	
	take_adjusted = true;
	fillincontent = false;
	
	readnc(nc,iprof); % This function retrieve all fields of 1 profile here !
	nl = length(nc('N_LEVELS'));
	if nl == length(isnan(PRES_ADJUSTED)) % IF ADJUSTED TABLES ARE FULL OF NANS, NOT ADJUSTED
		had_been_adjusted = false;
	else
		had_been_adjusted = true;
	end

	% 'CRUISE' INFORMATIONS
	cinfo = cruise_info(...
		'NAME',sprintf('%s',strtrim(PLATFORM_NUMBER)),...
		'PI_NAME',strtrim(PI_NAME),'PI_ORGANISM','',...
		'SHIP_NAME',argo_table8(WMO_INST_TYPE),'SHIP_WMO_ID','ARGO',...
		'DATE',[1 1]*get_t0(nc)+JULD_LOCATION,...
		'N_STATION',1);
	
	% 'GEO' INFORMATIONS
	geo.STATION_NUMBER     = CYCLE_NUMBER;
	geo.STATION_DATE       = get_t0(nc)+JULD_LOCATION;
	geo.STATION_CYCLE      = CYCLE_NUMBER;
	geo.STATION_DIRECTION  = DIRECTION;
	geo.LATITUDE           = LATITUDE;
	geo.LONGITUDE          = LONGITUDE;
	geo.POSITIONING_SYSTEM = strtrim(POSITIONING_SYSTEM);
	geo.ADJUSTED           = had_been_adjusted;
	if had_been_adjusted & take_adjusted
		geo.PRES = PRES_ADJUSTED;
	else				 
		geo.PRES = PRES;
	end
	geo.DEPH = 0;
		
	% ODATAS
	switch fillincontent
		case true
			if had_been_adjusted && take_adjusted
				data.TEMP = odata('name','TEMP','long_name',strtrim(nc{'TEMP'}.long_name(:)),...
					'long_unit',nc{'TEMP'}.units(:),'unit',shorten_unit(nc{'TEMP'}.units(:)),...
					'cont',TEMP_ADJUSTED);
				data.PSAL = odata('name','PSAL','long_name',strtrim(nc{'PSAL'}.long_name(:)),...
					'long_unit',nc{'PSAL'}.units(:),'unit',shorten_unit(nc{'PSAL'}.units(:)),...
					'cont',PSAL_ADJUSTED);
				data.CNDC = odata('name','CNDC','long_name',strtrim(nc{'CNDC'}.long_name(:)),...
					'long_unit',nc{'CNDC'}.units(:),'unit',shorten_unit(nc{'CNDC'}.units(:)),...
					'cont',CNDC_ADJUSTED);
				% Dissolved oxygen in Argo profile should be in mumol/kg, so we call OXYK
				if ~isempty(nc{'DOXY'})
					data.OXYK = odata('name','DOXY','long_name',strtrim(nc{'DOXY'}.long_name(:)),...
						'long_unit',nc{'DOXY'}.units(:),'unit',shorten_unit(nc{'DOXY'}.units(:)),...
						'cont',DOXY_ADJUSTED);
				end
			else
				data.TEMP = odata('name','TEMP','long_name',strtrim(nc{'TEMP'}.long_name(:)),...
					'long_unit',nc{'TEMP'}.units(:),'unit',shorten_unit(nc{'TEMP'}.units(:)),...
					'cont',TEMP);	
				data.PSAL = odata('name','PSAL','long_name',strtrim(nc{'PSAL'}.long_name(:)),...
					'long_unit',nc{'PSAL'}.units(:),'unit',shorten_unit(nc{'PSAL'}.units(:)),...
					'cont',PSAL);	
				data.CNDC = odata('name','CNDC','long_name',strtrim(nc{'CNDC'}.long_name(:)),...
					'long_unit',nc{'CNDC'}.units(:),'unit',shorten_unit(nc{'CNDC'}.units(:)),...
					'cont',CNDC);
				% Dissolved oxygen in Argo profile should be in mumol/kg, so we call OXYK
				if ~isempty(nc{'DOXY'})
					data.OXYK = odata('name','DOXY','long_name',strtrim(nc{'DOXY'}.long_name(:)),...
						'long_unit',nc{'DOXY'}.units(:),'unit',shorten_unit(nc{'DOXY'}.units(:)),...
						'cont',DOXY);		
				end
			end
			
		case false
			if had_been_adjusted & take_adjusted
				data.TEMP = odata('name','TEMP','long_name',strtrim(nc{'TEMP'}.long_name(:)),...
					'long_unit',nc{'TEMP'}.units(:),'unit',shorten_unit(nc{'TEMP'}.units(:)));
				data.PSAL = odata('name','PSAL','long_name',strtrim(nc{'PSAL'}.long_name(:)),...
					'long_unit',nc{'PSAL'}.units(:),'unit',shorten_unit(nc{'PSAL'}.units(:)));
				data.CNDC = odata('name','CNDC','long_name',strtrim(nc{'CNDC'}.long_name(:)),...
					'long_unit',nc{'CNDC'}.units(:),'unit',shorten_unit(nc{'CNDC'}.units(:)));
				% Dissolved oxygen in Argo profile should be in mumol/kg, so we call OXYK						
				if ~isempty(nc{'DOXY'})
					data.OXYK = odata('name','DOXY','long_name',strtrim(nc{'DOXY'}.long_name(:)),...
						'long_unit',nc{'DOXY'}.units(:),'unit',shorten_unit(nc{'DOXY'}.units(:)));
				end
			else
				data.TEMP = odata('name','TEMP','long_name',strtrim(nc{'TEMP'}.long_name(:)),...
					'long_unit',nc{'TEMP'}.units(:),'unit',shorten_unit(nc{'TEMP'}.units(:)));	
				data.PSAL = odata('name','PSAL','long_name',strtrim(nc{'PSAL'}.long_name(:)),...
					'long_unit',nc{'PSAL'}.units(:),'unit',shorten_unit(nc{'PSAL'}.units(:)));	
				data.CNDC = odata('name','CNDC','long_name',strtrim(nc{'CNDC'}.long_name(:)),...
					'long_unit',nc{'CNDC'}.units(:),'unit',shorten_unit(nc{'CNDC'}.units(:)));
				% Dissolved oxygen in Argo profile should be in mumol/kg, so we call OXYK						
				if ~isempty(nc{'DOXY'})
					data.OXYK = odata('name','DOXY','long_name',strtrim(nc{'DOXY'}.long_name(:)),...
						'long_unit',nc{'DOXY'}.units(:),'unit',shorten_unit(nc{'DOXY'}.units(:)));		
				end
			end
          end
          for iv = 1 : length(fieldnames(data))
              if iv==1
                  PS(1) = 'R';
              else
                  PS = cat(2,PS,'R');
              end
          end
	data.PARAMETERS_STATUS = PS;		
          
	% PROFILES QC:
	prec.PROFILE_TEMP_QC = PROFILE_TEMP_QC; % see also: getproqc(TEMP_QC)
	prec.PROFILE_PSAL_QC = PROFILE_PSAL_QC;
	prec.PROFILE_CNDC_QC = PROFILE_CNDC_QC;
	if ~isempty(nc{'DOXY'})
		prec.PROFILE_OXYK_QC = PROFILE_DOXY_QC;
	end

	% Create the transect object		
	T = transect('source',PROJECT_NAME,'file',name(nc),'cruise_info',cinfo,'geo',geo,'data',data,'prec',prec);																						
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PROF_QC = getproqc(QC)
	
	for ii = 1 : length(QC)
		if isspace(QC(ii))
			QC(ii) = '9';
		end
	end
	QC  = str2num(QC(:));
	nt  = length(find(QC~=9));	
	nok = length(find(QC==1 | QC==2 | QC==5 | QC==8));
	N   = nok*100/nt; 
	if N == 100
		PROF_QC = 'A';
	elseif N >= 75 & N < 100
		PROF_QC = 'B';
	elseif N >= 50 & N < 75
		PROF_QC = 'C';		
	elseif N >= 25 & N < 50	
		PROF_QC = 'D';
	elseif N > 0 & N < 25		
		PROF_QC = 'E';
	elseif N == 0	
		PROF_QC = 'F';		
	end
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the reference time
function ref = get_t0(nc)
	REFERENCE_DATE_TIME = nc{'REFERENCE_DATE_TIME'};
	ref = datenum(str2num(REFERENCE_DATE_TIME(1:4)),...
			str2num(REFERENCE_DATE_TIME(5:6)),...
			str2num(REFERENCE_DATE_TIME(7:8)),...
			str2num(REFERENCE_DATE_TIME(9:10)),...
			str2num(REFERENCE_DATE_TIME(11:12)),...
			str2num(REFERENCE_DATE_TIME(13:14)));			

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Retrieve all fields of 1 profile
function OUT = readnc(nc,ip)
	
%	t0 = clock;ii=0;
	ncv_list = var(nc);
%	ncv_list = varstoload(nc); % We limit the number of variables to load
	
%	ii=ii+1;dt(ii)=etime(clock,t0);t0=clock;
	% Now we look for every variables with N_PROF as a dimension and then grab the profile we want
	for iv = 1 : length(ncv_list) 
		t0 = clock;
		dims_list = getdim_list(ncv_list{iv});
%		ii=ii+1;dt(ii)=etime(clock,t0);t0=clock;
        [a id] = intersect(dims_list,'N_PROF');
%		ii=ii+1;dt(ii)=etime(clock,t0);t0=clock;
		if ~isempty(a)
			ncv    = ncv_list{iv};			
			cont   = reshape(ncv(:),size(ncv));
			switch id
				case 1, cont = cont(ip,:,:,:);
				case 2, cont = cont(:,ip,:,:);
				case 3, cont = cont(:,:,ip,:);
				case 4, cont = cont(:,:,:,ip);
			end
			assignin('caller',name(ncv),cont);
			clear a id ncv cont
		end%if
		clear dims_list		
%		ii=ii+1;dt(ii)=etime(clock,t0);t0=clock;
	end%for iv
	clear iv
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is where we choose what to load !
function ncv_list = varstoload(nc);
	ii = 0;
	
	ii=ii+1;ncv_list(ii) = {ncvar('PLATFORM_NUMBER',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('PI_NAME',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('WMO_INST_TYPE',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('JULD_LOCATION',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('CYCLE_NUMBER',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('DIRECTION',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('LATITUDE',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('LONGITUDE',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('POSITIONING_SYSTEM',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('PROJECT_NAME',nc)};
	
	ii=ii+1;ncv_list(ii) = {ncvar('PRES_ADJUSTED',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('TEMP_ADJUSTED',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('PSAL_ADJUSTED',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('CNDC_ADJUSTED',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('PRES',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('TEMP',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('PSAL',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('CNDC',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('PROFILE_TEMP_QC',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('PROFILE_PSAL_QC',nc)};
	ii=ii+1;ncv_list(ii) = {ncvar('PROFILE_CNDC_QC',nc)};
	if ~isempty(nc{'DOXY'})
		ii=ii+1;ncv_list(ii) = {ncvar('DOXY_ADJUSTED',nc)};
		ii=ii+1;ncv_list(ii) = {ncvar('DOXY',nc)};
		ii=ii+1;ncv_list(ii) = {ncvar('PROFILE_DOXY_QC',nc)};
	end
		
end%fucntion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = getdim_list(nc)
	dims = dim(nc);
	for id = 1 : length(dims)
		result(id) = {name(dims{id})};
	end%for id
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uniP = get_uniquePLATFORMS(nc);
	li = nc{'PLATFORM_NUMBER'}(:);
	for ii = 1 : size(li,1);
		A(ii) = {strtrim(li(ii,:))};
	end
	uniP = unique(A);	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function instrument = argo_table8(varargin)

code_figure = varargin{1};	
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

end %functionargo_table8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [N_PROF N_LEVELS] = getsize(nc)
	
%	d = dim(nc{'PRES'}); % PRES for sure is in a Argo file
%	N_PROF = length(d{1});
%	N_LEVELS = length(d{2});
	N_PROF   = length(nc('N_PROF'));
	N_LEVELS = length(nc('N_LEVELS'));

end%function	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wrapper to read unregular indices from nc fields
function C = load_fromnc(cdf,Cname,iprof,icok);

%% This should be as simple as:
%%	C = cdf{Cname}(iprof,icok);
%% but when iprof or icok are not regular, we do have a warning:
%%	## Indexing strides must be positive and constant.
%% So we load inside a loop if this is the case

if ~isempty(intersect(Cname,ncvarname(cdf))) % Check if variable is available in the file:
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%