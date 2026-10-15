local C=Color3.fromRGB
local sectors={
 {Id='ScrapBelt',Name='Sprout Moon',Short='SPROUT MOON',Distance='0.4 AU',Risk='LOW',Theme='Leaf-patterned eggs · meadow family',Description='Emerald meadows and forest-green trees rise above deep green cliffs.',Color=C(91,186,111),MapPosition=Vector2.new(.15,.46),Status='AVAILABLE'},
 {Id='IceGraveyard',Name='Frost Cove',Short='FROST COVE',Distance='1.8 AU',Risk='MODERATE',Theme='Ice-tipped eggs · frost family',Description='Aqua ice, pale blue shelves and soft blossom details surround crystal formations.',Color=C(83,216,251),MapPosition=Vector2.new(.27,.17),Status='AVAILABLE'},
 {Id='DerelictField',Name='Rust Crater',Short='RUST CRATER',Distance='3.2 AU',Risk='MODERATE',Theme='Armored eggs · rust family',Description='Ash and taupe ground, charcoal rocks and pale lavender salvage accents.',Color=C(168,155,157),MapPosition=Vector2.new(.61,.14),Status='AVAILABLE'},
 {Id='NebulaCurrent',Name='Violet Wilds',Short='VIOLET WILDS',Distance='6.7 AU',Risk='HIGH',Theme='Antenna-patterned eggs · mushroom family',Description='Orchid and periwinkle terraces with berry mushrooms and midnight-violet cliffs.',Color=C(224,123,224),MapPosition=Vector2.new(.29,.72),Status='AVAILABLE'},
 {Id='AncientRuins',Name='Relic Grove',Short='RELIC GROVE',Distance='9.4 AU',Risk='HIGH',Theme='Rune-patterned eggs · relic family',Description='Teal terraces, mint ruins and raspberry markings above blackberry-colored cliffs.',Color=C(23,190,187),MapPosition=Vector2.new(.72,.72),Status='AVAILABLE'},
 {Id='SingularityEdge',Name='Storm Reach',Short='STORM REACH',Distance='14.2 AU',Risk='EXTREME',Theme='Storm-striped eggs · storm family',Description='Aqua ridges, cream cliffs and bright yellow and pink storm equipment.',Color=C(0,145,173),MapPosition=Vector2.new(.86,.43),Status='AVAILABLE'},
}
return sectors
