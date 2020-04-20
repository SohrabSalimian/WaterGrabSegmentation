function [NoiseCorrelation, NoiseResp, RoiKeep ]= NeuralDataNoiseCorr(EventLockedDat, TimeLength, NumRois, LR, neuropil)
%NeuralDataNoiseCorr takes in as input the eventLockedData, length of time
%and number of Rois. It returns the noise correlation matrix across all
%trials as well as the noise response matrix for the left and right trials.


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


RightTrials = EvntLockedMat(:, :, Right);
LeftTrials = EvntLockedMat(:, :, Left);
RightTrialAvg = mean(RightTrials, [1, 3]); 
LeftTrialAvg = mean(LeftTrials, [1, 3]);

RightTrialFR = squeeze(mean(RightTrials, 1))';
LeftTrialFR = squeeze(mean(LeftTrials, 1))';


RightNoiseResp = reshape(RightTrialFR - RightTrialAvg, [], length(RoiKeep));
RightNoiseResp(RightNoiseResp < 0) = 0;
LeftNoiseResp = reshape(LeftTrialFR - LeftTrialAvg, [], length(RoiKeep));
LeftNoiseResp(LeftNoiseResp < 0) = 0;

NoiseResp = cat(1, RightNoiseResp, LeftNoiseResp);
NoiseCorrelation = corrcoef(NoiseResp);
end

