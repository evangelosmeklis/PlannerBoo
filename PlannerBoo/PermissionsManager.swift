import Foundation
import EventKit
import Photos
import HealthKit

enum PermissionType {
    case photos, calendar, reminders, health
}

@MainActor
class PermissionsManager: ObservableObject {
    @Published var calendarAccess = false
    @Published var remindersAccess = false
    @Published var healthAccess = false
    @Published var photosAccess = false
    
    private let eventStore = EKEventStore()
    private let healthStore = HKHealthStore()
    
    init() {
        // Check permissions after a brief delay to avoid crashes
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay
            await MainActor.run {
                checkPermissions()
            }
        }
    }
    
    func checkPermissions() {
        checkCalendarAccess()
        checkRemindersAccess()
        checkPhotosAccess()
        checkHealthAccess()
    }
    
    func requestAllPermissions() {
        Task {
            // Request permissions sequentially to avoid conflicts
            await requestPhotosAccess()
            await requestCalendarAccess()
            await requestRemindersAccess()
            await requestHealthAccess()
            
            // Check all permissions after requesting
            await MainActor.run {
                checkPermissions()
            }
        }
    }
    
    func requestIndividualPermission(for type: PermissionType) {
        Task {
            switch type {
            case .photos:
                await requestPhotosAccess()
            case .calendar:
                await requestCalendarAccess()
            case .reminders:
                await requestRemindersAccess()
            case .health:
                await requestHealthAccess()
            }
            
            // Check permissions after requesting
            await MainActor.run {
                checkPermissions()
            }
        }
    }
    
    // MARK: - Calendar Permissions
    
    private func checkCalendarAccess() {
        Task { @MainActor in
            let status = EKEventStore.authorizationStatus(for: .event)
            if #available(iOS 17.0, *) {
                calendarAccess = status == .fullAccess
            } else {
                calendarAccess = status == .authorized
            }
        }
    }
    
    func requestCalendarAccess() async {
        print("Requesting calendar access...")
        do {
            // Try the new iOS 17+ method first
            if #available(iOS 17.0, *) {
                let granted = try await eventStore.requestFullAccessToEvents()
                print("Calendar access granted: \(granted)")
                await MainActor.run {
                    calendarAccess = granted
                }
            } else {
                // Fallback for older iOS versions
                let granted = try await eventStore.requestAccess(to: .event)
                print("Calendar access granted (legacy): \(granted)")
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
            if #available(iOS 17.0, *) {
                remindersAccess = status == .fullAccess
            } else {
                remindersAccess = status == .authorized
            }
        }
    }
    
    func requestRemindersAccess() async {
        print("Requesting reminders access...")
        do {
            // Try the new iOS 17+ method first
            if #available(iOS 17.0, *) {
                let granted = try await eventStore.requestFullAccessToReminders()
                print("Reminders access granted: \(granted)")
                await MainActor.run {
                    remindersAccess = granted
                }
            } else {
                // Fallback for older iOS versions
                let granted = try await eventStore.requestAccess(to: .reminder)
                print("Reminders access granted (legacy): \(granted)")
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
        print("HealthKit temporarily disabled - entitlement required")
        await MainActor.run {
            healthAccess = false
        }
        return
        
        /*
        print("Requesting health access...")
        guard HKHealthStore.isHealthDataAvailable() else { 
            print("Health data not available on this device")
            await MainActor.run {
                healthAccess = false
            }
            return 
        }
        
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print("Step count type not available")
            await MainActor.run {
                healthAccess = false
            }
            return
        }
        
        let workoutType = HKObjectType.workoutType()
        let readTypes: Set<HKObjectType> = [stepType, workoutType]
        
        do {
            try await healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: readTypes)
            print("Health authorization request completed")
            await MainActor.run {
                checkHealthAccess()
            }
        } catch {
            print("Health access request failed: \(error)")
            await MainActor.run {
                healthAccess = false
            }
        }
        */
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