//
//  Helpers.swift
//  PlantDiseaseDetector
//
//  Created by Chairal Octavyanz on 10/06/25.
//

import PhotosUI

func saveImageToDisk(image: UIImage) -> String {
    let filename = UUID().uuidString + ".jpg"
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
    if let data = image.jpegData(compressionQuality: 0.8) {
        try? data.write(to: url)
        return filename
    }
    return ""
}

func loadImageFromDisk(named: String) -> UIImage {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(named)
    return UIImage(contentsOfFile: url.path) ?? UIImage()
}
