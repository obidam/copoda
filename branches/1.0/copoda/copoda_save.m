% copoda_save Save a COPODA database or transect class object
%
% MSG = copoda_save(FILENAME,OBJ)
% 
% Save a COPODA database or transect class object
%
% Inputs:
%	FILENAME: binary "MAT-file" where saving object OBJ
%		(named FILENAME.mat)
%	OBJ: a database or transect class instance
%
% Outputs:
%	MSG: true or false to indicate saving operation success
%
% Created: 2010-06-16.
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

% Category for documentation:
%CAT 
% Method's type for documentation:
%TYP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = copoda_save(varargin)

%%%%%%%%%%%%%%%%% Check inputs:
error(nargchk(2,2,nargin,'struct'))

FILE = varargin{1};
OBJname = varargin{2};
MSG  = false; % Default result

if ~ischar(FILE)
	error('File name must be a string')
end

% Eventually remove .mat extension:
if length(FILE) > 4
	if strcmp(FILE(end-4:end),'.mat')
		FILE = FILE(1:end-5);
	end
end

% Load object from caller workspace:
try 
	eval(sprintf('%s = evalin(''caller'',OBJname);',OBJname));
catch
	error(sprintf('%s is not in the workspace',OBJname))
end

% Only apply to copoda objects:
switch class(eval(OBJname))
	case {'transect','database'}
		% OK to use this script
	otherwise
		error('copoda_save function only for database and transect objects');
end

%%%%%%%%%%%%%%%%% Save
try		
	ver = 2; % What kind of saving do we do ?
	switch ver
		case 1 %-- Classic call object's saveobj methods:
			eval(sprintf('save(''%s'',''%s'',''-v6'');',FILE,OBJname));
			MSG = true;
		case 2 %-- Customize for database to be able to load only 1 transect within 1 database
			switch class(eval(OBJname))
				case 'transect'
					eval(sprintf('save(''%s'',''%s'',''-v6'');',FILE,OBJname));
					MSG = true;
				case 'database'
					% We gonna remove transect(s) from the database and save them as 
					% separate entities within the matlab mat file
					%stophere
					%D0 = D;
					nT  = length(D);nt=nT;
					iT0 = 1:nT; 					
					for ij = 1 : length(iT0)
						iTname  = iT0(ij);
						% Create a transect in the workspace
						eval(sprintf('T_%i = %s.transect{1};',iTname,OBJname));
						
						% And then remove it from the database:
						if nt > 2
							eval(sprintf('%s.transect = %s.transect(2 : %i);',OBJname,OBJname,nt));
						else
							eval(sprintf('%s.transect = {%s.transect(%i)};',OBJname,OBJname,nt));							
						end
						% Update the new database length:
						nt = nT-ij;
					end
					
					% And the last one:
					eval(sprintf('T_%i = %s.transect{1};',iT0(end),OBJname));
					eval(sprintf('%s.transect = [];',OBJname));														
										
					% Now record the database (with no transects but meta informations)
					% and all individual transects:
					eval(sprintf('%s = saveobj(%s);',OBJname,OBJname));
					eval(sprintf('save(''%s'',''%s'',''T_*'',''-v6'');',FILE,OBJname));
					MSG = true;
					
			end%switch class
	end%swtich%ver
end

%%%%%%%%%%%%%%%%% 
if nargout == 1
	varargout(1) = {MSG};
end

end %functioncopoda_save
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%









