//
//  LibraryModel.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 15/06/25.
//

import Foundation
import SwiftData

struct Disease: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let overview: String
    let symptoms: String
    let causes: String
    let treatments: String
}

let diseaseList: [Disease] = [
    Disease(
        name: "Rust",
        imageName: "image-rust",
        overview: "A fungal disease that primarily affects leaves, forming characteristic rust-colored pustules.",
        symptoms: "Tiny, powdery orange, yellow, or brown spots that often appear in clusters on the underside of leaves. Infected leaves may curl, distort, and fall off prematurely. In advanced stages, plants look thin and stressed.",
        causes: "Caused by rust fungi such as Puccinia and Uromyces. Spores spread via wind and water. Infection is favored by damp environments with warm days and cool nights.",
        treatments: """
        • Cultural: Prune affected areas; reduce humidity; water at the soil level.
        • Chemical: Apply fungicides containing mancozeb or chlorothalonil.
        • Organic: Use sulfur dust, neem oil, or baking soda sprays.
        """
    ),
    
    Disease(
        name: "Aphid",
        imageName: "image-aphid",
        overview: "Small, soft-bodied insects that feed on plant sap and reproduce rapidly, often forming dense colonies.",
        symptoms: "New growth becomes twisted, curled, or stunted. Sticky “honeydew” excreted by aphids can attract ants and lead to black sooty mold. You may also see clusters of green, black, or white aphids on stems and leaves.",
        causes: "Attracted to nitrogen-rich, succulent growth, especially in weak or stressed plants. Spread between plants by wind, ants, or human activity.",
        treatments: """
        • Cultural: Blast off with water; cut back heavily infested parts; attract beneficial insects.
        • Chemical: Use insecticidal soaps or horticultural oil; avoid broad-spectrum pesticides that harm beneficial insects.
        • Organic: Spray with neem oil, garlic or chili extract; introduce predators like ladybugs or lacewings.
        """
    ),
    
    Disease(
        name: "Sunburn",
        imageName: "image-sunburn",
        overview: "A non-infectious condition caused by too much direct sun, especially on tender or unacclimated plant parts.",
        symptoms: "Pale white, bleached, or tan patches appear on upper leaf surfaces and fruits. The tissue may become dry, brittle, or necrotic. In fruits like tomatoes and peppers, it causes leathery, sunken patches.",
        causes: "Happens when plants are exposed to intense sunlight without proper acclimatization—common after transplanting, heavy pruning, or sudden weather changes.",
        treatments: """
        • Cultural: Use shade covers or companion planting to provide protection.
        • Preventive: Acclimate seedlings slowly to outdoor conditions (“hardening off”); avoid pruning that overexposes inner leaves.
        """
    ),
    
    Disease(
        name: "Downy Mildew",
        imageName: "image-downeymildew",
        overview: "A water mold (oomycete) disease that affects leaves and sometimes stems, particularly in cool, humid environments.",
        symptoms: "Yellow or light green angular spots between veins on the upper leaf surface, which later turn brown. A fuzzy, grayish or purplish mold develops on the undersides. Infected leaves may curl or die.",
        causes: "Caused by oomycetes like Plasmopara and Peronospora. Spreads rapidly in wet, overcrowded conditions, especially when leaves stay wet overnight.",
        treatments: """
        • Cultural: Improve drainage, space plants well, and water early in the day.
        • Chemical: Apply systemic fungicides such as fosetyl-aluminum or copper hydroxide.
        • Organic: Use neem oil, diluted hydrogen peroxide spray, or potassium bicarbonate.
        """
    ),
    
    Disease(
        name: "Leaf Spot",
        imageName: "image-leafspot",
        overview: "A group of fungal or bacterial diseases that produce spots or lesions on foliage.",
        symptoms: "Small, circular to irregularly shaped spots on leaves, typically brown, black, or yellow with defined edges. Over time, spots may merge, leading to larger dead areas. A yellow halo may surround the spots, and severe cases result in premature leaf drop.",
        causes: "Commonly caused by fungi (Cercospora, Septoria, Alternaria) or bacteria (Xanthomonas, Pseudomonas). Wet foliage, high humidity, poor air circulation, and overhead watering encourage infection and spread.",
        treatments: """
        • Cultural: Remove infected leaves; ensure proper spacing and air circulation; avoid wetting leaves when watering.
        • Chemical: Use copper-based fungicides or broad-spectrum fungicides as needed.
        • Organic: Neem oil, compost tea sprays, or baking soda solutions.
        """
    ),
    
    Disease(
        name: "Powdery Mildew",
        imageName: "image-powdery",
        overview: "A common fungal disease that forms a distinctive white powder on leaves, stems, and flowers.",
        symptoms: "White, powdery or chalky spots that usually start on upper leaf surfaces and spread quickly. Leaves may curl, yellow, or die. Flowers and fruit can also become distorted or fail to develop properly.",
        causes: "Caused by fungi like Erysiphe, Podosphaera, and others. Prefers warm days and cool nights with low air movement, especially when plants are stressed or overcrowded.",
        treatments: """
        • Cultural: Ensure good airflow; avoid overhead watering and overcrowding.
        • Chemical: Apply fungicides such as sulfur, potassium bicarbonate, or myclobutanil.
        • Organic: Use a milk spray (1:9 milk to water), neem oil, or baking soda + soap mixture (1 tbsp baking soda + 1 tsp dish soap in 1 gallon water).        
        """
    )
]
