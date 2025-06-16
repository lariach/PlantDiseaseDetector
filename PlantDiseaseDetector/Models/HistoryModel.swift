//
//  HistoryModel.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 16/06/25.
//

import Foundation
import SwiftData

struct History: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let date: Date
    let disease1: String
    let disease2: String
    let disease3: String
}

// Helper untuk membuat Date dari String
func dateFrom(_ string: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd, yyyy 'at' h:mm a"
    formatter.locale = Locale(identifier: "en_US_POSIX") // penting untuk parsing waktu dalam format Inggris
    return formatter.date(from: string) ?? Date() // fallback ke Date() jika parsing gagal
}

// Dummy data
let historyList: [History] = [
    History(
        name: "History 1",
        image: "image-howto",
        date: dateFrom("Jun 16, 2025 at 1:42 AM"),
        disease1: "rust",
        disease2: "powdery",
        disease3: "sunburn"
    ),
    
    History(
        name: "History 2",
        image: "image-howto",
        date: dateFrom("Jun 16, 2025 at 1:42 AM"),
        disease1: "rust",
        disease2: "powdery",
        disease3: "sunburn"
    )
]

