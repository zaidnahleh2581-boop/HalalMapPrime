import SwiftUI

struct MapPaidBannerView: View {

    @EnvironmentObject var lang: LanguageManager
    @ObservedObject var viewModel: MapPaidAdsViewModel

    @State private var currentIndex: Int = 0
    @State private var timer: Timer?

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    private var currentAd: MapPaidAd? {
        guard !viewModel.activeAds.isEmpty else { return nil }
        let safeIndex = currentIndex % viewModel.activeAds.count
        return viewModel.activeAds[safeIndex]
    }

    var body: some View {
        Group {
            if let ad = currentAd {
                Button {
                    // لاحقاً ممكن نفتح صفحة تفاصيل الإعلان المدفوع
                    print("Tapped paid banner: \(ad.id)")
                } label: {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bannerTitle(for: ad))
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Text(bannerSubtitle(for: ad))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                        }

                        Spacer()

                        Image(systemName: "star.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(.systemPurple),
                                Color(.systemPink)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .cornerRadius(14)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.top, 6)
                .onAppear { startTimer() }
                .onDisappear { stopTimer() }
            } else {
                // لو ما في إعلانات مدفوعة، ممكن تظهر مساحة فارغة أو بانر مجاني
                EmptyView()
            }
        }
    }

    private func bannerTitle(for ad: MapPaidAd) -> String {
        switch ad.planType {
        case .daily:
            return L("إعلان مميز - باقة يومية", "Featured ad – Daily plan")
        case .weekly:
            return L("إعلان مميز - باقة أسبوعية", "Featured ad – Weekly plan")
        case .monthly:
            return L("إعلان مميز - باقة شهرية", "Featured ad – Monthly plan")
        }
    }

    private func bannerSubtitle(for ad: MapPaidAd) -> String {
        let days = ad.durationDays
        if lang.isArabic {
            return "إعلان مدفوع نشط لمدة \(days) يوم/أيام داخل الخريطة والبنرات."
        } else {
            return "Active paid banner for \(days) day(s) across the map and top banners."
        }
    }

    private func startTimer() {
        stopTimer()
        guard viewModel.activeAds.count > 1 else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            guard !viewModel.activeAds.isEmpty else { return }
            currentIndex = (currentIndex + 1) % viewModel.activeAds.count
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
