function out = getTypes(varargin)
% get name of types of arguments
	out = '';
	for i=1:nargin
		if i==1
			out = getType(varargin{i});
		else
			out = [ out ', ' getType(varargin{i}) ];
		end
	end
end
function out = getType(var)
	s = size(var);
	if max(s) ==1
		out = class(var);
	elseif min(s)==1 && length(s)==2
		out = [ class(var) '[' int2str(max(s)) ']'];
	
	else
		out = [ class(var) '[' ];
		for i=1:length(s)
			if i ==1
				out = [out num2str(s(i))];
			else
				out = [out 'x' num2str(s(i))];
			end
		end
		out = [out ']'];
	end
end
