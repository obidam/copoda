% box_transport Compute tracer transport
%
% [Tr Er Mr] = box_transport(T,MASKS,VNAME)
% 
% From the transect object T, look for the data field TIPE (in m3/s), ie the 
% Geostrophic transport positive North-Eastward (TRSP_INV_PLUS_EK), and using 
% the T.geo.AREA field (cell surfaces in m2) and the mask MASKS, compute the
% tracer transport with name VNAME.
%
% Inputs:
% (with Ns the number of stations and Nz the number of samples on the vertical)
%	T: transect object. It must have:
%		- T.geo.AREA: (Ns,Nz) cell surfaces in m^2
%		- T.geo.MCOV: (Ns,Ns) stations covariance matrix in m^2
%		- T.data.TIPE: (Ns,Nz) cell transport in m^3/s
%		- Fields from T.data to compute the density
%	MASKS: is the mask(s) defining where to compute the transport. It can be of the form:
%		- MASKS(n,Ns,Nz): n masks with 1/0 values
%		- MASKS(Ns,Nz): 1 mask with 1/0 values
%		- MASKS(Ns,Nz): 1 mask with 1:n integer values
%	VNAME: a cell list of:
%		- any tracer field given by datanames(T)
%		- 'MASS' for the mass transport (kg/s)
%		- 'VOLU' for the volume flux (m3/s)
%		- 'HEAT' for the heat transport (W)
%	VNAME can also be directly a (Nz,Nz) tracer matrix
%		
% Outputs:
%	Tr(n,length(VNAME)): is the list of transports
%	Er(n,length(VNAE)): is the list of error bars
%	Mr(n,length(VNAE)): is the mean tracer value
%
% Rq:
% The transport is computed as follow:
%	     //
%	Tr = || 		RHO * TRACER * U dS
%	     // MASKS==1
%	Note that U dS is given by T.data.TIPE
%
% and the error bar as:
%	Er = ( [RHO * TRACER * AREA]' x MCOV x [RHO * TRACER * AREA]  )^1/2
%	only for MASK==1
%
% Created: 2010-04-02.
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


function [Tr Er Mr] = box_transport(T,MASKS,VNAME)

MASKS = clean_mask(MASKS);
RHO   = get_rho(T);
US    = T.data.TIPE.cont;
S     = T.geo.AREA;
MCOV  = T.geo.MCOV;

if ischar(VNAME)
	VNAME = {VNAME};
elseif isnumeric(VNAME)	
	tracer = VNAME;
	VNAME  = {'toto'};
end

if ~isempty(intersect(lower(VNAME),'heat'))
	CP    = sw_cp(T.data.PSAL.cont,T.data.TEMP.cont,T.geo.PRES); % J/K/kg
end

%whos MASKS
%figure;pcolor(squeeze(nansum(MASKS,1))');shading flat

for imask = 1 : size(MASKS,1)
	mask = squeeze(MASKS(imask,:,:));
	
	for iv = 1 : length(VNAME)
		if strcmp(lower(VNAME{iv}),'mass')
			tracer = ones(size(MASKS,2),size(MASKS,3));
		elseif strcmp(lower(VNAME{iv}),'volu')
			tracer = 1./RHO;
		elseif strcmp(lower(VNAME{iv}),'heat')
			tracer = CP.*T.data.TEMP.cont;
		elseif strcmp(lower(VNAME{iv}),'toto')
			% tracer was given in input
		else
			tracer = getfield(T.data,VNAME{iv},'cont');
		end
	
		% Compute transport:
		Tr(imask,iv) = nansum(nansum(RHO(mask==1).*tracer(mask==1).*US(mask==1)));

		% Compute error:
		c = tracer.*RHO.*S; 
		c(mask==0)=NaN; c = nansum(c')'; 
		c = c'*MCOV*c;
		Er(imask,iv) = sqrt(nansum(nansum(c)));

		% Compute tracer value:
		Mr(imask,iv) = nansum(nansum(tracer(mask==1).*S(mask==1)))./nansum(nansum(S(mask==1)));
	
	end%for iv
		
end%for imask


end %functionbox_transport

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RHO = get_rho(T);
% Try to compute the density

if isdata(T,'RHO')
	RHO = T.data.RHO.cont;
	return
end

if isdata(T,'SIGI')
	RHO = T.data.SIGI.cont + 1000;
	return
end
	
if isdata(T,'TEMP') & isdata(T,'PSAL')
	p = T.geo.PRES;
	if size(p,1) == size(T.data.TEMP.cont,1) & size(p,2) == size(T.data.TEMP.cont,2)
		% ok
	elseif size(p,1) == size(T.data.TEMP.cont,1) & size(p,2) == 1 % (Ns,1)
		error('');
	elseif size(p,1) == size(T.data.TEMP.cont,2) & size(p,2) == 1 % (Nz,1)
		p = p'; % (1,Nz)
		[a p] = meshgrid(1:size(T.data.TEMP.cont,1),p);
	elseif size(p,1) == size(T.data.TEMP.cont,2) & size(p,2) == 1 % (1,Nz)
		[a p] = meshgrid(1:size(T.data.TEMP.cont,1),p);		
	end
	RHO = densjmd95(T.data.PSAL.cont,T.data.TEMP.cont,p);	
	return
end	
	
	error('I can''t compute density !')
	
end%function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function masks = clean_mask(MASKS);
% Change any type of MASKS to a (n,Ns,Nz) 1/0 matrix

% Dimensions:
[n1 n2 n3] = size(MASKS);
if n3 == 1
	MASKS = reshape(MASKS,1,n1,n2);
end
[n1 n2 n3] = size(MASKS);

% Values:
iMASK = 0;
masks = zeros(1,n2,n3);
for imask = 1 : n1
	c = squeeze(MASKS(imask,:)); c = c(~isnan(c)); 
	vlist = unique(c); vlist = vlist(vlist~=0);
	a = squeeze(MASKS(imask,:,:));
	for iv = 1 : length(vlist)
		iMASK = iMASK + 1;
		b = zeros(n2,n3);
		b(a==vlist(iv)) = 1;
		b(isnan(a)) = NaN;
		masks(iMASK,:,:) = b; 
	end
end%for in


end%function


















