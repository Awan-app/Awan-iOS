import Common
import SwiftUI

struct OnboardingContainerView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var viewModel: OnboardingViewModel

    // Bug fix 1: internal back-history so the back button navigates within
    // the container instead of the NavigationStack popping to Welcome.
    @State private var stepHistory: [OnboardingRoute] = []
    // Bug fix 1: tracks direction so the transition flips correctly.
    @State private var isGoingBack: Bool = false

    var body: some View {
        // Bug fix 2: VStack instead of ZStack — header occupies its own space,
        // content flows directly below with no overlap and no zIndex needed.
        VStack(spacing: 0) {
            OnboardingStepHeader(
                currentStep: coordinator.onboardingCoordinator.containerStep.stepNumber,
                totalSteps: viewModel.totalSteps,
                onSkip: { viewModel.skipOnboarding() },
                onBack: stepHistory.isEmpty ? nil : { goBack() }
            )
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Group {
                switch coordinator.onboardingCoordinator.containerStep {
                case .yourName:
                    OnboardingYourNameView(
                        viewModel: viewModel,
                        onContinue: { advance(to: .wakeSleep) }
                    )
                case .wakeSleep:
                    OnboardingWakeSleepView(
                        viewModel: viewModel,
                        onContinue: { advance(to: .suggestedZones) }
                    )
                case .suggestedZones:
                    OnboardingSuggestedZonesView(
                        viewModel: viewModel,
                        onContinue: { advance(to: .taskLength) }
                    )
                case .taskLength:
                    TaskLength(
                        viewModel: viewModel,
                        onContinue: { advance(to: .taskSimulation) }
                    )
                case .taskSimulation:
                    TaskSimulation(
                        viewModel: viewModel,
                        onContinue: { advance(to: .notification) }
                    )
                case .notification:
                    NotificationView(
                        viewModel: viewModel,
                        onContinue: {
                            viewModel.notificationsEnabled = true
                            viewModel.completeOnboarding()
                        },
                        onSkipNotifications: {
                            viewModel.notificationsEnabled = false
                            viewModel.completeOnboarding()
                        }
                    )
                default:
                    EmptyView()  // .addRealTask is pushed externally, never matched here
                }
            }
            .id(coordinator.onboardingCoordinator.containerStep)
            .transition(contentTransition)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            LinearGradient(
                stops: [
                    .init(color: AppColors.skyGradientTop, location: 0.0),
                    .init(color: AppColors.skyGradientBottom, location: 0.5),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        // Hide the NavigationStack back button — in-container back is handled
        // by goBack() via the header's chevron, not the system back gesture.
        .navigationBarBackButtonHidden(true)
        .sensoryFeedback(
            .impact(weight: .light, intensity: 1.0),
            trigger: coordinator.onboardingCoordinator.containerStep
        )
    }

    // Directional transition: flips based on isGoingBack so content always
    // slides in the correct direction relative to flow.
    private var contentTransition: AnyTransition {
        isGoingBack
            ? .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity))
            : .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity))
    }

    private func advance(to step: OnboardingRoute) {
        // isGoingBack must be set BEFORE withAnimation so SwiftUI captures
        // the correct contentTransition value when evaluating the animation block.
        isGoingBack = false
        stepHistory.append(coordinator.onboardingCoordinator.containerStep)
        withAnimation(.easeInOut(duration: 0.3)) {
            coordinator.onboardingCoordinator.containerStep = step
        }
    }

    private func goBack() {
        guard let previous = stepHistory.popLast() else { return }
        isGoingBack = true
        withAnimation(.easeInOut(duration: 0.3)) {
            coordinator.onboardingCoordinator.containerStep = previous
        }
    }
}
