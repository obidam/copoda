% mean H1LINE
%
% [] = mean()
% 
% HELPTEXT
%
% Created: 2009-11-18.
% http://copoda.googlecode.com
% Copyright 2010, COPODA

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


function varargout = mean(varargin)

D = varargin{1};
varn = varargin{2};

%%%%%%% This will be the common vertical axis we'll interpolate the datas:
dz = 10;
Z_i = get_common_Zaxis(D,dz);

%%%%%%% 
var_list = datanames(D,1);
[a iv] = intersect(var_list,varn);
if ~isempty(iv)
	for iT = 1 : length(D)
		C  = getfield(D.transect{iT}.data,var_list{iv},'cont');
		Cz = D.transect{iT}.geo.DEPH;
		Np = D.transect{iT}.cruise_info.N_STATION;
		if Np == 1
			C_i = interp1(Cz,C,Z_i);
		else
			Npm   = meshgrid(1:Np,max(Cz))';
			[Npm_i Zm_i] = meshgrid(1:Np,Z_i);Npm_i =Npm_i'; Zm_i=Zm_i';
			C_i = interp2(Npm',Cz',C',Npm_i,Zm_i);
		end
		CC_i(iT,:) = nanmean(C_i,1);
	end%for iT
	CC_i = nanmean(CC_i,1);
end

varargout(1) = {CC_i};
varargout(2) = {Z_i};

end %functionmean


function Z_i = get_common_Zaxis(D,dz);
	
	% First we look for extremums in the DEPH field:
	for iT = 1 : length(D)
		x(iT) = xtrm(D.transect{iT}.geo.DEPH);
	end%for iT
	Z_i = 0:dz:max(abs(x));
	Z_i = sort(-Z_i);
	
end

















