% Octave не воспринимает синтаксис %{ ... %} поэтому использую просто %
close all;
clear all;
format long;  

step=0.25;
%step=1e-2;
way=waygen(step, 3);

x=way.x;
y=way.y;
l=way.l;
c=way.c;
n=way.n;

% Диалог выяснение начала пути
%sprintf('%s', 'Enter begin of the way: \n');

% Параметры измерительной хорды
chordtail=5.185;
chordhead=10.6;
%a=sync();
%chordtail=a(2)
%chordhead=a(1)-chordtail
chord=chordtail+chordhead;

% Наложение шумов
xr=x+100*makenoise(size(x));
yr=y+100*makenoise(size(y));

% Генерация продольного профиля
zr=100*makenoise(size(x));

% Расчёт проектных стрел
versines=c2v(c, chordhead, chordtail, step, n);

figure;
hold on;
vs=length(versines);
plot(l, chordhead*chordtail*c/2, 'k');
plot([1:vs]*step, versines, '--r');

% Расчёт натурной кривизны
curvature=w2c(xr, yr, step, n);

% Сравнение кривизн
figure;
hold on;
plot([1:n]*step, curvature, 'b');
plot([1:n]*step, c, 'g');

% Расчёт сдвижек
%%{
result=int2(curvature - c, step, n);
figure;
hold on;
plot([1:n]*step, result, 'k');
kor=(1:n);
[p,S] = polyfit(kor, result, 1);
result=result-polyval(p, kor);
plot([1:n]*step, result, '--r');
[p,S] = polyfit(kor, result, 2);
shiftings=result-polyval(p, kor);
%%}

%shiftings=(xx.^2+y.^2).^0.5

figure;
hold on;
plot([1:n]*step, shiftings, 'r');
plot([1:n]*step, yr-y, '--k');

%Запись VER файла
ver.n = n;
ver.step = step;
ver.shifting = result;
ver.raising = -zr;
verwrite(ver, 'test');

start=100;
s=1000; % Общая длина пути
indices = floor((start-chord)/step);
%indices=0;
indices = indices+(1:ceil(s/step))';

% Построение "красной линии"
[xn, yn]=redline(xr, yr, step, -shiftings', n);
figure;
hold on;
plot(xn, yn, 'r');
plot(xr, yr, 'b');
plot(x, y, 'k');

disp('Загрузи файлы ALC в Пилот и создай output.dmp');
pause;

%Приделать сюда загрузку output.dmp
%% Чтение сдвижек
%load C:\PilotZ_LS\output.dmp
load ~/.wine/drive_c/PilotZ_LS/output.dmp
md=output(1, 1);
output = output/1e3;
%idx = round(chordhead/step):length(output);
idx = 1:length(output);
md
chordtail+chordhead-md
%projectVersine = output(idx-idx(1)+1,2);
projectVersine = output(idx, 2);
shiftings = output(idx, 3);
raisings_left = output(idx, 4);
raisings_right = output(idx, 5);
level = output(idx, 6);

% Построение графиков из output.dmp
figure;
hold on;
plot((idx-1)*step+md, projectVersine, 'r');
plot((idx-1)*step+md, shiftings, 'y');
plot((idx-1)*step+md, raisings_left, 'c');
plot((idx-1)*step+md, raisings_right, 'm');
plot((idx-1)*step+md, level, 'k');

% Наложение графиков и пути
figure;
hold on;
plot(xr, yr, 'b');
plot([1:n]*step, zr, '--b');
plot([1:n]*step, c, 'g');
plot((idx-1)*step+md, projectVersine, 'r');
plot((idx-1)*step+md, shiftings, 'y');
plot((idx-1)*step+md, raisings_left, 'c');
plot((idx-1)*step+md, raisings_right, 'm');
plot((idx-1)*step+md, level, 'k');
