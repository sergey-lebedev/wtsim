function curvature = v2c(versine, chordhead, chordtail, step, n)
format long;
%Создаем передаточную функцию для перевода стрел в кривизну
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

tf = -(l*(freq.^2))./(exp(i*freq*chordhead)*chordtail+exp(-i*freq*chordtail)*chordhead - l);
tf(1)=2/chordhead/chordtail;

%Создание массивов
idxfst = floor((fftsiz-n)/2);
auxsag=[versine(1)*ones(idxfst, 1); versine; versine(n)*ones(idxfst, 1)];

%Прямое Фурье-преобразование над стрелами
F = fft(auxsag, fftsiz);

%Умножение на передаточную функцию
F = F.*tf;

%Обратное Фурье-преобразование, получение кривизны
curvature=real(ifft(F));
curvature=curvature(idxfst+1:end-idxfst);

%figure;
%plot([1:length(tf)], log10(real(tf)), '-r');
