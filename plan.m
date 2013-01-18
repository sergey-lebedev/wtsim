%Симуляция работы машины в плане
function track = plan(track,task,parameters)
tic;
format long;
% натурное положение пути
X = [track.x(:) track.y(:)];

% параметры
chordHead = parameters.lining.chordHead;
chordTail = parameters.lining.chordTail;
stepSize = parameters.stepSize;

base = chordHead + chordTail;

shiftings = task.shiftings;

projectVersine = task.projectVersine;

rmin=0;
rmax=0;
pmax=0;

% графики

%{
%ylim = [min(X(:,2)) max(X(:,2))];
%if (ylim == [0 0])
%	ylim = [-1 1];
%end
ylim = ylim+[-1 1]*diff(ylim)/20;
%}
ylim=[-0.1 0.1];

% положение рихтовочной тележки
rear = 1;
front = find(sum((X-X(ones(size(X(:,1))),:)).^2,2)>=base^2,1,'first');

% длина пройденного пути
pathLength = [0; cumsum(sqrt(sum(diff(X).^2,2)))];
pathLength = pathLength-pathLength(front);

% рабочий цикл
ldrive = rear+1;
mating_coe = [];
n=length(shiftings)

f1=0; f2=0;
%Генератор "красных линий"
figure;
plot(X(:, 1), X(:, 2), 'b;Initial way;');
hold on;
plot(X(1, 1)+base+[1:n]*stepSize, shiftings, 'g;Shiftings;');

%Для рихтовки
base/stepSize
n-ceil(base/stepSize)
size(X)
size(shiftings)
for j=1:n-ceil(base/stepSize)
	Pl(j)=X(j+ceil(base/stepSize),2)-shiftings(j);
end

for j=n-ceil(base/stepSize):n
	Pl(j)=X(j,2);
end

hold on;
plot(X(1, 1)+base+[1:n]*stepSize, Pl, 'r;Way + Shiftings;');
%return;
%h=figure;
k=2;
mcp=0;
for taskIndex = 1:n
    
	%%Симуляция для рихтовки 
	while norm(X(front,:)-X(rear,:)) > base, rear = rear+1; end
    
	A=X(rear, :);
    
	%Находим точку, превосходящую конечную
	for j=k:n
		if (sum((A-X(j, :)).^2)>base*base)	
			k=j;
            	break; 
		end;	
	end

	%Пересечение конца хорды и пути
	P=X(k-1, :);
	Q=X(k, :);

	a=A-P;
	c=Q-P;
	b=a*c';
	d=c*c';
	alpha=(b+sqrt( b*b-d*((a*a')-base*base) ) )/d; %Проблема была здесь
	B=P*(1-alpha)+Q*alpha;
    
	% положение ПРУ
	origin=(B*chordTail+A*chordHead)/base;
    
	%Направляющий вектор хорды
	chord=B-A;
	versineOrth = -[chord(2) -chord(1)]/base;
    
	% Поиск точки пути ближайшей к пересечению препендикуляра от ПРУ и пути не используя FIND
	s = -1;
	for ldrive = rear:front-1
		W = origin-X(ldrive,:);
		U = X(ldrive+1,:)-X(ldrive,:);
        	s = -(W*chord')*(chord*(W-U)');
        	if (s>=0), break; end;
	end
    
	if taskIndex == 1
		track.info.driveStartIndex = ldrive;        
	end
    
	%Расстояние от ПРУ до пути
	%LININGVERSINE = X(ldrive, :) - origin
	LININGVERSINE=base*(W(1)*U(2)-U(1)*W(2))/(U*chord')*versineOrth;
	liningVersine=norm(LININGVERSINE);
    
	% задатчик для рихтовки
	taskVersine = -(shiftings(taskIndex)*chordTail/base+projectVersine(taskIndex));
    
	%shiftings(taskIndex)*chordTail/base
	%projectVersine(taskIndex)
	taskVersine*versineOrth;
	% перемещение РШР / оценка
	delta = taskVersine*versineOrth - LININGVERSINE;
     
	if (sign(delta(:,2))>0)
		%Максимальная сдвижка ПРУ при рихтовке
		if (rmax<norm(delta)) rmax=norm(delta);
		end 
	else
		%Минимальная сдвижка ПРУ при рихтовке
		if (rmin>-norm(delta)) rmin=-norm(delta);
        	end
    	end
        
	% перемещение РШР / работа
	ldrive;
	X(ldrive, :) = X(ldrive, :)+delta;

	% СГЛАЖИВАНИЕ!!! В результате того что неверно моделизуется перемещение
	% РШР при выправке, для того чтобы результат был хоть сколько либо
	% адекватный приходиться производить сглаживание
	%X(rear+1:ldrive,1) = smooth(X(rear+1:ldrive,1),5);
	%X(rear+1:ldrive,2) = smooth(X(rear+1:ldrive,2),5);

	% картинки
	%График для рихтовки
	%{
	%clf;
	%maxIndex = min(front+(front-rear)*3,length(X));
	%minIndex = max(1,rear-(front-rear)*3);
	%Положение пути после выправки
	%hold on;
	%plot(X(minIndex:maxIndex,1),X(minIndex:maxIndex,2));   
	%Проектируемое положеине пути - "красная линия"
	%hold on;
	%plot(X(minIndex:maxIndex,1),Pl(minIndex:maxIndex), 'r');
	%Сдвижки переднего конца в данной точке    
	%hold on;
	%plot(X(minIndex:maxIndex,1),shiftings(minIndex:maxIndex), 'g');
    
	%Xx = taskVersine*versineOrth+origin;
	%Xf = B-shiftings(taskIndex)*versineOrth;
	%Передняя точка хорды - зелёная
	%plot(B(1), B(2),'o g');
	%Задняя - красная
	%plot(A(1), A(2),'o r');
	%line([A(1) B(1)],[A(2) B(2)]);
	%Центр хорды 
	%plot(origin(1), origin(2),'+ k');
	%Положение ПРУ    
	%plot(Xx(1), Xx(2),'x k');
	%Положение, в которое сдвигается передний конец - должно совпадать с "красной линией"   
	%plot(Xf(1), Xf(2),'* k');
	%plot(X(rear:front,1),X(rear:front,2),'k -.');
	%set(gca,'YLim',ylim);
	%drawnow;
	%pv=projectVersine(taskIndex);
	%if (pv~=0)
	%	pv;
	%	   sqrt(sum((Xx-origin).^2));
	%  %v=-versine(X([rear:front+1],1), X([rear:front+1],2), chordHead, chordTail)
	%  %v(1)
	%end;
    	%}
    
	%Заплатка на пропуск и повтор значений
	if (mcp~=0)
        	if (mcp<(ldrive-1))
            		i=ldrive-1-mcp;
			for j=1:i
				X(ldrive-j, :)=X(ldrive-j, :)+delta;
            		end
		end;
		if (mcp==ldrive) X(ldrive, :)=X(ldrive, :)-delta; end;
	end;
	mcp=ldrive;
    
	% положение переднего конца рихт. х.
	while pathLength(front)<(taskIndex)*stepSize & front<length(X), front = front+1; end
	if (pathLength(front)<(taskIndex)*stepSize) break; end

end

track.info.driveFinishIndex = ldrive;

% результаты
track.x = X(:,1);
track.y = X(:,2);
toc
