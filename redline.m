function [xn, yn]=redline(x, y, step, shiftings, n)
format long;

%Сплайновая интерполяция
px=spline(step*[1:n], x);
py=spline(step*[1:n], y);

%Расчёт значений
A=[px.P(:, 4), px.P(:, 3), px.P(:, 2), px.P(:, 1)];
B=[py.P(:, 4), py.P(:, 3), py.P(:, 2), py.P(:, 1)];

sx=-B(:, 2)./sqrt(A(:, 2).^2+B(:, 2).^2);
sy=A(:, 2)./sqrt(A(:, 2).^2+B(:, 2).^2);

%Значение в крайней правой точке
dx=A(n-1,2)+2*A(n-1,3)*step+3*A(n-1,4)*step^2;
dy=B(n-1,2)+2*B(n-1,3)*step+3*B(n-1,4)*step^2;

sx(n)=-dy/sqrt(dx^2+dy^2);
sy(n)=dx/sqrt(dx^2+dy^2);

xn=x+sx.*shiftings;
yn=y+sy.*shiftings;
