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

function to = simplify_text(T1,T2,op)

%disp('--')
oplist = '-+';
t1 = sprintf('%s %s %s',deblank(T1),op,deblank(T2));

% Find elements:
t2 = t1;
for iop = 1 : length(oplist)
	t2 = strrep(t2,oplist(iop),'#');
end
[elements ii jj] = unique(deblank(strread(t2,'%s','delimiter','#')));
%elements = elements(jj(ii));

% Try to find preexisting factors:
R  = zeros(1,length(elements));
Rp = zeros(1,length(elements));
for iel = 1 : length(elements)
	[a b] = strread(elements{iel},'%s%s','delimiter','*');
	if ~strcmp(a,elements{iel})
		a = cell2mat(a);
		if ischar(a) & a=='n'
			Rp(iel) = 1;
		else
			R(iel) = str2num(a);
		end
		elements{iel} = b{:};
	else
		R(iel) = 0;
	end
end%for iel
%for iel = 1 : length(elements),disp(sprintf('%f + i%f : [%s]',real(R(iel)),imag(R(iel)),elements{iel}));end
[elements ii jj] = unique(elements);
R  = R(ii);
Rp = Rp(ii);

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
for iel = 1 : length(elements)
	if Rp(iel) == 1
		is = strfind(t2,sprintf('n*%s',ALPHABET(iel)));
		if ~isempty(is)
			op=t2(is-1);
			t2=strrep(t2,sprintf('%sn*%s',op,ALPHABET(iel)),'');
		end
	end
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
	R(iel) = R(iel) + s;
end%for ield
%for iel = 1 : length(elements),disp(sprintf('%i + i%i : [%s]',R(iel),Rp(iel),elements{iel}));end

% Build output string:
to = '';
for iel = 1 : length(elements)
	if R(iel) ~= 0
		if abs(R(iel)) == 1
			switch sign(R(iel))
				case -1, 
					if Rp(iel) == 1
						to = sprintf('%s - n*%s',to,elements{iel});
					else
						to = sprintf('%s - %s',to,elements{iel});
					end
				case  1, 					
					if Rp(iel) == 1
						to = sprintf('%s + n*%s',to,elements{iel});
					else
						to = sprintf('%s + %s',to,elements{iel});
					end
			end
		else
			switch sign(R(iel))
				case -1, 
					if Rp(iel) == 1
						to = sprintf('%s + n*%s',to,elements{iel});
					else
						to = sprintf('%s - %i*%s',to,abs(R(iel)),elements{iel});
					end
				case  1, 				
					if Rp(iel) == 1
						to = sprintf('%s + n*%s',to,elements{iel});
					else
						to = sprintf('%s + %i*%s',to,abs(R(iel)),elements{iel});
					end
			end
		end
	elseif R(iel) == 0 & Rp(iel) == 1
		to = sprintf('%s + n*%s',to,elements{iel});
	end
end %for iel
if length(to)>=1 
	to = dblk1(to);
	if to(1)=='+', to = to(2:end);end;
	if isspace(to(1)), to = to(2:end);end;
end


varargout(1) = {to};

%disp(t1);
%disp(sprintf('[%s]',to))

end %function


% Remove empty space at the beginning of the string:
function t = dblk1(t)
	done = 0;
	while done ~= 1
		if isspace(t(1))
			t = t(2:end);
		else
			done = 1;
		end
	end%while
	done = 0;
	while done ~= 1
		if isspace(t(end))
			t = t(1:end-1);
		else
			done = 1;
		end
	end%while
end


