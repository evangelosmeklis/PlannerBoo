import Foundation
import EventKit
import Photos
import HealthKit

@MainActor
class PermissionsManager: ObservableObject {
    @Published var calendarAccess = false
    @Published var remindersAccess = false
    @Published var healthAccess = false
    @Published var photosAccess = false
    
    private let eventStore = EKEventStore()
    private let healthStore = HKHealthStore()
    
    init() {
        // Don't check permissions immediately to avoid crashes
        // checkPermissions()
    }
    
    func checkPermissions() {
        checkCalendarAccess()
        checkRemindersAccess()
        checkPhotosAccess()
        checkHealthAccess()
    }
    
    func requestAllPermissions() {
        Task {
            await requestCalendarAccess()
            await requestRemindersAccess()
            await requestPhotosAccess()
            await requestHealthAccess()
        }
    }
    
    // MARK: - Calendar Permissions
    
    private func checkCalendarAccess() {
        Task { @MainActor in
            let status = EKEventStore.authorizationStatus(for: .event)
            calendarAccess = status == .fullAccess || status == .authorized
        }
    }
    
    func requestCalendarAccess() async {
        do {
            // Try the new iOS 17+ method first
            if #available(iOS 17.0, *) {
                let granted = try await eventStore.requestFullAccessToEvents()
                await MainActor.run {
                    calendarAccess = granted
                }
            } else {
                // Fallback for older iOS versions
                let granted = try await eventStore.requestAccess(to: .event)
                await MainActor.run {
                    calendarAccess = granted
                }
            }
        } catch {
            print("Calendar access request failed: \(error)")
            await MainActor.run {
                calendarAccess = false
            }
        }
    }
    
    // MARK: - Reminders Permissions
    
    private func checkRemindersAccess() {
        Task { @MainActor in
            let status = EKEventStore.authorizationStatus(for: .reminder)
            remindersAccess = status == .fullAccess || status == .authorized
        }
    }
    
    func requestRemindersAccess() async {
        do {
            // Try the new iOS 17+ method first
            if #available(iOS 17.0, *) {
                let granted = try await eventStore.requestFullAccessToReminders()
                await MainActor.run {
                    remindersAccess = granted
                }
            } else {
                // Fallback for older iOS versions
                let granted = try await eventStore.requestAccess(to: .reminder)
                await MainActor.run {
                    remindersAccess = granted
                }
            }
        } catch {
            print("Reminders access request failed: \(error)")
            await MainActor.run {
                remindersAccess = false
            }
        }
    }
    
    // MARK: - Health Permissions
    
    private func checkHealthAccess() {
        Task { @MainActor in
            guard HKHealthStore.isHealthDataAvailable() else {
                healthAccess = false
                return
            }
            
            guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
                healthAccess = false
                return
            }
            
            let workoutType = HKObjectType.workoutType()
            
            let stepStatus = healthStore.authorizationStatus(for: stepType)
            let workoutStatus = healthStore.authorizationStatus(for: workoutType)
            
            healthAccess = stepStatus == .sharingAuthorized && workoutStatus == .sharingAuthorized
        }
    }
    
    func requestHealthAccess() async {
        guard HKHealthStore.isHealthDataAvailable() else { 
            await MainActor.run {
                healthAccess = false
            }
            return 
        }
        
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            await MainActor.run {
                healthAccess = false
            }
            return
        }
        
        let workoutType = HKObjectType.workoutType()
        let readTypes: Set<HKObjectType> = [stepType, workoutType]
        
        do {
            try await healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: readTypes)
            await MainActor.run {
                checkHealthAccess()
            }
        } catch {
            print("Health access request failed: \(error)")
            await MainActor.run {
                healthAccess = false
            }
        }
    }
    
    // MARK: - Photos Permissions
    
    private func checkPhotosAccess() {
        Task { @MainActor in
            photosAccess = PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
        }
    }
    
    func requestPhotosAccess() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await MainActor.run {
            photosAccess = status == .authorized
        }
    }
}