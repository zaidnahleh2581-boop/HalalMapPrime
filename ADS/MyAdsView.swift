//
//  MyAdsView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by Zaid Nahleh on 2025-12-30.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct MyAdsView: View {

    @EnvironmentObject var lang: LanguageManager

    @StateObject private var store = MyPlacesStore()

    @State private var showAddPlaceForm = false
    @State private var preset: AddHalalPlaceFormView.Preset = .normal

    @State private var showDeleteConfirm = false
    @State private var pendingDeleteId: String? = nil

    @State private var showError = false
    @State private var errorText: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                privacyNote

                quickActions

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
        .sheet(isPresented: $showAddPlaceForm) {
            NavigationStack {
                AddHalalPlaceFormView(preset: preset)
                    .environmentObject(lang)
            }
        }
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

    // MARK: - Sections

    private var privacyNote: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("ملاحظة الخصوصية", "Privacy note"))
                .font(.footnote.weight(.semibold))

            Text(L(
                "بياناتك لا تُباع. يتم حفظ الإدراجات للمراجعة (Pending) وقد تظهر لاحقًا عند الموافقة.",
                "Your data is not sold. Submissions are saved as Pending and may appear after review."
            ))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(L("إضافة جديدة", "Add new"))
                .font(.headline)

            HStack(spacing: 10) {

                smallAction(
                    title: L("أضف محلك الحلال", "Add Halal Place"),
                    icon: "plus.circle.fill",
                    tint: .green
                ) {
                    preset = .halalPlace
                    showAddPlaceForm = true
                }

                smallAction(
                    title: L("أضف فود ترك", "Add Food Truck"),
                    icon: "truck.box.fill",
                    tint: .orange
                ) {
                    preset = .foodTruck
                    showAddPlaceForm = true
                }
            }

            bigAction(
                title: L("إضافة مكان (مجاني)", "Add place (Free)"),
                systemImage: "mappin.and.ellipse",
                tint: .blue
            ) {
                preset = .normal
                showAddPlaceForm = true
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }

    private var listSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(L("قائمة إدراجاتي", "My submissions"))
                .font(.headline)
                .padding(.top, 6)

            if store.items.isEmpty && !store.isLoading {
                emptyState
            } else {
                ForEach(store.items) { item in
                    row(item)
                }
            }
        }
    }

    // MARK: - Row

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

            Text(L("اضغط إضافة مكان لبدء أول إدراج لك.", "Tap Add place to create your first submission."))
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

    private func smallAction(title: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title).font(.footnote.weight(.semibold))
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(tint.opacity(0.15))
            .foregroundColor(tint)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func bigAction(title: String, systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage).foregroundColor(.white)
                Text(title).font(.headline).foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(tint.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
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
