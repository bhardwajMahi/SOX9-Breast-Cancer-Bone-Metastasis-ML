%% Step 1: Reduce the dataset size using correlation-based filtering
correlationThreshold = 0.1; % Adjust as needed
correlations = corr(table2array(predictorVars), responseVar);

% Filter features based on correlation threshold
selectedIdx = abs(correlations) > correlationThreshold; % Logical index for selected features
reducedPredictorVars = predictorVars(:, selectedIdx); % Keep only selected columns
reducedFeatureNames = featureNames(selectedIdx); % Keep corresponding feature names

%% Step 2: Discretize data to reduce memory usage
numBins = 10; % Number of bins for discretization
binnedPredictors = zeros(size(reducedPredictorVars, 1), size(reducedPredictorVars, 2));

for i = 1:size(reducedPredictorVars, 2)
    binnedPredictors(:, i) = discretize(table2array(reducedPredictorVars(:, i)), numBins);
end

%% Step 3: Apply mRMR feature selection
numFeaturesToSelect = 50; % Specify the number of features to select
mrmrIndices = fscmrmr(array2table(binnedPredictors), responseVar);

% Ensure we do not exceed available features
numFeaturesToSelect = min(numFeaturesToSelect, length(mrmrIndices));

%% Step 4: Extract selected feature names and predictors
finalSelectedFeatureIndices = mrmrIndices(1:numFeaturesToSelect); % Top N features
selectedFeatureNames = reducedFeatureNames(finalSelectedFeatureIndices); % Names of selected features
selectedPredictors = table2array(reducedPredictorVars(:, finalSelectedFeatureIndices)); % Selected predictors

%% Step 5: Assign feature importance scores
% Using inverse of rank as a proxy for importance (higher rank = lower score)
selectedFeatureScores = (numFeaturesToSelect:-1:1)'; 

%% Step 6: Clean Feature Names for Plotting
cleanFeatureNames = selectedFeatureNames; % Copy original names

for i = 1:length(cleanFeatureNames)
    % Check if the feature name contains " /// " and extract only the first part
    if contains(cleanFeatureNames{i}, ' /// ')
        parts = split(cleanFeatureNames{i}, ' /// ');
        cleanFeatureNames{i} = parts{1}; % Keep only the first part
    end
end

%% Step 7: Visualize feature importance using a bubble plot
bubbleSizes = selectedFeatureScores * 10; % Scale bubble sizes for better visualization

figure;
scatter(1:numFeaturesToSelect, selectedFeatureScores, bubbleSizes, selectedFeatureScores, ...
    'filled', 'MarkerFaceAlpha', 0.7);

colormap(parula); 
colorbar; 
caxis([min(selectedFeatureScores) max(selectedFeatureScores)]); 

% Add labels and title
xticks(1:numFeaturesToSelect); 
xticklabels(cleanFeatureNames); % Use cleaned feature names
xtickangle(45); 
xlabel('Selected Features');
ylabel('Feature Importance Scores');
grid on; 

% Enhance visualization
set(gca, 'FontSize', 12, 'LineWidth', 1.5); 
set(gcf, 'Position', [100, 100, 1400, 700]); 

%% Step 8: Display feature scores and names in the command window
disp('Selected Features and Scores:');
for i = 1:numFeaturesToSelect
    fprintf('Feature: %s, Score: %.4f\n', cleanFeatureNames{i}, selectedFeatureScores(i));
end
%%
%% Step 1: Define Response and Predictor Variables
responseVar = responseVar;  % Binary class (0 and 1)
predictors = selectedPredictors; % Selected predictors from mRMR
featureNames = cleanFeatureNames; % Use cleaned feature names

%% Step 2: Partition the Data for Training and Testing (80-20 Split)
cv = cvpartition(responseVar, 'HoldOut', 0.2);
trainIdx = training(cv);
testIdx = test(cv);

X_train = predictors(trainIdx, :);
y_train = responseVar(trainIdx);

X_test = predictors(testIdx, :);
y_test = responseVar(testIdx);

%% Step 3: Train the Model Using fitcauto (Automatic Model Selection)
optimizationOptions = struct("UseParallel",true,'ShowPlots', true, 'MaxObjectiveEvaluations', 100, 'Verbose', 1);
[autoModel, bayesianResults_mRMR] = fitcauto(X_train, y_train, ...
    'OptimizeHyperparameters', 'all', ...
    'HyperparameterOptimizationOptions', optimizationOptions); 

%% Step 4: Save Bayesian Optimization Results
bayesianResultsTable = bayesianResults_mRMR.XTrace;  
bayesianResultsTable.ObjectiveValue = bayesianResults_mRMR.ObjectiveTrace;  
writetable(bayesianResultsTable, 'mRMR_Bayesian_Optim_results.xlsx', 'Sheet', 'Bayesian_Optimization');
disp('Bayesian Optimization results saved.');

%% Step 5: Make Predictions for Training, Testing, and Overall Data
trainPredictions = predict(autoModel, X_train);
testPredictions = predict(autoModel, X_test);
overallPredictions = predict(autoModel, predictors);

% Scores for AUC-ROC Calculation
[~, trainScores] = predict(autoModel, X_train);
[~, testScores] = predict(autoModel, X_test);
[~, overallScores] = predict(autoModel, predictors);

%% Step 6: Compute Confusion Matrices
confMatTrain = confusionmat(y_train, trainPredictions);
confMatTest = confusionmat(y_test, testPredictions);
confMatOverall = confusionmat(responseVar, overallPredictions);

disp('Training Confusion Matrix:'); disp(confMatTrain);
disp('Testing Confusion Matrix:'); disp(confMatTest);
disp('Overall Confusion Matrix:'); disp(confMatOverall);

%% Step 7: Compute Performance Metrics

% Helper function for performance calculations
computeMetrics = @(confMat) struct( ...
    'Accuracy', sum(diag(confMat)) / sum(confMat(:)) * 100, ...
    'Precision', confMat(2,2) / (confMat(2,2) + confMat(1,2)), ...
    'Recall_Sensitivity', confMat(2,2) / (confMat(2,2) + confMat(2,1)), ...
    'Specificity', confMat(1,1) / (confMat(1,1) + confMat(1,2)), ...
    'F1_Score', 2 * (confMat(2,2) / (confMat(2,2) + confMat(1,2))) * ...
               (confMat(2,2) / (confMat(2,2) + confMat(2,1))) / ...
               ((confMat(2,2) / (confMat(2,2) + confMat(1,2))) + ...
               (confMat(2,2) / (confMat(2,2) + confMat(2,1)))) ...
);


metricsTrain = computeMetrics(confMatTrain);
metricsTest = computeMetrics(confMatTest);
metricsOverall = computeMetrics(confMatOverall);

% Display metrics
fprintf('\nTraining Metrics:\n');
disp(metricsTrain);
fprintf('\nTesting Metrics:\n');
disp(metricsTest);
fprintf('\nOverall Metrics:\n');
disp(metricsOverall);

%% Step 8: Compute and Plot ROC-AUC Curve for Training, Testing, and Overall Data
[XrocTrain, YrocTrain, ~, AUC_Train] = perfcurve(y_train, trainScores(:,2), 1);
[XrocTest, YrocTest, ~, AUC_Test] = perfcurve(y_test, testScores(:,2), 1);
[XrocOverall, YrocOverall, ~, AUC_Overall] = perfcurve(responseVar, overallScores(:,2), 1);

figure;
plot(XrocTrain, YrocTrain, '-b', 'LineWidth', 2); hold on;
plot(XrocTest, YrocTest, '-r', 'LineWidth', 2);
plot(XrocOverall, YrocOverall, '-g', 'LineWidth', 2);
xlabel('False Positive Rate'); ylabel('True Positive Rate');
title('ROC Curves for Training, Testing, and Overall Data');
legend(['Train AUC = ' num2str(AUC_Train, '%.3f')], ...
       ['Test AUC = ' num2str(AUC_Test, '%.3f')], ...
       ['Overall AUC = ' num2str(AUC_Overall, '%.3f')]);
grid on; hold off;

%% Step 9: Plot Confusion Matrices
figure;
tiledlayout(1, 3);

% Training Confusion Matrix
nexttile;
confusionchart(confMatTrain, {'Class 0', 'Class 1'}, 'Title', 'Training Confusion Matrix');
xlabel('Predicted Class'); ylabel('Actual Class');

% Testing Confusion Matrix
nexttile;
confusionchart(confMatTest, {'Class 0', 'Class 1'}, 'Title', 'Testing Confusion Matrix');
xlabel('Predicted Class'); ylabel('Actual Class');

% Overall Confusion Matrix
nexttile;
confusionchart(confMatOverall, {'Class 0', 'Class 1'}, 'Title', 'Overall Confusion Matrix');
xlabel('Predicted Class'); ylabel('Actual Class');

set(gcf, 'Position', [100, 100, 1200, 400]); 

%% Step 10: Save Performance Metrics to Excel
performanceMetricsTable = table({'Training'; 'Testing'; 'Overall'}, ...
    [metricsTrain.Accuracy; metricsTest.Accuracy; metricsOverall.Accuracy], ...
    [metricsTrain.Precision; metricsTest.Precision; metricsOverall.Precision], ...
    [metricsTrain.Recall_Sensitivity; metricsTest.Recall_Sensitivity; metricsOverall.Recall_Sensitivity], ...
    [metricsTrain.Specificity; metricsTest.Specificity; metricsOverall.Specificity], ...
    [metricsTrain.F1_Score; metricsTest.F1_Score; metricsOverall.F1_Score], ...
    [AUC_Train; AUC_Test; AUC_Overall], ...
    'VariableNames', {'Dataset', 'Accuracy', 'Precision', 'Recall_Sensitivity', 'Specificity', 'F1_Score', 'AUC'});

writetable(performanceMetricsTable, 'mRMR_Model_Performance.xlsx', 'Sheet', 'Performance Metrics');
disp('Performance metrics saved.');

