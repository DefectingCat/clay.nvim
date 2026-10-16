// Quiet surfaces. A little clay.

const ACCENT: &str = "#d97757";

#[derive(Clone, Debug)]
struct Config {
    background: &'static str,
    contrast: &'static str,
    italics: bool,
}

impl Config {
    /// Build a configuration without changing its defaults.
    fn setup(contrast: &'static str) -> Self {
        // Function definitions receive Clay; calls stay gray.
        Self {
            background: "dark",
            contrast,
            italics: true,
        }
    }

    fn accent(&self) -> &'static str {
        ACCENT
    }
}

fn main() {
    let config = Config::setup("soft");
    println!(
        "{} {} {} {}",
        config.accent(),
        config.background,
        config.contrast,
        config.italics
    );
}

// TODO: inspect selection, search, and completion highlights.
