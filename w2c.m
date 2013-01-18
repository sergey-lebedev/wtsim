function curvature = w2c(x, y, step, n)
format long;

%Сплайновая интерполяция
px=spline(step*[1:n], x);
py=spline(step*[1:n], y);

%Расчёт значений
A=[px.P(:, 4), px.P(:, 3), px.P(:, 2), px.P(:, 1)];
B=[py.P(:, 4), py.P(:, 3), py.P(:, 2), py.P(:, 1)];    

curvature=2*(A(:,2).*B(:,3)-B(:,2).*A(:,3))./((sqrt(A(:,2).^2+B(:,2).^2)).^3);

%Значение в крайней правой точке
dx=A(n-1,2)+2*A(n-1,3)*step+3*A(n-1,4)*step^2;
dy=B(n-1,2)+2*B(n-1,3)*step+3*B(n-1,4)*step^2;
ddx=2*A(n-1,3)+6*A(n-1,4)*step;
ddy=2*B(n-1,3)+6*B(n-1,4)*step;

curvature(n)=(dx*ddy-ddx*dy)/((sqrt(dx^2+dy^2))^3);
