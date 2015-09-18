//
//  optimize.h
//  HV-MOTS-C
//
//

#ifndef OPTIMIZE_H_
# define OPTIMIZE_H_

#include "types.h"
#include "main.h"

void                    optimizeDistance(dataset *train, distances *distanceSet, criteria *criterias, int id, mParameters *param);
void                    optimizeDatasetTT(dataset *train, distances *distanceSet, criteria *criterias, mParameters *param);

#endif
