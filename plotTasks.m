function plotTasks(tasks)
%% PLOTTASKS
%for each tasks: plot a line connecting the origin and destination
	
	if ~isempty(tasks)
		if ~isa(tasks(1),'Task')
			error('input is not of type Task');
		end
		figure
		hold on
		for t = tasks
			line(	[t.loc_origin.x t.loc_destination.x],...
					[t.loc_origin.y t.loc_destination.y],...
					[t.loc_origin.z t.loc_destination.z]);
		end
		title('Task movements');
	end
end