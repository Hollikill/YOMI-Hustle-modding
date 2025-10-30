#define RUN_FLUID

#ifdef RUN_TINT
#include "tint.h"
#endif

#ifdef RUN_FLUID
#include "fluidsim.h"
#endif


int main() {

    #ifdef RUN_TINT
    tintMain();
    #endif

    #ifdef RUN_FLUID
    fluidMain();
    #endif

    return 0;
}