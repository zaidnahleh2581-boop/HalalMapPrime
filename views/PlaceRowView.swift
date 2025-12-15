//
//  PlaceRowView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-15.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct PlaceRowView: View {
    let place: Place

    var body: some View {
        HStack(spacing: 12) {

            // Emoji + small dot
            VStack(spacing: 6) {
                Text(place.category.emoji)
                    .font(.title3)
                Circle()
                    .fill(place.category.mapColor)
                    .frame(width: 8, height: 8)
            }
            .frame(width: 34)

            VStack(alignment: .leading, spacing: 6) {

                HStack {
                    Text(place.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if place.isCertified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                    }

                    Spacer()

                    Text(place.category.displayName)
                        .font(.caption2.weight(.semibold))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                        .foregroundColor(.secondary)
                }

                Text("\(place.address), \(place.cityState)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)

                    Text(String(format: "%.1f", place.rating))
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.primary)

                    Text("(\(place.reviewCount))")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    if place.deliveryAvailable {
                        Text("Delivery")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.16))
                            .clipShape(Capsule())
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
