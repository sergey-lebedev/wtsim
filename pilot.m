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

% Диалог выяснение начала пути
%sprintf('%s', 'Enter begin of the way: \n');

% Параметры измерительной хорды
% Здесь должно быть чтение ini файла
chordtail=5.185;
chordhead=10.6;
%chordtail=5;
%chordhead=10.01;
chord=chordtail+chordhead;

% Измерение стрел проекта
arrows=-versine(x, y, chordhead, chordtail);

m=length(arrows)

% Наложение шумов
xr=x+1*100*makenoise(size(x));
yr=y+1*100*makenoise(size(y));

% Измерение стрел реального пути
arrowsr=-versine(xr, yr, chordhead, chordtail);
mr=length(arrowsr)

figure;
plot([1:mr]*step,arrowsr,'r;Real versines;');
hold on;
plot([1:m]*step,arrows,'k;Project versines;');

% Построение стрел по кривизне
if rem(n, 2)~=0
	v=n-1;
end

versines=c2v(c, chordhead, chordtail, step, v);

hold on;
vs=length(versines);
plot([1:vs]*step,versines,'--g;Versines;');
hold on;
plot(l,chordhead*chordtail*c/2,'y;Simple versines;');

%Нереальная кривизна
%figure;
%plot(l, chordhead*chordtail*c/2, 'k');
%hold on;
%tt=v2c(chordhead*chordtail*c'/2, chordhead, chordtail, step, size(c));
%size(l)
%size(tt)
%plot([1:max(size(tt))]*step, tt, 'r');

if rem(m, 2)~=0
	m=m-1;
end

if rem(mr, 2)~=0
	mr=mr-1;
end

% Пересчет стрел в кривизну
curvature=v2c(arrows, chordhead, chordtail, step, m);

figure;
plot(l, c, 'g;Project curvature;');
hold on;
s=length(curvature);
plot([1:s]*step,curvature,'b;Curvature from versines;');

% Пересчет реальных стрел в кривизну
curvaturer=v2c(arrowsr, chordhead, chordtail, step, mr);

figure;
sr=length(curvaturer);
plot([1:sr]*step,curvaturer,'b;Real curvature;');
hold on;
plot(l, c, 'g;Project curvature;');
hold on;
%breaks=polysec(sections, c, step, 1)
%plot(sections, breaks, '-*r');
breaks=polysec([[sections(1:end-1)]; mr*step], curvaturer, step, 1);
plot([[sections(1:end-1)]; mr*step], breaks, '-*r;Sections;');

s=min(s, sr);

% Сравнение, построение графиков
figure;
plot(xr, yr, 'r;Initial way;');
hold on;
plot(x, y, 'k;;');
axis equal;

green=2*int2(arrowsr(1:m)-arrows(1:m), step, m)/(chordhead*chordtail); 
kor=(1:m)';
[p,S] = polyfit(kor,green,2);
green=green-polyval(p,kor);

plot([1:m]*step, green, '-.g');

yt=v2yt(arrowsr, chordhead, chordtail, step, m)-v2yt(arrows, chordhead, chordtail, step, m);
hold on;

kor=(1:m)';
[p,S] = polyfit(kor,yt,2);
yt=yt-polyval(p,kor);

plot([1:m]*step, yt, '-y');

start=100;
s=1000; % Общая длина пути
indices = floor((start-chord)/step);
%indices=0;
indices = indices+(1:ceil(s/step));

%prj_versines = arrows(indices); % С проектными стрелами вроде всё ок - на прямой они нулевые
%prj_versines = versines(indices+floor((chordtail)/step));
versines=c2v_shft(c, chordhead, chordtail, step, v);
prj_versines = versines(indices);

%%{
%Запись стрел в файл
mes.versine = arrowsr(indices) * 1e3;
mes.n = max(size(mes.versine));
mes.leftRaisingVersine = zeros(mes.n, 1);
mes.rightRaisingVersine = zeros(mes.n, 1);
mes.stepSize = step;
mes.level = zeros(mes.n, 1);
meswrite(mes,'test');
%%}

%Приделать сюда загрузку output.dmp
disp('Process test.mes file and press any key.');
pause;
%% Чтение сдвижек
%load C:\PilotZ_LS\output.dmp
load ~/.wine/drive_c/PilotZ_LS/output.dmp
output = output/1e3;
idx = round(chordhead/step):length(output);
projectVersine = output(idx-idx(1)+1,2);
size(projectVersine)
shiftings = output(idx,3);
size(shiftings)
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
task.projectVersine = projectVersine;
% Сдвижки переднего конца
%task.shiftings = shiftings(indices+floor(chordhead/step));
task.shiftings = shiftings;

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
% c2w
[c2wx, c2wy]=c2w(curvature, step, 0, 0, 0, length(curvature));
plot(c2wx(indices), c2wy(indices), 'g');
% "Красная линия"
[rlx, rly]=redline(xr(indices+floor(chord/step)+1), yr(indices+floor(chord/step)+1), step, -shiftings, length(shiftings));
plot(rlx, rly, 'r');
%size(indices(SF))
%axis equal;

% Измерительная поездка - сравниваем стрелы:
figure;
hold on;
% Исходные
plot([1:length(arrowsr)]*step,arrowsr,'r;Initial versines;');
% Проектные
plot([1:length(arrows)]*step,arrows,'g;Project versines;');
% Полученные
arrows_math=-versine(newTrack.x, newTrack.y, chordhead, chordtail);
plot(start-chord+[1:length(arrows_math)]*step,arrows_math,'k;Final versines;');
