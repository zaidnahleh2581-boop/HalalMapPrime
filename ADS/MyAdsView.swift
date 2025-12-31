//
//  MyAdsView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by Zaid Nahleh on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct MyAdsView: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var store = MyPlacesStore()

    @State private var showDeleteConfirm = false
    @State private var pendingDeleteId: String? = nil

    @State private var showError = false
    @State private var errorText: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                if store.isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                        .padding(.top, 10)
                }

                if let err = store.errorMessage {
                    errorCard(err)
                }

                listSection
            }
            .padding()
        }
        .navigationTitle(L("إعلاناتي / أماكني", "My Ads / My Places"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.startListeningMyPlaces() }
        .onDisappear { store.stopListening() }
        .alert(L("حذف", "Delete"), isPresented: $showDeleteConfirm) {
            Button(L("إلغاء", "Cancel"), role: .cancel) { pendingDeleteId = nil }
            Button(L("حذف نهائي", "Delete"), role: .destructive) {
                guard let id = pendingDeleteId else { return }
                Task {
                    do {
                        try await store.deletePlace(docId: id)
                    } catch {
                        errorText = error.localizedDescription
                        showError = true
                    }
                    pendingDeleteId = nil
                }
            }
        } message: {
            Text(L("هل أنت متأكد أنك تريد حذف هذا الإدراج؟", "Are you sure you want to delete this submission?"))
        }
        .alert(L("خطأ", "Error"), isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorText)
        }
    }

    // MARK: - List

    private var listSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(L("قائمة إدراجاتي", "My submissions"))
                .font(.headline)

            if store.items.isEmpty && !store.isLoading {
                emptyState
            } else {
                ForEach(store.items) { item in
                    row(item)
                }
            }
        }
    }

    private func row(_ item: MyPlacesStore.MyPlaceRow) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.placeName)
                        .font(.headline)

                    Text("\(prettyType(item.placeType)) • \(item.city), \(item.state)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                statusBadge(item.status)
            }

            if let dt = item.createdAt {
                Text(L("تاريخ الإرسال:", "Submitted:")
                     + " "
                     + formatDate(dt))
                .font(.footnote)
                .foregroundColor(.secondary)
            }

            HStack {
                Button(role: .destructive) {
                    pendingDeleteId = item.id
                    showDeleteConfirm = true
                } label: {
                    Label(L("حذف", "Delete"), systemImage: "trash")
                }
                .font(.footnote)

                Spacer()

                Text("#\(item.id.prefix(6))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - UI Helpers

    private func statusBadge(_ status: String) -> some View {
        let (text, color) = statusStyle(status)
        return Text(text)
            .font(.caption.weight(.semibold))
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    private func statusStyle(_ status: String) -> (String, Color) {
        let s = status.lowercased()
        if s == "active" { return (L("نشط", "Active"), .green) }
        if s == "rejected" { return (L("مرفوض", "Rejected"), .red) }
        if s == "expired" { return (L("منتهي", "Expired"), .gray) }
        if s == "deleted" { return (L("محذوف", "Deleted"), .gray) }
        return (L("قيد المراجعة", "Pending"), .orange)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 34))
                .foregroundColor(.secondary)

            Text(L("لا يوجد إدراجات بعد", "No submissions yet"))
                .font(.headline)

            Text(L("أضف مكانك المجاني من أعلى صفحة الإعلانات.", "Add your free place from the top Ads tab."))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 2)
        )
    }

    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("مشكلة", "Issue"))
                .font(.footnote.weight(.semibold))
            Text(message)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.red.opacity(0.10)))
    }

    private func prettyType(_ raw: String) -> String {
        switch raw.lowercased() {
        case "restaurant": return L("مطعم", "Restaurant")
        case "grocery": return L("بقالة / سوبرماركت", "Grocery / Market")
        case "mosque": return L("مسجد", "Mosque")
        case "school": return L("مدرسة / تعليم", "School / Education")
        case "shop": return L("متجر", "Shop")
        case "service": return L("خدمة", "Service")
        case "foodtruck", "food_truck": return L("فود ترك", "Food Truck")
        default: return raw
        }
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }
}
