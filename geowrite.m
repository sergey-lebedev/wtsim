function geowrite(geo, filename)
n = geo.n;
delta = geo.delta;
sceleton = geo.sceleton;
begin=0;

file=fopen(strcat(filename, '.geo'), 'w');
fprintf(file, 'SollGeom\n');
%fprintf(file, '0\n');
fprintf(file, '========= BeginOfTab =========\n');

for i=1:n
%использовать case
%449 450 451
%464 465
elevation_or_length=0;
elevation_type=464;
curvature_type=449;
if sceleton(i)~=0
	curvature_type=450;
end
if rem(i, 2)==0
	curvature_type=451;
end

switch curvature_type
	case 449
		radius_or_length=0;
	case 450
		radius_or_length=1/sceleton(i);
	case 451
		elevation_or_length=delta(i);
		radius_or_length=delta(i);
		elevation_type=465;
end

	fprintf(file, '  %5.3f  % .3e % .3e  %d %d\n', ...
	begin, ...
	radius_or_length, ...
	elevation_or_length, ...
	curvature_type, ...
	elevation_type);

begin=begin+delta(i);
end
fprintf(file, '  %5.3f  % .3e % .3e  %d %d\n', begin, 0, 0, 449, 464);
fprintf(file, '========== EndOfTab ==========\n');
%fprintf(file, '========= BeginOfTab =========\n');
%fprintf(file, '  %5.3f  % .3e % .3e % .3e %d\n', 0, 0, 0, 0, 480);
%fprintf(file, '========== EndOfTab ==========');
fclose(file);
