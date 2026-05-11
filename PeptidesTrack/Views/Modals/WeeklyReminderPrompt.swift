import SwiftUI

// MARK: - WeeklyReminderPrompt

struct WeeklyReminderPrompt: View {

    let peptideName: String
    let peptideID: UUID
    var onActivate: (() -> Void)? = nil
    var onSkip: (() -> Void)? = nil

    @State private var selectedWeekday: Int = Calendar.current.component(.weekday, from: Date())
    @State private var selectedHour: Int = 9
    @State private var selectedMinute: Int = 0
    @State private var showWarning = false
    @AppStorage("hasSeenReminderWarning") private var hasSeenReminderWarning = false

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color(hex: "06B6D4"))
                    .padding(.top, 32)
                    .accessibilityHidden(true)

                Text(LocalizedStringKey("reminder.prompt.title"))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "F1F5F9"))
                    .multilineTextAlignment(.center)

                Text(LocalizedStringKey("reminder.prompt.subtitle"))
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "94A3B8"))
                    .multilineTextAlignment(.center)
            }

            // Day + Time pickers
            VStack(spacing: 12) {
                // Weekday picker
                Picker(selection: $selectedWeekday, label: EmptyView()) {
                    ForEach(1...7, id: \.self) { day in
                        Text(weekdayName(day)).tag(day)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 80)
                .clipped()

                // Time picker
                DatePicker(
                    selection: Binding(
                        get: { timeDate },
                        set: { updateTime($0) }
                    ),
                    displayedComponents: .hourAndMinute
                ) { EmptyView() }
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 80)
                .clipped()
                .tint(Color(hex: "06B6D4"))
            }
            .padding(.horizontal, 8)

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                Button(action: activateReminder) {
                    Text(LocalizedStringKey("reminder.prompt.cta"))
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "031820"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "06B6D4"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button(action: { onSkip?() }) {
                    Text(LocalizedStringKey("reminder.prompt.skip"))
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "64748B"))
                }
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .background(Color(hex: "0D1220"))
        .presentationDetents([.height(520)])
        .presentationBackground(Color(hex: "0D1220"))
        .sheet(isPresented: $showWarning) {
            ReminderWarningModal(onDismiss: {
                showWarning = false
                scheduleAndActivate()
            })
        }
    }

    // MARK: - Helpers

    private var timeDate: Date {
        Calendar.current.date(bySettingHour: selectedHour, minute: selectedMinute, second: 0, of: Date()) ?? Date()
    }

    private func updateTime(_ date: Date) {
        selectedHour = Calendar.current.component(.hour, from: date)
        selectedMinute = Calendar.current.component(.minute, from: date)
    }

    private func weekdayName(_ day: Int) -> String {
        let symbols = Calendar.current.weekdaySymbols
        guard day >= 1, day <= 7 else { return "" }
        return symbols[day - 1]
    }

    private func activateReminder() {
        if hasSeenReminderWarning {
            scheduleAndActivate()
        } else {
            showWarning = true
        }
    }

    private func scheduleAndActivate() {
        Task {
            let granted = await PeptidesNotificationManager.shared.requestPermission()
            if granted {
                await PeptidesNotificationManager.shared.scheduleReminder(
                    for: peptideName,
                    peptideID: peptideID,
                    weekday: selectedWeekday,
                    hour: selectedHour,
                    minute: selectedMinute
                )
            }
            onActivate?()
        }
    }
}

#Preview {
    WeeklyReminderPrompt(peptideName: "Semaglutide", peptideID: UUID())
}
