#include "fluid.h"

#define fl2c(x, y) ((x * sizeX) + y)

Fluid::Fluid(double NinitialDensity, int NsizeX, int NsizeY, double NcellSize) : initialDensity(NinitialDensity), cellSize(NcellSize) {
        sizeX = NsizeX + 2;
        sizeY = NsizeY + 2;
        
        totalSize = sizeX * sizeY;

        std::shared_ptr<double[]> NvelocityX(new double[totalSize]);
        velocityX = NvelocityX;
        std::shared_ptr<double[]> NvelocityY(new double[totalSize]);
        velocityY = NvelocityY;
        std::shared_ptr<double[]> NnewVelocityX(new double[totalSize]);
        newVelocityX = NnewVelocityX;
        std::shared_ptr<double[]> NnewVelocityY(new double[totalSize]);
        newVelocityY = NnewVelocityY;

        std::shared_ptr<double[]> Ndensity(new double[totalSize]);
        density = Ndensity;

        std::shared_ptr<bool[]> NisNotWall(new bool[totalSize]);
        isNotWall = NisNotWall;

        std::shared_ptr<double[]> Ndye(new double[totalSize]);
        dye = Ndye;
        std::shared_ptr<double[]> NnewDye(new double[totalSize]);
        newDye = NnewDye;

        for (int x = 0; x < sizeX; x++) {
            for (int y = 0; y < sizeY; y++) {
                if ((x == 0 || x == sizeX - 1) || (y == 0 || y == sizeY - 1)) {
                    isNotWall[fl2c(x, y)] = false;
                }
                else {
                    isNotWall[fl2c(x, y)] = true;
                }
                velocityX[fl2c(x, y)] = 0.0;
                velocityY[fl2c(x, y)] = 0.0;
                newVelocityX[fl2c(x, y)] = 0.0;
                newVelocityY[fl2c(x, y)] = 0.0;

                density[fl2c(x, y)] = initialDensity;

                dye[fl2c(x, y)] = 0.0;
                newDye[fl2c(x, y)] = 0.0;
            }
        }
}

Fluid::~Fluid() {
    //idk
}