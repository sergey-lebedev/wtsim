% Octave не воспринимает синтаксис %{ ... %} поэтому использую просто %
close all;
clear all;
format long;  

step=0.25;
%step=1e-1;
way=waygen(step, 3);

x=way.x;
y=way.y;
l=way.l;
cc=way.c;
n=way.n;
yt=way.yt;
sections=way.s;

%Генерация шумов
xr=x+1*100*makenoise(size(x));
yr=y+1*100*makenoise(size(y));
tic;
cr=w2c(xr, yr, step, n)
toc;
tic;
ytr=int2(cr, step, n)
toc
figure;
plot(l, ytr, 'b');
hold on;
plot(l, yt, 'k');
tic;
curvature=quadro(sections, ytr, step, -1)
toc
figure; 
plot(l, cr, 'g');
hold on;
plot(l, cc, 'k');
hold on;
plot(sections, curvature, '-b');
tic;
[xn, yn]=c2w(cr, step, xr(1), yr(1), 0, n);
toc
figure;
plot(xn, yn, 'g');
hold on;
plot(xr, yr, 'r');
hold on;
plot(x, y, 'k');
