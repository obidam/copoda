% test_oxygen Check if oxygen field is OXYL and the unit ml/l. If only OXYK is
%		found (unit micromoles/kg), OXYL is created by unit conversion.
%
% [] = test_oxygen()
% 
% HELPTEXT
%
%
% Created: 2009-07-31.
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

function varargout = test_oxygen(varargin)

test_name = 'Oxygen field and unit';
test_desc = {'Check if oxygen field is OXYL and the unit ml/l. If only OXYK is';...
				'found (unit micromoles/kg), OXYL is created by unit conversion.'};
res   = false;
fixed = false;
switch nargin
	case 0
		varargout(1) = {5}; % ID of the test
		varargout(2) = {test_desc};
		return
	otherwise
		T 		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OXYL exists but not OXYK, only check unit
if isdata(T,'OXYL') & ~isdata(T,'OXYK')	
	C = getodata(T,'OXYL');
	unit      = C.unit;
	long_unit = C.unit;
	if ~strcmp(unit,'ml/l') & ~strcmp(long_unit,'millitres/litre') % See shorten_unit.m and convert_oxygen.m
		if fixe
			%%%%%%%%% Found weird unit, try ton convert to ml/l:
			try % Try to convert to good unit:
%				Cnew = convert_oxygen(C.cont,C.unit,'ml/l',getfield(T.data,'SIG0','cont'));
				Cnew = convert_unit(C.cont,'OXY',C.unit,'ml/l',getfield(T.data,'SIG0','cont'));
				C.cont = Cnew;
				% Update new unit:
				C.unit = 'ml/l';
				C.long_unit = 'millitres/litre';
				% Update names if unit in there:
				C.name = strrep(C.name,unit,C.unit);
				C.name = strrep(C.name,long_unit,C.long_unit);
				C.long_name = strrep(C.long_name,unit,C.unit);
				C.long_name = strrep(C.long_name,long_unit,C.long_unit);
				disp_res(test_name,'echec, weird oxygen (OXYL) unit, but successfully converted to ml/l',verbose)
				fixed = true;
			catch
				disp_res(test_name,'echec, weird oxygen (OXYL) unit, can''t convert it',verbose)
			end
		else	
			disp_res(test_name,'echec, weird oxygen (OXYL) unit but it may be possible to convert it (try FIX=1)',verbose)
		end
	%%%%%%%%% Unit ok
	else
		disp_res(test_name,'OK',verbose)	
		res = true;			
	end		
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OXYK exists but not OXYL, add new field OXYL by conversion of OXYK
elseif ~isdata(T,'OXYL') & isdata(T,'OXYK')
	C = getodata(T,'OXYK');
	unit      = C.unit;
	long_unit = C.unit;
	%%%%%%%%% OXYK has weird unit:
	if ~strcmp(unit,'mumol/kg') & ~strcmp(long_unit,'micromoles/kg') % See shorten_unit.m and convert_oxygen.m
		if fixe
			try % Try to convert to good unit:
%				Cnew = convert_oxygen(C.cont,C.unit,'ml/l',getfield(T.data,'SIG0','cont'));
				Cnew = convert_unit(C.cont,'OXY',C.unit,'ml/l',getfield(T.data,'SIG0','cont'));
				if ~isempty(Cnew)
					OD = odata('name','OXYL',...
								'long_name',sprintf('Oxygen (in ml/l), added by %s',getenv('USER')),...
								'unit','ml/l','long_unit','millitres/litre',...
								'cont',Cnew);
					T.data = setfield(T.data,'OXYL',OD);
					disp_res(test_name,sprintf('echec, but created OXYL from OXYK (weird unit tough, was %s !)',C.unit),verbose)				
					fixed = true;
				else
					disp_res(test_name,'echec, weird oxygen (OXYK) unit',verbose)
				end
			catch
				disp_res(test_name,'echec, weird oxygen (OXYK) unit',verbose)
			end
		else			
			disp_res(test_name,'echec, weird oxygen (OXYK) unit but it may be converted (try FIX=1)',verbose)
		end
	%%%%%%%%% OXYK has classic unit:		
	else		
		if fixe
			try % Convert to OXYL with right unit:
%				Cnew = convert_oxygen(C.cont,C.unit,'ml/l',getfield(T.data,'SIG0','cont'));
				Cnew = convert_unit(C.cont,'OXY',C.unit,'ml/l',getfield(T.data,'SIG0','cont'));
				OD = odata('name','OXYL',...
							'long_name',sprintf('Oxygen (in ml/l), added by %s',getenv('USER')),...
							'unit','ml/l','long_unit','millitres/litre',...
							'cont',Cnew);
				T = addodata(T,'OXYL',OD);
				disp_res(test_name,'OK, found OXYK and created OXYL',verbose)
				fixed = true;					
			catch
				disp_res(test_name,'echec, can''t convert OXYK to OXYL, may be this is simply because SIG0 is not in the transect',verbose)
			end
		else	
			disp_res(test_name,'echec (try FIX=1)',verbose)
		end	
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OXYK and OXYL exist, check by unit conversion their similarities
elseif isdata(T,'OXYL') & isdata(T,'OXYK')	

	%%%%%%%%%%%% Unknow units !
	if (~strcmp(getfield(T,'data','OXYK','unit'),'mumol/kg') & ...
			~strcmp(getfield(T,'data','OXYK','long_unit'),'micromoles/kg')) | ...
	   (~strcmp(getfield(T,'data','OXYL','unit'),'ml/l') & ...
			~strcmp(getfield(T,'data','OXYL','long_unit'),'millitres/litre'))
		% See shorten_unit.m and convert_oxygen.m
		disp_res(test_name,'Echec, OXYL and/or OXYK have weird units',verbose)
		
	%%%%%%%%%%%% Convert both:
	else
	% 	oxyl2oxyk = convert_oxygen(getfield(T.data,'OXYL','cont'),...
	% 					getfield(T.data,'OXYL','unit'),getfield(T.data,'OXYK','unit'),getfield(T.data,'SIG0','cont'));
	% 	oxyk2oxyl = convert_oxygen(getfield(T.data,'OXYK','cont'),...
	% 					getfield(T.data,'OXYK','unit'),getfield(T.data,'OXYL','unit'),getfield(T.data,'SIG0','cont'));
		oxyl2oxyk = convert_unit(getfield(T.data,'OXYL','cont'),'OXY',...
						getfield(T.data,'OXYL','unit'),getfield(T.data,'OXYK','unit'),getfield(T.data,'SIG0','cont'));
		oxyk2oxyl = convert_unit(getfield(T.data,'OXYK','cont'),'OXY',...
						getfield(T.data,'OXYK','unit'),getfield(T.data,'OXYL','unit'),getfield(T.data,'SIG0','cont'));
		if numel(oxyl2oxyk) ~= numel(oxyk2oxyl)
			disp_res(test_name,'echec OXYL/OXYK dimensions differ',verbose)
		else
			% Check if the nb of points (for which the absolute difference between fields is higher than 0.5% of the minimum)
			% is larger than 1% of the total of grid points
			C1    = abs(oxyl2oxyk - getfield(T.data,'OXYK','cont'));
			C1min = nanmin([oxyl2oxyk(:) ; T.data.OXYK.cont(:)]);
			C2    = abs(oxyk2oxyl - getfield(T.data,'OXYL','cont'));
			C2min = nanmin([oxyk2oxyl(:) ; T.data.OXYL.cont(:)]);
			
			%% Rev. by Guillaume Maze on 2009-11-26: There's a problem here when C1min or C2min are 0 because whatever the amplitude
			% of the difference (C1 or C2), even 1e-25 (for example) will add up to make differences and the test will fail. Therefore
			% we need to scale this minimum to be meaningful:
			if C1min == 0
				C1min = 1e3*eps/0.005; % This something around e-13 !
			end			
			if C2min == 0
				C2min = 1e3*eps/0.005; % This something around e-13 !
			end
			
			% test:
			ok = 1;
			if length(find(C1 > 0.005*C1min)) > 0.01*numel(oxyl2oxyk)
				disp_res(test_name,'echec, OXYL->OXYK differ',verbose)
				ok = 0;
			end
			if length(find(C2 > 0.005*C2min)) > 0.01*numel(oxyk2oxyl)
				disp_res(test_name,'echec, OXYK->OXYL differ',verbose)
				ok = 0;
			end
			if ok == 1
				res = true;
				disp_res(test_name,'OK',verbose)
			end
		end
	end		
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% None of OXYK and OXYL exist, test OK
elseif ~isdata(T,'OXYL') & ~isdata(T,'OXYK')	
	disp_res(test_name,'No oxygen data in this transect',verbose)
	res = true;
end




msg(1).text_name = test_name;
msg(1).result    = '?';

if fixed, res=true;end
if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {msg};
	varargout(3) = {fixed};
	varargout(4) = {T};
end

end %function