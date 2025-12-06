import Foundation

// MARK: - موديل وقت الصلاة

struct PrayerTime: Identifiable {
    let id = UUID()
    let name: String
    let time: String
}

// MARK: - مواقيت صلاة تجريبية لنيويورك

let demoPrayerTimesNY: [PrayerTime] = [
    PrayerTime(name: "الفجر",  time: "5:30 AM"),
    PrayerTime(name: "الظهر",  time: "12:15 PM"),
    PrayerTime(name: "العصر",  time: "3:45 PM"),
    PrayerTime(name: "المغرب", time: "4:40 PM"),
    PrayerTime(name: "العشاء", time: "6:10 PM")
]
