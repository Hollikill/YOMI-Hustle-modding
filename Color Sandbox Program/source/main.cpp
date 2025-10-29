#define TINT

#ifdef TINT
#include "tint.cpp"
#endif

#ifdef FLUID
#include "fluid.cpp"
#endif

int main() {

    #ifdef TINT
    tintMain();
    #endif

    #ifdef FLUID
    fluidMain();
    #endif

    return 0;
}