private var totalPowerDraw: Double {
    let cameraDraw = cameraBrands[safeBrand].models[safeModel].powerDraw
    let accessoriesDraw = currentAccessories.reduce(0.0) { total, index in
        guard index < accessories.count else { return total }
        let accessory = accessories[index]
        // Apply multiplier only to focus systems
        if accessory.category == .focus {
            return total + (accessory.powerDraw * Double(focusSystemMultiplier))
        } else {
            return total + accessory.powerDraw
        }
    }
    return cameraDraw + accessoriesDraw
}

// In the AccessoriesSection view
if selectedAccessories.wrappedValue.contains { index in
    accessories[index].category == .focus
} {
    VStack(spacing: 8) {
        // ... rest of the focus system multiplier UI ...
    }
} 