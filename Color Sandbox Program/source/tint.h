#ifndef TINT
#define TINT

#include <cstdlib>
#include <ctime>
#include <algorithm>
#include <chrono>
#include <thread>

#include <SFML/Graphics.hpp>
#include "imgui.h"
#include "imgui-SFML.h"

#include "../external/colorm.h"

sf::Image displayDebugColors(int, int);
sf::Image displayAlteredColors(int, int, colorm::Rgb);
sf::Image displayAlteredColors2(int, int, colorm::Rgb);
void tintColor2(colorm::Rgb&, colorm::Rgb, double);
void tintColor(colorm::Rgb&, colorm::Rgb);
void grayscaleColor(colorm::Rgb&);
void grayscaleColor(colorm::Rgb&, int);

int tintMain();

//#include "tint.cpp"

#endif