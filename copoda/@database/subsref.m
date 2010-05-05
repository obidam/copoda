% subsref H1LINE
%
% [] = subsref()
% 
% HELPTEXT
%
%
% Created: 2009-07-22.
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
		keyboard
		it = index(1).subs
end

end %function