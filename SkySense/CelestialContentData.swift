import Foundation

// Note: Named `CelestialContent` to avoid collision with the existing `CelestialObject` in CelestialDatabase.swift
struct CelestialContent: Identifiable {
    let id = UUID()
    let name: String
    let category: String // "Planet", "Star", or "Satellite"
    let personaSubtitle: String
    let stat1: String // e.g., "⏱️ Light takes 43 mins to reach you"
    let stat2: String // e.g., "🏙️ Pierces through city lights"
    let stat3: String // e.g., "🌍 1,300 Earths fit inside"
    let mythParagraph: String
    let realityParagraph: String
}

struct CelestialContentDatabase {
    static let content: [CelestialContent] = [
        // MARK: - Satellite
        CelestialContent(
            name: "Moon",
            category: "Satellite",
            personaSubtitle: "The Original Nightlight",
            stat1: "🌖 Controls the ocean tides",
            stat2: "👣 Still has human footprints",
            stat3: "📏 Drifting 3.8cm away every year",
            mythParagraph: "For millennia, humans looked up and saw a deity riding a silver chariot across the dark. Many cultures believed its changing shape controlled fertility, harvests, and the very flow of time itself.",
            realityParagraph: "Stepping onto its surface feels like standing in a silent, grey desert where gravity is just a suggestion. With no atmosphere to scatter light, the sky remains pitch black even when the blinding sun is out."
        ),
        
        // MARK: - Planets
        CelestialContent(
            name: "Mercury",
            category: "Planet",
            personaSubtitle: "The Speed Demon",
            stat1: "🏎️ Zips around the sun in 88 days",
            stat2: "🌡️ Swings from freezing to boiling",
            stat3: "🪨 Covered in ancient craters",
            mythParagraph: "Named after the swift-footed messenger of the Roman gods, ancient astronomers noticed how quickly it darted across the sky. Some even thought it was two different stars—one in the morning and one at night.",
            realityParagraph: "Standing here would be a nightmare of extremes. You'd face a blinding sun three times larger than you're used to, baking you alive, while just a few steps into the shadows, you'd instantly freeze in the eternal cold."
        ),
        CelestialContent(
            name: "Venus",
            category: "Planet",
            personaSubtitle: "The Hottest Planet in the Room",
            stat1: "🔥 Hot enough to melt lead",
            stat2: "☁️ Crushing toxic clouds",
            stat3: "⏪ Spins backward",
            mythParagraph: "Because it shines so brilliantly in the twilight, it was named after the goddess of love and beauty. Ancient poets called it the Morning Star, a beacon of hope before the dawn.",
            realityParagraph: "Landing on Venus is like stepping into a pressure cooker filled with battery acid. The air is so thick it feels like walking through deep water, and the crushing weight of the toxic atmosphere would snap a submarine in half."
        ),
        CelestialContent(
            name: "Mars",
            category: "Planet",
            personaSubtitle: "The Rusty Desert",
            stat1: "🔴 Covered in iron oxide (rust)",
            stat2: "🏔️ Home to a giant volcano",
            stat3: "🤖 Populated entirely by robots",
            mythParagraph: "Its blood-red glow inspired fear and awe, leading the Romans to name it after their god of war. Countless stories were written about canals and ancient civilizations hiding just beneath its dusty surface.",
            realityParagraph: "It’s like being stranded in a freezing, endless desert under a pale, butterscotch sky. The air is so thin you can't breathe, and if you watched a sunset, you'd see a small, distant sun dipping below the horizon in an eerie blue glow."
        ),
        CelestialContent(
            name: "Jupiter",
            category: "Planet",
            personaSubtitle: "The Heavyweight Champion with a Stormy Heart",
            stat1: "🌪️ Has a storm bigger than Earth",
            stat2: "🛡️ Protects us from asteroids",
            stat3: "🌍 1,300 Earths fit inside",
            mythParagraph: "Commanding the sky with its bright, steady light, it was the king of the gods in Roman mythology. Ancient stargazers respected it as the supreme ruler of the celestial spheres.",
            realityParagraph: "There is no ground to stand on—just an endless, bottomless ocean of swirling, howling gas. If you fell in, you would be crushed by hurricane winds and unfathomable pressure long before reaching its mysterious, metallic core."
        ),
        CelestialContent(
            name: "Saturn",
            category: "Planet",
            personaSubtitle: "The Lord of the Rings",
            stat1: "💍 Surrounded by floating ice rings",
            stat2: "🎈 Could float in a giant bathtub",
            stat3: "🌪️ Raging hexagonal storms",
            mythParagraph: "Moving slowly across the backdrop of stars, it was associated with time, agriculture, and the father of the gods. Before telescopes, no one knew it was wearing the most spectacular jewelry in the sky.",
            realityParagraph: "It's a beautiful but violent world of swirling pale yellow clouds. Up close, its famous rings aren't solid paths, but a chaotic demolition derby of billions of sparkling ice chunks and boulders crashing into each other at dizzying speeds."
        ),
        CelestialContent(
            name: "Uranus",
            category: "Planet",
            personaSubtitle: "The Sideways Roller",
            stat1: "🧊 Freezing icy core",
            stat2: "🔄 Rolling on its side",
            stat3: "💎 Might rain literal diamonds",
            mythParagraph: "Invisible to the naked eye for most of history, it was the first planet discovered using a telescope. It broke the ancient boundaries of the known universe, named after the primordial Greek god of the sky.",
            realityParagraph: "It’s a bizarre, pale blue world where the seasons last for decades because the entire planet is knocked over. Plunging into its atmosphere would be a freezing, dark descent into an ocean of slushy water, ammonia, and methane."
        ),
        CelestialContent(
            name: "Neptune",
            category: "Planet",
            personaSubtitle: "The Windy Blue Giant",
            stat1: "💨 Winds blow faster than sound",
            stat2: "🥶 Coldest planet in the system",
            stat3: "🌊 Deep azure blue color",
            mythParagraph: "Its existence was predicted by math before anyone actually saw it through a telescope. Because of its deep, rich blue color, it rightfully earned the name of the Roman god of the sea.",
            realityParagraph: "This is a place of sheer violence, where freezing supersonic winds whip clouds of methane ice around the planet. It’s a dark, stormy abyss where the sun is just a bright star in an otherwise pitch-black sky."
        ),
        
        // MARK: - Stars
        CelestialContent(
            name: "Sirius",
            category: "Star",
            personaSubtitle: "The Diamond of the Night",
            stat1: "💎 The brightest star we can see",
            stat2: "🐶 Known as the Dog Star",
            stat3: "🔥 Actually two stars dancing",
            mythParagraph: "Ancient Egyptians watched for its return in the dawn sky, as it magically predicted the annual flooding of the Nile. It was revered as the cosmic soul of the goddess Isis, bringing life to the desert.",
            realityParagraph: "If it replaced our sun, Earth's oceans would boil away instantly. It pumps out sheer, intense heat and blinding white-blue light, partnered in a dizzying gravitational waltz with a tiny, super-dense dead star."
        ),
        CelestialContent(
            name: "Canopus",
            category: "Star",
            personaSubtitle: "The Navigator's Guide",
            stat1: "🧭 Used by spacecraft to steer",
            stat2: "🌟 Second brightest in the sky",
            stat3: "🔥 A bloated supergiant",
            mythParagraph: "Named after the legendary pilot of the Spartan fleet in Greek mythology, it has always been a beacon for those lost at sea. Polynesian voyagers used it to navigate the vast, uncharted Pacific Ocean.",
            realityParagraph: "It is a massive, swollen giant burning fiercely in the deep south. If you were close to it, the sheer intensity of its yellow-white radiation would be overwhelming, a blazing inferno thousands of times more luminous than our own sun."
        ),
        CelestialContent(
            name: "Rigil Kentaurus",
            category: "Star",
            personaSubtitle: "The Next-Door Neighbor",
            stat1: "🤝 Actually a triple star system",
            stat2: "🚀 The closest stars to Earth",
            stat3: "🔭 A prime target for future travel",
            mythParagraph: "Shining in the hoof of the legendary Centaur, it has captured human imagination as the first logical stepping stone into the wider galaxy. Sci-fi writers have spent decades dreaming about who—or what—might live there.",
            realityParagraph: "Imagine looking up into a sky with two suns blazing at once. The gravitational ballet of these closely locked stars would bathe any nearby planets in shifting, complex shadows and intense, dynamic sunlight."
        ),
        CelestialContent(
            name: "Arcturus",
            category: "Star",
            personaSubtitle: "The Speeding Giant",
            stat1: "🏃‍♂️ Moving unusually fast",
            stat2: "🟠 A massive red giant",
            stat3: "🍂 Harvester of the spring sky",
            mythParagraph: "To the ancient Greeks, it was the 'Bear Watcher,' keeping an eternal eye on the Great Bear constellation. Polynesian navigators called it the 'Star of Joy,' guiding them to the islands of Hawaii.",
            realityParagraph: "It is an aging, bloated monster that has burned through its main fuel and puffed up to a staggering size. Floating near it would feel like being baked by a massive, angry orange coal radiating sheer, silent heat."
        ),
        CelestialContent(
            name: "Vega",
            category: "Star",
            personaSubtitle: "The Sapphire Beacon",
            stat1: "⏱️ Will be our North Star again",
            stat2: "🌪️ Spinning so fast it bulges",
            stat3: "💎 Brilliant blue-white color",
            mythParagraph: "In Asian folklore, this star represents a celestial weaver girl separated from her true love by the cosmic river of the Milky Way. They are allowed to meet only once a year on a bridge of magpies.",
            realityParagraph: "It is rotating at such a dizzying speed that it's physically stretched out into the shape of an egg. The star burns furiously bright and hot, throwing off a dazzling, piercing blue light that would blind you in an instant."
        ),
        CelestialContent(
            name: "Capella",
            category: "Star",
            personaSubtitle: "The Golden Chariot",
            stat1: "🐐 Known as the 'Goat Star'",
            stat2: "✨ Actually four stars hiding together",
            stat3: "🟡 Similar yellow glow to our sun",
            mythParagraph: "In mythology, it represented the magical goat that nursed the infant Zeus. In many ancient cultures, its bright yellow rising signaled the coming of winter and stormy seas.",
            realityParagraph: "What looks like a single friendly yellow star is actually a chaotic, crowded neighborhood. Two giant stars orbit each other so closely they are practically scraping atmospheres, while two smaller red dwarfs silently tag along in the dark."
        ),
        CelestialContent(
            name: "Rigel",
            category: "Star",
            personaSubtitle: "The Blue Supergiant",
            stat1: "💥 A ticking supernova timebomb",
            stat2: "🦶 Forms the foot of Orion",
            stat3: "🔥 Insanely hot and bright",
            mythParagraph: "Anchoring the mighty hunter Orion in the sky, it was seen as the giant's foot crushing down on the heavens. To ancient mariners, its brilliant light was a comforting anchor in the dark winter nights.",
            realityParagraph: "This is a cosmic blowtorch. It is pouring out energy at such a terrifying rate that it's physically tearing itself apart, destined to end its short, violent life in an apocalyptic explosion that will light up the entire galaxy."
        ),
        CelestialContent(
            name: "Procyon",
            category: "Star",
            personaSubtitle: "The Loyal Companion",
            stat1: "🐕 The 'Before-the-Dog' star",
            stat2: "🌟 Part of the Winter Triangle",
            stat3: "🤝 Hides a tiny dead star",
            mythParagraph: "Its name literally means 'before the dog,' as it always rises just before the even brighter Sirius. Ancient cultures saw it as a faithful scout, running ahead to announce the arrival of the great dog star.",
            realityParagraph: "It’s a bright, puffy yellow-white star that has puffed up as it ages. Orbiting quietly beside it is a white dwarf—a collapsed, dead core of a former star that packs the mass of a sun into a sphere the size of Earth."
        ),
        CelestialContent(
            name: "Achernar",
            category: "Star",
            personaSubtitle: "The River's End",
            stat1: "🌊 Marks the end of a starry river",
            stat2: "🔄 The flattest star we know",
            stat3: "🔵 Blazing hot blue star",
            mythParagraph: "It sits at the very end of the celestial river Eridanus. Because it stays so low in the southern sky, it was a mysterious, hidden gem to classical astronomers in the northern hemisphere.",
            realityParagraph: "It spins so ridiculously fast that it looks more like a spinning top or a frisbee than a round star. The extreme rotation flings its equator outward, making it a bizarre, flattened disk of blinding blue plasma."
        ),
        CelestialContent(
            name: "Betelgeuse",
            category: "Star",
            personaSubtitle: "The Beating Red Heart",
            stat1: "🫀 Pulses and changes brightness",
            stat2: "💥 Ready to explode anytime",
            stat3: "🔴 A massive red supergiant",
            mythParagraph: "Glowing with a menacing ruby-red light, it sits on the shoulder of Orion the Hunter. Aboriginal Australians correctly noticed long ago that it magically faded and brightened, weaving it into their oral traditions.",
            realityParagraph: "It is a dying, unstable monster so large that if put in our solar system, it would swallow everything up to Jupiter. Its surface isn't solid, but a boiling, bubbling cauldron of plasma ready to erupt in a spectacular supernova."
        )
    ]
}
