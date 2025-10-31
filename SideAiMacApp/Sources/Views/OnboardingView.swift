import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var currentPage = 0
    private let totalPages = 4
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)
                    
                    FeaturesPage()
                        .tag(1)
                    
                    NotificationsPage()
                        .tag(2)
                    
                    GetStartedPage()
                        .tag(3)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(width: 600, height: 500)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(16)
                .shadow(radius: 20)
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .keyboardShortcut(.cancelAction)
                    }
                    
                    Spacer()
                    
                    if currentPage < totalPages - 1 {
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .keyboardShortcut(.defaultAction)
                    } else {
                        Button("Get Started") {
                            settingsManager.completeOnboarding()
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
        }
    }
}

struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Welcome to SideAi")
                .font(.system(size: 36, weight: .bold))
            
            Text("Your personal productivity companion for macOS")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FeaturesPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Text("Powerful Features")
                .font(.system(size: 32, weight: .bold))
                .padding(.top, 40)
            
            VStack(spacing: 24) {
                FeatureRow(
                    icon: "checklist",
                    title: "Task Management",
                    description: "Organize your tasks with priorities, due dates, and tags"
                )
                
                FeatureRow(
                    icon: "calendar",
                    title: "Schedule Events",
                    description: "Keep track of your events with an integrated calendar"
                )
                
                FeatureRow(
                    icon: "bell",
                    title: "Smart Reminders",
                    description: "Never miss important deadlines with customizable reminders"
                )
                
                FeatureRow(
                    icon: "lock.shield",
                    title: "Secure Storage",
                    description: "Your data is encrypted and stored securely using macOS Keychain"
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.accentColor)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct NotificationsPage: View {
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "bell.badge")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Stay Notified")
                .font(.system(size: 32, weight: .bold))
            
            Text("Enable notifications to receive timely reminders about your tasks and events")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
            
            Button(action: {
                NotificationManager.requestAuthorization()
            }) {
                Label(
                    notificationManager.isAuthorized ? "Notifications Enabled" : "Enable Notifications",
                    systemImage: notificationManager.isAuthorized ? "checkmark.circle.fill" : "bell"
                )
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(notificationManager.isAuthorized)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct GetStartedPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("You're All Set!")
                .font(.system(size: 32, weight: .bold))
            
            VStack(alignment: .leading, spacing: 16) {
                TipRow(icon: "plus.circle", text: "Click + to add your first task")
                TipRow(icon: "calendar", text: "Use the Schedule tab to plan your events")
                TipRow(icon: "bell", text: "Set reminders so you never miss a deadline")
                TipRow(icon: "gearshape", text: "Customize settings to match your workflow")
            }
            .padding(.horizontal, 60)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}
