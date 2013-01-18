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
sprintf('%s', 'Enter begin of the way: \n');

% Параметры измерительной хорды
chordtail=5.185;
chordhead=10.6;
%a=sync();
%chordtail=a(2)
%chordhead=a(1)-chordtail
chord=chordtail+chordhead;

% Измерение стрел проекта
arrows=-versine(x, y, chordhead, chordtail);

m=length(arrows)

% Наложение шумов
xr=x+100*makenoise(size(x));
yr=y+100*makenoise(size(y));

% Измерение стрел реального пути
arrowsr=-versine(xr, yr, chordhead, chordtail);
mr=length(arrowsr)

figure;
plot([1:mr]*step,arrowsr,'r');
hold on;
plot([1:m]*step,arrows,'k');

% Построение стрел по кривизне
if rem(n, 2)~=0
    v=n-1;
end

versines=c2v(c, chordhead, chordtail, step, v);

hold on;
vs=length(versines);
plot([1:vs]*step,versines,'--g');

hold on;
plot(l,chordhead*chordtail*c/2,'y');

if rem(m, 2)~=0
    m=m-1;
end

if rem(mr, 2)~=0
   mr=mr-1;
end

% Пересчет стрел в кривизну
curvature=v2c(arrows, chordhead, chordtail, step, m);

figure;
plot(l, c, 'g');
hold on;
s=length(curvature);
plot([1:s]*step,curvature,'b');

% Пересчет реальных стрел в кривизну
curvaturer=v2c(arrowsr, chordhead, chordtail, step, mr);


figure;
sr=length(curvaturer);
plot([1:sr]*step,curvaturer,'b');
hold on;
plot(l, c, 'g');

s=min(s, sr);

% Сравнение, построение графиков
figure;
plot(xr, yr, 'r');
hold on;
plot(x, y, 'k');
axis equal;

% Построение графиков
result=int2(curvaturer(1:s) - curvature(1:s), step, s);
figure;
hold on;
plot([1:s]*step,result,'k');
kor=(1:s);
[p,S] = polyfit(kor,result,1);
result=result-polyval(p,kor);
plot([1:s]*step,result,'--r');
[p,S] = polyfit(kor,result,2);
result=result-polyval(p,kor);

figure;
hold on;
plot([1:s]*step, result, 'r');
plot([1:n]*step, yr-y, '--k');

green=2*int2(arrowsr(1:m)-arrows(1:m), step, m)/(chordhead*chordtail); 
kor=(1:m);
[p,S] = polyfit(kor,green,2);
green=green-polyval(p,kor);

plot([1:m]*step, green, '-.g');

%Запись VER файла
ver.n = s;
ver.step = step;
ver.shifting = result;
ver.raising = [1:s]*0;
verwrite(ver, 'test');

start=100;
s=1000; % Общая длина пути
indices = floor((start-chord)/step);
%indices=0;
indices = indices+(1:ceil(s/step))';

prj_versines = arrows(indices); % С проектными стрелами вроде всё ок - на прямой они нулевые
%prj_versines = versines(indices+floor((chordtail)/step));

%Запись стрел в файл
mes.versine = arrowsr(indices) * 1e3;
mes.n = max(size(mes.versine));
mes.leftRaisingVersine = zeros(mes.n, 1);
mes.rightRaisingVersine = zeros(mes.n, 1);
mes.stepSize = step;
mes.level = zeros(mes.n, 1);
meswrite(mes,'test');

disp('Загрузи файлы в ALC и скопируй output.dmp');
pause;

%Приделать сюда загрузку output.dmp
%% Чтение сдвижек
%load C:\PilotZ_LS\output.dmp
load ~/.wine/drive_c/PilotZ_LS/output.dmp
output = output/1e3;
idx = round(chordhead/step):length(output);
projectVersine = output(idx-idx(1)+1,2);
shiftings = output(idx,3);

%% Выправка за счет подтягивания по методу Саши Субботина
track.x = xr(indices);
track.y = yr(indices);

% Параметры тоже передаются в структуре
parameters.lining.chordHead = chordhead;
parameters.lining.chordTail = chordtail;
parameters.stepSize = step;
%parameters.startMating = startMating;
%parameters.finishMating= finishMating;

% Проектные стрелы
task.projectVersine = prj_versines;
% Сдвижки переднего конца
task.shiftings = result(indices+floor(chordhead/step));

% Симуляция выправки пути
newTrack = plan(track, task, parameters);

% Графики
figure;
hold on;
plot(newTrack.x,newTrack.y,'k','LineWidth',2);
SF = [newTrack.info.driveStartIndex newTrack.info.driveFinishIndex];
plot(x(indices(SF)), y(indices(SF)),'Marker','hexagram','MarkerSize',5,'Color','r','LineStyle','none');
plot(x(indices),y(indices),'-k','LineWidth',1);
plot(xr(indices),yr(indices),'-.b','LineWidth',1);
%size(indices(SF))
%axis equal;

% Измерительная поездка - сравниваем стрелы:
figure;
hold on;
% Исходные
plot([1:length(arrowsr)]*step,arrowsr,'r');
% Проектные
plot([1:length(arrows)]*step,arrows,'g');
% Полученные
arrows_math=-versine(newTrack.x, newTrack.y, chordhead, chordtail);
plot(start-chord+[1:length(arrows_math)]*step,arrows_math,'k');
