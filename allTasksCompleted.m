function retval = allTasksCompleted(tasks)
%ALLTASKSCOMPLETED determine if all tasks are completed
	retval=true;
	for t=tasks
		if t.status~=TaskStatus.Completed
			retval=false;
			return
		end
	end
end
