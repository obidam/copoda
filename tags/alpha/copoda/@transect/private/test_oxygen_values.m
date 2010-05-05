% test_oxygen_values H1LINE
%
% [] = test_oxygen_values()
% 
% HELPTEXT
%
%
% Created: 2009-09-02.
% Rev. by Guillaume Maze on 2009-09-23: Do not fix valid values here but get them from par_code.m
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

function varargout = test_oxygen_values(varargin)

test_name = 'Oxygen content';
test_desc = {'Check if oxygen content is within valid values given by par_code routine.'};
res   = false;
fixed = false;
switch nargin
	case 0
		varargout(1) = {9}; % ID of the test
		varargout(2) = {test_desc};
		return
	otherwise
		T 		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end	


if ~isdata(T,'OXYL') & ~isdata(T,'OXYK') 
	disp_res(test_name,'Skip, no OXYL and OXYK',verbose);
	res = true;
else

	if isdata(T,'OXYK') 
		[T res1 fixed1] = valid_this('OXYK',T,fixe,verbose,test_name);
		if isdata(T,'OXYL') 
			[T res2 fixed2] = valid_this('OXYL',T,fixe,verbose,test_name);
			if res1   & res2, res = true; end
			if fixed1 & fixed2, fixed = true; end
		else
			res = res1;
			fixed = fixed1;
		end
	elseif isdata(T,'OXYL') 
		[T res1 fixed1] = valid_this('OXYL',T,fixe,verbose,test_name);
		if isdata(T,'OXYK') 
			[T res2 fixed2] = valid_this('OXYK',T,fixe,verbose,test_name);
			if res1   & res2, res = true; end
			if fixed1 & fixed2, fixed = true; end
		else
			res = res1;
			fixed = fixed1;
		end
	end
end


% Deprec:
msg(1).text_name = test_name;
msg(1).result    = '?';

if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {msg};
	varargout(3) = {fixed};
	varargout(4) = {T};
end

end %function



function [T res fixed] = valid_this(varn,T,fixe,verbose,test_name)
	V = getfield(T.data,varn);
	fixed = false;
	
	switch V.unit
		case 'ml/l',     %valid = [0 40];
		case 'mumol/kg', %valid = [0 1000];
		otherwise
			disp_res(test_name,sprintf('%s has not a standard unit !',varn),verbose);
			res   = false;
			fixed = false;
			return
	end
	
	par = par_code(varn);
	if ~iscell(par)
		disp_res(test_name,sprintf('Echec, Couldn''t determine valid values for field %s in par_code.m !',varn),verbose);
		res   = false;
		fixed = false;
		return
	else
		valid = [par{1}.valid_min par{1}.valid_max];
	end

	C = cont(V);
	if nanmean(C(:)) < valid(1) | nanmean(C(:)) > valid(2) % The mean is supposed to be meaningful of the order of the whole field (not always the case ?)		
% 		if fixe
% 			switch varn
% 				case 'OXYL', % Is it a factor of 10 of ml ?
% 				case 'OXYK', % Is it a factor of 10 of mumol ?
% 					done = 0; n = 0;
% 					while done ~= 1
% 						if nanmean(C(:)) < valid(1), % To small, multiply by a factor of 10 until mean > valid(1)
% 							n = n + 1; 
% 							c = C*10^n;
% 							if nanmean(c(:)) > valid(1), 
% 								done = 1;
% 								fixed = true;
% 							end
% 						end 
% 						if nanmean(C(:)) > valid(2), % To large, divide by a factor of 10 until mean < valid(2)
% 							n = n - 1; 
% 							c = C/10^n;
% 							if nanmean(c(:)) < valid(2), 
% 								done = 1;
% 								fixed = true;
% 							end
% 						end 
% 						if abs(n)>6
% 							done = 1;
% 							disp_res(test_name,sprintf('Can''t fix %s, realy weird field !',varn),verbose);										
% 							fixed = false;
% 						end
% 					end % while
% 					if fixed
% 						c(c<valid(1))=NaN;
% 						c(c>valid(2))=NaN;
% 						V.cont = c;
% 						T.data = setfield(T.data,varn,V);
% 						disp_res(test_name,sprintf('%s was multiplied by a factor of %i',varn,n),verbose);
% 						res   = true;
% 						fixed = true;
% 					end
% 			end % swtich

% 		else
% 			disp_res(test_name,sprintf('%s seems entirely compromised ! try FIX=1',varn),verbose);			
% 			res = false;
% 			fixed = false;
% 		end
		disp_res(test_name,sprintf('%s seems entirely compromised ! try FIX=1',varn),verbose);			
		res = false;
		fixed = false;
		
	elseif ~isempty(find(C<valid(1))) | ~isempty(find(C>valid(2)))	
		if fixe
			C(C<valid(1))=NaN;
			C(C>valid(2))=NaN;
			V.cont = C;
			T.data = setfield(T.data,varn,V);
			disp_res(test_name,sprintf('Found invalid %s values, set them to NaN',varn),verbose);	
			res = true;		
			fixed = true;
		else	
			disp_res(test_name,sprintf('Found invalid %s values, could set them to NaN if FIX=1',varn),verbose);
			res = false;		
			fixed = false;
		end
	else			
		disp_res(test_name,sprintf('OK for %s',varn),verbose);	
		res = true;	
		fixed = true;
	end
	
end%function

