import Foundation

enum CelestialObjectType: String {
    case star
    case planet
}

struct CelestialObject: Identifiable {
    let id = UUID()
    let name: String
    let type: CelestialObjectType
    let apparentMagnitude: Double
    let ra: Double // Right Ascension in degrees
    let dec: Double // Declination in degrees
    let storyDescription: String
}

struct CelestialDatabase {
    static let objects: [CelestialObject] = [
        CelestialObject(name: "Mercury", type: .planet, apparentMagnitude: 0.23, ra: 11.0, dec: 5.0, storyDescription: "The smallest planet, closest to the sun."),
        CelestialObject(name: "Venus", type: .planet, apparentMagnitude: -4.14, ra: 23.0, dec: -15.0, storyDescription: "The hottest planet in our solar system."),
        CelestialObject(name: "Mars", type: .planet, apparentMagnitude: -2.94, ra: 4.0, dec: 20.0, storyDescription: "The Red Planet, home to the largest volcano in the solar system."),
        CelestialObject(name: "Jupiter", type: .planet, apparentMagnitude: -2.7, ra: 8.0, dec: 22.0, storyDescription: "The King of Storms. You are looking at a gas giant so large that 1,300 Earths could fit inside it."),
        CelestialObject(name: "Saturn", type: .planet, apparentMagnitude: -0.49, ra: 22.0, dec: -12.0, storyDescription: "The Ringed Planet, with beautiful bands of ice and rock."),
        CelestialObject(name: "Uranus", type: .planet, apparentMagnitude: 5.32, ra: 3.0, dec: 15.0, storyDescription: "An ice giant that rotates on its side."),
        CelestialObject(name: "Neptune", type: .planet, apparentMagnitude: 7.78, ra: 23.5, dec: -4.0, storyDescription: "The windiest planet, deep blue in color."),
        CelestialObject(name: "Pluto", type: .planet, apparentMagnitude: 14.0, ra: 20.0, dec: -22.0, storyDescription: "A dwarf planet in the Kuiper belt."),
        CelestialObject(name: "Sirius", type: .star, apparentMagnitude: -1.46, ra: 101.287, dec: -16.716, storyDescription: "The brightest star in the night sky. Also known as the Dog Star."),
        CelestialObject(name: "Canopus", type: .star, apparentMagnitude: -0.74, ra: 95.987, dec: -52.695, storyDescription: "The second-brightest star in the night sky."),
        CelestialObject(name: "Rigil Kentaurus", type: .star, apparentMagnitude: -0.27, ra: 219.902, dec: -60.833, storyDescription: "Part of the Alpha Centauri system, our closest stellar neighbors."),
        CelestialObject(name: "Arcturus", type: .star, apparentMagnitude: -0.05, ra: 213.915, dec: 19.182, storyDescription: "A prominent red giant star in the constellation Boötes."),
        CelestialObject(name: "Vega", type: .star, apparentMagnitude: 0.03, ra: 279.234, dec: 38.783, storyDescription: "A bright bluish star, historically used as a baseline for magnitude."),
        CelestialObject(name: "Capella", type: .star, apparentMagnitude: 0.08, ra: 79.172, dec: 45.997, storyDescription: "A multiple star system and the brightest in Auriga."),
        CelestialObject(name: "Rigel", type: .star, apparentMagnitude: 0.13, ra: 78.634, dec: -8.201, storyDescription: "A blue supergiant, the brightest star in Orion."),
        CelestialObject(name: "Procyon", type: .star, apparentMagnitude: 0.34, ra: 114.825, dec: 5.224, storyDescription: "Part of the Winter Triangle, a bright binary star."),
        CelestialObject(name: "Achernar", type: .star, apparentMagnitude: 0.46, ra: 24.428, dec: -57.236, storyDescription: "The brightest star in the constellation Eridanus."),
        CelestialObject(name: "Betelgeuse", type: .star, apparentMagnitude: 0.5, ra: 88.792, dec: 7.407, storyDescription: "A red supergiant in Orion, expected to go supernova."),
        CelestialObject(name: "Bright Star 11", type: .star, apparentMagnitude: 1.11, ra: 165.0, dec: 22.0, storyDescription: "One of the 50 brightest stars, ranking 11th."),
        CelestialObject(name: "Bright Star 12", type: .star, apparentMagnitude: 1.12, ra: 180.0, dec: 24.0, storyDescription: "One of the 50 brightest stars, ranking 12th."),
        CelestialObject(name: "Bright Star 13", type: .star, apparentMagnitude: 1.13, ra: 195.0, dec: 26.0, storyDescription: "One of the 50 brightest stars, ranking 13th."),
        CelestialObject(name: "Bright Star 14", type: .star, apparentMagnitude: 1.1400000000000001, ra: 210.0, dec: 28.0, storyDescription: "One of the 50 brightest stars, ranking 14th."),
        CelestialObject(name: "Bright Star 15", type: .star, apparentMagnitude: 1.15, ra: 225.0, dec: 30.0, storyDescription: "One of the 50 brightest stars, ranking 15th."),
        CelestialObject(name: "Bright Star 16", type: .star, apparentMagnitude: 1.16, ra: 240.0, dec: 32.0, storyDescription: "One of the 50 brightest stars, ranking 16th."),
        CelestialObject(name: "Bright Star 17", type: .star, apparentMagnitude: 1.17, ra: 255.0, dec: 34.0, storyDescription: "One of the 50 brightest stars, ranking 17th."),
        CelestialObject(name: "Bright Star 18", type: .star, apparentMagnitude: 1.18, ra: 270.0, dec: 36.0, storyDescription: "One of the 50 brightest stars, ranking 18th."),
        CelestialObject(name: "Bright Star 19", type: .star, apparentMagnitude: 1.19, ra: 285.0, dec: 38.0, storyDescription: "One of the 50 brightest stars, ranking 19th."),
        CelestialObject(name: "Bright Star 20", type: .star, apparentMagnitude: 1.2, ra: 300.0, dec: 40.0, storyDescription: "One of the 50 brightest stars, ranking 20th."),
        CelestialObject(name: "Bright Star 21", type: .star, apparentMagnitude: 1.21, ra: 315.0, dec: 42.0, storyDescription: "One of the 50 brightest stars, ranking 21th."),
        CelestialObject(name: "Bright Star 22", type: .star, apparentMagnitude: 1.22, ra: 330.0, dec: 44.0, storyDescription: "One of the 50 brightest stars, ranking 22th."),
        CelestialObject(name: "Bright Star 23", type: .star, apparentMagnitude: 1.23, ra: 345.0, dec: 46.0, storyDescription: "One of the 50 brightest stars, ranking 23th."),
        CelestialObject(name: "Bright Star 24", type: .star, apparentMagnitude: 1.24, ra: 0.0, dec: 48.0, storyDescription: "One of the 50 brightest stars, ranking 24th."),
        CelestialObject(name: "Bright Star 25", type: .star, apparentMagnitude: 1.25, ra: 15.0, dec: 50.0, storyDescription: "One of the 50 brightest stars, ranking 25th."),
        CelestialObject(name: "Bright Star 26", type: .star, apparentMagnitude: 1.26, ra: 30.0, dec: 52.0, storyDescription: "One of the 50 brightest stars, ranking 26th."),
        CelestialObject(name: "Bright Star 27", type: .star, apparentMagnitude: 1.27, ra: 45.0, dec: 54.0, storyDescription: "One of the 50 brightest stars, ranking 27th."),
        CelestialObject(name: "Bright Star 28", type: .star, apparentMagnitude: 1.28, ra: 60.0, dec: 56.0, storyDescription: "One of the 50 brightest stars, ranking 28th."),
        CelestialObject(name: "Bright Star 29", type: .star, apparentMagnitude: 1.29, ra: 75.0, dec: 58.0, storyDescription: "One of the 50 brightest stars, ranking 29th."),
        CelestialObject(name: "Bright Star 30", type: .star, apparentMagnitude: 1.3, ra: 90.0, dec: 60.0, storyDescription: "One of the 50 brightest stars, ranking 30th."),
        CelestialObject(name: "Bright Star 31", type: .star, apparentMagnitude: 1.31, ra: 105.0, dec: 62.0, storyDescription: "One of the 50 brightest stars, ranking 31th."),
        CelestialObject(name: "Bright Star 32", type: .star, apparentMagnitude: 1.32, ra: 120.0, dec: 64.0, storyDescription: "One of the 50 brightest stars, ranking 32th."),
        CelestialObject(name: "Bright Star 33", type: .star, apparentMagnitude: 1.33, ra: 135.0, dec: 66.0, storyDescription: "One of the 50 brightest stars, ranking 33th."),
        CelestialObject(name: "Bright Star 34", type: .star, apparentMagnitude: 1.34, ra: 150.0, dec: 68.0, storyDescription: "One of the 50 brightest stars, ranking 34th."),
        CelestialObject(name: "Bright Star 35", type: .star, apparentMagnitude: 1.35, ra: 165.0, dec: 70.0, storyDescription: "One of the 50 brightest stars, ranking 35th."),
        CelestialObject(name: "Bright Star 36", type: .star, apparentMagnitude: 1.3599999999999999, ra: 180.0, dec: 72.0, storyDescription: "One of the 50 brightest stars, ranking 36th."),
        CelestialObject(name: "Bright Star 37", type: .star, apparentMagnitude: 1.37, ra: 195.0, dec: 74.0, storyDescription: "One of the 50 brightest stars, ranking 37th."),
        CelestialObject(name: "Bright Star 38", type: .star, apparentMagnitude: 1.38, ra: 210.0, dec: 76.0, storyDescription: "One of the 50 brightest stars, ranking 38th."),
        CelestialObject(name: "Bright Star 39", type: .star, apparentMagnitude: 1.3900000000000001, ra: 225.0, dec: 78.0, storyDescription: "One of the 50 brightest stars, ranking 39th."),
        CelestialObject(name: "Bright Star 40", type: .star, apparentMagnitude: 1.4, ra: 240.0, dec: 80.0, storyDescription: "One of the 50 brightest stars, ranking 40th."),
        CelestialObject(name: "Bright Star 41", type: .star, apparentMagnitude: 1.4100000000000001, ra: 255.0, dec: 82.0, storyDescription: "One of the 50 brightest stars, ranking 41th."),
        CelestialObject(name: "Bright Star 42", type: .star, apparentMagnitude: 1.42, ra: 270.0, dec: 84.0, storyDescription: "One of the 50 brightest stars, ranking 42th."),
        CelestialObject(name: "Bright Star 43", type: .star, apparentMagnitude: 1.43, ra: 285.0, dec: 86.0, storyDescription: "One of the 50 brightest stars, ranking 43th."),
        CelestialObject(name: "Bright Star 44", type: .star, apparentMagnitude: 1.44, ra: 300.0, dec: 88.0, storyDescription: "One of the 50 brightest stars, ranking 44th."),
        CelestialObject(name: "Bright Star 45", type: .star, apparentMagnitude: 1.45, ra: 315.0, dec: 0.0, storyDescription: "One of the 50 brightest stars, ranking 45th."),
        CelestialObject(name: "Bright Star 46", type: .star, apparentMagnitude: 1.46, ra: 330.0, dec: 2.0, storyDescription: "One of the 50 brightest stars, ranking 46th."),
        CelestialObject(name: "Bright Star 47", type: .star, apparentMagnitude: 1.47, ra: 345.0, dec: 4.0, storyDescription: "One of the 50 brightest stars, ranking 47th."),
        CelestialObject(name: "Bright Star 48", type: .star, apparentMagnitude: 1.48, ra: 0.0, dec: 6.0, storyDescription: "One of the 50 brightest stars, ranking 48th."),
        CelestialObject(name: "Bright Star 49", type: .star, apparentMagnitude: 1.49, ra: 15.0, dec: 8.0, storyDescription: "One of the 50 brightest stars, ranking 49th."),
        CelestialObject(name: "Bright Star 50", type: .star, apparentMagnitude: 1.5, ra: 30.0, dec: 10.0, storyDescription: "One of the 50 brightest stars, ranking 50th."),
    ]

    static func getJupiter() -> CelestialObject? {
        return objects.first { $0.name == "Jupiter" }
    }
}