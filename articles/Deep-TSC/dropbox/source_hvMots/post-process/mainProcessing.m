mainDirectory = '../output';
variety = {'HV-MOTS'};
varSimp = {'Normal'};
criteria = {'1-NN', '5-NN', 'NC', 'MOTS', 'NP-MOTS', 'HV-MOTS'};
datasets = {'50Words','Adiac','ARSim','Beef','CBF','Chlorine',...
    'CinECG','Coffee','Cricket_X','Cricket_Y','Cricket_Z','DiatomSize',...
    'Earthquakes','ECG200','ECGFiveDays','FaceAll','FaceFour','FacesUCR',...
    'Fish','FordA','FordB','Gun_Point','HandOutlines','Haptics',...
    'InlineSkate','ItalyPower','Lighting2','Lighting7','MALLAT',...
    'MedicalImages','MoteStrain','NonInv_ECG1','NonInv_ECG2','OliveOil',...
    'OSULeaf','SonyAIBO1','SonyAIBO2','StarLight','SwedishLeaf',...
    'Symbols','Synthetic','Trace','Two_Patterns','TwoLeadECG',...
    'uWGestureX','uWGestureY','uWGestureZ','Wafer','WordsSynonyms','Yoga'};
distances = {'L1', 'L2', 'LI', 'LP', 'ERP', 'EDR', 'LCSS', 'DTW', ...
    'OSB', 'FFT(L2)', 'FFT(DTW)', 'ACF(L2)', 'ACF(DTW)', 'CDM'};
resultsL2 = [36.9 38.9 48.6 46.7 14.8 35 10.3 25 42.6 35.6 38 6.5, ...
28.8 12 20.3 28.6 21.6 23.1 21.7 31.8 40.9 8.7 14 63 65.8 4.5 24.6, ...
42.5 8.6 31.6 12.1 17.1 12 13.3 48.3 30.5 14.1 15.1 21.3 10 12 24 9, ...
25.3 26.1 33.8 35 0.5 38.2 17];
resultsDTWb = [24.2 39.1 44.3 46.7 0.4 35 7 17.9 23.6 19.7 18 6.5, ...
27.3 12 20.3 19.2 11.4 8.8 16 26.7 38.1 8.7 16 58.8 61.3 4.5 13.1, ...
28.8 8.6 25.3 13.4 18.5 12.9 16.7 38.4 30.5 14.1 9.5 15.7 6.2 1.7, ...
1 0.1 13.2 22.7 30.1 32.2 0.5 25.2 15.5];
resultsDTWf = [31 39.6 44.3 50 0.3 35.2 34.9 17.9 22.3 20.8 20.8 3.3, ...
27.3 23 23.2 19.2 17 9.5 16.7 26.7 38.1 9.3 16 62.3 61.6 5 13.1 27.4, ...
6.6 26.3 16.5 20.9 13.5 13.3 40.9 27.5 16.9 9.3 21 5 0.7 0 0 9.6 27.3, ...
36.6 34.2 2 35.1 16.4];
resultsLearn = [];
classes = [50 37 2 5 3 3 4 2 12 12 12 4 2 2 2 14 4 14 7 2 2 2 2 5 7 2 2,...
    7 8 10 2 42 42 4 6 2 2 3 15 6 6 4 4 2 8 8 8 2 25 2];
tsLength = [270 176 500 470 128 166 1639 286 300 300 300 345 512 96 136,...
131 350 131 463 500 500 150 2709 1092 1882 24 637 319 1024 99 84 750,...
750 570 427 70 65 1024 128 398 60 275 128 82 315 315 315 152 270 426];
trainSet = [450 390 2000 30 30 467 40 28 390 390 390 16 322 100 23 560,...
    24 200 175 2571 3601 150 1000 155 100 67 60 70 55 381 20 1800 1800,...
    30 200 20 27 1000 500 25 300 100 1000 23 896 896 896 1000 267 300];
testSet = [455 391 2000 30 900 3840 1380 28 390 390 390 306 139 100 861,...
    1690 88 2050 175 1320 810 150 300 308 550 1029 61 73 2345 760 1252,...
    1965 1965 30 242 601 953 8236 625 995 300 100 4000 1139 3582 3582,...
    3582 6174 638 3000];
for i = [23 21 20 13]
    datasets(i) = []; resultsL2(i) = []; resultsDTWb(i) = [];
    resultsDTWf(i) = []; classes(i) = []; tsLength(i) = [];
    trainSet(i) = []; testSet(i) = [];
end
TTRatio = trainSet ./ testSet;
properties = {classes, tsLength, TTRatio, trainSet, testSet};
propNames = {'Classes', 'Length', 'Ratio', 'Train', 'Test'};
bestResults = ones(length(datasets), length(criteria));
spaceResults = ones(length(datasets), length(criteria));
distResults = ones(length(datasets), length(distances));
nbComb = (2^length(distances)) - 1;
disp(nbComb);
allResults = ones(length(datasets) * nbComb, length(criteria));
distSpaceSize = zeros(length(datasets), length(criteria), length(distances), 2);
distOccur = zeros(length(distances), length(datasets), length(criteria), 2);
distOccurCumul = zeros(length(distances), length(datasets), length(criteria), 2);
distCoOccur = zeros(length(distances), length(distances), length(criteria), 2);
combosReal = ones(length(distances), nbComb);
resultsLearn = [];
for v = 1
for c = 1:length(criteria)
    fID = fopen(['distances/' varSimp{v} '_' criteria{c} '_Occur_Best.csv'], 'w');
    fprintf(fID, '.');
    for d = 1:length(distances)
        fprintf(fID, '\t%s', distances{d});
    end
    fprintf(fID, '\n');
    fclose(fID);
    fID = fopen(['distances/' varSimp{v} '_' criteria{c} '_Occur_Space.csv'], 'w');
    fprintf(fID, '.');
    for d = 1:length(distances)
        fprintf(fID, '\t%s', distances{d});
    end
    fprintf(fID, '\n');
    fclose(fID);
end
wID = fopen(['distances/' varSimp{v} '_distanceParams.txt'], 'w');
fclose(wID);
end
for v = 1
    disp(['Variety : ' variety{v}]);
    for i = 1:length(datasets)
        curDataset = datasets{i};
        fprintf('- Processing %s\n', curDataset);
        resultFolder = [mainDirectory '/' variety{v} '/' curDataset '/results'];
        resID = fopen([resultFolder '/globalResults.txt'], 'r');
        if (resID == -1)
            fprintf('   *** No results ***\n');
            continue;
        end
        curComb = 1;
        % Global results import
        while (1)
            if (feof(resID))
                break;
            end
            k = curComb;
            comb = zeros(length(distances), 1);
            for j = 1:length(distances)
                comb(j) = bitand(k, 1); 
                k = bitshift(k, -1);
            end
            dists = fgetl(resID);
            results = fgetl(resID);
            if (results == -1)
                break;
            end
            strFloats = regexp(results, ' ', 'split');
            resFloats = str2double(strFloats(1:(end-1)));
            distSplit = regexp(dists, ' ', 'split');
            if (sum(comb) == 1)
                distResults(i, comb ~= 0) = resFloats(1);
            end
            if (strcmp(distSplit(1), 'Best'))
                bestResults(i, :) = resFloats;
            end
            if (strcmp(distSplit(1), 'Space'))
                spaceResults(i, :) = resFloats;
            end
            if (curComb <= nbComb)
                allResults(curComb + ((i - 1) * nbComb), :) = resFloats;
                combosReal(:, curComb) = comb;
            end
            curComb = curComb + 1;
        end
        fclose(resID);
        % For each distance we retrieve the best parameters
        wID = fopen(['distances/' varSimp{v} '_distanceParams.txt'], 'a');
        fprintf(wID, '%s\n', datasets{i});
        for d = 1:length(distances)
            fid = fopen([mainDirectory '/' variety{v} '/' curDataset '/optimize_distance/' distances{d} '.txt'], 'r');
            if (fid == -1)
                continue;
            end
            bestVals = [];
            bestErr = 2.0;
            disp(distances{d});
            if (feof(fid))
                continue;
            end
            results = fgetl(fid);
            if (results == -1)
                continue;
            end
            distOptim = regexp(results, ' ', 'split');
            distOptimNb = str2double(distOptim(end));
            for dO = 1:distOptimNb
                curStr = fgetl(fid);
                curVals = regexp(curStr, '\t', 'split');
                err = regexp(curVals(end), '=', 'split');
                curErr = str2double(err{1}(end));
                if (curErr < bestErr)
                    bestErr = curErr;
                    bestVals = curStr;
                end
            end
            fclose(fid);
            fprintf(wID, '%s\t: %s\n', distances{d}, curStr);
        end
        fclose(wID);
        % Based on best and space results, find back corresponding combos
        for c = 1:length(criteria)
            for r = 1:nbComb
                if (allResults(r + ((i - 1) * nbComb), c) == bestResults(i, c))
                    fID = fopen(['distances/' varSimp{v} '_' criteria{c} '_Occur_Best.csv'], 'a');
                    fprintf(fID, '%s', datasets{i});
                    distOccurCumul(:, i, c, 1) = distOccurCumul(:, i, c, 1) + combosReal(:, r);
                    distSpaceSize(i, c, sum(combosReal(:, r)), 1) = distSpaceSize(i, c, sum(combosReal(:, r)), 1) + 1;
                    for d1 = 1:length(distances)
                        fprintf(fID, '\t%d', combosReal(d1, r));
                        for d2 = 1:length(distances)
                            if (d1 ~= d2 && combosReal(d1, r) == 1 && combosReal(d2, r) == 1)
                                distCoOccur(d1, d2, c, 1) = distCoOccur(d1, d2, c, 1) + 1;
                            end
                        end
                    end
                    fprintf(fID, '\n');
                    fclose(fID);
                end
                if (allResults(r + ((i - 1) * nbComb), c) == spaceResults(i, c))
                    fID = fopen(['distances/' varSimp{v} '_' criteria{c} '_Occur_Space.csv'], 'a');
                    fprintf(fID, '%s', datasets{i});
                    distOccurCumul(:, i, c, 2) = distOccurCumul(:, i, c, 2) + combosReal(:, r);
                    distSpaceSize(i, c, sum(combosReal(:, r)), 2) = distSpaceSize(i, c, sum(combosReal(:, r)), 1) + 2;
                    for d1 = 1:length(distances)
                        fprintf(fID, '\t%d', combosReal(d1, r));
                        for d2 = 1:length(distances)
                            if (d1 ~= d2 && combosReal(d1, r) == 1 && combosReal(d2, r) == 1)
                                distCoOccur(d1, d2, c, 2) = distCoOccur(d1, d2, c, 2) + 1;
                            end
                        end
                    end
                    fprintf(fID, '\n');
                    fclose(fID);
                end
            end
        end
        % Per-criteria results import
        for c = 1:length(criteria)
            resID = fopen([resultFolder '/' criteria{c} '.txt'], 'r');
            if (resID == -1)
                fprintf('   *** No results for %s ***\n', criteria{c});
                continue;
            end
            while (1)
                if (feof(resID))
                    break;
                end
                results = fgetl(resID);
                if (results == -1)
                    break;
                end
                distSplit = regexp(results, ' ', 'split');
                errors = regexp(fgetl(resID), ': ', 'split');
                errors = str2double(errors(2));
                rate = regexp(fgetl(resID), ': ', 'split');
                rate = str2double(rate(2));
                classesErrors = str2num(fgetl(resID));
                confMatrix = zeros(classes(i), classes(i));
                for cl = 1:classes(i)
                    curConfusion = fgetl(resID);
                    confMatrix(cl, :) = str2num(curConfusion);
                end
                break;
            end
            fclose(resID);
        end
    end
    minResults = [min(distResults, [], 2) bestResults(:, end)];
    bestResults = bestResults * 100;
    spaceResults = spaceResults * 100;
    distResults = distResults * 100;
    minResults = minResults * 100;
    disp(bestResults);
    disp(spaceResults);
    %% First compute critical differences (inside our criteria)
    figure; criticaldifference(bestResults, criteria);
    title('Best results'); setPaperQuality();
    figure; criticaldifference(spaceResults, criteria);
    title('Space results'); setPaperQuality();
    % Then compute critical differences (over all combinations)
    figure; criticaldifference(allResults, criteria);
    title('All results'); setPaperQuality();
    % Compute critical differences with best (against state-of-art)
    SOAResults = [resultsL2' resultsDTWb' resultsDTWf' bestResults(:, [1 end])];
    SOANames = {'L2', 'DTWb', 'DTWf', 'Multi', 'HV-MOTS'};
    figure; criticaldifference(SOAResults, SOANames);
    title('State-of-art vs. best'); setPaperQuality();
    % Compute critical differences with space (against state-of-art)
    SOAResults = [resultsL2' resultsDTWb' resultsDTWf' spaceResults(:, [1 end])];
    SOANames = {'L2', 'DTWb', 'DTWf', 'Multi', 'HV-MOTS'};
    figure; criticaldifference(SOAResults, SOANames);
    title('State-of-art vs. best'); setPaperQuality();
    %% Export the pairwise data (for scatterplot analysis)
    cResID = fopen('classif.results.space.csv', 'w');
    SOAResults = [resultsL2' resultsDTWb' resultsDTWf' spaceResults(:, end)];
    SOANames = {'L2', 'DTWb', 'DTWf', 'HV-MOTS'};
    fprintf(cResID, 'dataset');
    for c = 1:length(SOANames)
        fprintf(cResID, ',%s', SOANames{c});
    end
    fprintf(cResID, '\n');
    for i = 1:length(datasets)
        fprintf(cResID, '%s', datasets{i});
        for j = 1:length(SOANames)
            fprintf(cResID, ',%f', SOAResults(i, j) / 10.0);
        end
        fprintf(cResID, '\n');
    end
    fclose(cResID);
    SOAResults = [resultsL2' resultsDTWb' resultsDTWf' bestResults(:, end)];
    SOANames = {'L2', 'DTWb', 'DTWf', 'HV-MOTS'};
    cResID = fopen('classif.results.best.csv', 'w');
    fprintf(cResID, 'dataset');
    for c = 1:length(SOANames)
        fprintf(cResID, ',%s', SOANames{c});
    end
    fprintf(cResID, '\n');
    for i = 1:length(datasets)
        fprintf(cResID, '%s', datasets{i});
        for j = 1:length(SOANames)
            fprintf(cResID, ',%f', SOAResults(i, j) / 10.0);
        end
        fprintf(cResID, '\n');
    end
    fclose(cResID);
    %% Dataset properties analysis (best)
    deltaError = bestResults - repmat(mean(bestResults(:, [1 2 4 5 6]), 2), 1, size(bestResults, 2));
    colorsCrit = distinguishable_colors(length(criteria));
    for p = 1:length(properties)
        f = figure;
        xVals = properties{p}';
        linePointsX = [min(xVals) max(xVals)];
        hold on;
        for c = [1 2 4 5 6]
            plot(0, 0, 'Color', colorsCrit(c,:));
        end
        for c = [1 2 4 5 6]
            yVals = deltaError(:, c);
            pPoly = polyfit(xVals, yVals, 1);
            linePointsY = polyval(pPoly, linePointsX);
            scatter(xVals, yVals, repmat(40, length(yVals), 1), 'o', 'MarkerEdgeColor',colorsCrit(c,:),'MarkerFaceColor',colorsCrit(c, :),'LineWidth',1.5);
            plot(linePointsX, linePointsY, '-.', 'Color', colorsCrit(c,:));
            [R, P] = corrcoef(xVals, yVals);
            fprintf('[%s] %s : R = %f / p = %f\n', propNames{p}, criteria{c}, R(2), P(2));
        end
        hold off;
        legend(criteria);
        title(propNames{p});
        setPaperQuality();
    end
    % Distance-wise analysis (scatterplot distance against best / space)
    figure;
    hold on;
    colorsCrit = distinguishable_colors(length(distances));
    xVals = bestResults(:, end);
    % First do it with best
    for d = 1:length(distances)
        scatter(xVals, distResults(:, d), repmat(40, length(xVals), 1), 'o', 'MarkerEdgeColor',colorsCrit(d,:),'MarkerFaceColor',colorsCrit(d, :),'LineWidth',1.5);
    end
    hold off;
    title('Distances against best');
    legend(distances);
    setPaperQuality();
    % Then do it with space
    figure;
    hold on;
    xVals = spaceResults(:, end);
    for d = 1:length(distances)
        scatter(xVals, distResults(:, d), repmat(40, length(xVals), 1), 'o', 'MarkerEdgeColor',colorsCrit(d,:),'MarkerFaceColor',colorsCrit(d, :),'LineWidth',1.5);
    end
    hold off;
    title('Distances against space');
    legend(distances);
    setPaperQuality();
    % Similarity space analysis
    testNames = {'Best', 'Space'};
    for c = 1:length(criteria)
        for i = 1:2
            fID = fopen(['distances/' varSimp{v} '_' criteria{c} '_Size_' testNames{i} '.csv'], 'w');
            fprintf(fID, '.');
            for d = 1:length(datasets)
                fprintf(fID, '\t%s', datasets{d});
            end
            fprintf(fID, '\n');
            for di = 1:length(distances)
                fprintf(fID, '%d', di);
                for da = 1:length(datasets)
                    fprintf(fID, '\t%d', distSpaceSize(da, c, di, i));
                end
                fprintf(fID, '\n');
            end
            fclose(fID);
            fID = fopen(['distances/' varSimp{v} '_' criteria{c} '_OccurCumul_' testNames{i} '.csv'], 'w');
            fprintf(fID, '.');
            for d = 1:length(datasets)
                fprintf(fID, '\t%s', datasets{d});
            end
            fprintf(fID, '\n');
            for di = 1:length(distances)
                fprintf(fID, '%s', distances{di});
                for da = 1:length(datasets)
                    fprintf(fID, '\t%d', distOccurCumul(di, da, c, i));
                end
                fprintf(fID, '\n');
            end
            fclose(fID);
            fID = fopen(['distances/' varSimp{v} '_' criteria{c} '_CoOccur_' testNames{i} '.csv'], 'w');
            fprintf(fID, '.');
            for d = 1:length(distances)
                fprintf(fID, '\t%s', distances{d});
            end
            fprintf(fID, '\n');
            for di = 1:length(distances)
                fprintf(fID, '%s', distances{di});
                for di2 = 1:length(distances)
                    fprintf(fID, '\t%d', distCoOccur(di, di2, c, i));
                end
                fprintf(fID, '\n');
            end
            fclose(fID);
        end
    end
end