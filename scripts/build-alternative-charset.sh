#!/bin/bash
# Modern build script for Jost font - compatible with current tool versions

# Exit on error, but allow specific commands to fail with the || operator
set -e

# Ensure we're running from the correct directory
cd "$(dirname "$0")/.."
ROOT_DIR="$(pwd)"

echo "=== Jost Font Build Script ==="
echo "Making Alternative Character Set Files"
echo "Building in: $ROOT_DIR"

mkdir -p "$ROOT_DIR/sources-alt"
cp -a "$ROOT_DIR/sources/." "$ROOT_DIR/sources-alt/"

echo "Fixing Naming Conventions"

#Variable
sed -i 's/Book/Regular/g' "$ROOT_DIR/sources-alt/UFO/400.ufo/fontinfo.plist"
sed -i 's/Book/Regular/g' "$ROOT_DIR/sources-alt/UFO/400i.ufo/fontinfo.plist"
sed -i 's/Regular Italic/Italic/g' "$ROOT_DIR/sources-alt/UFO/400i.ufo/fontinfo.plist"
sed -i 's/RegularItalic/Italic/g' "$ROOT_DIR/sources-alt/UFO/400i.ufo/fontinfo.plist"

sed -i 's/Thin/ExtraLight/g' "$ROOT_DIR/sources-alt/designspace/jost.designspace"
sed -i 's/Hairline/Thin/g' "$ROOT_DIR/sources-alt/designspace/jost.designspace"
sed -i 's/Book/Regular/g' "$ROOT_DIR/sources-alt/designspace/jost.designspace"
sed -i 's/Regular Italic/Italic/g' "$ROOT_DIR/sources-alt/designspace/jost.designspace"
sed -i 's/RegularItalic/Italic/g' "$ROOT_DIR/sources-alt/designspace/jost.designspace"
sed -i 's/Semi/SemiBold/g' "$ROOT_DIR/sources-alt/designspace/jost.designspace"
sed -i 's/Heavy/ExtraBold/g' "$ROOT_DIR/sources-alt/designspace/jost.designspace"
sed -i 's/maximum="2" default="0" name="Italic" tag="ital">/maximum="1" default="0" name="Italic" tag="ital">/g' "$ROOT_DIR/sources-alt/designspace/jost.designspace"
sed -i 's/dimension name="Italic" xvalue="2"/dimension name="Italic" xvalue="1"/g' "$ROOT_DIR/sources-alt/designspace/jost.designspace"

echo "0. Modify Font Files"
python "$ROOT_DIR/scripts/modify.py"

# Ensure output directories exist
mkdir -p "$ROOT_DIR/fonts-alt/ttf" "$ROOT_DIR/fonts-alt/otf" "$ROOT_DIR/fonts-alt/woff" "$ROOT_DIR/fonts-alt/web"

echo "1. Generating Variable Font"
fontmake -o variable -m "$ROOT_DIR/sources-alt/designspace/jost.designspace" --output-path "$ROOT_DIR/fonts-alt/Jost-VF.ttf"

echo "2. Cleaning up variable font"
# Note: skipping deprecated gftools fix-dsig commands
# Apply fix-nonhinting if it exists in this version
if command -v gftools fix-nonhinting &>/dev/null; then
  echo "  - Applying fix-nonhinting to variable font"
  gftools fix-nonhinting "$ROOT_DIR/fonts-alt/Jost-VF.ttf" "$ROOT_DIR/fonts-alt/Jost-VF.ttf.fix" || echo "Warning: fix-nonhinting failed, continuing"
  if [ -f "$ROOT_DIR/fonts-alt/Jost-VF.ttf.fix" ]; then
    mv "$ROOT_DIR/fonts-alt/Jost-VF.ttf.fix" "$ROOT_DIR/fonts-alt/Jost-VF.ttf"
  fi
fi

gftools fix-unwanted-tables --tables MVAR "$ROOT_DIR/fonts-alt/Jost-VF.ttf";
statmake --designspace "$ROOT_DIR/sources-alt/designspace/jost.designspace" "$ROOT_DIR/fonts-alt/Jost-VF.ttf"

fonttools ttLib --flavor woff "$ROOT_DIR/fonts-alt/Jost-VF.ttf" -o "$ROOT_DIR/fonts-alt/woff/Jost-VF.woff"
fonttools ttLib --flavor woff2 "$ROOT_DIR/fonts-alt/Jost-VF.ttf" -o "$ROOT_DIR/fonts-alt/woff/Jost-VF.woff2"

echo "3. Generating subset web fonts"


UNICODES_NAMES=(
 "cyrillic-ext:U+0460-052F,U+1C80-1C8A,U+20B4,U+2DE0-2DFF,U+A640-A69F,U+FE2E-FE2F"
 "cyrillic:U+0301,U+0400-045F,U+0490-0491,U+04B0-04B1,U+2116"
 "greek-ext:U+1F00-1FFF"
 "greek:U+0370-0377,U+037A-037F,U+0384-038A,U+038C,U+038E-03A1,U+03A3-03FF"
 "math:U+0302-0303,U+0305,U+0307-0308,U+0310,U+0312,U+0315,U+031A,U+0326-0327,U+032C,U+032F-0330,U+0332-0333,U+0338,U+033A,U+0346,U+034D,U+0391-03A1,U+03A3-03A9,U+03B1-03C9,U+03D1,U+03D5-03D6,U+03F0-03F1,U+03F4-03F5,U+2016-2017,U+2034-2038,U+203C,U+2040,U+2043,U+2047,U+2050,U+2057,U+205F,U+2070-2071,U+2074-208E,U+2090-209C,U+20D0-20DC,U+20E1,U+20E5-20EF,U+2100-2112,U+2114-2115,U+2117-2121,U+2123-214F,U+2190,U+2192,U+2194-21AE,U+21B0-21E5,U+21F1-21F2,U+21F4-2211,U+2213-2214,U+2216-22FF,U+2308-230B,U+2310,U+2319,U+231C-2321,U+2336-237A,U+237C,U+2395,U+239B-23B7,U+23D0,U+23DC-23E1,U+2474-2475,U+25AF,U+25B3,U+25B7,U+25BD,U+25C1,U+25CA,U+25CC,U+25FB,U+266D-266F,U+27C0-27FF,U+2900-2AFF,U+2B0E-2B11,U+2B30-2B4C,U+2BFE,U+3030,U+FF5B,U+FF5D,U+1D400-1D7FF,U+1EE00-1EEFF"
 "symbols:U+0001-000C,U+000E-001F,U+007F-009F,U+20DD-20E0,U+20E2-20E4,U+2150-218F,U+2190,U+2192,U+2194-2199,U+21AF,U+21E6-21F0,U+21F3,U+2218-2219,U+2299,U+22C4-22C6,U+2300-243F,U+2440-244A,U+2460-24FF,U+25A0-27BF,U+2800-28FF,U+2921-2922,U+2981,U+29BF,U+29EB,U+2B00-2BFF,U+4DC0-4DFF,U+FFF9-FFFB,U+10140-1018E,U+10190-1019C,U+101A0,U+101D0-101FD,U+102E0-102FB,U+10E60-10E7E,U+1D2C0-1D2D3,U+1D2E0-1D37F,U+1F000-1F0FF,U+1F100-1F1AD,U+1F1E6-1F1FF,U+1F30D-1F30F,U+1F315,U+1F31C,U+1F31E,U+1F320-1F32C,U+1F336,U+1F378,U+1F37D,U+1F382,U+1F393-1F39F,U+1F3A7-1F3A8,U+1F3AC-1F3AF,U+1F3C2,U+1F3C4-1F3C6,U+1F3CA-1F3CE,U+1F3D4-1F3E0,U+1F3ED,U+1F3F1-1F3F3,U+1F3F5-1F3F7,U+1F408,U+1F415,U+1F41F,U+1F426,U+1F43F,U+1F441-1F442,U+1F444,U+1F446-1F449,U+1F44C-1F44E,U+1F453,U+1F46A,U+1F47D,U+1F4A3,U+1F4B0,U+1F4B3,U+1F4B9,U+1F4BB,U+1F4BF,U+1F4C8-1F4CB,U+1F4D6,U+1F4DA,U+1F4DF,U+1F4E3-1F4E6,U+1F4EA-1F4ED,U+1F4F7,U+1F4F9-1F4FB,U+1F4FD-1F4FE,U+1F503,U+1F507-1F50B,U+1F50D,U+1F512-1F513,U+1F53E-1F54A,U+1F54F-1F5FA,U+1F610,U+1F650-1F67F,U+1F687,U+1F68D,U+1F691,U+1F694,U+1F698,U+1F6AD,U+1F6B2,U+1F6B9-1F6BA,U+1F6BC,U+1F6C6-1F6CF,U+1F6D3-1F6D7,U+1F6E0-1F6EA,U+1F6F0-1F6F3,U+1F6F7-1F6FC,U+1F700-1F7FF,U+1F800-1F80B,U+1F810-1F847,U+1F850-1F859,U+1F860-1F887,U+1F890-1F8AD,U+1F8B0-1F8BB,U+1F8C0-1F8C1,U+1F900-1F90B,U+1F93B,U+1F946,U+1F984,U+1F996,U+1F9E9,U+1FA00-1FA6F,U+1FA70-1FA7C,U+1FA80-1FA89,U+1FA8F-1FAC6,U+1FACE-1FADC,U+1FADF-1FAE9,U+1FAF0-1FAF8,U+1FB00-1FBFF"
 "vietnamese:U+0102-0103,U+0110-0111,U+0128-0129,U+0168-0169,U+01A0-01A1,U+01AF-01B0,U+0300-0301,U+0303-0304,U+0308-0309,U+0323,U+0329,U+1EA0-1EF9,U+20AB"
 "latin-ext:U+0100-02BA,U+02BD-02C5,U+02C7-02CC,U+02CE-02D7,U+02DD-02FF,U+0304,U+0308,U+0329,U+1D00-1DBF,U+1E00-1E9F,U+1EF2-1EFF,U+2020,U+20A0-20AB,U+20AD-20C0,U+2113,U+2C60-2C7F,U+A720-A7FF"
 "latin:U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD"
)


layout_features="tnum,ss01"
for pair in "${UNICODES_NAMES[@]}"; do
  name="${pair%%:*}"
  unicode="${pair##*:}"
  echo $name
  echo $unicode

  pyftsubset "$ROOT_DIR/fonts-alt/Jost-VF.ttf" --unicodes=${unicode} --layout_features=${layout_features} --flavor="woff2" --output-file="$ROOT_DIR/fonts-alt/web/jost-$name.woff2"
  pyftsubset "$ROOT_DIR/fonts-alt/Jost-VF.ttf" --unicodes=${unicode} --layout_features=${layout_features} --flavor="woff" --output-file="$ROOT_DIR/fonts-alt/web/jost-$name.woff"

done

# Clean up any backup files
find "$ROOT_DIR/fonts-alt" -name "*backup*" -delete

echo "4. Generating source UFO files"
WEIGHTS=("100" "200" "300" "400" "500" "600" "700" "800" "900")
for weight in "${WEIGHTS[@]}"; do
  echo "  - Generating $weight"
  fontmake -o ufo -i "$weight" -m "$ROOT_DIR/sources-alt/designspace/jost.designspace"
  fontmake -o ufo -i "${weight}i" -m "$ROOT_DIR/sources-alt/designspace/jost.designspace"
done

echo "5. Generating TrueType Fonts"
# Create a temporary directory for intermediate TTF files
mkdir -p "$ROOT_DIR/fonts-alt/ttf2"

# Build all instances
INSTANCES_ARGS=""
for ufo in "$ROOT_DIR"/sources-alt/instances/*.ufo; do
  INSTANCES_ARGS="$INSTANCES_ARGS $ufo"
done

fontmake -o ttf --output-dir "$ROOT_DIR/fonts-alt/ttf2/" -u $INSTANCES_ARGS

# Apply ttfautohint to each font
echo "6. Applying hinting"
WEIGHT_NAMES=(
  "100:Hairline" "200:Thin" "300:Light" "400:Book"
  "500:Medium" "600:Semi" "700:Bold" "800:Heavy" "900:Black"
)

for pair in "${WEIGHT_NAMES[@]}"; do
  weight="${pair%%:*}"
  name="${pair##*:}"

  echo "  - Hinting $name"
  ttfautohint -n "$ROOT_DIR/fonts-alt/ttf2/$weight.ttf" "$ROOT_DIR/fonts-alt/ttf/Jost-$weight-$name.ttf"
  ttfautohint -n "$ROOT_DIR/fonts-alt/ttf2/${weight}i.ttf" "$ROOT_DIR/fonts-alt/ttf/Jost-$weight-${name}Italic.ttf"

  # Apply fix-hinting if available in this version
  if command -v gftools fix-hinting &>/dev/null; then
    gftools fix-hinting "$ROOT_DIR/fonts-alt/ttf/Jost-$weight-$name.ttf" || echo "Warning: fix-hinting failed, continuing"
    gftools fix-hinting "$ROOT_DIR/fonts-alt/ttf/Jost-$weight-${name}Italic.ttf" || echo "Warning: fix-hinting failed, continuing"
  fi
done

echo "7. Finalizing TTF fonts"
# Create a safety mechanism to avoid removing files if fix didn't work
if ls "$ROOT_DIR/fonts-alt/ttf/"*.ttf.fix 1> /dev/null 2>&1; then
  # Remove original ttf files before moving the fixed ones
  rm "$ROOT_DIR/fonts-alt/ttf/"*.ttf

  # Move fixed files to their final location
  for pair in "${WEIGHT_NAMES[@]}"; do
    weight="${pair%%:*}"
    name="${pair##*:}"

    mv "$ROOT_DIR/fonts-alt/ttf/Jost-$weight-$name.ttf.fix" "$ROOT_DIR/fonts-alt/ttf/Jost-$weight-$name.ttf"
    mv "$ROOT_DIR/fonts-alt/ttf/Jost-$weight-${name}Italic.ttf.fix" "$ROOT_DIR/fonts-alt/ttf/Jost-$weight-${name}Italic.ttf"

    fonttools ttLib --flavor woff "$ROOT_DIR/fonts-alt/ttf/Jost-$weight-$name.ttf" -o "$ROOT_DIR/fonts-alt/woff/Jost-$weight-$name.woff"
    fonttools ttLib --flavor woff "$ROOT_DIR/fonts-alt/ttf/Jost-$weight-${name}Italic.ttf" -o "$ROOT_DIR/fonts-alt/woff/Jost-$weight-${name}Italic.woff"
    fonttools ttLib --flavor woff2 "$ROOT_DIR/fonts-alt/ttf/Jost-$weight-$name.ttf" -o "$ROOT_DIR/fonts-alt/woff/Jost-$weight-$name.woff2"
    fonttools ttLib --flavor woff2 "$ROOT_DIR/fonts-alt/ttf/Jost-$weight-${name}Italic.ttf" -o "$ROOT_DIR/fonts-alt/woff/Jost-$weight-${name}Italic.woff2"
  done
else
  echo "  - No .fix files found - either fix-hinting command is not available or files are already processed"
fi

# Clean up temporary directory
rm -f "$ROOT_DIR/fonts-alt/ttf2/"*.ttf
rmdir "$ROOT_DIR/fonts-alt/ttf2"

echo "8. Generating OpenType Fonts"
fontmake -o otf --output-dir "$ROOT_DIR/fonts-alt/otf/" -u $INSTANCES_ARGS


echo "9. Renaming OTF files"
# Rename OTF files to follow naming convention
for pair in "${WEIGHT_NAMES[@]}"; do
  weight="${pair%%:*}"
  name="${pair##*:}"

  mv "$ROOT_DIR/fonts-alt/otf/$weight.otf" "$ROOT_DIR/fonts-alt/otf/Jost-$weight-$name.otf"
  mv "$ROOT_DIR/fonts-alt/otf/${weight}i.otf" "$ROOT_DIR/fonts-alt/otf/Jost-$weight-${name}Italic.otf"
done

echo "10. Cleaning up"
rm -rf "$ROOT_DIR/sources-alt"

echo "=== Build completed successfully ==="
