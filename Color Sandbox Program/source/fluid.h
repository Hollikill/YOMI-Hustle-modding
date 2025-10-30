#ifndef FLUID
#define FLUID

class Fluid {
public:
    double initialDensity;

    int sizeX;
    int sizeY;

    double cellSize;

    double* velocityX;
    double* velocityY;
    double* newVelocityX;
    double* newVelocityY;

    double* density;

    bool* isNotWall;

    double* dye;
    double* newDye;

    // fucntions

    Fluid(double initialDensity, int sizeX, int sizeY, double cellSize);

    ~Fluid();
};

#endif