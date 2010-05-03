% webcarina2database Create a database object from CARINA hydrographic profiles
%
% D = webcarina2database({OPT_NAME,OPT_VALUE})
% 
% Create a database object from hydrographic profiles of the 
% CARINA (CARbon In the Atlantic Ocean) project.
% Datas are downloaded from the web at:
%	http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/
%
% Inputs are a list of options name with their values:
%	OPT_NAME:
%		AREA: a string with 
%			AMS: Arctic Mediterranean Seas Region
%			ATL: Atlantic Ocean
%			SO: Southern Ocean
%		VERSION: a string with:
%			for AMS: v1.0, v1.1, v1.2
%			for ATL: v1.0
%			for SO: v1.0, v1.1
%	
% Outputs:
%	D: the database object
%
% Requirements:
%	You need the system commands: 'wget' and 'unzip'
%
% CARINA Project Main Page: 
%	http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html
%
% Created: 2010-04-27.
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
function varargout = webcarina2database(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
switch nargin
	case 0 % Display help and availibility

	case 1 % 
		error('Options must come by pairs');
	otherwise
		for in = 1 : 2 : nargin
			prop = varargin{in};
			val = varargin{in+1};
			switch lower(prop)
				case 'area'
					switch lower(val)
						case 'ams'
							AREA = 'AMS';
							area_name = 'Arctic Mediterranean Seas Region';
						case 'atl'
							AREA = 'ATL';
							area_name = 'Atlantic Ocean';
						case 'so'						
							AREA = 'SO';
							area_name = 'Southern Ocean';
						otherwise
							error('Unknown area (AMS, ATL or SO) !')
					end%switch			
				case 'version'
					if exist('AREA','var')
						switch AREA
							case 'AMS'
								switch lower(val)
									case {'v1.0','v1.1','v1.2'}
										VER = upper(val);
									otherwise
										error('Wrong version (v1.0, v1.1 or v1.2) ');									
								end%witch
							case 'ATL'
								switch lower(val)
									case {'v1.0'}
										VER = upper(val);
									otherwise
										error('Wrong version (v1.0 only) ');									
								end%witch
							case 'SO'							
								switch lower(val)
									case {'v1.0','v1.1'}
										VER = upper(val);
									otherwise
										error('Wrong version (v1.0 or v1.1) ');									
								end%witch
						end%switch
					else
						error('Please specify AREA before VERSION in the option list');
					end
				otherwise
					error('Unknown option');
			end%switch
		end%for in
end% nargin checkin
data_desc = getcarinadesc(AREA,VER);
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
data_path = copoda_readconfig('copoda_data_folder');
mname = sprintf('CARINA.%s.%s.mat',AREA,VER);
mfile = sprintf('%s/%s',data_path,mname);
if exist(mfile)
	disp(sprintf('\nA database called ''%s'' already exists in:\n%s',mname,mfile));
	r = input(sprintf('\nDo you want to load it [y]/n ?'),'s');
	switch lower(r)
		case {'n','no'}
			% We continue ...
		otherwise
			try 
				load(mfile);
				if nargout == 1, varargout(1) = {D}; end
				disp('Database loaded !');
				return
			catch
				error(sprintf('Couldn''t load:\n%s',mfile));
			end
	end
end	% if database already created


	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
disp(sprintf('\nCreating a database object for: CARINA %s (%s) version %s\n',area_name,AREA,VER));
	
	
%%%%%%%%
disp(sprintf('\nDownloading csv files from the web ...\n'));
url_base = 'http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database';

csvdata_url  = sprintf('%s/CARINA.%s.%s/CARINA.%s.%s.csv.zip',url_base,AREA,VER,AREA,VER);
csvdata_file = sprintf('.carina_data_%s.csv.zip',sprintf('%i',randperm(20)));
system(sprintf('wget -O %s ''%s''',csvdata_file,csvdata_url));
system(sprintf('unzip -p %s > %s',csvdata_file,strrep(csvdata_file,'.zip',''))); csvdata_file = strrep(csvdata_file,'.zip','');
%csvdata_file = '.carina_data_1169513186121914715220171141038.csv';

csvcrui_url = sprintf('%s/CARINA.%s.%s/%sCruises.csv',url_base,AREA,VER,AREA);
csvcrui_file = sprintf('.carina_cruise_%s.csv',sprintf('%i',randperm(20)));
system(sprintf('wget -O %s ''%s''',csvcrui_file,csvcrui_url));
%csvcrui_file = '.carina_cruise_1610192011442188179153713512116.csv';

%%%%%%%%
disp(sprintf('\nConverting csv file to mat file ...\n'));
carina_csv2mat(csvdata_file,csvcrui_file); 
matdata_file = strrep(csvdata_file,'.csv','.mat');

%%%%%%%%
disp(sprintf('\nCreating database object (this may take a while) ...\n'));
D = mat2database(matdata_file,sprintf('%s/CARINA.%s.%s/CARINA.%s.%s.csv.zip',url_base,AREA,VER,AREA,VER));

%%%%%%%%
disp(sprintf('\nCleaning temp files ...\n'));
delete(strrep(csvdata_file,'.csv','.csv.zip'));
delete(csvdata_file);
delete(matdata_file);
delete(csvcrui_file);

%%%%%%%% Adjust database properties:
D.name = sprintf('CARINA %s %s',AREA,VER);
D.description = data_desc;
D.source = 'CARINA Group';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
if nargout == 1
	varargout(1) = {D};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
if ~exist(mfile)
	r = input(sprintf('\nDo you want to save the database ''%s'' in:\n%s\n\nPlease answer yes (y) or no (n) ?',mname,mfile),'s');
	if ~isempty(r)
		switch lower(r)
			case {'y','yes'}
				save(mfile,'D');
				disp('Database saved !');
			case {'n','no'}
				disp('Database not saved');
				% nothing to do
			otherwise	
				disp('Database not saved');	
				% nothing to do either
		end
	else
		disp('Database not saved');
		% nothing to do
	end
end

end %functionclean_carina2database
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = copoda_home()
	p = strrep([mfilename('fullpath') '.m'],[mfilename '.m'],'');
	p = strrep(p,'transcripts/','');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data_desc = getcarinadesc(AREA,VER)

	switch AREA
		case 'AMS'
		data_desc = {...
		sprintf('CARINA Group. 2009. Carbon in the Arctic Mediterranean Seas Region - the CARINA project: Results and Data, Version %s.',upper(VER));...
		sprintf('http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/CARINA.AMS.%s/',upper(VER));...
		sprintf('Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. Department of Energy, Oak Ridge, Tennessee.');...
		sprintf('doi: 10.3334/CDIAC/otg.CARINA.AMS.%s',upper(VER));...
		'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};

		case 'ATL'
		data_desc = {...
		sprintf('CARINA Group. 2009. Carbon in the Atlantic Ocean Region - the CARINA project: Results and Data, Version %s.',upper(VER));...
		sprintf('http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/CARINA.ATL.%s/',upper(VER));...
		sprintf('Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. Department of Energy, Oak Ridge, Tennessee.');... 
		sprintf('doi: 10.3334/CDIAC/otg.CARINA.ATL.%s',upper(VER));...
		'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
		
		case 'SO'
		data_desc = {...
		sprintf('CARINA Group. 2010. Carbon in the Southern Ocean Region - the CARINA project: Results and Data, Version %s.',upper(VER));...
		sprintf('http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/CARINA.SO.%s/',upper(VER));... 
		sprintf('Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. Department of Energy, Oak Ridge, Tennessee.');...
		sprintf('doi: 10.3334/CDIAC/otg.CARINA.SO.%s',upper(VER));...
		'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
			
	end
	
end%function	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = mat2database(mat_file,real_source_file)

load(mat_file);
	
data(data==-999) = NaN;
t = datenum(get_carina('year',data,hdr0),...
			get_carina('month',data,hdr0),...
			get_carina('day',data,hdr0),0,0,0);
[t it] = sort(t);
data = data(it,:);

% define the availabe variables
for i=1:length(hdr0);
     carinavar=[hdr0{i}, ' = data(:,i);'];
     eval(carinavar);
end

D = database;
crno      = unique(cruiseno);
nb_cruise = length(crno);
for icr = 1 : nb_cruise
%for icr = 1 : 2
	ii = find(cruiseno==crno(icr));
	nsamples_cruise(icr) = length(ii); % number of samples per cruise	
	nsamples_station     = nosamp(ii); % number of samples per stations
	
	clear X Y Time PRES DEPTH MAX_PRESSURE TEMP PSAL OXYK NITR SIO3 PHOS ALKT SIG0 SIG1 SIG2 SIG3 SIG4 STATION
	[N_LEVELS N_PROF] = get_dims(nsamples_station,ii);
	PRES  = zeros(N_PROF,N_LEVELS)*NaN;
	DEPTH = zeros(N_PROF,N_LEVELS)*NaN;
	TEMP  = zeros(N_PROF,N_LEVELS)*NaN;
	PSAL  = zeros(N_PROF,N_LEVELS)*NaN;
	OXYK  = zeros(N_PROF,N_LEVELS)*NaN;
	NITR  = zeros(N_PROF,N_LEVELS)*NaN;
	SIO3  = zeros(N_PROF,N_LEVELS)*NaN;
	PHOS  = zeros(N_PROF,N_LEVELS)*NaN;
	ALKT  = zeros(N_PROF,N_LEVELS)*NaN;
	SIG0  = zeros(N_PROF,N_LEVELS)*NaN;
	SIG1  = zeros(N_PROF,N_LEVELS)*NaN;
	SIG2  = zeros(N_PROF,N_LEVELS)*NaN;
	SIG3  = zeros(N_PROF,N_LEVELS)*NaN;
	SIG4  = zeros(N_PROF,N_LEVELS)*NaN;
	STATION = zeros(N_PROF,1)*NaN;
	MAX_PRESSURE = zeros(N_PROF,1)*NaN;
	done = 0; ik = 0; ij = ii;	
	while done ~= 1
		N_LEVELS = nsamples_station(1);		
		this = ij(1:N_LEVELS);
		if find(diff(longitude(this))~=0) | find(diff(latitude(this))~=0)
			error('Bad axis long or lat');
		end				
		if find(diff(station(this))~=0) 
			error('Bad axis station');
		end
		
		ik = ik + 1;
		nsamples_station = nsamples_station(N_LEVELS+1:end);
		ij = ij(N_LEVELS+1:end);
		if isempty(nsamples_station)==1,done=1;end

		X(ik) = longitude(this(1));
		Y(ik) = latitude(this(1));
		Time(ik) = t(this(1));
		
		MAX_PRESSURE(ik)     = maxsampdepth(this(1));
		STATION(ik) = station(this(1));
		PRES(ik,1:N_LEVELS)  = pressure(this);
		z = depth(this); %if mean(z)>0,z=-z;end
		DEPTH(ik,1:N_LEVELS) = -abs(z);
		TEMP(ik,1:N_LEVELS)  = temperature(this);
		PSAL(ik,1:N_LEVELS)  = salinity(this);
		OXYK(ik,1:N_LEVELS)  = oxygen(this);
		NITR(ik,1:N_LEVELS)  = nitrate(this);
		SIO3(ik,1:N_LEVELS)  = silicate(this);
		PHOS(ik,1:N_LEVELS)  = phosphate(this);
		ALKT(ik,1:N_LEVELS)  = alk(this);
		SIG0(ik,1:N_LEVELS)  = sigma0(this);
		SIG1(ik,1:N_LEVELS)  = sigma1(this);
		SIG2(ik,1:N_LEVELS)  = sigma2(this);
		SIG3(ik,1:N_LEVELS)  = sigma3(this);
		SIG4(ik,1:N_LEVELS)  = sigma4(this);
	end%while

	% Number of stations per cruise	
	N_PROF(icr) = ik; 
	% Move to longitude east from 0 to 360	
	X(X>=-180 & X<0) = 360 + X(X>=-180 & X<0);
	
	% Create transect object
	T = transect;
	T.file = real_source_file;
	K = find(UC == crno(icr));
	CODE = read_expocode(expocode{K(1)});
	T.cruise_info = cruise_info(...
						'NAME',sprintf('%s (CARINA #%i)',upper(basename{K(1)}),crno(icr)),...
						'PI_NAME','?',...
						'PI_ORGANISM','?',...
						'SHIP_NAME',CODE.ship_name,...
						'SHIP_WMO_ID',CODE.wmo,...
						'DATE',[min(t(ii)) max(t(ii))],...
						'N_STATION',N_PROF(icr)...
						...
						);
	geo.STATION_DATE = Time';
%	geo.STATION_NUMBER = N_PROF(icr);
	geo.STATION_NUMBER = STATION(:);
	geo.LATITUDE = Y';
	geo.LONGITUDE = X';
	geo.POSITIONING_SYSTEM = '?';
	geo.PRES = PRES;
	geo.MAX_PRESSURE = MAX_PRESSURE(:);
	geo.DEPH = DEPTH;
	T.geo = geo;
	
	od.TEMP = odata(...
		'long_name','Temperature',...
		'long_unit','degreeC',...
		'unit','degC',...
		'cont',TEMP,...
		'prec',NaN,...
		'name','TEMP');
	od.PSAL = odata(...
		'long_name','Salinity',...
		'long_unit','PSU',...
		'unit','PSU',...
		'cont',PSAL,...
		'prec',NaN,...
		'name','PSAL');	
	od.OXYK = odata(...
		'long_name','Oxygen',...
		'long_unit','mumol/kg',...
		'unit','mumol/kg',...
		'cont',OXYK,...
		'prec',NaN,...
		'name','OXYK');
	od.NITR = odata(...
		'long_name','Nitrate',...
		'long_unit','mumol/kg',...
		'unit','mumol/kg',...
		'cont',NITR,...
		'prec',NaN,...
		'name','NITR');	
	od.SIO3 = odata(...
		'long_name','Silicate',...
		'long_unit','mumol/kg',...
		'unit','mumol/kg',...
		'cont',SIO3,...
		'prec',NaN,...
		'name','SIO3');
	od.PHOS = odata(...
		'long_name','Phosphate',...
		'long_unit','mumol/kg',...
		'unit','mumol/kg',...
		'cont',PHOS,...
		'prec',NaN,...
		'name','PHOS');
	od.ALKT = odata(...
		'long_name','Alkalinity',...
		'long_unit','mumol/kg',...
		'unit','mumol/kg',...
		'cont',ALKT,...
		'prec',NaN,...
		'name','ALKT');
	od.SIG0 = odata(...
		'long_name','Potential Density relative to 0dB',...
		'long_unit','kg/m3',...
		'unit','kg/m3',...
		'cont',SIG0,...
		'prec',NaN,...
		'name','SIG0');
	od.SIG1 = odata(...
		'long_name','Potential Density relative to 1000dB',...
		'long_unit','kg/m3',...
		'unit','kg/m3',...
		'cont',SIG1,...
		'prec',NaN,...
		'name','SIG1');
	od.SIG2 = odata(...
		'long_name','Potential Density relative to 2000dB',...
		'long_unit','kg/m3',...
		'unit','kg/m3',...
		'cont',SIG2,...
		'prec',NaN,...
		'name','SIG2');
	od.SIG3 = odata(...
		'long_name','Potential Density relative to 3000dB',...
		'long_unit','kg/m3',...
		'unit','kg/m3',...
		'cont',SIG3,...
		'prec',NaN,...
		'name','SIG3');
	od.SIG4 = odata(...
		'long_name','Potential Density relative to 4000dB',...
		'long_unit','kg/m3',...
		'unit','kg/m3',...
		'cont',SIG4,...
		'prec',NaN,...
		'name','SIG4');
	od = orderfields(od);
	T.data = od;

	% Update database object:
	D.transect(icr) = T;
end




end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CODE = read_expocode(expocode)
	
%	Cruises are identified by EXPOCODE of format XXYYAAAABBCC with: 
%	XX=country code, YY=ship code, AAAA=year, BB=month, CC=day. 
%	Month, day and year are when the ship sailed (when available) or date of first station. 
%
%	See: http://cdiac.ornl.gov/oceans/CARINA/Carina_table.html

	CODE.country_code = NaN;
	CODE.ship_code    = NaN;
	CODE.year         = NaN;
	CODE.month        = NaN;
	CODE.day          = NaN;
	CODE.ship_name    = NaN;
	CODE.wmo          = NaN;
	
	if length(expocode) == 12
		CODE.country_code = expocode(1:2);
		CODE.ship_code    = expocode(3:4);
		CODE.year         = expocode(5:8);
		CODE.month        = expocode(9:10);
		CODE.day          = expocode(11:12);
		s = ship_code(expocode(1:4),'NODC');
		if iscell(s)
			CODE.ship_name = strtrim(deblank(strrep(s{1,4},'  ',' ')));
			CODE.wmo = s{1,2};
		end
		
	elseif strcmp(expocode,'IrmingerSea')		
		% 56 occupations of 2 locations on 52 individual cruises during time period forming a irregular time series.
		CODE.country_code = 'Multiple';
		CODE.ship_code    = 'Multiple';
		
	elseif strcmp(expocode,'IcelandSea')
		% 79 occupations of 2 locations on 59 individual cruises during time period forming a irregular time series.
		CODE.country_code = 'Multiple';
		CODE.ship_code    = 'Multiple';
		
	elseif strcmp(expocode,'OMEX1NA')
		%	Includes data from 42 cruises from the Ocean Margin EXperiment; 
		%	See Wollast and Chou 2001a,b; Kier et al. 2001; van Weering et al. 2001 and other papers in that issue; Frankignoulle and Borges 2001; Frankignnoulle et al 1996a,b, Wassman et al. 1999; and special issue of Sarsia 84(3/4), Nov. 1999.
		% 	Wollast, R. and L. Chou. 2001a. Ocean Margin EXchange in the Northern Gulf of Biscaye: OMEX-1. An introduction. Deep-Sea Res. II 48(14-15):2971-2978.
		% 	Wollast, R. and L. Chou. 2001b. The carbon cycle at the ocean margin in the northern Gulf of Biscay. Deep-Sea Res. II 48:3265-3293.
		% 	Keir, R.S., G. Rehder and M. Frankignoulle. 2001. Partial pressure and air-sea flux of CO2 in the Northeast Atlantic during September 1995. Deep-Sea Res. II 48:3179-3189.
		% 	van Weering, T.C.E., H.C. De Stigter, W. Balzer, E.H.G. Epping, G. Graf, I.F. Hall, W. Helder, A. Khripounoff, L. Lohse, I.N. McCave, L. Thomsen and A. Vangriesheim. 2001. Benthic dynamics and carbon fluxes on the NW European continental margin. Deep-Sea Res. II 48:3191-3221.
		% 	Frankignoulle M. and A.V. Borge. 2001. European continental shelf as a significant sink for atmospheric carbon dioxide. Global Biogeochem. Cycles 15(3):569-576.
		% 	Frankignoulle, M., M. Elskens, R. Biondo, I. Bourge, C. Canon, S. Desgain and P. Dauby. 1996a. Distribution of inorganic carbon and related parameters in surface seawater of the English Channel in Spring 1994. Mar. Sys. 7(2-4):427-434.
		% 	Frankignoulle, M., I. Bourge, C. Canon and P. Dauby. 1996b. Distribution of surface seawater partial CO2 pressure in the English Channel and in the Southern Bight of the North Sea. Continental Shelf Res. 16:381-395.
		% 	Wassmann, P., I.J. Andreassen and F. Rey. 1999. Seasonal variation of nutrients and suspended biomass on a transect across Nordvestbanken, north Norwegian shelf, in 1994. Sarsia, 84(3/4):199-211.
		% 	Hydes, D.J., Le Gall, A.C., Miller, A.E.J., Brockmann, U., Raabe, T.Holley, S., Alvarez-Salgado, X., Antia, A., Balzer, W., Chou, L., Elskens, M., Helder, W., Joint, I., Orren, M. 2001. Supply and demand of nutrient and dissolved organic matter at and across the NW European shelf break in relation to hydrography and biogeochemical activity. Deep-Sea Research. Part 2: Topical Studies in Oceanography, 48(14/15):3023-3047; ISSN: 0967-0645.		
		CODE.country_code = 'Ocean Margin EXperiment 1';
		CODE.ship_code    = 'XX';

	elseif strcmp(expocode,'OMEX1NS')
		% Includes data from 42 cruises from the Ocean Margin EXperiment; See Wollast and Chou 2001a,b; Kier et al. 2001; van Weering et al. 2001 and other papers in that issue; Frankignoulle and Borges 2001; Frankignnoulle et al 1996a,b, Wassman et al. 1999; and special issue of Sarsia 84(3/4), Nov. 1999.
		% Wollast, R. and L. Chou. 2001a. Ocean Margin EXchange in the Northern Gulf of Biscaye: OMEX-1. An introduction. Deep-Sea Res. II 48(14-15):2971-2978.
		% Wollast, R. and L. Chou. 2001b. The carbon cycle at the ocean margin in the northern Gulf of Biscay. Deep-Sea Res. II 48:3265-3293.
		% Keir, R.S., G. Rehder and M. Frankignoulle. 2001. Partial pressure and air-sea flux of CO2 in the Northeast Atlantic during September 1995. Deep-Sea Res. II 48:3179-3189.
		% van Weering, T.C.E., H.C. De Stigter, W. Balzer, E.H.G. Epping, G. Graf, I.F. Hall, W. Helder, A. Khripounoff, L. Lohse, I.N. McCave, L. Thomsen and A. Vangriesheim. 2001. Benthic dynamics and carbon fluxes on the NW European continental margin. Deep-Sea Res. II 48:3191-3221.
		% Frankignoulle M. and A.V. Borge. 2001. European continental shelf as a significant sink for atmospheric carbon dioxide. Global Biogeochem. Cycles 15(3):569-576.
		% Frankignoulle, M., M. Elskens, R. Biondo, I. Bourge, C. Canon, S. Desgain and P. Dauby. 1996a. Distribution of inorganic carbon and related parameters in surface seawater of the English Channel in Spring 1994. Mar. Sys. 7(2-4):427-434.
		% Frankignoulle, M., I. Bourge, C. Canon and P. Dauby. 1996b. Distribution of surface seawater partial CO2 pressure in the English Channel and in the Southern Bight of the North Sea. Continental Shelf Res. 16:381-395.
		% Wassmann, P., I.J. Andreassen and F. Rey. 1999. Seasonal variation of nutrients and suspended biomass on a transect across Nordvestbanken, north Norwegian shelf, in 1994. Sarsia, 84(3/4):199-211.
		% Hydes, D.J., Le Gall, A.C., Miller, A.E.J., Brockmann, U., Raabe, T.Holley, S., Alvarez-Salgado, X., Antia, A., Balzer, W., Chou, L., Elskens, M., Helder, W., Joint, I., Orren, M. 2001. Supply and demand of nutrient and dissolved organic matter at and across the NW European shelf break in relation to hydrography and biogeochemical activity. Deep-Sea Research. Part 2: Topical Studies in Oceanography, 48(14/15):3023-3047; ISSN: 0967-0645.
		CODE.country_code = 'Ocean Margin EXperiment 1';
		CODE.ship_code    = 'XX';
		
	elseif strcmp(expocode,'OMEX2')
		%	Includes data from 12 cruises; see also Alvarez-Salgado et al. 2003.
		%	Álvarez-Salgado X.A, F.G. Figueiras, F.F. PÈrez, S. Groom, E. Nogueira, A.V. Borges, L. Chou, C.G. Castro, G. Moncoiffe, A.F. Rios, A.E.J. Miller, M. Frankignoulle, G. Savidge and R. Wollast. 2003. Thermohaline, chemical and biological characterisation of the poleward flowing Portugal coastal counter current off NW Spain. Prog. Oceanogr. 56(2):281-321.
		CODE.country_code = 'Ocean Margin EXperiment 2';
		CODE.ship_code    = 'XX';
		
	end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [N ik] = get_dims(nsamples_station,ii)
	done = 0; ik = 0; ij = ii;	
	while done ~= 1
		N_LEVELS = nsamples_station(1);		
		this = ij(1:N_LEVELS);	

		ik = ik + 1;
		nsamples_station = nsamples_station(N_LEVELS+1:end);
		N(ik) = N_LEVELS;
		ij = ij(N_LEVELS+1:end);
		if isempty(nsamples_station)==1,done=1;end
	end%while
	N = max(N);
	
end%function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = get_carina(varn,data,name_list)
	for ii = 1 : length(name_list);
		if strcmp(name_list{ii},varn), 
			break
		end
	end
	varargout(1) = {data(:,ii)};
end%function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vargout = carina_csv2mat(file,cruise_file)
	
% Script ot read the CARINA files from csv format and store them as mat
% files so that they can be read fast by matlab.
% You will need the merged data file in csv format, and also a list of
% cruisenumbers and expocodes.
%
% Toste Tanhua 2009.06.05


% MAKE SURE YOU HAVE THE RIGHT PATH AND FILENAME
data=csvread(file,1,0);

D=length(data(1,:)); 

% MAKE SURE YOU HAVE THE RIGHT PATH AND FILENAME
fid = fopen(file);

hdr=textscan(fid,'%s',D,'delimiter',',');     
eval(cat(2,'hdr',int2str(i),'=hdr{1};'));
fclose(fid);

for ii=1:length(hdr0);
     carinavar=[hdr0{ii}, ' = data(:,ii);'];
     eval(carinavar);
end

% To read the expocodes right
% MAKE SURE YOU HAVE THE RIGHT PATH AND FILENAME
%fid = fopen(sprintf('../../data/%sCruises.csv',zone));
fid = fopen(cruise_file);
crs=textscan(fid,'%s%s%s%s',199,'delimiter',','); 
fclose(fid);
ex=crs{1}; expocode=ex(2:length(ex));
uc=crs{2};  ucruise=uc(2:length(uc));
basename=crs{3};basename=basename(2:length(basename));
UC = str2double(ucruise);

% MAKE SURE YOU HAVE THE RIGHT PATH AND FILENAME
%save CARINA_ATL_final data hdr0 expocode UC
save(strrep(file,'.csv','.mat'),'data','hdr0','expocode','UC','basename');

end%function read_carina
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%