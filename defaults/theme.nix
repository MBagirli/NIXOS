# Single source of truth for the look.
# Hex values have NO leading '#' — each app adds the prefix it needs.
{
  bg       = "1e1e2e";
  bgAlt    = "181825";
  surface  = "313244";
  fg       = "cdd6f4";
  fgDim    = "a6adc8";
  inactive = "45475a";

  accent   = "89b4fa";
  accent2  = "cba6f7";
  ok       = "a6e3a1";
  warn     = "f9e2af";
  urgent   = "f38ba8";

  # Decimal RGB triplets for CSS rgba(). GTK3 cannot parse 8-digit hex,
  # so translucent backgrounds need these rather than the values above.
  # Keep in sync: rgbBg matches bg, rgbSurface matches surface.
  rgbBg      = "30, 30, 46";
  rgbSurface = "49, 50, 68";

  font     = "JetBrainsMono Nerd Font";
  fontSize = 11;

  gaps     = 6;
  gapsOut  = 10;
  rounding = 8;
  border   = 2;
}
