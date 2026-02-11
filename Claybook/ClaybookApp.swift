import Foundation
import SwiftData
import SwiftUI

@main
struct ClaybookApp: App {
    let modelContainer: ModelContainer
    @State private var showDataRecoveryAlert = false

    init() {
        let result = StoreRecoveryService.openStore()
        switch result {
        case .healthy(let container):
            modelContainer = container
        case .recoveredFromBackup(let container):
            modelContainer = container
            // Defer alert to after SwiftUI is ready
            _showDataRecoveryAlert = State(initialValue: true)
        case .failed(let error):
            fatalError("Claybook: unrecoverable store failure — \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(showDataRecoveryAlert: $showDataRecoveryAlert)
        }
        .modelContainer(modelContainer)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allSettings: [UserSettings]
    @Binding var showDataRecoveryAlert: Bool

    private var colorScheme: ColorScheme? {
        allSettings.first?.appearanceMode.colorScheme
    }

    var body: some View {
        LibraryView()
            .preferredColorScheme(colorScheme)
            .onAppear {
                let settings = modelContext.fetchOrCreateSettings()
                PotteryReminderService.syncWeekendReminder(enabled: settings.weekendReminderEnabled)
            }
            .alert("Data Recovery", isPresented: $showDataRecoveryAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your data file could not be opened and has been backed up. Your pottery data may need to be restored — please contact support.")
            }
    }
}
