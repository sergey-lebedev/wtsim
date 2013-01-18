function versine = c2v_shft(curvature, chordhead, chordtail, step, n)
format long;
%Создаем передаточную функцию для перевода кривизны в стрелы
n=n(1); %!n должно быть четным
fftsiz=2^ceil(log2(n*1.4));
freq_step = 2*pi/step/fftsiz;
l=chordhead+chordtail;

freq = ones(fftsiz, 1);
for j=2:fftsiz
    freq(j) = freq_step*(j-1);
    if (j>fftsiz/2)
        freq(j) = freq(j)-freq_step*fftsiz;
    end
end

tf = -(exp(i*freq*chordhead)*chordtail+exp(-i*freq*chordtail)*chordhead - l)./(l*(freq.^2));
tf = tf.*exp(i*freq*chordtail);
tf(1)=chordhead*chordtail/2;

%Создание массивов
idxfst = floor((fftsiz-n)/2);
auxsag=[curvature(1)*ones(idxfst, 1); curvature; curvature(n)*ones(idxfst, 1)];

%Прямое Фурье-преобразование над кривизнами
F = fft(auxsag, fftsiz);

%Умножение на передаточную функцию
F = F.*tf;

%Обратное Фурье-преобразование, получение стрел
versine=real(ifft(F));
versine=versine(idxfst+1:end-idxfst);
