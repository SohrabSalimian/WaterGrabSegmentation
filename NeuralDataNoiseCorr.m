function [NoiseCorrelation, ClustNoiseResp, RoiKeep ]= NeuralDataNoiseCorr(EventLockedDat, TimeLength,...
    NumRois, LR, ClusterIds, neuropil)
%NeuralDataNoiseCorr takes in as input the eventLockedData, length of time
%and number of Rois. It returns the noise correlation matrix across all
%trials as well as the noise response matrix for the left and right trials.
%Modifying for Clustering

EvntLockedMat = [EventLockedDat(:).data];
EvntLockedMat = reshape(EvntLockedMat, length(TimeLength), NumRois, []);

Left = find(LR ==1 );
Right = find(LR == 2);
RoiSums = sum(EvntLockedMat, [1,3]);

if neuropil == 1
    thresh = median(RoiSums);
else
    thresh = median(RoiSums)/2;
    
end

RoiRemoved = (RoiSums < thresh);
[~, RoiKeep] = find(RoiRemoved == 0);
EvntLockedMat = EvntLockedMat(:, RoiKeep, :);

Shape = size(EvntLockedMat);
%PSTH by Cluster
%Getting unique clusterIds and total number of clusters
Clusts = unique(ClusterIds);
Clusts = Clusts(~isnan(Clusts)); 
NumClusts = length(Clusts(~isnan(Clusts)));

%Storing the PSTH for each cluster within an array. 
ClustNoiseResp = zeros(Shape(2), Shape(3));
for i=1:NumClusts
    Cluster = find(ClusterIds == Clusts(i));
    PSTH = mean(EvntLockedMat(:, :, Cluster), [1, 3]);
    
    Responses = sum(EvntLockedMat(:, :, Cluster), 1);
    Diff = Responses - PSTH;
    Diff(Diff < 0) = 0;
    ClustNoiseResp(:, Cluster) = Diff;
    
end


% RightTrials = EvntLockedMat(:, :, Right);
% LeftTrials = EvntLockedMat(:, :, Left);
% RightTrialAvg = mean(RightTrials, [1, 3]); 
% LeftTrialAvg = mean(LeftTrials, [1, 3]);
% 
% RightTrialFR = squeeze(mean(RightTrials, 1))';
% LeftTrialFR = squeeze(mean(LeftTrials, 1))';
% 
% 
% RightNoiseResp = reshape(RightTrialFR - RightTrialAvg, [], length(RoiKeep));
% RightNoiseResp(RightNoiseResp < 0) = 0;
% LeftNoiseResp = reshape(LeftTrialFR - LeftTrialAvg, [], length(RoiKeep));
% LeftNoiseResp(LeftNoiseResp < 0) = 0;
% 
% NoiseResp = cat(1, RightNoiseResp, LeftNoiseResp);
NoiseCorrelation = corrcoef(ClustNoiseResp');
end
