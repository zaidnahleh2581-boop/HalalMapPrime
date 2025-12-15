//
//  PlaceCardView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-15.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct PlaceCardView: View {

    @EnvironmentObject var lang: LanguageManager
    let place: Place

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    private var categoryTitle: String {
        // نعرض أسماء واضحة بدل الإنجليزية الثابتة
        switch place.category {
        case .restaurant: return L("مطعم", "Restaurant")
        case .grocery:    return L("بقالة", "Grocery")
        case .school:     return L("مدرسة", "School")
        case .mosque:     return L("مسجد", "Mosque")
        case .service:    return L("خدمات", "Services")
        case .foodTruck:  return L("فود ترك", "Food Truck")
        case .market:     return L("سوق", "Market")
        case .shop:       return L("محل", "Shop")
        case .center:     return L("مركز", "Center")
        case .funeral:    return L("مغسلة/دفن", "Funeral")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Placeholder image area (جاهز للصور لاحقاً)
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(place.category.mapColor.opacity(0.22))

                VStack(alignment: .leading, spacing: 6) {

                    HStack(spacing: 8) {
                        Text(place.category.emoji)
                            .font(.title2)

                        Text(categoryTitle)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                            .lineLimit(1)

                        Spacer()

                        if place.isCertified {
                            Text(L("حلال ✅", "Halal ✅"))
                                .font(.caption2.weight(.bold))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.green.opacity(0.18))
                                .clipShape(Capsule())
                        }
                    }

                    Text(place.name)
                        .font(.headline)
                        .lineLimit(2)

                    // Rating
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)

                        Text(String(format: "%.1f", place.rating))
                            .font(.caption.weight(.semibold))

                        Text(L("تقييمات", "reviews"))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("(\(place.reviewCount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
            }
            .frame(height: 150)

            // Address
            Text(place.address.isEmpty ? place.cityState : place.address)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            // Tags
            HStack(spacing: 8) {
                TagPill(text: place.cityState.isEmpty ? L("بالقرب منك", "Nearby") : place.cityState)

                if place.deliveryAvailable {
                    TagPill(text: L("توصيل", "Delivery"))
                }

                Spacer()
            }

            // Footer tiny brand label
            Text(L("برايم • حلال", "Prime • Halal"))
                .font(.caption2)
                .foregroundColor(Color(red: 0.0, green: 0.55, blue: 0.45))
        }
        .padding(12)
        .frame(width: 260, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Small tag pill

private struct TagPill: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
            .foregroundColor(.secondary)
    }
}
