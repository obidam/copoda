% data_list Determine the list of allowed fields within transect.data property
%
% [] = data_list()
% 
% Determine the list of allowed fields within transect.data property
% This list is called from numerous places in the package to test wether a field
% is allowed or not to exist.
%
%
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

		% List of fields:
		% This is just indicative because it's dynamically generated when calling T.STATION_PARAMETERS
		% with subsref.m
		T.STATION_PARAMETERS = {'PSAL','TEMP',...
		'OXYL','OXYK','TPOT','SIGI','SIG0','SI15','SIG1',...
		'SIG2','SIG3','SIG4','SIG5','DYNH','BRV2',...
		'AOU','VORP','GAMM','OXSL','OXST',...
		'PHOS','NITR','ALKT','SIO2','SIO3','CANT','CTOT',...
		'TIPE','CNDC',...
		};
		% TIPE stands for TRSP_INV_PLUS_EK:  Geostrophic transport plus Ekman
		
		% The status is defined for odata fields with names, ie the list of fields returned by datanames(T,0)
		T.PARAMETERS_STATUS = 'RRRRRRRRRRRRRRRRRRRRRRRRRRRR'; 
		
		
		% Measures by alphabetical order:
		T.ALKT = odata('name','ALKT','long_name','Alkalinity interpolated by Fiz','unit','mumol/kg','long_unit','micromol/kilogram');
		T.AOU  = odata('name','AOU','long_name','Apparent Oxygen Utilisation','unit','ml/l','long_unit','milliliter/liter');
		T.BRV2 = odata('name','BRV2','long_name','Brunt-Vaisala frequency squared','unit','1/s2','long_unit','1/second^2');
		T.CANT = odata('name','CANT','long_name','Anthropic Carbon interpolated by Fiz','unit','pmol/kg','long_unit','picomol/kilogram');
		T.CNDC = odata('name','CNDC','long_name','Electrical conductivity','unit','mhos/m','long_unit','mhos/m');
		T.CTOT = odata('name','CTOT','long_name','Total Carbon interpolated by Fiz','unit','mumol/kg','long_unit','micromol/kilogram');
		T.DYNH = odata('name','DYNH','long_name','Dynamical Height','unit','dynm','long_unit','dynamical meter');
		T.GAMM = odata('name','GAMM','long_name','Neutral surface density','unit','kg/m^3','long_unit','kg/m3');
		T.NITR = odata('name','NITR','long_name','Nitrate interpolated by Fiz','unit','mumol/kg','long_unit','micromol/kilogram');
		T.OXSL = odata('name','OXSL','long_name','Oxygen Solubility','unit','ml/l','long_unit','milliliter/liter');
		T.OXST = odata('name','OXST','long_name','Oxygen Saturation','unit','%','long_unit','%');
		T.OXYK = odata('name','OXYK','long_name','Oxygen Concentration','unit','mumol/kg','long_unit','micromol/kilogram');
		T.OXYL = odata('name','OXYL','long_name','Oxygen Concentration','unit','ml/l','long_unit','milliliter/liter');
		T.PHOS = odata('name','PHOS','long_name','Phosphate interpolated by Fiz','unit','mumol/kg','long_unit','micromol/kilogram');
		T.PSAL = odata('name','PSAL','long_name','Salinity','unit','PSU','long_unit','P.S.U.');
		T.SI15 = odata('name','SI15','long_name','Potential density referenced to 1500db','unit','kg/m3','long_unit','kg/m3');
		T.SIG0 = odata('name','SIG0','long_name','Potential density referenced to surface','unit','kg/m3','long_unit','kg/m3');
		T.SIG1 = odata('name','SIG1','long_name','Potential density referenced to 1000db','unit','kg/m3','long_unit','kg/m3');
		T.SIG2 = odata('name','SIG2','long_name','Potential density referenced to 2000db','unit','kg/m3','long_unit','kg/m3');
		T.SIG3 = odata('name','SIG3','long_name','Potential density referenced to 3000db','unit','kg/m3','long_unit','kg/m3');
		T.SIG4 = odata('name','SIG4','long_name','Potential density referenced to 4000db','unit','kg/m3','long_unit','kg/m3');
		T.SIG5 = odata('name','SIG5','long_name','Potential density referenced to 5000db','unit','kg/m3','long_unit','kg/m3');
		T.SIGI = odata('name','SIGI','long_name','In-Situ Potential density','unit','kg/m3','long_unit','kg/m3');
		T.SIO2 = odata('name','SIO2','long_name','Silice interpolated by Fiz','unit','mumol/kg','long_unit','micromol/kilogram');
		T.SIO3 = odata('name','SIO3','long_name','Silicat interpolated by Fiz','unit','mumol/kg','long_unit','micromol/kilogram');
		T.TEMP = odata('name','TEMP','long_name','Temperature','unit','degC','long_unit','degree Celsius');
		T.TIPE = odata('name','TIPE','long_name','Absolute transport (Geostrophic+Ekman)','unit','m3/s','long_unit','m3/s');
		T.TPOT = odata('name','TPOT','long_name','Potential Temperature','unit','degC','long_unit','degree Celsius');
		T.VORP = odata('name','VORP','long_name','Planetary Vorticity (f/h)','unit','1/s','long_unit','1/s');
		
end %function