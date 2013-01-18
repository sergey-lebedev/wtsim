function verwrite(ver, filename)
n = ver.n;
step = ver.step/1000;
shifting = ver.shifting*1000;
raising = ver.raising*1000;

file=fopen(strcat(filename, '.ver'), 'w');
%fprintf(file, '========= BeginOfTab =========\n');
for i=1:n
fprintf(file, '   %2.5f  % 7.0f   % 7.0f  % g\n', ...
	step*(i-1), ...
   	shifting(i), ...
	raising(i), ...
	0);
end
%fprintf(file, '========== EndOfTab ==========');
fclose(file);
