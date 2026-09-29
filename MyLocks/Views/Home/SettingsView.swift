import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    
    @State private var isRefreshing = false
    @State private var showRefreshAlert = false
    @State private var refreshMessage = ""
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(AppFonts.icon)
                            .foregroundStyle(AppColors.icon)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, AppSpacing.pageHorizontal)
                .padding(.top, AppSpacing.pageTop)
                
                // Title
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Settings")
                        .font(AppFonts.title)
                        .foregroundStyle(AppColors.titleText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.pageHorizontal)
                .padding(.top, AppSpacing.sectionTop)
                .padding(.bottom, AppSpacing.sectionBottom)
                
                // Settings content
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    // Language section
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Language")
                            .font(AppFonts.body)
                            .foregroundStyle(AppColors.secondaryText)
                        
                        VStack(spacing: 0) {
                            // English option
                            Button(action: {
                                selectedLanguage = "English"
                            }) {
                                HStack {
                                    Text("English")
                                        .font(AppFonts.body)
                                        .foregroundStyle(AppColors.primaryText)
                                    
                                    Spacer()
                                    
                                    if selectedLanguage == "English" {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(AppColors.accent)
                                    }
                                }
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.vertical, AppSpacing.md)
                                .background(AppColors.cardBackground)
                            }
                            .buttonStyle(.plain)
                            
                            Rectangle()
                                .fill(AppColors.separator)
                                .frame(height: 0.5)
                                .padding(.leading, AppSpacing.lg)
                            
                            // Chinese option
                            Button(action: {
                                selectedLanguage = "Chinese"
                            }) {
                                HStack {
                                    Text("中文")
                                        .font(AppFonts.body)
                                        .foregroundStyle(AppColors.primaryText)
                                    
                                    Spacer()
                                    
                                    if selectedLanguage == "Chinese" {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(AppColors.accent)
                                    }
                                }
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.vertical, AppSpacing.md)
                                .background(AppColors.cardBackground)
                            }
                            .buttonStyle(.plain)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: AppDimensions.radiusMD))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppDimensions.radiusMD)
                                .stroke(AppColors.separator.opacity(0.3), lineWidth: 0.5)
                        )
                    }
                }
                .padding(.horizontal, AppSpacing.pageHorizontal)
                
                // Data refresh section
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Data")
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.secondaryText)
                    
                    Button(action: {
                        Task {
                            await refreshData()
                        }
                    }) {
                        HStack {
                            if isRefreshing {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .frame(width: 20, height: 20)
                                Text("Refreshing...")
                                    .font(AppFonts.body)
                                    .foregroundStyle(AppColors.secondaryText)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(AppColors.accent)
                                Text("Refresh Data from Cloud")
                                    .font(AppFonts.body)
                                    .foregroundStyle(AppColors.primaryText)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.md)
                        .background(AppColors.cardBackground)
                    }
                    .buttonStyle(.plain)
                    .disabled(isRefreshing)
                    .clipShape(RoundedRectangle(cornerRadius: AppDimensions.radiusMD))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppDimensions.radiusMD)
                            .stroke(AppColors.separator.opacity(0.3), lineWidth: 0.5)
                    )
                    
                    Text("Load the latest cities and restaurant data from cloud sources")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.quaternaryText)
                        .padding(.horizontal, AppSpacing.sm)
                }
                .padding(.horizontal, AppSpacing.pageHorizontal)
                .padding(.top, AppSpacing.xl)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .alert("Refresh Complete", isPresented: $showRefreshAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(refreshMessage)
        }
    }
    
    // MARK: - Refresh Data
    
    private func refreshData() async {
        isRefreshing = true
        
        do {
            try await DataSeeder.refreshRestaurantData(from: ModelContainerProvider.shared)
            refreshMessage = "Data has been successfully updated from cloud sources."
            showRefreshAlert = true
        } catch {
            refreshMessage = "Failed to refresh data: \(error.localizedDescription)"
            showRefreshAlert = true
        }
        
        isRefreshing = false
    }
}
