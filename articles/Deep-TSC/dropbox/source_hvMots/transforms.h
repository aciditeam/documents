//
//  transforms.h
//  HV-MOTS-C
//
//

#ifndef TRANSFORMS_H_
# define TRANSFORMS_H_

# include "types.h"

series              *transform_Resample(series *raw, int targetLength);
series              *transform_ACF(series *raw);
series              *transform_PCA(series *raw);
series              *transform_FFT(series *raw, int fftSize);
char                *transform_SAX(series *raw, int alphaSize, int timeBins);

#endif
