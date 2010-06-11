% carina2database Create a database object from a CARINA mat file
%
% D = carina2database(MATFILE)
% 
% Create a database object D from the mat file MATFILE created with the 
% the matlab routine read_carina.m provided with the CARINA matlab
% package:
% http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_MATLAB/
%
% Source: http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database
% About cruises: http://cdiac.ornl.gov/oceans/CARINA/Carina_table.html
%
% Created: 2009-09-19.
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

function D = carina2database(varargin)

file = varargin{1}; % Mat file created with read_carina.m
load(file);
	
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
%for icr = 1 : 20
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
%	X(X>=-180 & X<0) = 360 + X(X>=-180 & X<0);
	
	% Create transect object
	T = transect;
	T.file = strrep(file,'../','');
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
	% clf
	% subplot(1,2,1);plot(T,'track');
	% subplot(1,2,2);plot(T.data.OXYK.cont,T.geo.DEPH,'.');shading flat
	% suptitle(num2str(icr));
	% drawnow
%	pause
	
	% Update database object:
	D.transect(icr) = clean_empty_variables(T);
%	D.transect(icr) = T;
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
