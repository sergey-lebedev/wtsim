function meswrite(mes, filename)
n=mes.n;
Versine = mes.versine;
LeftVersine = mes.leftRaisingVersine;
RightVersine = mes.rightRaisingVersine;
Step = mes.stepSize;
Level = mes.level;

file=fopen(strcat(filename, '.mes'), 'w');
fprintf(file, 'Messung\n%g\n%s\n%d\n0\n', Step*(n-1), filename, cputime);
fprintf(file, '========= BeginOfTab =========\n');
for i=1:n
	fprintf(file, '  %g  %g  %g  %g  %g  0  0  0  0  1\n', ...
	Step*(i-1), ...
	Versine(i), ...
	LeftVersine(i), ...
	RightVersine(i), ...
	Level(i));
end
fprintf(file, '========== EndOfTab ==========');
fclose(file);
