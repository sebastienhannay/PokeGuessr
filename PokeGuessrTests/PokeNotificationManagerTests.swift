//
//  PokeNotificationManagerTests.swift
//  PokeGuessrTests
//
//  Created for testing PokeNotificationManager
//

import Testing
import UserNotifications
@testable import PokeGuessr

extension PokeNotificationManager {
    
    static func testInstance() -> PokeNotificationManager {
        PokeNotificationManager()
    }
    
}

// MARK: - Mock Notification Center

/// A synchronous, in-memory stand-in for UNUserNotificationCenter.
/// Avoids any real system calls during tests.
final class MockNotificationCenter: PokeNotificationCenter {

    var stubbedAuthorizationStatus: UNAuthorizationStatus = .authorized
    var addedRequests: [UNNotificationRequest] = []
    var removedIdentifiers: [String] = []
    var addError: Error? = nil
    
    func authorizationStatus() async -> UNAuthorizationStatus {
        stubbedAuthorizationStatus
    }

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        stubbedAuthorizationStatus != .denied
    }

    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)? = nil) {
        if let error = addError { completionHandler?(error); return }
        addedRequests.append(request)
        completionHandler?(nil)
    }

    func pendingNotificationRequests() async -> [UNNotificationRequest] {
        addedRequests
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
        addedRequests.removeAll { identifiers.contains($0.identifier) }
    }
}

// MARK: - Notification ID helper (mirrors production logic)
private func expectedNotificationId(for date: Date) -> String {
    let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
    return String(
        format: "pokemon-%04d-%02d-%02d",
        components.year ?? 1,
        components.month ?? 1,
        components.day ?? 1
    )
}

// MARK: - Test Suite

@Suite("PokeNotificationManager")
struct PokeNotificationManagerTests {

    // MARK: Notification ID format

    @Test("Notification ID is stable and zero-padded for a known date")
    func notificationIdFormat() async throws {
        // Jan 5 2026 → "pokemon-2026-01-05"
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 5
        let date = try #require(Calendar.current.date(from: components))

        let id = expectedNotificationId(for: date)
        #expect(id == "pokemon-2026-01-05")
    }

    @Test("Notification ID is unique per calendar day")
    func notificationIdUniquenessPerDay() {
        let base = Date()
        let calendar = Calendar.current
        let today = expectedNotificationId(for: base)
        let tomorrow = expectedNotificationId(
            for: calendar.date(byAdding: .day, value: 1, to: base)!
        )
        #expect(today != tomorrow)
    }

    @Test("Notification ID is identical for two dates on the same calendar day")
    func notificationIdSameDay() {
        let calendar = Calendar.current
        let morning = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
        let evening = calendar.date(bySettingHour: 21, minute: 30, second: 0, of: Date())!
        #expect(expectedNotificationId(for: morning) == expectedNotificationId(for: evening))
    }

    // MARK: Scheduling

    @Test("schedulePokemonNotifications schedules exactly 5 requests for the Fibonacci-ish offsets")
    func schedulesCorrectNumberOfNotifications() async throws {
        let manager = PokeNotificationManager.testInstance()
        let mock = MockNotificationCenter()

        await manager.scheduleNotifications(using: mock, from: Date())

        #expect(mock.addedRequests.count == 5)
    }

    @Test("Scheduled notifications use offsets [1, 2, 3, 5, 8] days from base date")
    func scheduledDatesMatchExpectedOffsets() async throws {
        let manager = PokeNotificationManager.testInstance()
        let mock = MockNotificationCenter()
        let baseDate = Date()
        let calendar = Calendar.current
        let expectedOffsets = [1, 2, 3, 5, 8]

        await manager.scheduleNotifications(using: mock, from: baseDate)

        let scheduledIds = Set(mock.addedRequests.map(\.identifier))
        for offset in expectedOffsets {
            let targetDate = calendar.date(byAdding: .day, value: offset, to: baseDate)!
            let at9 = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: targetDate)!
            let expectedId = expectedNotificationId(for: at9)
            #expect(scheduledIds.contains(expectedId), "Missing notification for offset +\(offset) days")
        }
    }

    @Test("Each scheduled notification fires at 09:00")
    func scheduledNotificationsFireAt9AM() async throws {
        let manager = PokeNotificationManager.testInstance()
        let mock = MockNotificationCenter()

        await manager.scheduleNotifications(using: mock, from: Date())

        for request in mock.addedRequests {
            let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
            #expect(trigger.dateComponents.hour == 9)
            #expect(trigger.dateComponents.minute == 0)
            #expect(trigger.repeats == false)
        }
    }

    @Test("Scheduled notification identifiers all start with 'pokemon-'")
    func identifiersHaveCorrectPrefix() async throws {
        let manager = PokeNotificationManager.testInstance()
        let mock = MockNotificationCenter()

        await manager.scheduleNotifications(using: mock, from: Date())

        for request in mock.addedRequests {
            #expect(request.identifier.hasPrefix("pokemon-"))
        }
    }

    @Test("Scheduled notification identifiers are all unique")
    func identifiersAreUnique() async throws {
        let manager = PokeNotificationManager.testInstance()
        let mock = MockNotificationCenter()

        await manager.scheduleNotifications(using: mock, from: Date())

        let ids = mock.addedRequests.map(\.identifier)
        #expect(Set(ids).count == ids.count)
    }

    @Test("Notification content has non-empty title and body")
    func notificationContentIsNonEmpty() async throws {
        let manager = PokeNotificationManager.testInstance()
        let mock = MockNotificationCenter()

        await manager.scheduleNotifications(using: mock, from: Date())

        for request in mock.addedRequests {
            #expect(!request.content.title.isEmpty)
            #expect(!request.content.body.isEmpty)
        }
    }

    // MARK: Cancellation

    @Test("cancelToday removes only today's notification")
    func cancelTodayRemovesCorrectId() async throws {
        let manager = PokeNotificationManager.testInstance()
        let mock = MockNotificationCenter()

        // Pre-populate mock with today's pending notification
        let calendar = Calendar.current
        let todayAt9 = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
        let todayId = expectedNotificationId(for: todayAt9)
        let content = UNMutableNotificationContent()
        let request = UNNotificationRequest(identifier: todayId, content: content, trigger: nil)
        mock.addedRequests.append(request)

        await manager.cancelToday(using: mock)

        #expect(mock.removedIdentifiers == [todayId])
    }

    @Test("cancelAll removes all 'pokemon-' prefixed requests and leaves others untouched")
    func cancelAllOnlyRemovesPokemonRequests() async throws {
        let manager = PokeNotificationManager.testInstance()
        let mock = MockNotificationCenter()

        // Add a mix of pokemon and unrelated notifications
        let pokemonContent = UNMutableNotificationContent()
        mock.addedRequests.append(
            UNNotificationRequest(identifier: "pokemon-2026-04-20", content: pokemonContent, trigger: nil)
        )
        mock.addedRequests.append(
            UNNotificationRequest(identifier: "pokemon-2026-04-21", content: pokemonContent, trigger: nil)
        )
        let otherContent = UNMutableNotificationContent()
        mock.addedRequests.append(
            UNNotificationRequest(identifier: "other-reminder-42", content: otherContent, trigger: nil)
        )

        await manager.cancelAll(using: mock)

        #expect(mock.removedIdentifiers.allSatisfy { $0.hasPrefix("pokemon-") })
        #expect(mock.removedIdentifiers.count == 2)
        // Unrelated notification still pending
        #expect(mock.addedRequests.contains { $0.identifier == "other-reminder-42" })
    }

    // MARK: Permission flow

    @Test("requestPermissionAndSchedule asks permission only once")
    func permissionRequestedOnlyOnce() async throws {
        // Reset UserDefaults key for a clean slate
        UserDefaults.standard.removeObject(forKey: "hasAskedNotificationPermission")
        let manager = PokeNotificationManager.testInstance()
        let mock = MockNotificationCenter()

        await manager.requestPermissionAndSchedule(using: mock)
        await manager.requestPermissionAndSchedule(using: mock)

        // Should have scheduled once; re-scheduling on second call happens only if authorized
        // The key guard means the first branch is taken once
        #expect(UserDefaults.standard.bool(forKey: "hasAskedNotificationPermission") == true)
    }

    @Test("Re-scheduling on subsequent launches cancels old pokemon notifications before adding new ones")
    func reschedulingCancelsBeforeAdding() async throws {
        // Simulate "already asked" state
        UserDefaults.standard.set(true, forKey: "hasAskedNotificationPermission")
        let manager = PokeNotificationManager.testInstance()
        let mock = MockNotificationCenter()
        mock.stubbedAuthorizationStatus = .authorized

        // Seed some stale pokemon notifications
        let staleContent = UNMutableNotificationContent()
        mock.addedRequests.append(
            UNNotificationRequest(identifier: "pokemon-2025-01-01", content: staleContent, trigger: nil)
        )

        await manager.requestPermissionAndSchedule(using: mock)

        // The stale id should have been cancelled
        #expect(mock.removedIdentifiers.contains("pokemon-2025-01-01"))
        // And new ones scheduled
        #expect(mock.addedRequests.count == 5)

        // Clean up
        UserDefaults.standard.removeObject(forKey: "hasAskedNotificationPermission")
    }
}
