classdef Location
	%LOCATION contains x,y,z coordinates
	% Location(double x, double y, double z)
	% Location(double [xyz])
	% Location(Location loc)
	
	properties
		x=0;
		y=0;
		z=0;
	end
	
	methods(Static)
		function obj = Location(varargin)
			switch nargin
				case 0
					% do nothing, xyz are already initialized to 0
				case 1
					if length(varargin{1})==3
						p=num2cell(varargin{1});
						[obj.x obj.y obj.z] = p{:};
					elseif isa(varargin{1},class(obj))
						obj=varargin{1};
					else
						error([class(obj) '(' getTypes(varargin{:}) ') constructor doesn''t exist.']);
					end
				case 3
					obj.x = varargin{1};
					obj.y = varargin{2};
					obj.z = varargin{3};
				otherwise
					error([class(obj) '(' getTypes(varargin{:}) ') constructor doesn''t exist.']);
			end
		end
		function obj = Zero()
			obj = Location();
		end
	end
	methods
		function disp(obj)
			fprintf('<a href = "matlab:help %s">%s</a>\n',class(obj),class(obj));
			fprintf('\t xyz coordinates: %3d  %3d  %3d\n',obj.x,obj.y,obj.z);
		end
		function s=toString(obj)
			s=sprintf('xyz coordinates: %3d  %3d  %3d',obj.x,obj.y,obj.z);
		end
	end
	
end

