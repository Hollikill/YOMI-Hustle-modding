#include <cstdlib>
#include <ctime>
#include <algorithm>
#include <chrono>

#include <SFML/Graphics.hpp>
#include "imgui.h"
#include "imgui-SFML.h"

#include "../external/colorm.h"

sf::Image displayDebugColors(int, int);
sf::Image displayAlteredColors(int inFidelity, int pixel_size, colorm::Rgb tint_color, double tintFactor);
void tintColor(colorm::Rgb&, colorm::Rgb, double);
void grayscaleColor(colorm::Rgb&);
void grayscaleColor(colorm::Rgb&, int);

sf::Vector2u vec2u(int x, int y) {
    return sf::Vector2u((unsigned int)x, (unsigned int)y);
}
sf::Color sfColor(colorm::Rgb color) {
    return sf::Color(color.red8(), color.green8(), color.blue8());
}

int main() {
    sf::RenderWindow window;
    window.create(sf::VideoMode({ 1920, 1080 }), "Color Tests", sf::State::Windowed);
    window.setFramerateLimit(60);
    if (!ImGui::SFML::Init(window)) {
        return -1;
    }

    ImGuiStyle* style = &ImGui::GetStyle();
    style->WindowMinSize = { 300, 150 };

    sf::Clock deltaClock;

    int rval = 128;
    int gval = 128;
    int bval = 128;

    float tintFactor = 1.0;

    std::chrono::milliseconds lastFrame = std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::system_clock::now().time_since_epoch()
    );

    std::chrono::milliseconds frameDelay(5);

    sf::Image alteredImage({100,100}, sf::Color::Magenta);

    while (window.isOpen())
    {
        if (lastFrame + frameDelay < std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch())) {
            while (const std::optional event = window.pollEvent())
            {
                ImGui::SFML::ProcessEvent(window, event.value());
                if (event->is<sf::Event::Closed>())
                {
                    window.close();
                }
                else if (event->is<sf::Event::Resized>())
                {
                    sf::FloatRect view({ 0, 0 }, { (float)window.getSize().x, (float)window.getSize().y });
                    window.setView(sf::View(view));
                }
                else if (event->is<sf::Event::KeyPressed>()) {
                    if (sf::Keyboard::isKeyPressed(sf::Keyboard::Key::R)) {
                        // reload altered color set on key 'r' pressed
                        alteredImage = displayAlteredColors(10, 90, colorm::Rgb(rval, gval, bval), (double)tintFactor);
                    }
                }
            }

            ImGui::SFML::Update(window, deltaClock.restart());
            window.clear();

            //main menu
            ImGui::Begin("Main Menu");

            ImGui::SliderInt("Red value", &rval, 0, 255);
            ImGui::SliderInt("Green value", &gval, 0, 255);
            ImGui::SliderInt("Blue value", &bval, 0, 255);

            ImGui::SliderFloat("Tint Factor", &tintFactor, 0, 1);

            sf::Texture texture(displayDebugColors(10, 90));
            sf::Sprite sprite(texture);
            window.draw(sprite);

            sf::Texture texture2(alteredImage);
            sf::Sprite sprite2(texture2);
            sprite2.setPosition({ 900,0 });
            window.draw(sprite2);

            sf::CircleShape tintCirc(50);
            tintCirc.setFillColor(sf::Color(rval, gval, bval));
            tintCirc.setPosition({ 0,900 });
            window.draw(tintCirc);

            ImGui::End();

            ImGui::SFML::Render(window); // This should be last render step most of the time

            window.display();

            lastFrame = std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()
            );
        }
    }

    ImGui::SFML::Shutdown();

	return 0;
}

sf::Image displayDebugColors(int fidelity, int pixelSize) {

    sf::Image canvas(vec2u(fidelity*pixelSize, fidelity * pixelSize), sf::Color::Black);

    for (int y = 0; y < fidelity * pixelSize; y++) {
        for (int x = 0; x < fidelity * pixelSize; x++) {
            float x_val = (x / pixelSize) * 255 / fidelity;
            float y_val = (y / pixelSize) * 255 / fidelity;
            float y_val_granular = (y % pixelSize) * (255 / pixelSize);

            colorm::Rgb defaultColor(x_val, y_val, y_val_granular);

            canvas.setPixel(vec2u(x, y), sfColor(defaultColor));
        }
    }

    return canvas;
}

sf::Image displayAlteredColors(int fidelity, int pixelSize, colorm::Rgb tint_color, double tintFactor) {

    sf::Image canvas(vec2u(fidelity * pixelSize, fidelity * pixelSize), sf::Color::Black);

    for (int y = 0; y < fidelity * pixelSize; y++) {
        for (int x = 0; x < fidelity * pixelSize; x++) {
            float x_val = (x / pixelSize) * 255 / fidelity;
            float y_val = (y / pixelSize) * 255 / fidelity;
            float y_val_granular = (y % pixelSize) * (255 / pixelSize);

            colorm::Rgb baseColor(x_val, y_val, y_val_granular);

            tintColor(baseColor, tint_color, tintFactor);

            canvas.setPixel(vec2u(x,y), sfColor(baseColor));
        }
    }

    return canvas;
}

/*void tintColor(colorm::Rgb& inputColor, colorm::Rgb tintColor, double tintFactor) {
    grayscaleColor(inputColor);

    double brightness = colorm::Oklab(inputColor).lightness();

    tintColor = colorm::Rgb(colorm::Oklab(tintColor).setLightness(brightness));

    double colors[3] = {
        (inputColor.red() * (1 - tintFactor)) + (tintColor.red() * tintFactor),
        (inputColor.green() * (1 - tintFactor)) + (tintColor.green() * tintFactor),
        (inputColor.blue() * (1 - tintFactor)) + (tintColor.blue() * tintFactor)
    };

    inputColor = colorm::Rgb(colors[0], colors[1], colors[2]);
}*/

void tintColor(colorm::Rgb& inputColor, colorm::Rgb tintColor, double tintFactor) {
    double lightnessAdjustment = (1 - colorm::Oklab(tintColor).lightness())/2;

    colorm::Oklch colorHueShifted = colorm::Oklch(inputColor);

    colorHueShifted.setHue(colorm::Oklch(tintColor).hue());
    colorHueShifted.setChroma(colorm::Oklch(tintColor).chroma());

    colorm::Oklab oklabTint = colorm::Oklab(colorHueShifted);
    colorm::Oklab oklabBase = colorm::Oklab(inputColor);

    double baseColorLightnessCorrected = std::max(0.0, (colorm::Oklab(inputColor).lightness() - 0.25));
    double darkBaseColorCorrection = std::min(1.0, std::max(0.0, (0.5 + log(baseColorLightnessCorrected))));
    lightnessAdjustment = lightnessAdjustment * darkBaseColorCorrection;

    colorm::Oklab midpoint = colorm::Oklab(
        ((baseColorLightnessCorrected * (1 - lightnessAdjustment)) + (colorm::Oklab(tintColor).lightness() * lightnessAdjustment)),
        (oklabBase.a() * (1 - tintFactor)) + (oklabTint.a() * tintFactor),
        (oklabBase.b() * (1 - tintFactor)) + (oklabTint.b() * tintFactor)
    );
    midpoint = colorm::Oklab(colorm::Hsl(midpoint).setSaturation(colorm::Hsl(midpoint).saturation() * std::min(1.0, pow(1 + baseColorLightnessCorrected, 2) - 1)));
    //((oklabTint.lightness() * (1-lightnessAdjustment)) + (colorm::Oklab(tintColor).lightness() * lightnessAdjustment)),

    inputColor = colorm::Rgb(midpoint);
    
    //inputColor = colorm::Rgb((int)(darkBaseColorCorrection*255), (int)(darkBaseColorCorrection * 255), (int)(darkBaseColorCorrection * 255));
}

void grayscaleColor(colorm::Rgb& inputColor) {
    colorm::Oklch tempColor = colorm::Oklch(inputColor);
    tempColor.setChroma(0);
    inputColor = colorm::Rgb(tempColor);
}

void grayscaleColor(colorm::Rgb& inputColor, int grayscaleFactor) {
    colorm::Oklch tempColor = colorm::Oklch(inputColor);
    tempColor.setChroma(tempColor.chroma()/grayscaleFactor);
    inputColor = colorm::Rgb(tempColor);
}