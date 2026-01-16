import 'clothing_item_hive.dart';

String categoryLabel(ClothingCategory c) {
  switch (c) {
    case ClothingCategory.top:
      return 'Oberteile (inkl. Kleider)';
    case ClothingCategory.bottom:
      return 'Unterteile (inkl. Strumpfhosen)';
    case ClothingCategory.outerwear:
      return 'Jacken / Mäntel';
    case ClothingCategory.shoes:
      return 'Schuhe / Stiefel';
    case ClothingCategory.outfit:
      return 'Outfit (komplett)';
  }
}

String colorLabel(ColorTag c) {
  switch (c) {
    case ColorTag.black:
      return 'Schwarz';
    case ColorTag.white:
      return 'Weiß';
    case ColorTag.grey:
      return 'Grau';
    case ColorTag.beige:
      return 'Beige/Nude';
    case ColorTag.brown:
      return 'Braun';
    case ColorTag.blue:
      return 'Blau/Navy';
    case ColorTag.green:
      return 'Grün';
    case ColorTag.red:
      return 'Rot';
    case ColorTag.bordeauxViolet:
      return 'Bordeaux/Violett';
    case ColorTag.pink:
      return 'Rosa/Pink';
    case ColorTag.yellow:
      return 'Gelb';
    case ColorTag.orange:
      return 'Orange';
    case ColorTag.metallic:
      return 'Metallic';
    case ColorTag.denim:
      return 'Denim';
    case ColorTag.multicolor:
      return 'Mehrfarbig';
    case ColorTag.pattern:
      return 'Muster';
  }
}

String topTypeLabel(TopType t) {
  switch (t) {
    case TopType.tshirt:
      return 'T-Shirt';
    case TopType.PoloShirt:
      return 'Polo-Shirt';
    case TopType.blouse:
      return 'Bluse';
    case TopType.shirt:
      return 'Hemd';
    case TopType.tankTop:
      return 'Top/Träger';
    case TopType.longsleeve:
      return 'Longsleeve';
    case TopType.sweater:
      return 'Pullover';
    case TopType.hoodie:
      return 'Hoodie';
    case TopType.cardigan:
      return 'Cardigan';
    case TopType.blazer:
      return 'Blazer';
    case TopType.tunic:
      return 'Tunika';
    case TopType.turtleneck:
      return 'Rollkragen';
    case TopType.cropTop:
      return 'Crop-Top';
    case TopType.body:
      return 'Body';
    case TopType.dressShort:
      return 'Kleid (kurz)';
    case TopType.dressLong:
      return 'Kleid (lang)';
    case TopType.jumpsuit:
      return 'Jumpsuit/Overall';
    case TopType.coordTop:
      return 'Set/Oberteil';
    case TopType.sportsTop:
      return 'Sporttop';
    case TopType.tank:
      return 'Tanktop';
    case TopType.clubwear:
      return 'Date / FürIhn';
    case TopType.homewear:
      return 'Home & Loungewear';  
    case TopType.other:
      return 'Sonstiges';
  }
}

String bottomTypeLabel(BottomType b) {
  switch (b) {
    case BottomType.jeans:
      return 'Jeans';
    case BottomType.trousers:
      return 'Stoffhose';
    case BottomType.chino:
      return 'Chino';
    case BottomType.leggings:
      return 'Leggings';
    case BottomType.tights:
      return 'Strumpfhose';
    case BottomType.joggers:
      return 'Jogginghose';
    case BottomType.shorts:
      return 'Shorts';
    case BottomType.bikerShorts:
      return 'Radler/Biker Shorts';
    case BottomType.skirtMini:
      return 'Rock (mini)';
    case BottomType.skirtMidi:
      return 'Rock (midi)';
    case BottomType.skirtMaxi:
      return 'Rock (maxi)';
    case BottomType.culotte:
      return 'Culotte';
    case BottomType.palazzo:
      return 'Palazzo';
    case BottomType.cargo:
      return 'Cargo';
    case BottomType.leatherLook:
      return 'Lederhose/Imitat';
    case BottomType.suitTrousers:
      return 'Anzughose';
    case BottomType.sportsPants:
      return 'Sporthose';
    case BottomType.thermoPants:
      return 'Thermohose';
    case BottomType.coordBottom:
      return 'Set/Unterteil';
    case BottomType.CroppedTrouser:
      return '7/8-Hose';
    case BottomType.clubwear:
      return 'Date / FürIhn';    
    case BottomType.homewear:
      return 'Home & Loungewear';    
    case BottomType.other:
      return 'Sonstiges';
  }
}

String shoeTypeLabel(ShoeType s) {
  switch (s) {
    case ShoeType.sneakers:
      return 'Sneaker';
    case ShoeType.boots:
      return 'Stiefel';
    case ShoeType.ankleBoots:
      return 'Stiefelette/Boots';
    case ShoeType.heels:
      return 'High Heels/Pumps';
    case ShoeType.sandals:
      return 'Sandalen';
    case ShoeType.ballerinas:
      return 'Ballerinas';
    case ShoeType.loafers:
      return 'Loafer';
    case ShoeType.slippers:
      return 'Slipper';
    case ShoeType.laceUps:
      return 'Schnürschuhe';
    case ShoeType.chelseaBoots:
      return 'Chelsea Boots';
    case ShoeType.overknee:
      return 'Overknee';
    case ShoeType.platform:
      return 'Plateau';
    case ShoeType.wedges:
      return 'Wedges/Keilabsatz';
    case ShoeType.flipFlops:
      return 'Flip-Flops';
    case ShoeType.houseShoes:
      return 'Hausschuhe';
    case ShoeType.sportShoes:
      return 'Sportschuhe';
    case ShoeType.hikingShoes:
      return 'Wanderschuhe';
    case ShoeType.businessShoes:
      return 'Business-Schuhe';
    case ShoeType.flatSummerSandals:
      return 'Sommersandale flach';
    case ShoeType.other:
      return 'Sonstiges';
  }
}

String outfitOccasionLabel(OutfitOccasion o) {
  switch (o) {
    case OutfitOccasion.casual:
      return 'Freizeit / Casual';
    case OutfitOccasion.homewear:
      return 'Homewear / Loungewear';
    case OutfitOccasion.streetwear:
      return 'Streetwear';
    case OutfitOccasion.travel:
      return 'Reise / Travel';
    case OutfitOccasion.summer:
      return 'Sommer Outfit';
    case OutfitOccasion.winter:
      return 'Winter Outfit';
    case OutfitOccasion.officeBusinessCasual:
      return 'Büro / Business Casual';
    case OutfitOccasion.businessFormal:
      return 'Business / Formal';
    case OutfitOccasion.smartCasual:
      return 'Smart Casual';
    case OutfitOccasion.appointment:
      return 'Termin / Präsentation';
    case OutfitOccasion.sportTraining:
      return 'Sport / Training';
    case OutfitOccasion.outdoorHiking:
      return 'Outdoor / Wandern';
    case OutfitOccasion.running:
      return 'Running / Cardio';
    case OutfitOccasion.yoga:
      return 'Yoga / Relax Sport';
    case OutfitOccasion.dinner:
      return 'Abend / Dinner';
    case OutfitOccasion.clubParty:
      return 'Tanzen / Club';
    case OutfitOccasion.eventFormal:
      return 'Event / Feierlich';
    case OutfitOccasion.dateNight:
      return 'Date / FürIhn';
    case OutfitOccasion.beachHoliday:
      return 'Urlaub / Strand';
    case OutfitOccasion.rainWeather:
      return 'Schlechtwetter / Regen';
  }
}
