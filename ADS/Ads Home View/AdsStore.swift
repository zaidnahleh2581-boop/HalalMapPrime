//
//  AdsStore.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Updated by Zaid Nahleh on 2026-01-08.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//
import Foundation
import Combine          // ✅ هذا هو المفتاح
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AdsStore: ObservableObject {
    
    // ✅ Public feed + My ads
    @Published var publicAds: [HMPAd] = []
    @Published var myAds: [HMPAd] = []
    
    @Published var isLoading: Bool = false
    @Published var lastError: String? = nil
    
    // Optional profile snapshot
    @Published var profileBusinessName: String? = nil
    @Published var profilePhone: String? = nil
    
    private let db = Firestore.firestore()
    
    // Local free gift flag (مرحلة أولى)
    private let freeGiftKey = "HMP_freeGiftUsed_v1"
    
    // MARK: - Computed (Public)
    var activePublicAds: [HMPAd] {
        let active = publicAds.filter { $0.isActive }
        return active.sorted { a, b in
            let pa = planRank(a.plan)
            let pb = planRank(b.plan)
            if pa != pb { return pa < pb }
            return a.createdAt > b.createdAt
        }
    }
    
    // MARK: - Computed (My)
    var activeMyAds: [HMPAd] {
        let active = myAds.filter { $0.isActive }
        return active.sorted { a, b in
            let pa = planRank(a.plan)
            let pb = planRank(b.plan)
            if pa != pb { return pa < pb }
            return a.createdAt > b.createdAt
        }
    }
    
    var expiredMyAds: [HMPAd] {
        myAds.filter { !$0.isActive }.sorted { $0.expiresAt > $1.expiresAt }
    }
    
    private func planRank(_ p: HMPAdPlanKind) -> Int {
        switch p {
        case .prime: return 0
        case .monthly: return 1
        case .weekly: return 2
        case .freeOnce: return 3
        }
    }
    
    // MARK: - Free Gift (Local flag for now)
    var canUseFreeGift: Bool {
        !UserDefaults.standard.bool(forKey: freeGiftKey)
    }
    
    func markFreeGiftUsed() {
        UserDefaults.standard.set(true, forKey: freeGiftKey)
    }
    
    // MARK: - Compatibility API (keep your calls working)
    /// Old code calls adsStore.load() — keep it, but now it loads PUBLIC + MY from Firestore
    func load() {
        Task {
            await loadPublic()
            await loadMyAds()
        }
    }
    
    /// Old code calls adsStore.createAdFromDraft(...) — keep it, but now it writes to Firestore
    func createAdFromDraft(draft: AdDraft, plan: HMPAdPlanKind) {
        Task { await createAdFromDraftAsync(draft: draft, plan: plan) }
    }
    
    // MARK: - Firestore Loads
    func loadPublic() async {
        lastError = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await ensureUID()
            
            let snap = try await db.collection("ads")
                .whereField("expiresAt", isGreaterThan: Timestamp(date: Date()))
                .order(by: "expiresAt", descending: false)
                .limit(to: 200)
                .getDocuments()
            
            self.publicAds = snap.documents.compactMap { decodeAd($0) }
        } catch {
            self.lastError = error.localizedDescription
        }
    }
    
    func loadMyAds() async {
        lastError = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            let uid = try await ensureUID()
            
            let snap = try await db.collection("ads")
                .whereField("ownerId", isEqualTo: uid)   // ✅ matches your rules
                .order(by: "createdAt", descending: true)
                .limit(to: 200)
                .getDocuments()
            
            self.myAds = snap.documents.compactMap { decodeAd($0) }
            
            self.profileBusinessName = self.myAds.first?.businessName
            self.profilePhone = self.myAds.first?.phone
        } catch {
            self.lastError = error.localizedDescription
        }
    }
    
    // MARK: - Firestore Create
    private func createAdFromDraftAsync(draft: AdDraft, plan: HMPAdPlanKind) async {
        lastError = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            let uid = try await ensureUID()
            let now = Date()
            let expires = Calendar.current.date(byAdding: .day, value: plan.durationDays, to: now) ?? now
            
            let ref = db.collection("ads").document()
            
            // ✅ MUST satisfy your rules: ownerId + createdAt timestamp
            let data: [String: Any] = [
                "id": ref.documentID,
                
                "ownerId": uid,
                "ownerKey": uid, // keep for your model
                
                "plan": plan.rawValue,
                "isFeatured": plan.isFeatured,
                "audience": audienceKey(from: draft.selectedAudience),
                
                "businessName": draft.businessName,
                "headline": draft.headline,
                "adText": draft.adText,
                
                "phone": draft.phone,
                "website": draft.website,
                "addressHint": draft.addressHint,
                
                "imageBase64s": draft.imageBase64s,
                
                "createdAt": Timestamp(date: now),
                "expiresAt": Timestamp(date: expires)
            ]
            
            try await ref.setData(data, merge: false)
            
            // refresh lists
            await loadPublic()
            await loadMyAds()
        } catch {
            self.lastError = error.localizedDescription
        }
    }
    
    private func audienceKey(from a: AdAudience) -> String {
        switch a {
        case .restaurants: return "restaurants"
        case .mosques:     return "mosques"
        case .shops:       return "shops"
        case .schools:     return "schools"
        }
    }
    
    // MARK: - Auth
    private func ensureUID() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid { return uid }
        
        return try await withCheckedThrowingContinuation { cont in
            Auth.auth().signInAnonymously { result, error in
                if let error { cont.resume(throwing: error); return }
                guard let uid = result?.user.uid else {
                    cont.resume(throwing: NSError(domain: "Auth", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Missing UID"
                    ]))
                    return
                }
                cont.resume(returning: uid)
            }
        }
    }
    
    // MARK: - Decode
    private func decodeAd(_ doc: QueryDocumentSnapshot) -> HMPAd? {
        let d = doc.data()
        let id = (d["id"] as? String) ?? doc.documentID
        
        // ✅ REQUIRED fields only
        guard
            let ownerKey = (d["ownerKey"] as? String) ?? (d["ownerId"] as? String),
            let planRaw = d["plan"] as? String,
            let plan = HMPAdPlanKind(rawValue: planRaw),
            let isFeatured = d["isFeatured"] as? Bool,
            let audience = d["audience"] as? String,
            let businessName = d["businessName"] as? String,
            let headline = d["headline"] as? String,
            let adText = d["adText"] as? String,
            let createdAtTS = d["createdAt"] as? Timestamp,
            let expiresAtTS = d["expiresAt"] as? Timestamp
        else {
            return nil
        }
        
        // ✅ OPTIONAL fields (safe defaults)
        let phone = (d["phone"] as? String) ?? ""
        let website = (d["website"] as? String) ?? ""
        let addressHint = (d["addressHint"] as? String) ?? ""
        let imageBase64s = (d["imageBase64s"] as? [String]) ?? []
        
        return HMPAd(
            id: id,
            ownerKey: ownerKey,
            plan: plan,
            isFeatured: isFeatured,
            audience: audience,
            businessName: businessName,
            headline: headline,
            adText: adText,
            phone: phone,
            website: website,
            addressHint: addressHint,
            imageBase64s: imageBase64s,
            createdAt: createdAtTS.dateValue(),
            expiresAt: expiresAtTS.dateValue()
        )
    }
}
