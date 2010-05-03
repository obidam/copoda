% vtv_aou Compute Virtual AOU
%
% AOU = vtv_aou(T)
% 
% Compute Virtual AOU from OXYL or and OXYK and OXSL
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

function varargout = vtv_aou(varargin)

vtv_name = 'AOU';
vtv_desc = {'Compute: Apparent Oxygen Utilization'};
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

%index(1)
% index(2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 1st, we check if we have the required variables
if isdata(T,'OXSL')
	OXSL = getodata(T,'OXSL');
	oxsl = getfield(OXSL,'cont',index(2).subs);
else
	error('I can''t compute AOU without Oxygen Solubility OXSL')
end

if     ~isdata(T,'OXYL') & ~isdata(T,'OXYK')
	error('I can''t compute AOU without Oxygen Concentration OXYL or OXYK')
elseif ~isdata(T,'OXYL') & isdata(T,'OXYK')
	OXY = getodata(T,'OXYK');
elseif  isdata(T,'OXYL') & ~isdata(T,'OXYK')
	OXY = getodata(T,'OXYL');
else % We take the one with similar unit
	OXY = getodata(T,'OXYL');
end	

oxy = getfield(OXY,'cont',index(2).subs);	
try,
	if isdata(T,'SIG0')
		oxy = convert_unit(oxy,'OXY',OXY.unit,OXSL.unit,getfield(T.data.SIG0.cont,index(2).subs));
	else
		oxy = convert_unit(oxy,'OXY',OXY.unit,OXSL.unit);
	end
	OXY.unit = OXSL.unit;
end

AOU = T.data.AOU;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2nd, we check the unit compatibility
if strcmp(AOU.unit,OXSL.unit)
	% ALL OK here:
	C = oxsl - oxy;
	varargout(1) = {C};
	return
else
	% try to convert units
	try 
		if isdata(T,'SIG0')
			oxsl = convert_unit(oxsl,'OXY',OXSL.unit,AOU.unit,getfield(T.data.SIG0.cont,index(2).subs));
		else
			oxsl = convert_unit(oxsl,'OXY',OXSL.unit,AOU.unit);
		end
		C = oxsl - oxy;
		varargout(1) = {C};
		return
	catch
		error('I couldn''t compute AOU because of units issues ! You should double check if OXSL and OXYK or OXYL have similar units of AOU')	
	end
end






end %functionvtv_aou


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function status = get_status(T,name);
	
	%% Check the status of the field (Real or Virtual ?)								
	L = datanames(T);
	[i ii] = intersect(L,name);
	status = T.data.PARAMETERS_STATUS(ii);
	
end%function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function C = get_oxsl(T,index)
	
	if ~isdata(T,'TEMP') & ~isdata(T,'PSAL')
		error('I can''t compute Oxygen Solubility (OXSL) without TEMP and PSAL')
	else
		Temp = getfield(T.data.TEMP.cont,index(end).subs);
		Salt = getfield(T.data.PSAL.cont,index(end).subs);
	end

	%%%%%%%%%%
	switch T.data.AOU.unit
		case 'ml/l'
			C = oxysol(Temp,Salt,'ml/l');
			varargout(1) = {C};
			return
		case 'mumol/kg'
			C = oxysol(Temp,Salt,'mumol/kg');
			varargout(1) = {C};
			return
		otherwise
			error('AOU has a wired unit')
	end

end%function







