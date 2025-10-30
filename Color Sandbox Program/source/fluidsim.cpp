#include "fluidsim.h"

//sf::Vector2u vec2u(int x, int y) {
//    return sf::Vector2u((unsigned int)x, (unsigned int)y);
//}
#define vec2u(x, y) sf::Vector2u((unsigned int)x, (unsigned int)y)


int fluidMain() {
    sf::RenderWindow window;
    window.create(sf::VideoMode({ 1920, 1080 }), "Fluid Test", sf::State::Windowed);
    window.setFramerateLimit(60);
    if (!ImGui::SFML::Init(window)) {
        return -1;
    }

    ImGuiStyle* style = &ImGui::GetStyle();
    style->WindowMinSize = { 300, 150 };

    sf::Clock deltaClock;

    std::chrono::milliseconds lastFrame = std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::system_clock::now().time_since_epoch()
    );

    std::chrono::milliseconds frameDelay(5);

    while (window.isOpen())
    {
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
                    // code
                }
            }
        }
        if (lastFrame + frameDelay < std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch())) {
            ImGui::SFML::Update(window, deltaClock.restart());
            window.clear();

            //main menu
            //ImGui::Begin("Main Menu");
            //ImGui::End();

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