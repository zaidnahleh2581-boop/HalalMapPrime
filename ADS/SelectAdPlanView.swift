import SwiftUI

/// شاشة اختيار باقة الإعلان (يومي / أسبوعي / شهري)
struct SelectAdPlanView: View {

    @EnvironmentObject var lang: LanguageManager

    @State private var showAlert: Bool = false
    @State private var selectedPlanMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // العنوان
                VStack(alignment: .leading, spacing: 4) {
                    Text(lang.isArabic ? "اختر باقة الإعلان" : "Select Your Ad Plan")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(
                        lang.isArabic
                        ? "اختر مدة ودرجة ظهور إعلانك في التطبيق."
                        : "Choose how long and how strong your ad will appear in the app."
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)

                // نص تعريفي
                Text(
                    lang.isArabic
                    ? "اختر مدة ظهور إعلانك داخل التطبيق. جميع عمليات الدفع تتم بأمان من خلال Apple In-App Purchase."
                    : "Pick how long your ad will run. All payments will be processed securely through Apple In-App Purchase."
                )
                .font(.subheadline)
                .foregroundColor(.secondary)

                // كروت الباقات
                VStack(spacing: 12) {
                    dailyPlanCard
                    weeklyPlanCard
                    monthlyPlanCard
                }
                .padding(.top, 4)

                // مقارنة بسيطة
                comparisonSection

                // ملاحظة أخيرة
                footerNote
            }
            .padding()
        }
        .navigationTitle(lang.isArabic ? "اختيار الباقة" : "Choose a Plan")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(lang.isArabic ? "قيد التنفيذ" : "Coming soon"),
                message: Text(selectedPlanMessage),
                dismissButton: .default(Text(lang.isArabic ? "حسناً" : "OK"))
            )
        }
    }
}

// MARK: - Components

private extension SelectAdPlanView {

    var dailyPlanCard: some View {
        planCard(
            titleAR: "إعلان يومي",
            titleEN: "Daily Ad",
            subtitleAR: "$4.99 / اليوم (مثال)",
            subtitleEN: "$4.99 / day (example)",
            descriptionAR: "ظهور إعلانك لمدة ٢٤ ساعة في الأماكن المميزة داخل التطبيق والخريطة.",
            descriptionEN: "Your ad appears for 24 hours in highlighted spots across the app and map.",
            bulletsAR: [
                "مناسب للعروض السريعة أو الافتتاحات.",
                "تفعيل فوري بعد إتمام الدفع.",
                "ظهور جيد ضمن نظام التدوير (Rotation)."
            ],
            bulletsEN: [
                "Great for quick promos or grand openings.",
                "Instant activation after payment.",
                "Good visibility in the rotation system."
            ],
            accentColor: Color(.systemYellow)
        ) {
            selectedPlanMessage =
            lang.isArabic
            ? "تم اختيار الباقة اليومية. لاحقًا سيتم ربط هذه الخطوة بالدفع عبر StoreKit ثم شاشة تعبئة تفاصيل الإعلان."
            : "Daily plan selected. Later this step will be connected to StoreKit payment, then the ad details form."
            showAlert = true
        }
    }

    var weeklyPlanCard: some View {
        planCard(
            titleAR: "إعلان أسبوعي (الأكثر اختياراً)",
            titleEN: "Weekly Ad (Most popular)",
            subtitleAR: "$14.99 / الأسبوع (مثال)",
            subtitleEN: "$14.99 / week (example)",
            descriptionAR: "ظهور إعلانك لمدة ٧ أيام متواصلة مع ترتيب أعلى في نتائج الإعلانات.",
            descriptionEN: "Your ad appears for 7 days with higher ranking in ad placements.",
            bulletsAR: [
                "مناسب للمطاعم والخدمات التي ترغب في ثبات الظهور.",
                "أولوية أعلى من الإعلان اليومي.",
                "قيمة أفضل مقابل السعر."
            ],
            bulletsEN: [
                "Perfect for restaurants and services that want steady visibility.",
                "Higher priority than daily ads.",
                "Better value for money."
            ],
            accentColor: Color(.systemBlue)
        ) {
            selectedPlanMessage =
            lang.isArabic
            ? "تم اختيار الباقة الأسبوعية. لاحقًا سيتم ربط هذه الخطوة بالدفع عبر StoreKit ثم شاشة تعبئة تفاصيل الإعلان."
            : "Weekly plan selected. Later this step will be connected to StoreKit payment, then the ad details form."
            showAlert = true
        }
    }

    var monthlyPlanCard: some View {
        planCard(
            titleAR: "إعلان شهري (مميز)",
            titleEN: "Monthly Ad (Premium)",
            subtitleAR: "$49.99 / الشهر (مثال)",
            subtitleEN: "$49.99 / month (example)",
            descriptionAR: "أقوى ظهور للإعلان داخل التطبيق مع أولوية عالية في تدوير البانرات.",
            descriptionEN: "Maximum visibility inside the app with top priority in banner rotation.",
            bulletsAR: [
                "أفضل خيار لأصحاب الأعمال الذين يريدون حضوراً دائماً.",
                "أعلى أولوية بين جميع الإعلانات.",
                "ظهور مستمر لمدة ٣٠ يوماً."
            ],
            bulletsEN: [
                "Best choice for businesses that want constant presence.",
                "Highest priority among all ad types.",
                "Continuous visibility for 30 days."
            ],
            accentColor: Color(.systemGreen)
        ) {
            selectedPlanMessage =
            lang.isArabic
            ? "تم اختيار الباقة الشهرية. لاحقًا سيتم ربط هذه الخطوة بالدفع عبر StoreKit ثم شاشة تعبئة تفاصيل الإعلان."
            : "Monthly plan selected. Later this step will be connected to StoreKit payment, then the ad details form."
            showAlert = true
        }
    }

    func planCard(
        titleAR: String,
        titleEN: String,
        subtitleAR: String,
        subtitleEN: String,
        descriptionAR: String,
        descriptionEN: String,
        bulletsAR: [String],
        bulletsEN: [String],
        accentColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        let bullets = lang.isArabic ? bulletsAR : bulletsEN

        return Button {
            action()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lang.isArabic ? titleAR : titleEN)
                            .font(.headline)

                        Text(lang.isArabic ? subtitleAR : subtitleEN)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "star.fill")
                                .foregroundColor(accentColor)
                                .imageScale(.medium)
                        )
                }

                Text(lang.isArabic ? descriptionAR : descriptionEN)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                            Text(bullet)
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                }

                Text(lang.isArabic ? "اختيار هذه الباقة" : "Choose this plan")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(accentColor)
                    )
                    .foregroundColor(.white)
                    .padding(.top, 4)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06),
                            radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
    }

    var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lang.isArabic ? "مقارنة سريعة بين الباقات" : "Quick comparison between plans")
                .font(.headline)

            VStack(spacing: 6) {
                comparisonRow(
                    label: lang.isArabic ? "مدة العرض" : "Duration",
                    daily: lang.isArabic ? "٢٤ ساعة" : "24 hours",
                    weekly: lang.isArabic ? "٧ أيام" : "7 days",
                    monthly: lang.isArabic ? "٣٠ يوم" : "30 days"
                )

                comparisonRow(
                    label: lang.isArabic ? "قوة الظهور" : "Visibility strength",
                    daily: "⭐",
                    weekly: "⭐⭐",
                    monthly: "⭐⭐⭐"
                )

                comparisonRow(
                    label: lang.isArabic ? "الأولوية" : "Priority",
                    daily: lang.isArabic ? "أساسية" : "Basic",
                    weekly: lang.isArabic ? "متوسطة" : "Medium",
                    monthly: lang.isArabic ? "عالية" : "High"
                )
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .padding(.top, 8)
    }

    func comparisonRow(label: String, daily: String, weekly: String, monthly: String) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(daily)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(weekly)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(monthly)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    var footerNote: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(lang.isArabic ? "ملاحظة مهمة" : "Important note")
                .font(.footnote.weight(.semibold))

            Text(
                lang.isArabic
                ? "جميع عمليات الشراء تتم من خلال Apple In-App Purchase، ويمكنك إدارة أو إلغاء الاشتراكات من إعدادات حسابك في App Store."
                : "All purchases will be handled through Apple In-App Purchase. You can manage or cancel subscriptions from your App Store settings."
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding(.top, 16)
    }
}

// MARK: - Preview

struct SelectAdPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SelectAdPlanView()
                .environmentObject(LanguageManager())
        }
    }
}
