function [loadoff, loadon, arrivalTime] = create_tasks( Ntrucks, Ncontainers, maxArrivalTime )
%CREATE_TASKS randomly create a set of tasks
%	
%	Ntrucks:		number of trucks
%	Ncontainers:	number of containers in the terminal (needed for
%					non-inferencing containernumbers.
%	maxArrivalTime:	The maximum value for 'arrivalTime'
%	loadoff:		Nx1 vector, contains for each truck, the containerindex
%					(> Ncontainers) to offload. a zero represents no
%					dropoff = empty truck.
%	loadon:			Nx1 vector, contains for each truck, the containerindex
%					(<=Ncontainres) to load on the truck. A zero represents
%					no load.
%	arrivalTime:	Nx1 vector, contains for each truck, the time in
%					seconds (since beginning of task execution) at which
%					the truck arrives. For simplicity's sake this
%					vector is sorted in ascending order.
	
	r = randint(1,1,Ntrucks); % number of trucks to offload
	loadoff = [Ncontainers+[1:r] zeros(1,Ntrucks-r)]; % 1,2,3,..,r,0,0,0,..
	loadoff = loadoff(randperm(Ntrucks))'; % shuffle and add Ncontainers
	
	cont=1:Ncontainers;
	loadon = zeros(Ntrucks,1);
	r=randint(Ntrucks,1,Ncontainers)+1;
	for i = 1:Ntrucks
		loadon(i)=cont(r(i));
		cont(r(i))=0;
	end
	loadon = loadon(randperm(Ntrucks));
	
	arrivalTime = sort(floor(maxArrivalTime*rand(1,Ntrucks)));
end