import SwiftUI

struct AddStoreCategorySection: View {
    @Binding var category: AddPlaceCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(AddPlaceCategory.allCases) { cat in
                        HStack(spacing: 6) {
                            Image(systemName: cat.iconName)
                            Text(cat.rawValue)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(category == cat ? Color.blue.opacity(0.2) : Color(.systemGray6))
                        .foregroundColor(category == cat ? .blue : .primary)
                        .cornerRadius(20)
                        .onTapGesture {
                            category = cat
                        }
                    }
                }
            }
        }
    }
}
