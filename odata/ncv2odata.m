% ncv2odata Convert a netcdf variable to an odata object
%
% OD = ncv2odata(NC,[VARNAME])
% 
% Convert the netcdf variable given by VARNAME from the netcdf
% object NC into an odata object.
%
% NC can be an ID from netcdf.open or a file (local or remote)
%
% If VARNAME is not specify, convert all variables within nc.
%
% Eg:
%	ncid = netcdf.open('~/data/ARGO/wmo/6901024/6901024_prof.nc');
%	t = ncv2odata(ncid,'TEMP')
%	s = ncv2odata(ncid,'PSAL')
%
% Created: 2009-11-05.
% Rev. by Guillaume Maze on 2013-12-05: Updated to use Matlab builtin netcdf package
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

%- Guess the data source:
if isa(varargin{1},'char')
	nc_file = varargin{1};
	% Remote file
	if ~isempty(strfind(nc_file,'ftp://')) | ~isempty(strfind(nc_file,'http://'))
		try
			[PATHSTR,NAME,EXT] = fileparts(nc_file);
			local_ncfile = fullfile('.',sprintf('tmp_%s%s',NAME,EXT));
			system(sprintf('wget -O %s ''%s''',local_ncfile,nc_file));
			% If we made it through here, we can change the nc_file value:
			nc_file = local_ncfile;
		catch
			error('You asked for an online netcdf file I couldn''t download !');
		end
		clear userdata_folder PATHSTR NAME EXT
	else
		nc_file = varargin{1};		
	end
	ncid = netcdf.open(nc_file);
else
	% Already open file:
	ncid = varargin{1};	
end% if

%- Determine the list of variables to load:

var_list_avail = ncvarname(ncid);
if nargin == 2
	var_list_asked = varargin{2};
	if ~isa(var_list_asked,'cell'),var_list_asked={var_list_asked};end% if 
	ii = 0;
	for iv = 1 : length(var_list_asked)
		if ~isempty(intersect(var_list_avail,var_list_asked{iv})) & ~isadim(ncid,var_list_asked{iv}) 
			if ~isachar(ncid,var_list_asked{iv})
				ii = ii + 1;
				var_list(ii) = var_list_asked(iv);
			else
				error('I can only load numeric variables (float and double)');				
			end% if 
		else
			warning(sprintf('%s is not available in this netcdf object',var_list_asked{iv}));
		end%if
	end%for iv
	clear var_list_asked ii iv
	if length(var_list) > 1 & nargout ~= length(var_list)
		error('The number of output should match the number of requested variables !');
	end% if
else
	ii = 0;
	for iv = 1 : length(var_list_avail)
		if ~isadim(ncid,var_list_avail{iv}) & ~isachar(ncid,var_list_avail{iv})
			ii = ii + 1;
			var_list(ii) = var_list_avail(iv);
		end	
	end%for iv
	clear ii iv
end% if 

%- Create odata objects
OAD = struct();
for iv = 1 : length(var_list)
	varid   = netcdf.inqVarID(ncid,var_list{iv});
    [varname,xtype,dimids,natts]   = netcdf.inqVar(ncid,varid);
	[Dim_ids Dim_names Dim_length] = netcdf.DimVar(ncid,varid);

	if ~strcmp(varname,var_list{iv})
		error('Internal error !')
	end% if 
	
	if xtype == 2
		varname,xtype
		error('I can only load numeric variables (float and double)');		
	end% if 
	
	% Try to load meta data:
	name  = varname;
	try, unit  = netcdf.getAtt(ncid,varid,'units'); catch, unit = ''; end
	try, long_name = netcdf.getAtt(ncid,varid,'long_name');catch, long_name = ''; end
	try, long_unit = netcdf.getAtt(ncid,varid,'long_units');	catch, long_unit = ''; end
	try, fval = netcdf.getAtt(ncid,varid,'_FillValue');catch, fval = NaN; end	
	
	% Load content:
	try
		cont = double(netcdf.getVar(ncid,varid));
		try
			if prod(Dim_length) ~= 1
%				cont = reshape(cont,Dim_length);
			end% if 
		catch
			warning(sprintf('I couldn''t manage to reshape %s properly',varname))
		end
		cont(cont==fval) = NaN;
	catch
		stophere
		error(sprintf('Cannot load %s from this file',varname));
	end
	od = odata('name',name,'unit',unit,'cont',cont,'long_name',long_name,'long_unit',long_unit);										
	OAD = setfield(OAD,varname,od);
		
end%for iv


%- Clean up
if exist('local_ncfile','var') & exist(local_ncfile,'file')
	delete(local_ncfile);
end% if 

%- Output
if nargin == 2
	for iv = 1 : length(var_list)
		varargout(iv) = {getfield(OAD,var_list{iv})};
	end% for iv
else
	varargout(1) = {OAD};
end% if 
	


end %functionncv2odata

% Return true if VARN is of CHAR netcdf data type
function result = isachar(ncid,varn)
	[varname,xtype,dimids,natts]   = netcdf.inqVar(ncid,netcdf.inqVarID(ncid,varn));
    if xtype == 2
		result = true;
	else
		result = false;
	end% if 
end

% List netcdf dimensions (limited AND unlimited)
function varargout = ncdimname(ncid)
	[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);

	for id = 1 : ndims
		dimid = id-1;
		[dimname,dimlen] = netcdf.inqDim(ncid,dimid);
		Dnames(id) = {dimname};
	end% for id
	[Dnames is] = sort(Dnames);
	varargout(1) = {Dnames};

end% function

% Return true if VARN is a netcdf dimension
function result = isadim(nc,varn)
	a = intersect(ncdimname(nc),varn);
	result = ~isempty(a);
end%function

% List netcdf variables
function varargout = ncvarname(ncid)

	[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);

	for iv = 1 : nvars
		varid = iv-1;
		[varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid);
		%disp(sprintf('%s: %i',varname,xtype));
		[Dim_ids Dim_names Dim_length] = netcdf.DimVar(ncid,varid);	
		dim_str = '';
		for id = 1 : length(Dim_ids)
			str = sprintf('(%s=%i)',Dim_names{id},Dim_length(id));
			if length(Dim_ids) == 1
				dim_str = sprintf('%s',str);
			elseif id == length(Dim_ids)
				dim_str = sprintf('%s %s',dim_str,str);
			else
				dim_str = sprintf('%s %s x',dim_str,str);
			end% if 
		end% for 
		dstr = sprintf('\t#%3.1d: %20s [%s]',varid,varname,dim_str);
		RESdisp(iv) = {dstr};
		Vnames(iv) = {varname};
		Vids(iv)   = varid;
	end% for iv
	[Vnames is] = sort(Vnames);
	RESdisp = RESdisp(is);
	Vids    = Vids(is);

	switch nargout
		case 1
			varargout(1) = {Vnames};
		case 2
			varargout(1) = {Vnames};
			varargout(2) = {Vids};
		otherwise
			s = sep;
			disp(sep('-',' LIST OF VARIABLE(S) '))	
			disp(sprintf('\t#IDS: %20s [%s]','VARIABLE NAME','(DIMENSION NAME = LENGTH)'))			
			disp(s(1:fix(length(s)/2)));
			for iv = 1 : nvars
				disp(RESdisp{iv});
			end% for iv
			disp(s);
	end% switch 

end %functionlistVar

%
function s = clean_spc(s)
	for ii=1:10
		s = strrep(s,'  ',' ');
	end
end