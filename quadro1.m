function [curvature, shiftings] = quadro(sections, ibreaks, y, lb, ub, step, mode)
printf("quadro.m\n");
tic;
format long;%Создание массивов
n = length(y);

%Надо учесть размерность шага
borders=floor(sections/step)

%Инициализация
k = length(borders)-2; %Число точек разбиения
q = 4*(k+1); %Размерность матрицы квадратичных членов
result = zeros(k+2, 1); %Число границ участков
k

% Initial condition
if (length(ibreaks)==0)|(floor(sections(k+2)/step)+1!=n)
	X0=[]
else
	X0=zeros(q, 1)
	for i=1:k+1		
		j=4*i;
		lft = sections(i);
		rgt = sections(i+1);
		dst=rgt-lft;
		
		X0(j-1)=ibreaks(i)/2;				X0(j)=(ibreaks(i+1)-ibreaks(i))/dst/6;
	
		X0(j-3)=y(floor(lft/step)+1);
		X0(j-2)=((y(floor(rgt/step)+1)-y(floor(lft/step)+1))- ...
						dst^2*(X0(j-1)+dst*X0(j)))/dst;	end
end

%Дополнительные условия, получение числа участков постоянной кривизны
switch mode
	case 0
		%Четные участки постоянной кривизны
		if rem(k, 2)==0 d=k/2+mode;
		else d=(k+1)/2; 
		end;
	case 1
		%Нечетные участки постоянной кривизны
		if rem(k, 2)==0 d=k/2+mode;
		else d=(k+1)/2; 
		end;
	otherwise;
        d=0;
end;
d

%Создание матриц
Q = zeros(q, q); %Матрица квадратичных членов
A = zeros(3*k+d, q); %Матрица ограничений для коэффициентов сплайна
B = zeros(3*k+d, 1);
C = zeros(q, 1);

for i=1:k+1
	j=4*i;
	lft = borders(i);
	rgt = borders(i+1);
        
	M(:,1) = step*((1:n)'-1);
	%M(:,2) = y;
	M(:,3) = M(:,1).^2;
	%M(:,4) = M(:,2).*M(:,1);
	M(:,5) = M(:,1).^3;
	%M(:,6) = M(:,2).*M(:,3);
	M(:,7) = M(:,1).^4;
	%M(:,8) = M(:,2).*M(:,5);
	M(:,9) = M(:,1).^5;
	M(:,10) = M(:,1).^6;
	
	if (i==1)
		M(1:rgt-lft+1,2) = y(lft+1:rgt+1);
		M(1:rgt-lft+1,4) = M(1:rgt-lft+1,2).*M(1:rgt-lft+1,1);
		M(1:rgt-lft+1,6) = M(1:rgt-lft+1,2).*M(1:rgt-lft+1,3);
		M(1:rgt-lft+1,8) = M(1:rgt-lft+1,2).*M(1:rgt-lft+1,5);
	    
		%Суммирование
		for i = 2:n
			M(i,:) = M(i,:) + M(i-1,:);
		end
		
		Q(j-3:j, j-3:j) = [rgt-lft+1, M(rgt-lft+1,1), M(rgt-lft+1,3), M(rgt-lft+1,5); ...
				M(rgt-lft+1,1), M(rgt-lft+1,3), M(rgt-lft+1,5), M(rgt-lft+1,7); ...
				M(rgt-lft+1,3), M(rgt-lft+1,5), M(rgt-lft+1,7), M(rgt-lft+1,9); ...
				M(rgt-lft+1,5), M(rgt-lft+1,7), M(rgt-lft+1,9), M(rgt-lft+1,10)];
		     
		C(j-3:j, 1) = -[M(rgt-lft+1,2), M(rgt-lft+1,4), M(rgt-lft+1,6), M(rgt-lft+1,8)];

	else
		M(1:rgt-lft,2) = y(lft+1:rgt);
		M(1:rgt-lft,4) = M(1:rgt-lft,2).*M(1:rgt-lft,1);
		M(1:rgt-lft,6) = M(1:rgt-lft,2).*M(1:rgt-lft,3);
		M(1:rgt-lft,8) = M(1:rgt-lft,2).*M(1:rgt-lft,5);
	    
		%Суммирование
		for i = 2:n
			M(i,:) = M(i,:) + M(i-1,:);
		end
		
		Q(j-3:j, j-3:j) = [rgt-lft, M(rgt-lft,1), M(rgt-lft,3), M(rgt-lft,5); ...
				M(rgt-lft,1), M(rgt-lft,3), M(rgt-lft,5), M(rgt-lft,7); ...
				M(rgt-lft,3), M(rgt-lft,5), M(rgt-lft,7), M(rgt-lft,9); ...
				M(rgt-lft,5), M(rgt-lft,7), M(rgt-lft,9), M(rgt-lft,10)];
		     
		C(j-3:j, 1) = -[M(rgt-lft,2), M(rgt-lft,4), M(rgt-lft,6), M(rgt-lft,8)];
	end
end

C;
Q;
%Создание матрицы ограничений для коэффициентов сплайна
lrc=0; %Lost rows counter
for i=1:k
	j=4*i;
	lft = sections(i);
	rgt = sections(i+1);

	if (d~=0)&(rem(i, 2)==mode) 
		A(j-3-lrc, j-3:j)=[0 0 0 1]; 
		A(j-2-lrc:j-lrc, j-3:j+4)=[1, (rgt-lft), (rgt-lft)^2, 0, -1,  0,  0, 0; ...
				0,         1, 2*(rgt-lft), 0,  0, -1,  0, 0; ...
				0,         0,           1, 0,  0,  0, -1, 0];
	else	
		lrc=lrc+1;
		A(j-2-lrc:j-lrc, j-3:j+4)=[1, (rgt-lft), (rgt-lft)^2,   (rgt-lft)^3, -1,  0,  0, 0; ...
				0,         1, 2*(rgt-lft), 3*(rgt-lft)^2,  0, -1,  0, 0; ...
				0,         0,           1,   3*(rgt-lft),  0,  0, -1, 0];
	end
end

% Граничные условия
i=k+1;
j=4*i;
if (d~=0)&(rem(i, 2)==mode) A(j-3-lrc, j-3:j)=[0 0 0 1]; end;

% Матрица ограничений
if (ub==lb)
	A_LB = []
	A_IN = []
	A_UB = []
else
	A_LB = zeros(n, 1);
	A_UB = zeros(n, 1);
	for i=1:n
		A_LB(i)=y(i)-ub(i);
		A_UB(i)=y(i)-lb(i);
	end

	A_IN = zeros(n, n);
	for i=1:k
		for j=borders(i):borders(i+1)
			coeff=j*step;
			A_IN(j+1, 4*i-3:4*i)=[1 j j^2 j^3];
		end
	end
	A_LB
	A_IN
	A_UB
	size(A_LB)
	size(A_IN)
	size(A_UB)
end
%Решение задачи квадратичного программирования
%[X, fval, exitflag] = qp(X0, Q, C, A, B);
[X, fval, exitflag] = qp(X0, Q, C, A, B, [], [], A_LB, A_IN, A_UB);
length(X0);
length(X);
[X0, X];
A*X0;
A*X;
2*fval;
sum(y.^2);
2*fval+sum(y.^2);
X'*Q*X;
2*C'*X;
exitflag;

for k=1:length(sections)-1
	for i=1:n
		j=4*k;
		a = X(j-3);
		b = X(j-2);
		c = X(j-1);
		d = X(j);
     
		%Применим схему Горнера
		rgt=(i-1)*step;
		lft = sections(k);
		rl=rgt-lft;
		breaks(i) = a+rl*(b+rl*(c+rl*d));
	end
end

%Построение нового графика кривизн по коэффициентам сплайна
for k=1:length(sections)-1
	j=4*k;
	c = X(j-1);
	d = X(j);
	curvature(k) = 2*c;
end
curvature(k+1) = 2*c+6*d*(sections(k+1)-sections(k));

curvature;

k=1;
for i=1:n
	j=4*k;
	a = X(j-3);
	b = X(j-2);
	c = X(j-1);
	d = X(j);
    
	rgt=(i-1)*step;
	lft = sections(k);
	if rgt>sections(k+1)
		k=k+1;
	end
    
	%Применим схему Горнера
	rl=rgt-lft;
	breaks(i) = a+rl*(b+rl*(c+rl*d));
end
size(y);
size(breaks);

shiftings=breaks'-y;
toc
