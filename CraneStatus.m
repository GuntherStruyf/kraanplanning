classdef (Enumeration) CraneStatus < int32
	enumeration
		Disabled			(0)			% disabled
		AwaitingOrders		(1)			% waiting for orders
		MoveToOrigin		(2)			% move to origin
		MoveToDestination	(3)			% move to destination
		LoadingContainer	(4)			% picking up a container
		UnloadingContainer	(5)			% putting a container down
		AwaitingExecOrderClearance	(6)	% waiting till prior task in the execution order are finished
		AwaitingOriginClearance		(7)	% waiting till the area to the origin is unclaimed
		AwaitingDestinationClearance(8)	% waiting till the area to the destination is unclaimed
	end
end
