% subsref H1LINE
%
% [] = subsref()
% 
% HELPTEXT
%
%
% Created: 2009-07-22.
% http://code.google.com/p/copoda
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


function b = subsref(a,index)

switch index(1).type
	case '.'
		switch index(1).subs
			case 'source',  				
				if size(index,2) == 1
					b = a.source;
				elseif size(index,2) == 2	
					b = a.source;
					b = b(index(2).subs{:});
				end
			case 'creator', 			
				if size(index,2) == 1
					b = a.creator;
				elseif size(index,2) == 2	
					b = a.creator;
					b = b(index(2).subs{:});
				end
			case 'created',  b = a.created;
			case 'modified', b = a.modified;
			case 'description', %b = a.description;		
				if size(index,2) == 1
					b = a.description;
				elseif size(index,2) == 2	
					b = a.description;
					b = b{index(2).subs{:}};
				end
			case 'name', 			
				if size(index,2) == 1
					b = a.name;
				elseif size(index,2) == 2	
					b = a.name;
					b = b(index(2).subs{:});
				end
			case 'transect', 
				if size(index,2) == 1
					b = a.transect;
				elseif size(index,2) == 2	
					b = a.transect;
%					b = b{cell2mat(index(2).subs)};	
%					b = b{index(2).subs{:}};
					if length(index(2).subs{:})>1
						b = b(index(2).subs{:});
					else
						b = b{index(2).subs{:}};
					end
				elseif size(index,2) == 3					
					b = a.transect;
					b = b{cell2mat(index(2).subs)};
					b = getfield(b,index(3).subs);				
				elseif size(index,2) == 4			
					b = a.transect;
					b = b{cell2mat(index(2).subs)};
					b = getfield(b,index(3).subs,index(4).subs);
				elseif size(index,2) == 5			
					b = a.transect;
					b = b{cell2mat(index(2).subs)};
					b = getfield(b,index(3).subs,index(4).subs,index(5).subs);
				elseif size(index,2) == 6
					b = a.transect;
					b = b{cell2mat(index(2).subs)};
					b = getfield(b,index(3).subs,index(4).subs,index(5).subs,index(6).subs);
				end
			otherwise
				error('Invalid field name');
		end

	case '{}'
		error('Cell array indexing not support by database objects');

	case '()'
		%keyboard		
		%whos index

		switch size(index(1).subs,2)
			case 1 % Call to D(i)... and not D(i,j)...
				%disp(sprintf('%i transect(s)',length(index(1).subs{:})))
				
				% In case we're calling: 'D(:)'
				if ischar(index(1).subs{:})
					if strcmp(index(1).subs{:},':')
						index(1).subs{:} = 1:length(a);
					end
				end
				
				switch length(index(1).subs{:})
					case 1 %-- Request about 1 transect
						b = a.transect{index(1).subs{:}};
						if length(index) > 1
							b = subsref(b,index(2:end));
						end
						
					otherwise %-- Request about more than 1 transect
						
						switch index(2).subs
							case {'geo','data'} %--- Request about geo or data
								%disp('use extract')								
								switch length(index)
									case 2 % Only D(i).<something>
										error('You must specify another field to extract');
									case 3 % Only D(i).<something>.<somethingelse>
										b = extract(a,index(3).subs);									
									otherwise % Call D(i).<something>(somethingelse)									
										error(sprintf('You can''t specify index in %s\nYou can only specify a field',index(3).subs));
								end
							case 'source'
								length(index)
							otherwise
								error('This indexing not implemented yet');								
								
						end 
						
				end
				return
				
				
				switch size(index,2)
					case 1 %-- Call to D(i)
						switch length(index(1).subs{:})
							case 1 % Retrieve single transect
								b = a.transect{index(1).subs{:}};
							otherwise % Retrieve more than 1 transect
								% Return a cell with transects:
								b = a.transect(index(1).subs{:});
						end
					otherwise 
%						keyboard
						switch index(2).type
							case '.' %-- Call to D(i).<something>
								switch length(index)
									case 2
										index(2)
										switch index(2).subs
										end
									case 3
										index(2)
										index(3)
									case 4
											index(2)
											index(3)
											index(4)
								end
								
							otherwise
								error('This indexing not implemented yet');								
						end
						
%						error('Use parentheses indexing to retrieve a transect only');
				end
			otherwise %-- Call to D(i,j)...
				error('This indexing not implemented yet');
		end

end

end %function