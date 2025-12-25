import SwiftUI

/// صفحة تعرض إعلانات المستخدم (لاحقاً سيتم ربطها مع Firebase)
struct MyAdsView: View {

    @EnvironmentObject var lang: LanguageManager

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text(lang.isArabic ? "لا توجد إعلانات بعد" : "No ads yet")
                .font(.title3.bold())

            Text(
                lang.isArabic
                ? "لاحقاً عندما نربط التطبيق بقاعدة البيانات، ستظهر هنا جميع إعلاناتك المجانية والمدفوعة مع حالة كل إعلان."
                : "Later, when we connect to the database, all your free and paid ads will appear here with their status."
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationTitle(lang.isArabic ? "إعلاناتي" : "My ads")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MyAdsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyAdsView()
                .environmentObject(LanguageManager())
        }
    }
}
