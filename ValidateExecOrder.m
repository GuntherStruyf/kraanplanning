function retVal = ValidateExecOrder(task_index, tasks,ordered_taskpairs)
%VALIDATEEXECORDER check if prior tasks are finished

	% get the indices of pairs in the exec_order where task_index is the
	% latter of one pair
	pre_idx = find(ordered_taskpairs(:,2)==task_index);
	% check if all prior tasks are finished
	retVal=true;
	for i=1:numel(pre_idx)
		if tasks(ordered_taskpairs(pre_idx(i),1)).status~=TaskStatus.Completed
			retVal=false;
			break;
		end
	end
end