// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("difficultyLevel") private var difficultyLevel = "Normal"
    
    var body: some View {
        Form {
            Toggle(isOn: $soundEnabled) {
                Text("Sound Effects")
            }
            
            Picker("Difficulty Level", selection: $difficultyLevel) {
                Text("Easy").tag("Easy")
                Text("Normal").tag("Normal")
                Text("Hard").tag("Hard")
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
