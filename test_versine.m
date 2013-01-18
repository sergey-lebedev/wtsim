% Octave не воспринимает синтаксис %{ ... %} поэтому использую просто %
close all;
clear all;
format long;  

step=0.25;
%step=1e-1;
NUMBER_OF_CIRCLES=3;
way=waygen(step, NUMBER_OF_CIRCLES);

x=way.x;
y=way.y;
l=way.l;
c=way.c;
n=way.n;
sections=way.s;

% Параметры измерительной хорды
chordtail=5.185;
chordhead=10.6;
%chordtail=5;
%chordhead=10.01;
chord=chordtail+chordhead;

% Измерение стрел проекта
arrows=-versine(x, y, chordhead, chordtail);


figure;
plot([1:length(arrows)]*step, arrows, 'r');
