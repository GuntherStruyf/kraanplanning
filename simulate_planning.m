function total_time = simulate_planning( tasks, cranes, exec_order, truckArrivalTime, initial_terminal_state,MaxCraneSpeeds,handlingTime )
%SIMULATE_PLANNING simulate the proposed execution order of the tasks
% at each time increment: either progress each crane's current task or pick
% the next task on the task list (respecting specified execution order)
% which the crane can execute

	t=0;
	Ntasks = numel(tasks);
	Ncranes = numel(cranes);
	% for easy task access (in the specified execution order), reorder the
	% tasks accordingly:
	tasks(exec_order) = tasks;
	
	speedX = MaxCraneSpeeds(1);
	speedY = MaxCraneSpeeds(2);
	
	% enable cranes
	for i = 1:Ncranes
		cranes(i).status = CraneStatus.AwaitingOrders;
	end
		
	% actual simulation
	while 1
		% check if all tasks are completed
		if allTasksCompleted(tasks);
			break;
		end
		for i=1:Ncranes
			if cranes(i).status == CraneStatus.AwaitingOrders
				% pick a new task
				for j=1:Ntasks
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
				[arrival,cranes(i).x, cranes(i).y] = move(cranes(i).x,cranes(i).y,...
					tasks(cranes(i).curTaskID).loc_destination.x, ...
					tasks(cranes(i).curTaskID).loc_destination.y, speedX, speedY);
				if arrival
					cranes(i).status=CraneStatus.HandlingContainer;
					cranes(i).actionStart=t;
				end
			end
		end
		
		t=t+1;
	end
	
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
function [arrival x y] = move(x1,y1,x2,y2, speedX, speedY)
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