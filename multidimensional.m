%% LoadFile
sources = {
    strcat(pwd, '/KBJ/KBJ_TR_S_classification.mat'), ...
	strcat(pwd, '/KBJ/KBJ_NN_S_classification.mat'), ...
    strcat(pwd, '/KBJ/KBJ_TR_NS_classification.mat'), ...
    strcat(pwd, '/KBJ/KBJ_NN_NS_classification.mat'), ...
    };

PlotName = {
    'Spatial TR', ...
    'Spatial NN', ...
    'Nonspatial TR', ...
    'Nonspatial NN', ...
    };
    

% bandEEG = [];
% trialId = [];
% for s = 1:length(sources),
%     bandInfo = load(char(sources(s)));
%     %size(bandInfo.bandEEG)
%     bandEEG = cat(4, bandEEG, bandInfo.bandEEG);
%     trialId = cat(1, trialId, s * ones(size(bandInfo.bandEEG, 4), 1));
% 
%     bands = bandInfo.bands;
%     times = bandInfo.times;
% end


%% Region Information
regionInfo = load('KBJ/KBJ_region');
[regionId, regions] =  grp2idx(regionInfo.mappingIdx(:, 2));

%% Mean per Test Case
clear meanBandEEG;
for s = 1:length(sources),
    meanBandEEG(:, :, :, s) = mean(bandEEG(regionId==1, :, :, trialId == s), 4);
end
regions(1)

%% Mean Activity per bands
meanActivity = mean(permute(meanBandEEG, [4, 3, 2, 1]), 4);
% meanActivity[time, band]
for b = 1:length(bands),
    figure(1); subplot(3,2,b);
    plot(times, meanActivity(:, :, b));
    xlabel('time from onset (s)');
    ylabel('Mean Power (mV)');
    legend(PlotName, 'Location','northwest');
    title(strcat('\fontsize{16}',bands(b)));
end

%% Multidimensional Scale
timeEEGT = permute(meanBandEEG, [1, 3, 4, 2]);

for b = 1:length(bands),
    timeEEG = timeEEGT(:,:,:,b);
    timeEEG = timeEEG(:, :)';
    D = pdist(timeEEG);
    Y = cmdscale(D);
    
    time = length(times);
    channel = size(Y, 2);
    Z = zeros(length(sources), time, channel);
    for s=1:length(sources),
        Z(s, :, :) = Y(1+(s-1)*time:s*time, :);
    end

    figure(2); subplot(3,2,b);
    plot(Z(:, :, 1)', Z(:, :, 2)');
    xlabel('Dimension1');
    ylabel('Dimension2');
    legend(PlotName);
    title(strcat('\fontsize{16}',bands(b)));
end

%% Distance
timeEEG = permute(meanBandEEG, [3, 1, 4, 2]);
for b = 1:length(bands),
    dist12 = sqrt(sum((timeEEG(:,:,1, b) - timeEEG(:,:,2, b)).^2, 2));
    dist13 = sqrt(sum((timeEEG(:,:,1, b) - timeEEG(:,:,3, b)).^2, 2));
    dist14 = sqrt(sum((timeEEG(:,:,1, b) - timeEEG(:,:,4, b)).^2, 2));
    dist23 = sqrt(sum((timeEEG(:,:,2, b) - timeEEG(:,:,3, b)).^2, 2));
    dist24 = sqrt(sum((timeEEG(:,:,2, b) - timeEEG(:,:,4, b)).^2, 2));
    dist34 = sqrt(sum((timeEEG(:,:,3, b) - timeEEG(:,:,4, b)).^2, 2));
    SvsNS = (dist13 + dist14 + dist23 + dist24) / 4;
    TRvsNN = (dist12 + dist14 + dist23 + dist34) / 4;
    figure(3); subplot(3,2,b);
    plot(times, SvsNS, times, TRvsNN);
    xlabel('time from onset (s)');
    ylabel('Mean Distance (mV)');
    legend({'S vs NS', 'TR vs NN'});
    title(bands(b));
end