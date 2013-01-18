function result = polysec(borders, y, step, mode)
printf("polysec.m\n");
tic;
%ABCDEFGJHKLMNOPQRSTUVWXYZ
%FGJHKMNOPSTUVWXYZ
%Создание массивов
n = length(y);
A = (1:n)'-1;
B = y;
C = A.^2;
D = B.^2;
E = A.*B;
    
%Суммирование
for i = 2:n
	A(i,:) = A(i,:) + A(i-1,:);
	B(i,:) = B(i,:) + B(i-1,:);
	C(i,:) = C(i,:) + C(i-1,:);
	D(i,:) = D(i,:) + D(i-1,:);
	E(i,:) = E(i,:) + E(i-1,:);
end

%Надо учесть размерность шага
borders=floor(borders/step);

%Инициализация
k = length(borders)-2; %Число точек разбиения
q = 2*(k+1); %Размерность матрицы квадратичных членов
result = zeros(k+2, 1); %Число границ участков
k;

%Дополнительные условия, получение числа участков постоянной кривизны
switch mode
	case 0
	%Четные участки постоянной кривизны
		if rem(k, 2)==0 d=k/2+mode;
		else d=(k+1)/2; 
		end
	case 1
	%Нечетные участки постоянной кривизны
		if rem(k, 2)==0 d=k/2+mode;
		else d=(k+1)/2; 
		end
	otherwise
	d=0;
end
d;

%Создание матрицы L
L = zeros(q+k, q+k);
Q = zeros(q, q); %Матрица квадратичных членов
K = zeros(k, q);

%Создание вектора-столбца R
R = zeros(q+k, 1);
P = zeros(q, 1);

for i=1:k+1
	j=2*i;
	lft = borders(i);
	rgt = borders(i+1);
	if i==1
		P(j-1:j, 1) = [E(rgt); B(rgt)];
		Q(j-1:j, j-1:j) = [C(rgt), A(rgt); ...
				A(rgt), rgt];
	else
		P(j-1:j, 1) = [E(rgt)-E(lft); B(rgt)-B(lft)];
		Q(j-1:j, j-1:j) = [C(rgt)-C(lft), A(rgt)-A(lft); ...
				A(rgt)-A(lft), rgt-lft];
		K(i-1, j-3:j) = [lft, 1, -lft, -1];
	end
end

%Внесение изменений в матрицу Q, K и столбец P
if d~=0
	for i=2-mode:2:k+1
		j=2*i;
		lft = borders(i);
		rgt = borders(i+1);
		if i==1
			P(j-1:j, 1) = [0; B(rgt)];
			Q(j-1:j, j-1:j) = [1, 0; ...
					0, rgt];
		else
			P(j-1:j, 1) = [0; B(rgt)-B(lft)];
			Q(j-1:j, j-1:j) = [1, 0; ...
					0, rgt-lft];
			K(i-1, j-3:j) = [lft, 1, 0, -1];
		end
	end
	for i=1+mode:2:k+1
		j=2*i;
		lft = borders(i);
		rgt = borders(i+1);
		if i~=1 K(i-1, j-3:j) = [0, 1, -lft, -1]; end
	end
end

L(1:q, 1:q) = Q;
L(q+1:q+k, 1:q) = K;
L(1:q, q+1:q+k) = K';
L;
R(1:q, 1) = P;

%Решение матричной системы
abbl = L\R;

%Расчёт значений на границах участков
for i=1:k+1
	j=2*i;
	a = abbl(j-1);
	b = abbl(j);

	lft = borders(i);
	rgt = borders(i+1);
	result(i) = a*lft+b;
	result(i+1) = a*rgt+b;
end
toc
