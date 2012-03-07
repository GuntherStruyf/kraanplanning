function [total_time , craneposX, craneposY]= simulate_planning( tasks, cranes, exec_order, handlingTime, initial_terminal_state)
%SIMULATE_PLANNING simulate the proposed execution order of the tasks
% at each time increment: either progress each crane's current task or pick
% the next task on the task list (respecting specified execution order)
% which the crane can execute

%% INITIALIZATION

	t=1;
	Ntasks = numel(tasks);
	Ncranes = numel(cranes);
	% for easy task access (in the specified execution order), reorder the
	% tasks accordingly:
	tasks(exec_order) = tasks;
	
	speedX = cranes(1).maxVelX;
	speedY = cranes(1).maxVelY;
	
	% enable cranes
	for i = 1:Ncranes
		cranes(i).status = CraneStatus.AwaitingOrders;
	end
	
	% preallocate memory for crane positions
	% otherwise, the size of this parameter would change every time step
	craneposX = zeros(500,Ncranes);
	craneposY = zeros(500,Ncranes);
	
%% DIVIDE TASKS
	
	% initialize crane task list:
	crane_TaskList{Ncranes}=[];
	
	for i=1:Ntasks
		possible_cranes = intersect(cell2mat(getResponsibleCranes(tasks(i).loc_origin.x,cranes)),...
									cell2mat(getResponsibleCranes(tasks(i).loc_destination.x,cranes)));
		if numel(possible_cranes)>1
			% make a choice!
			% let's choose the crane with the lowest index
			cr_idx = min(possible_cranes);
		else
			% this is easier
			cr_idx = possible_cranes;
		end
		crane_TaskList{cr_idx} = [crane_TaskList{cr_idx} i];
	end
	
%% ACUTAL SIMULATION
	while 1
		% check if all tasks are completed
		if allTasksCompleted(tasks);
			break;
		end
		M=size(craneposX,1);
		if t>size(craneposX,1) % if t has become larger than foreseen
			% enlarge the position vectors
			craneposX(M+500,3)=0;
			craneposY(M+500,3)=0;
		end
		for i=1:Ncranes
			craneposX(t,i)=cranes(i).x;
			craneposY(t,i)=cranes(i).y;
			
			if cranes(i).status == CraneStatus.AwaitingOrders
				% pick a new task from the crane task list
				for j=crane_TaskList{i}
					% check if task is ready to execute
					if tasks(j).status == TaskStatus.Awaiting && tasks(j).earliestStartTime<=t
						cranes(i).curTaskID = j;
						cranes(i).status = CraneStatus.MoveToOrigin;
						cranes(i).actionStart=t;
						tasks(j).status=TaskStatus.InProgress;
						break;
					end
				end
			end
			if cranes(i).status==CraneStatus.MoveToOrigin
				% move to origin
				[arrival,cranes(i).x, cranes(i).y] = move(cranes(i).x,cranes(i).y, ...
					tasks(cranes(i).curTaskID).loc_origin.x, ...
					tasks(cranes(i).curTaskID).loc_origin.y, speedX,speedY);
				if arrival
					cranes(i).status=CraneStatus.HandlingContainer;
					cranes(i).actionStart=t;
				end
			end
			if cranes(i).status==CraneStatus.HandlingContainer
				% check if handling time has passed
				if t>=cranes(i).actionStart+handlingTime
					% check if origin/destination reached (and thus doing
					% container handling at that spot)
					if cranes(i).x==tasks(cranes(i).curTaskID).loc_origin.x && ...
							cranes(i).y==tasks(cranes(i).curTaskID).loc_origin.y
						cranes(i).status = CraneStatus.MoveToDestination;
						cranes(i).actionStart=t;
					else % destination was reached
						% thus task completed
						tasks(cranes(i).curTaskID).status=TaskStatus.Completed;
						fprintf('Task %3d completed\n',cranes(i).curTaskID);
						cranes(i).status = CraneStatus.AwaitingOrders;
						cranes(i).actionStart=t;
					end
				end
			end
			if cranes(i).status==CraneStatus.MoveToDestination
				% move to destination, analogous to move to origin
				[arrival,cranes(i)] = move(cranes(i), ...
							tasks(cranes(i).curTaskID).loc_destination);
				if arrival
					cranes(i).status=CraneStatus.HandlingContainer;
					cranes(i).actionStart=t;
				end
			end
		end
		
		t=t+1;
	end
	% remove empty (preallocated) positions
	craneposX(t:end,:) = [];
	craneposY(t:end,:) = [];
	t=t-1;
	
	total_time=t;
end

function retval = allTasksCompleted(tasks)
	retval=true;
	for t=tasks
		if t.status~=TaskStatus.Completed
			retval=false;
			return
		end
	end
end
function [isArrival crane] = move(crane, destination,dt)
	brake_dist = crane.velX
	if abs(x1-x2)<speedX
		x=x2;
	elseif x2>x1
		x=x1+speedX;
	else
		x=x1-speedX;
	end
	if abs(y1-y2)<speedY
		y=y2;
	elseif y2>y1
		y=y1+speedY;
	else
		y=y1-speedY;
	end
	arrival = x==x2 && y==y2;
end
function [isArrival pos vel] = move(pos,vel,dt,vmax,amax, pos_dest)
	dx = pos_dest-pos;
	if dx<0
		[isArrival pos vel]=move(-pos,-vel,dt,vmax,amax,-pos_dest);
		pos=-pos;
		vel=-vel;
	else
		% when assuming triangular velocity profile: vtop = top velocity
		% equals the following (do the math if you don't believe me ;) )
		vtop = sqrt(dx*amax+vel^2/2);
		
		if vtop>vmax
% 			vel = vmax;
% 			pos = pos+(vel+vmax)/2*dt
			
		else
			
			
		end
	
	% can we still stop in time, if we raise velocity with maxAcc?
	brake_dist = (vel+maxAcc
	% and what if we keep moving with current velocity, can we stop in time?
	brake_dist = vel^2/maxacc;
	
	% and if we raise the velocity with maxacc?
	brake_dist = 
	
end

function is_area_free(xspan, curIndex, cranes)
	
	
end