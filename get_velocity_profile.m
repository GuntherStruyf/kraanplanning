function [ t_prof pos_prof vel_prof ] = get_velocity_profile( pos,vel,dt,vmax,amax, pos_dest )
%GET_VELOCITY_PROFILE moving with maximum acceleration/deceleration:
%generate the corresponding velocity profile for moving to a destination
	Dx = pos_dest-pos;
	if Dx<0
		% code below works with positive distance and velocity, so just
		% 'flip' everything, pass it again, and 'flip' the results back
		[pos vel]=get_velocity_profile(-pos,-vel,dt,vmax,amax,-pos_dest);
		pos=-pos;
		vel=-vel;
	else
		% when assuming triangular velocity profile: vtop = top velocity
		% equals the following (do the math if you don't believe me ;) )
		vtop = min(sqrt(Dx*amax+vel^2/2),vmax);
		Dt1=(vtop-vel)/amax;
		if abs(Dt1)<10*eps 
			Dt1=0;
		end
		Dt3=vtop/amax;
		if abs(Dt3)<10*eps 
			Dt3=0;
		end
		Dx1=(vel+vtop)/2*Dt1;
		Dx3=amax*Dt3^2/2;
		Dx2=Dx-Dx1-Dx3;
		if abs(Dx2)<10*eps 
			Dx2=0;
		end
		Dt2=Dx2/vtop;
		Dt=Dt1+Dt2+Dt3;
		
		% phase 1: acceleration
		t1=0:dt:Dt1;
		if isempty(t1)
			t1=0;
		elseif t1(end)~=Dt1
			t1=[t1 Dt1];
		end
		pos1=pos+vel*t1+amax*t1.^2/2;
		vel1=vel+amax*t1;
		
		% phase 2: max velocity
		if Dt2>0
			t2=dt:dt:Dt2;
			if isempty(t2)
				t2=Dt2;
			elseif t2(end)~=Dt2
				t2=[t2 Dt2];
			end
		else
			t2=[];
		end
		pos2=pos1(end)+vtop*t2;
		vel2=vtop*ones(size(t2));
		t2=Dt1+t2;
		
		% phase 3: deceleration
		if Dt3>0
			t3=dt:dt:Dt3;
			if isempty(t3)
				t3=Dt2;
			elseif t3(end)~=Dt3
				t3=[t3 Dt3];
			end
		else
			t3=[];
		end
		if isempty(pos2)
			pos3=pos1(end)+vtop*t3-amax*t3.^2/2;
		else
			pos3=pos2(end)+vtop*t3-amax*t3.^2/2;
		end
		vel3=vtop-amax*t3;
		t3=Dt1+Dt2+t3;
		
		% combination
		t_prof=[t1 t2 t3];
		pos_prof=[pos1 pos2 pos3];
		vel_prof=[vel1 vel2 vel3];
	end
	
end

