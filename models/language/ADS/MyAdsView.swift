//
//  MyAdsView.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh
//  Updated by Zaid Nahleh on 12/17/25
//

import SwiftUI

struct MyAdsView: View {

    @ObservedObject private var adsStore = AdsStore.shared
    @State private var errorMessage: String?

    @State private var pendingDeleteAd: FirebaseAd? = nil
    @State private var isDeleting = false

    var body: some View {
        NavigationStack {
            List {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                if adsStore.myAds.isEmpty {
                    Text("No ads yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(adsStore.myAds) { ad in
                        row(ad)
                    }
                    .onDelete(perform: askDeleteAt)
                    .disabled(isDeleting)
                }
            }
            .navigationTitle("My Ads")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditButton()
            }
            .onAppear {
                adsStore.startMyAdsListener()
            }
            .alert("Delete Ad?", isPresented: Binding(
                get: { pendingDeleteAd != nil },
                set: { if !$0 { pendingDeleteAd = nil } }
            )) {
                Button("Cancel", role: .cancel) {
                    pendingDeleteAd = nil
                }
                Button("Delete", role: .destructive) {
                    if let ad = pendingDeleteAd {
                        delete(ad)
                    }
                }
            } message: {
                Text("This will permanently delete the ad from Firebase.")
            }
        }
    }

    // MARK: - UI

    private func row(_ ad: FirebaseAd) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(ad.businessName.isEmpty ? "Business" : ad.businessName)
                .font(.headline)

            Text(ad.phone)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("\(ad.city), \(ad.state)")
                .font(.footnote)
                .foregroundColor(.secondary)

            Text(ad.isActive ? "ACTIVE" : "INACTIVE")
                .font(.caption)
                .foregroundColor(ad.isActive ? .green : .gray)
        }
        .padding(.vertical, 6)
    }

    // MARK: - Delete

    private func askDeleteAt(_ indexSet: IndexSet) {
        guard let idx = indexSet.first else { return }
        pendingDeleteAd = adsStore.myAds[idx]
        errorMessage = nil
    }

    private func delete(_ ad: FirebaseAd) {
        errorMessage = nil
        isDeleting = true

        Task {
            do {
                try await adsStore.deleteAd(adId: ad.id)

                await MainActor.run {
                    isDeleting = false
                    pendingDeleteAd = nil
                }
            } catch {
                await MainActor.run {
                    isDeleting = false
                    pendingDeleteAd = nil
                    errorMessage = "Delete failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
