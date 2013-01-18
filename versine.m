function result = versine(x, y, chordhead, chordtail)
tic;
format long;
l=chordhead+chordtail;
R=[x y];
%Организуем поточечный перебор
n=length(x);

summ=0;
k=0;
p=1;

%Поиск положения конечной точки хорды
for i=1:n
	if (sum((R(1, :)-R(i, :)).^2)>=l*l)	
		m=i;
	break;
	end	
end

result = zeros(n-m+1, 1);
a = ones(1, 2);
c = ones(1, 2);
chord = ones(1, 2);
A = ones(1, 2);
B = ones(1, 2);
O = ones(1, 2);
P = ones(1, 2);
Q = ones(1, 2);
U = ones(1, 2);
W = ones(1, 2);

for i=m:n

	%Ставим конечную точку
	B=R(i, :);

	%Находим точку P
	for j=k+1:i
		if (sum((B-R(j, :)).^2)<=l*l)	
			k=j;
		break;
		end	
	end
	%Пересечение конца хорды и пути
	P=R(k, :);
	Q=R(k-1, :);
     	
	a=B-P;
	c=Q-P;
	b=a*c';
	d=c*c';
	alpha=(b+sqrt( b*b-d*((a*a')-l*l) ) )/d; %Проблема была здесь
	A=P*(1-alpha)+Q*alpha;
	
	%Направляющий вектор хорды
	chord=B-A;

	%Датчик ошибок
	%{
	%sqrt(sum(chord.^2));
	%if (sqrt(sum(chord.^2))>(l+0.001))|(sqrt(sum(chord.^2))<(l-0.001))
	%    sqrt(sum(chord.^2))
	%end
	%if (alpha<0)|(alpha>1)
	%    alpha
	%end
	%}

	%ПРУ
	O=(A*chordhead+B*chordtail)/l;
	%Вычисляем стрелу
	for drive = p:i %Можно ещё ускорить добавив p+1, но непонятно что будет с точностью
		W = O - R(drive, :);
		U = R(drive+1, :) - R(drive, :);         
		s = -(W*chord')*(chord*(W-U)');
		if (s>=0) 
			result(i-m+1)=l*(W(1)*U(2)-U(1)*W(2))/(U*chord');
			summ=summ+result(i-m+1);
			p=drive;
		break; 
		end
	end 
end
toc
summ
