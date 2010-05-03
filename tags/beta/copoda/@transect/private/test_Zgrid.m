% test_Zgrid change vertical depth grid
%
% [] = test_Zgrid()
% 
% HELPTEXT
%
% Created: 2010-02-11.
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

function varargout = test_Zgrid(varargin)
	
test_name = 'Vertical resolution';
test_desc = {'Change the vertical grid to a regular one defined by the global variable:';...
			'	global validate_transect_Zgrid';...
			'	validate_transect_Zgrid.ztop   = 0;';...
			'	validate_transect_Zgrid.zbot   = -5500;';...
			'	validate_transect_Zgrid.dz     = -10;';...
			'	validate_transect_Zgrid.method = ''linear'';'};
switch nargin
	case 0
		varargout(1) = {12};
		varargout(2) = {test_desc};
		return
	otherwise
		T 		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end

res   = false;
fixed = false;
if fixe
	try 
		
		%%%%%%%% New axis:
		global validate_transect_Zgrid
		if isempty(validate_transect_Zgrid)  % Default parameter
			validate_transect_Zgrid.ztop   = 0;
			validate_transect_Zgrid.zbot   = -5500;
			validate_transect_Zgrid.dz     = -10;
			validate_transect_Zgrid.method = 'linear';
		%	validate_transect_Zgrid.method = 'spline';
		end
		newZ = validate_transect_Zgrid.ztop:validate_transect_Zgrid.dz:validate_transect_Zgrid.zbot;
		newZ = meshgrid(newZ,1:T.cruise_info.N_STATION);

		%%%%%%%% Old Axis:
		oldZ = T.geo.DEPH;

		%%%%%%%% Interpolation:
		datalist = datanames(T);
		for iv = 1 : length(datalist)
			od = getfield(T.data,datalist{iv});
	
			%%% Compute new fields cont and prec:
	
			C = od.cont;
			for is = 1 : size(C,1)
				idef = find(isnan(C(is,:))==0);				
				if length(idef>2)
					Cnew(is,:) = interp1(oldZ(is,idef),C(is,idef),newZ(is,:),validate_transect_Zgrid.method);				
				else
					Cnew(is,:) = NaN*ones(1,size(newZ,2));
				end			
			end%for is
	
			if size(od.prec,1) ~= 1 & size(od.prec,2) ~= 1	% 2 dimensions defined
				P = od.prec;
				for is = 1 : size(P,1)
					idef = find(isnan(P(is,:))==0);
					if length(idef>2)
						Pnew(is,:) = interp1(oldZ(is,idef),P(is,idef),newZ(is,:),validate_transect_Zgrid.method);
					else
						Pnew(is,:) = NaN*ones(1,size(newZ,2));
					end
				end%for is
			elseif size(od.prec,1) == 1 & size(od.prec,2) ~= 1	% Only one profil for all stations
				P = od.prec;
				idef = find(isnan(P(1,:))==0);
				if length(idef>2)
					Pnew(1,:) = interp1(oldZ(1,idef),P(1,idef),newZ(is,:),validate_transect_Zgrid.method);
				else
					Pnew(1,:) = NaN*ones(1,size(newZ,2));
				end
			else
				Pnew = od.prec;
			end
	
			%%% Update transect:
			od.cont = Cnew;
			od.prec = Pnew;
			T.data = setfield(T.data,datalist{iv},od);
	
		end%for iv

		%%%%%%%% Update geo properties of transect:
		T.geo = setfield(T.geo,'DEPH',newZ);
		C = T.geo.PRES;
		for is = 1 : size(C,1)
			idef = find(isnan(C(is,:))==0);
			if length(idef>2)
				Cnew(is,:) = interp1(oldZ(is,idef),C(is,idef),newZ(is,:),validate_transect_Zgrid.method);
			else
				Cnew(is,:) = NaN*ones(1,size(newZ,2));
			end
		end%for is
		T.geo = setfield(T.geo,'PRES',Cnew);
		
		res = true;
		fixed = true;		
		msg(1).result = 'OK';
		msg(1).text_name = 'Vertical depth axis interpolated';
		disp_res(test_name,'OK and fixed',verbose);
				
	catch
	
		res   = false;
		fixed = false;
		msg(1).result = 'Echec';
		l = lasterror; %s = l.stack; s.file,s.name,s.line
		msg(1).text_name = sprintf(' An error occured when interpolating: %s',l.message);
		disp_res(test_name,'echec',verbose);		
	
	end%try

else
	
	res = true;
	fixed = false;
	msg(1).result = 'OK';
	msg(1).text_name = 'OK but not interpolated because not asked to fixe';
	disp_res(test_name,'OK but not interpolated because not asked to fixe',verbose);
		
end


if fixed, res=true; end
if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {msg};
	varargout(3) = {fixed};
	varargout(4) = {T};
end


end %functiontest_Zgrid