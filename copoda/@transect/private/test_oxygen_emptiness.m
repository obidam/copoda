% text_oxygen_emptyness H1LINE
%
% [] = text_oxygen_emptyness()
% 
% HELP TEXT
%
% Inputs:
%
% Outputs:
%
%
% Created: 2010-05-10.
% http://code.google.com/p/copoda
% Copyright (c)  2010, COPODA

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = text_oxygen_emptyness(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%% HEADER
res   = false;
fixed = false;
test_name = 'Remove empty profiles of oxygen';
test_desc = {'Check if we find empty oyxgen profiles and';'squeeze the transect to stations with oxygen if fixe = 1'};
switch nargin
	case 0 % INFORMATIONS RETURNS WHEN NO ARGUMENTS ARE PROVIDED
		varargout(1) = {13};         % THIS IS THE ID OF THE TEST !
		varargout(2) = {test_desc}; % THIS IS ITS DESCRIPTION
		return
	otherwise % Otherwise the 1st argument is the 
		T 		= varargin{1}; % Transect object to be tested
		verbose = varargin{2}; % Do we verbose informations on screen (0/1) ?
		fixe 	= varargin{3}; % Do we try to fix the Transect object (0/1) ?
end
msg(1).test_name   = test_name;
msg(1).test_result = '?';

%%%%%%%%%%%%%%%%%%%%%%%%% THE TEST HERE:

%%%%%%%%%%%%%%%%%%%%%%%%% Only Oxygen in mumol/kg
if isdata(T,'OXYK') && ~isdata(T,'OXYL')
	
	foundemptyP = false;
	for is = 1 : size(T,1)
		p = T.data.OXYK.cont(is,:);
		if prod(size(p)) == length(find(isnan(p)==1)) % Full of NaNs 
			foundemptyP = true;
			tokeep(is) = false;
		else
			tokeep(is) = true;
		end
	end
	if foundemptyP
		res =false;
		switch fixe
			case 0 % We dont fix
				disp_res('Result','Echec, found empty OXYK profile(s), try fixe = 1',verbose);
			case 1 % We try to fix
				try
					if ~isempty(find(tokeep==true))
						T = reorder(T,1,find(tokeep==true));
						disp_res('Result','OK (found empty OXYK stations and removed them)',verbose);
					else
						ps = T.data.PARAMETERS_STATUS; ips = 1 : length(ps);
						ps = ps(ips~=dstatus(T,'OXYK',1))
						d = T.data;
						d = rmfield(d,'OXYK');
						d.PARAMETERS_STATUS = ps;
						T.data = d;
						disp_res('Result','OK (found all stations OXYK to be empty and removed OXYK)',verbose);
					end
					res = true;
					fixed = true;
				catch
					fixed = false;
				end
		end%switch fixe
	else
		disp_res('Result','OK (no stations without OXYK datas)',verbose);
		res = true;
		fixed = true;
	end
	
%%%%%%%%%%%%%%%%%%%%%%%%% Only Oxygen in ml/l
elseif 	~isdata(T,'OXYK') && isdata(T,'OXYL')

	foundemptyP = false;
	for is = 1 : size(T,1)
		p = T.data.OXYL.cont(is,:);
		if prod(size(p)) == length(find(isnan(p)==1)) % Full of NaNs 
			foundemptyP = true;
			tokeep(is) = false;
		else
			tokeep(is) = true;
		end
	end
	if foundemptyP
		res =false;
		switch fixe
			case 0 % We dont fix
				disp_res('Result','Echec, found empty OXYL profile(s), try fixe = 1',verbose);
			case 1 % We try to fix
				try
					if ~isempty(find(tokeep==true))
						T = reorder(T,1,find(tokeep==true));
						disp_res('Result','OK (found empty OXYL stations and removed them)',verbose);
					else
						ps = T.data.PARAMETERS_STATUS; ips = 1 : length(ps);
						ps = ps(ips~=dstatus(T,'OXYL',1))
						d = T.data;
						d = rmfield(d,'OXYL');
						d.PARAMETERS_STATUS = ps;
						T.data = d;
						disp_res('Result','OK (found all stations OXYL to be empty and removed OXYL)',verbose);
					end
					res = true;
					fixed = true;
				catch
					fixed = false;
				end
		end%switch fixe
	else
		disp_res('Result','OK (no stations without OXYL datas)',verbose);	
		res = true;
		fixed = true;
	end

%%%%%%%%%%%%%%%%%%%%%%%%% Only Oxygen in ml/l and mumol/kg
elseif isdata(T,'OXYK') && isdata(T,'OXYL')


foundemptyP = false;
for is = 1 : size(T,1)
	p1 = T.data.OXYL.cont(is,:);
	p2 = T.data.OXYK.cont(is,:);
	if prod(size(p1)) == length(find(isnan(p1)==1)) && prod(size(p2)) == length(find(isnan(p2)==1)) % Full of NaNs 
		foundemptyP = true;
		tokeep(is) = false;
	else
		tokeep(is) = true;
	end
end
if foundemptyP
	res =false;
	switch fixe
		case 0 % We dont fix
			disp_res('Result','Echec, found empty OXYL/OXYK profile(s), try fixe = 1',verbose);
		case 1 % We try to fix
			try
				if ~isempty(find(tokeep==true))
					T = reorder(T,1,find(tokeep==true));
					disp_res('Result','OK (found empty OXYL/OXYK stations and removed them)',verbose);
				else
					ps = T.data.PARAMETERS_STATUS; ips = 1 : length(ps);
					ps = ps(ips~=dstatus(T,'OXYL',1));
					ps = ps(ips~=dstatus(T,'OXYK',1));
					d = T.data;
					d = rmfield(d,'OXYL');
					d = rmfield(d,'OXYK');
					d.PARAMETERS_STATUS = ps;
					T.data = d;
					disp_res('Result','OK (found all stations OXYL/OXYK to be empty and removed OXYL/OXYK)',verbose);
				end
				res = true;
				fixed = true;
			catch
				fixed = false;
			end
	end%switch fixe
else
	disp_res('Result','OK (no stations without OXYK/OXYL datas)',verbose);
	res = true;
	fixed = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%% No Oxygen
else
	disp_res('Result','OK (not oxygen datas)',verbose);
	res = true;
	fixed = true;

end


%%%%%%%%%%%%%%%%%%%%%%%%% FOOTER
if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {msg};
	varargout(3) = {fixed};
	varargout(4) = {T};
end


end %functiontext_oxygen_emptyness
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
