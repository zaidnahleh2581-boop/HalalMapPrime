//
//  AdCopyLibrary.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh
//  Updated by Zaid Nahleh on 12/18/25
//

import Foundation

enum AdCopyLibrary {

    /// Generates safe, pre-approved ad copy (NO user-written text)
    static func generate(ad: Ad, isArabic: Bool) -> String {
        let phrase = pickPhrase(
            businessType: ad.businessType,
            template: ad.template,
            isArabic: isArabic,
            stableKey: ad.businessName + "|" + ad.phone + "|" + ad.city + "|" + ad.state
        )

        let type = isArabic ? ad.businessType.titleAR : ad.businessType.titleEN
        let location = "\(ad.city), \(ad.state)".trimmingCharacters(in: .whitespacesAndNewlines)

        return phrase
            .replacingOccurrences(of: "{BUSINESS}", with: ad.businessName)
            .replacingOccurrences(of: "{TYPE}", with: type)
            .replacingOccurrences(of: "{CITYSTATE}", with: location)
            .replacingOccurrences(of: "{ADDRESS}", with: ad.addressLine)
            .replacingOccurrences(of: "{PHONE}", with: ad.phone)
    }

    // MARK: - Phrase Picker (stable, not random)
    private static func pickPhrase(
        businessType: Ad.BusinessType,
        template: Ad.CopyTemplate,
        isArabic: Bool,
        stableKey: String
    ) -> String {

        let list = phrases(isArabic: isArabic, type: businessType, template: template)
        if list.isEmpty {
            return isArabic
            ? "{BUSINESS} — {TYPE} في {CITYSTATE}. للتواصل: {PHONE}."
            : "{BUSINESS} — {TYPE} in {CITYSTATE}. Contact: {PHONE}."
        }

        let idx = Int(fnv1a64(stableKey) % UInt64(list.count))
        return list[idx]
    }

    // MARK: - Deterministic hash (FNV-1a 64-bit)
    private static func fnv1a64(_ s: String) -> UInt64 {
        let prime: UInt64 = 1099511628211
        var hash: UInt64 = 14695981039346656037
        for b in s.utf8 {
            hash ^= UInt64(b)
            hash &*= prime
        }
        return hash
    }

    // MARK: - Library (NO user text)
    private static func phrases(isArabic: Bool, type: Ad.BusinessType, template: Ad.CopyTemplate) -> [String] {

        func base(_ ar: [String], _ en: [String]) -> [String] { isArabic ? ar : en }

        // ✅ 10 base phrases لكل BusinessType (نخليها آمنة ومحايدة)
        let restaurantAR = [
            "{BUSINESS} — {TYPE} حلال في {CITYSTATE}.",
            "أشهى الأطباق الحلال بانتظاركم في {BUSINESS}.",
            "تجربة طعام مميزة وأجواء لطيفة في {BUSINESS}.",
            "أطباق متنوعة تناسب كل الأذواق في {BUSINESS}.",
            "وجبات طازجة وخدمة مميزة في {BUSINESS}.",
            "زوروا {BUSINESS} واستمتعوا بطعام حلال لذيذ.",
            "خيار رائع للعائلة والأصدقاء في {BUSINESS}.",
            "{BUSINESS} وجهتكم للطعام الحلال في {CITYSTATE}.",
            "طعم أصيل وجودة عالية في {BUSINESS}.",
            "اتصلوا بنا: {PHONE} — {BUSINESS}."
        ]
        let restaurantEN = [
            "{BUSINESS} — halal {TYPE} in {CITYSTATE}.",
            "Enjoy delicious halal food at {BUSINESS}.",
            "A great dining experience awaits at {BUSINESS}.",
            "A variety of dishes for every taste at {BUSINESS}.",
            "Fresh meals and friendly service at {BUSINESS}.",
            "Visit {BUSINESS} for a satisfying halal meal.",
            "Perfect for friends and families — {BUSINESS}.",
            "{BUSINESS} is your halal destination in {CITYSTATE}.",
            "Authentic taste and quality at {BUSINESS}.",
            "Call us: {PHONE} — {BUSINESS}."
        ]

        let groceryAR = [
            "{BUSINESS} — بقالة حلال في {CITYSTATE}.",
            "مواد غذائية حلال وتشكيلة يومية في {BUSINESS}.",
            "تسوّقوا بثقة: منتجات مختارة في {BUSINESS}.",
            "احتياجاتكم اليومية متوفرة في {BUSINESS}.",
            "أسعار مناسبة وخدمة سريعة في {BUSINESS}.",
            "منتجات طازجة ومتنوعة في {BUSINESS}.",
            "زورونا في {BUSINESS} — كل ما تحتاجه العائلة.",
            "تشكيلة واسعة من المنتجات الحلال في {BUSINESS}.",
            "{BUSINESS} قريب منكم في {CITYSTATE}.",
            "للاستفسار: {PHONE}."
        ]
        let groceryEN = [
            "{BUSINESS} — halal grocery in {CITYSTATE}.",
            "Daily essentials and halal items at {BUSINESS}.",
            "Shop with confidence at {BUSINESS}.",
            "Your everyday needs are here — {BUSINESS}.",
            "Great prices and quick service at {BUSINESS}.",
            "Fresh and diverse products at {BUSINESS}.",
            "Visit {BUSINESS} for family essentials.",
            "Wide selection of halal groceries at {BUSINESS}.",
            "{BUSINESS} near you in {CITYSTATE}.",
            "Questions? {PHONE}."
        ]

        let butcherAR = [
            "{BUSINESS} — ملحمة حلال في {CITYSTATE}.",
            "لحوم حلال بجودة عالية في {BUSINESS}.",
            "اختيارات متنوعة وخدمة محترمة في {BUSINESS}.",
            "تجهيزات حسب الطلب متوفرة في {BUSINESS}.",
            "لحوم طازجة وتقطيع احترافي في {BUSINESS}.",
            "زورونا في {BUSINESS} — جودة تفرق.",
            "{BUSINESS} خياركم للحوم الحلال في {CITYSTATE}.",
            "نستقبلكم يوميًا في {BUSINESS}.",
            "اطلبوا الآن واتصلوا: {PHONE}.",
            "عنواننا: {ADDRESS}."
        ]
        let butcherEN = [
            "{BUSINESS} — halal butcher in {CITYSTATE}.",
            "High-quality halal meats at {BUSINESS}.",
            "Great selection and respectful service at {BUSINESS}.",
            "Custom cuts available at {BUSINESS}.",
            "Fresh meats and professional preparation at {BUSINESS}.",
            "Visit {BUSINESS} — quality you can trust.",
            "{BUSINESS} is your halal meat destination in {CITYSTATE}.",
            "We’re open daily — {BUSINESS}.",
            "Order now: {PHONE}.",
            "Find us at {ADDRESS}."
        ]

        let deliAR = [
            "{BUSINESS} — ديلي حلال في {CITYSTATE}.",
            "ساندويشات وخيارات سريعة في {BUSINESS}.",
            "خدمة سريعة وطعم رائع في {BUSINESS}.",
            "اختيارات يومية مناسبة للدوام في {BUSINESS}.",
            "وجبات خفيفة لذيذة في {BUSINESS}.",
            "{BUSINESS} خيار ممتاز للغداء السريع.",
            "زورونا في {BUSINESS} اليوم.",
            "جودة ونظافة واهتمام بالتفاصيل في {BUSINESS}.",
            "للطلب: {PHONE}.",
            "{BUSINESS} — {ADDRESS}."
        ]
        let deliEN = [
            "{BUSINESS} — halal deli in {CITYSTATE}.",
            "Sandwiches and quick bites at {BUSINESS}.",
            "Fast service and great taste at {BUSINESS}.",
            "Daily options perfect for work days at {BUSINESS}.",
            "Tasty light meals at {BUSINESS}.",
            "{BUSINESS} is a great lunch spot.",
            "Stop by {BUSINESS} today.",
            "Clean, quality, and detail-focused — {BUSINESS}.",
            "To order: {PHONE}.",
            "{BUSINESS} — {ADDRESS}."
        ]

        let bakeryAR = [
            "{BUSINESS} — مخبز في {CITYSTATE}.",
            "مخبوزات طازجة يوميًا في {BUSINESS}.",
            "حلويات ومخبوزات بنكهة مميزة في {BUSINESS}.",
            "رائحة الخبز الطازج في {BUSINESS}.",
            "اختيارات رائعة للضيافة في {BUSINESS}.",
            "زورونا صباحًا في {BUSINESS}.",
            "{BUSINESS} — جودة وطعم يفرح.",
            "مخبوزات مناسبة للعائلة في {BUSINESS}.",
            "للاستفسار: {PHONE}.",
            "عنواننا: {ADDRESS}."
        ]
        let bakeryEN = [
            "{BUSINESS} — bakery in {CITYSTATE}.",
            "Fresh baked goods daily at {BUSINESS}.",
            "Sweets and pastries with a special taste at {BUSINESS}.",
            "The smell of fresh bread at {BUSINESS}.",
            "Great options for hosting at {BUSINESS}.",
            "Visit {BUSINESS} in the morning.",
            "{BUSINESS} — quality in every bite.",
            "Family-friendly bakery options at {BUSINESS}.",
            "Questions? {PHONE}.",
            "Address: {ADDRESS}."
        ]

        let cafeAR = [
            "{BUSINESS} — كافيه في {CITYSTATE}.",
            "قهوة طيبة وأجواء هادئة في {BUSINESS}.",
            "جلسات لطيفة مع مشروبات ساخنة في {BUSINESS}.",
            "مكان مناسب للعمل والدراسة في {BUSINESS}.",
            "مشروبات متنوعة وخدمة جميلة في {BUSINESS}.",
            "استمتعوا بوقتكم في {BUSINESS}.",
            "{BUSINESS} قريب منكم في {CITYSTATE}.",
            "زورونا اليوم في {BUSINESS}.",
            "للاستفسار: {PHONE}.",
            "عنواننا: {ADDRESS}."
        ]
        let cafeEN = [
            "{BUSINESS} — cafe in {CITYSTATE}.",
            "Great coffee and calm vibes at {BUSINESS}.",
            "A cozy spot for warm drinks at {BUSINESS}.",
            "Perfect for work or study — {BUSINESS}.",
            "Variety of drinks and friendly service at {BUSINESS}.",
            "Enjoy your time at {BUSINESS}.",
            "{BUSINESS} near you in {CITYSTATE}.",
            "Stop by {BUSINESS} today.",
            "Contact: {PHONE}.",
            "Address: {ADDRESS}."
        ]

        let foodTruckAR = [
            "{BUSINESS} — فود ترك في {CITYSTATE}.",
            "أكل سريع حلال وطعم قوي في {BUSINESS}.",
            "وجبات جاهزة بسرعة وجودة في {BUSINESS}.",
            "خيار ممتاز أثناء المشاوير: {BUSINESS}.",
            "زوروا {BUSINESS} لتجربة مختلفة.",
            "{BUSINESS} يقدم خيارات لذيذة يوميًا.",
            "خدمة سريعة وأكل حلال في {BUSINESS}.",
            "{BUSINESS} موجود في {CITYSTATE}.",
            "للطلب: {PHONE}.",
            "تعالوا زورونا اليوم!"
        ]
        let foodTruckEN = [
            "{BUSINESS} — food truck in {CITYSTATE}.",
            "Fast halal bites with big flavor at {BUSINESS}.",
            "Quick meals and quality at {BUSINESS}.",
            "A great stop while you’re out — {BUSINESS}.",
            "Try something different at {BUSINESS}.",
            "{BUSINESS} serves tasty options daily.",
            "Fast service and halal food at {BUSINESS}.",
            "{BUSINESS} in {CITYSTATE}.",
            "To order: {PHONE}.",
            "Come see us today!"
        ]

        let marketAR = [
            "{BUSINESS} — سوق في {CITYSTATE}.",
            "تشكيلة واسعة من المنتجات في {BUSINESS}.",
            "خدمة ممتازة وأسعار مناسبة في {BUSINESS}.",
            "كل احتياجات البيت في مكان واحد: {BUSINESS}.",
            "منتجات طازجة ومتنوعة في {BUSINESS}.",
            "{BUSINESS} خياركم للتسوق اليومي.",
            "زورونا في {BUSINESS} اليوم.",
            "تسوّق مريح وسريع في {BUSINESS}.",
            "للاستفسار: {PHONE}.",
            "عنواننا: {ADDRESS}."
        ]
        let marketEN = [
            "{BUSINESS} — market in {CITYSTATE}.",
            "Wide selection of products at {BUSINESS}.",
            "Great service and fair prices at {BUSINESS}.",
            "All your household needs in one place — {BUSINESS}.",
            "Fresh and diverse items at {BUSINESS}.",
            "{BUSINESS} for your daily shopping.",
            "Visit {BUSINESS} today.",
            "Easy and quick shopping at {BUSINESS}.",
            "Contact: {PHONE}.",
            "Address: {ADDRESS}."
        ]

        let otherAR = [
            "{BUSINESS} — خدمة مميزة في {CITYSTATE}.",
            "نرحب بكم في {BUSINESS}.",
            "جودة وخدمة محترمة في {BUSINESS}.",
            "{BUSINESS} قريب منكم في {CITYSTATE}.",
            "للتواصل: {PHONE}.",
            "زورونا: {ADDRESS}.",
            "خدمة سريعة ومريحة في {BUSINESS}.",
            "نفتخر بخدمة المجتمع في {BUSINESS}.",
            "أهلاً وسهلاً بكم في {BUSINESS}.",
            "نحن جاهزون لخدمتكم."
        ]
        let otherEN = [
            "{BUSINESS} — great service in {CITYSTATE}.",
            "Welcome to {BUSINESS}.",
            "Quality and respectful service at {BUSINESS}.",
            "{BUSINESS} near you in {CITYSTATE}.",
            "Contact: {PHONE}.",
            "Visit: {ADDRESS}.",
            "Fast and convenient service at {BUSINESS}.",
            "Proud to serve the community — {BUSINESS}.",
            "We’re happy to welcome you at {BUSINESS}.",
            "We’re ready to help."
        ]

        let baseList: [String] = {
            switch type {
            case .restaurant: return base(restaurantAR, restaurantEN)
            case .grocery: return base(groceryAR, groceryEN)
            case .butcher: return base(butcherAR, butcherEN)
            case .deli: return base(deliAR, deliEN)
            case .bakery: return base(bakeryAR, bakeryEN)
            case .cafe: return base(cafeAR, cafeEN)
            case .foodTruck: return base(foodTruckAR, foodTruckEN)
            case .market: return base(marketAR, marketEN)
            case .other: return base(otherAR, otherEN)
            }
        }()

        // ✅ 15 templates = “Style layer” فوق الـ baseList
        switch template {
        case .simple:
            return baseList

        case .halalFocused:
            return baseList.map { s in isArabic ? "✅ حلال | \(s) للتواصل: {PHONE}." : "✅ Halal | \(s) Contact: {PHONE}." }

        case .familyFriendly:
            return baseList.map { s in isArabic ? "👨‍👩‍👧‍👦 مناسب للعائلة | \(s)" : "👨‍👩‍👧‍👦 Family-friendly | \(s)" }

        case .newOpening:
            return baseList.map { s in isArabic ? "🎉 افتتاح جديد | \(s) زورونا: {ADDRESS}." : "🎉 New opening | \(s) Visit: {ADDRESS}." }

        case .communitySupport:
            return baseList.map { s in isArabic ? "🤝 دعم المجتمع | \(s)" : "🤝 Community support | \(s)" }

        case .popular:
            return baseList.map { s in isArabic ? "⭐ مكان مميز | \(s)" : "⭐ Popular spot | \(s)" }

        case .deliveryOrCall:
            return baseList.map { s in isArabic ? "📞 اتصال/توصيل | \(s) هاتف: {PHONE}." : "📞 Call/Delivery | \(s) Phone: {PHONE}." }

        case .locationHighlight:
            return baseList.map { s in isArabic ? "📍 موقع مميز | \(s) العنوان: {ADDRESS}." : "📍 Great location | \(s) Address: {ADDRESS}." }

        case .bestTimeToVisit:
            return baseList.map { s in isArabic ? "⏰ أفضل وقت للزيارة | \(s)" : "⏰ Best time to visit | \(s)" }

        case .specialOfferStyle:
            return baseList.map { s in isArabic ? "🎁 ميزة/عرض | \(s)" : "🎁 Special feature | \(s)" }

        case .fridaySpecial:
            return baseList.map { s in isArabic ? "🕌/🍽️ الجمعة | \(s)" : "🕌/🍽️ Friday highlight | \(s)" }

        case .weekend:
            return baseList.map { s in isArabic ? "🌙 الويكند | \(s)" : "🌙 Weekend | \(s)" }

        case .easyParking:
            return baseList.map { s in isArabic ? "🅿️ مواقف سهلة | \(s)" : "🅿️ Easy parking | \(s)" }

        case .accessible:
            return baseList.map { s in isArabic ? "♿ سهولة الوصول | \(s)" : "♿ Accessible | \(s)" }

        case .contactNow:
            return baseList.map { s in isArabic ? "📲 تواصل الآن | \(s) رقم: {PHONE}." : "📲 Contact now | \(s) Phone: {PHONE}." }
        }
    }
}
