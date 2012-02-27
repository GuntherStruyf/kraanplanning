classdef (Enumeration) TaskStatus < int32
	enumeration
		Awaiting	(0)
		InProgress	(1)
		Completed	(2)
	end
	methods
		function s=toString(obj)
			switch obj
				case TaskStatus.Awaiting
					s='Awaiting';
				case TaskStatus.InProgress
					s='In progress';
				case TaskStatus.Completed
					s='Completed';
			end
		end
	end
end
