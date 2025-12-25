import SwiftUI

/// نموذج الإعلان المجاني (مرة واحدة لكل حساب)
struct FreeAdFormView: View {

    @EnvironmentObject var lang: LanguageManager

    // بيانات بسيطة للنموذج
    @State private var fullName: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var city: String = ""
    @State private var category: String = ""

    @State private var showAlert = false

    var body: some View {
        Form {
            Section(
                header: Text(lang.isArabic ? "معلومات التواصل" : "Contact information")
            ) {
                TextField(lang.isArabic ? "الاسم الكامل" : "Full name", text: $fullName)
                TextField(lang.isArabic ? "رقم الهاتف" : "Phone number", text: $phone)
                    .keyboardType(.phonePad)
                TextField(lang.isArabic ? "البريد الإلكتروني (اختياري)" : "Email (optional)", text: $email)
                    .keyboardType(.emailAddress)
            }

            Section(
                header: Text(lang.isArabic ? "تفاصيل الإعلان" : "Ad details")
            ) {
                TextField(lang.isArabic ? "عنوان قصير للإعلان" : "Short ad title", text: $title)

                TextField(
                    lang.isArabic ? "اكتب نص الإعلان بالتفصيل" : "Write your ad text in detail",
                    text: $details,
                    axis: .vertical
                )
                .lineLimit(3...6)

                TextField(lang.isArabic ? "المدينة / المنطقة" : "City / area", text: $city)

                TextField(
                    lang.isArabic ? "نوع الإعلان (مثال: فعالية، إعلان مجتمعي…)" :
                                     "Ad type (e.g. event, community notice...)",
                    text: $category
                )
            }

            Section {
                Button {
                    // لاحقاً تربط هذه الخطوة بـ Firebase
                    showAlert = true
                } label: {
                    Text(lang.isArabic ? "إرسال الإعلان المجاني" : "Submit free ad")
                        .frame(maxWidth: .infinity)
                }
            }

            Section(
                footer: Text(
                    lang.isArabic
                    ? "سيتم استخدام هذا النموذج للإعلانات المجتمعية المجانية فقط، وليس للإعلانات التجارية المدفوعة."
                    : "This form is only for free community announcements, not for paid business ads."
                )
                .font(.footnote)
                .foregroundColor(.secondary)
            ) {
                EmptyView()
            }
        }
        .navigationTitle(lang.isArabic ? "إعلان مجاني" : "Free community ad")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(lang.isArabic ? "لاحقاً" : "Coming soon"),
                message: Text(
                    lang.isArabic
                    ? "سيتم حفظ هذا الإعلان في Firebase عند تفعيل قاعدة البيانات. حالياً النموذج لتجربة شكل العملية فقط."
                    : "This ad will be saved to Firebase once we enable the database. For now the form is for demo only."
                ),
                dismissButton: .default(Text(lang.isArabic ? "حسناً" : "OK"))
            )
        }
    }
}

struct FreeAdFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FreeAdFormView()
                .environmentObject(LanguageManager())
        }
    }
}
