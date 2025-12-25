//
//  WhatsAppHelper.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/12/25.
//  Copyright © 2025 Zaid Nahleh. All rights reserved.
//

import Foundation
import UIKit

enum WhatsAppHelper {

    /// ضع رقم واتساب الخاص بك هنا بصيغة دولية بدون + وبدون مسافات
    /// مثال نيويورك: 12125551234
    static let adminPhoneNumber: String = "6319475782"

    /// رسالة جاهزة للتحقق — آمنة وما بتعمل كراش حتى لو في نص عربي/إيموجي
    static func openVerifyChat(placeName: String,
                               categoryName: String,
                               addressLine: String) {

        // 1) تأكيد الرقم صحيح (بدون + / مسافات)
        let phone = sanitizePhone(adminPhoneNumber)
        guard !phone.isEmpty else {
            print("❌ WhatsAppHelper: adminPhoneNumber is empty/invalid.")
            return
        }

        // 2) نص الرسالة (يمكن عربي/إنجليزي عادي)
        let message = """
        Hi, I want to verify a place on Halal Map Prime.

        Name: \(placeName)
        Category: \(categoryName)
        Address: \(addressLine)

        I will send the required documents now.
        """

        // 3) Encoding للنص عشان ما يعطي Safari invalid
        guard let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ WhatsAppHelper: failed to encode message.")
            return
        }

        // 4) رابط wa.me الصحيح
        let urlString = "https://wa.me/\(phone)?text=\(encoded)"
        guard let url = URL(string: urlString) else {
            print("❌ WhatsAppHelper: invalid URL string.")
            return
        }

        // 5) فتح الرابط بأمان (بدون كراش)
        DispatchQueue.main.async {
            let app = UIApplication.shared
            if app.canOpenURL(url) {
                app.open(url, options: [:], completionHandler: nil)
            } else {
                // fallback: افتح صفحة المتصفح لنفس الرابط
                app.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    // MARK: - Private

    private static func sanitizePhone(_ number: String) -> String {
        // يشيل + والمسافات وأي شيء غير أرقام
        let digits = number.filter { $0.isNumber }
        return digits
    }
}
