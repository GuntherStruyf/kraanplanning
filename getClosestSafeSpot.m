function x = getClosestSafeSpot(crane, Xclaimed, xdesired,xmin)
%GETCLOSESTSAFESPOT get a safe (non-overlapping) x position, closest to
%	xdesired
	
% 	% gather all other crane spans
% 	other_cranes_span = [];
% 	for i=1:numel(cranes)
% 		other_cranes_span = [other_cranes_span cranes(i).Xspan];
% 	end
% 	
% 	% non overlapping span of current crane is then:
% 	safe_span = setdif(cranes(crane_idx).Xspan,other_cranes_span);
% 	
% 	% now get the point closest to xdesired
% 	if xdesired> max(safe_span)
% 		x=max(safe_span);
% 	elseif xdesired<min(safe_span)
% 		x=min(safe_span;
% 	else
% 		x=xdesired;
% 	end
	
	xrange = crane.getXRange;
	unclaimed_span = xrange(~Xclaimed(xrange-xmin+1));
	xdist = abs(xdesired-unclaimed_span);
	[~, idx] = min(xdist);
	if numel(idx)>1 % if multiple minima: select the one closest to crane.x
		% in 1d, max 2 minima, in 2d minima lie on a circle
		xdist2 = abs(unclaimed_span(idx)-crane.x);
		[~, idx2] = min(xdist2);
		% in theory, if we work in 2d (future work?), there could be again
		% max 2 minima, just pick the first one, it doesn't have to be
		% _that_ complex
		idx2=idx2(1);
		% and repick the corresponding index of the first minimum
		% calculation
		idx = idx(idx2);
	end
	x=unclaimed_span(idx);
	
end