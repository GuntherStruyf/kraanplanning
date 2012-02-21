function plot_task_containers( loadon, terminal, Ncranes,crane_overlap)
%DISPLAY_TASK_CONTAINERS plot the positions of the loadon containers +
% boundaries of crane_areas
	
	% width of the working area of one crane
	terminal_dim=size(terminal);
	crane_area = (terminal_dim(1) - crane_overlap)/Ncranes+crane_overlap;
% 	lb = 1+(i-1)*(crane_area-crane_overlap);
% 	ub = i*(crane_area-crane_overlap)+crane_overlap;
	
	[tmp,C] = ismember(loadon,terminal);
	[loadon_pos(:,1) loadon_pos(:,2) loadon_pos(:,3)] = ind2sub(size(terminal),C);
	% set empty tasks (load container 0) as assigned=true
	loadon_pos(loadon==0,:)=[];
	% plot
	scatter3(loadon_pos(:,1),loadon_pos(:,2),loadon_pos(:,3),75,loadon_pos(:,3),'filled');
	xlim([0 terminal_dim(1)+1]);
	ylim([0 terminal_dim(2)+1]);
	zlim([1 size(terminal,3)+1]);	
end
