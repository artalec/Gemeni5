import SwiftUI
import AVFoundation

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @State private var devices: [AudioEngine.AudioDevice] = []
    @State private var selectedDeviceID: UInt32?

    let freqs = ["31.5", "50", "80", "125", "200", "315", "500", "800", "1.2k", "2k", "3.1k", "5k", "8k", "10k", "12.5k", "14k", "16k", "20k"]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Настройки звука и эквалайзера")
                .font(.headline)

            // Audio output device selection
            VStack(alignment: .leading, spacing: 6) {
                Text("Устройство вывода звука")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("", selection: $selectedDeviceID) {
                    Text("Системное по умолчанию").tag(UInt32?(nil))
                    ForEach(devices) { device in
                        Text(device.name).tag(UInt32?(device.id))
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedDeviceID) { newID in
                    model.setAudioDevice(id: newID)
                }
            }

            Divider()

            // 18-band Equalizer
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("18-полосный эквалайзер")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Сбросить EQ") {
                        model.resetEQ()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                }

                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .center, spacing: 14) {
                        ForEach(0..<18, id: \.self) { index in
                            VStack(spacing: 4) {
                                Text(String(format: "%.1f", model.state.settings.eqGains[index]))
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(.secondary)

                                Slider(
                                    value: Binding(
                                        get: { Double(model.state.settings.eqGains[index]) },
                                        set: { model.updateEQGain(at: index, value: Float($0)) }
                                    ),
                                    in: -24.0...24.0
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 24, height: 110)

                                Text(freqs[index])
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 36)
                        }
                    }
                    .padding(.vertical, 10)
                }
                .frame(height: 180)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                .cornerRadius(8)
            }

            HStack {
                Spacer()
                Button("Закрыть") {
                    model.isShowingSettings = false
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 720, height: 380)
        .onAppear {
            devices = model.audioEngine.getAudioOutputDevices()
            selectedDeviceID = model.state.settings.selectedAudioDeviceID
        }
    }
}
