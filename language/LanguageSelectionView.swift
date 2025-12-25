import SwiftUI

struct LanguageSelectionView: View {

    @EnvironmentObject var lang: LanguageManager

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            Text(lang.isArabic ? "اختر لغة التطبيق" : "Choose App Language")
                .font(.title2.bold())

            VStack(spacing: 16) {

                Button {
                    lang.select(.arabic)
                } label: {
                    Text("العربية")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }

                Button {
                    lang.select(.english)
                } label: {
                    Text("English")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}
