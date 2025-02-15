import SwiftUI
import PDFKit
import UIKit

class PDFGenerator {
    static let shared = PDFGenerator()
    
    // Common styling
    private let brandColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    private let logoImage = UIImage(named: "-headerlogo-")
    
    struct BatteryReport {
        let camera: String
        let model: String
        let powerDraw: Double
        let accessories: [(name: String, powerDraw: Double)]
        let battery: String
        let batteryQuantity: Int
        let totalPowerDraw: Double
        let runtime: Double
        let date: Date
    }
    
    struct DataReport {
        let cameras: [(name: String, brand: String, model: String, codec: String, storage: Double)]
        let recordingHours: Double
        let totalStorage: Double
        let date: Date
    }
    
    func generateBatteryReport(data: BatteryReport) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "CINETOOLS",
            kCGPDFContextAuthor: "CINETOOLS Battery Calculator"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            let ctx = context.cgContext
            
            // Draw header
            drawHeader(in: ctx, pageRect: pageRect, title: "Battery Runtime Report")
            
            // Draw content
            var yPosition: CGFloat = 200
            
            // Camera Setup Section
            drawSectionTitle("Camera Setup", at: &yPosition)
            drawInfoLine("Camera Brand:", data.camera, at: &yPosition)
            drawInfoLine("Camera Model:", data.model, at: &yPosition)
            drawInfoLine("Power Draw:", String(format: "%.1fW", data.powerDraw), at: &yPosition)
            
            // Accessories Section
            if !data.accessories.isEmpty {
                yPosition += 20
                drawSectionTitle("Accessories", at: &yPosition)
                for accessory in data.accessories {
                    drawInfoLine(accessory.name + ":", String(format: "%.1fW", accessory.powerDraw), at: &yPosition)
                }
            }
            
            // Battery Section
            yPosition += 20
            drawSectionTitle("Battery Configuration", at: &yPosition)
            drawInfoLine("Battery Type:", data.battery, at: &yPosition)
            drawInfoLine("Quantity:", "\(data.batteryQuantity)", at: &yPosition)
            
            // Results Section
            yPosition += 20
            drawSectionTitle("Results", at: &yPosition)
            drawInfoLine("Total Power Draw:", String(format: "%.1fW", data.totalPowerDraw), at: &yPosition)
            drawInfoLine("Estimated Runtime:", String(format: "%.1f hours (%.0f minutes)", data.runtime, data.runtime * 60), at: &yPosition)
            
            // Draw footer
            drawFooter(in: ctx, pageRect: pageRect, date: data.date)
        }
        
        return data
    }
    
    func generateDataReport(data: DataReport) -> Data? {
        // Similar implementation for data calculator report
        // ... implementation details ...
        return nil
    }
    
    private func drawHeader(in context: CGContext, pageRect: CGRect, title: String) {
        // Draw logo
        if let logo = logoImage {
            let logoRect = CGRect(x: 36, y: 36, width: 200, height: 60)
            logo.draw(in: logoRect)
        }
        
        // Draw title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: brandColor
        ]
        
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(
            x: (pageRect.width - titleSize.width) / 2,
            y: 120,
            width: titleSize.width,
            height: titleSize.height
        )
        
        title.draw(in: titleRect, withAttributes: titleAttributes)
    }
    
    private func drawSectionTitle(_ title: String, at yPosition: inout CGFloat) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: brandColor
        ]
        
        title.draw(at: CGPoint(x: 36, y: yPosition), withAttributes: attributes)
        yPosition += 24
    }
    
    private func drawInfoLine(_ label: String, _ value: String, at yPosition: inout CGFloat) {
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.darkGray
        ]
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.black
        ]
        
        label.draw(at: CGPoint(x: 36, y: yPosition), withAttributes: labelAttributes)
        value.draw(at: CGPoint(x: 200, y: yPosition), withAttributes: valueAttributes)
        yPosition += 20
    }
    
    private func drawFooter(in context: CGContext, pageRect: CGRect, date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        let footerText = "Generated by CINETOOLS on \(dateFormatter.string(from: date))"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]
        
        let size = footerText.size(withAttributes: attributes)
        let rect = CGRect(
            x: (pageRect.width - size.width) / 2,
            y: pageRect.height - 50,
            width: size.width,
            height: size.height
        )
        
        footerText.draw(in: rect, withAttributes: attributes)
    }
} 