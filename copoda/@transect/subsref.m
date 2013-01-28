% subsref Subscripted reference of a transect object field
%
% B = subsref(T,index)
% 
% Subscripted reference of a transect object field: retrieve
% informations from T.
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


function b = subsref(T,index)

%disp(index(1).type)

switch index(1).type
	%%%%%%%%%%%		
	case '.'	
	%- dot access to index(1).subs:
		switch index(1).subs
			%%%%%%%%%%%%%%%%%%%%%%%%%%
			%-- source
			case 'source', 	  
				if size(index,2) == 1
					b = T.source;
				elseif size(index,2) == 2
					b = T.source;
					b = b(cell2mat(index(2).subs));
				end
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%				
			%-- file			
			case 'file', 	  
				if size(index,2) == 1
					b = T.file;
				elseif size(index,2) == 2
					b = T.file;
					b = b(cell2mat(index(2).subs));
				end	

			%%%%%%%%%%%%%%%%%%%%%%%%%%
			%-- creator			
			case 'creator', 	  
				if size(index,2) == 1
					b = T.creator;
				elseif size(index,2) == 2
					b = T.creator;
					b = b(cell2mat(index(2).subs));					
				else
					error('Invalid field name');
				end				

			%%%%%%%%%%%%%%%%%%%%%%%%%%				
			%-- cruise_info			
			case 'cruise_info', 
				if size(index,2) == 1
					b = T.cruise_info;
				elseif size(index,2) == 2
					b = T.cruise_info;
					b = getfield(b,index(2).subs);
				elseif size(index,2) == 3
					b = T.cruise_info;
					b = getfield(b,index(2).subs);
					b = b(cell2mat(index(3).subs));
				else
					error('Invalid field name');
				end
				
			%%%%%%%%%%%%%%%%%%%%%%%%%%
			%-- geo									
			case 'geo'
				switch size(index,2)
					case 1 %--- size(index,2) = 1 -> call to T.geo
						b = T.geo;						
					case 2 %--- size(index,2) = 2 -> call to T.geo.<something>	
						b = T.geo;
						b = getfield(b,index(2).subs);
						switch index(2).subs
							case 'LONGITUDE'
								% Here, we force longitude to be in -180:180 or 0:360
								if copoda_readconfig('copoda_longitude_classicsystem')
									% Move to longitude east from 0 to 360:
									b(b>=-180 & b<0) = 360 + b(b>=-180 & b<0); 
								else
									% Move to longitude west/east: -180:180								
									b(b>180 & b<=360) = b(b>180 & b<=360) - 360;
								end
						end
					case 3 %--- size(index,2) = 3 -> call to T.geo.<something>(<somethingelse>)
						b = T.geo;
						b = getfield(b,{1},index(2).subs,index(3).subs);
						switch index(2).subs
							case 'LONGITUDE'
								% Here, we force longitude to be in -180:180 or 0:360
								if copoda_readconfig('copoda_longitude_classicsystem')
									% Move to longitude east from 0 to 360:
									b(b>=-180 & b<0) = 360 + b(b>=-180 & b<0); 
								else
									% Move to longitude west/east: -180:180								
									b(b>180 & b<=360) = b(b>180 & b<=360) - 360;
								end
						end
					otherwise
						error('Invalid field name');						
				end

			%%%%%%%%%%%%%%%%%%%%%%%%%%	
			%-- data			
			case 'data', 			
%				disp(size(index,2))
				
				switch size(index,2)
					
					case 1 %--- size(index,2) = 1 -> call to T.data
						b  = T.data;
						
						% Add the list of parameters:
						b  = setfield(b,'STATION_PARAMETERS',datanames(T));
						
						%
						dn = datanames(T);
						bn = fieldnames(b);
						for ib = 1 : length(bn)
							if isempty(intersect(bn{ib},dn)) & (~strcmp(bn{ib},'STATION_PARAMETERS') & ~strcmp(bn{ib},'PARAMETERS_STATUS'))
								b = rmfield(b,bn{ib});
							end
						end
						
					case 2 %--- size(index,2) = 2 -> call to T.data.<something>
						switch index(2).subs
							case 'STATION_PARAMETERS' %---- return STATION_PARAMETERS
								% The property 'STATION_PARAMETERS' is build "dynamically" by scanning
								% the content of T.data and identifying odata object:
								b = datanames(T);
								
							case 'PARAMETERS_STATUS' %---- return PARAMETERS_STATUS
								b = T.data;
								b = b.PARAMETERS_STATUS;
								
							otherwise %---- return ODATA object
								l = data_list;
								if isfield(l,index(2).subs)
									b = T.data;
									if isfield(b,index(2).subs)
										status = dstatus(T,index(2).subs);						
										switch status
											case 'R'
												b = getfield(b,index(2).subs);
											case 'V'
												% disp(sprintf('\ti2: This field is virtual !\tI''m going to compute it online at your request'))
												b = getfield(b,index(2).subs);
												b.cont = virtual_variables(T,index(2).subs); % Fill in content
										end
									else
										throw(MException('COPODA:transect:data','This field is valid but not defined in this transect !'));
									end
								else
									throw(MException('COPODA:transect:data',...
												'Invalid field name for transect.data odata object, type:\n\tsupported_variables(transect,''t'')\nto list valid fields'));
								end
						end%switch what after .data
					
					case 3	%--- size(index,2) = 3 -> call to T.data.<something>.(<somethingelse>)
						% <something> = index(2).subs
						% <somethingelse> = index(3).subs
						switch index(2).subs
							case 'STATION_PARAMETERS' 
							%---- return STATION_PARAMETERS(<somethingelse>)
								l = datanames(T);
								b = l(index(3).subs{1});
								
							case 'PARAMETERS_STATUS' 
							%---- return PARAMETERS_STATUS(<somethingelse>)
								l = T.data.PARAMETERS_STATUS;
								b = l(index(3).subs{1});
								
							otherwise 
							%---- return ODATA.<somethingelse>
								% An odata object: 
								b = T.data;
								switch dstatus(T,index(2).subs)						
									case 'R'
										b = getfield(b,{1},index(2).subs,index(3).subs);					
									case 'V'							
										% disp(sprintf('\ti3: This field is virtual !\tI''m going to compute it online at your request'))
										b = getfield(b,{1},index(2).subs);	% Get odata object									
										% index(3).subs is an odata property:
										switch class(index(3).subs)
											case 'char'										
												if strcmp(index(3).subs,'cont')
													b.cont = virtual_variables(T,index(2).subs); % Fill in content
													b = b.cont; % Return only numerical values
												else
													b = getfield(b,index(3).subs);			
												end												
											case 'double'	
												b = virtual_variables(T,index(2).subs,substruct('.','cont','()',index(3).subs)); % Fill in content
										end
								end
						end%switch what we asked for
					
					case 4 %--- size(index,2) = 4 -> call to T.data.ODATA.<something>(somethingelse)
						b = T.data;
						switch dstatus(T,index(2).subs)						
							case 'R'
								b = getfield(b,{1},index(2).subs,index(3).subs,index(4).subs);					
							case 'V'							
								% disp(sprintf('\ti4: This field is virtual !\tI''m going to compute it online at your request'))
								b = getfield(b,{1},index(2).subs); % Odata object
								switch index(3).subs % These are odata fields
									case 'cont'
										% Method 1, we compute everything and extract what we need:
										% Not efficient !
%										b.cont = virtual_variables(T,index(2).subs); % Fill in content							
%										b = getfield(b,index(3).subs,index(4).subs);
										
										% Method 2, we compute only what we need !
										b = virtual_variables(T,index(2).subs,index(3:end));

									otherwise					
										b = getfield(b,index(3).subs,index(4).subs);
								end
						end
							
					otherwise
						throw(MException('COPODA:transect:data',...
								'Invalid field name for transect.data odata object, type:\n\tsupported_variables(transect,''t'')\nto list valid fields'));
						
				end%switch how deep we asked
				
			%%%%%%%%%%%%%%%%%%%%%%%%%%	
			%-- prec (precision)		
			case 'prec', 
				%b = T.prec;
				switch size(index,2)				
					case 1 %--- size(index,2) = 1 -> call to T.prec
						b = T.prec;
					case 2 %--- size(index,2) = 2 -> call to T.prec.<something>					
						b = T.prec;
						b = getfield(b,index(2).subs);
				end
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%
			%-- created
			case 'created', 				  
				if size(index,2) == 1
					b = T.created;
				elseif size(index,2) == 2
					b = T.created;
					b = b(cell2mat(index(2).subs));
				end

			%%%%%%%%%%%%%%%%%%%%%%%%%%
			%-- modified
			case 'modified', 	  
				if size(index,2) == 1
					b = T.modified;
				elseif size(index,2) == 2
					b = T.modified;
					b = b(cell2mat(index(2).subs));
				end	
				
			%%%%%%%%%%%%%%%%%%%%%%%%%%
			%-- file_date
			case 'file_date', 	  
				if size(index,2) == 1
					b = T.file_date;
				elseif size(index,2) == 2
					b = T.file_date;
					b = b(cell2mat(index(2).subs));
				end
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%	
			%-- otherwise > error !		
			otherwise
				throw(MException('COPODA:transect','Invalid transect object property'));
		end
		
	%%%%%%%%%%%
	%- {} access error !
	case '{}'
		throw(MException('COPODA:transect','Cell array indexing not supported by transect objects'));
	
end% switch 

end %function


%%%%%%%%
function b = st_par(T)
	b = T.data; 
	bnam = fieldnames(b); 
	keep = NaN;
	for ib = 1 : length(bnam)
		if isa(getfield(b,bnam{ib}),'odata')
			keep = [keep ib];
		end
	end
	keep = keep(2:end);
	b = bnam(keep);
end


