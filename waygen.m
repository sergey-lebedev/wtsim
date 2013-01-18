function way = waygen(step, nc)
%Octave не воспринимает синтаксис %{ ... %} поэтому использую просто %
format long;

P=17;
%Длины переходных кривых по СТН Ц-01-95 (Таблица 6)
curvature=[ 1/4000, 1/3000, 1/2500, 1/2000, 1/1800, ... 
            1/1500, 1/1200, 1/1000, 1/800, 1/700, ...
            1/600, 1/500, 1/400, 1/350, 1/300, ...
            1/250, 1/200    ];
%{ Тестим перевод стрел в кривизну на участках меньше длины хорды
%min_length=[1, 1, 1, 1, 1, ... 
%            1, 1, 1, 1, 1, ...
%            1, 1, 1, 1, 1, ...
%            1, 1          ];   

%max_length=[1, 1, 1, 1, 1, ... 
%            1, 1, 1, 1, 1, ...
%            1, 1, 1, 1, 1, ...
%            1, 1          ];   
%
%}
%%{     
min_length=[20, 20, 20, 20, 20, ... 
            30, 30, 40, 40, 50, ...
            50, 60, 60, 60, 80, ...
            80, 80          ];   
        
max_length=[40, 60, 80, 100, 100, ... 
            120, 140, 140, 160, 160, ...
            160, 160, 160, 140, 140, ...
            120, 100        ];       
%%}
%{
%min_length=[0, 0, 0, 0, 0, ... 
%            0, 0, 0, 0, 0, ...
%            0, 0, 0, 0, 0, ...
%            0, 0          ];   
        
%max_length=[0, 0, 0, 0, 0, ... 
%            0, 0, 0, 0, 0, ...
%            0, 0, 0, 0, 0, ...
%            0, 0          ];
%}

%Генератор проекта в форме кривизны
min_length;
max_length;
%Число участков пути
count=(nc*4)+1; %нечетное, на концах - прямые

%Получение кривизны
sceleton=zeros(count, 1);
delta=zeros(count, 1);
param=zeros(count, 1);
len=zeros(count+1, 1);
point=zeros(count+1, 1);
for i=1:count+1
	if (rem(i, 2)~=0)
		if (rem((i-1), 4)==0) 
			sceleton(i)=0;
		else
			param(i)=floor(1+P*rand(1));
			sceleton(i)=curvature(param(i))*sign(rand(1)-0.5);
		end
		delta(i)=floor(200+(1000-200)*rand(1));
	end
end

%Расчет длин переходных с условием того, что они кратны 10м
for i=1:count
	if (rem(i, 2)==0)
		if (rem(i, 4)==0)
			delta(i)=floor( ( min_length(param(i-1))+( max_length(param(i-1))- ...
			min_length(param(i-1)) )*rand(1))/10)*10;
        	else
			delta(i)=floor((min_length(param(i+1))+(max_length(param(i+1))- ...
			min_length(param(i+1)))*rand(1))/10)*10;
		end
	end
end
param;
sceleton;
delta;

%Запись GEO файла
geo.n = count;
geo.delta = delta;
geo.sceleton = sceleton;
geowrite(geo, 'test');

%Конвертер участков в длину
for i=2:count+1
	len(i)=len(i-1)+delta(i-1);
end
len;

%Конвертер участков в точки
for i=1:count
	if (rem(i,2)~=0) 
		point(i)=sceleton(i);
		point(i+1)=sceleton(i);
	end
end
point;

%График кривизн
figure;
%plot(len, point, 'b');
%hold on;

%Генератор пути в декартовой системе координат
%Будем учитывать шаг - минимальный дискрет пути
n=len(count+1)/step+1;
x=zeros(n, 1);
y=zeros(n, 1);

%Дискретизация пути и кривизны
l=zeros(n, 1);
c=zeros(n, 1);
j=1;
for i=1:n
	l(i)=(i-1)*step;
	if (l(i)>len(j+1)) 
		j=j+1;
	end
	if len(j+1)~=len(j)
		c(i)=point(j)+(l(i)-len(j))*(point(j+1)-point(j))/(len(j+1)-len(j));
	else
		c(i)=point(j);
	end
end
plot(l, c, 'g;curvature;');

%Интегрирование, преобразование в декартову систему
figure;
plot(0, 0, 'xr');

j=2;
[x, y]=c2w(c, step, 0, 0, 0, n);

for i=2:n
	if (l(i)==len(j))
		j=j+1;
		hold on;
		plot(x(i), y(i), 'xr'); 
	end
end

%Построение чертежа плана
j=1;
lx=zeros(2,1);
ly=zeros(2,1);
%{
%for i=1:n
%    if (l(i)>=len(j))
%	hold on;
%        if (rem(j, 2)==0)
%                lx(1)=x(i);
%                lx(2)=x(k);
%                ly(1)=y(i);
%                ly(2)=y(k);
%            if (rem(j, 4)==0)
%                r=1/point(j);
%                Z=[(lx(1)+lx(2))/2 (ly(1)+ly(2))/2];
%                W=[(lx(1)-lx(2))/2 (ly(1)-ly(2))/2];
%                d=sign(r)*sqrt(r^2-sum(W.^2));
%                if (delta(j-1)>abs(pi*r))
%                    d=-d;
%                end
%                
%                O=Z+d*[-W(2) W(1)]/(sqrt(sum(W.^2)));
%                a=O(1);
%                b=O(2);
%                t=[0:0.01:2*pi];
%                plot(a+r*sin(t), b+r*cos(t), '--r');
%            else
%                plot(lx, ly, '--r');
%            end	
%        end
%        j=j+1;
%        k=i;
%    end
%end
%}
%%{
for i=1:count
hold on;
	if (rem(i, 2)==1)
		lx(1)=x(len(i)/step+1);
		lx(2)=x(len(i+1)/step+1);
		ly(1)=y(len(i)/step+1);
		ly(2)=y(len(i+1)/step+1);

		r=1/point(i);
		Z=[(lx(1)+lx(2))/2 (ly(1)+ly(2))/2];
		W=[(lx(1)-lx(2))/2 (ly(1)-ly(2))/2];
		d=-sign(r)*sqrt(r^2-sum(W.^2));
                
		if (delta(i)>abs(pi*r))
            		d=-d;
		end

		O=Z+d*[-W(2) W(1)]/(sqrt(sum(W.^2)));  %Центр окружности
		a=O(1);
		b=O(2);
		t=[0:0.01:2*pi];
		plot(a+r*sin(t), b+r*cos(t), '-r');
	end    
end
%%}

%Построение плана
plot(x, y, 'k;way;');
axis equal;

%Построение yt
yt=int2(c, step, n);
figure;
axis equal;
j=1;
for i=1:n
	if (l(i)==len(j))
		j=j+1;
		plot((i-1)*step, yt(i), 'xk'); 
		hold on;
	end
end
plot(([1:n]-1)*step,yt,'-k;yt;');

way.x=x;
way.y=y;
way.l=l;
way.c=c;
way.n=n;
way.s=len;
way.yt=yt;
