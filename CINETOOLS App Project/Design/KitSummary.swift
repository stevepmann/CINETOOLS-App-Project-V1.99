//
//  KitSummary.swift
//  CineTools — Restyle v4
//
//  Display-only summaries for a kit (Home battery card, Kit Bag cards).
//  These mirror the Battery screen's rules exactly:
//    • draw    = camera draw + Σ accessory draw (× quantity for quantity categories)
//    • runtime = (battery Wh × 0.90 × battery count) / draw
//  They never change saved data. Index lookups are guarded so stale saved indices can't crash.
//

import Foundation

enum KitSummary {

    static func camera(brand: Int, model: Int) -> Camera? {
        let brands = CameraDatabase.shared.getCameraForBatteryCalc()
        guard brands.indices.contains(brand),
              brands[brand].models.indices.contains(model)
        else { return nil }
        return brands[brand].models[model]
    }

    /// Same per-item rule as BatteryCalculatorView.totalPowerDraw
    static func drawWatts(brand: Int, model: Int,
                          accessories selected: Set<Int>,
                          quantities: [Int: Int]) -> Double? {
        guard let camera = camera(brand: brand, model: model) else { return nil }
        let accessories = CameraDatabase.shared.getAccessories()
        let accessoriesDraw = selected.reduce(0.0) { total, index in
            guard index < accessories.count else { return total }
            let accessory = accessories[index]
            if accessory.category.supportsQuantity {
                let quantity = quantities[index] ?? 1
                return total + (accessory.powerDraw * Double(quantity))
            } else {
                return total + accessory.powerDraw
            }
        }
        return camera.powerDraw + accessoriesDraw
    }

    /// Last battery used on the Battery screen (saved there)
    static var lastBattery: Battery? {
        let index = UserDefaults.standard.integer(forKey: BatteryCalculatorView.lastBatteryKey)
        let batteries = BatteryCalculatorView.batteryList
        return batteries.indices.contains(index) ? batteries[index] : nil
    }

    static var lastBatteryQuantity: Int {
        let quantity = UserDefaults.standard.integer(forKey: BatteryCalculatorView.lastBatteryQuantityKey)
        return (1...20).contains(quantity) ? quantity : 1
    }

    /// Same expression as BatteryCalculatorView.runtime (base 90% efficiency)
    static func runtimeHours(draw: Double, battery: Battery, quantity: Int) -> Double? {
        guard draw > 0 else { return nil }
        return (battery.wattHours * 0.90 * Double(quantity)) / draw
    }

    /// Accessory names, A–Z, with "×2" for quantities above 1
    static func accessoryNames(_ selected: Set<Int>, quantities: [Int: Int]) -> [String] {
        let accessories = CameraDatabase.shared.getAccessories()
        return selected
            .filter { $0 < accessories.count }
            .sorted { accessories[$0].name.localizedCaseInsensitiveCompare(accessories[$1].name) == .orderedAscending }
            .map { index in
                let quantity = quantities[index] ?? 1
                if accessories[index].category.supportsQuantity && quantity > 1 {
                    return "\(accessories[index].name) ×\(quantity)"
                }
                return accessories[index].name
            }
    }
}
