%% LoadFile
%?? ??
name = 'KBJ'; %??? ??
sources = {
    strcat(pwd, '/Data/', name, '_TR_S_band.mat'), ...
    strcat(pwd, '/Data/', name, '_NN_S_band.mat'), ...
    strcat(pwd, '/Data/', name, '_TR_NS_band.mat'), ...
    strcat(pwd, '/Data/', name, '_NN_NS_band.mat'), ...
};
% sources = {
%     strcat(pwd, '/preprocessed/', name, '_S_TR.mat'), ...
%     strcat(pwd, '/preprocessed/', name, '_S_NN.mat'), ...
%     strcat(pwd, '/preprocessed/', name, '_NS_TR.mat'), ...
%     strcat(pwd, '/preprocessed/', name, '_NS_NN.mat'), ...
%     };

TypeName = {
    'Spatial TR', ...
    'Spatial NN', ...
    'Nonspatial TR', ...
    'Nonspatial NN', ...
};

bandERSP = [];
trialId = [];
for s = 1:length(sources),
    bandInfo = load(char(sources(s)));
    bandERSP = cat(4, bandERSP, bandInfo.bandEEG);
    trialId = cat(1, trialId, s * ones(size(bandInfo.bandEEG, 4), 1));

    bands = bandInfo.bands;
    times = bandInfo.times;
end


%% Region Information
% regionInfo = load('Data/KBJ_regions');
% [regionId, regions] =  grp2idx(regionInfo.mappingIdx(:, 2));

%% Mean per Test Case
for s = 1:length(sources),
    selectedERSP = bandERSP(:, :, :, trialId == s);
    meanBandERSP(:, :, :, s) = mean(selectedERSP(:, :, :, end*2/3:end), 4);
end

%% Normalize per Band
normalizedBandERSP = meanBandERSP;
for s=1:length(sources),
    for b = 1:length(bands),
        base = meanBandERSP(:, b, times<0, s);
        baseline = mean(base(:));
        disp(baseline);
        normalizedBandERSP(:, b, :, s) = meanBandERSP(:, b, :, s) / baseline;
    end
end

%% Mean Activity per bands
meanActivity = mean(permute(normalizedBandERSP, [4, 3, 2, 1]), 4);
% meanActivity[time, band]
for b = 1:length(bands),
    figure(figureStart); subplot(3,2,b);
    plot(times, meanActivity(:, :, b));
    xlabel('time from onset (s)');
    ylabel('Mean Power (mV)');
    title(strcat('\fontsize{16}',bands(b)));
end
legend(TypeName, 'Location','southeast');

%% Multidimensional Scale
timeERSPT = permute(normalizedBandERSP, [1, 3, 4, 2]);

for b = 1:length(bands),
    timeERSP = timeERSPT(:,:,:,b);
    timeERSP = timeERSP(:, :)';
    D = pdist(timeERSP);
    Y = cmdscale(D);
    
    time = length(times);
    channel = size(Y, 2);
    Z = zeros(length(sources), time, channel);
    for s=1:length(sources),
        Z(s, :, :) = Y(1+(s-1)*time:s*time, :);
    end

    figure(figureStart+1); subplot(3,2,b);
    plot(Z(:, :, 1)', Z(:, :, 2)');
    xlabel('Dimension1');
    ylabel('Dimension2');
    title(strcat('\fontsize{16}',bands(b)));
end
legend(TypeName, 'Location','southeast');

%% Distance
timeERSP = permute(normalizedBandERSP, [3, 1, 4, 2]);
for b = 1:length(bands),
    dist12 = sqrt(sum((timeERSP(:,:,1, b) - timeERSP(:,:,2, b)).^2, 2)); %% TR vs NN in S
    dist34 = sqrt(sum((timeERSP(:,:,3, b) - timeERSP(:,:,4, b)).^2, 2)); %% TR vs NN in NS
    dist13 = sqrt(sum((timeERSP(:,:,1, b) - timeERSP(:,:,3, b)).^2, 2)); %% S vs NS in TR
    dist14 = sqrt(sum((timeERSP(:,:,1, b) - timeERSP(:,:,4, b)).^2, 2));
    dist23 = sqrt(sum((timeERSP(:,:,2, b) - timeERSP(:,:,3, b)).^2, 2));
    dist24 = sqrt(sum((timeERSP(:,:,2, b) - timeERSP(:,:,4, b)).^2, 2)); %% S vs NS in NN
    SvsNS = (dist13 + dist14 + dist23 + dist24) / 4;
    TRvsNN = (dist12 + dist14 + dist23 + dist34) / 4;
    figure(figureStart+2); subplot(3,2,b);
    plot( ...
        times, SvsNS, ...
        times, TRvsNN);
%     plot(times, dist12, ...
%         times, dist34, ...
%         times, dist13, ...
%         times, dist24);
%     plot( ...
%         times, dist12, ...
%         times, dist13, times, dist14);
    xlabel('time from onset (s)');
    ylabel('Mean Distance (mV)');
    title(bands(b));
end

%legend({'S vs NS', 'TR vs NN', '', '', '', '' });
legend({'S  TR vs NN', 'NS  TR NN', 'TR   S NS', 'NN S NS'});

