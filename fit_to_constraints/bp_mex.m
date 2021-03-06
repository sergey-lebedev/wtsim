m=3;
n=4;
nz=10;
qn=3;
qnz=4;

% Инициализация массивов
acolcnt=zeros(1, n);
acolidx=zeros(1, nz);
acolnzs=zeros(1, nz);

qcolcnt=zeros(1, n);
qcolidx=zeros(1, qnz);
qcolnzs=zeros(1, qnz);

status=zeros(1, n+m);
rhs=zeros(1, m);
obj=zeros(1, n);

lbound=zeros(1, n+m);
ubound=zeros(1, n+m);
primal=zeros(1, n+m);
dual=zeros(1, n+m);
big=1e30;

acolcnt=[3,         2,      2,      3];
acolidx=[1, 2, 3,   1, 3,   2, 3,   1, 2, 3];
acolnzs=[1, 3, 1,   2, 3,   -2,3,   -4,-1,-2];
int32(acolcnt)

qcolcnt=[2,     1,0,1];
qcolidx=[1,2,   2,  4];
qcolnzs=[2,2,   4,  2];

rhs=[0, 100, 10];
obj=[1,0,0,0];
lbound=[ 0,   0,   0,-big,   0,-big,0];
ubound=[20, big, big, big, big, 0, 20];

code=0;
opt=0; 
memsiz=0;

[result1, result2, result3] = bp(m,n,nz,qn,qnz, ...
                            int32(acolcnt),int32(acolidx),acolnzs, ...
                            int32(qcolcnt),int32(qcolidx),qcolnzs, ...
                            rhs,obj,lbound,ubound,primal,dual,int32(status), ...
                            big,code,opt,memsiz,0);
result1
%result2
%result3
