//
//  PlaceDetailView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-15.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import MapKit

struct PlaceDetailView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.openURL) private var openURL

    let place: Place

    @State private var showShareSheet: Bool = false

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                // Title + badges
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 10) {
                        Text(place.name)
                            .font(.title2.bold())
                            .foregroundColor(.primary)

                        Spacer()

                        if place.isCertified {
                            Text(L("حلال ✅", "Halal ✅"))
                                .font(.caption2.bold())
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(Color.green.opacity(0.18))
                                .clipShape(Capsule())
                        }
                    }

                    // Rating line
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)

                        Text(String(format: "%.1f", place.rating))
                            .font(.caption.weight(.semibold))

                        Text("(\(place.reviewCount))")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if place.deliveryAvailable {
                            Spacer()
                            Label(L("توصيل", "Delivery"), systemImage: "bicycle")
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.green)
                        }
                    }
                }

                // Address
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.address)
                        .font(.subheadline)
                    Text(place.cityState)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }

                // Actions: Directions + Share
                HStack(spacing: 10) {
                    Button {
                        openDirections()
                    } label: {
                        Label(L("الاتجاهات", "Directions"), systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        showShareSheet = true
                    } label: {
                        Label(L("مشاركة", "Share"), systemImage: "square.and.arrow.up")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                // About
                VStack(alignment: .leading, spacing: 8) {
                    Text(L("عن هذا المكان", "About this place"))
                        .font(.headline)

                    Text(categoryDescription)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }

                // Mini Map
                Map(
                    coordinateRegion: .constant(
                        MKCoordinateRegion(
                            center: place.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    ),
                    annotationItems: [place]
                ) { p in
                    MapMarker(coordinate: p.coordinate, tint: .red)
                }
                .frame(height: 200)
                .cornerRadius(14)
            }
            .padding()
        }
        .navigationTitle(L("التفاصيل", "Details"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
    }

    // MARK: - Share content

    private var shareItems: [Any] {
        let text = """
        \(place.name)
        \(place.address), \(place.cityState)
        """

        // Apple Maps URL
        let urlString = "https://maps.apple.com/?q=\(urlEncoded(place.name))&ll=\(place.latitude),\(place.longitude)"
        if let url = URL(string: urlString) {
            return [text, url]
        } else {
            return [text]
        }
    }

    private func urlEncoded(_ s: String) -> String {
        s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s
    }

    // MARK: - Actions

    private func openDirections() {
        let name = urlEncoded(place.name)
        let urlString = "maps://?q=\(name)&ll=\(place.latitude),\(place.longitude)"
        if let url = URL(string: urlString) {
            openURL(url)
        }
    }

    private var categoryDescription: String {
        switch place.category {
        case .restaurant:
            return L("مطعم حلال. تناول داخل المطعم أو سفري أو توصيل.", "Halal restaurant. Dine-in, take-out, or delivery.")
        case .grocery:
            return L("بقالة/سوبرماركت بمنتجات حلال وملائمة للمسلمين.", "Grocery / supermarket offering halal-friendly products.")
        case .school:
            return L("مدرسة إسلامية أو برنامج تعليمي للمجتمع.", "Islamic school or community education program.")
        case .mosque:
            return L("مسجد للصلاة والجمعة والفعاليات المجتمعية.", "Mosque / masjid for prayers, Jumu’ah and community events.")
        case .service:
            return L("خدمات تخدم المجتمع المسلم.", "Services that support the Muslim community.")
        case .market:
            return L("سوق/بازار يضم بائعين أو محلات حلال.", "Market / bazaar with halal vendors or stalls.")
        case .shop:
            return L("محل/متجر بمنتجات ملائمة للمسلمين.", "Shop / retail store with Muslim-friendly products.")
        default:
            return L("مكان أو خدمة حلال ضمن حلال ماب برايم.", "Halal place or service listed on Halal Map Prime.")
        }
    }
}
