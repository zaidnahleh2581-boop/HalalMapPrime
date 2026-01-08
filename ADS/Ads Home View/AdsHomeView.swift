import SwiftUI
import UIKit

struct AdsHomeView: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var adsStore = AdsStore()

    @State private var showAddressSheet = false
    @State private var showFreeAdSheet = false
    @State private var showPaidSheet = false
    @State private var showFreeLimitAlert = false

    @State private var selectedAd: HMPAd? = nil
    @State private var showAdPreview: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {

                    topButtonsRow
                    profileCard

                    publicAdsSection   // ✅ NEW
                    myAdsSection
                    expiredSection
                }
                .padding(.top, 10)
                .padding(.bottom, 22)
            }
            .navigationTitle(L("الإعلانات", "Ads"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { adsStore.load() } // ✅ now loads public + my
        }
        .sheet(isPresented: $showPaidSheet) {
            NavigationStack {
                SelectAdPlanView()
                    .environmentObject(lang)
                    .environmentObject(adsStore)
            }
        }
        .sheet(isPresented: $showFreeAdSheet) {
            NavigationStack {
                CreateAdFormView(
                    planDisplayTitleAR: "إعلان مجاني (30 يوم)",
                    planDisplayTitleEN: "Free Ad (30 days)",
                    onSaved: { draft in
                        adsStore.createAdFromDraft(draft: draft, plan: .freeOnce)
                        adsStore.markFreeGiftUsed()
                        showFreeAdSheet = false
                    }
                )
                .environmentObject(lang)
            }
        }
        .sheet(isPresented: $showAddressSheet) {
            NavigationStack { HMPAddressSheet().environmentObject(lang) }
        }
        .sheet(isPresented: $showAdPreview) {
            if let ad = selectedAd {
                NavigationStack { AdPreviewScreen(langIsArabic: lang.isArabic, ad: ad) }
            }
        }
        .alert(L("تم استخدام الهدية المجانية", "Free gift already used"),
               isPresented: $showFreeLimitAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(L("لقد استخدمت إعلانك المجاني مرة واحدة. الآن يمكنك اختيار خطة مدفوعة.",
                   "You already used your free ad once. Please choose a paid plan."))
        }
    }

    private var topButtonsRow: some View {
        HStack(spacing: 10) {

            Button { showAddressSheet = true } label: {
                topPill(title: L("أضف عنوانك", "Add your address"),
                        systemImage: "mappin.and.ellipse",
                        tint: .blue)
            }
            .buttonStyle(.plain)

            Button {
                if adsStore.canUseFreeGift {
                    showFreeAdSheet = true
                } else {
                    showFreeLimitAlert = true
                }
            } label: {
                topPill(title: L("إعلان مجاني", "Free Ad"),
                        systemImage: "gift.fill",
                        tint: .green)
                .opacity(adsStore.canUseFreeGift ? 1 : 0.35)
            }
            .buttonStyle(.plain)

            Button { showPaidSheet = true } label: {
                topPill(title: L("مدفوع", "Paid"),
                        systemImage: "creditcard.fill",
                        tint: .orange)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 3) {
                    Text(adsStore.profileBusinessName ?? L("حساب الإعلانات", "Ads Profile"))
                        .font(.headline.weight(.bold))

                    Text(adsStore.profilePhone ?? L("أنشئ إعلان لتظهر بياناتك هنا", "Create an ad to show your info here"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    adsStore.load()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                statChip(title: L("مجتمع", "Public"), value: "\(adsStore.activePublicAds.count)", tint: .blue)
                statChip(title: L("نشط", "My Active"), value: "\(adsStore.activeMyAds.count)", tint: .green)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
        .padding(.horizontal, 14)
    }

    // ✅ NEW: Public Ads
    private var publicAdsSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(L("إعلانات المجتمع", "Community Ads"))
                .font(.title3.bold())
                .padding(.horizontal, 14)
                .padding(.top, 2)

            if adsStore.activePublicAds.isEmpty {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 140)
                    .overlay(Text(L("لا يوجد إعلانات عامة الآن", "No public ads yet")).foregroundStyle(.secondary))
                    .padding(.horizontal, 14)
                    .padding(.top, 6)
            } else {
                VStack(spacing: 10) {
                    ForEach(adsStore.activePublicAds.prefix(25)) { ad in
                        Button {
                            selectedAd = ad
                            showAdPreview = true
                        } label: {
                            adsDashboardCard(ad) // reuse same card UI
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)
            }
        }
    }

    private var myAdsSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(L("إعلاناتك", "Your Ads"))
                .font(.title3.bold())
                .padding(.horizontal, 14)
                .padding(.top, 6)

            if adsStore.activeMyAds.isEmpty {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 140)
                    .overlay(Text(L("لا يوجد إعلانات نشطة بعد", "No active ads yet")).foregroundStyle(.secondary))
                    .padding(.horizontal, 14)
                    .padding(.top, 6)
            } else {
                VStack(spacing: 10) {
                    ForEach(adsStore.activeMyAds) { ad in
                        Button {
                            selectedAd = ad
                            showAdPreview = true
                        } label: {
                            adsDashboardCard(ad)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)
            }
        }
    }

    private var expiredSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if adsStore.expiredMyAds.isEmpty { return AnyView(EmptyView()) }

            return AnyView(
                VStack(alignment: .leading, spacing: 10) {
                    Text(L("إعلانات منتهية", "Expired Ads"))
                        .font(.headline)
                        .padding(.horizontal, 14)
                        .padding(.top, 10)

                    VStack(spacing: 10) {
                        ForEach(adsStore.expiredMyAds.prefix(6)) { ad in
                            adsExpiredCard(ad)
                                .padding(.horizontal, 14)
                        }
                    }
                }
            )
        }
    }

    // same cards (you already have them)
    private func adsDashboardCard(_ ad: HMPAd) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ad.businessName).font(.headline.weight(.bold)).lineLimit(1)
                    Text(ad.headline).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
                Spacer()
                planBadge(ad.plan)
            }

            if let img = ad.uiImages().first {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 170)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            Text(ad.adText)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Text(ad.remainingText(langIsArabic: lang.isArabic))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.07), radius: 12, x: 0, y: 8)
    }

    private func adsExpiredCard(_ ad: HMPAd) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ad.businessName).font(.subheadline.weight(.bold)).lineLimit(1)
                Spacer()
                Text(L("منتهي", "Expired"))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.9))
                    .clipShape(Capsule())
            }
            Text(ad.headline).font(.caption).foregroundStyle(.secondary).lineLimit(1)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemBackground)))
    }

    private func planBadge(_ plan: HMPAdPlanKind) -> some View {
        let title: String
        let bg: Color

        switch plan {
        case .prime:
            title = "PRIME"; bg = .yellow.opacity(0.95)
        case .monthly:
            title = L("شهري", "MONTH"); bg = .blue.opacity(0.9)
        case .weekly:
            title = L("أسبوعي", "WEEK"); bg = .cyan.opacity(0.9)
        case .freeOnce:
            title = L("هدية", "GIFT"); bg = .green.opacity(0.9)
        }

        return Text(title)
            .font(.caption2.weight(.bold))
            .foregroundColor(plan == .prime ? .black : .white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(bg)
            .clipShape(Capsule())
    }

    private func topPill(title: String, systemImage: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage).font(.subheadline.weight(.semibold))
            Text(title).font(.subheadline.weight(.semibold)).lineLimit(1)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 14).fill(tint.opacity(0.15)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.opacity(0.35), lineWidth: 1))
    }

    private func statChip(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline.weight(.bold))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(tint.opacity(0.12)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.opacity(0.22), lineWidth: 1))
    }

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }
}

// Address Sheet (same)
private struct HMPAddressSheet: View {
    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @State private var addressText: String = ""

    var body: some View {
        Form {
            Section(header: Text(lang.isArabic ? "عنوانك" : "Your Address")) {
                TextField(lang.isArabic ? "اكتب العنوان" : "Enter address", text: $addressText)
            }
            Section {
                Button(lang.isArabic ? "حفظ" : "Save") { dismiss() }
            }
        }
        .navigationTitle(lang.isArabic ? "أضف عنوانك" : "Add Address")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(lang.isArabic ? "إغلاق" : "Close") { dismiss() }
            }
        }
    }
}
