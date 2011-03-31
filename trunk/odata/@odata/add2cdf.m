% add2cdf Add an Odata object to a netcdf class
%
% ncvar = add2cdf(odata)
% 
% Add an Odata object to a netcdf class
%
% Created: 2009-11-05.
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

function ncv = add2cdf(varargin)

oda      = varargin{1};
ncparent = varargin{2};

if ~isempty(oda.dims)
	
	% Get informations from the OData objects
	varname   = oda.name;
	dims_name = dimensions(oda);
	long_name = oda.long_name;
	siz       = size(oda);
	units     = oda.unit;

	% Fill in the netcdf object:
	for idim = 1 : length(dims_name)
		ncdim(dims_name{idim},siz(idim),ncparent);
	end	
	ncvar(varname,'float',dims_name,ncparent);
	ncatt('long_name','char',long_name,ncparent{varname});
	ncatt('units','char',units,ncparent{varname});
	ncatt('FillValue_','float',-9999.99,ncparent{varname});
	C = cont(oda);
	C(isnan(C)) = -9999.99;
	switch dim(oda)
		case 1
			ncparent{varname}(:) = C;
		case 2
			ncparent{varname}(:,:) = C;
		case 3
			ncparent{varname}(:,:,:) = C;
	end
	ncv = ncparent{varname};
	
else
	error('Cannot convert to ncvar object because axis are not defined')
end

end %functionadd2cdf
















