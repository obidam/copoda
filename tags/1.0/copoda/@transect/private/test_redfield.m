% test_redfield H1LINE
%
% [] = test_redfield()
% 
% HELPTEXT
%
%
% Created: 2009-09-22.
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

function varargout = test_redfield(varargin)

test = 'red < 0 | red > 50'; % This is the test performed, ok is false
test_name = 'Redfield ratios';
test_desc = {'Check if nitrate and phosphate are consistent with a constant redfield ratio.';...
			'The following test must be an echec for a point to be retained:';...
			test};
res   = false;
fixed = false;
switch nargin
	case 0
		varargout(1) = {10}; % ID of the test
		varargout(2) = {test_desc};
		return
	otherwise
		T 		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end	

if isdata(T,'PHOS') & isdata(T,'NITR') 
	
	c1 = T.data.NITR.cont;
	c2 = T.data.PHOS.cont;
	c1(c2==0 | c1==0) = NaN;
	c2(c2==0 | c1==0) = NaN;
	c1(c2<0 | c1<0) = NaN;
	c2(c2<0 | c1<0) = NaN;
	c1(isnan(c2) | isnan(c1)) = NaN;
	c2(isnan(c2) | isnan(c1)) = NaN;
	red = c1./c2; % It should be around 16:1 !
	ii = eval(test);
	if ~isempty(find(ii==1))
		res = false;
		if fixe
			
			c1(find(ii==1)) = NaN;
			od = T.data.NITR;
			od.cont = c1;
			T.data = setfield(T.data,'NITR',od);
			
			c2(find(ii==1)) = NaN;
			od = T.data.PHOS;
			od.cont = c2;
			T.data = setfield(T.data,'PHOS',od);
			
			disp_res(test_name,'echec but fixed',verbose);			
			res   = true;
			fixed = true;
		else	
			disp_res(test_name,'echec, try FIX=1',verbose);
		end
	else	
		disp_res(test_name,'OK',verbose);
		res = true;
	end
	
	
else
	disp_res(test_name,'Skip, no PHOS and NITR',verbose);
	fixed = true;
	res = true;
end%if


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