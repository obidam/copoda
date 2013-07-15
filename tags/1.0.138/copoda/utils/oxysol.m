% oxysol Compute solubility of Oxygen (O2) in sea water at STP, real gas
%
% SOLO2 = oxysol(T,S,[OPT])
% 
% Compute solubility of Oxygen (O2) in sea water at STP, real gas.
%
% Inputs:
%	T: temperature in degree C
%	S: salinity in psu (no unit)
%	OPT: optional argument, it can be:
% 		a method (double): one of the methods available (see below)
%		'ml/l' 	   to specify the solubility unit
%		'mumol/kg' to specify the solubility unit
%		'check' to perform a value check of all the methods
%
% Output:
%	SOLO2: solubility in ml/l (default unit, unless otherwise specified by OPT)
%
% Methods:
%	1          : Weiss, 1970 (idem as sw_satO2.m routine from seawater package)
%	2 (default): Benson and Krauss, 1984
%	3          : Garcia and Gordon, 1992, with Benson and Krauss datas
%	4          : Garcia and Gordon, 1992, with Murray & Riley (1969) and Carpenter (1966) datas
%	5          : Garcia and Gordon, 1992, with a combined fit of coef.
%
% Example:
%	for t=1:40, for im=1:5
%		sol(t,im) = oxysol(t,35,im);
%	end, end
%	figure; 
%	plot(sol,'linewidth',2); grid on, box on,
%	xlabel('Temperature in degC');ylabel('O2 solubility in ml/l for a salinity of 35');
%	legend('Weiss 1970','Benson and Krauss 1984','Garcia and Gordon 1992 (with B&K datas)',...
%			'Garcia and Gordon 1992 (with M&R&C datas)','Garcia and Gordon 1992, with a combined fit of coef')
%
% Remarks:
%	When only physical processes are involved, the dissolved oxygen (DO) concentration in 
%	water is governed by the laws of solubility, i.e., it is a function of atmospheric pressure, 
%	water temperature, and salinity. The corresponding equilibrium concentration is generally 
%	called solubility. It is an essential reference for the interpretation of DO data. Precise 
% 	solubility data, tables, and mathematical functions have been established (Carpenter, 1966; 
% 	Murray and Riley, 1969; Weiss, 1970) and adopted by the international community (UNESCO, 1973). 
% 	However, Weiss (1981) drew attention to an error in the international tables in which the 
% 	values are low by 0.10 % since they are based on ideal gas molar volume instead of actual 
% 	dioxygen molar volume. Later, the Joint Panel on Oceanographic Tables and Standards (JPOTS) 
% 	recommended that the oxygen solubility equation of Benson and Krause (1984), which 
% 	incorporated improved solubility measurements, be adopted and the tables updated (UNESCO, 1986). 
% 	However, the UNESCO paper only referred to the equation that gives concentrations in the 
% 	unit “micromole per kilogram”.
% 
% Help: 
%	http://www.helcom.fi/groups/monas/CombineManual/AnnexesB/en_GB/annex9app3/
%
% References:
% 	Benson, B.B., and Krause, D., Jr. 1984. The concentration and isotopic fractionation of oxygen 
%		dissolved in freshwater and seawater in equilibrium with the atmosphere. Limnology and 
%		Oceanography, 29: 620–632.
% 	Carpenter, J.H. 1966. New measurements of oxygen solubility in pure and natural water. 
%		Limnology and Oceanography, 11: 264–277.
%	Culberson, C.H. 1991. Dissolved oxygen. WOCE Hydrographic Programme Operations and Methods 
%		(July 1991). 15 pp.
%	Garcia and Gordon 1992. Oxygen solubility in seawater: better fitting equations
%		Limnology and Oceanography, 37 (6): p1307-1312
%	Garcia 1993. Erratum: Oxygen solubility in seawater: better fitting equations
%		Limnology and Oceanography, 38 (3): p656
%	Murray, C.N., and Riley, J.P. 1969. The solubility of gases in distilled water and sea 
%		water - II. Oxygen. Deep-Sea Research, 16: 311–320.
% 	UNESCO. 1973. International oceanographic tables, Vol. 2. NIO-UNESCO, Paris.
% 	UNESCO. 1986. Progress on oceanographic tables and standards 1983–1986: work and 
%		recommendations of the UNESCO/SCOR/ICES/IAPSO Joint Panel. UNESCO Technical Papers 
%		in Marine Science, 50. 59 pp.
% 	Weiss, R.F. 1970. The solubility of nitrogen, oxygen and argon in water and seawater. 
%		Deep-Sea Research, 17: 721–735.
% 	Weiss, R.F. 1981. On the international oceanographic tables, Vol. 2, UNESCO 1973, Oxygen 
%		solubility in seawater. UNESCO Technical Papers in Marine Science, 36: 22.
%
%
% Rev. by Guillaume Maze on 2012-04-23: Updated methods 3/4/5 with Garcia (1993) erratum formulae.
%
% Created: 2009-09-23.
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

function varargout = oxysol(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input check:
error(nargchk(2,4,nargin,'struct'));
T = varargin{1};
S = varargin{2};
if size(T) ~= size(S)
	error('Temperature and Salinity must have similar dimensions');
end

if nargin >= 3
	method = varargin{3};
else
	method = 2; % Default method
end

% Default unit of output:
unit_out = 'ml/l'; 

% Adjust with arguments:
if ischar(method)
	method_list = 2; % Default method
	check = 0;
	switch method
		case 'ml/l',     unit_out = 'ml/l';
		case 'mumol/kg', unit_out = 'mumol/kg';
		case 'check'
%			unit_out = 'mumol/kg';
			unit_out = 'ml/l';
			method_list = [1 2 3 4 5];
			check = 1;
			T = 10;
			S = 35;
			disp(sprintf('Check values for T=%0.3f degC and S=%0.3f',T,S));
		otherwise
			error('Third argument must be ''ml/l'', ''mumol/kg'' or ''check''');
	end%switch
else
	method_list = method;
	check = 0;
end

% Potential density anomaly, referred to 0 (for method 1)
if length(size(S)) >= 3
	if nargin < 4
		error('For more than 2 dimensions, you must provide the depth axis as the fourth argument');
	else
		Z = varargin{4};	
	end
	for iz = 1 : size(S,1)
		sig0(iz,:,:) = densjmd95(S(iz,:,:),T(iz,:,:),0.09998*9.81*abs(Z(iz))*ones(1,size(S,2),size(S,3)))-1000;
	end%for iz
else
	sig0 = densjmd95(S,T,0)-1000;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% We insert a loop here to check all methods against predefined T,S
% In normal computation, the loop iters only once on the required method

for im = 1 : length(method_list)
	method = method_list(im);
	clear a0 a1 a2 a3 a4 a5 b0 b1 b2 b3 b4 b5 c0
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
	switch method
		case 1  % Weiss, R. F. 1970 
				% The solubility of nitrogen, oxygen and argon in water and seawater."
		    	% Deap-Sea Research., 1970, Vol 17, pp721-735.

			% Convert T to Kelvin:
			Ts = 273.15 + T * 1.00024;

			% Constants for Eqn (4) of Weiss 1970
			a1 = -173.4292;
			a2 =  249.6339;
			a3 =  143.3483;
			a4 =  -21.8492;
			b1 =   -0.033096;
			b2 =    0.014259;
			b3 =   -0.0017000;

			% Eqn (4) of Weiss 1970
			lnC = a1 + a2.*(100./Ts) + a3.*log(Ts./100) + a4.*(Ts./100) + ...
			      S.*( b1 + b2.*(Ts./100) + b3.*((Ts./100).^2) );

			C = exp(lnC);
			C = convert_unit(C,'OXY','ml/l',unit_out,sig0);
		
			if check, disp(sprintf('Method %2i: %50s -> %0.3f %s',method,'Weiss 1970',C,unit_out)); end
		
		case 2 % Benson and Krauss 1984
			% The concentration and isotopic fractionation of oxygen 
			% dissolved in freshwater and seawater in equilibrium with the atmosphere. 
			% Limnology and Oceanography, 29: 620–632.
		
			switch unit_out
				case 'mumol/kg'
					% Constants for eq(31) of Benson and Krauss 1984
					% To get mumol/kg:
					a0 = -135.29996;
					a1 =    1.572288*1e5;
					a2 =   -6.637149*1e7;
					a3 =    1.243678*1e10;
					a4 =   -8.621061*1e11;
					b0 =    0.020573;
					b1 =  -12.142;
					b2 = 2363.1;
				
				case 'ml/kg'
					% Constants for eq(31) of Benson and Krauss 1984
					% To get cm3/kg = ml/kg:
					a0 = -139.09803;
					a1 = 1.572288*1e5;
					a2 = -6.37149*1e7;
					a3 = 1.243678*1e10;
					a4 = -8.621061*1e11;
					b0 = 0.020573;
					b1 = -12.142;
					b2 = 2363.1;
		
				case 'mumol/l'
					% Constants for eq(32) of Benson and Krauss 1984
					% To get mumol/l:
					a0 = -135.90205; 
					a1 = 1.575701*1e5;
					a2 = -6.642308*1e7;
					a3 = 1.243800*1e10;
					a4 = -8.621949*1e11;
					b0 = 0.017674;
					b1 = -10.754;
					b2 = 2140.7;					
						
				case 'ml/l'	
					% Constants for eq(32) of Benson and Krauss 1984
					% To get ml/l:
					a0 = -139.70012; 
					a1 = 1.575701*1e5;
					a2 = -6.642308*1e7;
					a3 = 1.243800*1e10;
					a4 = -8.621949*1e11;
					b0 = 0.017674;
					b1 = -10.754;
					b2 = 2140.7;						
			end%switch unit			
							
			% Convert T to Kelvin:
			Ts = 273.15 + T;
		
			% eq(31) or eq(32) of Benson and Krauss 1984
			lnC = a0 + a1./Ts + a2./Ts.^2 + a3./Ts.^3 + a4./Ts.^4 - S.*(b0 + b1./Ts + b2./Ts.^2);
	%		lnC = fix(lnC*1e2)./1e2
			%	
			C = exp(lnC);
				
	%		t = T;		
	%		exp(-135.29996 + (1.572288 *1e5) / (t + 273.15) - (6.637149 *1e7) / (t + 273.15)^2 + (1.243678 *1e10) /...
	%		(t + 273.15)^3 - (8.621061 *1e11) / (t + 273.15)^4 - S * (0.020573 - 12.142 / (t + 273.15)+ 2363.1 / (t + 273.15)^2) )
				
				
			if check, 
				switch unit_out
					case 'mumol/kg', Cref = 274.61;
					case 'ml/l', 	 Cref = 274.61*2.2414*1e-2*convert_unit(1,'oxy','ml/kg','ml/l',sw_dens0(S,T)-1000);
				end
				disp(sprintf('Method %2i: %50s -> %0.3f %s (%0.3f from the paper)',method,...
						'Benson and Krauss 1984',C,unit_out,Cref)); 
			end


		case 3 % Garcia and Gordon 1992
			% Oxygen solubility in seawater: better fitting equations
			% Limnology and Oceanography, 37: 1307-1312
		
			% Constants For eq(8) of Garcia and Gordon 1992 with coef of Benson and Krause (table 1, col 1 and 2)
			switch unit_out
				case 'ml/l'
					a0 = 2.00907;
					a1 = 3.22014;
					a2 = 4.05010;
					a3 = 4.94457;
					a4 = -2.56847*1e-1;
					a5 = 3.88767;
					b0 = -6.24523*1e-3;
					b1 = -7.37614*1e-3;
					b2 = -1.03410*1e-2;
					b3 = -8.17083*1e-3;
					c0 = -4.88682*1e-7;
				case 'mumol/kg'
					a0 = 5.80871;
					a1 = 3.20291;
					a2 = 4.17887;
					a3 = 5.10006;
					a4 = -9.86643*1e-2;
					a5 = 3.80369;
					b0 = -7.01577*1e-3;
					b1 = -7.70028*1e-3;
					b2 = -1.13864*1e-2;
					b3 = -9.51519*1e-3;
					c0 = -2.75915*1e-7;
			end%switch unit			
			
			% Scaled temperature with T in degC
			Ts  = log( (298.15-T)./(273.15+T) ); 

			% eq(8) of Garcia and Gordon 1992:
	%		lnC =       a0    + a1*Ts    + a2*Ts.^2 + a3*Ts.^2 ...
	%				          + a3*Ts.^3 + a4*Ts.^4 + a5*Ts.^5 ...
	%			  + S.*(b0    + b1*Ts    + b2*Ts.^2 + b3*Ts.^3) ...
	%			  + c0*S.^2;
			% Following the Gordon (1993) erratum about the a3*Ts.^2 term:
			lnC =       a0    + a1*Ts    + a2*Ts.^2 + ...
					          + a3*Ts.^3 + a4*Ts.^4 + a5*Ts.^5 ...
				  + S.*(b0    + b1*Ts    + b2*Ts.^2 + b3*Ts.^3) ...
				  + c0*S.^2;

			%
			C = exp(lnC);			
		
			if check, 
				switch unit_out
					case 'mumol/kg', Cref = 274.610;
					case 'ml/l', 	 Cref = 6.315;
				end
				disp(sprintf('Method %2i: %50s -> %0.3f %s (%0.3f from the paper)',method,...
						'Garcia and Gordon 1992 (with B&K datas)',C,unit_out,Cref)); 
			end

		
		case 4 % Garcia and Gordon 1992
			% Oxygen solubility in seawater: better fitting equations
			% Limnology and Oceanography, 37: 1307-1312

			% Constants For eq(8) of Garcia and Gordon 1992 with coef of Murray, Riley, Carpenter (table 1, col 3 and 4)
			switch unit_out
				case 'ml/l'
					a0 = 2.00805;
					a1 = 3.22773;
					a2 = 3.93008;
					a3 = 4.68335;
					a4 = 2.51836;
					a5 = 4.60916*1e-1;
					b0 = -6.23669*1e-3;
					b1 = -6.49387*1e-3;
					b2 = -3.47040*1e-3;
					b3 = -4.27025*1e-4;
					c0 = -6.40583*1e-8;
				
				case 'mumol/kg'
					a0 = 5.80767;
					a1 = 3.21049;
					a2 = 4.05806;
					a3 = 4.84125;
					a4 = 2.78998;
					a5 = 8.07948*1e-1;
					b0 = -7.00781*1e-3;
					b1 = -6.81863*1e-3;
					b2 = -4.50121*1e-3;
					b3 = -1.68803*1e-3;
					c0 = -1.25609*1e-7;
			
			end%switch unit			

			% Scaled temperature with T in degC
			Ts  = log( (298.15-T)./(273.15+T) ); 

			% eq(8) of Garcia and Gordon 1992:
	%		lnC =       a0    + a1*Ts    + a2*Ts.^2 + a3*Ts.^2 ...
	%				          + a3*Ts.^3 + a4*Ts.^4 + a5*Ts.^5 ...
	%			  + S.*(b0    + b1*Ts    + b2*Ts.^2 + b3*Ts.^3) ...
	%			  + c0*S.^2;
			% Following the Gordon (1993) erratum about the a3*Ts.^2 term:
			lnC =       a0    + a1*Ts    + a2*Ts.^2 + ...
					          + a3*Ts.^3 + a4*Ts.^4 + a5*Ts.^5 ...
				  + S.*(b0    + b1*Ts    + b2*Ts.^2 + b3*Ts.^3) ...
				  + c0*S.^2;

			%
			C = exp(lnC);			
	%		C = convert_unit(C,'OXY','ml/l',unit_out);

			if check, 
				switch unit_out
					case 'mumol/kg', Cref = 274.735;
					case 'ml/l', 	 Cref = 6.318;
				end
				disp(sprintf('Method %2i: %50s -> %0.3f %s (%0.3f from the paper)',method,...
						'Garcia and Gordon 1992 (with M&R&C datas)',C,unit_out,Cref)); 
			end
		
		case 5 % Garcia and Gordon 1992
			% Oxygen solubility in seawater: better fitting equations
			% Limnology and Oceanography, 37: 1307-1312

			% Constants For eq(8) of Garcia and Gordon 1992 with combined fit for coef (table 1, col 5 and 6)
			switch unit_out
				case 'ml/l'
					a0 = 2.00856;
					a1 = 3.22400;
					a2 = 3.99063;
					a3 = 4.80299;
					a4 = 9.78188*1e-1;
					a5 = 1.71069;
					b0 = -6.24097*1e-3;
					b1 = -6.93498*1e-3;
					b2 = 6.90358*1e-3;
					b3 = -4.29155*1e-3;
					c0 = -3.11680*1e-7;
				
				case 'mumol/kg'
					a0 = 5.80818;
					a1 = 3.20684;
					a2 = 4.11890;
					a3 = 4.93845;
					a4 = 1.01567;
					a5 = 1.41575;
					b0 = -7.01211*1e-3;
					b1 = -7.25958*1e-3;
					b2 = -7.93335*1e-3;
					b3 = -5.54491*1e-3;
					c0 = -1.32412*1e-7;
			
			end%switch unit			

			% Scaled temperature with T in degC
			Ts  = log( (298.15-T)./(273.15+T) ); 

			% eq(8) of Garcia and Gordon 1992:
	%		lnC =       a0    + a1*Ts    + a2*Ts.^2 + a3*Ts.^2 ...
	%				          + a3*Ts.^3 + a4*Ts.^4 + a5*Ts.^5 ...
	%			  + S.*(b0    + b1*Ts    + b2*Ts.^2 + b3*Ts.^3) ...
	%			  + c0*S.^2;
			% Following the Gordon (1993) erratum about the a3*Ts.^2 term:
			lnC =       a0    + a1*Ts    + a2*Ts.^2 + ...
					          + a3*Ts.^3 + a4*Ts.^4 + a5*Ts.^5 ...
				  + S.*(b0    + b1*Ts    + b2*Ts.^2 + b3*Ts.^3) ...
				  + c0*S.^2;

			%
			C = exp(lnC);			
	%		C = convert_unit(C,'OXY','ml/l',unit_out);

			if check, 
				switch unit_out
					case 'mumol/kg', Cref = 274.647;
					case 'ml/l', 	 Cref = 6.316;
				end
				disp(sprintf('Method %2i: %50s -> %0.3f %s (%0.3f from the paper)',method,...
						'Garcia and Gordon 1992 (combined fit)',C,unit_out,Cref)); 
			end
	
	end% switch

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
	varargout(1) = {C};

end%for im
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

end %function











