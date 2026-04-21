//
//  PokeNotificationManager.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 17/04/2026.
//

import UserNotifications
import SwiftUI

protocol PokeNotificationCenter {
    func authorizationStatus() async -> UNAuthorizationStatus
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    @MainActor func add(_ request: UNNotificationRequest, withCompletionHandler: (@Sendable (Error?) -> Void)?)
    func pendingNotificationRequests() async -> [UNNotificationRequest]
    @MainActor func removePendingNotificationRequests(withIdentifiers: [String])
}

extension UNUserNotificationCenter: PokeNotificationCenter {
    
    func authorizationStatus() async -> UNAuthorizationStatus {
        await self.notificationSettings().authorizationStatus
    }
}

actor PokeNotificationManager {
    
    static var shared = PokeNotificationManager()
    
    private let titles = [
        String(localized: "pokemon.notification.title.1"),
        String(localized: "pokemon.notification.title.2")
    ]
    
    private let bodies = [
        String(localized: "pokemon.notification.body.1"),
        String(localized: "pokemon.notification.body.2")
    ]
    
    private var hasAskedNotificationPermission: Bool {
        get { UserDefaults.standard.bool(forKey: "hasAskedNotificationPermission") }
        set { UserDefaults.standard.set(newValue, forKey: "hasAskedNotificationPermission") }
    }
    
    private func isAuthorized(using center: any PokeNotificationCenter) async -> Bool {
        await center.authorizationStatus() == .authorized
    }
    
    private func notificationId(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        let identifier = String(
            format: "pokemon-%04d-%02d-%02d",
            components.year ?? 1,
            components.month ?? 1,
            components.day ?? 1
        )
        
        return identifier
    }
    
    func requestPermissionAndSchedule(
        using center: PokeNotificationCenter = UNUserNotificationCenter.current(),
        from base: Date = Date()
    ) async {
        if !hasAskedNotificationPermission {
            hasAskedNotificationPermission = true
            
            let granted = await requestNotificationPermission()
            if granted {
                await scheduleNotifications(using: center, from: base)
            }
        } else {
            if await isAuthorized(using: center) {
                await cancelAll(using: center)
                await scheduleNotifications(using: center, from: base)
            }
        }
    }
    
    private func requestNotificationPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Permission error: \(error)")
            return false
        }
    }

    func scheduleNotifications(
        using center: PokeNotificationCenter = UNUserNotificationCenter.current(),
        from base: Date = Date()
    ) async {
        let calendar = Calendar.current
        
        let dayOffsets = [1, 2, 3, 5, 8]
        
        for offset in dayOffsets {
            guard let targetDate = calendar.date(byAdding: .day, value: offset, to: base),
                  let finalDate = calendar.date(
                      bySettingHour: 9,
                      minute: 0,
                      second: 0,
                      of: targetDate
                  )
            else { continue }
            
            let components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: finalDate
            )
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )
            
            let content = UNMutableNotificationContent()
            content.title = titles.randomElement()!
            content.body = bodies.randomElement()!
            content.sound = .default
            
            let identifier = notificationId(for: finalDate)
            
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            await center.add(request) { error in
                if let error {
                    print("Notification scheduling error: \(error)")
                }
            }
        }
    }

    func cancelToday(using center: PokeNotificationCenter = UNUserNotificationCenter.current()) async {
        let calendar = Calendar.current
        
        guard let todayAt9 = calendar.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: Date()
        ) else { return }
        
        let id = notificationId(for: todayAt9)
        
        await center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func cancelAll(using center: PokeNotificationCenter = UNUserNotificationCenter.current()) async {
        let requests = await center.pendingNotificationRequests()
        let ids = requests
            .filter { $0.identifier.starts(with: "pokemon-") }
            .map(\.identifier)
        
        await center.removePendingNotificationRequests(withIdentifiers: ids)
    }
}
