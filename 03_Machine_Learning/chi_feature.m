% Step 1: Feature Selection Using Chi-Square Statistics
[selectedFeatureScores, chi2Indices] = fscchi2(predictorVars, responseVar);

% Step 2: Sort the Features by Score in Descending Order
[sortedScores, sortedIndices] = sort(selectedFeatureScores, 'descend');

% Step 3: Select Top N Features
numFeaturesToSelect = 50; % Specify the number of features to select
% Ensure we do not exceed available features
numFeaturesToSelect = min(numFeaturesToSelect, length(sortedIndices));

selectedFeatureIndices = sortedIndices(1:numFeaturesToSelect); % Indices of top features
selectedFeatureScores = sortedScores(1:numFeaturesToSelect);  % Scores of top features

% Step 4: Extract Selected Feature Names and Predictors
selectedFeatureNames = predictorVars.Properties.VariableNames(selectedFeatureIndices);
selectedPredictors = table2array(predictorVars(:, selectedFeatureIndices));

% Step 5: Save the Selected Predictors and Scores
save('SelectedFeatures_ChiSquare.mat', 'selectedPredictors', 'selectedFeatureNames', 'selectedFeatureScores');

% Step 6: Scale the Bubble Sizes Based on Feature Scores
bubbleSizes = selectedFeatureScores * 0.01; % Adjust scale factor for better visualization

% Step 7: Create the Bubble Plot
figure;
scatter(1:numFeaturesToSelect, selectedFeatureScores, bubbleSizes, selectedFeatureScores, ...
    'filled', 'MarkerFaceAlpha', 0.7);

colormap(parula); % Apply a colormap
colorbar;         % Add a color bar
caxis([min(selectedFeatureScores) max(selectedFeatureScores)]); % Set color bar limits

% Add Labels and Title
xticks(1:numFeaturesToSelect); 
xticklabels(selectedFeatureNames); 
xtickangle(45); 
xlabel('Selected Features');
ylabel('Chi-Square Scores');
title('Bubble Plot of Chi-Square Selected Features');
grid on; 

% Step 8: Enhance Visualization
set(gca, 'FontSize', 10, 'LineWidth', 1.5); % Adjust font size and axis line width
set(gcf, 'Position', [100, 100, 1400, 700]); % Set figure size

% Step 9: Display Feature Scores and Names in the Command Window
disp('Selected Features and Scores:');
for i = 1:numFeaturesToSelect
    fprintf('Feature: %s, Score: %.4f\n', selectedFeatureNames{i}, selectedFeatureScores(i));
end
%%
%% Step 1: Define Response and Predictor Variables
responseVar = responseVar;  % Binary class (0 and 1)
predictors = selectedPredictors; % Selected predictors from Chi-Square
featureNames = selectedFeatureNames; % Feature names

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
[autoModel, bayesianResults_ChiSquare] = fitcauto(X_train, y_train, ...
    'OptimizeHyperparameters', 'all', ...
    'HyperparameterOptimizationOptions', optimizationOptions); 

%% Step 4: Save Bayesian Optimization Results
bayesianResultsTable = bayesianResults_ChiSquare.XTrace;  
bayesianResultsTable.ObjectiveValue = bayesianResults_ChiSquare.ObjectiveTrace;  
writetable(bayesianResultsTable, 'ChiSquare_Bayesian_Optim_results.xlsx', 'Sheet', 'Bayesian_Optimization');
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
    'F1_Score', (2 * (confMat(2,2) / (confMat(2,2) + confMat(1,2))) * ...
                (confMat(2,2) / (confMat(2,2) + confMat(2,1)))) / ...
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

writetable(performanceMetricsTable, 'ChiSquare_Model_Performance.xlsx', 'Sheet', 'Performance Metrics');
disp('Performance metrics saved.');
