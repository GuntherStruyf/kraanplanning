function [total_time ,tasks, craneposX, craneposY]= simulate_planning( tasks, cranes, exec_order,ordered_taskpairs, handlingTime, initial_terminal_state)
%SIMULATE_PLANNING simulate the proposed execution order of the tasks
% at each time increment: either progress each crane's current task or pick
% the next task on the task list (respecting specified execution order)
% which the crane can execute

%% INITIALIZATION

	t=1;
	dt=1;
	Ntasks = numel(tasks);
	Ncranes = numel(cranes);
	% for easy task access (in the specified execution order), reorder the
	% tasks accordingly:
	tasks(exec_order) = tasks;
	
	xmin=[];
	xmax=[];
	% enable cranes
	for i = 1:Ncranes
		cranes(i).status = CraneStatus.AwaitingOrders;
		% determine the min/max x positions
		xmin=min([xmin cranes(i).getXRange]);
		xmax=max([xmax cranes(i).getXRange]);
	end
	
	global_xspan = xmax-xmin+1;
	Xclaimed = false(1,global_xspan);
	
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
		% enlarge position array if needed
		M=size(craneposX,1);
		if t>size(craneposX,1) % if t has become larger than foreseen
			% enlarge the position vectors
			craneposX(M+500,3)=0;
			craneposY(M+500,3)=0;
		end
		% loop over all cranes
		for i=1:Ncranes
			% save current position
			craneposX(t,i)=cranes(i).x;
			craneposY(t,i)=cranes(i).y;
			
			% by using switch, transitions take at least 1s, if this is a
			% problem: use if/elseif
			% OR use the following flag: this allows rapid flow through the
			% flowchart
			FLOW_COMPLETED=false;
			while(~FLOW_COMPLETED)
				switch cranes(i).status
%--------------------------------------------------------------------------
					case CraneStatus.AwaitingOrders
						% pick a new task from the crane task list
						for j=crane_TaskList{i}
							% check if task is ready to execute
							if tasks(j).status == TaskStatus.Awaiting && tasks(j).earliestStartTime<=t
								tasks(j).status=TaskStatus.InProgress;
								cranes(i).curTaskID = j;
								cranes(i).actionStart=t;
								cranes(i).status = CraneStatus.AwaitingExecOrderClearance;
								break;
							end
						end
						FLOW_COMPLETED=true;
%--------------------------------------------------------------------------
					case CraneStatus.AwaitingExecOrderClearance
						if ValidateExecOrder(cranes(i).curTaskID,tasks,ordered_taskpairs)
							cranes(i).status = CraneStatus.AwaitingOriginClearance;
							cranes(i).actionStart=t;
							cranes(i).Xclaimed = [];
						else
							FLOW_COMPLETED=true;
						end
%--------------------------------------------------------------------------
					case CraneStatus.AwaitingOriginClearance
						% claim task space
						task_space = create_taskspace(cranes(i).x,tasks(cranes(i).curTaskID).loc_origin.x);
						[retVal, Xclaimed] = claim_area(Xclaimed,task_space,xmin);
						if retVal
							cranes(i).status= CraneStatus.MoveToOrigin;
							cranes(i).Xclaimed = task_space;
							cranes(i).actionStart=t;
						else
							% move to closest non-claimed area
							x_closest = getClosestSafeSpot(cranes(i), Xclaimed, tasks(cranes(i).curTaskID).loc_origin.x,xmin);
							[~,cranes(i)] = moveCrane( cranes(i), ...
									Location(x_closest,tasks(cranes(i).curTaskID).loc_origin.y,1), dt);
							FLOW_COMPLETED=true;
						end
%--------------------------------------------------------------------------
					case CraneStatus.MoveToOrigin
						% get task space
						task_space = create_taskspace(cranes(i).x,tasks(cranes(i).curTaskID).loc_origin.x);
						% unclaim previously claimed but no longer needed
						% area: so other cranes can use this area
						area_to_unclaim = setdiff(cranes(i).Xclaimed,task_space);
						Xclaimed=unclaim(Xclaimed,area_to_unclaim,xmin);
						cranes(i).Xclaimed = task_space;
						
						% move to origin
						[arrival,cranes(i)] = moveCrane( cranes(i), ...
									tasks(cranes(i).curTaskID).loc_origin, dt);
						if arrival
							cranes(i).status=CraneStatus.LoadingContainer;
							cranes(i).actionStart=t;
						else
							FLOW_COMPLETED=true;
						end
%--------------------------------------------------------------------------
					case CraneStatus.LoadingContainer
						% check if handling time has passed
						if t>=cranes(i).actionStart+handlingTime
							cranes(i).status = CraneStatus.AwaitingDestinationClearance;
							cranes(i).actionStart=t;
							% unclaim any position
							Xclaimed=unclaim(Xclaimed,cranes(i).Xclaimed,xmin);
							cranes(i).Xclaimed=[];
						else
							FLOW_COMPLETED=true;
						end
%--------------------------------------------------------------------------
					case CraneStatus.AwaitingDestinationClearance
						% claim task space
						task_space = create_taskspace(cranes(i).x,tasks(cranes(i).curTaskID).loc_destination.x);
						[retVal, Xclaimed] = claim_area(Xclaimed,task_space,xmin);
						if retVal
							cranes(i).status = CraneStatus.MoveToDestination;
							cranes(i).Xclaimed = task_space;
							cranes(i).actionStart=t;
						else
							% move to closest non-claimed area
							x_closest = getClosestSafeSpot(cranes(i), Xclaimed, tasks(cranes(i).curTaskID).loc_destination.x,xmin);
							[~,cranes(i)] = moveCrane( cranes(i), ...
									Location(x_closest,tasks(cranes(i).curTaskID).loc_destination.y,1), dt);
							FLOW_COMPLETED=true;
						end
%--------------------------------------------------------------------------
					case CraneStatus.MoveToDestination
						% get task space
						task_space = create_taskspace(cranes(i).x,tasks(cranes(i).curTaskID).loc_destination.x);
						% unclaim previously claimed but no longer needed
						% area: so other cranes can use this area
						area_to_unclaim = setdiff(cranes(i).Xclaimed,task_space);
						Xclaimed=unclaim(Xclaimed,area_to_unclaim,xmin);
						cranes(i).Xclaimed = task_space;
						
						% move to destination, analogous to move to origin
						[arrival,cranes(i)] = moveCrane( cranes(i), ...
									tasks(cranes(i).curTaskID).loc_destination, dt);
						if arrival
							cranes(i).status=CraneStatus.UnloadingContainer;
							cranes(i).actionStart=t;
						else
							FLOW_COMPLETED=true;
						end
%--------------------------------------------------------------------------
					case CraneStatus.UnloadingContainer
						if t>=cranes(i).actionStart+handlingTime
							% destination was reached
							% thus task completed
							tasks(cranes(i).curTaskID).status=TaskStatus.Completed;
							tasks(cranes(i).curTaskID).finishTime=t;
							fprintf('Task %3d completed\n',cranes(i).curTaskID);
							cranes(i).status = CraneStatus.AwaitingOrders;
							cranes(i).actionStart=t;
							% unclaim any position
							Xclaimed=unclaim(Xclaimed,cranes(i).Xclaimed,xmin);
							cranes(i).Xclaimed=[];
						else
							FLOW_COMPLETED=true;
						end
				end
			end
		end
		
		t=t+dt;
	end
	% remove empty (preallocated) positions
	craneposX(t:end,:) = [];
	craneposY(t:end,:) = [];
	t=t-1;
	
	total_time=t;
end

function [isArrival crane] = moveCrane(crane, destination,dt)
	% area should be cleared (or is clearing as we speak). so no collision
	% checks here ;)
	[arrivalX crane.x crane.velX] = move_constant_acceleration( crane.x,...
		crane.velX,dt,crane.maxVelX, crane.maxAccX,destination.x);
	[arrivalY crane.y crane.velY] = move_constant_acceleration( crane.y,...
		crane.velY,dt,crane.maxVelY, crane.maxAccY,destination.y);
	isArrival = (arrivalX && arrivalY);
end

function [success, area_claim] = claim_area(area_claim, new_claim,xmin)
	if any(area_claim(new_claim-xmin+1))
		% area is already claimed -> fail
		success=false;
	else
		% area is free -> success + claim
		success=true;
		area_claim(new_claim-xmin+1)=true;
	end
end
function area_claim=unclaim(area_claim, old_claim, xmin)
	area_claim(old_claim-xmin+1)=false;
end