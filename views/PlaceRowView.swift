import SwiftUI

struct PlaceRowView: View {
    let place: Place
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(place.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if place.isCertified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Text(place.category.rawValue)
                    .font(.caption)
                    .padding(6)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.yellow)
            }
            
            Text("\(place.address), \(place.cityState)")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(spacing: 4) {
                ForEach(0..<5) { index in
                    Image(systemName: index < Int(round(place.rating)) ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                }
                
                Text(String(format: "%.1f", place.rating))
                    .font(.caption2)
                    .foregroundColor(.yellow)
                
                Text("(\(place.reviewCount))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if place.deliveryAvailable {
                    Text("Delivery")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.3))
                        .cornerRadius(6)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
