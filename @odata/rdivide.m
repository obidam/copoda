% rdivide Division operator with ODdata object
%
% C = rdivide(C1,C2)
% 
% If C1 or C2 is of OData class, C is a OData object
% with content C1.cont / C2 or C1 / C2.cont
%
% If C1 and C2 are OData objects, C is a OData object
% with content C1.cont ./ C2.cont, of precision the
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

function varargout = rdivide(varargin)

% How to alert users ?
fct = 'warning';
%fct = 'error';

% The operation depends on the class of each elements
switch class(varargin{1})
	case 'odata'
		switch class(varargin{2})
			case 'odata'			
				method = 1;
				switch method
					case 0 % Return numerical results
						% This need to be better, the result should still be an OData object
						R = getfield(varargin{1},'cont') ./ getfield(varargin{2},'cont');
						varargout(1) = {R};
						
					case 1 % Return new odata object with modified name and unit
						od1  = varargin{1};
						od2  = varargin{2};
						R = getfield(varargin{1},'cont') ./ getfield(varargin{2},'cont');
						% Create new odata object:							
						next = check_units(od1,od2);							
						if next % Same units:
							unit = '';
						else
							unit = sprintf('(%s / %s)',od1.unit,od2.unit);
						end
						OD = odata(...
							'name',sprintf('(%s / %s)',od1.name,od2.name),...
							'unit',unit,...
							'cont',R,...
							'prec',maxi(od1.prec,od2.prec),...
							'prec_conv',od1.prec_conv,...
							'long_name',sprintf('(%s / %s)',od1.long_name,od2.long_name),...
							'long_unit',od1.long_unit);
						varargout(1) = {OD};								

				end%switch method difference of 2 odata objects
			otherwise			
				OD  = varargin{1};	
				OD.cont = OD.cont ./ varargin{2};
				varargout(1) = {OD};
		end %switch
	otherwise		
		switch class(varargin{2})
			case 'odata'			
				OD  = varargin{2};	
				OD.cont = varargin{1} ./ OD.cont;
				OD.name = sprintf('%s/n',OD.name);
				OD.long_name = sprintf('%s/n',OD.long_name);
				varargout(1) = {OD};
			otherwise
				error('Calling odata method without odata object ! This should not happen!');
		end%switch
end%switch

end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function M = maxi(C1,C2)
	ns1 = size(C1);
	nd1 = ndims(C1);
	ns2 = size(C2);
	nd2 = ndims(C2);
	if nd1 == nd2
		if ns1 == ns2
			C1 = reshape(C1,[1 prod(ns1)]);
			C2 = reshape(C2,[1 prod(ns2)]);
			M = nanmax([C1;C2]);
			M = reshape(M,ns1);
		else	
			error('Arguments of similar dimensions but different size !');
		end
	else
		if isnan(C1)
			M = C2;
		elseif isnan(C2)
			M = C1;
		else
			error('Two arguments must be of similar dimensions');
		end
	end
end



