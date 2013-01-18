function result=int2(values, step, n)
format long;
%Двойное интегрирование методом трапеций
integral=zeros(n, 1);
for i=2:n
    integral(i)=integral(i-1)+(values(i)+values(i-1))/2;
end
values=integral;

integral=zeros(n, 1);
for i=2:n
    integral(i)=integral(i-1)+(values(i)+values(i-1))/2;
end
values=integral;

result=step*step*values;
