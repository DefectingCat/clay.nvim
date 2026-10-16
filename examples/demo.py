# Quiet surfaces. A little clay.

from dataclasses import dataclass

ACCENT = "#d97757"


@dataclass
class Config:
    """Build a configuration without changing its defaults."""

    background: str = "dark"
    contrast: str = "soft"
    italics: bool = True

    def accent(self) -> str:
        # Function definitions receive Clay; calls stay gray.
        return ACCENT


def main() -> None:
    config = Config(contrast="soft")
    print(config.accent())


# TODO: inspect selection, search, and completion highlights.
if __name__ == "__main__":
    main()
