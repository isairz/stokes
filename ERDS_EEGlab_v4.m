%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%Time-frequency Anaysis for Motor Imagery %%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ERDS_EEGlab_v4(fpath, state)
%%

% clc; 
% clear all; 
% close all;

% %% data loading and Common Average reference
% row = size(epoch{1}, 1);
% 
% for ii = 1:size(epoch, 2)
%     allEpoch(((ii-1)*row)+1:ii*row, :) = epoch{ii};    
% end

% eeglabPath = '~/eeglab10_2_5_8b';
% addpath([eeglabPath '/functions/popfunc']);
% addpath([eeglabPath '/functions/adminfunc']);
% addpath([eeglabPath '/functions/guifunc']);
% addpath([eeglabPath '/functions/sigprocfunc']);
% addpath([eeglabPath '/functions/timefreqfunc']);
% addpath([eeglabPath '/functions/miscfunc']);
% addpath([eeglabPath '/plugins/iirfilt1.02']);

% fpath = 'E:\docs\Lab\Projects\BCI\DataSets\Attention\processed\';
% state = 'BMJ';
% TRnRes = {'NN'};
% TRnRes = {'TRnRes'};
% TRnRes = {'TR', 'NN', 'Res'};
TRnRes = {'NN'};
postfix = {'_S', '_NS'};

for TR = 1:length(TRnRes)
for PF = 1:length(postfix)
	filename = [fpath '/' state postfix{PF} '_' TRnRes{TR} ];
	setname = [filename '.set'];
	EEG = pop_loadset(setname);
	
nRows = EEG.nbchan;
nData = EEG.trials * EEG.pnts;
nPnts = EEG.pnts;

allEpoch = zeros(nData, nRows);

for i = 1:EEG.trials
	allEpoch(((i-1)*nPnts)+1:(i*nPnts), :) = EEG.data(:,:,i)';
end

%% Time-frequency Analysis
% sTime = -10000;   eTime = 30000;
% sampling = 256;    trialNum = 21;
sTime = EEG.xmin;
eTime = EEG.xmax;
sampling = EEG.srate;
trialNum = EEG.trials;

frame = (size(allEpoch,1)/trialNum);

% electrode = {'Fp1', 'Fp2', 'F7', 'F3', 'Fz', 'F4', 'F8', ...
%     'C3', 'Cz','C4','P3', 'Pz', 'P4', 'O1', 'O2'};
for i=1:nRows
	electrode{i} = EEG.chanlocs(i).labels;
end


lname1 = '.jpg';    lname2 = '.fig';    lname3 = '.dat';

% %each  trials
% trialNum = 1;
% frame = (size(epoch{1},1)/trialNum);
% for ii = 1:size(epoch, 2)
%     for jj = 8:10%1:size(electrode,2);
%         Data = epoch{ii} (:, jj)';
% %         title_name = [electrode{jj}];                 
% 		title_name = '';
% %         [ersp,itc,powbase,times,freqs,erspboot,itcboot] = newtimef(Data,frame,...
% %             [sTime,eTime], sampling, 0,'type','phasecoher', 'plotitc' , 'off', 'freqs', [6 40], 'title', title_name, 'alpha', 0.05); % Time Frequency
%         %t-test + multiple correctection
%         [ersp,itc,powbase,times,freqs,erspboot,itcboot] = newtimef(Data,frame,...
%             [sTime,eTime], sampling, 0,'type','phasecoher', 'plotitc' , 'off', 'freqs', [6 40], 'title', title_name, 'alpha', 0.05, 'mcorrect', 'fdr'); % Time Frequency
%         % save figure
%         savename1 = ['jpg/' num2str(ii) electrode{jj}, lname1];
%         saveas(gcf, savename1);
%         savename2 = ['fig/' num2str(ii) electrode{jj}, lname2];
%         saveas(gcf, savename2);
%         close;
% %         savename3 = ['ersp/' num2str(ii) electrode{jj}, lname3];
% %         eval(['save ' savename3 ' ersp -ascii']);            
%     end   
% end


%all Trials
chanERSP = zeros(nRows, 169, 200, trialNum);
% chanERSP = zeros(nRows, 169, 200);
for i = 1:nRows %1:size(electrode,2);
    Data = allEpoch(:,i)';
    title_name = [state postfix{PF} '_' TRnRes{TR} '_ch' num2str(i) '_' electrode{i}];
% 	title_name = ['ch' num2str(i)];
% 	figure;
    [ersp,itc,powbase,times,freqs,erspboot,itcboot, tfdata] = newtimef(Data, frame, [sTime,eTime], sampling, 0, 'plotitc' , 'off', 'plotersp' , 'on', 'freqs', [2 170], 'title', title_name, 'erspmax', 5, 'nfreqs', 169); % Time Frequency
	chanERSP(i,:,:,:) = tfdata;
% 	chanERSP(i,:,:) = ersp;

    % save figure
    savename1 = [fpath '/jpg/' title_name, lname1];
    saveas(gcf, savename1);
%     savename2 = ['fig/' title_name, lname2];
%     saveas(gcf, savename2);
    close;

%     savename3 = ['ersp/' electrode{jj}, lname3];
%     eval(['save ' savename3 ' ersp -ascii']);            
end   

save([filename '.mat'], 'chanERSP', 'times', 'freqs', '-v7.3');



% fid = fopen([state '.sav'],'w');
% fwrite(fid, chanERSP_m, 'double');
% fclose(fid);

end
end