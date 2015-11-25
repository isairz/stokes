% 1~200 frequency dimension? brain wave(6??) dimension?? ????

%% Load File
clear;
sourcePath = strcat(pwd, '/Data/KBJ_TR_S.mat');
targetPath = regexprep(sourcePath, '\.mat$', '_band.mat');
info = load(sourcePath);

rawEEG = info.chanERSP;
times = info.times;
freqs = info.freqs;
[channel, frequency, time, trial] = size(rawEEG);

%% Absoulte
% ???? ??? EEG Power? ??? ??
absEEG = abs(rawEEG);
clear rawEEG;


%% Brain Wave Information
% ?? ??? ??? ??
bands = {'Delta', 'Theta', 'Alpha', 'Beta', 'Gramma Low', 'Gramma High'};
band = length(bands);

bandId = zeros(length(freqs), 1);
bandId(freqs >= 0 & freqs < 4) = 1;
bandId(freqs >= 4 & freqs < 8) = 2;
bandId(freqs >= 8 & freqs < 12) = 3;
bandId(freqs >= 12 & freqs < 30) = 4;
bandId(freqs >= 30 & freqs < 50) = 5;
bandId(freqs >= 70 & freqs < 120) = 6;

%% Means per band
% ??? ?? ??
bandEEG = zeros(channel, band, time, trial);
for bandIdx=1:band,
    bandEEG(:, bandIdx, :, :) = mean(absEEG(:, bandId == bandIdx, :, :), 2);
end

%% Save File
save(targetPath, 'bandEEG', 'bands', 'times', '-v7.3');