//
//  optimize.c
//  HV-MOTS-C
//
//

#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <unistd.h>
#include <math.h>
#include "classification.h"
#include "optimize.h"
#include "types.h"
#include "main.h"

void                    optimizeDistance(dataset *train, distances *distanceSet, criteria *criterias, int id, mParameters *param)
{
    FILE                *exportFile = NULL;
    char                *exportStr = NULL;
    float               **parameters;
    float               **nbRepetitions;
    float               *curParamSeq;
    float               errors, bestErr;
    float               **result, **cur;
    int                 i, j, k, l, nbComb = 1;
    int                 t1, t2, classFound, bestID = 0;
    series              *ts1, *ts2;
    
    if (param->paperMode)
    {
        exportStr = calloc(512, sizeof(char));
        sprintf(exportStr, "%s/%s/optimize_distance/%s.txt", param->output, train->name, distanceSet->name[id]);
        exportFile = fopen(exportStr, "w");
    }
    printf("  - Optimizing %s", distanceSet->name[id]);
    nbRepetitions = calloc(distanceSet->args[id], sizeof(float *));
    for (i = 0; i < distanceSet->args[id]; i++)
    {
        nbRepetitions[i] = calloc(2, sizeof(float));
        nbComb *= distanceSet->params[id][i]->opt_size;
        nbRepetitions[i][0] = 1;
        nbRepetitions[i][1] = 1;
        for (j = i - 1; j >= 0; j--)
        {
            nbRepetitions[j][1] *= distanceSet->params[id][i]->opt_size;
            nbRepetitions[i][0] *= distanceSet->params[id][j]->opt_size;
        }
    }
    printf(" [%d combos]\n", nbComb);
    if (param->paperMode) { fprintf(exportFile, "Combos : %d\n", nbComb); }
    parameters = calloc(nbComb, sizeof(float *));
    for (i = 0; i < nbComb; i++)
        parameters[i] = calloc(distanceSet->args[id], sizeof(float));
    for (i = 0; i < distanceSet->args[id]; i++)
    {
        curParamSeq = calloc(distanceSet->params[id][i]->opt_size * nbRepetitions[i][0], sizeof(float));
        for (j = 0, l = 0; j < distanceSet->params[id][i]->opt_size; j++)
            for (k = 0; k < nbRepetitions[i][0]; k++, l++)
                curParamSeq[l] = distanceSet->params[id][i]->optimized[j];
        for (j = 0, l = 0; j < nbRepetitions[i][1]; j++)
            for (k = 0; k < distanceSet->params[id][i]->opt_size * nbRepetitions[i][0]; k++, l++)
                parameters[l][i] = curParamSeq[k];
        free(curParamSeq);
    }
    cur = calloc(train->cardinality, sizeof(float *));
    result = calloc(train->cardinality, sizeof(float *));
    for (i = 0; i < train->cardinality; i++)
    {
        result[i] = calloc(train->cardinality, sizeof(float));
        cur[i] = calloc(1, sizeof(float));
    }
    for (i = 0, bestErr = 2.0; i < nbComb; i++)
    {
        errors = 0;
        curParamSeq = parameters[i];
        for (t1 = 0; t1 < train->cardinality; t1++)
        {
            #pragma omp parallel for
            for (t2 = t1; t2 < train->cardinality; t2++)
            {
                if (t2 == t1) { result[t2][t2] = 0; }
                else {
                ts1 = train->data[t1];
                ts2 = train->data[t2];
                result[t2][t1] = distanceSet->functions[id](ts1, ts2, curParamSeq);
                result[t1][t2] = result[t2][t1]; }
            }
            for (t2 = 0; t2 < train->cardinality; t2++)
                cur[t2][0] = result[t1][t2];
            // For distance optimization we rely solely on 1-NN
            classFound = criterias->functions[0](cur, train->classes, train->cardinality, 1, t1, train->nb_classes);
            if (classFound != train->classes[t1])
                errors++;
        }
        errors /= train->cardinality;
        if (errors < bestErr) { bestErr = errors; bestID = i; }
        if (param->paperMode)
        {
            fprintf(exportFile, "%d\t", i);
            for (j = 0; j < distanceSet->args[id]; j++)
                fprintf(exportFile, "%s=%f\t", distanceSet->params[id][j]->name, parameters[i][j]);
            fprintf(exportFile, "err=%f\n", errors);
        }
    }
    printf("Best err \t: %f\n", bestErr);
    distanceSet->best[id] = parameters[bestID];
    for (j = 0; j < distanceSet->args[id]; j++)
    {
        distanceSet->params[id][j]->best = parameters[bestID][j];
        printf("Param %s \t: %f ", distanceSet->params[id][j]->name, parameters[bestID][j]);
    }
    printf("\n");
    for (i = 0; i < nbComb; i++)
        if (i != bestID)
            free(parameters[i]);
    for (i = 0; i < train->cardinality; i++)
    {
        free(result[i]);
        free(cur[i]);
    }
    for (i = 0; i < distanceSet->args[id]; i++)
        free(nbRepetitions[i]);
    free(nbRepetitions);
    free(parameters);
    free(result);
    free(cur);
    if (param->paperMode)
    {
        fclose(exportFile);
        free(exportStr);
    }
}

void                    optimizeCriteriaSpace(dataset *train, distances *distanceSet, criteria *criterias, int id, mParameters *param)
{
    FILE                *distFile, *exportFile = NULL;
    char                *distStr, *exportStr = NULL;
    float               ***dists;
    float               **result;
    float               errors, bestErr;
    int                 *trueCompute, *curCompute;
    int                 i, j, k, bestNb = 0, nbDist, nbComb = 0;
    int                 t1, t2, classFound, bestID = 1;
    series              *ts1, *ts2;
    
    if (param->paperMode)
    {
        exportStr = calloc(512, sizeof(char));
        sprintf(exportStr, "%s/%s/optimize_criteria/%s.txt", param->output, train->name, criterias->name[id]);
        exportFile = fopen(exportStr, "w");
    }
    printf("  - Optimizing %s", criterias->name[id]);
    trueCompute = distanceSet->compute;
    distStr = calloc(512, sizeof(char));
    curCompute = calloc(distanceSet->nb_distances, sizeof(int));
    for (i = 0; i < distanceSet->nb_distances; i++)
        if (distanceSet->compute[i])
            nbComb++;
    nbComb = pow(2, nbComb);
    printf(" [%d combos]\n", nbComb - 1);
    dists = calloc(train->cardinality, sizeof(float **));
    result = calloc(train->cardinality, sizeof(float *));
    for (i = 0; i < train->cardinality; i++)
    {
        dists[i] = calloc(train->cardinality, sizeof(float *));
        for (j = 0; j < train->cardinality; j++)
            dists[i][j] = calloc(distanceSet->nb_distances, sizeof(float));
    }
    for (i = 0; i < distanceSet->nb_distances; i++)
        if (trueCompute[i])
        {
            sprintf(distStr, "%s/%s/distances/train_%s.txt", param->output, train->name, distanceSet->name[i]);
            if (access(distStr, F_OK) != -1)
            {
                distFile = fopen(distStr, "r");
                for (t1 = 0; t1 < train->cardinality; t1++)
                    for (t2 = 0; t2 < train->cardinality; t2++)
                        fscanf(distFile, "%f", &(dists[t1][t2][i]));
                fclose(distFile);
            }
            else
            {
                for (t1 = 0; t1 < train->cardinality; t1++)
                {
                    #pragma omp parallel for private(ts1, ts2)
                    for (t2 = (t1 + 1); t2 < train->cardinality; t2++)
                    {
                        ts1 = train->data[t1];
                        ts2 = train->data[t2];
                        dists[t1][t2][i] = distanceSet->functions[i](ts1, ts2, distanceSet->best[i]);
                        dists[t2][t1][i] = dists[t1][t2][i];
                    }
                }
                distFile = fopen(distStr, "w");
                for (t1 = 0; t1 < train->cardinality; t1++)
                {
                    for (t2 = 0; t2 < train->cardinality; t2++)
                        fprintf(distFile, "%f ", dists[t1][t2][i]);
                    fprintf(distFile, "\n");
                }
                fclose(distFile);
            }
        }
    for (i = 1, bestErr = 2.0; i < nbComb; i++)
    {
        for (k = i, j = 0, nbDist = 0; j < distanceSet->nb_distances; j++)
            if (trueCompute[j]) { curCompute[j] = k & 0x1; k >>= 1; nbDist += curCompute[j];}
        errors = 0;
        for (t1 = 0; t1 < train->cardinality; t1++)
            result[t1] = calloc(nbDist, sizeof(float));
        for (t1 = 0; t1 < train->cardinality; t1++)
        {
            for (t2 = 0; t2 < train->cardinality; t2++)
                for (k = 0, j = 0; j < distanceSet->nb_distances; j++)
                    if (curCompute[j])
                        result[t2][k++] = dists[t2][t1][j];
            normalize_distance(result, nbDist, train->cardinality);
            classFound = criterias->functions[id](result, train->classes, train->cardinality, nbDist, t1, train->nb_classes);
            if (classFound != train->classes[t1])
                errors++;
        }
        errors /= train->cardinality;
        if (errors < bestErr || (errors == bestErr && nbDist > bestNb)) { bestErr = errors; bestID = i; bestNb = nbDist; }
        if (param->paperMode)
        {
            fprintf(exportFile, "%d\t", i);
            fprintf(exportFile, "err=%f\t", errors);
            for (j = 0; j < distanceSet->nb_distances; j++)
                if (curCompute[j])
                    fprintf(exportFile, "%s\t", distanceSet->name[j]);
            fprintf(exportFile, "\n");
        }
        for (t1 = 0; t1 < train->cardinality; t1++)
            free(result[t1]);
    }
    printf("Best err \t: %f\n", bestErr);
    criterias->bestSpaceID[id] = bestID;
    criterias->bestSpace[id] = calloc(distanceSet->nb_distances, sizeof(int));
    for (k = bestID, nbDist = 0, j = 0; j < distanceSet->nb_distances; j++)
        if (trueCompute[j]) { criterias->bestSpace[id][j] = k & 0x1; k >>= 1; nbDist += criterias->bestSpace[id][j];}
    criterias->nbBest[id] = nbDist;
    printf("Combo \t: ");
    for (j = 0; j < distanceSet->nb_distances; j++)
        if (criterias->bestSpace[id][j])
            printf("%s ", distanceSet->name[j]);
    printf("\n");
    if (param->paperMode)
    {
        fprintf(exportFile, "Best err \t: %f\n", bestErr);
        fprintf(exportFile, "Combo \t: ");
        for (j = 0; j < distanceSet->nb_distances; j++)
            if (criterias->bestSpace[id][j])
                fprintf(exportFile, "%s ", distanceSet->name[j]);
        fclose(exportFile);
        free(exportStr);
    }
    free(distStr);
    for (i = 0; i < train->cardinality; i++)
    {
        for (j = 0; j < train->cardinality; j++)
            free(dists[i][j]);
        free(dists[i]);
    }
    free(result);
}

void                    optimizeDatasetTT(dataset *train, distances *distanceSet, criteria *criterias, mParameters *param)
{
     int                 i;
    
    distanceSet->best = calloc(distanceSet->nb_distances, sizeof(float *));
     for (i = 0; i < distanceSet->nb_distances; i++)
         if (distanceSet->compute[i] && distanceSet->args[i])
             optimizeDistance(train, distanceSet, criterias, i, param);
    criterias->nbBest = calloc(criterias->nb_criteria, sizeof(int));
    criterias->bestSpace = calloc(criterias->nb_criteria, sizeof(int *));
    criterias->bestSpaceID = calloc(criterias->nb_criteria, sizeof(int));
     for (i = 0; i < criterias->nb_criteria; i++)
         if (criterias->compute[i])
             optimizeCriteriaSpace(train, distanceSet, criterias, i, param);
}