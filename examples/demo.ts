// Quiet surfaces. A little clay.

const accent = "#d97757";

interface Options {
  contrast?: string;
  italics?: boolean;
}

type Config = {
  background: string;
  contrast: string;
  italics: boolean;
};

/** Build a configuration without changing its defaults. */
function setup(opts: Options = {}): Config {
  const config: Config = {
    background: "dark",
    contrast: opts.contrast ?? "soft",
    italics: opts.italics ?? true,
  };

  // Function definitions receive Clay; calls stay gray.
  console.log(accent);
  return config;
}

const config = setup({ contrast: "soft" });

// TODO: inspect selection, search, and completion highlights.
export { config };
