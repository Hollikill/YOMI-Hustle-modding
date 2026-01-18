#ifndef FLUID
#define FLUID

#include <memory>

class Fluid {
public:
    double initialDensity;

    int sizeX;
    int sizeY;
    int totalSize;

    double cellSize;

    std::shared_ptr<double[]> velocityX;
    std::shared_ptr<double[]> velocityY;
    std::shared_ptr<double[]> newVelocityX;
    std::shared_ptr<double[]> newVelocityY;

    std::shared_ptr<double[]> density;

    std::shared_ptr<bool[]> isNotWall;

    std::shared_ptr<double[]> dye;
    std::shared_ptr<double[]> newDye;

    // fucntions

    Fluid(double initialDensity, int sizeX, int sizeY, double cellSize);

    void simulate(double dt, int incompressibilityIterations);

    ~Fluid();
};

#endif