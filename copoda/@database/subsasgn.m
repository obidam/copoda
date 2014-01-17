% subsasgn H1LINE
%
% [] = subsasgn()
% 
% HELPTEXT
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
			case 'source',   
				if ischar(val)
					a.source = val;
				else
					error('Database ''source'' property must be a string');
				end% if 
			case 'creator',  
				if ischar(val)
					a.creator = val;
				else
					error('Database ''creator'' property must be a string');
				end% if
			case 'created',  				
				%a.created = val;
				if isfield(a,'created')	% Already set up at the creation			
					error('This property is read only');
				end
			case 'modified',  a.modified = val;
			case 'name',      % a.name = val;
				if ischar(val)
					a.name = val;
				else
					error('Database ''name'' property must be a string');
				end% if
			case 'description', % a.description = val;
				if iscell(val)
					for il = 1 : length(val)
						if ~ischar(val{il})
							error('Database ''description'' property must be a cell of strings');							
						end% if 
					end% for il
					a.description = val;
				else
					error('Database ''description'' property must be a cell of strings');
				end% if
			case 'transect', 
				if size(index,2) == 1
					a.transect = val;
				elseif size(index,2) == 2
					b  = a.transect;
					ii = cell2mat(index(2).subs);
					b{ii} = val;
					a.transect = b;
				end% if 
			otherwise
				error('Database: Invalid property');
		end
	case '{}'
		error('Cell array indexing not support by database objects');
	case '()'
		error('Parent array indexing not support by database objects');
end



% Here we update the modified property:
%%%% Comment lines between brackets if you don't want this property to be modified automatically:
%%% {
switch index(1).type
	case '.'
		switch index(1).subs
			case 'modified', % Nothing to do
			otherwise % We update:
				a.modified = now;
		end
end%switch
%%% }

% And here w



end %function