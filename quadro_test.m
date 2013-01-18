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

cr=w2c(xr, yr, step, n);

ytr=int2(cr, step, n);

figure;
plot(l, ytr, 'b');
hold on;
plot(l, yt, 'k');

[curvature, shiftings]=quadro(sections, [], ytr', step, -1);

figure; 
plot(l, cr, 'g');
hold on;
plot(l, cc, 'k');
hold on;
plot(sections, curvature, '-b');

[xn, yn]=redline(xr, yr, step, shiftings, n);

figure;
plot(xn, yn, 'g');
hold on;
plot(xr, yr, 'r');
hold on;
plot(x, y, 'k');
