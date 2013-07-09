% virtual_VTST Compute a virtual variable
%
% C = virtual_variables(T,VNAME)
% 
% From the transect object datas T, this function computes the
% "virtual" variable content named VNAME. 
% A virtual variable is an odata object within the transect data 
% list which has meta informations (name, unit, etc ...) but no content.
%
% This function should be called by transect/subsref.m
%
% The status (REAL/VIRTUAL) of an odata object is set by 
% the T.data.PARAMETERS_STATUS variable.
%
% Created: 2010-03-04.
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

function C = virtual_variables(varargin)

T     = varargin{1};
VNAME = varargin{2};
if nargin == 3
	index = varargin{3};
else
	index = NaN;
end

%index(1)
%index(2)

VTVlist = list_all_vtv;
found = false;
for ivtv = 1 : length(VTVlist)
	if strcmp(VTVlist(ivtv).vname,VNAME)
		found = true;
		if ~isa(index,'struct')
			eval(sprintf('C = %s(T);',VTVlist(ivtv).fct))
		else
			eval(sprintf('C = %s(T,index);',VTVlist(ivtv).fct))			
		end
	end% if 
end% for ivtv

if ~found
	error('A private routine is missing to compute this virtual variable !')
end% if 

end %functionvirtual_variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%
function VTV = list_all_vtv(varargin)
	
	p  = class_home;
	di = dir(class_home);
	it = 0;
	for ii = 1 : length(di)
		if ~di(ii).isdir
			if strfind(di(ii).name,'.m') & strfind(di(ii).name,'vtv_')
				it = it + 1;
				VTV(it).fct = strrep(di(ii).name,'.m','');
				[VTV(it).vname VTV(it).desc] = eval(VTV(it).fct);
			end
		end
	end
	if it == 0
		VTV = NaN;
	end

end%function

%%%%%%%%%%%%%%%%%%%
function p = class_home()
	p = strrep([mfilename('fullpath') '.m'],[mfilename '.m'],'');
end%function










