% transect Constructor for transect class
%
% T = transect(no arguments) creates a default transect object
% 
% [] = transect(T) display properties of a transect object T
%
% T = transect('property',value,...) creates a transect object
%	
% List of properties:
% 
%	source (string)		: Description of the data source, by default it is
%				set to config file property: transect_constructor_default_source
%	creator (string)	: Creator of the transect object, by default it is set to
%				the environment variable USER.
%	file (string)		: File name with original datas 
%	file_date (datenum)	: System date (as return by datenum) of the file
%	created (datenum)	: Date (as return by datenum) of creation, by 
%				default set to the output from the matlab command 'now'.
%	modified (datenum)	: Date (as return by datenum) of last modification
%				of the database. This property is modified when saving the 
%				object with save.
% 
%	cruise_info (class cruise_info): Contains basic informations about the cruise.
%					It can be defined like this:
%					T.cruise_info = cruise_info();
%					Type help cruise_info for more informations about this class.
% 
%	geo (struct): Structure containing informations about localization of measurements.
%			The list of fields it must have is:
%				geo.STATION_NUMBER (double)
%				geo.STATION_DATE (double as return by datenum)
%				geo.LATITUDE (double)
%				geo.LONGITUDE (double)
%				geo.POSITIONING_SYSTEM (string)
%				geo.PRES (double)
%				geo.MAX_PRESSURE (double)
%				geo.DEPH (double)
%			Note that this field is customizable, you can add other fields like AREA ...
% 
%	data (struct): This property contains data from all stations parameters as odata objects.
% 		*	An odata object is an array of values associated with a name and an unit.
% 			Type "help odata" for more informations about this class.
% 			The method to add a new odata object to a transect object T is: "setodata". For instance:
% 				T = setodata(T,'TEMP',odata);
% 				T = setodata(T,'PSAL',odata);
% 			To remove a parameter, you can do:
% 				T = delodata(T,'TEMP',odata);
%			Possible names (like 'TEMP' here above) for odata objects within a transect are controlled
% 			by the framework. They are builtin variables and users can define their owns. See User's 
% 			Manual for more details. To see the list of supported variables in your environment, type:
% 				supported_variables(transect);
% 					or for more detailled descriptions:
% 				supported_variables(transect,'t');
% 		*	If you type "T.data", more read-only fields, generated dynamically, will appear:
%				data.STATION_PARAMETERS (cell of strings) : The list of parameters available in the transect. 
% 					For a more detailled listing of parameters, use the transect method "datanames"
%				data.PARAMETERS_STATUS (chars) : This is an array of 'R' or 'V', defined for each odata object.
%					R: stands for Real variables (odata content is loaded in memory)
%					V: stands for Virtual variables (odata content is NaN and computed dynamically).
%						Note that when a parameter status is changed from R to V, the odata content is 
% 						cleared from memory.
%
%			To each one of these should corresponds an odata object within 
%			the structure data like:
%				data.TEMP (class odata): odata object class.
%			Type help odata for more informations about this class


%			and typing:
%				data.STATION_PARAMETERS
%			will give:
%				{'TEMP','PSAL','OXYL'}
%
%	prec (struct): Contains all information about quality/precision of geo and data:
%				Not used right now
%
% More informatios in the COPODA html documentation:
%	<a href="matlab:copoda_open_doc">COPODA Documentation</a>
%	copoda_open_doc
%
% http://copoda.googlecode.com
% Copyright 2010-2013, COPODA

% Created: 2009-07-22.
% Rev. by Guillaume Maze on 2011-03-31: Now use config file for default source
% Rev. by Guillaume Maze on 2010-04-26: Read the default source property from the configuration file 
%										(prop key: transect_constructor_default_source)
% Rev. by Guillaume Maze on 2010-03-05: Implemented Real/Virtual variables
% Rev. by Guillaume Maze on 2009-08-04: data.STATION_PARAMETERS is read only and defined dynamically
% Rev. by Guillaume Maze on 2009-07-29: Added help

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

function T = transect(varargin)

switch nargin
	
	case 0 
		% Create default object
		T = init_fields;
		T = class(T,'transect');
		
	case 1 
		% If a single argument of class transect, return it
		if (isa(varargin{1},'transect'))
			T = varargin{1};
		else
			error('Input argument is not a transect object');
		end
		
	otherwise
		n = nargin;
		if mod(n,2) ~= 0,
			error('Invalid number of input arguments');
		else	
			% Create default object:
			T = init_fields;
			T = class(T,'transect');
			for iprop = 1 : 2 : n
				T = subsasgn(T,substruct('.',varargin{iprop}),varargin{iprop+1});				
			end%for iprop
			%if isempty(intersect(varargin{1:2:end},'PARAMETERS_STATUS'));
			% Ensure we have a PARAMETERS_STATUS field:
			
		end
	
end %switch

end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function OK = check_prop(P)
	if 		strcmp(P,'source'), OK = true;
	elseif	strcmp(P,'creator'), OK = true;
	elseif	strcmp(P,'file'), OK = true;
	elseif	strcmp(P,'cruise_info'), OK = true;
	elseif	strcmp(P,'geo'), 		 OK = true;
	elseif	strcmp(P,'data'), 		 OK = true;
	elseif	strcmp(P,'prec'), 		 OK = true;
	elseif	strcmp(P,'created'), 		 OK = true;
	elseif	strcmp(P,'modified'), 		 OK = true;
	elseif	strcmp(P,'file_date'), 		 OK = true;
	else, OK = false;
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T = init_fields()

T.source = copoda_readconfig('transect_constructor_default_source');
%T.creator = getenv('USER');
T.creator = sprintf('%s (USER)',getenv('USER'));
T.file = '';
T.cruise_info = cruise_info('N_STATION',0);
T.geo  = geo_list;
T.data = data_list;
T.prec = prec_list;
T.created = now;
T.modified  = now;
T.file_date = NaN;

end %function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = class_home()
	p = strrep([mfilename('fullpath') '.m'],[mfilename '.m'],'');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T = geo_list(varargin)

	% Stations:	
	T.STATION_NUMBER = 9999;
	T.STATION_DATE   = datenum(0,0,0,0,0,0);
	
	% Lat/Lon:
	T.LATITUDE  = 9999;
	T.LONGITUDE = 9999;
	T.POSITIONING_SYSTEM = '';

	% Vertical axis:
	T.PRES = 9999;
	T.MAX_PRESSURE = 9999;
	T.DEPH = 9999;
	
	% These are usually useless:
%	T.STATION_DATE_BEGIN = '';
%	T.STATION_DATE_END = '';
%	T.LATITUDE_BEGIN = 0;
%	T.LATITUDE_END = 0;
%	T.LONGITUDE_BEGIN = 0;
%	T.LONGITUDE_END = 0;
 	

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T = prec_list(varargin)
	
	T.POSITION_QC = '';
	T.PROFILE_PRES_PREC = 0;
	T.PROFILE_DEPH_PREC = 0;
	T.PROFILE_PSAL_PREC = 0;
	T.PROFILE_TEMP_PREC = 0;
	T.PROFILE_OXYL_PREC = 0;
	T.PROFILE_TPOT_PREC = 0;
	T.PROFILE_SIGI_PREC = 0;
	T.PROFILE_DYNH_PREC = 0;
	T.PROFILE_BRV2_PREC = 0;
	T.PROFILE_VORP_PREC = 0;
	T.PROFILE_SIG0_PREC = 0;
	T.PROFILE_SIG1_PREC = 0;
	T.PROFILE_SI15_PREC = 0;
	T.PROFILE_SIG2_PREC = 0;
	T.PROFILE_SIG3_PREC = 0;
	T.PROFILE_SIG4_PREC = 0;
	T.PROFILE_SIG5_PREC = 0;
	T.PROFILE_GAMM_PREC = 0;

end




