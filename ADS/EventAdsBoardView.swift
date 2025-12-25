import SwiftUI

struct EventAdsBoardView: View {

    @EnvironmentObject var lang: LanguageManager

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(.blue.opacity(0.85))

                Text(
                    L(
                        "صفحة إعلانات الفعاليات قيد التطوير.\nمن هنا سيتم عرض جميع فعاليات المجتمع.",
                        "Events board is under construction.\nHere you will see all community events."
                    )
                )
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle(L("إعلانات الفعاليات", "Community Events"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EventAdsBoardView_Previews: PreviewProvider {
    static var previews: some View {
        EventAdsBoardView()
            .environmentObject(LanguageManager())
    }
}
