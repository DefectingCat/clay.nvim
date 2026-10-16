/* Quiet surfaces. A little clay. */
#include <stdio.h>

static const char *accent = "#d97757";

typedef struct {
  const char *background;
  const char *contrast;
  int italics;
} Config;

/* Build a configuration without changing its defaults. */
static Config setup(const char *contrast) {
  Config config = {
      .background = "dark",
      .contrast = contrast,
      .italics = 1,
  };

  /* Function definitions receive Clay; calls stay gray. */
  printf("%s\n", accent);
  return config;
}

int main(void) {
  Config config = setup("soft");
  return config.italics ? 0 : 1;
}

/* TODO: inspect selection, search, and completion highlights. */
