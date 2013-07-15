% bfrq Compute the Brunt-Vaisala frequency squared (N^2)
%
% T = bfrq(T)
% 
% Compute the Brunt-Vaisala frequency squared (N^2)
% from the equation:
%
%           g     d(ST)
%   N2 = - --- x -------
%           ST    d(z)
%
% Rq:
% 	At this point, this function simply calls the Sea Water package
%	routine sw_bfrq.m
% 	[bfrq,vort,p_ave] = sw_bfrq(S,T,P,{LAT})
%
%
% Created: 2011-05-23.
% http://code.google.com/p/copoda
% Copyright 2011, COPODA

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

% Category for documentation:
%CAT 
% Method's type for documentation:
%TYP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T = bfrq(T,varargin)

%- Default options:
grd = 'z'; % Give back the result on the p/z grid
%grd = 'w'; % Give back the result on the w grid (mid press/depth)

%- Compute N2:
t  = T.data.TEMP.cont;
s  = T.data.PSAL.cont;
p  = T.geo.PRES;
if size(p,1) == 1
	% we have a similar pressure axis for all profiles:
	p = meshgrid(p,1:size(t,1));
end% if 
la = meshgrid(T.geo.LATITUDE,1:size(T,2))';

[b,v,pa] = sw_bfrq(s',t',p',la');
b  = b';
v  = v';
pa = pa';

%- Update the transect object:
Vlist = data_list; od = Vlist.BRV2; clear Vlist
od.long_name = sprintf('%s, added by %s',od.long_name,getenv('USER'));

switch grd
	case 'z'
		cont = zeros(size(T))*NaN;
		for ip = 1 : size(T,1)
			c = interp1(pa(ip,~isnan(b(ip,:))),b(ip,~isnan(b(ip,:))),p(ip,:));			
			cont(ip,:) = c;
		end% for ip
		od.cont = cont;
		T = addodata(T,'BRV2',od);
	case 'w'
		% TODO: I don't knwo what to do here, if we introduce a new vertical grid, what should be the default BRV2 odata axis ?
end% switch 


end %functionbfrq
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%











