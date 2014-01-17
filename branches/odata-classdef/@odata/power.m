% power Power operator with ODdata object
%
% C = power(C1,n)
% 
% C is a OData object with content C1.cont .^ n
%
%
%
% Created: 2009-08-26.
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

function varargout = power(varargin)

% How to alert users ?
fct = 'warning';
%fct = 'error';

od1  = varargin{1};
n    = varargin{2};
od1.cont = (od1.cont).^n;

od1.name      = update(od1.name,n);
od1.long_name = update(od1.long_name,n);
od1.unit      = update(od1.unit,n);
od1.long_unit = update(od1.long_unit,n);
varargout(1) = {od1};

end %function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = update(t,n)
	if ~isempty(t)
		if contain_op(t)
			if fix(n)==n
				t = sprintf('(%s)^{%i}',t,n);
			else
				t = sprintf('(%s)^n',t);
			end
		else			
			if fix(n)==n
				t = sprintf('%s^{%i}',t,n);
			else
				t = sprintf('%s^n',t);
			end
		end
	else
		t = '';
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = contain_op(t)
	res = false;
	oplist = '+-*/^';
	done = 0; ii = 1;
	while done ~= 1
		for iop = 1 : length(oplist)
			if strfind(t,oplist(iop))
				res = true;
				done = 1;
			end
		end
		ii = ii + 1;
		if ii>length(t),done=1;end
	end
end







