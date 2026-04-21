'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "75ba61bab6ad7451fe513927bb61f98f",
"version.json": "16593d5241f585ca3c870bf4e5d7ff9b",
"index.html": "f4a213b1573663f26392bc73ec2d3341",
"/": "f4a213b1573663f26392bc73ec2d3341",
"main.dart.js": "bd0eb7522fdb5d1c4a4f27d64869ecfa",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "18e86ab49eb0f67f47e7ac98b6d8767e",
"icons/Icon-192.png": "4ad541cff89aa38c74f68e0f6b39974a",
"icons/Icon-maskable-192.png": "4ad541cff89aa38c74f68e0f6b39974a",
"icons/Icon-maskable-512.png": "3128339b47031a40eae79465a0d16dfa",
"icons/Icon-512.png": "3128339b47031a40eae79465a0d16dfa",
"manifest.json": "7e4600aaa7b07322f0684ac279db36e3",
"assets/NOTICES": "77097ae188cbec6e98941491095e694e",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "69db5c6c43c3db5e1016422cb8660060",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/AssetManifest.bin": "31606e8c636bfa537ba0d9a73d3b405e",
"assets/fonts/MaterialIcons-Regular.otf": "f9e1b56bdf9cae22da0481685c9821ba",
"assets/assets/data_from_exel.txt": "743cf75b883eebf6529ad801da849c5a",
"assets/assets/fusion_onyx_stats.json": "25fc5433f973465c7cf4a7ced5bbac70",
"assets/assets/images/Parrot.png": "b47abc9f23365faf927f8ab745535c32",
"assets/assets/images/Dog.png": "a0fd8c25b9649a488ac48e3ffe711729",
"assets/assets/images/Destruction.png": "b7c2e794ca348a389bedc8f7aa4c3d07",
"assets/assets/images/Wealth.png": "4665d43cef2b154f16e2b91441233feb",
"assets/assets/images/Desert.png": "7d3c9bec348d40d880edef971f8ad887",
"assets/assets/images/Horse.png": "52949b9089b325ef605f9c796f70a8da",
"assets/assets/images/Wizarding%2520School.png": "23959bc19b9d72c8f7a45c48794dbe8a",
"assets/assets/images/War.png": "398efc31bd30b6fcd92b605528b84eb1",
"assets/assets/images/Card.png": "e1534b7d32d6611ffa19f108f6f73235",
"assets/assets/images/Affliction_(Onyx).png": "402c4dcc87e3a94216d1197a2e974ac7",
"assets/assets/images/Cartoon_(Onyx).png": "256af4f4c6e6fca2edec8867485b8cef",
"assets/assets/images/Wraith.png": "403fdc8b09d00b611e2f25064b34667f",
"assets/assets/images/Human_(Onyx).png": "d8ed323330900ac39ed9b8fff01372a1",
"assets/assets/images/Poison_(Onyx).png": "c980062e45fe750efaa8d6e0311128af",
"assets/assets/images/Ancient%2520Ark.png": "07e29de6f505b53f35db58105e5ae42a",
"assets/assets/images/Carver%2520of%2520Doom.png": "82c3230e8f107be656a350a7b4a465e4",
"assets/assets/images/Underground.png": "a2be100ef52fd405c905b51d76a83820",
"assets/assets/images/Pirate.png": "0e2df568b60a3670dbd263c6a0c868c7",
"assets/assets/images/Science.png": "24ad9d1a83d542090a5aa0e00e9cb3bb",
"assets/assets/images/Beauty.png": "168c51567e0170651eb131a7d89e184f",
"assets/assets/images/Turtle.png": "76aa656c3ffa96ea9aef4c8410c0868f",
"assets/assets/images/Insect_(Onyx).png": "e2d8d3c31c7a9a1389bad1e3bbc75864",
"assets/assets/images/Sci-Fi.png": "876ff7ffe5dc16755919ba7128f74529",
"assets/assets/images/Fish_(Onyx).png": "ca094a8322a2d685ea66adf584da112e",
"assets/assets/images/Plant.png": "7d4824f4b68bee7eb13c798c895b06d2",
"assets/assets/images/Turkey%2520Day.png": "d22189f8f5b16f65eac87ee52e391ec8",
"assets/assets/images/Bird_(Onyx).png": "760a5c852634284d3d1b823035e6ad9e",
"assets/assets/images/Werewolf_(Onyx).png": "36dad6152440c14d9ea53aea103ccbb3",
"assets/assets/images/Precious%2520Ring%2520Lore_(Onyx).png": "51c38485f6251700c6b74452a7aeb4fa",
"assets/assets/images/Arachnid.png": "42e1e230d6ce2e4165e2cfb137403b1a",
"assets/assets/images/Dog_(Onyx).png": "b05b0cb634ff108efd36ffc4319aa9f5",
"assets/assets/images/Harpy.png": "10577903f7ce94a5f968a3ce594558df",
"assets/assets/images/Wizard_(Onyx).png": "a262caaca61ff414062f03837c1c6009",
"assets/assets/images/Chinchilla.png": "735318a12ca92a57584a8b065d8b0737",
"assets/assets/images/Mutation.png": "e6a9d11e61124219ba0b5fc77ffa5b80",
"assets/assets/images/Parasite.png": "c5face1597d7994ddce553fd2bcfca1f",
"assets/assets/images/Life_(Onyx).png": "0b3b8049d2f36e5e1e1feeeaac63c23d",
"assets/assets/images/Holy%2520Water.png": "4a8addec314b0f7cc6fc6af78127aa34",
"assets/assets/images/Extraterrestrial.png": "3348cb2802e326602528d9f7c5336121",
"assets/assets/images/Doves.png": "203743e412ae0d03e5814ee653b92c86",
"assets/assets/images/Weapon_(Onyx).png": "d381ad175e39b70c29ca57763a3f1917",
"assets/assets/images/Monster_(Onyx).png": "2676299af8837a31577f163fae3fdfd1",
"assets/assets/images/Time.png": "9a70ad0bdd96ae1888abf57834933f22",
"assets/assets/images/Metal.png": "04f5a78469291c72a75290a6806e9034",
"assets/assets/images/Knowledge.png": "b3f8849c96bcc2c72099dd650e72f9c3",
"assets/assets/images/Celebration_(Onyx).png": "252b2954d951a3449163f7c5d61e347e",
"assets/assets/images/Sun_(Onyx).png": "395ad10ec00489b333bd95d3088b73aa",
"assets/assets/images/Negative%2520Slime.png": "4c38af540f6f5a226acc276fa7e2c964",
"assets/assets/images/Radiation_(Onyx).png": "57f4bde4186fc51bd721b517b589c1a1",
"assets/assets/images/Medieval.png": "956e8f57e578d13f9b19b40c028b895f",
"assets/assets/images/Space.png": "22d24ea609d4c3db6d246e1de9b9bde7",
"assets/assets/images/Horn_(Onyx).png": "98b9340b8272d857e8934bc80998f771",
"assets/assets/images/Affliction.png": "ffeae4968f4018bb49a3cfc7b69ef43f",
"assets/assets/images/Water%2520Serpent_(Onyx).png": "b36dc22d9157239bf517f9c36134de11",
"assets/assets/images/Ash.png": "4fc134f31849ea89739c53ee0ac8b122",
"assets/assets/images/Extraterrestrial_(Onyx).png": "6bd93404316b3120c419651fd6661b02",
"assets/assets/images/Turkey%2520Zombie.png": "15acdfe4c4949753757bdfb55923b461",
"assets/assets/images/Arcade.png": "2badf2cca9a986cdd17f31a51de52682",
"assets/assets/images/Healing.png": "54f6bcf88ec711b8e2241d8504f4adbe",
"assets/assets/images/Sleep.png": "559ea29962d6427313ec32c7c7b3eac9",
"assets/assets/images/Earth_(Onyx).png": "1a79f1f7770c16d462adc492b4ad2939",
"assets/assets/images/New%2520Years.png": "382a8a8d6bf41f8bddca759ff003cd8e",
"assets/assets/images/Fire.png": "5a7981c85aa181b451385e2f7f9075b7",
"assets/assets/images/Destruction_(Onyx).png": "dfe99a98f94d3a420ff991122524317f",
"assets/assets/images/Leader_(Onyx).png": "d264d7eee15707552ad900bf114b9a86",
"assets/assets/images/Leader.png": "f83c6483a03ee645fbddc3b8d771632a",
"assets/assets/images/Dragon_(Onyx).png": "81ee5c3f55c3253b9f034eec65426eca",
"assets/assets/images/Demon_(Onyx).png": "781ec6e1346bd658d9c93e9fa2689565",
"assets/assets/images/Energy.png": "a47e74c6f89ed3f40b8f8bbeef84102a",
"assets/assets/images/Cursed.png": "364b9ea7bc46ddaf4a101057a4dc88b7",
"assets/assets/images/Transmutation.png": "d550706703ac4eb242d0e63ef3e5a4a8",
"assets/assets/images/Relic.png": "126ac60f7e0730893633727518b48cdd",
"assets/assets/images/Multiples.png": "6b5cbce91f360e98241d4282a443aae2",
"assets/assets/images/Wizard.png": "ae6046163c2f5bbe57692b7ce26ba7bd",
"assets/assets/images/Sweets.png": "08707d0b5ea1660fc2e91e5974489891",
"assets/assets/images/Atomic%2520Aftermath.png": "f2ef56161a73c3dd2116378fc1361408",
"assets/assets/images/Bear_(Onyx).png": "882fd281ddbf1fabd7ac9d8135d407aa",
"assets/assets/images/Invention_(Onyx).png": "40519fe94795e734bc9fd54bce2fddfc",
"assets/assets/images/Speed.png": "22280d8b326776258da0edfec653ee78",
"assets/assets/images/Holidays.png": "2f09c52102a44a241b70b21d525a8cc1",
"assets/assets/images/Villain_(Onyx).png": "7eb26643f91ef7a7b42b6b1bdda791c0",
"assets/assets/images/Void_(Onyx).png": "a6353e524eedeaa8b83f597912dcf1e1",
"assets/assets/images/Death_(Onyx).png": "66f63c057d4592fecaf61f011623d9f9",
"assets/assets/images/Slime%2520Warrior.png": "d919e0c60e3b1bf62946243e4a090eea",
"assets/assets/images/Nightmarish%2520Swarms.png": "85e21ed45956d24299ea39b98668ccb1",
"assets/assets/images/shop_packs/shop_pack_Bloody.png": "d70c4121bf259c87b61d2f5aff2b742b",
"assets/assets/images/shop_packs/shop_pack_Chosen_Hero.png": "f3f8cf15e7a69fc8a548841e2dd0df2e",
"assets/assets/images/shop_packs/shop_pack_Insanity.png": "b4c1842c878d7a9446ad6335e9d11792",
"assets/assets/images/shop_packs/shop_pack_Bug.png": "0633f31ffc09dee0014b3910dd0d4940",
"assets/assets/images/shop_packs/shop_pack_Commander.png": "da95c3ff9b059d7138d800141d786e65",
"assets/assets/images/shop_packs/shop_pack_Purrrfect.png": "367802911f9c502178ff4b5ac1712e92",
"assets/assets/images/shop_packs/shop_pack_Lunar.png": "79175653d4fa84504b8fd5ff07052860",
"assets/assets/images/shop_packs/shop_pack_Subterranean.png": "7f5a51db1ddff455506651d9f526311f",
"assets/assets/images/shop_packs/shop_pack_Innovation.png": "53a2180a3bcd3d312a36b03328b6f18b",
"assets/assets/images/shop_packs/shop_pack_Advanced.png": "cde454b64817b2c9ca105940978d3fd6",
"assets/assets/images/shop_packs/shop_pack_Viking.png": "3fa71ec82e6ae71b9abcfecb93c22bd8",
"assets/assets/images/shop_packs/shop_pack_Sahara.png": "0a524b25154b201c0267b263cef9fc81",
"assets/assets/images/shop_packs/shop_pack_Cloaked.png": "78a357c1dd05a800cab7b8f1a00577de",
"assets/assets/images/shop_packs/shop_pack_Scheming.png": "96ea197f779c9c2bff1272563d141bea",
"assets/assets/images/shop_packs/shop_pack_The_Dark.png": "031b9b6908e2b75155f04f80f3659293",
"assets/assets/images/shop_packs/shop_pack_Scaly.png": "e7c5fe9073b28c3e1883f90ae615a582",
"assets/assets/images/shop_packs/shop_pack_Thanksgiving.png": "da0cac5344c02e4af3ebe4ea17d64bc1",
"assets/assets/images/shop_packs/shop_pack_Fight.png": "416d57e6e9e0b646a9c45b8ceed5bb19",
"assets/assets/images/shop_packs/shop_pack_Booming_Spike.png": "8454f173e11e14cff8a05beec4d6adc5",
"assets/assets/images/shop_packs/shop_pack_Millionaire.png": "3876661b8e186bf124a975dd1bdcaa4f",
"assets/assets/images/shop_packs/shop_pack_Meta.png": "9562d0db07f33e9d30718e4fd2d6236c",
"assets/assets/images/shop_packs/shop_pack_Parasitic.png": "99fb5205a868ce3a3cc11e0ece5075e2",
"assets/assets/images/shop_packs/shop_pack_Zoom_Zoom.png": "4ef8cd42167f163027d0316873c3626d",
"assets/assets/images/shop_packs/shop_pack_Wintertide.png": "ebdb46e81eece0bbfed71de0212afc34",
"assets/assets/images/shop_packs/shop_pack_Leftovers.png": "fcec50f70bffc87de67a410802312db7",
"assets/assets/images/shop_packs/shop_pack_Jungle.png": "06ef4533e664291f635154688e653725",
"assets/assets/images/shop_packs/shop_pack_Artifact.png": "2d0e4f041952b83ea574497bf97ed646",
"assets/assets/images/shop_packs/shop_pack_Aviary.png": "afbc8a7b959965125689700605267e99",
"assets/assets/images/shop_packs/shop_pack_Summertide.png": "410e64856f5c8460de2d9b32617273bd",
"assets/assets/images/shop_packs/shop_pack_Phantom.png": "2c5bc340b8245854fc1bdd74c4f8290c",
"assets/assets/images/shop_packs/shop_pack_Confectionery.png": "ebaf050973f514f1e9f35c995e931633",
"assets/assets/images/shop_packs/shop_pack_Regal.png": "62340cb85ee91223ec696d3699d393c1",
"assets/assets/images/shop_packs/shop_pack_Adversary.png": "8d020beebc326404c5da1059f5f3a4c1",
"assets/assets/images/shop_packs/shop_pack_Swift.png": "7f1863006bf383f6d8e40505148dc7e0",
"assets/assets/images/shop_packs/shop_pack_First_Aid.png": "67577d6ccfd9708483b01125b1e219ce",
"assets/assets/images/shop_packs/shop_pack_Undying.png": "9a35e4ac659fbed31c2242fef8c4de33",
"assets/assets/images/shop_packs/shop_pack_Portal.png": "03694ff14ece14b29913423603b146fc",
"assets/assets/images/shop_packs/shop_pack_Tiny.png": "1380582ad4f47b5cdf6bf1f0618daa6d",
"assets/assets/images/shop_packs/shop_pack_Anniversary.png": "b4b4557caeaf54ae468ee201f4315faf",
"assets/assets/images/shop_packs/shop_pack_Multiplicity.png": "5deab3a4d43d13e1b90daf760187c399",
"assets/assets/images/shop_packs/shop_pack_Dr._Frankenstein.png": "e62cc3aec80ba6dfbf2565f02fab3cd0",
"assets/assets/images/shop_packs/shop_pack_half_half.png": "cd62f8acfae61f6f8cb0a1c9db7cf2b7",
"assets/assets/images/shop_packs/shop_pack_Martian.png": "60a6cbfb2ae70d723b0de50d71e7caf2",
"assets/assets/images/shop_packs/shop_pack_Dark_Ages.png": "b8be1695b1f9ae636bb2286d4580b740",
"assets/assets/images/shop_packs/shop_pack_Shrine.png": "06106f81b64889ebc6178cb2c630c2f2",
"assets/assets/images/shop_packs/shop_pack_End_of_World.png": "3fe2106a36f7b8403a27e570f299790d",
"assets/assets/images/shop_packs/shop_pack_Frozen.png": "12a0bb86c1e23c48dc51145424d0f4b1",
"assets/assets/images/shop_packs/shop_pack_Melody.png": "249f74bec985cfc28bb5e9d9053c5285",
"assets/assets/images/shop_packs/shop_pack_Tortoise.png": "74d0769481b64f486ad2e02fbf30e962",
"assets/assets/images/shop_packs/shop_pack_Hypno.png": "e437981a81d2aec8a3382e0416c03f5e",
"assets/assets/images/shop_packs/shop_pack_Accursed.png": "e888a2a27e26b2bb2f32f332ec7db852",
"assets/assets/images/shop_packs/shop_pack_Rat.png": "a5586626a3b44349bdc80f071f949b30",
"assets/assets/images/shop_packs/shop_pack_Far_Away.png": "2b20f55792090fb9972465915f68c138",
"assets/assets/images/shop_packs/shop_pack_Fable.png": "ae79131084912bfa436ab53b392f0f8d",
"assets/assets/images/shop_packs/shop_pack_Yuletide.png": "35db24e7bb77af910ed744816ad59273",
"assets/assets/images/shop_packs/shop_pack_Mon.png": "d9c009fb56905c4b26e3f2d181304ae0",
"assets/assets/images/shop_packs/shop_pack_Comic_Book.png": "a794dc0b4ad35799f499174fb7cf6bd1",
"assets/assets/images/shop_packs/shop_pack_Combat.png": "12497ae6921ccd338b0ae20c4ad764bf",
"assets/assets/images/shop_packs/shop_pack_Aquatic.png": "c779a10c3e64e427a0968ce7342f10f6",
"assets/assets/images/shop_packs/shop_pack_Atomic_Aftermath.png": "158f8dc343ded88fb10c0dd863d6132f",
"assets/assets/images/shop_packs/shop_pack_Slime.png": "1d49526f8fbde9f6d2eff3370f8176cc",
"assets/assets/images/shop_packs/shop_pack_Rage.png": "18a52524491c99c5e9bf9b463a2a9a7d",
"assets/assets/images/shop_packs/shop_pack_Sports.png": "05a2d118e06822885f62102c0ec0e8e7",
"assets/assets/images/shop_packs/shop_pack_Hope.png": "75fc57c1b2b2c0133c384238cde59479",
"assets/assets/images/shop_packs/shop_pack_Futuristic.png": "694a1d18b33e3e437aa78cd41ef6ddd6",
"assets/assets/images/shop_packs/shop_pack_Wingman.png": "2b87051fe8b59ccf3912dca0b4057dfe",
"assets/assets/images/shop_packs/shop_pack_Gamer.png": "85c510ae142ed2a7e8e94c7bac7f406c",
"assets/assets/images/shop_packs/shop_pack_Mythos.png": "b08ccc64f0b0e084921b48d65107b626",
"assets/assets/images/shop_packs/shop_pack_Animation.png": "5c11bcc6ca4f117f9b922051a724521b",
"assets/assets/images/shop_packs/shop_pack_Wizarding.png": "2a3046bf07584ab4caf55f9f3e5ed1c3",
"assets/assets/images/shop_packs/shop_pack_Arachnid.png": "f060822ae3a2f732c89e649ec906ac14",
"assets/assets/images/shop_packs/shop_pack_Skeletal.png": "6f801623f6e5449ceb4aa575cd4ee5ec",
"assets/assets/images/shop_packs/shop_pack_Hallow's_Eve.png": "6d4f650d978ae5182ba790f8f340b0ee",
"assets/assets/images/shop_packs/shop_pack_Carnage.png": "7459bd237e650759020822d182287211",
"assets/assets/images/shop_packs/shop_pack_Nemesis.png": "692443a1f9d3f381aa1151cada53dcd5",
"assets/assets/images/shop_packs/shop_pack_Alien_Dino.png": "cbfc520a91168100db22247559ad3569",
"assets/assets/images/shop_packs/shop_pack_Gargantuan.png": "42a3f63830e9468759ccf6f0cb9c427e",
"assets/assets/images/shop_packs/shop_pack_Botanical.png": "c9fd0452f06c969238a5b47d004cf4a1",
"assets/assets/images/shop_packs/shop_pack_valentine_s.png": "07a91602cde51fd8d869c08fac31b2f4",
"assets/assets/images/shop_packs/shop_pack_Primate.png": "7500d582c595a5ab672a773e06c6a98e",
"assets/assets/images/shop_packs/shop_pack_Oceana.png": "1bb1d5bc2176656cb8682b6d61cec93a",
"assets/assets/images/shop_packs/shop_pack_New_Years.png": "cd4f5a20a8421999f317c9b404ff9b21",
"assets/assets/images/shop_packs/shop_pack_Mutant.png": "19d06c740a16251311ec0666b53ff48d",
"assets/assets/images/shop_packs/shop_pack_Pirate.png": "9be54a4480238a0ced105ced74aeea70",
"assets/assets/images/shop_packs/shop_pack_Vanity.png": "f062616b2b03a4d289185ef0683f15ce",
"assets/assets/images/shop_packs/shop_pack_Muscle.png": "2d6e3e92f5da874f8bbddc3775afa100",
"assets/assets/images/shop_packs/shop_pack_Fantasy.png": "82c819959124036fda1e29af74628e65",
"assets/assets/images/shop_packs/shop_pack_Starter.png": "330549321dab2c68d89930d9ab7d2846",
"assets/assets/images/shop_packs/shop_pack_Adventure.png": "f2ac3437f220bca8dd7d40648d24a6a8",
"assets/assets/images/shop_packs/shop_pack_Arms.png": "c64fc27516ac5f43635f51c2d70dde90",
"assets/assets/images/shop_packs/shop_pack_Spycraft.png": "63e5584c72165cec86bd51be02fce8ab",
"assets/assets/images/shop_packs/shop_pack_Slumber.png": "86ac4a5ae44664879ed9451495111e88",
"assets/assets/images/shop_packs/shop_pack_Clairvoyant.png": "233f9a1d810958e855fc38e1dea3e8d6",
"assets/assets/images/shop_packs/shop_pack_Fun.png": "523af262c58ee37bb275957bfe840e03",
"assets/assets/images/shop_packs/shop_pack_Plague.png": "021f4ce73396c572cc39d333583f42ac",
"assets/assets/images/shop_packs/shop_pack_Canine.png": "9070d30b2f50687568af2d32fec8e326",
"assets/assets/images/shop_packs/shop_pack_Machine.png": "ff1c3e4ea3dbe902ca09cdd515902d4e",
"assets/assets/images/shop_packs/shop_pack_Future_Fight.png": "3f656b1b8567661fe7b3c3aff9c8bc3d",
"assets/assets/images/Toy.png": "3570d6144a31bf8bf25a37e52d725e1f",
"assets/assets/images/Mimic.png": "deb66ecc97292c3bcc236f1ed6e303f4",
"assets/assets/images/Dragon.png": "0f8815985b963f9aa2e52bfe4e0839db",
"assets/assets/images/Sci-Fi_(Onyx).png": "9d52756328f62c62d0709eae41d2610e",
"assets/assets/images/Angel.png": "a859b90ec9ee7eb1f8893d2102639ddb",
"assets/assets/images/Angel%2520Kid.png": "218e153e72d06b85228bf61415ef5a02",
"assets/assets/images/Wings.png": "ccc2f7694cdeeb109923f199f9e8503f",
"assets/assets/images/Life.png": "9aff48887b12a043675f645ac6e70621",
"assets/assets/images/Mutation_(Onyx).png": "4ac6a94b1c4588d4729a382c759c5ff0",
"assets/assets/images/Dragon%2520Princess.png": "3cfc8a230c3b1c4f0852cb1d29123a76",
"assets/assets/images/Arcade_(Onyx).png": "2243704cce2d3656933256e284d9a238",
"assets/assets/images/Nosferatu%2520Duck.png": "98a5fe9780bbc066b0e8ded11583f304",
"assets/assets/images/Magic_(Onyx).png": "7c1738d2ca4c0652dd4d815c32713029",
"assets/assets/images/Undead.png": "2310c2bb36689832c0fe14aadde66ba2",
"assets/assets/images/Bird.png": "d0b0f1394830eb45cd50458638a613b1",
"assets/assets/images/Arachnid_(Onyx).png": "edb30abef6a97d46af9674a32d9746bd",
"assets/assets/images/Darkness.png": "5ad332b68a2de0058ad82fb2bcd78ad4",
"assets/assets/images/Music.png": "f9eee1c8d78b6a96a99d685f09e231ff",
"assets/assets/images/Fairy.png": "917cfddbb4042c3f8e152e459572b6f4",
"assets/assets/images/Space_(Onyx).png": "e70bb34f0c919c02d8be1b1f86d3ae4d",
"assets/assets/images/Camouflage_(Onyx).png": "6e9b78d4aab751929b3add2da01e6ed5",
"assets/assets/images/Halloween.png": "aea73d21a63cd8c4471faf8b74c08443",
"assets/assets/images/Superhero_(Onyx).png": "67614c1252a5d9f01521477a2460a80b",
"assets/assets/images/Card_(Onyx).png": "761d6a05da7bbb9601471d6d400e6dbe",
"assets/assets/images/Knowledge_(Onyx).png": "851563a18fc097020bb7f76c3624d350",
"assets/assets/images/Love_(Onyx).png": "33ff7f79508b998626aa50d6bf3bd315",
"assets/assets/images/Holidays_(Onyx).png": "9f0db17375e9599dbdc21ab5b6dd6876",
"assets/assets/images/Future%2520Fight.png": "6d8bd00ecc303680e05633300cb5a08e",
"assets/assets/images/Desert_(Onyx).png": "08cadb435ba7a0baaa3bd61609248b0c",
"assets/assets/images/Plague%2520Dragon.png": "59273d87d21b504fa3982b55e55cd5df",
"assets/assets/images/Planar%2520Privateer.png": "3e0aa726dd002ca4a7fb1633c1068fcd",
"assets/assets/images/Precious%2520Ring%2520Lore.png": "0e79886f27d1feda85c91ac4f8bd50db",
"assets/assets/images/Knight_(Onyx).png": "becc53c5ed3a0a77c3fa2c12f7bd2400",
"assets/assets/images/Sidekick.png": "e88802a553df70915abdfc472b1fd541",
"assets/assets/images/Strength_(Onyx).png": "2ebd5e377458c37fb4caba96a537b18c",
"assets/assets/images/Spy.png": "e5ae637a5c1e68149d530f5bb48e9d27",
"assets/assets/images/Werewolf.png": "0c397271ac937052209c1f6705734485",
"assets/assets/images/Wind.png": "d4d2eb9d929d312e25201ee905539fb5",
"assets/assets/images/Gifted%2520Birds.png": "350771a56412e109d1b6820c1d7ec80c",
"assets/assets/images/Sports.png": "b8388befbbf1f37e8dc55c05bfffb779",
"assets/assets/images/Multiples_(Onyx).png": "98ce59a76d9455ad6c3e196d642233c6",
"assets/assets/images/Wind_(Onyx).png": "c9df34c16dbe89a9e27bd5d09e46f6fc",
"assets/assets/images/Earth.png": "6b2064de06f9673526877962d8752b0e",
"assets/assets/images/Snake_(Onyx).png": "51f1ef2e7b3353d577cf1d54811918ba",
"assets/assets/images/Adventure.png": "44379db933682c59bd4d45019be70b2f",
"assets/assets/images/Knight.png": "d6f4d99ff277694c660fa36ed4aa2dad",
"assets/assets/images/Blood.png": "78747b0116b99c29b0c9143aec25a6c6",
"assets/assets/images/Speed_(Onyx).png": "4084ac715b8c444fcb82087a7d2c5651",
"assets/assets/images/War_(Onyx).png": "2f0801d0b6ca3cf76c7b9f6f798543dc",
"assets/assets/images/Wolf.png": "6acc57de6b11b9718fd79aaa7ef469a2",
"assets/assets/images/Weapon.png": "bc9905fe200dd27d908d8c99b72b197d",
"assets/assets/images/Animal%2520Whisperer.png": "dbd4479ded0a596ff24af4dfff71f954",
"assets/assets/images/Galaxy%2520Wars.png": "496ddcaaf478dc86f824c1328caa6a16",
"assets/assets/images/Poison.png": "789e0e38bb0334f897ef2f9f171f3dbe",
"assets/assets/images/Giant.png": "52bb860696e3dcae236c996d59ef17d6",
"assets/assets/images/Dark%2520Swan.png": "465e2e0c5c03829b7cc278c8c8e9a328",
"assets/assets/images/Plucky%2520Puck-Ducks.png": "caabe7c4b95d32fcada25707d0f7f44a",
"assets/assets/images/Moon.png": "0d7c9464b361e172ddd8bbb0f82a28dd",
"assets/assets/images/Madness_(Onyx).png": "e825d6737ebbadba09a28eba29ebaa97",
"assets/assets/images/Penguin.png": "d947c526092161137e559a81e174e6c0",
"assets/assets/images/Celebration.png": "df10507ee88650e8327dfcb67623a2b4",
"assets/assets/images/Wings_(Onyx).png": "3e1f45a5fb2a76056964fc5fa960951f",
"assets/assets/images/Water%2520Serpent.png": "c439fef599a0c23f66630d94bb207e50",
"assets/assets/images/Mind%2520Slug.png": "a79bf30bce4c8d5965b6b8ab97aba700",
"assets/assets/images/Martial%2520Arts.png": "cf37de554adfde8cff2e7b5bee40eea1",
"assets/assets/images/Spirit.png": "524223c69155a03a6898938ea65d5464",
"assets/assets/images/Jungle.png": "10d81716a130d9cfae5fe2c78d683794",
"assets/assets/images/Portal.png": "bb02cc73a6cceeb4e02fad227124717d",
"assets/assets/images/Time_(Onyx).png": "4d86f1d228bea6955b005943f3b02bed",
"assets/assets/images/Invention.png": "4871c5ba6cef8202d163b4cfe7918d76",
"assets/assets/images/Sword.png": "8c2fa8a012c10abf94c3a8c6e0f8549d",
"assets/assets/images/Cat.png": "61b1537321d541e6cc1a61f672509d12",
"assets/assets/images/Food.png": "722cf655421e6e2d70ec692cc1da9a1e",
"assets/assets/images/Turtle_(Onyx).png": "36bae430fe77e99c3e9b4148d47ed7f0",
"assets/assets/images/Insect.png": "12b410337ec7bda9da155847fd60b571",
"assets/assets/images/Blob.png": "edba6fee82cfae424b25cc245cdb0e01",
"assets/assets/images/Anger.png": "9cd763a116a4d225ff3ce781f7c20302",
"assets/assets/images/Hybrid.png": "0a1c6c3c6963caada0abd30d78347f59",
"assets/assets/images/Miniature.png": "af012074897449880ddeb746f1e918df",
"assets/assets/images/Trident.png": "93be26ad975e2ac0e94b1a9f07d46950",
"assets/assets/images/Sword_(Onyx).png": "548b42d68b8b8f12f08105d98f313505",
"assets/assets/images/Puff%2520Hero.png": "76f01a960549ef4dba75cbdf845bd3f1",
"assets/assets/images/Energy_(Onyx).png": "46c22cebb553c208f8c9f459d3ae074e",
"assets/assets/images/Toy_(Onyx).png": "ee044b30d475be3e5ae697bbdd16cbb1",
"assets/assets/images/Prehistoric_(Onyx).png": "c28e682509874780b8f203cf4aa31a7c",
"assets/assets/images/Alien%2520Beastie.png": "a8cb4d86104b5aca9d6a150a408592cf",
"assets/assets/images/Mind%2520Control.png": "0ddd416174e7aadda88aae4f3a7bb96b",
"assets/assets/images/Ice.png": "22ab01d8b154be04e9532148742f66e8",
"assets/assets/images/Void.png": "a350e0d95255ab8e586d5623f3b3c9c9",
"assets/assets/images/Cartoon.png": "f5115f977661c44ba641580f452d4232",
"assets/assets/images/Wealth_(Onyx).png": "7c125aa60983d8cf41f4b8584ffb7247",
"assets/assets/images/Madness.png": "3e056d5cf730476799e489167e957c98",
"assets/assets/images/Hopefulness.png": "b7eda72af7acf5271c13810ae2f4a1e1",
"assets/assets/images/Water.png": "e6b348b798161c326be5357f5163e6b5",
"assets/assets/images/Flea.png": "c88aadfc4235f31a6d95e4ab86244009",
"assets/assets/images/Undead_(Onyx).png": "16497666f341d771d1238855bde98310",
"assets/assets/images/Elf.png": "7ca0001cb9bd53544b7ab9ff8efd9e4d",
"assets/assets/images/Tree.png": "b835e02a5116de752ed9b1058c11eed2",
"assets/assets/images/Robot.png": "27cb51ef064d5a1f5912ba02e373f99b",
"assets/assets/images/Pocket%2520Pet.png": "85b301f98ec6789028539febc4d3e029",
"assets/assets/images/Fairy%2520Tale.png": "f62fe51b9c9154dd5845a62afc18a32e",
"assets/assets/images/Radiation%2520Sickness.png": "66d8f1f48a922adb731f98672aff3113",
"assets/assets/images/Goblin%2520Banker.png": "2f4926eeb39f8e71ac6711de5e6785ee",
"assets/assets/images/Pocket%2520Pet_(Onyx).png": "fa6089a3b4647dfc2efe9c68655de79c",
"assets/assets/images/Blood_(Onyx).png": "9d73dee8f048fdae473fe3a581025dd4",
"assets/assets/images/Royalty.png": "6af3ce2f3166299e082b0c284589348f",
"assets/assets/images/Reptile.png": "b8ef1b153c0e48d0b04fb92d8008ecb7",
"assets/assets/images/Relic_(Onyx).png": "25165553a9679de534c31d3acfc32492",
"assets/assets/images/Fairy_(Onyx).png": "a7057c31986358dd5492d93b9b24bb65",
"assets/assets/images/Royal%2520Game.png": "3c754893bf52d1a68277ff7a7b443b01",
"assets/assets/images/Fire_(Onyx).png": "3f9a43a6006249cef99474a3db3e4670",
"assets/assets/images/Shrine.png": "93acebd3648b746f3850316c74bc9a15",
"assets/assets/images/Angel%2520of%2520Wrath.png": "841f8d6a43d4b3d42ff219af38e15066",
"assets/assets/images/Human.png": "eb0f9857e3502c393a2366236e2707bc",
"assets/assets/images/Superhero.png": "2d4aa636dcf6ddb2e80331a99415c289",
"assets/assets/images/Werechicken.png": "6e5a5ef09398f9a95dc370294fe1ed80",
"assets/assets/images/Water_(Onyx).png": "7d3b9b1af95fffcba513d54573653abb",
"assets/assets/images/Villain.png": "f14be221bb2432872848ee1e00bade29",
"assets/assets/images/Psychic.png": "226558e57c8f68804ed9fc20d42bff84",
"assets/assets/images/Monkey.png": "9d53c93ffbf16d230167af2b79166225",
"assets/assets/images/Science_(Onyx).png": "543eae27a1a86eb0d7550e38a1aea3bf",
"assets/assets/images/Stymphalian%2520Bird.png": "1205250a31078d0be58de24a327e5997",
"assets/assets/images/Rodent.png": "45fcd84ba920f301f50f7c96b6733ea7",
"assets/assets/images/Horse_(Onyx).png": "5d6c95d7de3d3897bbda3253c7a4a02c",
"assets/assets/images/Angel%2520of%2520Valor.png": "e095aeb108e4b594a2e7f4734f878465",
"assets/assets/images/Beauty_(Onyx).png": "ed1472595b090538299ada4664e98221",
"assets/assets/images/Trident_(Onyx).png": "1767af588a0bc58d80b6310ffed1d81c",
"assets/assets/images/Bat.png": "c2980235e1ac2bbad0e199cbbd3fa225",
"assets/assets/images/Gummy%2520Duo.png": "c3f37bced87054f789e7180a9ed6a870",
"assets/assets/images/Darkness_(Onyx).png": "db83c0d65e12b81b23d83cc90c7d26cc",
"assets/assets/images/Bat_(Onyx).png": "b248bc71dba1df5b5a2f87fbe73d81de",
"assets/assets/images/Apocalypse_(Onyx).png": "a026006ebadd9fb273e9fc00f125832d",
"assets/assets/images/Underwater.png": "e3f81763e2511fd5c8b56e5a3c08cd8d",
"assets/assets/images/Fairy%2520Tale_(Onyx).png": "6c1c7a3199cb6068cf238d6c2c84bbc4",
"assets/assets/images/Hammer.png": "b6cbd2108c9d334ca1b8cbd28e119e97",
"assets/assets/images/Bone.png": "1cd7939241f06a10ff0e1139c4466068",
"assets/assets/images/Camouflage.png": "837a6ffa537afe4de7090229c956e627",
"assets/assets/images/Viking.png": "2493e65288bcf71a7a7b20a2f9528d05",
"assets/assets/images/The%2520Chosen%2520One.png": "64fb31c7ab1d3287d9d857618f35f51e",
"assets/assets/images/Vampire_(Onyx).png": "cf800b96b57771dcb2360fa088cc6ee3",
"assets/assets/images/Sun.png": "0921487f27312c5823f4abcd9edf00f8",
"assets/assets/images/Cockatrice.png": "3f2046943455fec68211b34aec71b73a",
"assets/assets/images/Ash_(Onyx).png": "8688b3a08b0fa6f67c4d3a4d9c3f5ad9",
"assets/assets/images/Apocalypse.png": "4238d4495575af32579f7831d9c32655",
"assets/assets/images/Strength.png": "15c38a357c771d6abe404d630dea50c1",
"assets/assets/images/Wolf_(Onyx).png": "226a4c97e8865a447c8bb954163db5b9",
"assets/assets/images/Love.png": "c8bd43f8c92f5121e0828a4172ce8e7a",
"assets/assets/images/Myth.png": "4fda23816999caffb8c918954df64e39",
"assets/assets/images/Death.png": "b5be9acf7c5f722073bbd98cafaad87a",
"assets/assets/images/Cat_(Onyx).png": "711a02d3fb4748a54dd0d1c0c3fc7d0a",
"assets/assets/images/Tree_(Onyx).png": "c0454a72a4cea98c2fcedcb23f3f12c7",
"assets/assets/images/Radiation.png": "50f36431293cb225cc3fb39b454ddcc8",
"assets/assets/images/Cursed_(Onyx).png": "0608d48a0486ad7525306f6c8d3e00e7",
"assets/assets/images/Anger_(Onyx).png": "0014dc7dff4db85faee16e20c13183c8",
"assets/assets/images/Magic.png": "cc2ccb23f3c9aa8dcf4d19937f42ca9d",
"assets/assets/images/Golem.png": "d0cec35bddabdc9176db1e3d989b4bd5",
"assets/assets/images/Metal_(Onyx).png": "b6041436d103dde15b1c3e37e6a8fdbf",
"assets/assets/images/Blob_(Onyx).png": "52146937a56fc4e0f310a0f335ecde9c",
"assets/assets/images/Barbarian.png": "b260d5d4d1730275aea261e0aeafd1af",
"assets/assets/images/Chinchilla_(Onyx).png": "2af6263da72c8175c6e332adceceac3a",
"assets/assets/images/Elf_(Onyx).png": "9b01edad620dddc4148b5acf2f18d1eb",
"assets/assets/images/The%2520Chosen%2520One_(Onyx).png": "25992958183b9bdf2beac0859034ee01",
"assets/assets/images/Hammer_(Onyx).png": "cdaca6077fd08a2e82b5b213be4b5875",
"assets/assets/images/Underwater_(Onyx).png": "c5e400e13a1323bb543d4c00ec3f633a",
"assets/assets/images/Vehicle.png": "81b674e957c07ef3bf2a67313d2dfca5",
"assets/assets/images/Spirit_(Onyx).png": "d3de5015980a692121ab9d8ba33e9d30",
"assets/assets/images/Monkey_(Onyx).png": "97da9ed5670e909d36e0b3ea591214a2",
"assets/assets/images/Demon.png": "49dd37e188a555a315fd22b5a7bb5eac",
"assets/assets/images/Angel_(Onyx).png": "7a40cbed6786d9a2e83862a0b288f681",
"assets/assets/images/Immortality.png": "9cabd3063394d4352466248e3e51f706",
"assets/assets/images/Bone_(Onyx).png": "44504e81f284937feabf279a0f7b3ab7",
"assets/assets/images/Monster.png": "84572ce08209fe694ecaa6235ef02d38",
"assets/assets/images/Horn.png": "b517de85a6a186e055251f4e11c87c86",
"assets/assets/images/Alicorn.png": "9f09942fd140ed478c8491b5957d648d",
"assets/assets/images/Snake.png": "1f8b585f910c33b5172e09e0460216ee",
"assets/assets/images/Bear.png": "82f14515a5012128e3e6929d47cdb6db",
"assets/assets/images/Phoenix.png": "452f82b90791f7dce768c4f186a679dd",
"assets/assets/images/Wintertide.png": "02fe664b8b3457b4b85f09062f330c5c",
"assets/assets/images/Gargoyle.png": "704f49ef372b14bb50165f0b84b380f6",
"assets/assets/images/Fish.png": "9ac99e614a5930c71ec2ffe201bd259d",
"assets/assets/images/Food_(Onyx).png": "a1c430c2e8f1d0e9aa9427823d12f2b3",
"assets/assets/images/Prehistoric.png": "6e0fb0b796fd7ccc040fb24466d81dbf",
"assets/assets/images/Summertide.png": "1dd977c7bdb0bfc370d37169ac92c93d",
"assets/assets/images/Rainbow.png": "6f49e16b8ed51a0e3c49605fd753c032",
"assets/assets/images/Vampire.png": "f44d3f4ca3d60d725358621863bf1e0b",
"assets/assets/images/Turkeyzilla.png": "f43505cdc2137ec29e1c64d0ccd13261",
"assets/assets/CombinationPatch.json": "8a80554c91d9fca8acb82f023de02f11",
"assets/assets/icons/portal/Huntress_Icon.png": "4fa9318fe32ed13704e79d6bd2719b52",
"assets/assets/icons/portal/Cyclone_Icon.png": "7d825aad082d8d9c579560c362c863b9",
"assets/assets/icons/portal/Time_Traveler_Icon.png": "2a5aa57cf753c32d9a87a864092739ae",
"assets/assets/icons/portal/Super_Villain_Icon.png": "110050ff3619b138a8b01a1f8c194363",
"assets/assets/icons/portal/Mad_Scientist_Icon.png": "f8cf241114c8daedd290d8d469a62b98",
"assets/assets/icons/portal/Invasion_Icon.png": "ef3dbee61dd6ea5659c122338b5c7c22",
"assets/assets/icons/portal/Science_Fair_Icon.png": "7d274ca80ca54170ad72c033dd82c0eb",
"assets/assets/icons/portal/Crazed_AI_Icon.png": "83c3d3493a91404459b0935273917b29",
"assets/assets/icons/portal/Monster_Bash_Icon.png": "c7a3c4cfbd2bd4cbdf5fef1a63b59e4e",
"assets/assets/icons/portal/Copper_Chef_Icon.png": "b33528b09039d879972f2b35f89787a3",
"assets/assets/icons/list/Shop.png": "c308caa2d50af334df0d5eaa1d359082",
"assets/assets/icons/list/Portal.png": "8eadad64faf8139d97be8fb90f59de82",
"assets/assets/icons/list/Arena.png": "bc21970e0d41749a5226d6d3ec1b8c42",
"assets/assets/icons/arena/MasterEnchanter.png": "2ccafae5bbe56e16992a0ef2483ee7cd",
"assets/assets/icons/arena/ComboMaster.png": "e1f82a9e8023558b3d4146acc66febe7",
"assets/assets/icons/arena/QuickLearner.png": "157d34a3ab820f44ef4b8a64c3c95a0d",
"assets/assets/icons/arena/MasterElementalist.png": "1ce69ff4cd22505bd125ae8ec588ad24",
"assets/assets/icons/arena/TieBreaker.png": "2f48c1d871c1a492a1e3cf61e513c5cd",
"assets/assets/icons/arena/MasterHealer.png": "a8293b7764de7a0a65643e8cce4b4feb",
"assets/assets/icons/arena/GreedAlchemist.png": "169b71d8e578cfd7def92de375ab0cff",
"assets/assets/icons/arena/Lucky.png": "20a703234b71bb577668fd5119e2960b",
"assets/assets/icons/arena/Lobotomizer.png": "5fb3b58cf5c20dfa573107827dcdaf53",
"assets/assets/AlchemyCardData.json": "b6bcf2142ab8cea1f9f365d35455a485",
"assets/assets/data/special_packs.json": "bf8efe279dcc14d72fbf33bb5a988517",
"assets/assets/data/shop_pack_contents.json": "c18b789e6292ac87ae9428c42c0d897e",
"assets/assets/data/onyx_wiki_display_names.json": "ee4d308856d669c4fe9a166d5b3de10a",
"assets/assets/data/pack_schedule_occasions.json": "128de4c98c85a93e1239552a1b035016",
"assets/assets/data/shop_packs.json": "7fa69297b2df6e4496ad0a093f68945b",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
