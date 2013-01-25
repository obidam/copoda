% data_list_user Define my data
%
% No inputs, this function is called by the transect class to allow for additional
% variables in the transect.data object defined by user.
%
% Created: 2012-01-26.
% http://code.google.com/p/copoda
% Copyright 2012, COPODA

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

% Category for documentation:
%CAT 
% Method's type for documentation:
%TYP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T = data_list_user(varargin)

	% TIPE stands for TRSP_INV_PLUS_EK:  Geostrophic transport plus Ekman		
	T.TIPE = odata('name','TIPE','long_name','Absolute transport (Geostrophic+Ekman)','unit','m3/s','long_unit','m3/s');
	T.TPOT = odata('name','TPOT','long_name','Potential Temperature','unit','degC','long_unit','degree Celsius');
	T.VORP = odata('name','VORP','long_name','Planetary Vorticity','unit','1/s/m','long_unit','1/s/m');
	T.MLD  = odata('name','MLD' ,'long_name','Mixed Layer Depth','unit','m','long_unit','meter');

	% About the Thermocline (TH*):
	T.THH     = odata('name','THH'   ,'long_name','Main Thermocline Thickness','unit','m','long_unit','meter');
	T.THD     = odata('name','THD'   ,'long_name','Main Thermocline Depth','unit','m','long_unit','meter');
	T.THDTOP  = odata('name','THDtop','long_name','Main Thermocline Top Depth','unit','m','long_unit','meter');
	T.THDBTO  = odata('name','THDbto','long_name','Main Thermocline Bottom Depth','unit','m','long_unit','meter');
	T.THPLPV  = odata('name','THPLPV','long_name','Main Thermocline Planetary Potential Vorticity (q = f*N2/g)','unit','1/m/s','long_unit','1/m/s');
	T.THPSAL  = odata('name','THPSAL','long_name','Main Thermocline Salinity','unit','PSU','long_unit','P.S.U.');
	T.THSIG0  = odata('name','THSIG0','long_name','Main Thermocline Potential Density','unit','kg/m3','long_unit','kg/m3');
	T.THTEMP  = odata('name','THTEMP','long_name','Main Thermocline Temperature','unit','degC','long_unit','degree Celsius');
	T.THBFRQ  = odata('name','THBFRQ','long_name','Main Thermocline Brunt-Vaisala Frequency squared','unit','1/s2','long_unit','1/s2');
	T.THMWD   = odata('name','THMWD' ,'long_name','Mode Water Core Depth from TH diagnostic','unit','m','long_unit','meter');
	T.THHC    = odata('name','THHC'  ,'long_name','Main Thermocline Heat content','unit','J/m2','long_unit','J/m2');

	% About the Eighteen Degree Mode Water (EDW*):
	T.EDWH    = odata('name','EDWH'    ,'long_name','EDW thickness','unit','m','long_unit','meter');
	T.EDWD    = odata('name','EDWD'    ,'long_name','EDW Core Depth (18^oC isotherm depth)','unit','m','long_unit','meter');
	T.EDWDTOP = odata('name','EDWDTOP' ,'long_name','EDW Top Depth (19^oC isotherm depth)','unit','m','long_unit','meter');
	T.EDWDBTO = odata('name','EDWDBTO' ,'long_name','EDW Bottom Depth (17^oC isotherm depth)','unit','m','long_unit','meter');
	T.EDWPLPV = odata('name','EDWPLPV' ,'long_name','EDW Planetary Potential Vorticity (q = f*N2/g)','unit','1/m/s','long_unit','1/m/s');
	T.EDWPSAL = odata('name','EDWPSAL' ,'long_name','EDW salinity','unit','psu','long_unit','psu');

	% Misc:
	T.NOP = odata('name','NOP','long_name','Preformed Nitrate','unit','mumol/kg','long_unit','micromol/kilogram');
	T.HC  = odata('name','HC' ,'long_name','Heat Content','unit','J/m2','long_unit','J/m2');
	T.TOTHC  = odata('name','TOTHC' ,'long_name','Total Heat Content','unit','J/m2','long_unit','J/m2');

end %functiondata_list_user
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
