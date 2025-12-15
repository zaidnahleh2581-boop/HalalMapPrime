import SwiftUI

struct MoreCategoriesSheet: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    let excluded: [PlaceCategory]
    let onSelect: (PlaceCategory) -> Void

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    private func localizedCategoryName(_ cat: PlaceCategory) -> String {
        switch cat {
        case .restaurant: return L("مطاعم", "Restaurants")
        case .foodTruck:  return L("فود ترك", "Food Trucks")
        case .mosque:     return L("مساجد", "Mosques")
        case .school:     return L("مدارس", "Schools")
        case .grocery:    return L("بقالات", "Groceries")
        case .market:     return L("أسواق", "Markets")
        case .shop:       return L("محلات", "Shops")
        case .service:    return L("خدمات", "Services")
        case .center:     return L("مراكز", "Centers")
        case .funeral:    return L("مغاسل/دفن", "Funeral")
        }
    }

    private var categories: [PlaceCategory] {
        PlaceCategory.allCases.filter { !excluded.contains($0) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { cat in
                    Button {
                        onSelect(cat)
                    } label: {
                        HStack(spacing: 10) {
                            Text(cat.emoji)
                            Text(localizedCategoryName(cat))
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(L("كل التصنيفات", "All categories"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("إغلاق", "Close")) {
                        dismiss()
                    }
                }
            }
        }
    }
}
