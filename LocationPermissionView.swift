//
//  LocationPermissionView.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 12/24/25.
//

import SwiftUI
import CoreLocation

struct LocationPermissionView: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var location: LocationManager

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            Image(systemName: "location.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text(L("نحتاج موقعك", "We need your location"))
                .font(.title2.bold())

            Text(L(
                "نستخدم موقعك فقط لعرض الأماكن والوظائف القريبة منك ضمن 5 أميال.",
                "We use your location only to show nearby places & jobs within 5 miles."
            ))
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            Button {
                location.requestPermission()
            } label: {
                Text(L("السماح بالموقع", "Allow Location"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.92))
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal)

            if location.authorization == .denied || location.authorization == .restricted {
                Text(L(
                    "تم رفض الموقع. يمكنك تفعيله من الإعدادات: Settings → Privacy → Location.",
                    "Location is denied. Enable it from Settings → Privacy → Location."
                ))
                .font(.footnote)
                .foregroundColor(.orange)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
    }
}
