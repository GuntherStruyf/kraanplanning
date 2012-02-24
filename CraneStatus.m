classdef (Enumeration) CraneStatus < int32
	enumeration
		statDisabled			(0)
		statWaitingForOrders	(1)
		statWorking				(2)
	end
end
