function [r] = Analysis_Stokes_Neuron_2013(sample, training, group, N_iter)
% Pattern Classification Index (r')
% Strokes et al., Neuron, 2013
%
% sample
% training
% group
% N_iter

dim = size(training,2);
[gindex, groups, glevels] = grp2idx(group);
N_c = size(groups,1);

N_samples = [];
for k = 1:N_c
    N_samples(k,1) = size(find(gindex == glevels(k,1)),1);
end; clear k
if ~isempty(find(N_samples ~= N_samples(1))), error(''), end
N_samples = N_samples(1);

classComb = nchoosek([1:N_c], 2);
NclassComb = size(classComb,1);

r = [];
for iter = 1:N_iter
    
    idx = crossvalind('Kfold', N_samples, 2);
    idx = repmat(idx,[N_c, 1]);
    while length(idx) > length(gindex),
        gindex(end+1) = 0;
    end
    
    ftpcc = [];% Fisher transformed Pearson's correlation coefficient
    for k = 1:NclassComb
        
        training11 = training([idx == 1 & gindex == classComb(k,1)], :);
        training12 = training([idx == 1 & gindex == classComb(k,2)], :);
        m_training1 = mean(training11,1) - mean(training12,1);
        
        % training21 = training([idx == 2 & gindex == classComb(k,1)], :);
        % training22 = training([idx == 2 & gindex == classComb(k,2)], :);
        % m_training2 = mean(training21,1) - mean(training22,1);
        
        % sample11 = sample([idx == 1 & gindex == classComb(k,1)], :);
        % sample12 = sample([idx == 1 & gindex == classComb(k,2)], :);
        % m_sample1 = mean(sample11,1) - mean(sample12,1);
        
        sample21 = sample([idx == 2 & gindex == classComb(k,1)], :);
        sample22 = sample([idx == 2 & gindex == classComb(k,2)], :);
        m_sample2 = mean(sample21,1) - mean(sample22,1);
        
        pcc = corr(m_training1.', m_sample2.');% Pearson's correlation coefficient
        % pcc = corr(m_training2.', m_sample1.');% Pearson's correlation coefficient
        % pcc = corr(m_training1.', m_training2.');% Pearson's correlation coefficient
        % pcc = corr(m_sample1.', m_sample2.');% Pearson's correlation coefficient
        
        % ftpcc(k,1) = 0.5 * log((1+pcc) / (1-pcc));% Fisher transformation
        ftpcc(k,1) = atanh(pcc);% Fisher transformation
        
        % clear training11 training12 training21 training22 sample11 sample12 sample21 sample22
        % clear m_training1 m_training2 m_sample1 m_sample2
        % clear pcc
    end;% clear k
    
    r(iter, 1) = mean(ftpcc, 1);
    % clear idx ftpcc
end; clear iter
