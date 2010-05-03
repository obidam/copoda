% shorten_unit Find abbreviation of a long unit string
%
% [short_string] = shorten_unit(string)
% 
% Find abbreviation of a long unit string
%
%
% Created: 2009-07-27.
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

function varargout = shorten_unit(varargin)

long_unit = varargin{1};
% Clean the input string:
long_unit = lower(long_unit);
long_unit = deblank(long_unit);
long_unit = strtrim(long_unit);
%long_unit = strrep(long_unit,' ','');
%disp(['|' long_unit '|'])

% Try to make it shorter:
if ~isempty(strmatch(long_unit,strvcat(...
		'micromole/kg','micromol/kg','micro mole/kg','micro mol/kg',...
		'micromole/ kg','micromol/ kg','micro mole/ kg','micro mol/ kg',...
		'micromoles/kg','micromols/kg','micro moles/kg','micro mols/kg',...
		'micromoles/ kg','micromols/ kg','micro moles/ kg','micro mols/ kg')))
			unit = 'mumol/kg';
			unit_latex = '\mum/kg';
elseif ~isempty(strmatch(long_unit,strvcat(...
		'celsius degrees','degrees celsius',...
		'degree celsius','celsius degree',...
		'celsius deg','deg celsius','degree_Celsius')))
			unit = 'degC';
			unit_latex = '^oC';
elseif ~isempty(strmatch(long_unit,strvcat(...			
		'p.s.u','.p.s.u.','psu')));
			unit = 'PSU';
			unit_latex = 'PSU';
			
elseif ~isempty(strmatch(long_unit,strvcat(...
		'millitre/litre','millitre /litre','millitre/ litre','millitre / litre',...
		'ml/litre','ml /litre','ml/ litre','ml / litre',...
		'millitre/l','millitre /l','millitre/ l','millitre / l',...
		'millitres/litre','millitres /litre','millitres/ litre','millitres / litre')))			
			unit = 'ml/l';
			unit_latex = 'ml.l^{1}';
			
elseif ~isempty(strmatch(long_unit,strvcat(...
		'cubic meter per second')))
			unit = 'm^3/s';
			unit_latex = 'm^3/s';

elseif ~isempty(strmatch(long_unit,strvcat(...
		'square meter')))
			unit = 'm^2';
			unit_latex = 'm^2';

elseif ~isempty(strmatch(long_unit,strvcat(...
		'micromole/m3','micromol/m3','micro mole/m3','micro mol/m3',...
		'micromole/ m3','micromol/ m3','micro mole/ m3','micro mol/ m3',...
		'micromoles/m3','micromols/m3','micro moles/m3','micro mols/m3',...
		'micromoles/ m3','micromols/ m3','micro moles/ m3','micro mols/ m3')))
			unit = 'mumol/m3';
			unit_latex = '\mum/m3';

% Otherwise return long_unit unchanged:		
else
	unit = varargin{1};
end		


switch nargout
	case {0,1}
		varargout(1) = {unit};
	case 2
		varargout(1) = {unit};
		varargout(2) = {unit_latex};
end

end %function