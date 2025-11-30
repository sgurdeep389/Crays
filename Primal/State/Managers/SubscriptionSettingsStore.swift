import Foundation

struct SubscriptionSettings: Codable {
    var monthlyPrice: Int
    var threeMonthDiscount: Int
    var sixMonthDiscount: Int
    var twelveMonthDiscount: Int
    var subscribersActive: Int
    var subscribersExpiringSoon: Int
    var subscribersLapsed: Int
    var earningsSubscriptions: Int
    var earningsPPV: Int
    var earningsTips: Int
    var earningsDMs: Int
    
    static let `default` = SubscriptionSettings(
        monthlyPrice: 10_000,
        threeMonthDiscount: 10,
        sixMonthDiscount: 15,
        twelveMonthDiscount: 25,
        subscribersActive: 120,
        subscribersExpiringSoon: 18,
        subscribersLapsed: 42,
        earningsSubscriptions: 1_200_000,
        earningsPPV: 350_000,
        earningsTips: 90_000,
        earningsDMs: 150_000
    )
    
    func discount(for months: Int) -> Int {
        switch months {
        case 3: return threeMonthDiscount
        case 6: return sixMonthDiscount
        case 12: return twelveMonthDiscount
        default: return 0
        }
    }
    
    func bundlePrice(for months: Int) -> Int {
        let discount = max(0, min(100, self.discount(for: months)))
        let base = monthlyPrice * months
        let discounted = Double(base) * (1 - Double(discount) / 100)
        return Int(discounted.rounded())
    }
    
    mutating func setDiscount(_ value: Int, for months: Int) {
        switch months {
        case 3: threeMonthDiscount = value
        case 6: sixMonthDiscount = value
        case 12: twelveMonthDiscount = value
        default: break
        }
    }
}

final class SubscriptionSettingsStore {
    static let shared = SubscriptionSettingsStore()
    
    private let defaults: UserDefaults
    private let key = "subscription_settings"
    
    private(set) var settings: SubscriptionSettings
    
    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if
            let data = defaults.data(forKey: key),
            let saved = try? JSONDecoder().decode(SubscriptionSettings.self, from: data)
        {
            settings = saved
        } else {
            settings = .default
        }
    }
    
    func update(_ block: (inout SubscriptionSettings) -> Void) {
        block(&settings)
        save()
    }
    
    private func save() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: key)
        NotificationCenter.default.post(name: .subscriptionSettingsUpdated, object: nil)
    }
}

extension Notification.Name {
    static let subscriptionSettingsUpdated = Notification.Name("subscriptionSettingsUpdated")
}

