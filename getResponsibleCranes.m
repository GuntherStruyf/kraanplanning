function crane_idx = getResponsibleCranes( x, cranes )
%GETRESPONSIBLECRANES return the cranes who can serve the specified x position
	N = numel(x);
	crane_idx{N}=[];
	for i = 1:length(cranes)
		sp = cranes(i).Xstart+(0:cranes(i).Xspan-1);
		val = ismember(x,sp);
		for j = 1:N
			if val(j)
				crane_idx{j} = [crane_idx{j} i];
			end
		end
	end
	
end

