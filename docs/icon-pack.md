# Icon pack: product placeholders

Written for: whoever generates the icons in GPT (image generation).

The app needs 85 product icons, one per product type across our SME categories. Generate each icon, save it as `<key>.png`, and put it in `assets/icons/products/`. The app falls back to a built-in icon for any key without a PNG, so the pack can be added gradually.

## Style for every icon

- PNG, 512 × 512 px, transparent background.
- One object, centered, filling about 80% of the canvas.
- Flat minimal illustration with soft rounded shapes. No text, letters, logos, or brand names.
- Colors: ink `#111111` for outlines and detail, mint `#4AD39A` as the main accent. Orange `#F59E4B` may appear as a second accent. Use at most 3 colors, and no gradients.
- Light from the top left. No heavy shadows; one soft flat shadow under the object is fine.
- Same visual weight across the set, so the icons look like one family.

## Prompt template

> Flat minimal icon of {description}. Soft rounded shapes, colors #111111 and #4AD39A with optional #F59E4B accent, no text, no gradient, centered on a transparent background, 512x512 PNG.

## Icons

| File | Label (app) | Group | Description for GPT |
|---|---|---|---|
| `bakery.png` | Roti tawar | Roti & kue | a sliced loaf of white sandwich bread |
| `cake.png` | Kue | Roti & kue | a slice of layered sponge cake with frosting |
| `cookie.png` | Kukis | Roti & kue | a round chocolate-chip cookie |
| `icecream.png` | Puding / dessert | Roti & kue | a dessert cup of pudding with a spoon |
| `muffin.png` | Muffin | Roti & kue | a cupcake-style muffin with a domed top |
| `croissant.png` | Croissant | Roti & kue | a golden crescent-shaped croissant |
| `donut.png` | Donat | Roti & kue | a glazed ring donut with sprinkles |
| `bread_bun.png` | Roti kecil | Roti & kue | a round bread bun |
| `rice.png` | Nasi | Makanan | a bowl of steamed white rice |
| `noodle.png` | Mie | Makanan | a bowl of noodles with chopsticks |
| `sandwich.png` | Sandwich | Makanan | a sandwich cut in half |
| `burger.png` | Burger | Makanan | a burger with a bun, patty, and lettuce |
| `pizza.png` | Pizza | Makanan | a slice of pizza with cheese |
| `fried_chicken.png` | Ayam goreng | Makanan | a fried chicken drumstick |
| `egg.png` | Telur | Makanan | a whole egg, one in a small tray |
| `tempe.png` | Tempe | Makanan | a rectangular block of fermented soybean cake (tempe) |
| `tahu.png` | Tahu | Makanan | a block of white tofu (tahu) |
| `fish.png` | Ikan | Makanan | a whole fish |
| `chili.png` | Cabai | Makanan | a red chili pepper |
| `vegetable.png` | Sayur | Makanan | a bundle of leafy green vegetables |
| `fruit.png` | Buah | Makanan | a whole apple with a leaf |
| `snack_bag.png` | Keripik | Makanan | a crisp snack bag with a chip falling out |
| `frozen.png` | Makanan beku | Makanan | a frozen food pack with a snowflake |
| `food_tray.png` | Katering | Makanan | a catering tray with food compartments and a lid |
| `coffee.png` | Kopi | Minuman | a takeaway coffee cup with a lid |
| `tea.png` | Teh | Minuman | a cup of tea with a teabag string |
| `juice.png` | Jus | Minuman | a tall glass of juice with a straw |
| `bottle.png` | Botol minuman | Minuman | a plastic drink bottle with a cap |
| `boba.png` | Boba | Minuman | a plastic cup of milk tea with tapioca pearls |
| `grain.png` | Tepung | Bahan baku | a paper bag of wheat flour |
| `sugar.png` | Gula | Bahan baku | a bag of white sugar with a scoop |
| `salt.png` | Garam | Bahan baku | a small salt shaker |
| `spice.png` | Bumbu | Bahan baku | a jar of ground spices |
| `oil.png` | Minyak goreng | Bahan baku | a bottle of cooking oil |
| `milk.png` | Susu | Bahan baku | a carton of milk |
| `butter.png` | Mentega | Bahan baku | a block of butter with a wrapper |
| `cheese.png` | Keju | Bahan baku | a wedge of cheese |
| `drop.png` | Sirup / cairan | Bahan baku | a small bottle of syrup with a drop falling |
| `honey.png` | Madu | Bahan baku | a honey jar with a dipper |
| `chocolate.png` | Cokelat | Bahan baku | a bar of dark chocolate with squares |
| `coffee_beans.png` | Biji kopi | Bahan baku | a pile of roasted coffee beans |
| `herb.png` | Rempah & jamu | Bahan baku | a bundle of fresh herbs and roots (ginger, turmeric) |
| `box.png` | Kardus / kotak | Kemasan | a closed cardboard box |
| `paper_bag.png` | Tas kertas | Kemasan | a brown paper shopping bag |
| `jar.png` | Toples | Kemasan | a glass jar with a lid |
| `pouch.png` | Kemasan pouch | Kemasan | a flat zip-top pouch bag |
| `label_tag.png` | Label harga | Kemasan | a price tag with a string |
| `shirt.png` | Kemeja / kaos | Fashion & tekstil | a folded t-shirt |
| `dress.png` | Gaun | Fashion & tekstil | a dress on a hanger |
| `pants.png` | Celana | Fashion & tekstil | a pair of folded pants |
| `shoe.png` | Sepatu | Fashion & tekstil | a single sneaker shoe |
| `bag.png` | Tas | Fashion & tekstil | a handbag with a handle |
| `hat.png` | Topi | Fashion & tekstil | a baseball cap |
| `batik.png` | Kain batik | Fashion & tekstil | a folded batik cloth with a simple motif |
| `fabric_roll.png` | Kain gulung | Fashion & tekstil | a roll of fabric |
| `candle.png` | Lilin | Kerajinan & rumah tangga | a scented candle in a glass |
| `soap.png` | Sabun | Kerajinan & rumah tangga | a bar of soap with a leaf |
| `basket.png` | Keranjang anyaman | Kerajinan & rumah tangga | a woven rattan basket |
| `vase.png` | Gerabah | Kerajinan & rumah tangga | a clay pottery vase |
| `wood.png` | Kayu | Kerajinan & rumah tangga | a wooden plank with grain |
| `towel.png` | Handuk | Kerajinan & rumah tangga | a rolled towel |
| `cleaner.png` | Pembersih | Kerajinan & rumah tangga | a spray bottle of cleaner |
| `lotion.png` | Lotion | Kecantikan & kesehatan | a pump bottle of lotion |
| `lipstick.png` | Lipstik | Kecantikan & kesehatan | a lipstick tube |
| `perfume.png` | Parfum | Kecantikan & kesehatan | a perfume bottle with an atomizer |
| `jamu.png` | Jamu botol | Kecantikan & kesehatan | a small glass bottle of herbal jamu |
| `face_mask.png` | Masker | Kecantikan & kesehatan | a sheet face mask in a package |
| `seedling.png` | Bibit | Pertanian | a seedling sprouting from soil |
| `coconut.png` | Kelapa | Pertanian | a whole coconut |
| `rice_sack.png` | Beras | Pertanian | a sack of rice grains |
| `phone.png` | Ponsel | Elektronik & jasa | a smartphone |
| `laptop.png` | Laptop | Elektronik & jasa | a closed laptop |
| `battery.png` | Baterai | Elektronik & jasa | a battery |
| `cable.png` | Kabel | Elektronik & jasa | a coiled charging cable with a plug |
| `headphone.png` | Headphone | Elektronik & jasa | a pair of headphones |
| `printer.png` | Printer | Elektronik & jasa | a small desktop printer |
| `stationery.png` | Alat tulis | Elektronik & jasa | a pencil and a pen |
| `repair_tool.png` | Perkakas | Elektronik & jasa | a wrench and a screwdriver crossed |
| `pet_food.png` | Makanan hewan | Hewan peliharaan | a pet food bag with a paw print |
| `deadstock.png` | Deadstock | Sirkular & limbah | a crate with a small warning badge |
| `recycle.png` | Daur ulang | Sirkular & limbah | two arrows forming a loop (recycling) |
| `compost.png` | Kompos | Sirkular & limbah | a small pot with compost and a sprout |
| `waste.png` | Limbah | Sirkular & limbah | a trash bin |
| `eco.png` | Ramah lingkungan | Sirkular & limbah | a green leaf |
| `inventory.png` | Produk umum | Umum | a generic product box with a tag |

## Notes

- Keys are stored in the database as `icon_key`. Do not rename a file after release; add a new key instead.
- The Material fallback icons are a stopgap, listed in `lib/features/inventory/data/product_icons.dart`.
- UI icons (buttons, navigation, status) stay Material icons. Only product icons come from this pack.
