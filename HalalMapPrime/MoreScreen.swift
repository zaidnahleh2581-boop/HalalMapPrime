import SwiftUI

struct MoreScreen: View {
    @EnvironmentObject var lang: LanguageManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - About
                    GroupBox("About Halal Map Prime") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Halal Map Prime هو دليل رقمي متكامل يساعد المسلمين على العثور على المطاعم، البقالات، المدارس، المساجد والخدمات الحلال حولهم بسهولة ووضوح.")
                            Text("هدفنا أن نوفّر خريطة واحدة موثوقة، محترمة، وتراعي خصوصية المستخدم وتدعمه في حياته اليومية داخل الولايات المتحدة وخارجها.")
                        }
                        .font(.subheadline)
                    }
                    
                    // MARK: - Mission
                    GroupBox("Our Mission – رسالتنا") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• خدمة العائلات المسلمة التي تبحث عن أماكن حلال موثوقة.")
                            Text("• دعم أصحاب الأعمال الحلال بمنصة عادلة وواضحة للإعلان.")
                            Text("• مساعدة المدارس، المساجد والمراكز الإسلامية للوصول إلى المجتمع بسهولة.")
                            Text("")
                            Text("Halal Map Prime – Your trusted halal companion.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .font(.subheadline)
                    }
                    
                    
                    // MARK: - Privacy
                    GroupBox("Privacy & Security — الخصوصية والأمان") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Read how we handle data, permissions, and verification. اقرأ كيف نتعامل مع البيانات والصلاحيات والتوثيق.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            NavigationLink {
                                PrivacySecurityView()
                                    .environmentObject(lang)
                            } label: {
                                HStack {
                                    Image(systemName: "hand.raised.fill")
                                    Text("Privacy & Security")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }

// MARK: - Contact
                    GroupBox("Contact Us – تواصل معنا") {
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(label: "Email (Main)", value: "support@halalmapprime.com")
                            InfoRow(label: "Gmail", value: "halalmapprime@gmail.com")
                            InfoRow(label: "Outlook", value: "halalmapprime@outlook.com")
                            InfoRow(label: "Phone / WhatsApp", value: "+1 (631) 947-5782")
                            
                            Link(destination: URL(string: "https://halalmapprime.com")!) {
                                HStack {
                                    Image(systemName: "globe")
                                    Text("halalmapprime.com")
                                }
                            }
                            .font(.subheadline)
                            .padding(.top, 4)
                            
                            Text("لأي استفسار، اقتراح، أو ملاحظات على أي مكان في التطبيق، راسلنا في أي وقت. نحن نراجع كل رسالة يدويًا لأن ثقة المجتمع أهم من أي شيء.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .font(.subheadline)
                    }
                    
                    // MARK: - Privacy & Security
                    GroupBox("Privacy & Security – الخصوصية والحماية") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• نستخدم موقعك فقط لعرض أماكن قريبة منك، ولا نبيع بيانات موقعك لأي طرف ثالث.")
                            Text("• نستخدم خدمات خارجية مثل Google Maps و Google Places التي قد تجمع بعض البيانات حسب سياساتها الخاصة.")
                            Text("• لا نطلب معلومات شخصية حساسة بدون سبب واضح (مثل رقم الضمان الاجتماعي أو معلومات بنكية).")
                            Text("• الأماكن المضافة عبر Add Store قد تُراجع يدويًا قبل النشر لحماية المستخدمين.")
                            Text("• لحذف بياناتك أو أي مكان مضاف، راسلنا على privacy@halalmapprime.com.")
                            
                            Text("هذا الملخص لأغراض توضيحية فقط، ولا يُعتبر نصًا قانونيًا نهائيًا. سيتم نشر سياسة الخصوصية الكاملة على موقعنا الرسمي عند الإطلاق.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .font(.subheadline)
                    }
                    
                    // MARK: - Terms of Use
                    GroupBox("Terms of Use") {
                        VStack(alignment: .leading, spacing: 8) {
                            NavigationLink(destination: TermsView()) {
                                Label("View Terms of Use", systemImage: "doc.text.fill")
                            }
                            .font(.subheadline)
                            
                            Text("تعرف على شروط وأحكام استخدام Halal Map Prime.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // MARK: - App Info
                    GroupBox("App Info – معلومات التطبيق") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("• App Name: Halal Map Prime")
                            Text("• Region: United States")
                            Text("• Jobs & Ads: جميع الوظائف والإعلانات عبر التطبيق يجب أن تكون حلالًا وقانونية داخل الولايات المتحدة.")
                            
                            Text("باستخدامك للتطبيق، فأنت توافق على احترام القوانين المحلية، والحفاظ على روح الاحترام بين جميع مستخدمي Halal Map Prime.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .font(.subheadline)
                    }
                }
                .padding()
            }
            .navigationTitle("More")
        }
    }
}

// MARK: - Info Row (label + value in one line)
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.footnote.weight(.semibold))
            Spacer()
            Text(value)
                .font(.footnote)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Terms of Use View
struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text("Terms of Use – شروط الاستخدام")
                    .font(.title2.bold())
                
                Text("""
باستخدامك لتطبيق Halal Map Prime، فإنك توافق على الشروط التالية:

1. يجب أن تكون جميع الإعلانات، الوظائف، أو النشاطات التجارية المدرجة في التطبيق قانونية وحلال داخل الولايات المتحدة.
2. يُمنع إضافة أي محتوى مضلل، غير دقيق، أو يسيء إلى أي فرد أو مؤسسة.
3. نحتفظ بحق إزالة أي مكان أو إعلان إذا وُجد أنه غير مناسب أو مخالف لسياساتنا.
4. يتم استخدام موقعك الجغرافي فقط لعرض الأماكن القريبة منك، ولا يتم مشاركته مع أي طرف غير مصرح.
5. Google Maps و Google Places هما خدمات طرف ثالث وقد تجمع بعض البيانات حسب سياساتها الخاصة.
6. أي محاولة لاختراق التطبيق، التلاعب بالإعلانات، أو إساءة استخدام الخدمات قد تؤدي إلى حظر الحساب أو اتخاذ إجراءات قانونية.

نشكرك على استخدامك Halal Map Prime، ونسعى دائمًا لتقديم خدمة موثوقة ومحترمة للمجتمع المسلم.
""")
                .font(.subheadline)
                .foregroundColor(.primary)
                
                Text("Last updated: January 2025")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Terms of Use")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MoreScreen()
}


// MARK: - Privacy & Security

struct PrivacySecurityView: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text(L("الخصوصية والأمان", "Privacy & Security"))
                    .font(.title2.bold())

                GroupBox(L("ماذا نجمع؟", "What we collect")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Bullet(text: L("معلومات المكان التي ترسلها أنت (الاسم، العنوان، النوع…)", "Place info you submit (name, address, category, etc.)."))
                        Bullet(text: L("بيانات تقنية لتحسين الأداء والاستقرار (مثل الأعطال/التشخيص عند الحاجة).", "Technical data to improve stability (e.g., crash diagnostics when needed)."))
                        Bullet(text: L("الموقع الجغرافي: فقط إذا سمحت لنا بذلك من إعدادات النظام.", "Location: only if you grant permission in system settings."))
                    }
                }

                GroupBox(L("كيف نستخدم البيانات؟", "How we use data")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Bullet(text: L("عرض الأماكن على الخريطة وتحسين نتائج البحث.", "To display places on the map and improve search results."))
                        Bullet(text: L("مراجعة الإضافات قبل نشرها لمنع المحتوى المخالف أو المضلل.", "To review submissions before publishing to prevent spam or misleading content."))
                        Bullet(text: L("تقديم الإعلانات المدفوعة (عند اختيارك ذلك).", "To provide paid ads (only if you choose to use them)."))
                    }
                }

                GroupBox(L("التوثيق (Verified Halal)", "Verification (Verified Halal)")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(L(
                            "ميزة التوثيق اختيارية. قد نطلب إثباتاً (مثل صورة واجهة المحل أو فاتورة) لتفعيل علامة Verified.",
                            "Verification is optional. We may request proof (like a storefront photo or receipt) to enable the Verified badge."
                        ))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                        Text(L(
                            "ملاحظة: إرسال الإثبات عبر WhatsApp هو خيار مؤقت للـ MVP. لا ننشر الإثبات للعامة.",
                            "Note: Sending proof via WhatsApp is a temporary MVP option. Proof is not published publicly."
                        ))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }

                GroupBox(L("مشاركة البيانات", "Data sharing")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Bullet(text: L("لا نبيع بياناتك.", "We do not sell your data."))
                        Bullet(text: L("قد نستخدم مزودي خدمة مثل Firebase لتخزين البيانات وتشغيل التطبيق.", "We may use service providers like Firebase to run the app and store data."))
                    }
                }

                GroupBox(L("التحكم والاتصال", "Control & Contact")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(L(
                            "يمكنك التحكم في صلاحيات الموقع/الصور من إعدادات iOS. ولأي استفسار تواصل معنا:",
                            "You can control permissions (Location/Photos) from iOS Settings. For questions, contact:"
                        ))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                        Text("info@halalmapprime.com")
                            .font(.subheadline.bold())
                        Text("+1 (631) 947-5782")
                            .font(.subheadline.bold())
                    }
                }
                GroupBox(L("الموقع الرسمي وسياسة الخصوصية", "Official Website & Privacy Policy")) {
                    VStack(alignment: .leading, spacing: 10) {

                        Text(L(
                            "يمكنك قراءة سياسة الخصوصية الكاملة والمحدّثة عبر موقعنا الرسمي:",
                            "You can read the full and updated Privacy Policy on our official website:"
                        ))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                        Link(destination: URL(string: "https://halalmapprime.com/privacy")!) {
                            HStack {
                                Image(systemName: "globe")
                                Text("halalmapprime.com/privacy")
                                    .font(.subheadline.weight(.semibold))
                            }
                        }

                        Text(L(
                            "في حال وجود أي تعارض بين هذا الملخص وسياسة الخصوصية على الموقع، يُعتمد النص المنشور على الموقع.",
                            "In case of any conflict between this summary and the website policy, the website version prevails."
                        ))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                }
                Spacer(minLength: 24)
            }
            .padding()
        }
        .navigationTitle(L("الخصوصية", "Privacy"))
    }
}

private struct Bullet: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•").font(.headline)
            Text(text).font(.subheadline)
            Spacer()
        }
    }
}
