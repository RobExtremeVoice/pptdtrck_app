import SwiftUI

// MARK: - ReminderWarningModal

struct ReminderWarningModal: View {

    @AppStorage("hasSeenReminderWarning") private var hasSeenReminderWarning = false
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color(hex: "1E1205"))
                    .frame(width: 72, height: 72)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color(hex: "FB923C"))
                    .accessibilityHidden(true)
            }
            .padding(.top, 32)

            Text(LocalizedStringKey("reminder.warning.title"))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color(hex: "F1F5F9"))
                .multilineTextAlignment(.center)

            Text(LocalizedStringKey("reminder.warning.body"))
                .font(.subheadline)
                .foregroundStyle(Color(hex: "94A3B8"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()

            Button(action: {
                hasSeenReminderWarning = true
                onDismiss?()
            }) {
                Text(LocalizedStringKey("reminder.warning.cta"))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "031820"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "06B6D4"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .background(Color(hex: "0D1220"))
        .presentationDetents([.height(460)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(hex: "0D1220"))
    }
}

#Preview {
    ReminderWarningModal()
}
