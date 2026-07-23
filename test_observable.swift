import SwiftUI
import Observation

@MainActor
protocol ZoneManaging {
    var name: String { get set }
}

@Observable
class MyViewModel: ZoneManaging {
    var name = ""
}

struct MyView<VM: ZoneManaging & Observable>: View {
    @Bindable var vm: VM
    
    var body: some View {
        TextField("Name", text: $vm.name)
    }
}
