classdef Task
	%TASK move a container from location i to location j
	
	properties
		loc_origin		= Location.Zero();
		loc_destination	= Location.Zero();
		EarliestStartTime = 0;
	end
	
	methods(Static)
		function obj = Task(varargin)
			switch nargin
				case 0
					% do nothing, properties are already initialized to
					% zero ^^
				case 2
					if isa(varargin{1},'Location') && isa(varargin{2},'Location')
						obj.loc_origin = varargin{1};
						obj.loc_destination = varargin{2};
						obj.EarliestStartTime = 0;
					else
						error([class(obj) '(' getTypes(varargin{:}) ') constructor doesn''t exist.']);
					end
				case 3
					if isa(varargin{1},'Location') && isa(varargin{2},'Location') && isa(varargin{3},'double')
						obj.loc_origin = varargin{1};
						obj.loc_destination = varargin{2};
						obj.EarliestStartTime = varargin{3};
					else
						error([class(obj) '(' getTypes(varargin{:}) ') constructor doesn''t exist.']);
					end
				otherwise
					error([class(obj) '(' getTypes(varargin{:}) ') constructor doesn''t exist.']);
			end
		end
	end
	methods
		function disp(obj)
			fprintf('<a href = "matlab:help %s">%s</a>\n',class(obj),class(obj));
			fprintf('\tOrigin:\t\t %s\n',obj.loc_origin.toString);
			fprintf('\tDestination: %s\n',obj.loc_destination.toString);
			fprintf('\tMin Starting time: %3d\n',obj.EarliestStartTime);			
		end
	end
	
end

