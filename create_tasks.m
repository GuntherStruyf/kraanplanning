function [tasks, ordered_taskpairs, truckArrivalTime] = create_tasks( Ntrucks, terminal, cranes, maxArrivalTime, truckLanes, dropZoneWidth )
%CREATE_TASKS randomly create a set of tasks
%	
%	Ntrucks:		number of trucks
%	terminal:		matrix representation of the terminal, each value
%					represents a container index, 0 is no container
%	cranes:			Crane objects holding information on the cranes
%	maxArrivalTime:	The maximum value for 'arrivalTime'
%	truckLanes:		number of adjacent trucklanes
%	dropZoneWidth:	width of the dropzone (where containers are offloaded)
%
%	tasks:			Task objects, holding the generated tasks
%	ordered_taskpairs:	vector, holding task index pairs, referencing tasks
%						which should be executed in order: task(index1)
%						before task(index2)
%	truckArrivalTime:	Nx1 vector, contains for each truck, the time in
%					seconds (since beginning of planning execution) at
%					which the truck arrives. For simplicity's sake this
%					vector is sorted in ascending order.
	
	%% CHECK INPUT
	terminalDim = size(terminal);
	truckAreaDim = [size(terminal,1) truckLanes];
	dropZoneDim = [size(terminal,1) dropZoneWidth size(terminal,3)];
	
	if Ntrucks > prod(truckAreaDim)
		error('can''t fit that many trucks inside given truckArea');
	end
	
	%% SET UP RANDOM TRUCK CONFIGURATION
	
	% pick random locations for all arriving trucks
	rnd_idx = 1:prod(truckAreaDim);
	rnd_idx = rnd_idx(randperm(prod(truckAreaDim))); % shuffle
	rnd_idx = rnd_idx(1:Ntrucks); % remove unused indices
	[truck_loc(:,1) truck_loc(:,2)] = ind2sub(truckAreaDim,rnd_idx);
	truck_loc(:,3) = 1;
	
	% pick random arrival times
	truckArrivalTime = sort(floor(maxArrivalTime*rand(Ntrucks,1)));
	
	%% UNLOADING TASKS
	
	% number of trucks to offload, other trucks arrive empty
	Nunload = 1+floor(rand*Ntrucks);
	% generate positions in the dropzone
	drop_loc(:,1)  = floor(rand(Nunload,1)*dropZoneDim(1));
	drop_loc(:,2)  = truckLanes+ terminalDim(2) + floor(rand(Nunload,1)*dropZoneDim(2));
	drop_loc(:,3)  = 1; % don't care, drop and forget
	
	% pick which trucks to offload
	truck_unload = 1:Ntrucks;
	truck_unload = truck_unload(randperm(Ntrucks)); % shuffle
	truck_unload = truck_unload(1:Nunload); % not necessary, but for clarity
	
	% convert to tasks
% 	tasks(Nunload) = Task; % preallocate memory
% 	for i = 1:Nunload
% 		tasks(i) = Task(	Location(truck_loc(truck_unload(i),:))	, ...
% 							Location(drop_loc(i,:))				, ...
% 							truckArrivalTime(truck_unload(i))	, ...
% 							truck_unload(i)						);
% 	end
	
	tasks(Nunload) = Task; % preallocate memory
	empty_tasks =[];
	for i = 1:Nunload
		% the truck stand on position x, find the range of terminal
		% locations that the cranes can offload this truck to
		xspan = possible_terminal_region(truck_loc(truck_unload(i),1), cranes);
		if isempty(xspan) % truck position is of out any crane range
			empty_tasks = [empty_tasks i];
		else
			% pick a random x location out of the possible
			x = xspan(1+floor(rand*numel(xspan)));
			% pick random y location
			y = floor(rand*dropZoneDim(2));
			% save task
			tasks(i) = Task(Location(truck_loc(truck_unload(i),:))			, ...
							Location(x, y + truckLanes+ terminalDim(2), 1)	, ...
							truckArrivalTime(truck_unload(i))				, ...
							truck_unload(i)									);
		end
	end
	tasks(empty_tasks) = []; % remove empty tasks
	Nunload = Nunload - length(empty_tasks);
	
	
	
	
	
	
	%% LOADING TASKS
	
	% number of trucks to offload, other trucks leave empty
	Ncontainers = countContainers(terminal);
	Nload = min(1+floor(rand*Ntrucks), Ncontainers);
	% pick which trucks to load
	truck_load = 1:Ntrucks;
	truck_load = truck_load(randperm(Ntrucks)); % shuffle
	truck_load = truck_load(1:Nload); % not necessary, but for clarity
	
	% convert to tasks
	tasks(Nunload+Nload) = Task; % preallocate memory
	empty_tasks =[];
	for i = 1:Nload
		% the truck stand on position x, find the range of containers that
		% the cranes can deliver to this x position
		xspan = possible_terminal_region(truck_loc(truck_load(i),1), cranes);
		if isempty(xspan) % truck position is of out any crane range
			empty_tasks = [empty_tasks Nunload+i];
		else
			% get the containers in this range
			cont_possible = unique(terminal(xspan,:,:));
			% randomly pick one of them
			rnd = 1+floor(rand*numel(cont_possible));
			% convert to xyz indicies
			xyz = findContainer(terminal,cont_possible(rnd));
			% detect for nill container
			if all(xyz ==[0 0 0])
				empty_tasks = [empty_tasks Nunload+i];
			else
				% save task
				tasks(Nunload+i) = Task(Location(xyz + [0 truckLanes 0])		, ...
										Location(truck_loc(truck_load(i),:))	, ...
										truckArrivalTime(truck_load(i))			, ...
										truck_load(i)							);
				% remove container from terminal, so it can't be chosen again
				terminal(xyz(1),xyz(2),xyz(3))=0;
			end
		end
	end
	tasks(empty_tasks) = []; % remove empty tasks
	Nload = Nload - length(empty_tasks);
	
	%% DETECT ORDER OF EXECUTION RULES
	
	% loop through all unloading tasks, if there exists a loading task for
	% the same truck -> apply order rule on these two tasks
	ordered_taskpairs = [];
	for i=1:Nunload % loop through all unloading tasks
		for j=Nunload+1:Nunload+Nload % loop through all loading tasks
			if tasks(i).truckID == tasks(j).truckID
				ordered_taskpairs = [ordered_taskpairs ; i j];
				break
			end
		end
	end
	
	% ...
	
end

function x_possible = possible_terminal_region(truck_x,cranes)
	crane_idx = cell2mat(getResponsibleCranes(truck_x,cranes));
	x_possible=[];
	for i = 1:numel(crane_idx)
		x_possible = unique([x_possible,cranes(crane_idx(i)).Xstart+[0:cranes(crane_idx(i)).Xspan-1]]);
	end
end
