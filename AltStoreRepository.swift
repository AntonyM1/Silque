//
//  AltStoreRepository.swift
//  Silque
//
//  Created by Antony Marcelino on 26/05/2025.
//


import Foundation

struct AltStoreRepository: Codable {
    let name: String
    let apps: [AltStoreApp]
}

struct AltStoreApp: Codable, Identifiable {
    var id: String { bundleIdentifier }
    let name: String
    let iconURL: String
    let bundleIdentifier: String
    let versions: [AltStoreAppVersion]
}

struct AltStoreAppVersion: Codable {
    let version: String
    let date: String?
    let url: String
    let localizedDescription: [String: String]?
}
