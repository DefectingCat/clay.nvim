// Quiet surfaces. A little clay.
#include <iostream>
#include <string>

namespace clay {

constexpr const char *kAccent = "#d97757";

struct Config {
  std::string background;
  std::string contrast;
  bool italics;

  /// Build a configuration without changing its defaults.
  static Config setup(std::string contrast) {
    Config config;
    config.background = "dark";
    config.contrast = contrast;
    config.italics = true;
    // Function definitions receive Clay; calls stay gray.
    return config;
  }

  const char *accent() const { return kAccent; }
};

}  // namespace clay

int main() {
  auto config = clay::Config::setup("soft");
  std::cout << config.accent() << " " << config.contrast << "\n";
}

// TODO: inspect selection, search, and completion highlights.
