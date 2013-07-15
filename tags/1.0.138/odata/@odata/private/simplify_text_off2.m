% simplify_text H1LINE
%
% [] = simplify_text()
% 
% HELPTEXT
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

function varargout = simplify_text(T1,T2,op)

%%%%%%%%%%%%%%%%%% This version can't manage factors

oplist = '-+';
t1 = sprintf('%s %s %s',deblank(T1),op,deblank(T2));

% Find elements:
t2 = t1;
for iop = 1 : length(oplist)
	t2 = strrep(t2,oplist(iop),'#');
end
[elements ii jj] = unique(deblank(strread(t2,'%s','delimiter','#')));
elements = elements(jj);

% Create symbolic expression to be simplified:
ALPHABET = 'abcdefghijklmnopqrstuvwxyz';
t2 = t1;
for iel = 1 : length(elements)
	t2 = strrep(t2,elements{iel},ALPHABET(iel));
end
t2 = strrep(t2,' ','');
if isempty(strfind(oplist,t2(1)))
	t2 = ['+' t2];
end

% Simplify:
for iel = 1 : length(elements)
	% Find corresponding operators and compute results:
	ops = t2(strfind(t2,ALPHABET(iel))-1);
	s = 0;
	for iop = 1 : length(ops)
		switch ops(iop)
			case '+',s = s + 1;
			case '-',s = s - 1;
		end
	end
	R(iel) = s;
end%for ield

% Build output string:
to = '';
for iel = 1 : length(elements)
	if R(iel) ~= 0
		if abs(R(iel)) == 1
			switch sign(R(iel))
				case -1, to = sprintf('%s - %s',to,elements{iel});
				case  1, to = sprintf('%s %s',to,elements{iel});
			end
		else
			switch sign(R(iel))
				case -1, to = sprintf('%s - %i*%s',to,abs(R(iel)),elements{iel});
				case  1, to = sprintf('%s + %i*%s',to,abs(R(iel)),elements{iel});
			end
		end
	end
end %for iel
to = deblank(to);
if length(to)>=1 if to(1) == '+', to = to(2:end);end; end


varargout(1) = {to};

%disp(t1);
disp(to)

end %function


















