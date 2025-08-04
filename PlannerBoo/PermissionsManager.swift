import Foundation
import EventKit
import Photos

@MainActor
class PermissionsManager: ObservableObject {
    @Published var calendarAccess = false
    @Published var remindersAccess = false
    @Published var healthAccess = false
    @Published var photosAccess = false
    
    private let eventStore = EKEventStore()
    
    init() {
        // Don't check permissions immediately to avoid crashes
        // checkPermissions()
    }
    
    func checkPermissions() {
        // Temporarily disable to avoid crashes
        // checkCalendarAccess()
        // checkRemindersAccess()
        // checkHealthAccess()
        checkPhotosAccess()
    }
    
    func requestAllPermissions() {
        Task {
            // Temporarily disable calendar and reminders to avoid crashes
            // await requestCalendarAccess()
            // await requestRemindersAccess()
            // Skip health access for now due to Info.plist requirements
            // await requestHealthAccess()
            await requestPhotosAccess()
        }
    }
    
    // MARK: - Calendar Permissions
    
    private func checkCalendarAccess() {
        // Temporarily disabled to avoid crashes
        calendarAccess = false
        /*
        Task { @MainActor in
            calendarAccess = EKEventStore.authorizationStatus(for: .event) == .fullAccess
        }
        */
    }
    
    func requestCalendarAccess() async {
        // Temporarily disabled to avoid crashes
        return
        /*
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            await MainActor.run {
                calendarAccess = granted
            }
        } catch {
            print("Calendar access request failed: \(error)")
        }
        */
    }
    
    // MARK: - Reminders Permissions
    
    private func checkRemindersAccess() {
        // Temporarily disabled to avoid crashes
        remindersAccess = false
        /*
        Task { @MainActor in
            remindersAccess = EKEventStore.authorizationStatus(for: .reminder) == .fullAccess
        }
        */
    }
    
    func requestRemindersAccess() async {
        // Temporarily disabled to avoid crashes
        return
        /*
        do {
            let granted = try await eventStore.requestFullAccessToReminders()
            await MainActor.run {
                remindersAccess = granted
            }
        } catch {
            print("Reminders access request failed: \(error)")
        }
        */
    }
    
    // MARK: - Health Permissions
    
    private func checkHealthAccess() {
        // Temporarily disable health access to avoid Info.plist requirements
        healthAccess = false
        return
        
        /* 
        guard HKHealthStore.isHealthDataAvailable() else {
            healthAccess = false
            return
        }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let workoutType = HKObjectType.workoutType()
        
        let stepStatus = healthStore.authorizationStatus(for: stepType)
        let workoutStatus = healthStore.authorizationStatus(for: workoutType)
        
        healthAccess = stepStatus == .sharingAuthorized && workoutStatus == .sharingAuthorized
        */
    }
    
    func requestHealthAccess() async {
        // Temporarily disabled - requires Info.plist configuration
        return
        
        /*
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let workoutType = HKObjectType.workoutType()
        let readTypes: Set<HKObjectType> = [stepType, workoutType]
        
        do {
            try await healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: readTypes)
            await MainActor.run {
                checkHealthAccess()
            }
        } catch {
            print("Health access request failed: \(error)")
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