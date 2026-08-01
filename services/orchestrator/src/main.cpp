#include <chrono>
#include <iostream>

int main()
{
    using SimulationDuration = std::chrono::duration<double>;

    constexpr SimulationDuration initialSimulationTime{0.0};

    std::cout << "twins-orchestrator ready at simulation time "
              << initialSimulationTime.count() << " s\n";

    return 0;
}
