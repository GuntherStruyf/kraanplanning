%% RESET WORKSPACE

clear
close all
clc

%% SETTINGS

% let's assume 2 TEU (40 foot container)
container_length	= 12.192;	% 40ft
container_width		= 2.438;	% 8ft
container_height	= 2.591;	% 8.5ft

Ncontainers = 50;			% number of containers in the terminal
Ntrucks = 10;				% number of trucks
truckLanes = 13;			% number of adjacent trucklanes
terminal_dim = [29 5 4];	% dimensions of the terminal, [length width height]
dropZoneWidth = 5;			% dropzone width
maxArrivalTime = 300;		% max value for arrival time (seconds)
handlingTime = 50;			% how long it takes to handle one container (ie
							% single action of putting down, picking up a
							% container with the crane)

crane_track_speed = 1/container_length;	
							% containers/s speed along the crane's track
crane_gantry_speed = 1/container_width;
							% containres/s speed along the crane's gantry

Ncranes = 3;				% number of cranes
crane_overlap = 2;			% expressed in number of containers

%% INITIAL SETUP

% width of the working area of one crane
crane_area = (terminal_dim(1) - crane_overlap)/Ncranes+crane_overlap;

% preallocate memory
cranes(Ncranes) = Crane;
% set first crane
cranes(1) = Crane(crane_area,1);
% and also the others
for i = 2:Ncranes
	cranes(i) = Crane(crane_area,cranes(i-1).Xstart+crane_area-crane_overlap);
end

%% INPUT

% fill the terminal randomly with containers
terminal = populate_terminal(terminal_dim,Ncontainers);
% generate some tasks
[tasks, ordered_taskpairs, truckArrivalTime] = create_tasks(Ntrucks, terminal, cranes, maxArrivalTime, truckLanes, dropZoneWidth );
% so the total number of tasks is:
Ntasks = length(tasks);

%% DIVIDE TASKS

% % find the loadon container, save the position
% [tmp,C] = ismember(loadon,terminal);
% [loadon_pos(:,1) loadon_pos(:,2) loadon_pos(:,3)] = ind2sub(size(terminal),C);
% 
% % display container positions
% plot_task_containers(loadon,terminal,Ncranes,crane_overlap);
% 
% crane_numtasks=zeros(Ncranes,1);	% initialize crane number of tasks
% task_assigned = zeros(Ncranes,1);	% initialize task assignment indicator
% 
% % first crane only has one neighbour, thus different overlap
% ub = crane_area-crane_overlap;		% upper bound of the current crane's area
% idx = find(loadon_pos(:,1)<ub);
% crane_numtasks(1) = numel(idx);
% task_assigned(idx)=true;
% % so is the case for the last crane
% lb = (Ncranes-1)*(crane_area-crane_overlap)+crane_overlap;	% lower bound of the current crane's area
% idx = find(loadon_pos(:,1)>lb);
% crane_numtasks(1) = numel(idx);
% task_assigned(idx)=true;
% % all other cranes have two neighbours
% for i=2:Ncranes-1
% 	lb = 1+(i-1)*(crane_area-crane_overlap);
% 	ub = i*(crane_area-crane_overlap)+crane_overlap;
% 	idx = find(loadon_pos(:,1)>lb & loadon_pos(:,1)<ub);
% 	crane_numtasks(i) = numel(idx);
% end
% % set empty tasks (load container 0) as assigned=true
% task_assigned(loadon==0)=true;
% 
% % divide remaining overlapping tasks to either of two cranes in the
% % overlapping area
% 
% %...


%% SET TASK ORDER

% let's keep it easy for now: firstly offload everything, then load
exec_order = 1:Ntasks;
% for easy analysis, calculate the inverse of this exec_order
% ie an array contain the exec number for each task:
inv_exec_order(exec_order) = 1:Ntasks;


%% CHECK CONDITIONS

for i=1:size(ordered_taskpairs,1)
	if inv_exec_order(ordered_taskpairs(i,1))>inv_exec_order(ordered_taskpairs(i,2))
		warning('CranePlanning:TaskExecOrder','Task %d must be handled before task %d',ordered_taskpairs(i,1),ordered_taskpairs(i,2));
	end
end


%% SIMULATE TASK EXECUTION

[total_time , craneposX, craneposY] = simulate_planning(tasks, cranes, exec_order, truckArrivalTime, terminal ,[crane_track_speed crane_gantry_speed], handlingTime);
fprintf('Total execution time: %4ds\n',total_time);

%% PRODUCE NICE IMAGES
figure
plot(craneposX,craneposY);
xlabel('x');ylabel('y','Rotation',0)