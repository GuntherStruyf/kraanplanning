
clear
close all
clc

%% settings

% dt1=4;	% acceleration phase
dt2=5;		% maximum velocity phase
% dt3=4;	% deceleration phase
v0=2;	% starting velocity
a=1;	% maximum acceleration/deceleration

vmax=5;	% maximum velocity

%% calculations

dt1=(vmax-v0)/a;
dt3=vmax/a;

% integrating velocity and acceleration to determine travel
dx1=v0*dt1+a*dt1^2/2;
dx2=vmax*dt2;
dx3=a*dt3^2/2;
dx=dx1+dx2+dx3;

vtop=vmax;

% total time
dt=dt1+dt2+dt3;

t = [0 dt1 dt1+dt2 dt1+dt2+dt3];
v=[v0 vtop vtop 0];

%% plot velocity

figure
plot(t,v,'LineWidth',2);

XL = [min(t)-dt/10 max(t)+dt/10];
YL = [min([0 v0]-vtop/10) max([vtop v0]+vtop/10)];

% mark lines
clr = .35*[1 1 1]; % [.8 .8 .8]
line( XL,			[0 0]		,'Color',clr,'LineStyle','--');
line([XL(1) dt1],	[vtop vtop]	,'Color',clr,'LineStyle','--');
line([XL(1) 0],		[v0 v0]		,'Color',clr,'LineStyle','--');
line([0 0],			[YL(1) v0]	,'Color',clr,'LineStyle','--');
line([dt1 dt1],		[YL(1) vtop],'Color',clr,'LineStyle','--');
line([dt1 dt1],		[YL(1) vtop],'Color',clr,'LineStyle','--');
line([dt1+dt2 dt1+dt2],[YL(1) vtop],'Color',clr,'LineStyle','--');
line([dt dt],[YL(1) 0],'Color',clr,'LineStyle','--');

% labels and ticks
set(gca,'XTick',[dt1/2 dt1+dt2/2 dt1+dt2+dt3/2 ],'XTickLabel',{'$\Delta t_1$','$\Delta t_2$','$\Delta t_3$'});
set(gca,'YTick',[0 v0 vtop],'YTickLabel',{'0','$v_0$','$v_{max}$'});
xl=xlabel('Time');
yl=ylabel('Velocity');%,'Rotation',0);

% set plot limits
xlim(XL);
ylim(YL);

% set label position
set(xl,'Position',get(xl,'Position')+[0 -0.15 0]);
set(yl,'Position',get(yl,'Position')+[0.75 0.7 0]);

matlabfrag('trunc_triangular_velocity_profile');


%% plot position

t1=0:dt1/200:dt1;
t2=[]; % because straight line
t3=0:dt3/200:dt3;
t=[t1 t2 dt1+dt2+t3];

x1=v0*t1+a*t1.^2/2;
x2=vmax*t2;
x3=dx1+dx2+vmax*t3-a*t3.^2/2;
x=[x1 x2 x3];

figure
plot(t,x,'LineWidth',2);

XL = [min(t)-dt/10 max(t)+dt/10];
YL = [-dx/20 dx+dx/20];

% mark lines
clr = .35*[1 1 1]; % [.8 .8 .8]
line( XL,				[0 0]		,'Color',clr,'LineStyle','--');
line([XL(1) dt1],		dx1*[1 1]	,'Color',clr,'LineStyle','--');
line([XL(1) dt1+dt2],(dx1+dx2)*[1 1],'Color',clr,'LineStyle','--');
line([XL(1) dt],		[dx dx]		,'Color',clr,'LineStyle','--');

line([0 0],				YL				,'Color',clr,'LineStyle','--');
line([dt1 dt1],			[YL(1) dx1]		,'Color',clr,'LineStyle','--');
line((dt1+dt2)*[1 1],	[YL(1) dx1+dx2]	,'Color',clr,'LineStyle','--');
line([dt dt],			[YL(1) dx]		,'Color',clr,'LineStyle','--');

% labels and ticks
set(gca,'XTick',[dt1/2 dt1+dt2/2 dt1+dt2+dt3/2 ],'XTickLabel',{'$\Delta t_1$','$\Delta t_2$','$\Delta t_3$'});
set(gca,'YTick',[0 dx1/2 dx1+dx2/2 dx1+dx2+dx3/2],'YTickLabel',{'0','$\Delta x_1$','$\Delta x_2$','$\Delta x_3$'});
xl=xlabel('Time');
yl=ylabel('Position');%,'Rotation',0);

% set plot limits
xlim(XL);
ylim(YL);

% set label position
set(xl,'Position',get(xl,'Position')+[0 -0.85 0]);
set(yl,'Position',get(yl,'Position')+[1.25 0.7 0]);

matlabfrag('position_limited');
