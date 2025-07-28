import pathlib
import re

# Dirty script to set the alternative char as default and the default as alternative

base = pathlib.Path('/app/sources-alt')

with open(base.joinpath("designspace/jost.designspace"), "r") as designspace_file:
    designspace_content = designspace_file.read()
    designspace_content = re.sub(r"<conditionset>([A-Za-z0-9\"\s\/<>.=]+)</conditionset>\n", "", designspace_content)
    designspace_content = re.sub(r"<sub name=\"([a-z0-9]+)\" with=\"([a-z0-9]+.alt)\" />",
                                 r'<sub name="\g<2>" with="\g<1>" />', designspace_content)

with open(base.joinpath("designspace/jost.designspace"), "w") as designspace_file:
    designspace_file.write(designspace_content)

for weight in ("100", "100i", "400", "400i", "900", "900i"):
    weight_path = base.joinpath(f"UFO/{weight}.ufo")

    # move utf8 char from non alt to alt glyph
    glyphs_weight_path = weight_path.joinpath("glyphs")
    for alt_glif in glyphs_weight_path.glob('*.alt.glif'):
        print(alt_glif.absolute())
        name = alt_glif.stem.split('.')[0]
        with open(glyphs_weight_path.joinpath(f"{name}.glif"), "r") as glif_file:
            lines = glif_file.readlines()

        hex_line = lines.pop(3)

        with open(glyphs_weight_path.joinpath(f"{name}.glif"), "w") as file:
            file.writelines(lines)

        with open(alt_glif) as alt_glif_file:
            lines_alt = alt_glif_file.readlines()

        lines_alt.insert(3, hex_line)

        with open(alt_glif, "w") as file:
            file.writelines(lines_alt)

    #
    with open(glyphs_weight_path.joinpath("uni0430.glif"), "r") as glif_file:
        lines_uni = glif_file.readlines()
        h = lines_uni.pop(3)
    with open(glyphs_weight_path.joinpath("uni0430.glif"), "w") as glif_file:
        glif_file.writelines(lines_uni)
    with open(glyphs_weight_path.joinpath("a.alt.glif"), "r") as glif_file:
        lines_a = glif_file.readlines()
        lines_a.insert(3, h)
    with open(glyphs_weight_path.joinpath("a.alt.glif"), "w") as file:
        file.writelines(lines_a)

    # modify features.fea
    with open(weight_path.joinpath("features.fea"), "r") as fea_file:
        lines_fea = fea_file.readlines()
        # currently remove the replacement (TODO: a.alt should only replaced by uni0430 if unicode char match)
        lines_fea.pop(20)

    with open(weight_path.joinpath("features.fea"), "w") as file:
        file.writelines(lines_fea)

    with open(weight_path.joinpath("features.fea"), "r") as fea_file:
        lines = fea_file.read()
        lines = re.sub(r"sub (\\[a-z0-9]+) by (\\[a-z0-9]+.alt) ;", r"sub \g<2> by \g<1> ;", lines)

        lineparts = lines.split("#Mark attachment classes (defined in GDEF, used in lookupflags)")

        for m in re.findall(r"(\\[a-z0-9]+.alt)", lineparts[1]):
            pp = m.split('.')
            lineparts[1] = lineparts[1].replace(m, f"{m}.tmp")
            lineparts[1] = lineparts[1].replace(f"{pp[0]} ", f"{m} ")
            lineparts[1] = lineparts[1].replace(f"{m}.tmp", f"{pp[0]}")

    with open(weight_path.joinpath("features.fea"), "w") as fea_file:
        fea_file.write("#Mark attachment classes (defined in GDEF, used in lookupflags)".join(lineparts))


    with open(weight_path.joinpath("lib.plist"), "r") as plist_file:
        plist_lines = plist_file.read()
        for m in re.findall(r">([a-z0-9]+.alt)<", plist_lines):
            pp = m.split('.')
            plist_lines = plist_lines.replace(f">{m}<", f">{m}.tmp<")
            plist_lines = plist_lines.replace(f">{pp[0]}<", f">{m}<")
            plist_lines = plist_lines.replace(f">{m}.tmp<", f">{pp[0]}<")

    with open(weight_path.joinpath("lib.plist"), "w") as plist_file:
        plist_file.write(plist_lines)













