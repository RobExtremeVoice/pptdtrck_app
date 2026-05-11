import SwiftUI

// MARK: - InjectionSiteMapView

struct InjectionSiteMapView: View {

    @Binding var selectedSite: InjectionSite?
    let recentSites: [InjectionSite]
    var onConfirm: (() -> Void)? = nil

    @State private var showAsList = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 6) {
                Text(LocalizedStringKey("site.map.title"))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "F1F5F9"))

                Text(LocalizedStringKey("site.map.instruction"))
                    .font(.caption)
                    .foregroundStyle(Color(hex: "94A3B8"))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 16)
            .padding(.horizontal, 24)

            if showAsList {
                listMode
            } else {
                mapMode
            }

            // Legend
            legendRow
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

            // Toggle
            Button(action: { showAsList.toggle() }) {
                Text(LocalizedStringKey(showAsList ? "site.map.title" : "site.showlist"))
                    .font(.caption)
                    .foregroundStyle(Color(hex: "4A5580"))
            }
            .padding(.bottom, 16)

            // Confirm
            if selectedSite != nil {
                Button(action: { onConfirm?() }) {
                    Text(LocalizedStringKey("button.confirm"))
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "031820"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "06B6D4"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(Color(hex: "080C18"))
    }

    // MARK: - Map mode

    private var mapMode: some View {
        GeometryReader { geo in
            ZStack {
                // Body silhouette
                Image(systemName: "figure.stand")
                    .font(.system(size: min(geo.size.width, geo.size.height) * 0.85))
                    .foregroundStyle(Color(hex: "1E2640"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityHidden(true)

                // Site dots
                ForEach(InjectionSite.allCases, id: \.self) { site in
                    let pos = site.normalizedPosition
                    let x = geo.size.width * pos.x
                    let y = geo.size.height * pos.y

                    SiteDot(
                        site: site,
                        isSelected: selectedSite == site,
                        isRecent: recentSites.contains(site)
                    )
                    .position(x: x, y: y)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.25)) {
                            selectedSite = (selectedSite == site) ? nil : site
                        }
                    }
                }
            }
        }
        .frame(height: 280)
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }

    // MARK: - List mode

    private var listMode: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(InjectionSite.allCases, id: \.self) { site in
                    Button(action: {
                        withAnimation { selectedSite = (selectedSite == site) ? nil : site }
                    }) {
                        HStack {
                            Circle()
                                .fill(dotColor(site))
                                .frame(width: 12, height: 12)
                            Text(LocalizedStringKey(site.localizationKey))
                                .font(.subheadline)
                                .foregroundStyle(Color(hex: "F1F5F9"))
                            Spacer()
                            if selectedSite == site {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(hex: "06B6D4"))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(selectedSite == site ? Color(hex: "061E2A") : Color(hex: "131929"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 280)
        .padding(.vertical, 8)
    }

    // MARK: - Legend

    private var legendRow: some View {
        HStack(spacing: 16) {
            legendItem(color: "06B6D4", key: "site.legend.selected")
            legendItem(color: "FB923C", key: "site.legend.recent")
            legendItem(color: "061E2A", key: "site.legend.available")
        }
        .padding(.vertical, 8)
    }

    private func legendItem(color: String, key: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(Color(hex: color)).frame(width: 10, height: 10)
            Text(LocalizedStringKey(key))
                .font(.caption2)
                .foregroundStyle(Color(hex: "94A3B8"))
        }
    }

    private func dotColor(_ site: InjectionSite) -> Color {
        if selectedSite == site { return Color(hex: "06B6D4") }
        if recentSites.contains(site) { return Color(hex: "FB923C") }
        return Color(hex: "0891B2")
    }
}

// MARK: - SiteDot

private struct SiteDot: View {

    let site: InjectionSite
    let isSelected: Bool
    let isRecent: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(fillColor)
                .frame(width: 24, height: 24)
                .overlay(Circle().strokeBorder(borderColor, lineWidth: 1.5))
                .scaleEffect(isSelected ? 1.0 : 1.0)
                .animation(.spring(response: 0.25), value: isSelected)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(hex: "031820"))
                    .accessibilityHidden(true)
            }
        }
        .accessibilityLabel(Text(LocalizedStringKey(site.localizationKey)))
    }

    private var fillColor: Color {
        if isSelected { return Color(hex: "06B6D4") }
        if isRecent   { return Color(hex: "FB923C") }
        return Color(hex: "061E2A")
    }

    private var borderColor: Color {
        if isSelected { return Color(hex: "06B6D4") }
        if isRecent   { return Color(hex: "FB923C") }
        return Color(hex: "0891B2")
    }
}

#Preview {
    InjectionSiteMapView(
        selectedSite: .constant(.abdomenLowerLeft),
        recentSites: [.thighLeft, .thighRight]
    )
}
