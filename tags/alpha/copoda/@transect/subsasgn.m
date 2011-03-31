% subsasgn Subscripted assignment of transect object field
%
% T = subsasgn(T,index,val)
% 
% Subscripted assignment of transect object field:
% Define how to assign value to transect.
%
%
% Created: 2009-07-22.
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


function a = subsasgn(a,index,val)

switch index(1).type
	case '.'
		switch index(1).subs 
		%- Basic properties:
			case 'source',    a.source = val;	
			case 'creator',   a.creator = val;		
			case 'created',   a.created = val;
			case 'modified',  a.modified = val;
			case 'file',      a.file = val;
			case 'file_date', a.file_date = val;
			
		%- Advanced properties:
			
			%-- cruise_info
			case 'cruise_info', 
				switch size(index,2)
					case 1
						if ~isa(val,'cruise_info')
							error('the transect property cruise_info must be a cruise_info object');
						end
						a.cruise_info = val;	
					case 2
						b = a.cruise_info;
						eval(sprintf('b.%s=val;',index(2).subs))
						a.cruise_info = b;
					case 3
						b = a.cruise_info;
						eval(sprintf('c=b.%s',index(2).subs));
						c(index(3).subs{:}) = val;
						eval(sprintf('b.%s = c;',index(2).subs));
						a.cruise_info = b;						
				end
				
			%-- geo
			case 'geo',
				switch size(index,2)
					case 1
						a.geo = val;	
					case 2
						b = a.geo;
						b = setfield(b,index(2).subs,val);
						a.geo = b;
				end
			
			%-- data 
			case 'data', 				
					switch size(index,2)
						case 1 %-- define T.data = val
							% val is a structure with OData fields and eventualy PARAMETERS_STATUS
							% We need to be sure OData fields are sorted.
							if isfield(val,'STATION_PARAMETERS')
								val = rmfield(val,'STATION_PARAMETERS');
							end
							
							if isfield(val,'PARAMETERS_STATUS')
								PARAMETERS_STATUS = val.PARAMETERS_STATUS; n1 = length(PARAMETERS_STATUS);
								val = rmfield(val,'PARAMETERS_STATUS'); n2 = length(fieldnames(val));
								if n1 ~= n2
									error(sprintf('The length of PARAMETERS_STATUS (%i) must match the number of fields (%i)',n1,n2));
								else
									n = n1;
								end
							else
								n = length(fieldnames(val));
							end
							
							% Reorder fields:
							[val is] = orderfields(val);
							if exist('PARAMETERS_STATUS','var')
								PARAMETERS_STATUS = PARAMETERS_STATUS(is);
							else
								PARAMETERS_STATUS = 'R';
								for ii = 1 : n
									PARAMETERS_STATUS = sprintf('%sR',PARAMETERS_STATUS);
								end
							end
							val.PARAMETERS_STATUS = PARAMETERS_STATUS(is);
							a.data = val;	
							
						case 2 %-- define T.data.<something> = val
							switch index(2).subs
								case 'STATION_PARAMETERS' %--- define T.data.STATION_PARAMETERS = val
									error('Read only property')
									
								case 'PARAMETERS_STATUS'  %--- define T.data.PARAMETERS_STATUS = val
									if length(datanames(a)) ~= length(val)
										error('PARAMETERS_STATUS must be of the same size of the list of datas')
									else
										a.data.PARAMETERS_STATUS = val;
										% When we set the status to virtual, we clear the odata object content and set it to NaN.
										% (This is the goal of implementing virtual var: empty disk space)
										if strfind(val,'V')
											for iv = 1 : length(datanames(a))
												if a.data.PARAMETERS_STATUS(iv) == 'V'
													
												end
											end
										end
									end
									
								otherwise  %--- define T.data.ODATA = val
									l = data_list;
									if ~isfield(l,index(2).subs)
										error('Invalid field name from transect.data property (see list of available variables in the doc)')
									else
										b = a.data;
										if isfield(b,'STATION_PARAMETERS')
											b = rmfield(b,'STATION_PARAMETERS');
										end
										if isfield(b,'PARAMETERS_STATUS')
											PARAMETERS_STATUS = b.PARAMETERS_STATUS; n = length(PARAMETERS_STATUS);
											b = rmfield(b,'PARAMETERS_STATUS');
										end
										
										
										if ~isa(val,'odata')
											error(sprintf('%s must be an OData object',index(2).subs));
										else
											% Add the field at the end:
											b = setfield(b,index(2).subs,val);
											PARAMETERS_STATUS = [PARAMETERS_STATUS(1:n) 'R'];
											
											% Reorder fields by alphabetical order:
											[b is] = orderfields(b);
											PARAMETERS_STATUS = PARAMETERS_STATUS(is);
											
											b.PARAMETERS_STATUS = PARAMETERS_STATUS;
											a.data = b;

										end
									end
							end
							
						case 3 %-- define T.data.<something>(<something>) = val
							switch index(2).subs
								case 'STATION_PARAMETERS' %--- define T.data.STATION_PARAMETERS(<something>) = val ! NOT ALLOWED
									error('STATION_PARAMETERS is a read only property')	
																	
								case 'PARAMETERS_STATUS' %--- define T.data.PARAMETERS_STATUS(<something>) = val
									if length(index(3).subs{1}) ~= length(val)
										error('Wrong size for parameter status');
									end
									if length(strfind(val,'R')) + length(strfind(val,'V')) ~= length(index(3).subs{1})
										error('PARAMETERS_STATUS could only be set to: R (real) or V (virtual)')											
									end
								
									if max(index(3).subs{1}) > length(datanames(a))
										error('You''re trying to set a status for more variables than available !')
									else
										OLD_PARAMETERS_STATUS = a.data.PARAMETERS_STATUS;
										a.data.PARAMETERS_STATUS(index(3).subs{1}) = val;
									end
									
									% When we set the status to virtual, we clear the odata object content and set it to a NaN.
									% (This is the goal of implementing virtual var: empty disk space)
									if strfind(val,'V')
										b = a.data;
										f = datanames(a);
										for iv = 1 : length(f)
											if a.data.PARAMETERS_STATUS(iv) == 'V'
												od = getfield(b,f{iv});
												od.cont = NaN;
												b = setfield(b,f{iv},od);
											end
										end
										a.data = b;
									end%if virtual
									
									
									% We change the status from virtual to real, we try to fill the content:
									if strfind(val,'R')
										is = strfind(val,'R');
										fn = datanames(a);
										b  = a.data;
										for iv = 1 : length(is)
											if OLD_PARAMETERS_STATUS(is(iv)) == 'V'
												c = virtual_variables(a,fn{iv});
												b = setfield(b,fn{iv},'cont',c);
											end
										end
										a.data = b;
									end
									
								otherwise
									error('Not allowed yet !')
							end

						case 4 %-- define T.data.ODATA.<something>(<something>) = val
							error('Not allowed yet !')						
					end
			
			
					% We need to be sure here that fields are sorted by alphebetical order
					% ----
			%-- prec		
			case 'prec',  
				switch size(index,2)
					case 1
						a.prec = val;	
					case 2
						b = a.prec;
						b = setfield(b,index(2).subs,val);
						a.prec = b;
				end
			
			
			otherwise
				error('Invalid field name');
		end
	case '{}'
		error('Cell array indexing not support by transect objects');
end

% Here we update the modified property:
if copoda_readconfig('transect_constructor_update_modified')
	switch index(1).type
		case '.'
			switch index(1).subs
				case 'modified', % Nothing to do
				otherwise % We update:
					a.modified = now;
			end
	end%switch
end%if

% And here we check if virtual variables are those allowed:
dn  = datanames(a);
VTV = list_all_vtv; 
for iv = 1 : length(dn)
	if strcmp(dstatus(a,dn{iv}),'V')
		if isempty(intersect(VTV,dn{iv}))
			error(sprintf('Variable %s is not allowed to have a Virtual status !',dn{iv}));
		end
	end
end



end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%
function Vlist = list_all_vtv(varargin)
	
	p  = class_home;
	di = dir(sprintf('%s/private',class_home));
	it = 0;
	for ii = 1 : length(di)
		if ~di(ii).isdir
			if strfind(di(ii).name,'.m') & strfind(di(ii).name,'vtv_')
				it = it + 1;
				VTV(it).fct = strrep(di(ii).name,'.m','');
				[VTV(it).vname VTV(it).desc] = eval(VTV(it).fct);
				Vlist(it) = {VTV(it).vname};
			end
		end
	end
	if it == 0
		Vlist = NaN;
	end

end%function

%%%%%%%%%%%%%%%%%%%
function p = class_home()
	p = strrep([mfilename('fullpath') '.m'],[mfilename '.m'],'');
end%function



