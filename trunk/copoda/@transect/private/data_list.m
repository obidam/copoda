% data_list Determine the list of allowed fields within transect.data property
%
% [] = data_list()
% 
% Determine the list of allowed fields within transect.data property
% This list is called from numerous places in the package to test wether a field
% is allowed or not to exist.
%
% This function simply return the structure used as transect.data property
%
%
% Created: 2009-07-31.
% Rev. by Guillaume Maze on 2011-03-31: Removed Fiz mentions
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

%- These variables should be for everybody:
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

%- These variables are specific and should from the copoda_contrib folder:
		% TIPE stands for TRSP_INV_PLUS_EK:  Geostrophic transport plus Ekman		
		T.TIPE = odata('name','TIPE','long_name','Absolute transport (Geostrophic+Ekman)','unit','m3/s','long_unit','m3/s');
		T.TPOT = odata('name','TPOT','long_name','Potential Temperature','unit','degC','long_unit','degree Celsius');
		T.VORP = odata('name','VORP','long_name','Planetary Vorticity (f/h)','unit','1/s','long_unit','1/s');
		T.MLD  = odata('name','MLD','long_name','Mixed Layer Depth','unit','m','long_unit','meter');

		% About the thermocline:
		T.THD  = odata('name','THD','long_name','Main Thermocline Depth','unit','m','long_unit','meter');
		T.THH  = odata('name','THH','long_name','Main Thermocline Thickness','unit','m','long_unit','meter');
		T.THSIG0 = odata('name','THSIG0','long_name','Main Thermocline Potential Density','unit','kg/m3','long_unit','kg/m3');
		T.THDSIG0 = odata('name','THDSIG0','long_name','Main Thermocline Potential Density Gradient','unit','kg/m3','long_unit','kg/m3');
		T.THTEMP = odata('name','THTEMP','long_name','Main Thermocline Temperature','unit','degC','long_unit','degree Celsius');
		T.THPSAL = odata('name','THPSAL','long_name','Main Thermocline Salinity','unit','PSU','long_unit','P.S.U.');
		T.THDTOP = odata('name','THDtop','long_name','Main Thermocline Top Depth','unit','m','long_unit','meter');
		T.THDBTO = odata('name','THDbto','long_name','Main Thermocline Bottom Depth','unit','m','long_unit','meter');
		T.THMWD  = odata('name','THMWD','long_name','Mode Water Depth from TH diagnostic','unit','m','long_unit','meter');
		
		% Misc:
		T.NOP = odata('name','NOP','long_name','Preformed Nitrate','unit','mumol/kg','long_unit','micromol/kilogram');
		
		
%- List of fields:
% This is just indicative because it's dynamically generated when calling T.STATION_PARAMETERS
% with subsref.m
T.STATION_PARAMETERS = fieldnames(T);
	
%- The status is defined for odata fields with names, ie the list of fields returned by datanames(T,0)
T.PARAMETERS_STATUS = 'RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR'; 


end %function