//
//  PlaceDetailsSheet.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import MapKit

struct PlaceDetailsSheet: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    let place: Place

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {

                // Title + Emoji
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(place.name)
                            .font(.title2.bold())

                        Text(place.formattedAddress)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(place.category.emoji)
                        .font(.title2)
                }

                // ⭐️ Stars + Rating text
                HStack(spacing: 10) {
                    StarRatingView(rating: place.rating)
                    Text(String(format: "%.1f", place.rating))
                        .font(.subheadline.bold())

                    Text("•")

                    Text(L("\(place.reviewCount) تقييم", "\(place.reviewCount) reviews"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if place.isCertified {
                        Label(L("موثّق", "Certified"), systemImage: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .padding(.leading, 6)
                    }
                }

                // Extra tags
                HStack(spacing: 10) {
                    if place.deliveryAvailable {
                        Label(L("توصيل", "Delivery"), systemImage: "bicycle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Label(place.cityState, systemImage: "building.2")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Actions
                VStack(spacing: 10) {

                    Button {
                        openDirections()
                    } label: {
                        Label(L("الاتجاهات", "Directions"), systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    // يظهر فقط إذا الرقم فعلاً رقم
                    if let phone = place.phoneNumber,
                       isValidPhone(phone) {
                        Button {
                            call(phone)
                        } label: {
                            Label(L("اتصال", "Call"), systemImage: "phone.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

                    if let website = place.website,
                       let url = URL(string: website) {
                        Button {
                            UIApplication.shared.open(url)
                        } label: {
                            Label(L("الموقع", "Website"), systemImage: "safari.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle(L("تفاصيل", "Details"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L("تم", "Done")) { dismiss() }
                }
            }
        }
    }

    // MARK: - Helpers

    private func openDirections() {
        let item = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate))
        item.name = place.name
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    private func call(_ phone: String) {
        let digits = phone.filter { "0123456789+".contains($0) }
        guard let url = URL(string: "tel://\(digits)"),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    private func isValidPhone(_ phone: String) -> Bool {
        let digits = phone.filter { "0123456789".contains($0) }
        return digits.count >= 10 && digits.count <= 15
    }
}

// MARK: - Stars View
private struct StarRatingView: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: starName(for: i))
                    .font(.subheadline)
            }
        }
        .accessibilityLabel("Rating \(rating)")
    }

    private func starName(for index: Int) -> String {
        let value = rating - Double(index - 1)
        if value >= 0.75 { return "star.fill" }
        if value >= 0.25 { return "star.leadinghalf.filled" }
        return "star"
    }
}
