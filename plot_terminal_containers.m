function plot_terminal_containers( terminal )
%PLOT_ALL_CONTAINERS plot all the containers in the terminal

	[tmp,C] = ismember(1:max(max(max(terminal))),terminal);
	[pos(:,1) pos(:,2) pos(:,3)] = ind2sub(size(terminal),C);
	scatter3(pos(:,1),pos(:,2),pos(:,3),75,pos(:,3),'filled');
	xlim([0 size(terminal,1)+1]);
	ylim([0 size(terminal,2)+1]);
	zlim([1 size(terminal,3)+1]);
	title('terminal');
end