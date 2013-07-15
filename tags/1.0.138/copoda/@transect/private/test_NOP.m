% test_NOP H1LINE
%
% [] = test_NOP()
% 
% Compute preformed nitrate according to Eq.(1) in:
%	J.~Abell, S.~Emerson, and R.~G. Keil
%	Using preformed nitrate to infer decadal changes in dom
%  	remineralization in the subtropical north pacific.
%	Global Biogeochem. Cycles, 19(1), 2005.
%
% Created: 2011-11-17.
% http://code.google.com/p/copoda
% Copyright 2011, COPODA

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
function varargout = test_NOP(varargin)

test_name = 'Preformed Nitrate';
test_desc = {'Check if variable NOP exists and try to compute it otherwise'};
res   = false;
fixed = false;
rON = 10; % O2 to NO3 Redfield ratio, 



switch nargin
	case 0
		varargout(1) = {15}; % ID of the test
		varargout(2) = {test_desc};
		return
	otherwise
		T 		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end	

%- Already exists:
if isdata(T,'NOP')
	disp_res(test_name,'NOP already exists, not overwritten',verbose);
	msg(1).test_name   = test_name;
	msg(1).test_result = 'OK';
	fixed = true; 
	res   = true;

%- Fix it (compute it):
elseif isdata(T,'AOU')	& isdata(T,'NITR') & fixe 
	% Compute preformed nitrate:
	switch T.data.AOU.unit
		case 'mumol/kg'
			% Nothing to do, correct unit
			AOU = T.data.AOU.cont;
		otherwise
			% Try to convert to mumol/kg
			try 
				if isdata(T,'SIG0')
					AOU = convert_unit(T.data.AOU.cont,'OXY',T.data.AOU.unit,'mumol/kg',T.data.SIG0.cont);
				else
					AOU = convert_unit(T.data.AOU.cont,'OXY',T.data.AOU.unit,'mumol/kg');
				end% if 
			catch
				disp_res(test_name,'Echec, cannot change unit of AOU to compute NOP (preformed nitrate)',verbose);
				msg(1).test_name   = test_name;
				msg(1).test_result = 'Echec';
				res = false;
			end
	end% switch 
	NOP =  T.data.NITR.cont - AOU./rON;
	
	od = odata('name','NOP',...
				'long_name',sprintf('Preformed Nitrate (computed using r-O2:NO3=%0.1f)',rON),...
				'unit','mumol/kg','long_unit','micromol/kilogram');
	od.cont = NOP;
	T = setodata(T,'NOP',od,'R');

	disp_res(test_name,'OK, NOP created',verbose);
	msg(1).test_name   = test_name;
	msg(1).test_result = 'OK';
	fixed = true;
	res   = true;

%-- Can we fix it ?	
else
	if isdata(T,'AOU')	& isdata(T,'NITR')
		disp_res(test_name,'OK, fields exist to compute NOP (use fix=1 option)',verbose);
		msg(1).test_name   = test_name;
		msg(1).test_result = 'OK';
		fixed = false;
		res   = true;
	elseif fixe
		disp_res(test_name,'Echec, cannot compute NOP without AOU and NITR !',verbose);
		msg(1).test_name   = test_name;
		msg(1).test_result = 'Echec';
		fixed = false;
		res   = false;
	else
		disp_res(test_name,'Echec, I couldn''t compute NOP without AOU and NITR !',verbose);
		msg(1).test_name   = test_name;
		msg(1).test_result = 'Echec';
		fixed = false;
		res   = false;
	end% if
end% if 

%- Outputs
if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {msg};
	varargout(3) = {fixed};
	varargout(4) = {T};
end



end %functiontest_NOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
