function task_space = create_taskspace(x1, x2)
%CREATE_TASKSPACE return the span between x1 and x2
	if x1>x2
		task_space=create_taskspace(x2,x1);
	else
		task_space = floor(x1):ceil(x2);
	end
end

