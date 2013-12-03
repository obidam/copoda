% test_dimensions H1LINE
%
% [] = test_dimensions()
% 
% HELPTEXT
%
% Rev. by Guillaume Maze on 2013-11-28: Only test the first dimension
% Rev. by Guillaume Maze on 2010-03-05: Only test real variables ! (exclude virtual)
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

function varargout = test_dimensions(varargin)
	
test_name = 'OData dimensions';
test_desc = {'Check if all datas are of the same size along the first dimension (could be otherwise';...
				'but it is assumed to be the case as of Jul.31/2009)'};
res   = false;
fixed = false;
switch nargin
	case 0
		varargout(1) = {1};
		varargout(2) = {test_desc};
		return
	otherwise
		T 		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end

fields = datanames(T);
ij = 0;
for ii = 1 : length(fields);
	if T.data.PARAMETERS_STATUS(ii) == 'R'
		od = getfield(T.data,fields{ii});
		ij = ij + 1;
		dims(ij,:) = size(od.cont);
	end
end

if find(diff(dims(:,1),1)~=0)	
	if fixe, 
		disp_res(test_name,'echec, cannot be fixed',verbose);
	else
		disp_res(test_name,'echec',verbose);
	end
	msg(1).test_name   = test_name;
	msg(1).test_result = 'One of the OData object within this transect data property is not consistent with the others';
else
	disp_res(test_name,'OK',verbose);
	msg(1).test_name   = test_name;
	msg(1).test_result = 'OK';
	res = true;
end


if fixed, res=true; end
if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {msg};
	varargout(3) = {fixed};
	varargout(4) = {T};
end


end %function