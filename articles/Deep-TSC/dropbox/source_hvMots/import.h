/*
 *  import.h
 *  HV-MOTS Classification
 *
 *	This file contains the header definitions for time series datasets.
 *
 *
 */

#ifndef IMPORT_H_
# define IMPORT_H_

# include "types.h"

dataset			*importRaw(char *filename, char *name, int *c_vals, int n_class);
dataset			*importRawMultiple(char *filename, char *name);
collection		*importCollection(char *filename, int loadData);
void			freeDataset(dataset *dSet, int type);

#endif