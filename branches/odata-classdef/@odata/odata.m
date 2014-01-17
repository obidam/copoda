% odata H1LINE
%
% [] = odata()
% 
% HELPTEXT
%
% Created: 2013-07-18.
% Copyright (c) 2013, Guillaume Maze (Ifremer, Laboratoire de Physique des Oceans).
% All rights reserved.
% http://codes.guillaumemaze.org

% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 	* Redistributions of source code must retain the above copyright notice, this list of 
% 	conditions and the following disclaimer.
% 	* Redistributions in binary form must reproduce the above copyright notice, this list 
% 	of conditions and the following disclaimer in the documentation and/or other materials 
% 	provided with the distribution.
% 	* Neither the name of the Ifremer, Laboratoire de Physique des Oceans nor the names of its contributors may be used 
%	to endorse or promote products derived from this software without specific prior 
%	written permission.
%
% THIS SOFTWARE IS PROVIDED BY Guillaume Maze ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, 
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Guillaume Maze BE LIABLE FOR ANY 
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
classdef odata
	%- Default properties
	properties
		name = '?';
		unit = '?';
		long_name = '?';
		long_unit = '?';
		cont = [];
	end
	properties (SetAccess = private, GetAccess = public)
		lastModified = now;
		created = now;
		version;
	end
	properties (Dependent, SetAccess = private, GetAccess = public)
		createdSince;
	end	
	properties (SetAccess = private, GetAccess = private)
		% Their could go file pointers ...
	end
	
	%- List methods in separate files
	methods
		val = subsref(obj,s)
		obj = subsasgn(obj,s,val)
		ind = end(obj,k,n)
		
		varargout = disp(O,varargin)
		varargout = size(OD,varargin)
		
		varargout = plus(varargin)
		varargout = minus(varargin)
		varargout = power(varargin)
		varargout = rdivide(varargin)
		varargout = times(varargin)
	end % methods
	
	methods (Access = protected, Hidden = true)
		RES = check_units(od1,od2)
	end
	
	%- Local Methods without attributes
	methods
	
		%-- Constructor function
		% Enables to pass the data as arguments to the constructor,
		% Assigns values to properties.
		function obj = odata(varargin)
		   if nargin > 0 
				n = nargin;
				for iprop = 1 : 2 : n
					prop_nam = varargin{iprop};
					prop_val = varargin{iprop+1};
					obj = subsasgn(obj,substruct('.',prop_nam),prop_val);
				end
		   end 
		end %end TensileData
		
		%-- Property Set Methods
		
		function obj = set.name(obj,value)
			if ~ischar(value)
				error('Property ''name'' value must be a string')
			else
				obj.name = value;
				obj.lastModified = now;
			end
		end %end function set name
		
		function obj = set.long_name(obj,value)
			if ~ischar(value)
				error('Property ''long_name'' value must be a string')
			else
				obj.long_name = value;
				obj.lastModified = now;
			end
		end %end function set name
		
		function obj = set.long_unit(obj,value)
			if ~ischar(value)
				error('Property ''long_unit'' value must be a string')
			else
				obj.long_unit = value;
				obj.lastModified = now;
			end
		end %end function set unit
				
		function obj = set.unit(obj,value)
			if ~ischar(value)
				error('Property ''unit'' value must be a string')
			else
				obj.unit = value;
				obj.lastModified = now;
			end
		end %end function set unit

		%-- Property Get Methods
		
		function value = get.lastModified(obj)
			value = datestr(obj.lastModified);
		end%end function get lastModified
	
		function value = get.created(obj)
			value = datestr(obj.created);
		end%end function get created
	
		function value = get.createdSince(obj)
			dt = now - datenum(obj.created);
			value = dt*86400; % In seconds
		end%end fucntion
	
		% Odata class version. Generated only when needed
		function value = get.version(obj)
			value = '2.0';
		end%end fucntion
	
	end %end methods
	
end %end classdef