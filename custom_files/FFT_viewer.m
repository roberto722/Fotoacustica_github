n = 4096;
fs = 31.25e6;
figure
for i = 1:128
    sino_fft = fft(data_filt(:, i));
    power = abs(sino_fft).^2/n;
    f = (-n/2:n/2-1)*(fs/n);
    plot(f,power)
    hold on
end
xlabel('Frequency')
ylabel('Power')
hold off