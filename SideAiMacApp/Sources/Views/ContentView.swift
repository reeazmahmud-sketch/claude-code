import SwiftUI

struct ContentView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var selectedTab: Tab = .tasks
    
    enum Tab {
        case tasks, schedule, reminders
    }
    
    var body: some View {
        ZStack {
            // Main content
            NavigationSplitView {
                // Sidebar
                SidebarView(selectedTab: $selectedTab)
                    .frame(minWidth: 200)
            } detail: {
                // Detail view based on selected tab
                Group {
                    switch selectedTab {
                    case .tasks:
                        TasksView()
                    case .schedule:
                        ScheduleView()
                    case .reminders:
                        RemindersView()
                    }
                }
            }
            .navigationSplitViewStyle(.balanced)
            
            // Onboarding overlay
            if settingsManager.showOnboarding {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: settingsManager.showOnboarding)
    }
}

struct SidebarView: View {
    @Binding var selectedTab: ContentView.Tab
    
    var body: some View {
        List(selection: $selectedTab) {
            Section("Main") {
                Button(action: { selectedTab = .tasks }) {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(ContentView.Tab.tasks)
                
                Button(action: { selectedTab = .schedule }) {
                    Label("Schedule", systemImage: "calendar")
                }
                .tag(ContentView.Tab.schedule)
                
                Button(action: { selectedTab = .reminders }) {
                    Label("Reminders", systemImage: "bell")
                }
                .tag(ContentView.Tab.reminders)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("SideAi")
    }
}
