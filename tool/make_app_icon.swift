// Construit l'icône de l'application à partir du logo : le logo centré sur un
// fond pollen, sans transparence (iOS refuse les icônes transparentes).
// La marge autour du logo évite que les coins arrondis d'iOS coupent la
// couronne ou les pièces.
//
// Usage, depuis la racine du projet : swift tool/make_app_icon.swift
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let iconSide = 1024
let logoShare: CGFloat = 0.72
let pollen = CGColor(srgbRed: 0xE2 / 255, green: 0xF2 / 255, blue: 0x4B / 255, alpha: 1)

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let logoURL = root.appendingPathComponent("assets/icon/pecule_logo.png")
let iconURL = root.appendingPathComponent("assets/icon/app_icon.png")

guard
    let source = CGImageSourceCreateWithURL(logoURL as CFURL, nil),
    let logo = CGImageSourceCreateImageAtIndex(source, 0, nil)
else {
    fatalError("Logo illisible : \(logoURL.path)")
}

guard
    let context = CGContext(
        data: nil,
        width: iconSide,
        height: iconSide,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    )
else {
    fatalError("Impossible de créer l'image de \(iconSide) pixels")
}

let side = CGFloat(iconSide)
context.setFillColor(pollen)
context.fill(CGRect(x: 0, y: 0, width: side, height: side))

context.interpolationQuality = .high
let logoSide = side * logoShare
let margin = (side - logoSide) / 2
context.draw(logo, in: CGRect(x: margin, y: margin, width: logoSide, height: logoSide))

guard
    let icon = context.makeImage(),
    let destination = CGImageDestinationCreateWithURL(
        iconURL as CFURL,
        UTType.png.identifier as CFString,
        1,
        nil
    )
else {
    fatalError("Impossible d'écrire \(iconURL.path)")
}
CGImageDestinationAddImage(destination, icon, nil)
guard CGImageDestinationFinalize(destination) else {
    fatalError("Impossible d'écrire \(iconURL.path)")
}
print("Icône écrite : \(iconURL.path)")
