function terminal = populate_terminal( dim,N)
%FILL_TERMINAL randomly fill a terminal with stacked containers
%	of course, gravity applies, so underneath each container there is
%	another one or ground level.
%	
%	dim:	dimensions of the terminal, a 1x3 vector, consisting of:
%				*	length of the terminal (this is the crane side)
%				*	width of the terminal
%				*	maximum height = maximum number of stacked containers
%	N:		number of containers to populate the terminal with

	% first check if this population is feasible
	M=prod(dim); % we use this again later
	if M<N
		error('Can''t fit that many containers in this dimensions');
	end
	terminal = [1:N zeros(1,M-N)];		% N integers, followed by zeros
	terminal = terminal(randperm(M));	% shuffled above
	terminal = reshape(terminal,dim);		% reshape to dim
	
	% some containers are possibly 'floating' now, let's drop those
	for j=1:dim(1)
		for k=1:dim(2)
			stack = squeeze(terminal(j,k,:));
			stack(stack==0)=[];
			terminal(j,k,:)=[stack ;zeros(dim(3)-length(stack),1)];
		end
	end
end