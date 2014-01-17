% plus Difference operator with ODdata object
%
% C = plus(C1,C2)
% 
% If C1 or C2 is of OData class, C is a OData object
% with content C1.cont + C2 or C1 + C2.cont
%
% If C1 and C2 are OData objects, C is a OData object
% with content C1.cont + C2.cont, of precision the
% maximum of C1.prec and C2.prec and other properties
% updated.
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

function varargout = plus(varargin)

% How to alert users ?
%fct = 'warning';
fct = 'error';

% The operation depends on the class of each elements
switch class(varargin{1})
	case 'odata'
		switch class(varargin{2})
			case 'odata'			
				od1  = varargin{1};
				od2  = varargin{2};
				if check_units(od1,od2) % They have the same unit:
					% Create new odata object:
					OD = odata(...
						'name',sprintf('(%s + %s)',od1.name,od2.name),...
						'long_name',sprintf('(%s + %s)',od1.long_name,od2.long_name),...
						'unit',od1.unit,...
						'long_unit',od1.long_unit,...
						'cont',od1.cont + od2.cont);
					varargout(1) = {OD};
				else
					feval(fct,sprintf('Cannot compute sum of 2 odata objects with different units !\n[%s] versus [%s]',od1.unit,od2.unit));
				end
			otherwise
				od  = varargin{1};	
				od.cont = od.cont + varargin{2};
				varargout(1) = {od};
		end %switch
	otherwise		
		switch class(varargin{2})
			case 'odata'			
				od  = varargin{2};	
				od.cont = varargin{1} + od.cont;
				varargout(1) = {od};
			otherwise
				error('Calling odata method without odata object ! This should not have happen!');
		end%switch
end%switch

end %function