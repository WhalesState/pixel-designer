class_name Constants
extends Object

const CELL_MATERIAL: Material = preload("./cell_button_material.tres")
const SPRITE_MATERIAL: Material = preload("./sprite_material.tres")
const MATERIAL_MATERIAL: Material = preload("./material_button_material.tres")
const MATERIAL_TEXTURE: CompressedTexture2D = preload("./material.png")

const SHADER_COLORS: PackedColorArray = [
    Color(0.0, 0.0, 0.0, 1.0), # 0 black # skin outline
    Color(1.0, 0.0, 0.0, 1.0), # 1 red   # skin color
    Color(0.0, 1.0, 0.0, 1.0), # 2 green # skin shade
    
    Color(0.0, 0.0, 1.0, 1.0), # 3 blue # eyes color
    
    Color(0.2, 0.2, 0.2, 1.0), # 4 dark gray # clothes outline
    Color(0.0, 1.0, 1.0, 1.0), # 5 cyan      # clothes color
    Color(1.0, 0.0, 1.0, 1.0), # 6 magneta   # clothes shade
    Color(1.0, 1.0, 0.0, 1.0), # 7 yellow    # clothes highlight
    
    Color(0.6, 0.0, 0.0, 1.0), # 8 maroon  # hair outline
    Color(0.4, 0.4, 0.4, 1.0), # 9 gray    # hair color
    Color(0.4, 0.0, 1.0, 1.0), # 10 Purple # hair shade
    Color(1.0, 0.4, 0.0, 1.0), # 11 Orange # hair dark shade
    
    Color(0.0, 0.6, 0.0, 1.0), # 12 dark green # item outline
    Color(0.8, 0.8, 0.8, 1.0), # 13 silver     # item color
    Color(0.6, 0.6, 0.0, 1.0), # 14 olive      # item shade
    Color(1.0, 0.6, 0.0, 1.0), # 15 orange-ish # item dark shade
    
    Color(0.6, 0.0, 0.6, 1.0), # 16 purple-ish # metal outline
    Color(0.0, 0.6, 0.6, 1.0), # 17 teal       # metal color
    Color(0.0, 0.0, 0.6, 1.0), # 18 navy       # metal shade
    
    Color(1.0, 1.0, 0.6, 1.0), # 19 light yellow # B&W black
    Color(0.6, 1.0, 0.0, 1.0), # 20 lime green   # B&W white
    
    Color(0.0, 1.0, 0.6, 1.0), # 21 spring green # mask outline
    Color(0.6, 0.0, 1.0, 1.0), # 22 violet       # mask color
    Color(0.0, 0.6, 1.0, 1.0), # 23 sky blue     # mask shade
    
    Color(1.0, 0.6, 0.4, 1.0), # 24 light orange
    Color(1.0, 0.0, 0.6, 1.0), # 25 rose
    Color(1.0, 0.8, 0.8, 1.0), # 26 pink
    Color(0.0, 0.8, 0.8, 1.0), # 27 aqua
    Color(1.0, 0.4, 0.2, 1.0), # 28 tomatoe
    Color(1.0, 0.8, 0.0, 1.0), # 29 gold
    Color(0.6, 0.2, 0.2, 1.0), # 30 brown
    Color(1.0, 1.0, 1.0, 1.0)  # 31 white
]

const MATERIAL_COLORS: PackedColorArray = [
    Color(0.0, 0.0, 0.0, 1.0), # 0 black     # primary outline
    Color(0.2, 0.2, 0.2, 1.0), # 1 dark gray # secondary outline
    
    Color(0.0, 0.0, 1.0, 1.0), # 2 blue
    Color(1.0, 0.0, 0.0, 1.0), # 3 red
    Color(0.0, 1.0, 0.0, 1.0), # 4 green
    Color(1.0, 0.0, 1.0, 1.0), # 5 magenta
    Color(1.0, 1.0, 0.0, 1.0), # 6 yellow
    Color(0.0, 1.0, 1.0, 1.0), # 7 cyan
    
    Color(1.0, 1.0, 1.0, 1.0), # 8 white    # highlight
    
    Color(0.4, 0.4, 0.4, 1.0)  # 9 gray     # shadow
]
