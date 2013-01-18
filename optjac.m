function jac=optjac(p, n)
printf("opt.m\n");
p
m=length(p)
m=m/4
%n=length(data)
n

jac=zeros(n, length(p));
for i=1:n
	%mm=0;	
	for j=1:m
		mm=4*(j-1);
		jac(i, [1+mm:m+mm])=[i^3, i^2, i, 1];
	end
end
