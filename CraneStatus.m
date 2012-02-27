classdef (Enumeration) CraneStatus < int32
	enumeration
		Disabled			(0)
		AwaitingOrders		(1)
		MoveToOrigin		(2)
		MoveToDestination	(3)
		HandlingContainer	(4)
	end
end
