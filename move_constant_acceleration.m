function [isArrival pos vel] = move_constant_acceleration( pos,vel,dt,vmax,amax, pos_dest )
%MOVE_CONSTANT_ACCELERATION move_constant_acceleration( pos,vel,dt,vmax,amax, pos_dest )
% move to a destination with constant acceration/deceleration
%
%	respect maximum velocity, move as fast as possible
%	this function returns the position, velocity and arrival state for one
%	time step dt

	dx = pos_dest-pos;
	if dx~=0 || vel~=0
		if dx<0
			% code below works with positive distance and velocity, so just
			% 'flip' everything, pass it again, and 'flip' the results back
			[isArrival pos vel]=move_constant_acceleration(-pos,-vel,dt,vmax,amax,-pos_dest);
			pos=-pos;
			vel=-vel;
		else
			% when assuming triangular velocity profile: vtop = top velocity
			% equals the following (do the math if you don't believe me ;) )
			vtop = sqrt(dx*amax+vel^2/2);
			vnew=vel+amax*dt;
			if vnew<vtop && vnew<vmax
				pos=pos+vel*dt+amax*dt^2/2;
				vel=vnew;
			else
				if vtop>=vmax
					% we first run into vmax
					dt1 = (vmax-vel)/amax; % how long does it take until vmax?
					% dt_rise should be smaller than dt, otherwise we couldn't
					% have reached this code
					dx1=(vel+vmax)/2*dt1; % trapezoidal integration approximation
					dx3=vmax^2/2/amax;
					dx2=dx-dx1-dx3;
					dt2=dx2/vmax;
					dt_rest = dt-dt1-dt2;
					if dt_rest>0 % already lowering velocity, we've passed the top
						pos=pos+dx-dx3+(vmax-amax*dt_rest/2)*dt_rest; % trapezoidal integration approximation
						% +dx1+dx2 = +dx-dx3
						vel=vmax-dt_rest*amax;
					else
						pos = pos+dx1+vmax*(dt-dt1);
						vel = vmax;
					end
				else
					% it'll be vtop -> no constant (=vmax) velocity phase
					dt1 = (vtop-vel)/amax; % how long does it take until vtop?
					if dt1<1e-9
						dt1=0;
					end
					dx1=(vel+vtop)/2*dt1; % trapezoidal integration approximation
					dt_rest=dt-dt1;
					dx2=(vtop-amax*dt_rest/2)*dt_rest; % trapezoidal integration approximation
					if dx-dx1<dt_rest*vtop/2 && vtop/amax<1
						pos=pos_dest;
						vel=0;
					else
						pos = min(pos+dx1+dx2,pos_dest);
						vel=max(vtop-dt_rest*amax,0);
					end
				end
			end
		end
	end
	isArrival=(abs(pos-pos_dest)<1e-5);
	if isArrival
		vel=0;
		pos=pos_dest;
	end
end