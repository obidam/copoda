% data_list Determine the list of allowed fields within transect.data property
%
% [] = data_list()
% 
% Determine the list of allowed fields within a transect.data property
% This list is called from numerous places in the package to test if a field
% is allowed or not to exist.
%
% This function simply return the structure used as transect.data property
%
%
% Rev. by Guillaume Maze on 2012-01-25: Add user data loading possibilities
% Rev. by Guillaume Maze on 2011-03-31: Removed Fiz mentions
% Created: 2009-07-31.
% Copyright (c) 2009 Guillaume Maze. 
% http://codes.guillaumemaze.org

%
% This program is free software: you can redistribute it and/or modify it under the 
% terms of the GNU General Public License as published by the Free Software Foundation, 
% either version 3 of the License, or any later version. This program is distributed 
% in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
% implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
% GNU General Public License for more details. You should have received a copy of 
% the GNU General Public License along with this program.  
% If not, see <http://www.gnu.org/licenses/>.
%

function T = data_list(varargin)

%- Standard variables:
		T.ALKT = odata('name','ALKT','long_name','Alkalinity','unit','mumol/kg','long_unit','micromol/kilogram');
		T.AOU  = odata('name','AOU','long_name','Apparent Oxygen Utilisation','unit','ml/l','long_unit','milliliter/liter');
		T.BRV2 = odata('name','BRV2','long_name','Brunt-Vaisala frequency squared','unit','1/s2','long_unit','1/second^2');
		T.CANT = odata('name','CANT','long_name','Anthropic Carbon','unit','pmol/kg','long_unit','picomol/kilogram');
		T.CNDC = odata('name','CNDC','long_name','Electrical conductivity','unit','mhos/m','long_unit','mhos/m');
		T.CTOT = odata('name','CTOT','long_name','Total Carbon','unit','mumol/kg','long_unit','micromol/kilogram');
		T.DYNH = odata('name','DYNH','long_name','Dynamical Height','unit','dynm','long_unit','dynamical meter');
		T.GAMM = odata('name','GAMM','long_name','Neutral surface density','unit','kg/m^3','long_unit','kg/m3');
		T.NITR = odata('name','NITR','long_name','Nitrate','unit','mumol/kg','long_unit','micromol/kilogram');
		T.OXSL = odata('name','OXSL','long_name','Oxygen Solubility','unit','ml/l','long_unit','milliliter/liter');
		T.OXST = odata('name','OXST','long_name','Oxygen Saturation','unit','%','long_unit','%');
		T.OXYK = odata('name','OXYK','long_name','Oxygen Concentration','unit','mumol/kg','long_unit','micromol/kilogram');
		T.OXYL = odata('name','OXYL','long_name','Oxygen Concentration','unit','ml/l','long_unit','milliliter/liter');
		T.PHOS = odata('name','PHOS','long_name','Phosphate','unit','mumol/kg','long_unit','micromol/kilogram');
		T.PSAL = odata('name','PSAL','long_name','Salinity','unit','PSU','long_unit','P.S.U.');
		T.SI15 = odata('name','SI15','long_name','Potential density referenced to 1500db','unit','kg/m3','long_unit','kg/m3');
		T.SIG0 = odata('name','SIG0','long_name','Potential density referenced to surface','unit','kg/m3','long_unit','kg/m3');
		T.SIG1 = odata('name','SIG1','long_name','Potential density referenced to 1000db','unit','kg/m3','long_unit','kg/m3');
		T.SIG2 = odata('name','SIG2','long_name','Potential density referenced to 2000db','unit','kg/m3','long_unit','kg/m3');
		T.SIG3 = odata('name','SIG3','long_name','Potential density referenced to 3000db','unit','kg/m3','long_unit','kg/m3');
		T.SIG4 = odata('name','SIG4','long_name','Potential density referenced to 4000db','unit','kg/m3','long_unit','kg/m3');
		T.SIG5 = odata('name','SIG5','long_name','Potential density referenced to 5000db','unit','kg/m3','long_unit','kg/m3');
		T.SIGI = odata('name','SIGI','long_name','In-Situ Potential density','unit','kg/m3','long_unit','kg/m3');
		T.SIO2 = odata('name','SIO2','long_name','Silice','unit','mumol/kg','long_unit','micromol/kilogram');
		T.SIO3 = odata('name','SIO3','long_name','Silicat','unit','mumol/kg','long_unit','micromol/kilogram');
		T.TEMP = odata('name','TEMP','long_name','Temperature','unit','degC','long_unit','degree Celsius');

%- User defined variables:
		try
			% data_list_user is supposed to be in the copoda_user_contrib/ folder
			Tuser = data_list_user;
			vlist = fieldnames(Tuser);
			for iv = 1 : length(vlist)
				switch vlist{iv}
					case {'PARAMETERS_STATUS'}
						% Not added, user is only allowed to defined real variables
					otherwise
						T = setfield(T,vlist{iv},getfield(Tuser,vlist{iv}));
				end% switch 				
			end% for iv
		catch
		end % catch

%- List of fields:
% This is just indicative because it's dynamically generated when calling T.STATION_PARAMETERS
% with subsref.m
T.STATION_PARAMETERS = fieldnames(T);

%- The status is defined for odata fields with names, ie the list of fields returned by datanames(T,0)
T.PARAMETERS_STATUS = rstat(length(T.STATION_PARAMETERS));


end %function


function str = rstat(n)
	str = '';
	for ii = 1 : n
		str = sprintf('%sR',str);
	end% for ii
end% function





