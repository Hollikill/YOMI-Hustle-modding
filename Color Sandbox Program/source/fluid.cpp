#include "fluid.h"

#define fl2c(x, y) (x * sizeX + y)
#define totalCells sizeX*sizeY

Fluid::Fluid(double NinitialDensity, int NsizeX, int NsizeY, double NcellSize) {
        initialDensity = NinitialDensity;

        sizeX = NsizeX + 2;
        sizeY = NsizeY + 2;

        cellSize = NcellSize;
}