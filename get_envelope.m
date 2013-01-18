function envelope = get_envelope(data, siz, ratio)

%Инициализация

% define
for i=1:siz-1
	a(i) = (i);
        b(i) = (siz-1+(i));
        c(i) = (2*(siz-1)+(i));
        d(i) = (3*(siz-1)+(i));
        fun(i) = (3*(i)-2);
        der(i) = (3*(i)-1);
        der2(i) = (3*(i));end

% BPMPD parameters
big = 1e30;
qnz = 2*(siz-1);
qn = 2*(siz-1);
n = 4*(siz-1);
m = 3*(siz-2)+2;
nz = m*5; % = NZMAX
code = 100;
memsiz = -1;
opt = 0;

% Defines quadratic form matrix
qcolcnt=zeros(1, n);
qcolidx=zeros(1, qnz);
qcolnzs=zeros(1, qnz);
idx=1;

for i=1:siz-1
        qcolcnt(a(i))=1;
        qcolidx(idx)=a(i);
        qcolnzs(idx)=ratio;
        idx=idx+1;
end

for i=1:siz-1
        qcolcnt(c(i))=1;
        qcolidx(idx)=c(i);
        qcolnzs(idx)=1.0e7;
        idx=idx+1;
end
%int32(qcolcnt)
%int32(qcolidx)
%qcolnzs
    
% Defines constraints matrix
acolcnt=zeros(1, n);
acolidx=zeros(1, nz);
acolnzs=zeros(1, nz);
idx = 1; 

% a
for i=1:siz-2
	acolcnt(a(i)) = 1;	if i>1
		acolcnt(a(i))= acolcnt(a(i))+1;
		acolidx(idx) = fun(i-1);
		acolnzs(idx) = -1;
		idx=idx+1;    
	end
	acolidx(idx) = fun(i);
	acolnzs(idx) = 1;
	idx=idx+1;      
end;
%%{
% a_last : f' exists, l < f < u
acolcnt(a(siz-1)) = acolcnt(a(siz-1)) + 2;
acolidx(idx) = fun(siz-2);
acolnzs(idx) = -1;
idx=idx+1;
acolidx(idx) = der(siz-1);
acolnzs(idx) = 1;
idx=idx+1;
%%}
% b
for i=1:siz-2
	acolcnt(b(i)) = 2;
	if i>1
		acolcnt(b(i))= acolcnt(b(i))+1;
		acolidx(idx) = der(i-1);
		acolnzs(idx) = -1;
		idx=idx+1;
	end
	acolidx(idx) = fun(i);
	acolnzs(idx) = 1;
	idx=idx+1;
	acolidx(idx) = der(i);
	acolnzs(idx) = 1;
	idx=idx+1;
end
%%{
% b_last : f' exists, l < f < u
acolcnt(b(siz-1)) = acolcnt(b(siz-1)) + 2;
acolidx(idx) = der(siz-2);
acolnzs(idx) = -1;
idx=idx+1;
acolidx(idx) = der(siz-1);
acolnzs(idx) = 1;
idx=idx+1;
%%}
% c
for i=1:siz-2
	acolcnt(c(i)) = 3;
	if i>1            
		acolcnt(c(i)) = acolcnt(c(i)) + 1;
		acolidx(idx) = der2(i-1);
		acolnzs(idx) = -1;
		idx=idx+1;
	end
	acolidx(idx) = fun(i);
	acolnzs(idx) = 1;
	idx=idx+1;
	acolidx(idx) = der(i);
	acolnzs(idx) = 2;
	idx=idx+1;
	acolidx(idx) = der2(i);
	acolnzs(idx) = 1;
	idx=idx+1;
end;
%%{
% c_last : f' exists, f''_lst = 0, l < f < u
acolcnt(c(siz-1)) = acolcnt(c(siz-1)) + 3;
acolidx(idx) = der2(siz-2);
acolnzs(idx) = -1;
idx=idx+1;
acolidx(idx) = fun(siz-1);
acolnzs(idx) = 2;
idx=idx+1;
acolidx(idx) = der(siz-1);
acolnzs(idx) = 1;
idx=idx+1;
%}
% d
for i=1:siz-2
	acolcnt(d(i)) = 3;
	acolidx(idx) = fun(i);
	acolnzs(idx) = 1;
	idx=idx+1;
	acolidx(idx) = der(i);
	acolnzs(idx) = 3;
	idx=idx+1;
	acolidx(idx) = der2(i);
	acolnzs(idx) = 3;
	idx=idx+1;
end;
%%{
% d_last : f''_lst = 0, l < f < u
acolcnt(d(siz-1)) = acolcnt(d(siz-1)) + 2;
acolidx(idx) = fun(siz-1);
acolnzs(idx) = 6;
idx=idx+1;
acolidx(idx) = der(siz-1);
acolnzs(idx) = 1;
idx=idx+1;
%%}
%int32(acolcnt)
%int32(acolidx)
%acolnzs
    
% Defines BPMPD arrays rhs, obj, lbound and ubound
rhs=zeros(1, m);
obj=zeros(1, n);
lbound=zeros(1, n+m);
ubound=zeros(1, n+m);

% Формирование ограничений
for i=1:siz-1
        lbound(a(i)) = data(i);
        ubound(a(i)) = big;
        lbound(b(i)) = -big;
        ubound(b(i)) = big;
        lbound(c(i)) = -big;
        ubound(c(i)) = big;
        lbound(d(i)) = -big;
        ubound(d(i)) = big;
	obj(a(i)) = -ratio*data(i);
end
    
rhs(m) = data(siz);
ubound(m+n) = big;
lbound(m+n) = 0;
    
% Declares primal, dual, status
primal=zeros(1, n+m);
dual=zeros(1, n+m);
status=zeros(1, n+m);
silent=1;
    
% Отладка
        
[X, result2, result3] = bp(m,n,nz,qn,qnz, ...
	int32(acolcnt),int32(acolidx),acolnzs, ...
	int32(qcolcnt),int32(qcolidx),qcolnzs, ...
	rhs,obj,lbound,ubound,primal,dual, ...
	int32(status),big,code,opt,memsiz,silent);                        

for i=1:siz-1
	envelope(i)=X(i);
end

envelope(siz)=X(a(siz-1))+X(b(siz-1))+X(c(siz-1))+X(d(siz-1));
size(data)
size(envelope)
