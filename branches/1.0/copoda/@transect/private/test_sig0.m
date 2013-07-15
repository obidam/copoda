% test_sig0 H1LINE
%
% [] = test_sig0()
% 
% HELPTEXT
%
% Created: 2009-11-25.
% Copyright (c) 2009, Guillaume Maze (Laboratoire de Physique des Oceans).
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

function varargout = test_sig0(varargin)

test_name = 'Density referenced to surface';
test_desc = {'Check if SIG0 is a data field and try to compute it otherwise'};
res   = false;
fixed = false;
switch nargin
	case 0
		varargout(1) = {11}; % ID of the test
		varargout(2) = {test_desc};
		return
	otherwise
		T 		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
if ~isdata(T,'SIG0')
	if isdata(T,'TEMP') & isdata(T,'PSAL')
		if fixe
			temp = T.data.TEMP.cont;
			salt = T.data.PSAL.cont;
			for ip = 1 : size(temp,1)
				ST0(ip,:)  = densjmd95(salt(ip,:),temp(ip,:),0) - 1000;
		  	end
			OD = odata('name','SIG0',...
						'long_name',sprintf('Density of Sea Water at atmospheric pressure, added by %s',getenv('USER')),...
						'unit','kg/m3','long_unit','kg/m3',...
						'cont',ST0);
			T = addodata(T,'SIG0',OD);
			res = true;
			fixed = true;
			disp_res(test_name,'Added missing sig0 to datas',verbose);		
			msg(1).text_name = 'Added missing sig0 to datas';
			msg(1).result = 'OK';
			
		else
			disp_res(test_name,'No sig0, but can be fixed',verbose)		
			res = true; % 
			msg(1).text_name = 'No sig0, but can be fixed';
			msg(1).result = '-';
		end
	else
		disp_res(test_name,'No temperature and/or salinity datas in this transect to compute sig0',verbose)		
		res = true; % Because this is not somehting we gonna be able to fix !
		msg(1).text_name = 'No temperature and/or salinity datas in this transect to compute sig0';
		msg(1).result = 'OK';
	end
else
	res = true;
	msg(1).result = 'OK';
	msg(1).text_name = 'SIG0 already in there';
	disp_res(test_name,'SIG0 already exists',verbose)		
	
end%if




if fixed, res=true;end
if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {msg};
	varargout(3) = {fixed};
	varargout(4) = {T};
end



end %functiontest_sig0












