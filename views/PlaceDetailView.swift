import SwiftUI
import MapKit

struct PlaceDetailView: View {
    let place: Place
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // الاسم
                Text(place.name)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                // العنوان
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.address)
                    Text(place.cityState)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                
                // معلومات عامة (التقييم – التوصيل – الشهادة)
                HStack(spacing: 12) {
                    Label("\(String(format: "%.1f", place.rating)) ⭐️", systemImage: "star.fill")
                    
                    Label("\(place.reviewCount) reviews",
                          systemImage: "person.3.fill")
                    
                    if place.deliveryAvailable {
                        Label("Delivery", systemImage: "bicycle")
                    }
                    
                    if place.isCertified {
                        Label("Certified", systemImage: "checkmark.seal.fill")
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                
                // وصف حسب الـ Category
                VStack(alignment: .leading, spacing: 8) {
                    Text("About this place")
                        .font(.headline)
                    
                    Text(categoryDescription)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                
                // خريطة صغيرة للمكان (اختياري)
                Map(coordinateRegion: .constant(
                    MKCoordinateRegion(
                        center: place.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                ),
                    annotationItems: [place]
                ) { place in
                    MapMarker(coordinate: place.coordinate, tint: .red)
                }
                .frame(height: 200)
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// نص الوصف حسب نوع المكان
    private var categoryDescription: String {
        switch place.category {
        case .restaurant:
            return "Halal restaurant. Dine-in, take-out, or delivery available."
            
        case .grocery:
            return "Grocery / supermarket offering halal and Muslim-friendly products."
            
        case .school:
            return "Islamic school or weekend program for kids and youth."
            
        case .mosque:
            return "Mosque / masjid for daily prayers, Jumu’ah, and community events."
            
        case .service:
            return "Halal-friendly services for the Muslim community."
            
        case .market:
            return "Market / bazaar with multiple halal vendors or stalls."
            
        case .shop:
            return "Halal shop / retail store with Muslim-friendly products."
            
            // أي نوع ثاني (Food Truck، أو غيره) يطيح هنا
        default:
            return "Halal place or service listed on Halal Map Prime."
        }
    }
}
