function [x, y]=c2w(c, step, x0, y0, alpha, n)

x=zeros(n, 1);
y=zeros(n, 1);

x(1)=x0;
y(1)=y0;
for i=2:n
    alpha=alpha+c(i-1)*step;
    x(i)=x(i-1)+step*cos(alpha);
    y(i)=y(i-1)+step*sin(alpha);
end
