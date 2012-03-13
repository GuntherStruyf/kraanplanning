function retVal = ValidateExecOrder(task_index, tasks,exec_order)
%VALIDATEEXECORDER check if prior tasks are finished

	% get the indices of pairs in the exec_order where task_index is the
	% latter of one pair
	pre_idx = find(exec_order(:,2)==task_index);
	% check if all prior tasks are finished
	retVal=true;
	for i=1:numel(pre_idx)
		if tasks(exec_order(1,pre_idx(i))).status~=TaskStatus.Completed
			retVal=false;
			break;
		end
	end
end