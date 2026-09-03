% Perform PCA on the predictor variables
[coeff, score, latent, tsquared, explained] = pca(table2array(predictorVars));

% Calculate cumulative explained variance
cumulativeExplained = cumsum(explained);

% Select the number of components explaining at least 90% variance
numComponents = find(cumulativeExplained >= 90, 1);

% Reduced data with selected principal components
reducedData = score(:, 1:numComponents);

% Identify the contribution of each original feature to the principal components
% Absolute loadings represent the contribution strength
featureContribution = abs(coeff(:, 1:numComponents));

% Sum the absolute loadings across the selected components
featureImportance = sum(featureContribution, 2);

% Sort features by importance
[sortedImportance, sortedIndices] = sort(featureImportance, 'descend');

% Select top features contributing to the selected components
% You can adjust the number of features to display (e.g., top 20)
numTopFeatures = 20;
selectedFeatureIndices = sortedIndices(1:numTopFeatures);
selectedFeatureNames = predictorVars.Properties.VariableNames(selectedFeatureIndices);

% Display the selected feature names and their importance scores
disp('Selected Features Based on PCA Contribution:');
for i = 1:numTopFeatures
    fprintf('Feature: %s, Contribution Score: %.4f\n', selectedFeatureNames{i}, sortedImportance(i));
end

% Visualization of explained variance
figure;
bar(explained, 'FaceAlpha', 0.6);
hold on;
plot(cumulativeExplained, '-or', 'LineWidth', 2);
yline(95, '--k', '90% Variance Threshold', 'LabelHorizontalAlignment', 'left');

xlabel('Principal Components');
ylabel('Explained Variance (%)');

legend('Explained Variance', 'Cumulative Variance', '90% Threshold');
grid on;
set(gca, 'FontSize', 12);
hold off;
%%
rng default
%% Step 1: Define Response and Predictor Variables
responseVar = responseVar;  % Binary class (0 and 1)
predictors = reducedData;   % Use reduced principal components directly
featureNames = strcat("PC", string(1:size(reducedData, 2))); % Rename features as PC1, PC2, etc.

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
[autoModel, bayesianResults_PCA] = fitcauto(X_train, y_train, ...
    'OptimizeHyperparameters', 'all', ...
    'HyperparameterOptimizationOptions', optimizationOptions); 

%% Step 4: Save Bayesian Optimization Results
bayesianResultsTable = bayesianResults_PCA.XTrace;  
bayesianResultsTable.ObjectiveValue = bayesianResults_PCA.ObjectiveTrace;  
writetable(bayesianResultsTable, 'PCA_Bayesian_Optim_results.xlsx', 'Sheet', 'Bayesian_Optimization');
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

writetable(performanceMetricsTable, 'PCA_Model_Performance.xlsx', 'Sheet', 'Performance Metrics');
disp('Performance metrics saved.');
