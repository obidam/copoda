% ncv2odata Convert a ncvar object to an odata object
%
% OD = ncv2odata(NC,[NCVARNAME])
% 
% Convert the ncvar variable given by NCVARNAME from the netcdf
% object NC into an odata object.
%
% If NCVARNAME is not specify, convert all ncvar within nc.
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

function varargout = ncv2odata(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%
nc = varargin{1};
var_list_avail = ncvarname(nc);
if nargin == 2
	var_list_asked = varargin{2};
	ii = 0;
	for iv = 1 : length(var_list_asked)
		if ismember(var_list_asked{iv},var_list_avail) & ~isadim(nc,var_list_asked{iv})
			ii = ii + 1;
			var_list(ii) = var_list_asked(iv);
		else
			warning(sprintf('%s is not available in this netcdf object',var_list_asked{iv}));
		end%if
	end%for iv
	clear var_list_asked
else
	ii = 0;
	for iv = 1 : length(var_list_avail)
		if ~isadim(nc,var_list_avail{iv})
			ii = ii + 1;
			var_list(ii) = var_list_avail(iv);
		end	
	end%for iv
end
%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%% 1st, we need to create oaxis objects
dim_list = getdim_list(nc);
OAXIS = struct();
for iv = 1 : length(dim_list)
	varname = dim_list{iv};
	ncv = nc{varname}; % ncvar object
	
	%%% TRY TO SEE IF A NCVAR OBJECT CORRESPOND TO THE DIMENSION
	if ismember(varname,var_list_avail)
		disp(sprintf('DIMENSION %s IS A NCVAR',varname))
		% Create oaxis object:
		name = varname;
		cont = ncv(:);		
		cont = cont(:)'; % I prefer 1 x N
		try, unit      = ncv.units(:); catch, unit = '';end
		try, long_name = ncv.long_name(:);catch, long_name = '';end
		try, long_unit = ncv.long_unit(:);catch, long_unit = '';end
		try, axi       = ncv.axis(:);catch, axi = '';end, if isempty(axi),axi='';end
		thisoax = oaxis('name',name,'unit',unit,'cont',cont,'long_name',long_name,'long_unit',long_unit,'axis',axi);
		OAXIS = setfield(OAXIS,varname,thisoax);		
	else
		disp(sprintf('DIMENSION %s IS NOT A NCVAR',varname))
		% Create oaxis object:
		name      = varname;
		ncdimension = getncdim(nc,name);
		cont      = 1:length(ncdimension);
		try, unit      = ncv.units(:); catch, unit = '';end
		try, long_name = ncv.long_name(:);catch, long_name = '';end
		try, long_unit = ncv.long_unit(:);catch, long_unit = '';end
		try, axi       = ncv.axis(:);catch, axi = '';end, if isempty(axi),axi='';end
		thisoax = oaxis('name',name,'unit',unit,'cont',cont,'long_name',long_name,'long_unit',long_unit);
		OAXIS = setfield(OAXIS,varname,thisoax);
	end	
end%for iv
%%%%%%% SAVE OAXIS IN THE BASE WORKSPACE
r = input('Do you want to load OAxis in the base workspace (1) or in a struct (2) ? ','s');
switch r
	case '1'
		fi = fieldnames(OAXIS);
		for ia = 1 : length(fi)
			eval(sprintf('%s = OAXIS.%s;',fi{ia},fi{ia}));
			wssave({fi{ia}});
		end
	otherwise
		wssave({'OAXIS'});
end
%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%% 2nd, we can create odata objects
OAD = struct();
for iv = 1 : length(var_list)
	varname = var_list{iv};
	ncv = nc{varname}; % ncvar object

	switch datatype(ncv)
		case {'float','double','int','short'}
			dim_list = getdim_list(ncv);
			switch length(dim_list)
				case 1
				case 2
					disp(sprintf('CONVERT 2D: %s',varname));
					name  = varname;
					unit  = ncv.units(:);
					cont  = ncv(:,:);
					cont  = reshape(cont,size(ncv));
					long_name = ncv.long_name(:);
					long_unit = ncv.long_unit(:);
					dims      = dim_list;
					od = odata('name',name,'unit',unit,'cont',cont,'long_name',long_name,'long_unit',long_unit,'dims',dims);					
					OAD = setfield(OAD,varname,od);
				case 3
					disp(sprintf('CONVERT 3D: %s',varname));
					name  = varname;
					unit  = ncv.units(:);
					cont  = ncv(:,:,:);
					cont  = reshape(cont,size(ncv));
					long_name = ncv.long_name(:);
					long_unit = ncv.long_unit(:);
					dims      = dim_list;
					od = odata('name',name,'unit',unit,'cont',cont,'long_name',long_name,'long_unit',long_unit,'dims',dims);				
					OAD = setfield(OAD,varname,od);
				case 4
					disp(sprintf('CONVERT 4D: %s',varname));
					name  = varname;					
					unit  = ncv.units(:);
					cont  = ncv(:,:,:,:);
					cont  = reshape(cont,size(ncv));
					long_name = ncv.long_name(:);
					long_unit = ncv.long_unit(:);
					dims      = dim_list
					od = odata('name',name,'unit',unit,'cont',cont,'long_name',long_name,'long_unit',long_unit,'dims',dims);				
					OAD = setfield(OAD,varname,od);					
			end
		otherwise
			disp(sprintf('%s data type not supported',datatype(ncv)));
	end
	
	
end%for iv
%%%%%%% SAVE OAD IN THE BASE WORKSPACE 
wssave({'OAD'});
%%%%%%%




end %functionncv2odata


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ncdimension = getncdim(nc,dimname)
	dims = dim(nc);
	for id = 1 : length(dims)
		if strcmp(name(dims{id}),dimname)
			ncdimension = dims{id};
			return
		end
	end%for id
end%function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = getdim_list(nc)
	dims = dim(nc);
	for id = 1 : length(dims)
		result(id) = {name(dims{id})};
	end%for id
end%function


	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = isadim(nc,varn)
	dims = dim(nc);
	result = 0;
	for id = 1 : length(dims)
		if strcmp(name(dims{id}),varn)
			result = 1;
		end
	end
end%function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = clean_spc(s)
	for ii=1:10
		s = strrep(s,'  ',' ');
	end
end





