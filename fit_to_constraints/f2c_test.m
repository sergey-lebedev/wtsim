clear all;
close all;

% Все размеры будут в метрах
n=1000;
step=0.25;

% Наложение шумов
x=[1:n];
shiftings=1*100*makenoise(size(x))';

% Генерция ограничений
ymax=0.1
ymin=0.000;
ub=0.1*ones(1, n);
a=0;
b=30;
c=b;
d=a;

ub(a/step+1:(a+b)/step)=ymin;	
ub(n-(c+d)/step+1:n-d/step)=ymin;	

lb=-ub;

% Построение графиков ограничений
figure;
hold on;
plot([1:n], lb, 'k');
plot([1:n], ub, 'k');

residual=zeros(1, n);

size(shiftings)
size(ub)
size(lb)
size(residual)
n

tic;
fitted = f2c(shiftings, lb, ub, residual, n, 1e-3); %было 1e-5
toc
% Надо понять как здесь можно записать плавность, проблема в том что я оперирую с остаточыми сдвижками
% Непонятки с ГУ
size(ub);
size(shiftings);

% В представленни для fit
figure;
hold on;
% plot("Для представления fit"); Разобраться в заголовках с помощью книжки
plot([1:n], shiftings-ub', 'r');
plot([1:n], shiftings-lb', 'b');
plot([1:n], shiftings-fitted, 'g');

% Построение сдвижек и ограничений
figure;
hold on;
plot([1:n], lb, 'k');
plot([1:n], ub, 'k');
plot([1:n], shiftings, 'b;Сдвижки без ограничений;');
plot([1:n], fitted, 'm;Сдвижки с ограничениями;');

% В представлении пути
figure;
hold on;
plot([1:n], lb, 'k');
plot([1:n], ub, 'k');
plot([1:n], -shiftings, 'b;Путь до выправки;');
plot([1:n], shiftings-shiftings, 'g;Выправка без ограничений;');
plot([1:n], fitted-shiftings, 'm;Выправка с ограничениями;');
