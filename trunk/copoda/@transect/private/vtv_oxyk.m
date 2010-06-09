% vtv_oxyk Compute OXYK from OXYL
%
% C = vtv_oxyk(T,[INDEXSTRUCT])
% 
% Compute OXYK from OXYL
%
% Created: 2010-06-03.
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

function varargout = vtv_oxyk(varargin)

vtv_name = 'OXYK';
vtv_desc = {'Compute Oxygen concentration in mumol/kg'};
switch nargin
	case 0
		varargout(1) = {vtv_name};
		varargout(2) = {vtv_desc};
		return
	otherwise
		T = varargin{1};
		if nargin == 2
			index = varargin{2};
		else		
			index(1).type = '.';
			index(1).subs = 'cont';
			index(2).type = '()';
			index(2).subs = {':' ':'};
		end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
if isdata(T,'OXYL')
	OXYL = getodata(T,'OXYL');
	oxyl = getfield(OXYL,'cont',index(2).subs);
else
	error('I can''t compute OXYK without Oxygen Concentration in ml/l (OXYL)')
end

if isdata(T,'SIG0')
	SIG0 = getodata(T,'SIG0');
	sig0 = getfield(SIG0,'cont',index(2).subs);
elseif isdata(T,'TEMP') & isdata(T,'PSAL')
	psal = getfield(PSAL,'cont',index(2).subs);
	temp = getfield(TEMP,'cont',index(2).subs);
	sig0 = densjmd95(psal,temp,0) - 1000;	
else
	sig0 = NaN;
end	

if ~isnan(sig0)
	oxyk = convert_unit(oxyl,'OXY','ml/l','mumol/kg',sig0);
else
	oxyk = convert_unit(oxyl,'OXY','ml/l','mumol/kg');
end

varargout(1) = {oxyk};

end %functionvtv_oxyk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
