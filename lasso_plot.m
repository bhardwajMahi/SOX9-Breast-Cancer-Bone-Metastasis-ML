% Read Excel sheets with the first row as headers
clc;
clear;
file1 = 'Data_2.xlsx';
file2 = 'Data_5.xlsx';
file3 = 'Data_3.xlsx';
file4 = 'Data_1.xlsx';
file5 = 'Data_4.xlsx';


% Read the tables, ensuring the first row is used as headers
data1 = readtable(file1, 'ReadVariableNames', true, 'VariableNamingRule', 'preserve');
data2 = readtable(file2, 'ReadVariableNames', true, 'VariableNamingRule', 'preserve');
data3 = readtable(file3, 'ReadVariableNames', true, 'VariableNamingRule', 'preserve');
data4 = readtable(file4, 'ReadVariableNames', true, 'VariableNamingRule', 'preserve');
data5 = readtable(file5, 'ReadVariableNames', true, 'VariableNamingRule', 'preserve');

% Verify that headers are correctly identified
if isempty(data1.Properties.VariableNames) || isempty(data2.Properties.VariableNames) || isempty(data3.Properties.VariableNames)...
        || isempty(data4.Properties.VariableNames) || isempty(data5.Properties.VariableNames) 
    error('Headers not correctly identified. Please check the Excel file for formatting issues.');
end

% Get all unique headers from both tables
headers1 = data1.Properties.VariableNames;
headers2 = data2.Properties.VariableNames;
headers3 = data3.Properties.VariableNames;
headers4 = data4.Properties.VariableNames;
headers5 = data5.Properties.VariableNames;

% Combine unique headers from all three tables iteratively
allHeaders = union(headers1, headers2, 'stable'); % Union of first two sets
allHeaders = union(allHeaders, headers3, 'stable'); % Add the third set
allHeaders = union(allHeaders, headers4, 'stable'); % Add the third set
allHeaders = union(allHeaders, headers5, 'stable'); % Add the third set


% Align headers for data1
for i = 1:length(allHeaders)
    if ~ismember(allHeaders{i}, data1.Properties.VariableNames)
        data1.(allHeaders{i}) = nan(height(data1), 1); % Add missing columns with NaN
    end
end

% Align headers for data2
for i = 1:length(allHeaders)
    if ~ismember(allHeaders{i}, data2.Properties.VariableNames)
        data2.(allHeaders{i}) = nan(height(data2), 1); % Add missing columns with NaN
    end
end

% Align headers for data2
for i = 1:length(allHeaders)
    if ~ismember(allHeaders{i}, data3.Properties.VariableNames)
        data3.(allHeaders{i}) = nan(height(data3), 1); % Add missing columns with NaN
    end
end

for i = 1:length(allHeaders)
    if ~ismember(allHeaders{i}, data4.Properties.VariableNames)
        data4.(allHeaders{i}) = nan(height(data4), 1); % Add missing columns with NaN
    end
end

for i = 1:length(allHeaders)
    if ~ismember(allHeaders{i}, data5.Properties.VariableNames)
        data5.(allHeaders{i}) = nan(height(data5), 1); % Add missing columns with NaN
    end
end


% Reorder columns to match the unique headers
data1 = data1(:, allHeaders);
data2 = data2(:, allHeaders);
data3 = data3(:, allHeaders);
data4 = data4(:, allHeaders);
data5 = data5(:, allHeaders);

% Ensure consistent data types for all columns
for i = 1:length(allHeaders)
    column1 = data1.(allHeaders{i});
    column2 = data2.(allHeaders{i});
    column3 = data3.(allHeaders{i});
    column4 = data4.(allHeaders{i});
    column5 = data5.(allHeaders{i});
    % Check if the column is a cell array in either table
    if iscell(column1) || iscell(column2) || iscell(column3) || iscell(column4) || iscell(column5)
        % Convert both columns to cell arrays of strings
        data1.(allHeaders{i}) = cellstr(string(column1));
        data2.(allHeaders{i}) = cellstr(string(column2));
        data3.(allHeaders{i}) = cellstr(string(column3));
        data4.(allHeaders{i}) = cellstr(string(column4));
        data5.(allHeaders{i}) = cellstr(string(column5));
    else
        % Convert both columns to double if numeric
        if isnumeric(column1) || isnumeric(column2) || isnumeric(column3) || isnumeric(column4) || isnumeric(column5)
            data1.(allHeaders{i}) = double(column1);
            data2.(allHeaders{i}) = double(column2);
            data3.(allHeaders{i}) = double(column3);
            data4.(allHeaders{i}) = double(column4);
            data5.(allHeaders{i}) = double(column5);
        end
    end
end

% Combine the two tables
mergedData = [data1; data2; data3; data4; data5];

% Write the merged table back to an Excel file
outputFile = 'MergedData.xlsx';
writetable(mergedData, outputFile);

headers = mergedData.Properties.VariableNames;
disp(headers);

%%


% Assume 'mergedData' is your combined table
transformed_table = mergedData;

% Check if the second column is binary class and calculate the class counts
binaryClassColumn = transformed_table{:, 2}; % Extract the second column
if ~all(ismember(binaryClassColumn, [0, 1]))
    error('The second column is not binary (0 or 1). Please check the data.');
end

% Calculate class distribution
classCounts = [sum(binaryClassColumn == 0), sum(binaryClassColumn == 1)];

% Create a bar plot with different colors for each class
figure;
bar(0:1, classCounts, 'FaceColor', 'flat');
colormap([0.2 0.6 1; 1 0.4 0.2]); % Define custom colors (blue and red)
barColors = colormap;

% Set individual bar colors
b = bar(0:1, classCounts);
b.FaceColor = 'flat';
b.CData(1, :) = barColors(1, :); % Color for Class 0
b.CData(2, :) = barColors(2, :); % Color for Class 1

% Add labels, title, and styling
xlabel('Class', 'FontSize', 14);
ylabel('Number of Samples', 'FontSize', 14);
title('Class Distribution', 'FontSize', 14);
xticks(0:1);
xticklabels({'Class 0', 'Class 1'});
set(gca, 'FontSize', 14); % Adjust X-tick and Y-tick font sizes
grid on;


%%
%%
% Check for NaN values in the table
features = transformed_table(:, 3:end); % Assuming genes start from the 3rd column
status = transformed_table.Status;      % Binary classification target (0 or 1)
features.Patient=[];
nanSummary = varfun(@(x) any(isnan(x)), features, 'OutputFormat', 'table');

% Display columns with NaN values
columnsWithNaN = transformed_table.Properties.VariableNames(table2array(nanSummary) == 1);
disp('Columns with NaN values:');
disp(columnsWithNaN);

% Check the total number of NaN values in the table
totalNaNs = sum(sum(ismissing(transformed_table)));
disp(['Total number of NaN values: ', num2str(totalNaNs)]);
%%
% Replace all NaN values in the table with 0
features = standardizeMissing(features, NaN); % Ensure NaN is recognized as missing
features= fillmissing(features, 'constant', 0);

% Display a message to confirm the operation
disp('All NaN values have been replaced with 0.');
%%
%%
%% Lasso Feature Selection with Improved Filtering and Visualization

% Set random seed for reproducibility
rng default;

% Define response and predictor variables
responseVar = status;       % Binary class (0 and 1)
predictorVars = features;   % Predictor variables
predictorVars.("PCDHGA3///PCDHGA5///PCDHGA6///PCDHGA10///PCDHGA11///PCDHGA12///")=[];         
predictors = table2array(predictorVars);
featureNames = predictorVars.Properties.VariableNames;


% Step 1: Lasso Regression with Cross-Validation
lambdaValues = logspace(-4, 0, 100); % Smaller min lambda encourages more features

% Perform Lasso Regression
[B, FitInfo] = lasso(predictors, responseVar, 'CV', 5, 'Lambda', lambdaValues);

% Step 2: Select Lambda Based on Minimum MSE
idxLambdaMinMSE = FitInfo.IndexMinMSE;

% Adjust Lambda for Less Regularization (Selecting More Features)
idxLambdaLessRegularization = max(idxLambdaMinMSE - 10, 1); % Move towards smaller lambda

% Step 3: Identify Selected Features
selectedFeatures = B(:, idxLambdaLessRegularization) ~= 0; % Logical array of selected features
selectedFeatureIndices = find(selectedFeatures);
selectedFeatureNames = featureNames(selectedFeatureIndices);
featureScores = abs(B(selectedFeatures, idxLambdaLessRegularization)); % Feature importance scores

% Step 4: Filter Out Weak Features (Thresholding)
threshold = 0.0099; % Threshold for filtering weak features
importantFeatureIdx = featureScores >= threshold; % Keep features above threshold
filteredFeatureNames = selectedFeatureNames(importantFeatureIdx);
filteredFeatureScores = featureScores(importantFeatureIdx);

% Display Filtered Important Features
disp('Filtered Important Features:');
for i = 1:length(filteredFeatureNames)
    fprintf('Feature: %s, Score: %.6f\n', filteredFeatureNames{i}, filteredFeatureScores(i));
end

% Step 5: Visualization (Bubble Plot)
% Scale bubble sizes with log-scaling for better differentiation
bubbleSizes = log1p(filteredFeatureScores) * 50000; % log1p avoids log(0)

% Create Bubble Plot
figure;
scatter(1:length(filteredFeatureScores), filteredFeatureScores, bubbleSizes, ...
    filteredFeatureScores, 'filled', 'MarkerFaceAlpha', 0.7);

% Colormap and Colorbar
colormap(parula);
colorbar;

% Add Labels and Title
xticks(1:length(filteredFeatureScores));
xticklabels(filteredFeatureNames);
xtickangle(45); % Rotate labels for better readability
xlabel('Filtered Feature Names');
ylabel('Feature Scores');


% Grid and Aesthetics
grid on;
set(gca, 'FontSize', 12, 'LineWidth', 1.5);
set(gcf, 'Position', [100, 100, 1200, 600]); % Adjust figure size

% Step 6: Save Selected Features and Scores
save('Filtered_Lasso_Features.mat', 'filteredFeatureNames', 'filteredFeatureScores');

%%
%% Machine Learning Model Development Using fitcauto
%% Machine Learning Model Development Using fitcauto with Enhanced Evaluation

% Set random seed for reproducibility


% Define response and predictor variables
responseVar = status;       % Binary classification (0 and 1)
predictorVars = features;   % Predictor variables
predictors = table2array(predictorVars);
featureNames = predictorVars.Properties.VariableNames;

% Step 1: Load the Filtered Important Features
% Assuming 'filteredFeatureNames' and 'filteredFeatureScores' are available
% If saved previously, load them:
% load('Filtered_Lasso_Features.mat');
rng default;

% Extract predictors based on the selected important features
selectedPredictors = predictors(:, ismember(featureNames, filteredFeatureNames));
selectedPredictorVars = array2table(selectedPredictors, 'VariableNames', filteredFeatureNames);

% Step 2: Partition the Data for Training and Testing (80-20 Split)
cv = cvpartition(responseVar, 'HoldOut', 0.2);
trainIdx = training(cv);
testIdx = test(cv);

X_train = selectedPredictorVars(trainIdx, :);
y_train = responseVar(trainIdx);

X_test = selectedPredictorVars(testIdx, :);
y_test = responseVar(testIdx);

optimizationOptions = struct("UseParallel",true,'ShowPlots', true, 'MaxObjectiveEvaluations', 100, ...
    'Verbose', 1, 'SaveIntermediateResults', true);

bayesianOptions = struct("UseParallel",true);
% Train the model with automatic hyperparameter tuning
[autoModel,bayesianResults_lasso] = fitcauto(X_train, y_train, ...
    'OptimizeHyperparameters', 'all', ...
    'HyperparameterOptimizationOptions', optimizationOptions); 
% Convert Bayesian optimization results to a table
bayesianResultsTable = bayesianResults_lasso.XTrace;  % Extract hyperparameter values
bayesianResultsTable.ObjectiveValue = bayesianResults_lasso.ObjectiveTrace; % Append objective function values
bayesianResultsTable.IterTimeTrace=bayesianResults_lasso.IterationTimeTrace

% Define the Excel file name
fileName = 'Lasso_Bayesian_Optim_results.xlsx';

% Save the results to an Excel file
writetable(bayesianResultsTable, fileName, 'Sheet', 'Bayesian_Optimization');



%% Step 4: Model Evaluation

% Predictions for Training, Testing, and Overall Data
trainPredictions = predict(autoModel, X_train);
testPredictions = predict(autoModel, X_test);
overallPredictions = predict(autoModel, selectedPredictorVars);

% Scores (probabilities) for AUC-ROC
[~, trainScores] = predict(autoModel, X_train);
[~, testScores] = predict(autoModel, X_test);
[~, overallScores] = predict(autoModel, selectedPredictorVars);



%% Step 5: Compute Confusion Matrices

% Training Confusion Matrix
confMatTrain = confusionmat(y_train, trainPredictions);
disp('Training Confusion Matrix:');
disp(confMatTrain);

% Testing Confusion Matrix
confMatTest = confusionmat(y_test, testPredictions);
disp('Testing Confusion Matrix:');
disp(confMatTest);

% Overall Confusion Matrix
confMatOverall = confusionmat(responseVar, overallPredictions);
disp('Overall Confusion Matrix:');
disp(confMatOverall);

%% Step 6: Plot Confusion Matrices

figure;
tiledlayout(1, 3); % Create a 1-row, 3-column layout for subplots

% Training Set Confusion Matrix
nexttile;
confusionchart(confMatTrain, {'Class 0', 'Class 1'}, 'Title', 'Training Confusion Matrix');
xlabel('Predicted Class'); ylabel('Actual Class');

% Testing Set Confusion Matrix
nexttile;
confusionchart(confMatTest, {'Class 0', 'Class 1'}, 'Title', 'Testing Confusion Matrix');
xlabel('Predicted Class'); ylabel('Actual Class');

% Overall Confusion Matrix
nexttile;
confusionchart(confMatOverall, {'Class 0', 'Class 1'}, 'Title', 'Overall Confusion Matrix');
xlabel('Predicted Class'); ylabel('Actual Class');

% Adjust the figure size
set(gcf, 'Position', [100, 100, 1200, 400]); % Adjust width and height for better visualization


%% Step 6: Accuracy Calculation

trainAccuracy = sum(trainPredictions == y_train) / length(y_train) * 100;
testAccuracy = sum(testPredictions == y_test) / length(y_test) * 100;
overallAccuracy = sum(overallPredictions == responseVar) / length(responseVar) * 100;

fprintf('Training Accuracy: %.2f%%\n', trainAccuracy);
fprintf('Testing Accuracy: %.2f%%\n', testAccuracy);
fprintf('Overall Accuracy: %.2f%%\n', overallAccuracy);

%% Step 7: ROC Curve and AUC for Training, Testing, and Overall Data

% Training AUC-ROC
[XrocTrain, YrocTrain, ~, AUC_Train] = perfcurve(y_train, trainScores(:, 2), 1);

% Testing AUC-ROC
[XrocTest, YrocTest, ~, AUC_Test] = perfcurve(y_test, testScores(:, 2), 1);

% Overall AUC-ROC
[XrocOverall, YrocOverall, ~, AUC_Overall] = perfcurve(responseVar, overallScores(:, 2), 1);

% Plot ROC Curves
figure;
plot(XrocTrain, YrocTrain, '-b', 'LineWidth', 2);
hold on;
plot(XrocTest, YrocTest, '-r', 'LineWidth', 2);
plot(XrocOverall, YrocOverall, '-g', 'LineWidth', 2);
xlabel('False Positive Rate');
ylabel('True Positive Rate');
title('ROC Curves for Training, Testing, and Overall Data');
legend(['Train AUC = ' num2str(AUC_Train, '%.3f')], ...
       ['Test AUC = ' num2str(AUC_Test, '%.3f')], ...
       ['Overall AUC = ' num2str(AUC_Overall, '%.3f')]);
grid on;
hold off;

%% Step 8: Feature Importance Visualization (if supported by the model)

if isprop(autoModel, 'Beta') && ~isempty(autoModel.Beta)
    % For linear models
    featureImportance = abs(autoModel.Beta);
    [sortedImportance, sortedIdx] = sort(featureImportance, 'descend');
    importantFeatures = filteredFeatureNames(sortedIdx);

    % Bar Plot for Feature Importance
    figure;
    bar(sortedImportance);
    set(gca, 'XTickLabel', importantFeatures, 'XTickLabelRotation', 45);
    xlabel('Features');
    ylabel('Importance Score');
    title('Feature Importance Based on Model Coefficients');
    grid on;
end
%%
%% Step 9: Compute Performance Metrics
% Function to compute metrics from confusion matrix
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

% Compute metrics for Training, Testing, and Overall datasets
metricsTrain = computeMetrics(confMatTrain);
metricsTest = computeMetrics(confMatTest);
metricsOverall = computeMetrics(confMatOverall);

% Display Metrics in Command Window
fprintf('\nTraining Metrics:\n');
disp(metricsTrain);
fprintf('\nTesting Metrics:\n');
disp(metricsTest);
fprintf('\nOverall Metrics:\n');
disp(metricsOverall);

%% Step 10: Save Performance Metrics to Excel
performanceMetricsTable = table({'Training'; 'Testing'; 'Overall'}, ...
    [metricsTrain.Accuracy; metricsTest.Accuracy; metricsOverall.Accuracy], ...
    [metricsTrain.Precision; metricsTest.Precision; metricsOverall.Precision], ...
    [metricsTrain.Recall_Sensitivity; metricsTest.Recall_Sensitivity; metricsOverall.Recall_Sensitivity], ...
    [metricsTrain.Specificity; metricsTest.Specificity; metricsOverall.Specificity], ...
    [metricsTrain.F1_Score; metricsTest.F1_Score; metricsOverall.F1_Score], ...
    [AUC_Train; AUC_Test; AUC_Overall], ...
    'VariableNames', {'Dataset', 'Accuracy', 'Precision', 'Recall_Sensitivity', 'Specificity', 'F1_Score', 'AUC'});

writetable(performanceMetricsTable, 'Lasso_Model_Performance.xlsx', 'Sheet', 'Performance Metrics');
disp('Performance metrics saved.');

%% Step 9: Save the Trained Model for Future Use
save('Trained_lasso_AutoML_Model.mat', 'autoModel');


