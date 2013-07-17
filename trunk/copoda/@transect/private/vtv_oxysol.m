% vtv_oxysol Compute Virtual OXSL
%
% OXSL = vtv_oxysol(T,[INDEXSTRUCT])
% 
% Compute Virtual OXSL from TEMP and PSAL
%
% Created: 2010-03-05.
% Copyright (c) 2010, Guillaume Maze (Laboratoire de Physique des Oceans).
% All rights reserved.
% http://codes.guillaumemaze.org

% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 	* Redistributions of source code must retain the above copyright notice, this list of 
% 	conditions and the following disclaimer.
% 	* Redistributions in binary form must reproduce the above copyright notice, this list 
% 	of conditions and the following disclaimer in the documentation and/or other materials 
% 	provided with the distribution.
% 	* Neither the name of the Laboratoire de Physique des Oceans nor the names of its contributors may be used 
%	to endorse or promote products derived from this software without specific prior 
%	written permission.
%
% THIS SOFTWARE IS PROVIDED BY Guillaume Maze ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, 
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Guillaume Maze BE LIABLE FOR ANY 
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%

function varargout = vtv_oxysol(varargin)

vtv_name = 'OXSL';
vtv_desc = {'Compute: Oxygen Solubility'};
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
if ~isdata(T,'TEMP') & ~isdata(T,'PSAL')
	if isdata(T,'TEMP',0) & isdata(T,'PSAL',0)
		error('I can''t compute Oxygen Solubility (OXSL) with empty TEMP and PSAL')
	else
		error('I can''t compute Oxygen Solubility (OXSL) without TEMP and PSAL')
	end
else
	Temp = getfield(T.data.TEMP.cont,index(end).subs);
	Salt = getfield(T.data.PSAL.cont,index(end).subs);
%	Temp = T.data.TEMP.cont;
%	Salt = T.data.PSAL.cont;
%	Temp = subsref(T.data.TEMP,index);
%	Salt = subsref(T.data.PSAL,index);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
switch T.data.OXSL.unit
	case 'ml/l'
		C = oxysol(Temp,Salt,'ml/l');
		varargout(1) = {C};
		return
	case 'mumol/kg'
		C = oxysol(Temp,Salt,'mumol/kg');
		varargout(1) = {C};
		return
	otherwise
		error('Oxygen solubility has a wired unit')
end

end %functionvtv_oxysol













