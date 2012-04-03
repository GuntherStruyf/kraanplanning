
data_file = 'setup.mat';
force_newdata = true;

if exist(data_file,'file') && ~force_newdata
%% load data from file (if one is present)
	planning_data = load(data_file);
	% split structure in separate variables
	for f = fieldnames(planning_data)'
	   assignin('base', f{:}, planning_data.(f{:}))
	end
	clear planning_data  f; % clear further unused variables from workspace
	fprintf('Input loaded from %s\n',data_file); % displaying info to user
else
%% else generate data and save to file
	% let's assume 2 TEU (40 foot container)
	container_length	= 12.192;	% 40ft
	container_width		= 2.438;	% 8ft
	container_height	= 2.591;	% 8.5ft

	% key parameters:
	Ncontainers = 150;			% number of containers in the terminal
	Ntrucks = 100;				% number of trucks
	truckLanes = 13;			% number of adjacent trucklanes
	terminal_dim = [29 5 4];	% dimensions of the terminal, [length width height]
	dropZoneWidth = 5;			% dropzone width
	maxArrivalTime = 300;		% max value for arrival time (seconds)
	handlingTime = 50;			% how long it takes to handle one container (ie
								% single action of putting down, picking up a
								% container with the crane)
	craneWidth = 10;			% width of a crane (in meter)

	% Maximum speed of the crane's track (m/s)
	MaxCrane_track_speed = container_length;	
	% Maximum speed of the crane's gantry (m/s)
	MaxCrane_gantry_speed = container_width;
	% Maximum acceleration of the crane's track (m/s^2)
	MaxCrane_track_acceleration = MaxCrane_track_speed/5; % so max speed is reached in 5s	
	% Maximum acceleration of the crane's gantry(m/s^2)				
	MaxCrane_gantry_acceleration = MaxCrane_gantry_speed/5;						
	
	
	Ncranes = 3;				% number of cranes
	crane_overlap = 2;			% expressed in number of containers

	%% CRANE SETUP
	% width of the working area of one crane
	crane_area = (terminal_dim(1) - crane_overlap)/Ncranes+crane_overlap;

	% preallocate memory
	cranes(Ncranes) = Crane;
	% set first crane
	cranes(1) = Crane(crane_area,1, ...
		1, 0, CraneStatus.Disabled, ...
		0,0, MaxCrane_track_speed, MaxCrane_gantry_speed, MaxCrane_track_acceleration, MaxCrane_gantry_acceleration,craneWidth/2,1);
	% and also the others
	for i = 2:Ncranes
		cranes(i) = Crane(crane_area,cranes(i-1).Xstart+crane_area-crane_overlap, ...
			cranes(i-1).Xstart+crane_area-crane_overlap, 0, CraneStatus.Disabled, ...
			0,0, MaxCrane_track_speed, MaxCrane_gantry_speed, MaxCrane_track_acceleration, MaxCrane_gantry_acceleration,craneWidth/2,i);
	end
	
	%% INPUT (random)
	% fill the terminal randomly with containers
	terminal = populate_terminal(terminal_dim,Ncontainers);
	% generate some tasks
	[tasks, ordered_taskpairs, truckArrivalTime] = create_tasks(Ntrucks, terminal, cranes, maxArrivalTime, truckLanes, dropZoneWidth );
	% so the total number of tasks is:
	Ntasks = length(tasks);
	
	
	%% SAVE data to file
	% the three dots enable this line of code to expand over multiple lines
	% = easier reading, doesn't influence functioning at all
	planning_data = struct(	'Ncontainers',		Ncontainers			, ...
							'Ncranes',			Ncranes				, ...
							'Ntasks',			Ntasks				, ...
							'Ntrucks',			Ntrucks				, ...
							'container_height',	container_height	, ...
							'container_length',	container_length	, ...
							'container_width',	container_width		, ...
							'crane_area',		crane_area			, ...
							'crane_overlap',	crane_overlap		, ...
							'cranes',			cranes				, ...
							'data_file',		data_file			, ...
							'dropZoneWidth',	dropZoneWidth		, ...
							'handlingTime',		handlingTime		, ...
							'maxArrivalTime',	maxArrivalTime		, ...
							'ordered_taskpairs',ordered_taskpairs	, ...
							'tasks',			tasks				, ...
							'terminal',			terminal			, ...
							'terminal_dim',		terminal_dim		, ...
							'truckArrivalTime',	truckArrivalTime	, ...
							'truckLanes',		truckLanes			, ...
							'MaxCrane_track_speed',	MaxCrane_track_speed	, ...
							'MaxCrane_gantry_speed',MaxCrane_gantry_speed	, ...
							'MaxCrane_track_acceleration',	MaxCrane_track_acceleration	, ...
							'MaxCrane_gantry_acceleration',	MaxCrane_gantry_acceleration);
	
	if ~force_newdata
		save(data_file,'-struct','planning_data'); % actual saving to file
		fprintf('Input generated and saved to %s\n',data_file); % displaying info to user
	end
	clear planning_data i; % clear further unused variables from workspace
	
	fprintf('Loaded %d tasks\n',numel(tasks));
	
end


