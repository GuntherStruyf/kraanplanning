classdef Crane
	%CRANE information about a crane
	%   contains crane span, start/end of span, current position
	%PROPERTIES
	%	Xspan:		the working span of the crane
	%	Xstart:		start of the crane's working span
	%	x,y:		position of the crane's gantry
	%	velX,velY:	velocity of the crane's gantry
	%	maxVelX/Y:	maximum x and y velocity
	%	maxAccX/Y:	maximum x and y acceleration
	%
	%	collisionWidth:	minimum distance an object has to stay away from
	%				the crane's center (x-position) in order not to collide
	%	status:		current status of the crane (Disabled, Waiting, Working)
	%	curTaskID:	the id of the current task the crane is executing
	%	actionStart:the time at which the current action of the crane has
	%				started
	%
	%CONSTRUCTOR:
	%	Crane(Xspan, Xstart)
	%	Crane(Xspan, Xstart, x, y, status)
	%	Crane(Xspan, Xstart, x, y, status, velX, velY, maxVelX, maxVelY, maxAccX, maxAccY, collisionWidth)
	
	properties(SetAccess=protected)
		Xspan	= 0;
		Xstart	= 0;
	end
	properties
		x		= 0;	% position
		y		= 0;
		velX	= 0;	% velocity
		velY	= 0;
		maxVelX	= 0;	% velocity limits
		maxVelY = 0;
		maxAccX	= 0;	% acceleration, assume step profile possible
		maxAccY	= 0;
		
		collisionWidth	= 0;
		status			= CraneStatus.Disabled;
		curTaskID		= 0;
		actionStart		= 0;
	end
	
	methods(Static)
		function obj = Crane(varargin)
			switch nargin
				case 0
					% do nothing, properties are already initialized to 0
				case 2
				% Crane(Xspan, Xstart)
					if	cell_isa(varargin,'double')
						[obj.Xspan, obj.Xstart  ...
							]= varargin{:};
					else
						error([class(obj) '(' getTypes(varargin{:}) ') constructor doesn''t exist.']);
					end
				case 5
				% Crane(Xspan, Xstart, x, y, status)
					if	cell_isa({varargin{1:4}},'double') && ...
						isa(varargin{5},'CraneStatus')
							[obj.Xspan, obj.Xstart, ...
								obj.x, obj.y, obj.status ...
								] = varargin{:};
					else
						error([class(obj) '(' getTypes(varargin{:}) ') constructor doesn''t exist.']);
					end
				case 12
				% Crane(Xspan, Xstart, x, y, status, velX, velY, maxVelX,
				% maxVelY, maxAccX, maxAccY)
					if	cell_isa({varargin{[1:4 6:12]}},'double') && ...
						isa(varargin{5},'CraneStatus')
							[obj.Xspan, obj.Xstart, ...
								obj.x, obj.y, obj.status, ...
								obj.velX, obj.velY, obj.maxVelX, obj.maxVelY, obj.maxAccX, obj.maxAccY, obj.collisionWidth ...
								] = varargin{:};
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
			if numel(obj)<=1
				fprintf('<a href = "matlab:help %s">%s</a>\n',class(obj),class(obj));
				fprintf('\t position:\t[%2.2f %2.2f]\n',obj.x,obj.y);
				fprintf('\t velocity:\t[%2.2f %2.2f]\n',obj.velX,obj.velY);
				fprintf('\t max velocity:\t\t[%2.2f %2.2f]\n',obj.maxVelX,obj.maxVelY);
				fprintf('\t max acceleration:\t[%2.2f %2.2f]\n',obj.maxAccX,obj.maxAccY);
				fprintf('\t collision width:\t %2.2f\n',obj.collisionWidth);
				fprintf('\t status:%s\n',evalc('disp(obj.status)'));
			else
				fprintf('\t<a href = "matlab:help %s">%s</a> array with dimensions [%s]\n',class(obj),class(obj),num2str(size(obj)));
			end
		end
	end
end
function r = cell_isa(cellvar, stype)
	r= all(cellfun(@(x) isa(x,stype),cellvar));
end