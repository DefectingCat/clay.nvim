// Quiet surfaces. A little clay.

final class Config {
  static final String ACCENT = "#d97757";

  final String background;
  final String contrast;
  final boolean italics;

  /** Build a configuration without changing its defaults. */
  static Config setup(String contrast) {
    // Function definitions receive Clay; calls stay gray.
    return new Config("dark", contrast, true);
  }

  private Config(String background, String contrast, boolean italics) {
    this.background = background;
    this.contrast = contrast;
    this.italics = italics;
  }

  String accent() {
    return ACCENT;
  }
}

final class Demo {
  public static void main(String[] args) {
    Config config = Config.setup("soft");
    System.out.println(config.accent() + " " + config.contrast);
  }
}

// TODO: inspect selection, search, and completion highlights.
