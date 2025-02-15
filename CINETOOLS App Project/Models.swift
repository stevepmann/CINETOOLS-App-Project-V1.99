import Foundation

// Camera Models for Battery Calculator
struct Camera {
    let model: String
    let powerDraw: Double // in watts
}

struct CameraBrand {
    let name: String
    let models: [Camera]
}

// Camera Models for Data Calculator
struct CameraData {
    let name: String
    let models: [CameraModel]
}

struct CameraModel {
    let name: String
    let powerDraw: Double
    let codecs: [CodecData]
}

struct CodecData {
    let name: String
    let bitrate: Double // in Mbps
}

// Accessory Models
enum AccessoryCategory: String, CaseIterable {
    case monitor = "Monitors"
    case wireless = "Wireless Video"
    case focus = "Focus Systems"
    case audio = "Audio"
}

struct Accessory {
    let name: String
    let powerDraw: Double // in watts
    let category: AccessoryCategory
}

// Battery Models
struct Battery {
    let model: String
    let wattHours: Double // in Wh
    let voltage: Double // in volts
}

// Drive Models for Data Transfer
struct DriveSpeed {
    let name: String
    let readSpeedMbps: Double
    let writeSpeedMbps: Double
    let type: String
}

struct TransferSpeed {
    let name: String
    let speedMbps: Double
} 
