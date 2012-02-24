function loc = findContainer( terminal, contArray )
%FINDCONTAINER retrieve the indices of specified containers in the
%specified terminal. When the container isn't found, output is zero for
%that item.
	
	tsize = size(terminal);
	Ncont = numel(contArray);
	loc = zeros(Ncont,3);
	
	% loop over all containers
	for i = 1:Ncont
		if contArray(i)~=0
			idx = find(terminal==contArray(i));
			if ~isempty(idx)
				[loc(i,1) loc(i,2) loc(i,3)] = ind2sub(tsize,idx);
			end
		end
	end
end

