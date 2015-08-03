%% LoadFile
source1 = strcat(pwd, '/Target/BYT_NS_band_abs.mat');
source2 = strcat(pwd, '/Nontarget/BYT_NS_band_abs.mat');

bandInfo1 = load(source1);
bandInfo2 = load(source2);

bandEEG1 = bandInfo1.bandEEG;
bandEEG2 = bandInfo2.bandEEG;

bands = bandInfo1.bands;
times = bandInfo1.times;


%% Mimimalize Demension
chan = min(size(bandEEG1, 1), size(bandEEG2, 1));
tc = min(size(bandEEG1, 4), size(bandEEG2, 4));
if mod(tc, 2) == 1
    tc = tc - 1;
end
bandEEG1 = bandEEG1(1:chan, :, :, 1:tc);
bandEEG2 = bandEEG2(1:chan, :, :, 1:tc);

%% Dimension Reorder
TrialEEG1 = permute(bandEEG1, [4, 1, 3, 2]); % Trial Channel Time Band
TrialEEG2 = permute(bandEEG2, [4, 1, 3, 2]);

%% cross-temporal classification matrix
crossTemporal = zeros(length(times), length(times), length(bands));
group = zeros(size(TrialEEG1, 1), 1);
group(1:2:end) = 1;
group(2:2:end) = 2;
for band = 1:length(bands),
    for t1 = 1:length(times),
        for t2 = 1:length(times),
            p1 = TrialEEG1(:, :, t1, band);
            p2 = TrialEEG1(:, :, t2, band);
            
            crossTemporal(t1, t2, band) = mean(Analysis_Stokes_Neuron_2013(p1, p2, group, 1));
        end
    end
end

%% cross-temporal classification matrix
crossTemporal2 = zeros(length(times), length(times), length(bands));
TrialEEG1 = TrialEEG1(1:191, :, :, :);
group = zeros(size(TrialEEG1, 1), 1);
group(1:2:end) = 1;
group(2:2:end) = 2;
for band = 1:length(bands),
    for t1 = 1:length(times),
        for t2 = 1:length(times),
            p1 = TrialEEG1(:, :, t1, band);
            p2 = TrialEEG2(:, :, t2, band);
            
            crossTemporal2(t1, t2, band) = mean(Analysis_Stokes_Neuron_2013(p1, p2, group, 1));
        end
    end
end


%% plot
for b = 1:length(bands),
    figure(2); subplot(3,2,b);
    imagesc(times, times, crossTemporal2(:,:,b));
    colormap('jet');
    xlabel('time (s)');
    ylabel('time (s)');
    title(bands(b));
    set(gca,'YDir','normal')
    colorbar;
end



%% cross-temporal classification matrix
crossTemporal = zeros(length(times), length(bands));
group = zeros(size(TrialEEG1, 1), 1);
group(1:2:end) = 1;
group(2:2:end) = 2;
for band = 1:length(bands),
    for t1 = 1:length(times),
        p1 = TrialEEG1(:, :, t1, band);
        p2 = TrialEEG2(:, :, t1, band);

        crossTemporal(t1, band) = mean(Analysis_Stokes_Neuron_2013(p1, p2, group, 10));
    end
end

%% plot
for b = 1:length(bands),
    figure(2); subplot(3,2,b);
    plot(crossTemporal(:,b));
    xlabel('time from onset (s)');
    ylabel({'Pattern Classification'; 'Index (r)'});
    title(strcat('\fontsize{16}',bands(b)));
end
