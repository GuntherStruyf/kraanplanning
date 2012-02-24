function Ncontainers = countContainers( terminal )
%COUNTCONTAINERS count all the number of containers in a given matrix
%representation of a terminal
	Ncontainers = sum(sum(sum(terminal~=0)));
end

