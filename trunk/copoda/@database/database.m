% database Constructor for database object
%
% The database object embeds 1 or more transect object and is
% associated with specific methods to allow easy manipulation
% of Hydrobase datas created at LPO.
%
% Syntax: 
%
% D = database(no arguments) creates a default database object
% 
% [] = database(D) display properties of a database object D
%
% D = database('property',value,...) creates a database object
%	
% List of properties:
%	source (string)		  : Description of the data source, by default it is
%				   set to 'Laboratoire de Physique des Oceans, Brest'
%	creator (string)	  : Creator of the database, by default it is set to
%				   the environment variable USER.
%	name (string)		  : This is the name of the database.
%	created (datenum)	  : Date (as return by datenum) of creation, by 
%				   default set to the output from the matlab command 'now'.
%				   It is set at the creation and cannot be changed later on.
%	modified (datenum) 	  : Date (as return by datenum) of last modification
%				   of the database.
%	description (string cell) : Give an exhaustive description of the database.
%	transect (class transect) : This is a cell array of transect object, by default
%				   it is set to 2 empty transects. To insert transect object, simply
%				   type: D.transect(i) = a_transect_object_as_returned_by_transect;
%
% Example:
%  D = database;
%  D.transect{1} = netcdf2transect('~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A01E/A01E91_dep.nc');
%  D.transect{2} = netcdf2transect('~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A01E/A01E94_dep.nc');
%
%  help(D) % will give you what you need to start using the database
%
% More informations about specific diagnostics:
%	help database/validate
%
% More informations about specific methods:
%	help database/extract
%	help database/reorder
%	help database/tracks
%	help database/header
%
% More informations about specific Matlab methods:
%	help database/help
%	help database/plot
%	help database/isfield
%	help database/length
%	help database/disp
%	help database/display
%	help database/saveobj
%	help database/loadobj
%
% Created: 2009-07-22.
% Rev. by Guillaume Maze on 2009-07-29: Added help
% Rev. by Guillaume Maze on 2010-04-28: Now check the version of the file when loading/saving
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

function D = database(varargin)

switch nargin
	case 0 
		% Create default object
		D = init_database;
		D = class(D,'database');
	case 1 
		% If a single argument of class transect, return it
		if (isa(varargin{1},'database'))
			D = varargin{1};
		else
			error('Input argument is not a database object');
		end
		
	otherwise
		n = nargin;
		if mod(n,2) ~= 0,
			error('Invalid number of input arguments');
		else	
			% Create default object:
			D = init_database;
			D = class(D,'database');
			% then modify object using specified values:
            for iprop = 1 : 2 : n                
				if check_prop(varargin{iprop})
                    eval(sprintf('D.%s = varargin{%i};',varargin{iprop},iprop+1));
                end
            end%for iprop            
% 			for iprop = 1 : 2 : n
% 				prop_nam = varargin{iprop};
% 				prop_val = varargin{iprop+1};
% 				if check_prop(prop_nam)
% 					D = setfield(D,prop_nam,prop_val);
% 				else
% 					error('Invalid propertie name for database object');
% 				end
% 			end
		end		
		
	
end


end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function OK = check_prop(P)
	if 		strcmp(P,'source'), OK = true;
	elseif	strcmp(P,'creator'), OK = true;
	elseif	strcmp(P,'transect'), OK = true;
	elseif	strcmp(P,'name'), OK = true;
	elseif	strcmp(P,'created'), OK = true;
	elseif	strcmp(P,'modified'), OK = true;
	elseif	strcmp(P,'description'), OK = true;
	else, OK = false;
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = init_database()

%D.source    = 'Laboratoire de Physique des Oceans, Brest';
D.source    = copoda_readconfig('database_constructor_default_source');
D.creator   = getenv('USER');
D.name	    = 'Unname database';
D.created   = now;
D.modified  = datenum(1900,1,1,0,0,0);
D.description = {'Description of';'the database here'};
D.transect  = [transect transect]; 


end %function









