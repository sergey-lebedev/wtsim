clear all;
close all;
EXEC_PATH()

% Все размеры будут в метрах
n=1000;
step=0.25;

% Наложение шумов
x=[1:n];
shiftings=1*100*makenoise(size(x))';

% Генерация ограничений
ub=0.1*ones(1, n);

lb=-ub;

residual=zeros(1, n);

size(shiftings)
size(ub)
size(lb)
size(residual)
n

tic;
fitted = fit_to_constraints(shiftings, lb, ub, residual, n, 1e-5);
toc

size(ub)
size(shiftings)

% В представленни для fit
figure;
hold on;
% plot("Для представления fit"); Разобраться в заголовках с помощью книжки
plot([1:n]*step, shiftings-ub', 'r');
plot([1:n]*step, shiftings-lb', 'b');
plot([1:n]*step, shiftings-fitted, 'g');

% Построение сдвижек и ограничений
figure;
hold on;
plot([1:n]*step, lb, 'k');
plot([1:n]*step, ub, 'k');
plot([1:n]*step, shiftings, 'b');
plot([1:n]*step, fitted, 'm');

% В представлении пути
figure;
hold on;
plot([1:n]*step, lb, 'k');
plot([1:n]*step, ub, 'k');
plot([1:n]*step, -shiftings, 'b');
plot([1:n]*step, shiftings-shiftings, 'g');
plot([1:n]*step, fitted-shiftings, 'm');
