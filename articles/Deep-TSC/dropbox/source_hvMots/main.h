//
//  main.h
//  HV-MOTS-C
//
//

#ifndef HV_MOTS_C_main_h
#define HV_MOTS_C_main_h

typedef struct		mParameters
{
	// Computing modes //
	
	int				paperMode;              /**< Paper mode specify full statistics computation */
	int				debugMode;              /**< Debug mode specify complete export of every steps */
	int				benchmarkMode;          /**< Benchmark mode allows to test every possible combinations */
	
	// Distributed computation //
	
	int				parallelize;            /**< Do we require the computation to be parallel */
	int				numThreads;             /**< How many threads do we require (-1 : Maximum) */
	
	// Datasets parameters //
    
    char            *collection;        /**< The input collection file */
    
    // Computation options //
    
    int             combineAll;
    
    // Output files //
    
    char            *output;
    FILE            *summary;
    FILE            *full;
    
} mParameters;

int                 importConfiguration(mParameters *params, char *configFile);

#endif
