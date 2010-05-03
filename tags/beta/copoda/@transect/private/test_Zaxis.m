% test_Zaxis Check if vertical depth axis is decreasing and sorted
%
% [] = test_Zaxis()
% 
% HELPTEXT
%
%
% Created: 2009-07-31.
% Rev. by Guillaume Maze on 2009-09-22: Added possibility to fixe the axis by reordering of all fields
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

function varargout = test_Zaxis(varargin)

test_name = 'DEPTH axis';
test_desc = {'Check if vertical depth axis is negative, decreasing and sorted'};
res   = false;
fixed = false;
switch nargin
	case 0
		varargout(1) = {4};
		varargout(2) = {test_desc};
		return
	otherwise
		T 		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end



if ~isempty(find(T.geo.DEPH>0))
	if ~issorted(abs(T.geo.DEPH)','rows')
		msg(1).test_name   = test_name;
		msg(1).test_result = 'DEPH axis in geo property has positive values and is not sorted';
		if fixe, 
			disp_res(test_name,'echec, cannot be fixed',verbose);			
		else,
			disp_res(test_name,'echec',verbose);
		end
	else
		msg(1).test_name   = test_name;
		msg(1).test_result = 'DEPH axis in geo property has positive values';
		if fixe, 
			disp_res(test_name,'echec, cannot be fixed',verbose);
		else,
			disp_res(test_name,'echec',verbose);
		end
	end
else
	if ~issorted(abs(T.geo.DEPH)','rows') % We take abs(x) because here, we're sure to find only negative values
		msg(1).test_name   = test_name;
		msg(1).test_result = 'DEPH axis in geo property is not sorted';
		if fixe, 
%			disp_res(test_name,'echec, cannot be fixed',verbose); %% Old version, 

			% Try to fixe this:
			c = T.geo.DEPH;
			c(isnan(c)) = -Inf;
			[c is] = sort(c,2,'descend');
			
			% Reorder geo properties:
			T.geo.PRES = resort(T.geo.PRES,is);
			T.geo.DEPH = resort(T.geo.DEPH,is);

			% Reorder datas:
			fields = datanames(T);
			data   = T.data;
			for iv = 1 : length(fields)
				od = getfield(T.data,fields{iv});
				if isfield(od,'prec') 
					if size(od.prec) == size(od.cont)
						od.prec = resort(od.prec,is);
					end
				end 
				od.cont = resort(od.cont,is);
				data = setfield(data,fields{iv},od);
			end
			T.data = data;

			disp_res(test_name,'echec but fixed !',verbose);
			res = true;
			fixed = true;
		else,
			disp_res(test_name,'echec',verbose);
		end
	else
		disp_res(test_name,'OK',verbose);
		msg(1).test_name   = test_name;
		msg(1).test_result = 'OK';
		res = true;
	end
end


if fixed, res=true; end
if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {msg};
	varargout(3) = {fixed};
	varargout(4) = {T};
end



end %function



function C = resort(C,is);
	for istat = 1 : size(is,1)
		C(istat,:) = C(istat,is(istat,:));
	end
end%function


