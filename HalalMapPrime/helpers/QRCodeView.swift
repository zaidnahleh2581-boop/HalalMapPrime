import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit

struct QRCodeView: View {
    let urlString: String
    
    var body: some View {
        if let image = generateQRCode(from: urlString) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Text("QR Error")
                .foregroundColor(.red)
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        guard let outputImage = filter.outputImage else {
            return nil
        }
        
        // تكبير الكود عشان يكون واضح للطباعة
        let scaled = outputImage.transformed(
            by: CGAffineTransform(scaleX: 10, y: 10)
        )
        
        guard let cgimg = context.createCGImage(scaled, from: scaled.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgimg)
    }
}
