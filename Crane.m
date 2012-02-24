classdef Crane
	%CRANE information about a crane
	%   contains crane span, start/end of span, current position
	%PROPERTIES
	%	Xspan:		the working span of the crane
	%	Xstart:		start of the crane's working span
	%	x,y:		current position of the crane's gantry
	%	status:		current status of the crane (Disabled, Waiting, Working)
	%
	%CONSTRUCTOR:
	%	Crane(Xspan, Xstart)
	%	Crane(Xspan, Xstart, x, y, status)
	
	properties(SetAccess=protected)
		Xspan	= 0;
		Xstart	= 0;
	end
	properties
		x		= 0;
		y		= 0;
		status	= CraneStatus.statDisabled;
	end
	
	methods(Static)
		function obj = Crane(varargin)
			switch nargin
				case 0
					% do nothing, properties are already initialized to 0
				case 2
					if		isa(varargin{1},'double') && isa(varargin{2},'double')
						obj.Xspan	= varargin{1};
						obj.Xstart	= varargin{2};
						obj.x = obj.Xstart;
					else
						error([class(obj) '(' getTypes(varargin{:}) ') constructor doesn''t exist.']);
					end
				case 5
					if		isa(varargin{1},'double') && ...
							isa(varargin{2},'double') && ...
							isa(varargin{3},'double') && ...
							isa(varargin{4},'double') && ...
							isa(varargin{5},'CraneStatus')
						obj.Xspan	= varargin{1};
						obj.Xstart	= varargin{2};
						obj.x		= varargin{3};
						obj.y		= varargin{4};
						obj.status	= varargin{5};
					else
						error([class(obj) '(' getTypes(varargin{:}) ') constructor doesn''t exist.']);
					end
				otherwise
					error([class(obj) '(' getTypes(varargin{:}) ') constructor doesn''t exist.']);
			end
		end
	end
end
