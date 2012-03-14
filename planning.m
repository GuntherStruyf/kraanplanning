%% RESET WORKSPACE

clear
close all
clc
tic

%% SETTINGS

planning_setup

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

[total_time , tasks, craneposX, craneposY] = simulate_planning(tasks, cranes, exec_order,ordered_taskpairs, handlingTime, terminal);
fprintf('Total execution time: %4ds\n',total_time);
toc

%% CALCULATE TOTAL GOAL FUNCTION VALUE

goal_value=0;
allowable_time=20*60;
for i=1:numel(tasks)
	goal_value = goal_value + max(0, tasks(i).finishTime-tasks(i).earliestStartTime);
end
fprintf('Goal value = %d\n',goal_value);


%% PRODUCE NICE IMAGES
figure; hold on
% draw crane span borders
YL = [min(craneposY(:))-1 max(craneposY(:))+1]; % get y[min, max]
for cr = cranes
	line(repmat(cr.Xstart,2,1)				,YL,'Color',[.8 .8 .8],'LineStyle','--');
	line(repmat(cr.Xstart+cr.Xspan+1,2,1)	,YL,'Color',[.8 .8 .8],'LineStyle','--');
end

% plot crane positions
plot(craneposX,craneposY);
xlabel('x');ylabel('y','Rotation',0)

% set figure limits
ylim(YL);
xlim([0 terminal_dim(1)+3]);


