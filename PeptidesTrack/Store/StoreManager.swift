import StoreKit
import SwiftUI

// MARK: - StoreManager

@MainActor
final class StoreManager: ObservableObject {

    static let productID = "com.peptidestrack.app.pro.monthly"

    // MARK: - Published State

    @Published var isPro: Bool = false
    @Published var isInTrial: Bool = false
    @Published var trialDaysRemaining: Int = 0
    @Published var proProduct: Product? = nil
    @Published var isPurchasing: Bool = false
    @Published var purchaseError: String? = nil

    // Free tier limits
    static let freePeptideLimit = 1
    static let freeDoseLimit = 5

    // MARK: - Init

    init() {
        Task { await checkSubscriptionStatus() }
        Task { await listenForTransactions() }
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [StoreManager.productID])
            proProduct = products.first
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    // MARK: - Purchase

    func purchase() async {
        guard let product = proProduct else { return }
        isPurchasing = true
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await checkSubscriptionStatus()
                }
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
        isPurchasing = false
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        isPurchasing = true
        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
        } catch {
            purchaseError = error.localizedDescription
        }
        isPurchasing = false
    }

    // MARK: - Check Subscription Status

    func checkSubscriptionStatus() async {
        var foundActive = false
        var foundTrial = false
        var daysLeft = 0

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == StoreManager.productID,
               transaction.revocationDate == nil {
                foundActive = true

                // Detect introductory offer (trial) — offerType is the correct StoreKit 2 API
                if transaction.offerType == .introductoryOffer {
                    foundTrial = true
                    if let expirationDate = transaction.expirationDate {
                        daysLeft = max(0, Calendar.current.dateComponents(
                            [.day], from: Date(), to: expirationDate
                        ).day ?? 0)
                    }
                }
            }
        }

        isPro = foundActive
        isInTrial = foundTrial
        trialDaysRemaining = daysLeft
    }

    // MARK: - Listen for Transactions

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                await transaction.finish()
                await checkSubscriptionStatus()
            }
        }
    }
}
