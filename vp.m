% Octave не воспринимает синтаксис %{ ... %} поэтому использую просто %
close all;
clear all;
format long;  

step=0.25;
%step=1e-2;
NUMBER_OF_CIRCLES=1;
way=waygen(step, NUMBER_OF_CIRCLES);

x=way.x;
y=way.y;
l=way.l;
c=way.c;
n=way.n;
sections=way.s;

% Lining chord parameters
chordtail=5.185;
chordhead=10.6;
chord=chordtail+chordhead;

% Noise generation in plan
xr=x+100*makenoise(size(x));
yr=y+100*makenoise(size(y));

% Noise generation in profile
zr=100*makenoise(size(x));

% Project versines computing 
versines1=c2v_shft(c, chordhead, chordtail, step, n);
versines2=c2v(c, chordhead, chordtail, step, n);

% Real versines computing
versines=-versine(xr, yr, chordhead, chordtail);

% Noise addend to versines
verr=0*ones(length(versines), 1);
%rand(1, length(versines))
versines=versines+0.001*(rand(length(versines), 1)-0.5)+verr;

%pause;
% Compare project and real versines
figure;
hold on;
plot([1:length(versines)]*step, versines, 'r;Real versines;');
plot(l,chordhead*chordtail*c/2,'y;Simple versines;');
plot([1:length(versines1)]*step, versines1, '-b;Laplass versines with shifthing;');
plot([1:length(versines2)]*step, versines2, '-g;Project versines;');

% Transforming versines in curvature
%curvature=c;
curvature=v2c(versines, chordhead, chordtail, step, length(versines));
size(curvature)
% Or transforming way in curvature
curvature=w2c(xr, yr, step, n);
size(curvature)

% Compare project and real curvatures
figure;
hold on;
plot([1:length(curvature)]*step, curvature, 'b;Curvature from versines;');
plot(l, c, 'g;Project curvature;');

% Sectioning way by curvatures
breaks=polysec([[sections(1:end-1)]; length(curvature)*step], curvature, step, 1);
plot([[sections(1:end-1)]; length(curvature)*step], breaks, '-*r;polysec;');

% Optimisation of sections
%Use sqp. See page 346 of GNU Octave Manual Version 3.


% Use that sectioning as initial condition in quadro
yt=int2(curvature, step, length(curvature));
sections
size(sections)
breaks
size(breaks)
size(yt)
[qcurvature, shiftings]=quadro(sections, breaks, yt, step, 1);

% Plot curvatures
figure; 
hold on;
plot(l, curvature, 'b;Curvature from versines;');
plot(l, c, 'g;Project curvature;');
plot(sections, qcurvature, '-xr;quadro;');

% Use shiftings without constraints and simulation
[xn, yn]=redline(xr, yr, step, shiftings, n);

figure;
%axis 'square';
hold on;
plot(xr, yr, 'b');
plot(xn, yn, 'r');
plot(x, y, 'k');

% Fixed sections generator
% Include it in the waygen

% Apply constraints
ub=0.1*ones(1, n);
lb=-ub;
residual=zeros(1,n);

fitted = fit_to_constraints(shiftings, lb, ub, residual, n, 1e-5);

%Compare shiftings
%figure;
%hold on;
%plot([1:length(lb)]*step, lb, 'k');
%plot([1:length(ub)]*step, ub, 'k');
%plot([1:length(shiftings)]*step, shiftings, 'b;Shiftings;')
%plot([1:length(fitted)]*step, fitted, 'm;Fitted;')

% Use constrained shiftings without simulation
[xc, yc]=redline(xr, yr, step, fitted, n);

figure;
%axis 'square';
hold on;
plot(xr, yr, 'b');
plot(xn, yn, 'r');
plot(xc, yc, '-r');
plot(x, y, 'k');

% Lining sumulation
% Part from test.m

%% Измерительная поездка - compare versines:
figure;
hold on;
% Initial versines
plot([1:length(versines)]*step, versines, 'r;Initial versines;');
% Project versines
plot([1:length(versines2)]*step, versines2, 'g;Project versines;');
% Final versines
arrows_math=-versine(xc, yc, chordhead, chordtail);
%arrows_math=-versine(xr, yr, chordhead, chordtail);
plot([1:length(arrows_math)]*step, arrows_math, 'k;Final versines;');
