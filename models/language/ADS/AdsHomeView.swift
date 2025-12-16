import SwiftUI

struct AdsHomeView: View {

    @EnvironmentObject var lang: LanguageManager

    @State private var showFreeAdForm: Bool = false
    @State private var showPaidAdPlans: Bool = false
    @State private var showPrimeAdPlans: Bool = false
    @State private var showMyAds: Bool = false
    @State private var showJobAds: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    introSection
                    buttonsSection
                    footerNote
                }
                .padding()
            }
            .navigationTitle(lang.isArabic ? "الإعلانات" : "Ads")
            .navigationBarTitleDisplayMode(.inline)

            .sheet(isPresented: $showFreeAdForm) {
                FreeAdFormView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showPaidAdPlans) {
                SelectAdPlanView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showPrimeAdPlans) {
                SelectAdPlanView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showMyAds) {
                MyAdsView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showJobAds) {
                JobAdsBoardView()
                    .environmentObject(lang)
            }
        }
    }
}

private extension AdsHomeView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(lang.isArabic ? "الإعلانات في Halal Map Prime" : "Ads in Halal Map Prime")
                .font(.title2.weight(.semibold))

            Text(lang.isArabic
                 ? "اختر نوع الإعلان الذي يناسب نشاطك التجاري أو خدمتك."
                 : "Choose the ad type that fits your business or service.")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }

    var introSection: some View {
        Text(lang.isArabic
             ? "ابدأ بإعلان مجاني بصور (1–3)، أو اختر باقات مدفوعة لظهور أقوى."
             : "Start with a free photo ad (1–3), or choose paid plans for stronger visibility.")
        .font(.subheadline)
        .foregroundColor(.secondary)
    }

    var buttonsSection: some View {
        VStack(spacing: 12) {

            adButton(
                titleAr: "إعلان مجاني (صور 1–3)",
                titleEn: "Free photo ad (1–3 images)",
                subtitleAr: "إعلان بسيط لمحلّك يظهر في الصفحة الرئيسية.",
                subtitleEn: "Simple ad that appears on the home feed.",
                background: Color.green
            ) { showFreeAdForm = true }

            adButton(
                titleAr: "إعلان مدفوع (يومي/أسبوعي/شهري)",
                titleEn: "Paid ad (daily/weekly/monthly)",
                subtitleAr: "ظهور أقوى ضمن Sponsored.",
                subtitleEn: "Stronger visibility in Sponsored.",
                background: Color.blue
            ) { showPaidAdPlans = true }

            adButton(
                titleAr: "Prime Ads (أعلى ظهور)",
                titleEn: "Prime Ads (top visibility)",
                subtitleAr: "أفضل ظهور ممكن ضمن Sponsored.",
                subtitleEn: "Maximum visibility in Sponsored.",
                background: Color.orange
            ) { showPrimeAdPlans = true }

            adButton(
                titleAr: "إعلاناتي",
                titleEn: "My ads",
                subtitleAr: "إدارة إعلاناتك السابقة.",
                subtitleEn: "Manage your created ads.",
                background: Color.purple
            ) { showMyAds = true }

            adButton(
                titleAr: "إعلانات وظائف",
                titleEn: "Job ads",
                subtitleAr: "نموذج وظائف (قريبًا نطوره أكثر).",
                subtitleEn: "Job ads template (we’ll expand it).",
                background: Color.brown
            ) { showJobAds = true }
        }
    }

    var footerNote: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(lang.isArabic ? "ملاحظة مهمة" : "Policy note")
                .font(.footnote.weight(.semibold))

            Text(lang.isArabic
                 ? "كل الإعلانات لازم تكون حلال ومتوافقة مع سياسات Apple."
                 : "All ads must be halal and compliant with Apple policies.")
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding(.top, 12)
    }

    func adButton(
        titleAr: String,
        titleEn: String,
        subtitleAr: String,
        subtitleEn: String,
        background: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(lang.isArabic ? titleAr : titleEn)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(lang.isArabic ? subtitleAr : subtitleEn)
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16).fill(background.opacity(0.92)))
            .shadow(color: background.opacity(0.25), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}
